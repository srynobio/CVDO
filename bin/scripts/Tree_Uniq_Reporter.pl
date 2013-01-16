#!/usr/bin/perl -w
use strict;
use IO::File;

# Script by Shawn Rynearson For Karen Eilbeck
# shawn.rynearson@gmail.com
# Used for DO development project.

my $usage = "\n
Description:
		Script is used to find the non-uniq items generated from
		Dup_Remover.pl.  Output is names of terms with 2 or more
		parents.  Some terms will still be duped, because they
		have more then two terms.

USAGE: 
        ./Tree_Uniq_Report.pl 
\n";

# I/O
my $in_fh = IO::File->new('traversed_uniqs.txt', 'r') || die "Can't open open file. $usage\n";
my $out_fh = IO::File->new('uniq_list.txt', 'w') || die "Can't open write file\n";


# Declared variables.
my %name_seen;
my $multiple_parent_count;

while ( defined( my $line = <$in_fh> ) ) {
    chomp $line;

    my ( $name, $acc, $parent_acc ) = split /\t/, $line;
    push( my @names, $name );

    my @new_name = grep { !/_/ } @names;

    # Remove the ! before hash count, now gives non-uniq names.
    my @uniq_names = grep { $name_seen{$_}++ } @new_name;

    foreach (@uniq_names) {
        $multiple_parent_count++;
        print $out_fh "$acc\n";
    }
}

$in_fh->close;
$out_fh->close;


