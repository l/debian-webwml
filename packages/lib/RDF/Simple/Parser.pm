package RDF::Simple::Parser;

use strict;
use XML::SAX qw(Namespaces Validation);
use LWP::UserAgent;

our $VERSION = '0.2';

use Class::MethodMaker new_hash_init => 'new', get_set => [ qw(base http_proxy)];

sub parse_rdf {
    my ($self,$rdf) = @_;
    my $sink = RDF::Simple::Parser::Sink->new;

    my $factory = XML::SAX::ParserFactory->new();
    $factory->require_feature(Namespaces);
    my $handler = RDF::Simple::Parser::Handler->new($sink, qnames => 1, base => $self->base );
    my $parser = $factory->parser(Handler=>$handler);
    eval {	
    	$parser->parse_string($rdf);
    };
    return if $@;	
    my $result = $handler->result;	
    return @{ $result } if $result;
}

sub parse_uri {
    my ($self,$uri) = @_;
    my $rdf;
    eval {
    	$rdf = $self->ua->get($uri)->content;
    };
    warn ($@) if $@;
    if ($rdf) {
	$self->base($uri);
    	return $self->parse_rdf($rdf);
    }
    return undef;
}

sub ua {
    my $self = shift;
    unless ($self->{_ua}) {
        $self->{_ua} = LWP::UserAgent->new(timeout => 30);
        if ($self->http_proxy) {
            $self->{_ua}->proxy('http',$self->http_proxy);
        } else {
            $self->{_ua}->env_proxy;
        }
    }
    return $self->{_ua};
}

package RDF::Simple::Parser::Handler;

use strict;
use RDF::Simple::NS;
use Carp;
use Data::Dumper;
use Class::MethodMaker get_set => [qw( stack base genID disallowed qnames result bnode_absolute_prefix )];

sub addns {
    my ($self,$prefix,$uri) = @_;
    $self->ns->lookup($prefix,$uri);
}

sub ns {
    my $self = shift;
    return $self->{_ns} if $self->{_ns};
    $self->{_ns} = RDF::Simple::NS->new;
}


sub new {
    my ($class,$sink, %p) = @_;
    my $self = bless {}, ref $class || $class;
    $self->base($p{'base'});
    $self->qnames($p{qnames});
    $self->genID(1);
    $self->stack([]);
    my @dis;
    foreach (('RDF','ID','about','bagID','parseType','resource','nodeID','datatype','li','aboutEach','aboutEachPrefix')) {
        push @dis, $self->ns->uri('rdf').$_;
    }
    $self->disallowed(\@dis);
    return $self;
}

sub triple {
    my ($self,$s,$p,$o) = @_;
    my $r = $self->result;
    push @$r, [$s,$p,$o];
#    $r .= join(' ',($s,$p,$o))."\n";
    $self->result($r);
}

sub start_element {
    my ($self,$sax) = @_;
    my $e;
    my ($name,$ns,$qname,$prefix) = ($sax->{LocalName},$sax->{NamespaceURI},$sax->{Name},$sax->{Prefix});
    my $stack = $self->stack;
    if (scalar(@$stack) > 0) {
        $e = RDF::Simple::Parser::Element->new($ns,$prefix,$name,$stack->[-1], RDF::Simple::Parser::Attribs->new($sax->{Attributes},$self->qnames),qnames => $self->qnames,base=> $self->base);
    }
    else {

        $e = RDF::Simple::Parser::Element->new($ns,$prefix,$name,undef, RDF::Simple::Parser::Attribs->new($sax->{Attributes},$self->qnames),qnames => $self->qnames,base=>$self->base);
    }

    push @{$e->xtext}, $e->qname.$e->attrs;
    push @{$stack}, $e;
    $self->stack($stack);
}

sub characters {
    my ($self,$chars) = @_;
    my $stack = $self->{stack} || [];
    $stack->[-1]->{text} = $chars->{Data};
    $stack->[-1]->{xtext}->[-1] = $chars->{Data};
    $self->stack($stack);
}

sub end_element {
    my ($self,$sax) = @_;
    my $name = $sax->{LocalName};
    my $qname = $sax->{Name};
    my $stack = $self->stack;
    my $element = pop @{$stack};
    $element->{xtext}->[2] .= '</'.$element->{qname}.'>';
    if (scalar(@$stack) > 0) {
        my $kids = $stack->[-1]->children || [];
        push @$kids, $element;
        $stack->[-1]->children($kids);
        @{ $element->{xtext} } = grep { defined($_) } @{ $element->{xtext} };
        $stack->[-1]->{xtext}->[1] = join('',@{$element->{xtext}});
        $self->stack($stack);
    }
    else {
        $self->document($element);
    }
}

