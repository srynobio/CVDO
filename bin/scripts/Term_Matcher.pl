#!/usr/bin/perl -w 
use strict;
use IO::File;
use OBO_utils;

# Matches the common term list and isolates anatomy term 
# for terms with two or more parents.
my $common_fh  = IO::File->new('../data/Common_term_tree.txt', 'r') || die "Can't open common txt file\n";
my $anatomy_fh = IO::File->new('../data/fma_anatomy_match', 'r')    || die "Can't open match list file\n";
my $write_fh   = IO::File->new('../data/mesh_common_match', 'w')    || die "Can't write file\n";

# Arrayref of common word file.
my @split_comm;
while (defined( my $line = <$common_fh>)) {
	chomp $line;

	my @comm_mesh;
	if ($line =~ /^Term ->\s+(.+$)/ ) {
		my $common = $1;
		push @comm_mesh, $common;	
	}
	my $comm_word = word_splitter(\@comm_mesh);
	push @split_comm, @$comm_word;
}

my @anatomy;
while (defined( my $line = <$anatomy_fh>)) {
	chomp $line;

	push @anatomy , $line;
}
	
# Compares words from each arrayref
# and returns any word which are in both files.
# Change the second foreach to change search.
my @match;
foreach my $mesh (@split_comm) {
	foreach my $fma (@anatomy) {
		if ($mesh eq $fma) {
			push @match, $fma;
		}
	}
}

my @clean_match = remove_duplicates(@match);
foreach (@clean_match) {
	print $write_fh "$_\n";
}


$common_fh->close;
$anatomy_fh->close;

