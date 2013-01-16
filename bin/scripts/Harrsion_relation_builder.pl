#!/usr/bin/perl -w
use strict;
use GO::Parser;
use IO::File;

# I/O for object.
my $hars_file = $ARGV[0] || "Cant open Harrison file $usage\n";
my $obo_fh = IO::File->new('../Ontologies/Final_CVDO_v1.08', 'r') || die "Can't open file $usage\n";


# arr_ref of harrisons and cvdo obo file
my $harrison = hars_obo($hars_file);

while (defined(my $line = <$obo_fh>)) {
	chomp $line;

	if ($line =~ /^comment:/){
		my $comment = $line;
		
		my ($text, $part, $section, $chapter, $subsection, $page) = split /,/, $comment;
		my $match = comment_matcher($subsection, $harrison);
		print "relationship: OBO_REL:located_in $match ! $subsection\n";
	}
	print "$line\n";
}


#--------------------------------------------------------
#------------------------SUBS-----------------------------
#--------------------------------------------------------

sub comment_matcher {

	my ($cvdo, $harrison) = @_;
	
	my @defined_cvdo;
	if (defined $cvdo) {
		push @defined_cvdo, $cvdo;
	}			
	
	foreach my $keys (keys %$harrison) {
		foreach my $i (@defined_cvdo) {
			if ($i =~ $keys) {
				return($harrison->{$keys})
			}
		}
	}
}

#--------------------------------------------------------

sub hars_obo {
	
	my $input = shift;

	# Make the iterator object.
	my $parser = new GO::Parser( { handler => 'obj' } );
	$parser->parse($input);

	# make graph object
	my $graph = $parser->handler->graph; 

	# make iterator object which travels up each node.
	my $it = eval { $graph->create_iterator({
	                direction=>"up",
	})};
	
	my @hars_list;
	while ( my $ni = $it->next_node_instance ) {
        	my $term = $ni->term;
        
        	my $relationship = join('::', $term->acc, $term->name);
        
	       	push @hars_list, $relationship;
	}
	my @uniq_hars_list = remove_duplicates(\@hars_list);
	
	my %hars;
	foreach my $i (@uniq_hars_list) {
		my ($acc, $name) = split /::/, $i;
		$hars{$name} = $acc;
	}
	return (\%hars);
}

#--------------------------------------------------------

sub remove_duplicates {

    my $arr_r = shift;
    my @arr = @{$arr_r};
    my %h = ();
    my $el;
    foreach $el (@arr) {
        $h{$el} = 1;
    }
    my @new_arr = ();
    foreach $el (keys %h) {
        push (@new_arr, $el);
    }
    @{$arr_r} = @new_arr;
    @new_arr;
}

#--------------------------------------------------------