sub uri {
    my ($self,$uri) = @_;
    # losing the angle brackets for sake of Simplicity
    return "$uri";
}

sub bNode {
    my ($self, $id, %p) = @_;

#    if (my $l = $p{label}) {
#        if ($l->[0] !~ m/^\w+$/) {
#            $l = 'b'.$l;
#            # very unsure
#            $l =~ s/^i([rd]+)/ir$1/;
#            return $l;
#        }
#    }
    my $n_id = sprintf("_:id%08x%04x", time, int rand 0xFFFF);
    $n_id = $self->bnode_absolute_prefix.$n_id if $self->bnode_absolute_prefix;
    return $n_id;
}

sub literal {
    my ($self,$string,$attrs) = @_;
    if ($attrs->{lang} and $attrs->{dtype}) {
        die "can't have both lang and dtype";
    }
    return $string;
#r_quot = re.compile(r'([^\\])"')

#      return ''.join(('"%s"' %
# r_quot.sub('\g<1>\\"',
#`unicode(s)`[2:-1]),
#          lang and ("@" + lang) or '',
# dtype and ("^^<%s>" % dtype) or ''))

}

sub document {
    my ($self,$doc) = @_;
    warn("couldn't find rdf:RDF element") unless $doc->URI eq $self->ns->uri('rdf').'RDF';
    my @children = @{$doc->children} if $doc->children;
    unless (scalar(@children) > 0) {
        warn("no rdf triples found in document!");
        return;
    }
    foreach my $e (@children) {
        $self->nodeElement($e);
    }
}


sub nodeElement {
    my ($self,$e) = @_;
    my $dissed =  $self->disallowed;
    my $dis = grep {$_ eq $e->URI} @$dissed;
    warn("disallowed element used as node") if $dis;
    my $rdf = $self->ns->uri('rdf');

    my $base = $e->base || $self->base;
    if ($e->attrs->{$rdf.'ID'}) {
        $e->subject( $self->uri( join('',($base,'#',$e->attrs->{$rdf.'ID'})) ));
    }
    elsif ($e->attrs->{$rdf.'about'}) {
        $e->subject( $self->uri( $e->attrs->{$rdf.'about'} ));
    }
    elsif ($e->attrs->{$rdf.'nodeID'}) {
        $e->subject( $self->bNode($e->attrs->{$rdf.'nodeID'}) );
    }
    elsif (not $e->subject) {
        $e->subject($self->bNode);
    }

    if ($e->URI ne $rdf.'Description') {
        $self->triple($e->subject,$rdf.'type',$self->uri($e->URI));
    }
    if ($e->attrs->{$rdf.'type'}) {
        $self->triple($e->subject,$rdf.'type',$self->ns->uri($e->{$rdf.'type'}));
    }
    foreach my $k (keys %{$e->attrs}) {
        my $dis = $self->disallowed;
        push @$dis, $rdf.'type';

        my ($in) = grep {/$k/} @$dis;
        if (not $in) {
            my $objt = $self->literal($e->attrs->{$k},$e->language);
            $self->triple($e->subject,$self->uri($k),$objt);
        }
    }
    my $children = $e->children;

    foreach (@$children) {
        $self->propertyElt($_);
    }
}

sub propertyElt {
    my ($self,$e) = @_;

    my $rdf = $self->ns->uri('rdf');
    if ($e->URI eq $rdf.'li') {
        $e->parent->{liCounter} ||= 1;
        $e->URI($rdf.$e->parent->{liCounter});
        $e->parent->{liCounter}++;
    }
    my $children = $e->children || [];

    if ((scalar(@$children) eq 1) and (not $e->attrs->{$rdf.'parseType'})) {
        $self->resourcePropertyElt($e);
    }
    elsif ((scalar(@$children) eq 0) and $e->text) {
        $self->literalPropertyElt($e);
    }
    elsif (my $ptype = $e->attrs->{$rdf.'parseType'}) {
        if ($ptype eq 'Resource') {
            $self->parseTypeResourcePropertyElt($e);
        }
        elsif ($ptype eq 'Collection') {
            $self->parseTypeCollectionPropertyElt($e);
        }
        else {
            $self->parseTypeLiteralPropertyElt($e);
        }
    }
    elsif (not $e->text) {
        $self->emptyPropertyElt($e);
    }

}

