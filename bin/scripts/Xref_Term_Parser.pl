#!/usr/bin/perl -w
use strict;
use GO::Parser;
use IO::File;
use OBO_utils;

# Script by Shawn Rynearson For Karen Eilbeck
# shawn.rynearson@gmail.com
# Used for DO development project.

my $usage = "\n
Description:
		Script used to extract and print all xrefs.

USAGE: 
        	./Xref_Parser.pl <xref obo file> 
\n";

# I/O for xref obo file.
my $xref_input = shift || die "Please enter xref obo file $usage\n";
my $xref_list  = IO::File->new('../data/xref_list.txt', 'w') || die "Can't write to file.\n";

# Make obo object.
my $it = iterator_maker($xref_input);

# This code will extract the xref values and make an hash of array refs.
my %refs;
while ( my $ni = $it->next_node_instance ) {
    my $term = $ni->term;

    my $xrefs = eval { $term->dbxref_list() };

    foreach my $xref (@$xrefs) {
        $refs{ $term->acc }{ $xref->dbname } = $xref->xref_key;
    }
}

# Access the reference and prints to STDOUT.
while ( my ( $keys, $values ) = each %refs ) {
    print $xref_list "$keys\t ";
    while ( my ( $xkey, $dbname ) = each %$values ) {
        print $xref_list "$xkey:$dbname\t";
    }
    print $xref_list "\n";
}

$xref_list->close;
