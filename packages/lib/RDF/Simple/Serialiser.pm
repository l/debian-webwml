package RDF::Simple::Serialiser;

use strict;
use Template;
use Storable qw(dclone);
use RDF::Simple::NS;
use Class::MethodMaker
  new_hash_init => 'new', get_set => [ qw{ baseuri path nodeid_prefix}];

our $VERSION = '0.1';

sub serialise {
    my ($self,@triples) = @_;
    my %object_ids;
    foreach (@triples) {
        push @{$object_ids{$_->[0]}}, dclone $_;
    }
    my @objects;

    foreach my $k (keys %object_ids) {
        push @objects, $self->make_object(@{$object_ids{$k}});
    }

    my $out;
    $self->render($self->get_template,{objects => \@objects},\$out);
    return $out;
}

sub serialize {
    my $self = shift;
    return $self->serialise(@_);
}

sub make_object {
    my ($self,@triples) = @_;
    my $object;
    my $rdf = $self->ns;
    my $pref = $self->nodeid_prefix || '_id:';
    @triples = map {$_->[1] = $rdf->qname($_->[1]); $_} @triples;

    my ($class) = grep {$_->[1] eq 'rdf:type'} @triples;

    foreach my $t (@triples) {
	$self->used($t->[1]); 
	my $qn = $rdf->qname($t->[0]);
	if ($qn ne $t->[0]) {
	    $self->used($qn);
	}
    }
    $self->used('rdf:Description');

    # find out if this bag of triples has a Class; generic Description if not
    if ($class) {
        $object->{Class} = $rdf->qname($class->[2]);
        $self->used( $object->{Class} );
    }
    else {
        $object->{Class} = 'rdf:Description';
    }

    # assign identifier as an arbitrary (but resolving) uri
    my $id = $triples[0]->[0];
    if (($id =~ m/^http/) or ($id =~ m/^\#/)) {
        $object->{Uri} = $id;
    }
    else {
        $id =~ s/^[^a..Z]/a/; # stupid xml naming conventions
        $id =~ s/\W//g;
	$object->{NodeId} = $id;
    }

    foreach my $statement (@triples) {
        next if $statement->[1] eq 'rdf:type';
        if ($statement->[2] =~ m/^$pref/) {
            $statement->[2] =~ s/^[^a..Z]/a/;
	    $statement->[2] =~ s/\W//g;
            push @{ $object->{nodeid}->{$statement->[1]} },$statement->[2];
        }
        elsif (($statement->[2] =~ m/^\w+\:/) or ($statement->[2] =~ m/^\#/)) {
            push @{ $object->{resource}->{$statement->[1]} }, $statement->[2];
        }
        else {
            # make safe for xml
            my %escape = ('<'=>'&lt;', '>'=>'&gt;', '&'=>'&amp;', '"'=>'&quot;');
    	    my $escape_re  = join '|' => keys %escape;
    	    $statement->[2] =~ s/($escape_re)/$escape{$1}/g;    
	    push @{ $object->{literal}->{$statement->[1]} }, $statement->[2];
        }
    }
    return $object;
}

sub render {
    my ($self,$template,$data,$out_object) = @_;
    my $tt = $self->tt;
    my $used = $self->used;
    #$data->{ns} = { $self->ns->lookup };
    my %ns_lookup = $self->ns->lookup;
    foreach (keys %$used) {
        $data->{ns}{$_} = $ns_lookup{$_}
    }

    eval {
        $tt->process($template, $data, $out_object);
    };
    if (my $error = $tt->error()) {
        warn "error info: ", $error->info(), "\n";
        warn $tt->error();
    }
    warn($@) if ($@);
}

##

sub addns {
    my ($self, %p) = @_;
    return $self->ns->lookup(%p);
}

sub genid {
    my $self = shift;
    my $prefix = $self->nodeid_prefix || '_id:';
    my @num = (0..9);
    my $string = join '', (map { @num[rand @num] } 0..7);
    return $prefix.$string;
}

sub ns {
    my $self = shift;
    return $self->{_rdfns} if $self->{_rdfns};
    $self->{_rdfns} = RDF::Simple::NS->new;
}

sub used {
    my ($self, $uri) = @_;
    if ($uri and ($uri !~ m/^http/)) {	
    	my $pref = $self->ns->prefix($uri);
	$self->{_used_entities}->{ $pref } = 1 if $pref;
    }
    return $self->{_used_entities};
}

sub tt {
    my ($self) = @_;
    return $self->{tt} if $self->{tt};
    $self->{tt} = Template->new();
}

sub get_template {

    my $template = <<'END_TEMPLATE';
<rdf:RDF
[%- FOREACH key = ns.keys %]
  xmlns:[% key %]="[% ns.$key %]"
[%- END %]
>
[% FOREACH object = objects %]
<[% object.Class %][% IF object.Uri %] rdf:about="[% object.Uri %]"[% ELSE %] rdf:nodeID="[% object.NodeId %]"[% END %]>
    [% FOREACH lit = object.literal.keys %][% FOREACH prop = object.literal.$lit %]
    <[% lit %]>[% prop %]</[% lit %]>[% END %][% END %][% FOREACH res = object.resource.keys %][% FOREACH prop = object.resource.$res %]
    <[% res %] rdf:resource="[% prop %]"/>[% END %][% END %][% FOREACH node = object.nodeid.keys %][% FOREACH prop = object.nodeid.$node %]
    <[% node %] rdf:nodeID="[% prop %]"/>[% END %][% END %]

</[% object.Class %]>
[% END %]

</rdf:RDF>

END_TEMPLATE

    return \$template;
}


package RDF::Simple::Serializer;

use base qw(RDF::Simple::Serialiser);

1;


=head1 NAME

    RDF::Simple::Serialiser

=head1 DESCRIPTION

    a simple RDF serialiser. accepts an array of triples, returns a serialised RDF document.

=head1 SYNOPSIS

    my $ser = RDF::Simple::Serialiser->new;

    my @triples = (
                   ['http://example.com/url#', 'dc:creator', 'zool@example.com'],
                   ['http://example.com/url#', 'foaf:Topic', '_id:1234'],
                   ['_id:1234','http://www.w3.org/2003/01/geo/wgs84_pos#lat','51.334422']
                   );

    my $rdf = $ser->serialise(@triples);

    ##
    ## supply own bNode id prefix, add namespaces

    my $ser = RDF::Simple::Serialiser->new( nodeid_prefix => 'a:' );

    $ser->addns( foaf => 'http://xmlns.com/foaf/0.1/' );

    my $node1 = $ser->genid;
    my $node2 = $ser->genid;

    my @triples = (
                   [$node1, 'foaf:name', 'Jo Walsh'],
                   [$node1, 'foaf:knows', $node2],
                   [$node2, 'foaf:name', 'Robin Berjon'],
                   [$node1, 'rdf:type', 'foaf:Person'],
                   [$node2, 'rdf:type','http://xmlns.com/foaf/0.1/Person']
                   );

    my $rdf = $ser->serialise(@triples);

    ##
    ## round-trip

    my $parser = RDF::Simple::Parser->new();
    my $rdf = LWP::Simple::get('http://www.zooleika.org.uk/foaf.rdf');

    my @triples = $parser->parse_rdf($rdf);
    my $new_rdf = $serialiser->serialise(@triples);


=head1 METHODS

=head2 new( [ nodeid_prefix => 'prefix' ])

=head2 serialise( @triples )


    accepts a 'bucket of triples'
    (an array of array references which are
    'subject, predicate, object' statements)
    and returns a serialised RDF document.

    if 'rdf:type' is not provided for a subject,
    the generic node type 'rdf:Description' is used.


=head2 genid( )


    generates a random identifier for use as a bNode
    (anonymous node) nodeID.
    if nodeid_prefix is set, the generated id uses the prefix,
    followed by 8 random numbers.


=head2 addns( qname => 'http://example.com/rdf/vocabulary#',
              qname2 => 'http://yetanother.org/vocabulary/' )


    add new namespaces to the RDF document.
    a namespace must exist for each predicate used in a triple.
    the RDF::Simple::NS module which supports this one
    provides the following vocabularies by default
    (you can override them if wished)

        foaf => 'http://xmlns.com/foaf/0.1/',
        dc => 'http://purl.org/dc/elements/1.1/',
        rdfs => "http://www.w3.org/2000/01/rdf-schema#",
        daml => 'http://www.w3.org/2001/10/daml+oil#',
        space => 'http://frot.org/space/0.1/',
        geo => 'http://www.w3.org/2003/01/geo/wgs84_pos#',
        rdf => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        owl => 'http://www.w3.org/2002/07/owl#',
        ical => 'http://www.w3.org/2002/12/cal/ical#',
        dcterms=>"http://purl.org/dc/terms/",
        wiki=>"http://purl.org/rss/1.0/modules/wiki/",
        chefmoz=>"http://chefmoz.org/rdf/elements/1.0/",


=head1 BUGS

    Probably still some left, this is a beta release. feedback very welcome.

=head1 NOTES

    I am English, so this is a Serialiser. for our divided friends across the water, RDF::Simple::Serializer will work as an alias to the module, and serialize() does the same as serialise().
 
    Neither parser or serialiser makes an effort to differentiate formally between URIs and literals, as is more general RDF practise. This was a conscious effort to keep things simple, but i plan to add a make_life_complex option to both.

=head1 THANKS

    Thanks particularly to Tom Hukins, Paul Mison, and Richard Clamp, for providing patches.

=head1 AUTHOR

    jo walsh <jo@london.pm.org>

=head1 LICENSE

    this module is available under the same terms as perl itself.

=cut
