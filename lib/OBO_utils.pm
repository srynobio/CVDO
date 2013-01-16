package OBO_utils;

use strict;
use base 'Exporter';
use GO::Parser;
use IO::File;

# Script by Shawn Rynearson For Karen Eilbeck
# shawn.rynearson@gmail.com
# Used for DO development project.

our @EXPORT = qw( duplicate 
	 	  plural_check 
		  iterator_maker 
	          word_match 
		  remove_duplicates  
		  name_term_grep
		  word_splitter 
		  gene_term_flip
		  term_cleaner
);



#===============================

# Used in OBO_Cleaner

sub duplicate {
    my @args = @_;
    my %names;
    foreach my $item (@args) {
        $names{$item}++;
    }
    my @thing = grep { $names{$_} => 1 } keys %names;
    return @thing;
}

#===============================

# sub take in individual word from name: field of obo file
# make a record of it before and after any changes are made
# then return the changed word.

sub plural_check {

    # May have to move outside of sub to have it work.
    my $write_fh = IO::File->new('../data/plural_change', 'w');
    
    my $line = shift;
    chomp $line;
    
    my $before = \$line;
    my $after;
    
    push( my @entry_list, $line );
    
    foreach (@entry_list) {

	s/Diseases/Disease/g;
	s/Syndromes/Syndrome/g;
	s/Defects/Defect/g;
	s/Malformations/Malformation/g;
	s/Cardiomyopathie/Cardiomyopathy/g;
	s/Disorders/Disorder/g;
	s/Hemorrhages/Hemorrhage/g;
	s/Anomalies/Anomaly/g;
	s/Defects/Defect/g;
	s/Neoplasms/Neoplasm/g;
	s/Abnormalities/Abnormality/g;
	s/Infections/Infection/g;
	s/Infarctions/Infarction/g;
	s/Cardiomyopathys/Cardiomyopathy/g;
	s/Complications/Complication/g;
	s/Vessels/Vessel/g;
	s/Complexes/Complex/g;
	s/Headaches/Headache/g;
	
	$after = \$_;
       } 
	my @change;
        if ($$before ne $$after ){
	    push (@change, $$before);
        }
	foreach (@change) {
	    print $write_fh "Plural changes made to\t$_\n";
	}
	foreach (@entry_list) {
	    return $_;
	}
	
    }

#===============================

# This takes an file and creates a $it object with it.

sub iterator_maker {

        my $input = shift;

        # make parse object
        my $parser = new GO::Parser( { handler => 'obj' } );
        $parser->parse($input);

        # make graph object
        my $graph = $parser->handler->graph;

        # make iterator object
        my $it = eval { $graph->create_iterator };

        return $it;
}

#===============================

sub remove_duplicates {

	my @list = @_;

	my %seen;
	my @uniq = grep {! $seen{$_} ++ } @list;

	return @uniq;
}


#===============================

sub name_term_grep {
	
	my @input = @_;
	
	my @term;
	foreach my $i (@input) {
		$i =~ /name:\s+(.+$)/;
		my $name = $1;
		push @term, $name;
		}
	my @name = remove_duplicates(@term);
	return \@name;
	
}		

#===============================

sub word_splitter {

	my $input = shift;

	my @mesh_term;
	foreach my $item (@$input) {
		my @word = split /\s+/, $item;
	
		foreach my $words (@word) {
			push @mesh_term, $words;
		}
	}
	return \@mesh_term;
}


#===============================

sub gene_term_flip {
	
	my $term = shift;
	chomp $term;

	$term =~ s/(.+)\,\s+(.+)/$2 $1/g;
	$term =~ s/(.+)\,\s+(.+)/$2 $1/g;

	return $term;
}


#===============================

sub term_cleaner {

	my $line = shift;



	# Call to OBO_utils to change word plurility.
	$line = plural_check($line) || warn "plural_check could not be called. $!\n";

	# List of matches to capture all possable word patterns in CVDO ontology.
        $line =~ s/^(\w+)(,)(\s)(\w+)$/$4 $1/g;	
	$line =~ s/^(\w+)(,)(\s)(\w+)(\s)(\w+)$/$4 $6 $1/g;
	$line =~ s/^(\w+)(,)(\s)(\w+)(\s)(\w+)(\s)(\w+)$/$4 $6 $8 $1/g;
	$line =~ s/^(\w+)(,)(\s)(\w+-\w+)$/$4 $1/g;
	$line =~ s/^(\w+)(,)(\s)(\w+)(,)(\s)(\w+)$/$7 $4 $1/g;
	$line =~ s/^(\w+)(\s)(\w+)(,)(\s)(\w+)$/$6 $1 $3/g;
	$line =~ s/^(\w+)(\s)(\w+)(\s)(\w+)(,)(\s)(\w+)$/$8 $1 $3 $5/g;
	$line =~ s/^(\w+)(\s)(\w+)(,)(\s)(\w+)(\s)(\w+)(\s)(\w+)$/$6 $8 $10 $1 $3/g;
	$line =~ s/^(\w+)(,)(\s)(\w+)(,)(\s)(\w+)(\s)(\w+)(\s)(\w+)$/$7 $9 $11 $4 $1/g;
	$line =~ s/^(\w+)(\s)(\w+)(,)(\s)(\w+-\w+)$/$6 $1 $3/g;
	$line =~ s/^(\w+-\w+)(,)(\s)(\w+)$/$4 $1/g;
	$line =~ s/^(\w+-\w+)(,)(\s)(\w+-\w+)$/$4 $1/g;
	$line =~ s/^(\w+)(\s)(\w+)(,)(\s)(\w+)(,)(\s)(\w+)$/$6 $9 $1 $3/g;
	
	return $line;
}

1;
