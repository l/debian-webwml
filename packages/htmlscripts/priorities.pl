use strict;
use warnings;

sub create_priorities() {
return (
'required'  => [ 'required' ],
'important' => [ 'important' ],
'standard'  => [ 'standard' ],
'optional'  => [ 'optional' ],
'extra'     => [ 'extra' ],
);
}

sub sorted_priorities() {
    return ( "required", "important", "standard", "optional", "extra" );
}

1;
