#!/usr/bin/perl
use warnings;
use strict;
use GO::Parser;

# Script by Shawn Rynearson For Karen Eilbeck
# shawn.rynearson@gmail.com
# Used for DO development project

my $usage = "\n
Description:
		Looks at OBO file for the presence of SNOMED terms.
		Outputs non-SNOMED terms.
Usage 
		/SNOMED_presence.pl < OBO file > 		

\n";

my $input = shift || die $usage;

# Make the iterator object.
my $parser = new GO::Parser( { handler => 'obj' } );
$parser->parse($input);

# make graph object
my $graph = $parser->handler->graph;

# make iterator object
my $it = eval { $graph->create_iterator };


# Collect all terms and terms with SNOMED names.
my @sno;
my @name;
while ( my $ni = $it->next_node_instance ) {
	
	my $term = $ni->term;
	my $db = $term->dbxref_list;

	push @name, $term->name;

	foreach my $i (@$db) {
		if ($i->xref_dbname =~ /SNOMEDCT/) {
			push @sno, $term->name;
		}
	}
}
# Combine lists and isolate term only appearing once.
my @name_list = (@sno, @name);
my @uniq_list = no_sno_med(@name_list);

# Print term name from above list.
foreach my $acc (@uniq_list) {

	my $term = $graph->get_term_by_name($acc);
	my $acc = $term->acc;


	if ($acc =~ /D\d+/) {
		print $term->name, "\n";
	}
	else {
		next;
	}
}


##-------------------------------------------------------##
##-----------------------SUBS----------------------------##
##-------------------------------------------------------##

# Modified from OBO_utils.
sub no_sno_med {
    my @args = @_;
    my %names;
    foreach my $item (@args) {
        $names{$item}++;
    }
    my @thing = grep { $names{$_} == 1 } keys %names;
    return @thing;
}

