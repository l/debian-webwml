# Here is the syntax:
#  The data is in a hash table returned by init_translators().
#  Each key is the name of a translator (trimmed, without email adress)
# Here is the syntax:
#  The data is in a hash table returned by init_translators().
#  Each key is the name of a translator (trimmed, without email adress)
#  For each one, you have a (sub)hash table containing:
#  * email:    the current email of this guy
#  * compress: which type of compression you want to have (NOT YET IMPLEMENTED)
#  Remaining keys have numeric value, which tells when to send info:
#  * summary:  a summary of which documents are outdated
#  * logs:     the cvs log' between the translated and current versions
#  * diff:     idem with diff
#  * file:     add current version of translated file

sub init_translators {
    my $translators = {
	'Gustavo Noronha' => {
	    'email'     => 'kov@debian.org',
	    'summary'   => 3,
	    'logs'      => 3,
	    'diff'      => 0,
	    'tdiff'     => 0,
	    'file'      => 0,
	    'compress'  => 'none'
	    },
		
		'Carlos Laviola' => {
		    'email'     => 'claviola@debian.org',
		    'summary'   => 3,
		    'logs'      => 3,
		    'diff'      => 0,
		    'tdiff'     => 0,
		    'file'      => 0,
		    'compress'  => 'none'
		    },
			
			'Eduardo Macan' => {
			    'email'     => 'macan@debian.org',
			    'summary'   => 3,
			    'logs'      => 3,
			    'diff'      => 0,
			    'tdiff'     => 0,
			    'file'      => 0,
			    'compress'  => 'none'
			    },
				'Philipe Gaspar' => {
				    'email' => 'kr0n@uol.com.br',
				    'summary' => 3,
				    'logs'      => 3,
				    'diff'      => 0,
				    'tdiff'     => 0,
				    'file'      => 0,
				    'compress'  => 'none'
				    },
					'list' => {
					    # this is a special name containing the default addressee
					    'email'     => 'debian-l10n-portuguese@lists.debian.org',
					    'missing'   => 1,
					    'summary'   => 2,
					    'logs'      => 0,
					    'diff'      => 0,
					    'tdiff'     => 0,
					    'file'      => 0,
					    'compress'  => 'none'
					    }
    };
    return $translators;
}

1;
