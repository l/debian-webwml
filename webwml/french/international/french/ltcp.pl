#!/usr/bin/perl
#  Copyright 2001 Denis Barbier <barbier@debian.org>
#  Copyright 2000 Javier Fernández-Sanguino Peña <jfs@computer.org>
#  Copyright 1998-2000 Christophe Le Bars <clebars@debian.org>
#  Copyright 1998 Paolo Molaro <lupus@debian.org> for update_db_CVS load_entries check_file
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

require 'translator.db.pl';

$translators = init_translators();

# $t : current document record
# $k : current document key
# $f : current document field

$types = {
        'Web' => {
                'name'          => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$k.en.html" },
                'url'           => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "http://www.debian.org/$k.en.html" },
                'mtime'         => sub {
my($t, $k, $f) = @_; return undef if !$t->{$f}; my @tm = localtime($t->{$f}); return spokendate((1900+$tm[5]).'-'.$tm[4].'-'.$tm[3]) },
                'cvs_url'       => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$CVSWEB/webwml/$from/$k.wml?cvsroot=webwml" },
                'source_url'    => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$CVSWEB/webwml/$from/$k.wml?cvsroot=webwml&amp;rev=$t->{'revision'}" },
                'translation_name'      => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$k.$to_abr.html" },
                'translation_url'       => sub {
my($t, $k, $f) = @_; return $t->{$f} if $t->{$f}; return $t->{'status'} <= 1 ? undef : "http://www.debian.org/$k.$to_abr.html" },
                'translation_cvs_url'   => sub {
my($t, $k, $f) = @_; return $t->{$f} if $t->{$f}; return $t->{'status'} <= 1 ? undef : "$CVSWEB/webwml/$to/$k.wml?cvsroot=webwml" },
                'translation_source_url'=> sub {
my($t, $k, $f) = @_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} : "$CVSWEB/webwml/$to/$k.wml?cvsroot=webwml&amp;rev=$t->{'translation_revision'}" },
                'translation_source_name'=> sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$k.wml" },
                'diff'          => sub {
my($t, $k, $f) = @_; return (!$t->{'base_revision'} || !$t->{'revision'} || $t->{'base_revision'} == $t->{'revision'}) ? undef : "$CVSWEB/webwml/$from/$k.wml?cvsroot=webwml&amp;r1=$t->{'base_revision'}&amp;r2=$t->{'revision'}" },
                'lines'         => sub {
my($t, $k, $f) = @_; my $file = "$(ENGLISHDIR)/".$k.".wml"; return undef if ! -f $file; my $line_string=`wc -l $file`; $line_string=~s/\Q$file\E//; return $line_string;},
},

        'DDP' => {
                'url'           => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "http://www.debian.org/doc/manuals/$k/" },
                'cvs_url'       => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$CVSWEB/ddp/manuals.sgml/$k/?cvsroot=debian-doc" },
                'source_url'    => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$CVSWEB/ddp/manuals.sgml/$k/$k.sgml?cvsroot=debian-doc" },
                'translation_url'       => sub {
my($t, $k, $f) = @_; return ($t->{$f} || $t->{'status'} == 0 || $t->{'status'} == 1 || $t->{'status'} == 2 || $t->{'status'} == 8) ? $t->{$f} : "#" },
                'translation_source_name'       => sub {
my($t, $k, $f)=@_; return $t->{$f} ? $t->{$f} : "$k.fr.sgml" },
                'translation_source_url'        => sub {
my($t, $k, $f)=@_; return ($t->{$f} || $t->{'status'} == 0 || $t->{'status'} == 1 || $t->{'status'} == 2 || $t->{'status'} == 8) ? $t->{$f} : "$CVSWEB/ddp/manuals.sgml/$k/$k.fr.sgml?cvsroot=debian-doc" },
        },
};

sub update_db_format {
# Goes through the database and adds all the information
# not included there but easy to extract
        my ($k, $t);

        while (($k, $t) = each %$translations) {
        
                next unless ($k);

                foreach my $f (keys %{$types->{$t->{'type'}}}) {
                        $t->{$f} = &{$types->{$t->{'type'}}->{$f}}($t, $k, $f);
                } 

                if ($k eq "international/$to") {
                        my $f;

                        foreach $f ('name', 'sub_name', 'revision', 'url', 'cvs_url', 'source_url', 'package') {
                                my $tmp = $t->{$f};
                                $t->{$f} = $t->{'translation_'.$f};
                                $t->{'translation_'.$f} = $tmp;
                        }

                        $t->{'base_revision'} = '';
                }
        }
}

