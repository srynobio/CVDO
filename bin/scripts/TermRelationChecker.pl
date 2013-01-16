#!/usr/bin/perl
use strict;
use warnings;
use IO::File;

my $oboFh = IO::File->new($ARGV[0], 'r');

my (%obo, $id);
foreach my $i (<$oboFh>){
    chomp $i;
    
    next if $i =~ /^xref:(.*)$/;
    next if $i =~ /^property_value:(.*)$/;  
    next if $i =~ /^def:(.*)$/;  
    next if $i =~ /^comment:(.*)$/;  
 
    if ($i =~ /^id:\s+(\S+)$/){
        $id = $1;
        $obo{$id} = [] unless exists $obo{$id};
    }
    elsif ($i =~ /(\S+):\s+([A-Z]+:(\d+))/){
        push @{$obo{$id}}, $2;
    }
    elsif ($i =~ /(\S+):\s+(\w+)\s+([A-Z]+:(\d+))/){
        push @{$obo{$id}}, $3;
    }
    else { next; }
}

# get all term id's
my @ids = keys %obo;

# get all relationships.
my @relation;
while ( my ($keys, $values) = each %obo ){
    foreach (@{$values}) {
        push @relation, $_;
    }
}

# sort and print out.
my $dangle     = arrayCompare( \@relation, \@ids );
my @sortDangle = sort {$a cmp $b} @{$dangle};

my @returnLine;
foreach (@sortDangle){
    my $line = system("grep '$_' $ARGV[0]");
    push @returnLine, $line unless $line eq '0';
}

map { print $_, "\n" }@returnLine;


#-------------------------------------------------
#-------------------------------------------------
#-------------------------------------------------

# perl cookbook standard.
sub arrayCompare {

    my ($A, $B) = @_;
    
    my %seen  = ();
    my @aonly = ();
    
    # build lookup table
    foreach my $item (@{$B}) {
        $seen{$item} = 1 unless exists $seen{$item};
    }
    
    # find only elements in @A and not in @B
    foreach my $item (@{$A}) {
        unless ($seen{$item}) {
        # it's not in %seen, so add to @aonly
        push(@aonly, $item);
        }
    }
    return \@aonly;
}

#-------------------------------------------------




