#!/usr/bin/perl -w
use strict;
use IO::File;
use OBO_utils;

# Script by Shawn Rynearson For Karen Eilbeck
# shawn.rynearson@gmail.com
# Used for DO development project.

my $usage = "\n
Description:
		Script input three file types: working mesh file, FMA file
		and PATO file.  Creates arrayrefs of individual words 	
		from the name: field of the obo file.  Compares each word 
		against eachother and output the matching word.
USAGE: 
		./Name_Matcher.pl 
\n";


# I/O
my $mesh_fh  = IO::File->new('../data/CVDO.obo', 'r') || die "Can't open MESH file $usage\n";
my $fma_fh   = IO::File->new('../Ontologies/fma.obo', 'r')     || die "Can't open FMA file\n";
my $pato_fh  = IO::File->new('../Ontologies/PATO.obo', 'r')    || die "Can't open PATO file\n";
my $write_fh = IO::File->new('../data/fma_anatomy_match', 'w') || die "Can't open write file\n";

# Creating arrayrefs of name terms.
my $mesh_ref   = name_term_grep(<$mesh_fh>);
my $fma_ref    = name_term_grep(<$fma_fh>);
my $pato_ref   = name_term_grep(<$pato_fh>);

# Passes to OBO_utils which splits sentences into
# individual words.
my $mesh_word = word_splitter($mesh_ref);
my $fma_word  = word_splitter($fma_ref);
my $pato_word = word_splitter($pato_ref);

# Compares words from each arrayref
# and returns any word which are in both files.
# Change the second foreach to change search.
my @match;
foreach my $mesh (@$mesh_word) {
	foreach my $fma (@$fma_word) {
		if ($mesh eq $fma) {
			push @match, $fma;	
		}
	}
}

my @clean = remove_duplicates(@match);
foreach (@clean) {
	print $write_fh "$_\n";
}

$mesh_fh->close;
$fma_fh->close;
$pato_fh->close;