sub resourcePropertyElt {
    my ($self,$e) = @_;

    my $rdf = $self->ns->uri('rdf');
    my $n = $e->children->[0];
    $self->nodeElement($n);
    if ($e->parent) {
        $self->triple($e->parent->subject,$self->uri($e->URI),$n->subject);
    }
    if ($e->attrs->{$rdf.'ID'}) {
        my $base = $e->base || $self->base;
        my $i = $self->uri(join($base,'#'.$e->attrs->{$rdf.'ID'}));
        $self->reify($i,$e->parent->subject,$self->uri($e->URI),$n->subject);
    }
}

sub reify {
    my ($self,$r,$s,$p,$o) = @_;
    my $rdf = $self->ns->uri('rdf');
    $self->triple($r,$self->uri($rdf.'subject'),$s);
    $self->triple($r,$self->uri($rdf.'predicate'),$p);
    $self->triple($r,$self->uri($rdf.'object'),$o);
    $self->triple($r,$self->uri($rdf.'type'),$self->uri($rdf.'Statement'));
}

sub literalPropertyElt {
    my ($self,$e) = @_;
    my $base = $e->base || $self->base;
    my $rdf = $self->ns->uri('rdf');
    my $o = $self->literal($e->text,$e->language,$e->attrs->{$rdf.'datatype'});
    $self->triple($e->parent->subject,$self->uri($e->URI),$o);
    if ($e->attrs->{$rdf.'ID'}) {
        my $i = $self->uri(join($base,'#'.$e->attrs->{$rdf.'ID'}));
        $self->reify($i,$e->parent->subject, $self->uri($e->URI),$o);
    }
}

sub parseTypeLiteralOrOtherPropertyElt {
    my ($self,$e) = @_;
    my $base = $e->base || $self->base;
    my $rdf = $self->ns->uri('rdf');
    my $o = $self->literal($e->xtext->[1],$e->language,$rdf.'XMLLiteral');
    $self->triple($e->parent->subject,$self->uri($e->URI),$o);
    if ($e->attrs->{$rdf.'ID'}) {
        my $i = $self->uri(join($base,'#'.$e->attrs->{$rdf.'ID'}));
        $e->subject($i);
        $self->reify($i,$e->parent->subject,$self->URI($e->URI),$o);
    }
}

sub parseTypeResourcePropertyElt {
    my ($self,$e) = @_;
    my $n = $self->bNode;
    $self->triple($e->parent->subject,$self->uri($e->URI),$n);

    my $c = RDF::Simple::Parser::Element->new('http://www.w3.org/1999/02/22-rdf-syntax-ns#','rdf','Description',$e->parent,$e->attrs,qnames=>$self->qnames,base=>$e->base);
    $c->subject($n);
    my @c_children;
    my $children = $e->children;
    foreach (@$children) {
        $_->parent($c);
        push @c_children, $_;
    }
    $c->children(\@c_children);
    $self->nodeElement($c);
}

