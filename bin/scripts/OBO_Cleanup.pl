#!/usr/bin/perl -w
use strict;
use IO::File;
use OBO_utils;

# Script by Shawn Rynearson For Karen Eilbeck
# shawn.rynearson@gmail.com
# Used for DO development project.

my $usage = "\n
Description:
		Script is designed to reverse the order of name terms in .obo file
		Example Aneurysm, Infected -> Infected Aneurysm.
		Will also change plurality of words.

		** This program will not match Central Nervous System, because 
		   it has a irregular pattern in the data. 
USAGE: 
        	./OBO_Cleanup.pl

\n";

# I/O
my $mesh_fh  = IO::File->new( '../data/CVDO.obo', 'r' )  || die "Can't open MeSH file. $usage\n";
my $out_fh   = IO::File->new( 'MeSHOBO_Final.obo', 'w' ) || die "Can't write to file.\n";
my $count_fh = IO::File->new( 'Mesh_Details', 'w' )      || die "Can't write to file.\n";

my $count;
while ( defined( my $line = <$mesh_fh> ) ) {
    chomp $line;

    if ( $line =~ /name:/ ) {

        # Call to OBO_utils to change word plurility.
        $line = plural_check($line) || warn "OBO_utils could not be called. $!\n";

        if ( $line =~ s/name:\s+(\w+)\,\s+(\w+)\s+(\w+)/name:    $2 $3 $1/ ) {

            # Matches two terms after one comma example:  "Embolism, Amniotic Fluid"
            $count++;
        }
        elsif ( $line =~ s/name:\s+(\w+)\,\s+(\w+),\s+(\w+)/name:    $3 $2 $1/ )
        {

	    # Matches terms separated by two commas example:  "Hematoma, Subdural, Chronic"
            $count++;
        }
        elsif ( $line =~ s/name:\s+(\w+)\,\s+(\w+)/name:    $2 $1/ ) {

            # Matches terms separated by comma.
            $count++;
        }
        elsif ( $line =~ s/name:\s+(\w+-\w+)\,\s+(\w+-\w+)/name:    $2 $1/ ) {

            # Matches terms separated by comma.
            $count++;
        }
        elsif ( $line =~ s/name:\s+(\w+-\w+)\,\s+(\w+)/name:    $2 $1/ ) {

            # Matches terms separated by comma.
            $count++;
        }
        elsif ( $line =~ s/name:\s+(\w+)\s+(\w+)\,\s+(\w+)/name:    $3 $1 $2/ )
        {

            # Matches two terms separated by one commas after second word example:
            # "Aortic Stenosis, Subvalvular"
            $count++;
        }
        elsif ( $line =~
            s/name:\s+(\w+)\s+(\w+)\s+(\w+)\,\s+(\w+)/name:    $4 $1 $2 $3/ )
        {
            $count++;
            # Matches three terms then one comma after third word example:
            # "Heart Septal Defects, Atrial"
        }
    }
    print $out_fh "$line\n";
}
print $count_fh "Word order changed on $count names\n";

$mesh_fh->close;
$count_fh->close;
