#!/usr/bin/perl -w
use strict;
use Text::Record::Deduper;

# Script by Shawn Rynearson For Karen Eilbeck
# shawn.rynearson@gmail.com
# Used for DO development project.

my $usage = "\n
Description:
        Script take file generated by go-perl GO_Traverser.pl
		and removes all duplicated terms. An example from go-perl 
		output is 22q11 Deletion Syndrome.
USAGE: 
        ./Tree_Dup_remover.pl
\n";

# File to parse.
my $input_file = shift || die "File not added $usage\n";

# Make new object;
my $deduper = new Text::Record::Deduper;

#remove lines which are duplicated.
$deduper->dedupe_file($input_file);

# separater used for file.
$deduper->field_separator('\n');

# Print report of dups, etc.
$deduper->report_file( "$input_file", all_records => 0 );