sub parseTypeCollectionPropertyElt {
    my ($self,$e) = @_;
    my $rdf = $self->ns->uri('rdf');
    my $children = $e->children;
    my @s;
    foreach (@$children) {
        $self->nodeElement($_);
        push @s, $self->bNode;
    }
    if (scalar(@s) eq 0) {
        $self->triple($e->parent->subject,$self->uri($e->URI),$self->uri($rdf.'nil'));
    }
    else {
        $self->triple($e->parent->subject,$self->uri($e->URI),$s[0]);
        foreach my $n (@s) {
            $self->triple($n,$self->uri($rdf.'type'),$self->uri($rdf.'List'));
        }
        for (0 .. $#s) {
            $self->triple($s[$_],$self->uri($rdf.'first'),$e->children->[1]->subject);
        }
        for (0 .. ($#s-1)) {
            $self->triple($s[$_],$self->uri($rdf.'rest'),$s[$_+1]);
        }
        $self->triple($s[-1],$self->uri($rdf.'rest'),$self->uri($rdf.'nil'));
    }

}

sub emptyPropertyElt {
    my ($self,$e) = @_;
    my $rdf = $self->ns->uri('rdf');
    my $base = $e->base or $self->base;
    $base ||= '';
    my @keys = keys %{$e->attrs};
    my $ids = $rdf.'ID';
    my ($id) = grep {/$ids/} @keys;
    my $r;
    if ($id) {
        $r = $self->literal($e->text,$e->language); # was o
        $self->triple($e->parent->subject,$self->uri($e->URI),$r);
    }
    else {
        if ($e->attrs->{$rdf.'resource'}) {
            my $res = $e->attrs->{$rdf.'resource'};
	    $res ||= '';
            $res = $base.$res if $res !~ m/\:\/\//;
            $r = $self->uri($res);
        }
        elsif ($e->attrs->{$rdf.'nodeID'}) {
            $r = $self->bNode($e->attrs->{$rdf.'nodeID'});
        }
        else {
            $r = $self->bNode;
        }

        my $dis = $self->disallowed;
        my @a = map { grep {!/$_/} @$dis } keys %{$e->attrs};

        foreach my $a (@a) {
            if ($a ne $rdf.'type') {
                my $o = $self->literal($e->attrs->{$a},$e->language);
                $self->triple($r,$self->uri($a),$o);
            }
            else {
                $self->triple($r,$self->uri($rdf.'type'),$self->uri($e->attrs->{$a}));
            }
        }
        $self->triple($e->parent->subject,$self->uri($e->URI),$r);
    }
    if ($e->attrs->{$rdf.'ID'}) {
        my $i = $self->uri(join($base,'#'.$e->attrs->{$rdf.'ID'}));
        $self->reify($i,$e->parent->subject,$self->uri($e->URI,$r));
    }

}

package RDF::Simple::Parser::Element;

use Class::MethodMaker get_set => [qw( base subject language URI qname attrs parent children xtext text )];
use Data::Dumper;

sub new {
    my ($class,$ns,$prefix,$name,$parent,$attrs,%p) = @_;
    my $self = bless {}, ref $class || $class;
    my $base = $attrs->{base};
    $base ||= $parent->{base};
    $base ||= $p{base};
    $self->base($base);
    $self->URI($ns.$name);
    $self->qname($ns.':'.$name);
    $self->attrs($attrs);
    $self->parent($parent) if $parent;
    $self->xtext([]);
    return $self;
}

package RDF::Simple::Parser::Attribs;
use Class::MethodMaker get_set => [qw( qnames x )];
use Data::Dumper;
use Carp;

sub new {
    my ($class, $attrs) = @_;

    my $self = bless {}, ref $class || $class;
    while (my ($k,$v) = each %{$attrs}) {

        my ($p,$n) = ($v->{NamespaceURI},$v->{LocalName});
        $self->{$p.$n} = $v->{Value};
    }
    return $self;
}

package RDF::Simple::Parser::Sink;

use Class::MethodMaker new_hash_init => 'new', get_set => [ qw(result) ];

sub write {
    my $self = shift;
    print $self->result;

}


1;

=head1 NAME

    RDF::Simple::Parser

=head1 DESCRIPTION

    a simple RDF/XML parser - 
    reads a string containing RDF in XML
    returns a 'bucket-o-triples' (array of arrays)


=head1 SYNOPSIS

    my $uri = 'http://www.zooleika.org.uk/bio/foaf.rdf';
    my $rdf = LWP::Simple::get($uri);
 
    my $parser = RDF::Simple::Parser->new(base => $uri)
    my @triples = $parser->parse_rdf($rdf);
    
    # returns an array of array references which are triples


=head1 METHODS 

=head2 new( [ base => 'http://example.com/foo.rdf' ])

    create a new RDF::Simple::Parser
    
    'base' supplies a base URI 
    for relative URIs found in the document

    'http_proxy' optionally supplies
    the address of an http proxy server.
    If this is not given it will try to use 
    the default environment settings.

    
=head2 parse_rdf($rdf)

    accepts a string which is an RDF/XML document
    (complete XML, with headers)

    returns an array of array references which are RDF triples.

=head2 parse_uri($uri)

    accepts a string which is a fully qualified http:// uri
    at which some valid RDF lives.
    returns the same thing as parse_rdf
    
=head1 NOTES

    This parser is a transliteration of 
    Sean B Palmer's python RDF/XML parser:

    http://www.infomesh.net/2003/rdfparser/    

    Thus the idioms inside are a bit pythonic.
    Most credit for the effort is due to sbp.
    


=head1 AUTHOR

    Jo Walsh <jo@london.pm.org>

=head1 CREDITS 

    thanks to Robert Price for the http_proxy patch

=head1 LICENSE

   this module is available under the same terms as perl itself

=cut



