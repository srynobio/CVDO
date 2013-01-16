#!/usr/bin/perl -w
use strict;
use GO::Parser;
use lib '../../lib';
use IO::File;
use Hash::Merge qw( merge );

my $usage = "\n
Description:
		Takes OmiDiseaseOntology_v0.8.obo file and collects
		gene terms.  Adds them to working MeSH obo. 
USAGE: 
        	./Gene_Merge.pl ../Ontologies/OmiDiseaseOntology_v0.8.obo 

\n";

# I/O files.
my $omi_file  = shift || die "$usage\n";
my $mesh_fh   = IO::File->new('../data/CVDO.obo', 'r')        || die "Can't open mesh file\n $usage\n";
my $ext_fh    = IO::File->new('../data/Not_in_ontology', 'w') || die "Can't open output file\n";


#-----------------------------------------------------------------

# Object creator.
my $it = iterator_maker($omi_file);

# Collect the cardiovascular disease terms into hash of arrayrefs.
my %ref;
while ( my $ni = $it->next_node_instance ) {
        
	my $term = $ni->term;
	my $xrefs = eval { $term->dbxref_list() };
	
	foreach my $xref (@$xrefs) {
		if ($term->acc =~ /C14/){
			
			$ref{ $term->name } = [] unless exists $ref{$term->name};
			my $pair = join(':', $xref->dbname, $xref->xref_key);
	
			push @{$ref{$term->name}}, $pair;
		}
	}
}
#-----------------------------------------------------------------

# Uses working MeSH file and adds above gene terms.
my %mesh;
my $acc;
my $term;
while ( defined( my $line = <$mesh_fh> ) ) {
    chomp $line;

    if ( $line =~ /(\[Term\])/ ) {
        next;
    }
    elsif ( $line =~ /(\[Typedef\])/ ) {
        next;
    }
    elsif ($line =~ /(id:.+)/ ) {
	$term = $1;
    }
    elsif ( $line =~ /name:\s+(.+)/ ) {
        $acc = $1;
        $mesh{$acc} = [$term] unless exists $mesh{$1};
    }
    else {
        my $element = $line;
        push @{ $mesh{$acc} }, $element;
    }
}

#-----------------------------------------------------------------


# Uses the Merge method to add gene terms to working MeSH file.
my $combine = Hash::Merge->new();
my %f_combine = %{ $combine->merge( \%mesh, \%ref ) };


#-----------------------------------------------------------------

# Output in obo format with Omi genes.
my @term;
foreach my $k (keys %f_combine) {

	foreach my $v (@{ $f_combine{$k}}) {
		push @term, $v;
	}
	my $rev_word = term_cleaner($k);

	my $terms = "name: $rev_word ";
	push @term, $terms;
}

foreach my $i (@term) {
	chomp $i;
	
	$i =~ s/^(GENE:.+)/xref: $1/g;
	$i =~ s/^(id:\s+(D\d+))/[Term]\n$1/g;
	print "$i\n";
}

close $omi_file;
$mesh_fh->close;



