#!/usr/bin/perl -w
use strict;
use IO::File;

# Script by Shawn Rynearson For Karen Eilbeck
# shawn.rynearson@gmail.com
# Used for DO development project.

my $usage = "\n
Description:
		Script used to extract xrefs with only D0...values 
		from referance obo file
		Input is from Xref_Parser.pl
USAGE: 
        ./Xref_Parser.pl <xref file>
\n";

# I/O
my $xref_fh  = IO::File->new('../data/xref_list.txt', 'r') || die "Can't read file.$usage\n";
my $xref_out = IO::File->new('../data/combine_xref.txt', 'w') || die "Can't write to file\n";

while ( defined( my $line = <$xref_fh> ) ) {
    chomp $line;
    push( my @xrefs, $line );

    my @match = grep { $_ =~ /D0\d+/ } @xrefs;

    foreach (@match) {
        print $xref_out "$_\n";
    }
}

$xref_fh->close;
$xref_out->close;

