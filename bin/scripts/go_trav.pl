#!/usr/bin/perl -w
use GO::Parser;
use Getopt::Long;
use OBO_utils;
use IO::File;

use Data::Dumper;

# Script by Shawn Rynearson For Karen Eilbeck
# shawn.rynearson@gmail.com
# Used for DO development project.

my $usage = "\n
Description:
		Uses go-perl, to retrieve different items, 
		based on options listed below.  

Usage / Options (required):
 
	--uniq		Isolates all the parent relationship, 
			for each node and outputs results.
	    		Must be ran first because traversed.txt 
	    		is needed for Tree_Uniq_Reporter.pl
			
 	--common 	Used to isolate the superclass of each 
    			term in the ontology. 
		
	--xref 		Script used to extract and print all xrefs. 
			This option will import the reference 
			obo file (HumanDO.obo for CVDO) will need 
			to change for additional ontologies.

\n";


my $opt = {};
GetOptions( 
	$opt, 
	"common", 
	"uniq", 
	"xref",
);



# I/O for object.
my $input = shift || die "$usage\n";

# Make the iterator object.
my $parser = new GO::Parser( { handler => 'obj' } );
$parser->parse($input);

# make graph object
my $graph = $parser->handler->graph;

# make iterator object
my $it = eval { $graph->create_iterator };

print Dumper($it);

while ( my $ni = $it->next_node_instance ) {

        my $depth        = $ni->depth;
        my $term         = $ni->term;
        my $relationship = $ni->parent_rel;

       print $taver_fh $term->name, "\t", $term->acc, "\t", $parent, "\n";
    
}

__END__
#-----------------------------------------------------
#-----------------------------------------------------

# This section traverses ontology tree,
# and lists relationships.

if ( $opt->{uniq} ) {
    my $taver_fh = IO::File->new( 'traversed.txt', 'w' ) || die "Can't write to file\n";

    # traverse the tree, additional method can be added.
    while ( my $ni = $it->next_node_instance ) {

        my $depth        = $ni->depth;
        my $term         = $ni->term;
        my $relationship = $ni->parent_rel;

        # Needed to eval all, because $relationship object contained
        # undefined values.  Methods would not allow undefined.
        my $parent = eval { $relationship->object_acc() };
        my $child  = eval { $relationship->subject_acc() };
        my $type   = eval { $relationship->type() };

        print $taver_fh $term->name, "\t", $term->acc, "\t", $parent, "\n";
    }
}

#-----------------------------------------------------
#-----------------------------------------------------

# Outputs the superclass term(s) of nodes with two or more parents.

if ( $opt->{common} ) {

    # I/O
    my $term_fh = IO::File->new( 'uniq_list.txt', 'r' ) || die "Could not open term file\n";
    my $common_fh = IO::File->new( '../data/Common_term_tree.txt', 'w' ) || die "Can't write to file\n";

    foreach my $acc (<$term_fh>) {
        chomp $acc;

        my $term = $graph->get_term($acc);

        printf $common_fh "Term ->  %s\n", $term->name;

        # Arrayref of go::model::term
        my $anc_term = $graph->get_recursive_parent_terms( $term->acc );

        my @names;
        foreach my $anc (@$anc_term) {
            push( @names, $anc->name );
        }

        # uses OBO_utils.
        my @ref = duplicate(@names);

        foreach my $element (@ref) {
            if ( $element =~ /Cardiovascular Disease/ ) {
                next;
            }
            print $common_fh "$element\n";

        }
        print $common_fh "\n";
    }
    $term_fh->close;
}

#-----------------------------------------------------
#-----------------------------------------------------

# This code will extract the xref values and make an hash of arrayrefs.

if ( $opt->{xref} ) {

    # I/O
    my $xref_fh = IO::File->new( 'xref_list.txt', 'w' ) || die "Can't write to file\n";

    # Using the above object.
    my %refs;
    while ( my $ni = $it->next_node_instance ) {
        my $term = $ni->term;
        
	my $xrefs = eval { $term->dbxref_list() };

        foreach my $xref (@$xrefs) {
            $refs{ $term->acc }{ $xref->dbname } = $xref->xref_key;
        }
    }

print Dumper(%refs);
=cut
    # Access the reference and prints to xref_list.txt.
    while ( my ( $keys, $values ) = each %refs ) {
        print $xref_fh "$keys\t ";
        while ( my ( $xkey, $dbname ) = each %$values ) {
            print $xref_fh "$xkey:$dbname\t";
        }
        print $xref_fh "\n";
    }
=cut
}

#-----------------------------------------------------
#-----------------------------------------------------
 

