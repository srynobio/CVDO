#!/usr/bin/perl -w
use strict;
use Hash::Merge qw( merge );
use IO::File;

# Script by Shawn Rynearson For Karen Eilbeck
# shawn.rynearson@gmail.com
# Used for DO development project.

my $usage = "\n
Description:
		Takes xref file and add xref's based on accession number.
		only adds xref's if numbers are in working MeSH file.	
USAGE: 
        ./Xref_Combine.pl
\n";

# I/O
my $in_fh   = IO::File->new('../data/MeSHOBO.obo', 'r') || die "Can't open mesh file. $usage\n";
my $xref_fh = IO::File->new('../data/combine_xref.txt', 'r') || die "Can't open xref file\n"; 
my $out_fh  = IO::File->new('../data/merged.txt', 'w') || die "Can't write to file\n";

# Take the mesh file and splits each element of the array.
my %mesh;
my $acc;
while ( defined( my $line = <$in_fh> ) ) {
    chomp $line;

    if ( $line =~ /\[Term\]/ ) {
        next;
    }
    elsif ( $line =~ /id:\s+(D\d+)/ ) {
        $acc = $1;
        $mesh{$acc} = [] unless exists $mesh{$1};
    }

    # This is where additional items will have to be added depending on
    # what the obo file contains.
    elsif ( $line =~ /(name:) || (def:) || (is_a:)/ ) {
        my $element = $line;
        push @{ $mesh{$acc} }, $element;
    }
}

# Takes the xref_list and adds to each element of array.
my %xref;
while ( defined( my $line = <$xref_fh> ) ) {
    chomp $line;

    # Moves the D0... acc number to the front of the line.
    $line =~ s/(^.*)(D0\d+)/$2\t$1/g;

    my @xref = split /\t+/, $line;
    my $acc_num = shift @xref;

    $xref{$acc_num} = [@xref];
}

# Uses the Merge method to add xrefs to working MeSH file.
my $combine = Hash::Merge->new();
my %f_combine = %{ $combine->merge( \%mesh, \%xref ) };

for my $number ( keys %f_combine ) {
    print $out_fh "$number\t@{$f_combine{$number}}\n";
}

$in_fh->close;
$xref_fh->close;
$out_fh->close;

