#!/usr/bin/perl

# $Id$
#
# find what's out of sync in a folder compared to the original one
# usage
#  <script> root-folder original-folder translation-folder [newer|nomatch] [dirs]
#    newer   - report newer files in original if translation present
#    nomatch - report files in original that have no corespondent transl
#    dirs    - print dirs also
#  ex: whatsnew.pl '..' english romanian newer
#

$action = "newer";
$rdir   = ".."; #root dir
$odir   = "english";
$tdir   = "romanian";
$nodir  = "nodir";

die "Unsupported since the move to git\n";

&usage;

if ($ARGV[0]) { $rdir = $ARGV[0]; };
if ($ARGV[1]) { $odir = $ARGV[1]; };
if ($ARGV[2]) { $tdir = $ARGV[2]; };
if ($ARGV[3]) { $action = $ARGV[3]; };
if ( !($action =~ m/^newer$/i)  && !($action =~ m/^nomatch$/i))
{
    die "Unsupported action: $action \n"
}
if ($ARGV[4]) { $nodir = $ARGV[4]; };

#first update current branch, then the reference one
printf "Updating from CVS repository **local branch**...\n";
`cvs update -d`;

chdir $rdir || die "*** No such root dir: $rdir\n";
chomp($rdir = `pwd`);

chdir $odir || die "*** No such dir: $rdir + $odir\n";
printf "\nUpdating from CVS repository **reference branch**...\n";
`cvs update -d`;

chdir ".." || die "*** No such root dir: $rdir\n";
@files  = `find "./$odir" -name '*' -print`;
#print @files;

for ($i=$#files; $i>=0; $i--)
{
    chomp $files[$i];
    if ( $files[$i] =~ m=/CVS= ) { goto _loop;}
    
    $tfile = $files[$i];
    $tfile =~ s=$odir=$tdir=;
    $mtimeo = (stat($files[$i]))[9];
    $mtimet = (stat($tfile))[9];
    
    if ( $action =~ m/newer/i )
    {
        if ( ($mtimeo > $mtimet) && -e $tfile )
        {
            print "Newer original than translation: $files[$i] \n";
        }
        
        if ( !(-e $tfile) && -d $files[$i] && !($nodir =~m/nodir/i) )
        {
            print "Original dir without correspondent: $files[$i] \n";
        }
    }
    elsif ( $action =~ m/nomatch/i )
    {
        if ( -f $files[$i] && !(-e $tfile) )
        {
            print "File without translation: $files[$i] \n";
        }
        elsif ( -d $files[$i] && !(-e $tfile)  && !($nodir =~m/nodir/i) )
        {
            print "Dir without correspondent: $files[$i] \n";
        }
        else
        {
            #
        }
    }

_loop:
}

print "\n=== Done ===\n";

#----------------------------------------------------------------
sub usage
{
    print "\nUsage: \n";
    print "  <script> root-folder original-folder translation-folder [newer|nomatch] [dirs]\n\n";
}
#----------------------------------------------------------------
