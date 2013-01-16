#!/usr/bin/perl -w 
use strict;
use IO::File;

# Script by Shawn Rynearson For Karen Eilbeck
# shawn.rynearson@gmail.com
# Used for DO development project.

my $usage = "\n
Description:
		Takes working.obo file and outputs a completed obo file,
		file will now have xref in the correct format for OBO-Edit.
	
		** This file will have to be modified for future onlologies.

USAGE: 
       		./Xref_Final.pl 
\n";

# I/O
my $read_fh = IO::File->new('../data/working.obo', 'r') || die "Can't open obo file. $usage\n";
my $out_fh = IO::File->new('../data/CVDO.obo', 'w') || die "Can't write to file\n";

while(defined(my $line = <$read_fh>)) {
	chomp $line;

	if($line =~ s/^(xref:)\s+(\w+:)\s+(\w+:\d+)\s+(\w+:\d+)\s+(\w+:\w+)\s+(\w+:\w+)/xref: $3\nxref: $4\nxref: $5\nxref: $6/g){
		}
	elsif($line =~ s/^(xref:)\s+([A-Z]+:\d+)\s+(\w+:\w+)/xref: $2\nxref: $3/g){
		}
	elsif($line =~ s/^(xref:)\s+(\w+:)\s+(\w+:\d+)\s+(\w+:\d+)\s+(\w+:\w+)/xref: $3\nxref: $4\nxref: $5/g){
		}
	elsif($line =~ s/^(xref:)\s+(\w+:)\s+(\w+:\w+)\s+(\w+:\w+)\s+(\w+:\w+-\w+)/xref: $3\nxref: $4\nxref: $5/g){
        }
	elsif($line =~ s/^(xref:)\s+(\w+:)\s+(\w+:\w+)\s+(\w+:\w+)\s+(\w+:\w+.\w+)/xref: $3\nxref: $4\nxref: $5/g){
		} 
	elsif($line =~ s/^(xref:)\s+(\w+:)\s+(\w+:\w+)\s+(\w+:\w+)/xref: $3/g) {	
        }
	elsif($line =~ s/^(xref:)\s+(\w+:)\s+(\w+:\d+)\s+(\w+:\w+)/xref: $3\nxref: $4/g){
        }
	elsif($line =~ s/^(xref:)\s+(\w+:)\s+(\w+:\w+)/xref: $3/g) {     
        }
	print $out_fh "$line\n";	

}

$read_fh->close;
$out_fh->close;

