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

# $t : current document record
# $k : current document key
# $f : current document field

$types = {
        'Web' => {
                'name'          => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$k.en.html" },
                'url'           => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "http://www.debian.org/$k.en.html" },
                'cvs_url'       => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$CVSWEB/webwml/$from/$k.wml?cvsroot=webwml" },
                'source_url'    => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$CVSWEB/webwml/$from/$k.wml?cvsroot=webwml&amp;rev=$t->{'revision'}" },
                'translation_name'      => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$k.$to_abr.html" },
                'translation_url'       => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "http://www.debian.org/$k.$to_abr.html" },
                'translation_cvs_url'   => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$CVSWEB/webwml/$to/$k.wml?cvsroot=webwml" },
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

                print "<LI>";

                $t->{'translation_name'} = $t->{'name'} . ' (original)'
                        if (!$t->{'translation_name'});
                $t->{'translation_url'} = $t->{'url'}
                        if (!$t->{'translation_url'});

                print "<A HREF=\"$t->{'translation_url'}\">" if $t->{'translation_url'};
                print "<B><I>$t->{'translation_name'}</I> $t->{'translation_sub_name'}</B>";
                print q{<ct-tag-nourl>} if !$t->{'translation_url'};
                print "</A>" if $t->{'translation_url'};
#        print "<BLOCKQUOTE>";
                print "<BR>".q{<ct-tag-source>}." : <A HREF=\"$t->{'translation_source_url'}\">$t->{'translation_source_name'}</A>"
                        if ($t->{'translation_source_url'} && uc $type ne 'DDP');
                print " (<A HREF=\"$t->{'translation_cvs_url'}\">".q{<ct-tag-cvspage>}."</A>)"
                        if ($t->{'translation_cvs_url'} && uc $type ne 'DDP');
                print "<BR>".q{<ct-tag-devel-url>}." : <A HREF=\"$t->{'translation_dev_url'}\">$t->{'translation_dev_url'}</A>"
                        if ($t->{'translation_dev_url'} && uc $type ne 'DDP');
                if ($t->{'translation_maintainer'}) {
                        print "<BR>".q{<ct-tag-translation_maintainer>}." : " ;
                        my $line = '';
                        my $translator;
                        foreach $translator (@{$t->{'translation_maintainer'}}) {
                                $translator =~ /([^\<]+)\s\<(.*)\>/;
                                $line .= " <A HREF=\"mailto:$2\"><I>$1</I></A> et";
                        }
                        $line =~ s/et$//;
                        print $line;
                }

                print "<BR>".q{<ct-tag-status>}.": $status[$t->{'status'}]";
                print " ".q{<ct-tag-since>}." $t->{'since'}" if ($t->{'since'});
                print "<BR>".q{<ct-tag-translation_revision>}.": $t->{'translation_revision'}" if ($t->{'translation_revision'});
                print "<BR>".q{<ct-tag-base_revision>}." : $t->{'base_revision'}" if ($t->{'base_revision'});
                print "<BR><A HREF=\"$t->{'diff'}\">".q{<ct-tag-diff>}."</A>" if ($t->{'diff'});
                print "<BR>".q{<ct-tag-available>}." <A HREF=\"http://packages.debian.org/$t->{'translation_package'}\">$t->{'translation_package'}</A>" if ($t->{'translation_package'});
                if ($t->{'translation_name'} !~ /original/) {
                        print "<BR>".q{<ct-tag-originaldoc>}." : <A HREF=\"$t->{'url'}\"> <I>$t->{'name'}</I> $t->{'sub_name'}</A>";
                }

                print " ( ".q{<ct-tag-revision>}." $t->{'revision'} ) " if ($t->{'revision'});
                print " ( ".q{<ct-tag-included>}." <A HREF=\"http://packages.debian.org/$t->{'package'}\">$t->{'package'}</A> ) " if ($t->{'package'});
                print " ( <A HREF=\"$t->{'source_url'}\">".q{<ct-tag-Source>}."</A> ) " if ($t->{'source_url'} && $t->{'source_url'} ne '?'); # Why this? && uc $type ne "DDP");
                print " ( <A HREF=\"$t->{'cvs_url'}\">".q{<ct-tag-CVSpage>}."</A> ) " if ($t->{'cvs_url'} && $t->{'cvs_url'} ne '?'); # Why this?  && uc $type ne "DDP");
                print "<BR>".q{<ct-tag-lines>}." : $t->{'lines'} " if ($t->{'lines'});

                print "<P>&nbsp;\n";
        } # of the foreach
}

1;
