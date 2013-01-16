#!/usr/bin/perl -w
use strict;
use GO::Parser;
use OBO_utils;
use Hash::Merge qw( merge );

# Script by Shawn Rynearson For Karen Eilbeck
# shawn.rynearson@gmail.com
# Used for DO development project.


my $usage = "\n
Description:
	Accepts obo file containing variant gene and adds gene transitivity
	to obo file.
	** File also uses IO::File to import the obo file, please check obo path.

USAGE: 
        ./Xref_Gene_transitivity.pl  <obo file> 
\n";


# I/O for object.
my $input = shift       || die "$usage\n";
my $copy_input = $input || die "$usage\n";

# Make the iterator object.
my $parser = new GO::Parser( { handler => 'obj' } );
$parser->parse($input);

# make graph object
my $graph = $parser->handler->graph; 

# make iterator object which travels up each node.
my $it = eval { $graph->create_iterator({
		direction=>"up",
})};

# Collect complete parent child gene relationship.
my %child_gene;
while ( my $ni = $it->next_node_instance ) {

	# Parent and each child term objects.
 	my $parent_term   = $ni->term;
	my $parent_child  = $graph->get_child_relationships($parent_term); 

	# Take each child term and collects GENE xrefs, make a hash of arrayrefs with
	# hash key being the parent acc number and the arrayref full of child gene terms.
	foreach my $i (@$parent_child) {
		my $child_list = $graph->get_term($i->subject_acc); 
		my $relationship = $child_list->dbxref_list; 

		# keys are parent acc numbers, and arrayref are child gene names.
		my @xref_gene;
		foreach my $i (@$relationship) {	
			my $xref = join(':', $i->xref_dbname, $i->xref_key);
			if ($xref =~ /(GENE:.+)/) {
				my $gene = $1;
				push @xref_gene, $gene;
			}
		}
		$child_gene{$i->object_acc}->{$i->subject_acc} = [@xref_gene];
	}
}


# Input will change based on file you want to add to.
my $mesh_fh   = IO::File->new($copy_input, 'r');


# Uses working MeSH file.
my %mesh;
my $term;
my $acc;
while ( defined( my $line = <$mesh_fh> ) ) {
    chomp $line;

    if ( $line =~ /(\[Term\])/ ) {
        next;
    }
    elsif ($line =~ /format-version:/) {
	next;
    }
    elsif ($line =~ /date:/) {
	next;
    }
    elsif ($line =~ /saved-by:/) {
	next;
    }
    elsif ($line =~ /auto-generated-by:/) {
	next;
    }
    elsif ($line =~ /default-namespace:/) {
	next;
    }
    elsif ( $line =~ /(\[Typedef\])/ ) {
        next;
    }
    elsif ( $line =~ /id:\s+(.+)/ ) {
        $acc = $1;
        $mesh{$acc} = [] unless exists $mesh{$1};
    }	
    else {
        my $element = $line;
        push @{ $mesh{$acc} }, $element;
    }
}


# Uses the Merge method to combine files.
my $combine = Hash::Merge->new();
my %f_combine = %{ $combine->merge( \%mesh, \%child_gene ) };


# Printing out the merged hashes in obo format.
foreach my $k (keys %f_combine) {
	if ($k =~ /OBO_REL:.+\_.+/) {
		print "[Typedef]\nid: $k\n";
	}
	elsif ($k =~ /OBO_REL:.+/) {
		print "[Typedef]\nid: $k\n";
	}
	elsif ($k =~ /OBO_REL:\d+/) {
		print "[Typedef]\nid: $k\n";
	}
	else {
		print "[Term]\nid: $k\n";
	}
	my @mesh_gene;
	my @child_gene;
	foreach my $v (@{ $f_combine{$k}}) {

		if ($v =~ /^xref:\s+(GENE:.+)/) {
			my $mesh_gene = $1;
			print "xref: $mesh_gene\n";
			push @mesh_gene, $mesh_gene;
		}
		elsif (ref($v)) {
			my @gene = grep {/(GENE:.+)/} @$v;

			foreach my $gene (@gene) {
				my @trans_gene = split /\s+/, $gene;
				foreach my $i (@trans_gene) {
					push @child_gene, $i;
				}
			}
		}
		else {
			print "$v\n";
		}
	}
	# Work with mesh file and collected transitivity genes.
	my @match;
	foreach my $trans (@child_gene) {
		foreach my $mesh (@mesh_gene) {
			if ($trans eq $mesh) {
				push @match, $trans;	
			}
		}
	}		
	# Takes transitivity gene and only prints one version of common gene.
	my @dup_list = duplicate(@match);
	foreach my $gene (@dup_list) {
		print "xref: $gene \"Transitive\"\n";
	}

}

$mesh_fh->close;
