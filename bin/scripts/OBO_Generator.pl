#!/usr/bin/perl

use warnings;
use strict;
use List::MoreUtils qw/uniq/;

# File coded by Marc S. for Karen Eilbeck
# File modified by Shawn Rynearson for Karen Eilbeck
# Changed Paths, updated MeSH files, etc.  Added additional comments.

my @DescriptorUI;
my @DescriptorName;
my @TreeNumber;
my @elements;
my %treehash;
my @newlist;

# open and write to files for shell script.
my $in_file = shift;
my $out_file = shift;

open( MESHOBO, '>', $out_file) or die "Cannot open file\n";

######################################Pull out only C tree values
open( PARSEDMESH, '<', $in_file)
  or die "Cannot open file\n";

foreach (<PARSEDMESH>) {
    if ( $_ ne "" ) {
        if ( $_ =~ m/C14/g ) {
            push( @newlist, $_ );
        }
        else { }
    }
    else { }
}
close PARSEDMESH;

######################################Create Hash of Tree Values to UI

open( PARSEDMESH, '<', $in_file)
  or die "Cannot open file\n";

foreach (<PARSEDMESH>) {
    if ( $_ ne "" ) {
        my @split = split( /:/,  $_ );
        my @tree  = split( /\//, $split[5] );
        foreach (@tree) {
            $_ =~ s/ //g;
            my $linelength = length($_);
            if ( $linelength > 2 ) {
                if ( !( exists $treehash{ $_{ $split[1] } } ) ) {
                    $treehash{$_}{ $split[1] } = 1;
                }
                else { }
            }
        }
    }
}

close PARSEDMESH;

#############################################Create OBO file

#open(PARSEDMESH, '<', $in_file)
#    or die "Cannot open file\n";

foreach (@newlist) {
    if ( $_ ne "" ) {
        my @split  = split( /:/, $_ );
        my $ccount = 0;
        my @tree   = split( /\//, $split[5] );

        foreach (@tree) {
            if    #($_ =~ m/./g) {
                  ( $_ =~ m/C14/g ) {
                      $ccount++;
                }
        }
        if ( $ccount ne 0 ) {
            print MESHOBO "[Term]\nid: $split[1]\nname: $split[3]\n";
            foreach (@split) {
                chomp $_;
                if ( $_ =~ m/\(Y./ ) {
                    my @desc = split( /\|/, $_ );
                    print MESHOBO "def: \"$desc[3]\"[MeSH:sr]\n";
                }
                else { }
            }
            my @quicktree;
            foreach (@tree) {
                $_ =~ s/ //g;
                if    #($_ =~ m/./g) {
                      ( $_ =~ m/C14/g ) {
                          my $linelength = length($_);
                          if ( ( $linelength > 3 ) ) {
                              my $chop = $_;
                              chop $chop;
                              chop $chop;
                              chop $chop;
                              chop $chop;
                              foreach my $uid ( keys %{ $treehash{$chop} } ) {
                                  push( @quicktree, $uid );

                                  # print MESHOBO
                                  #"is_a: $uid\t$chop\t$_\n";
                              }
                          }
                          else {
                          }
                    }
                    else {
                          if ( $_ ne "" ) {

                              #print MESHOBO "is_a: other\t$_\n";
                              #push (@quicktree, "Other");
                          }
                    }

            }
            my @sortquicktree = uniq sort @quicktree;
            foreach (@sortquicktree) {
                print MESHOBO "is_a: $_\n";
            }

            print MESHOBO "\n";
        }
    }
    else { }
}

#my @elementsort = uniq sort @elements;
#print "@elementsort\n";
