#!/usr/bin/perl -w
use strict;
use IO::File;

# I/O
my $read_fh  = IO::File->new('../data/merged.txt', 'r')  || die "Can't locate read file\n";
my $write_fh = IO::File->new('../data/working.obo', 'w') || die "Can't open file to write to\n";


while (defined( my $line = <$read_fh>) ) {
	chomp $line;
	
	my @matchs = grep { /name:/ } $line;

	foreach my $i (@matchs) {
		chomp $i;
	
		$i =~ s/\s(\w+):\s+/\n$1: /g;
		$i =~ s/^(D0\d+)/\nid: $1 /g;
		$i =~ s/(DOID:\d+)/\nxref: $1/g;
		$i =~ s/^\s+/\n[Term]\n/g;
		$i =~ s/MSH/xref: MSH$1/g;

		print $write_fh "$i\n";		
	}
}

$read_fh->close;
$write_fh->close;