sub dump_html {

        my ($status, $type) = @_;
        my ($k, $t);
        my $found = 0;

        foreach $k (sort keys %$translations) {
                $t = $translations->{$k} ;

                print STDERR "(dump_html) Dumping $k, $t\n" if $debug;
                if ($debug) {
                        foreach my $l (sort keys %$t) {
                                print STDERR "\t$l -> $t->{$l}\n";
                        }
                }

                next if ($t->{'status'} ne $status and $status != -1);
                next if ($type ne "" and uc $t->{'type'} ne uc $type);

                if (!$t->{'translation_name'}) {
                        $t->{'translation_name'} = $t->{'name'} . ' (original)';
                        $t->{'translation_url'} = $t->{'url'};
                }

                print "<ul>\n" unless $found;
                $found = 1;
                print "<li>";
                print "<a href=\"$t->{'translation_url'}\">" if $t->{'translation_url'};
                print "<b><i>$t->{'translation_name'}</i> $t->{'translation_sub_name'}</b>";
                print q{<ct-tag-nourl>} if !$t->{'translation_url'};
                print "</a>" if $t->{'translation_url'};
#        print "<BLOCKQUOTE>";
                print "<br />".q{<ct-tag-source/>}." : <a href=\"$t->{'translation_source_url'}\">$t->{'translation_source_name'}</a>"
                        if ($t->{'translation_source_url'} && uc $type ne 'DDP');
                print " (<a href=\"$t->{'translation_cvs_url'}\">".q{<ct-tag-cvspage/>}."</a>)"
                        if ($t->{'translation_cvs_url'} && uc $type ne 'DDP');
                print "<br />".q{<ct-tag-devel-url/>}." : <a href=\"$t->{'translation_dev_url'}\">$t->{'translation_dev_url'}</a>"
                        if ($t->{'translation_dev_url'} && uc $type ne 'DDP');
                if ($t->{'translation_maintainer'}) {
                        print "<br />".q{<ct-tag-translation_maintainer/>}." : " ;
                        my $line = '';
                        my $translator;
                        foreach $translator (@{$t->{'translation_maintainer'}}) {
                                $translator =~ s/\s*(<.*)?$//;
                                $line .= (defined $translators->{$translator} ?
                                        " <a href=\"mailto:$translators->{$translator}->{email}\"><i>$translator</i></a> " :
                                        " <i>$translator</i> ");
                        }
                        print $line;
                }

                print "<br />".q{<ct-tag-status/>}.": $status[$t->{'status'}]";
                print " ".q{<ct-tag-since/>}." $t->{'since'}" if ($t->{'since'});
                print "<br />".q{<ct-tag-translation_revision/>}.": $t->{'translation_revision'}" if ($t->{'translation_revision'});
                print "<br />".q{<ct-tag-base_revision/>}." : $t->{'base_revision'}" if ($t->{'base_revision'});
                print "<br /><a href=\"$t->{'diff'}\">".q{<ct-tag-diff/>}."</a>" if ($t->{'diff'});
                print "<br />".q{<ct-tag-available/>}." <a href=\"http://packages.debian.org/$t->{'translation_package'}\">$t->{'translation_package'}</a>" if ($t->{'translation_package'});
                if ($t->{'translation_name'} !~ /original/) {
                        print "<br />".q{<ct-tag-originaldoc/>}." : <a href=\"$t->{'url'}\"> <i>$t->{'name'}</i> $t->{'sub_name'}</a>";
                }

                if ($t->{'revision'}) {
                	print " ( ".q{<ct-tag-revision/>}." $t->{'revision'} ";
			print "-- ".$t->{'mtime'} if $t->{'mtime'};
                	print " ) ";
                }
                print " ( ".q{<ct-tag-included/>}." <a href=\"http://packages.debian.org/$t->{'package'}\">$t->{'package'}</a> ) " if ($t->{'package'});
                print " ( <a href=\"$t->{'source_url'}\">".q{<ct-tag-Source/>}."</a> ) " if ($t->{'source_url'} && $t->{'source_url'} ne '?'); # Why this? && uc $type ne "DDP");
                print " ( <a href=\"$t->{'cvs_url'}\">".q{<ct-tag-CVSpage/>}."</a> ) " if ($t->{'cvs_url'} && $t->{'cvs_url'} ne '?'); # Why this?  && uc $type ne "DDP");
                print "<br />".q{<ct-tag-lines/>}." : $t->{'lines'} " if ($t->{'lines'});

                print "<br /></li>\n";
        } # of the foreach
        print "</ul>\n" if $found;
}

1;
