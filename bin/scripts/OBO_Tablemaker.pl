#!/usr/bin/perl

use strict;
use diagnostics;
use GO::Parser;

# Script take CVDO obo file and outputs gene CVDO term relationship
# Only collect non_transitive genes.

# I/O for object.
my $input  = shift || die "Please enter file\n";
#my $out_fh = IO::File->new(">>Gene_Name_list") || die "Can't open write file\n";


# Make the iterator object.
my $parser = new GO::Parser( { handler => 'obj' } );
$parser->parse($input);

# make graph object
my $graph = $parser->handler->graph;

# make iterator object
my $it = eval { $graph->create_iterator };

# Collect complete parent child gene relationship.
my %table;
while ( my $ni = $it->next_node_instance ) {

	my $term = $ni->term;

	# use term object to get name and xrefs.
	my $name  = $term->name;
	my $xrefs = $term->dbxref_list;		

	foreach my $i (@$xrefs) {
		if ( $i->xref_dbname =~ /^HGNC_gene/ ) {
			my $gene = $i->xref_key;
			my ($hgnc, $desc)  = split(/,/, $i->xref_desc );
			$table{ $hgnc } = [] unless exists $table{ $hgnc };
			push @{ $table{ $hgnc }}, $gene, $name;
		}
	}
}
print "HGNC Number\tGene Name\tCVDO Name\n";
for my $i (keys %table) {
	my $name_list = remove_duplicates(( $table{$i} ));
	my $tab_list = join('	', @$name_list);
	print "$i\t$tab_list\n" if $i;
}


#----------------------------------------------------------------------
#-------------------------------SUBS-----------------------------------
#----------------------------------------------------------------------

sub remove_duplicates {

        my $list = shift;
	
	my %seen;
        my @uniq = grep {! $seen{$_} ++ } @$list;

        return \@uniq;
}

