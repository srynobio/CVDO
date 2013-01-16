#!/usr/bin/perl -w
use strict;
use GO::Parser;
use IO::File;

# Script by Shawn Rynearson For Karen Eilbeck
# shawn.rynearson@gmail.com
# Used for DO development project

#--------------------------------------------------------
#------------------------MAIN----------------------------
#--------------------------------------------------------

my $usage = "\n
Description:
		Adds HGNC_File data to xref: GENE.
USAGE: 

		./HGNC_Gene_Builder.pl <HGNC File> <OBO File>
\n";

# I/O for object.
my $hgnc_file = IO::File->new($ARGV[0], 'r') || die "Can't open HGNC file $usage\n";
my $cvdo_obo  = IO::File->new($ARGV[1], 'r') || die "Can't open CVDO file $usage\n";

my @id_list;
while (defined (my $line = <$hgnc_file>)) {
	chomp $line;

	if ($line =~ /^URL/) { next }
	push @id_list, $line;
}

# create hashref of desired terms.
# one term must have HGNC symbol.
my $arranged_hgnc = hgnc_file_builder(\@id_list);


foreach my $i (<$cvdo_obo>) {
	chomp $i;

	if ($i =~ /^xref: HGNC_gene:(.+)/ ) {   
		my ($sym, $id, $dec)  = symbol_match($1);
		$i =~ s/xref: HGNC_gene:(.+)/xref: HGNC_gene:$1 "$id, $dec"/g;
	}
	elsif ($i =~ /^xref: transitive_HGNC_gene:(.+)/) {
		my ($sym, $id, $dec)  = symbol_match($1);
		$i =~ s/xref: transitive_HGNC_gene:(.+)/xref: transitive_HGNC_gene:$1 "$id, $dec"/g;
	}
	print "$i\n";
}

close->$hgnc_file;
close->$cvdo_obo;

#--------------------------------------------------------
#------------------------SUBS-----------------------------
#--------------------------------------------------------

sub hgnc_file_builder {

	my $input = shift;
	my %south_of_heaven;

	foreach my $i (@$input) {

		my ($HGNC_ID, $Approved_Symbol, $Approved_Name, $Status, $Locus_Type, $Locus_Group, $Previous_Symbols, $Previous_Names, $Synonyms, $Name_Synonyms, $Chromosome, $Date_Approved, 
		    $Date_Modified, $Date_Symbol_Changed, $Date_Name_Changed, $Accession_Numbers, $Enzyme_ID, $Entrez_Gene_ID, $Ensembl_Gene_ID, $Mouse_Genome_Database_ID, $Specialist_Database_Links, 
		    $Specialist_Database_ID, $Pubmed_ID, $RefSeq_ID, $Gene_Family_Tag, $Gene_family_description, $Record_Type, $Primary_ID, $Secondary_ID, $CCDS_ID, $VEGA_ID, $Locus_Specific_Databases, 
		    $GDB_ID, $Entrez_Gene_ID_mapped, $OMIM_ID, $RefSeq, $UniProt_ID, $Ensembl_ID, $UCSC_ID, $Mouse_Genome_Database_ID, $Rat_Genome_Database_ID) = split /\t/, $i; 


		$south_of_heaven{$Approved_Symbol} = {
			hgncid      => $HGNC_ID,
			description => $Approved_Name,
		};
	}
	return(\%south_of_heaven);
}

#--------------------------------------------------------

sub symbol_match {

	my ($cvdo_syb) = shift;

	foreach my $i (keys %$arranged_hgnc) {
		if ($cvdo_syb eq $i) {
			return ($cvdo_syb, $arranged_hgnc->{$i}->{'hgncid'}, $arranged_hgnc->{$i}->{'description'});
		}
	}
}

#--------------------------------------------------------
