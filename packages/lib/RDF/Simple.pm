
package RDF::Simple;
use strict;

our $VERSION = 0.15;

sub new
{
        my ($class, %parameters) = @_;

        my $self = bless ({}, ref ($class) || $class);

        return ($self);
}

=head1 NAME

RDF::Simple - read and write RDF without complication

=head1 DESCRIPTION

    This package is for very simple manipulations
    of RDF/XML serialisations of RDF graphs. 
    It consists of:

    RDF::Simple::Parser
    RDF::Simple::Serialiser
    
    Please consult the individual pod for these packages.
    The parser requires XML::SAX,
    The serialiser requires Template Toolkit (Template)

    Also provided is RDF::Simple::NS,
    a utility class for XML namespaces in RDF

    The aim here is to keep things Simple: 
    e.g., the parser doesn't differentiate between
    literal and resource values in the model
    All you get back is a bucket-o-triples
    (array of arrays)
    
    Use the parser to read RDF that you recieve.
        
    The serialiser does its best to do DWYM. Use the
    serialiser to build RDF to send to others.

    If you want a more complex and involved RDF API,
    I'd suggest looking at RDF::Core
    or at the redland RDF application toolkit
    at http://www.redland.opensource.ac.uk
    
    This is an early alpha release, and likely contains bugs.
    Please report them!

=head1 AUTHOR
    
    Jo Walsh <jo@london.pm.org>

=head1 THANKS

    Sean Palmer, Paul Mison, Matt Biddulph, Tom Hukins, Richard Clamp 

    Openmute - http://www.metamute.com - for general support
	
=head1 LICENSE

    This package and its contents are available 
    under the same terms as perl itself

=cut

1;
__END__

