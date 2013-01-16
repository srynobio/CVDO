#!/usr/bin/perl
use strict;
use warnings;

# File coded by Marc S. for Karen Eilbeck
# File modified by Shawn Rynearson for Karen Eilbeck
# Changed Paths, updated MeSH files, etc.  Added additional comments.

##Module
use XML::Parser;
use List::MoreUtils qw/uniq/;

##XMLfile to parse
my $xmlfile = shift; 

##Initialize Variables
my $tag;

##Open file to write parsed data
open( PARSEDMESH, '>', "tmp1.txt" )
  or die "Cannot open File\n";

##Dnium. (Dorland, 28th ed)||    ||    )
my $parser = new XML::Parser;

##Define Event Handlers
$parser->setHandlers(
    Start   => \&startElement,
    End     => \&endElement,
    Char    => \&characterData,
    Default => \&default
);

##Instructions to Parser
$parser->parsefile($xmlfile);

##Start Tag
sub startElement {
  SWITCH: {
        my ( $parseinst, $element, %attr ) = @_;
        if ( $element eq "DescriptorRecord" ) {
            $tag = 'descriptorrecord';
            last SWITCH;
        }
        elsif ( $element eq "DateCreated" ) {
            $tag = 'datecreated';
            last SWITCH;
        }
        elsif ( $element eq "TreeNumberList" ) {
            $tag = 'treenumberlist';
            last SWITCH;
        }
        elsif ( $element eq "Concept" ) {
            $tag = 'concept';
            print PARSEDMESH ":($attr{PreferredConceptYN}";
            last SWITCH;
        }
        elsif ( $element eq "ConceptUI" ) {
            $tag = 'conceptui';
            last SWITCH;
        }
        elsif ( $element eq "ScopeNote" ) {
            $tag = 'scopenote';
            last SWITCH;
        }
        elsif ( $element eq "SemanticTypeList" ) {
            $tag = 'semantictypelist';
            last SWITCH;
        }
        elsif ( $element eq "RecordOriginatorsList" ) {
            $tag = 'recordsoriginatorslist';
            last SWITCH;
        }
    }
}
##
sub endElement {
    my ( $parseinst, $element ) = @_;
    if ( $element ne "" ) {
        if ( $element eq "DescriptorRecord" ) {
            print PARSEDMESH "\n";
        }
        elsif ( $element eq "Concept" ) {
            print PARSEDMESH ")";
        }
    }
}

##
sub characterData {
    my ( $parseinst, $data ) = @_;
    if ( ( $tag eq 'descriptorrecord' ) ) {

        #$data =~ s/ //g;
        $data =~ s/\n/:/g;
        print PARSEDMESH $data;
    }
    elsif ( $tag eq 'treenumberlist' ) {

        #$data =~ s/ //g;
        $data =~ s/\n/\//g;
        print PARSEDMESH $data;
    }
    elsif (( $tag eq 'concept' )
        || ( $tag eq 'scopenote' ) )
    {
        $data =~ s/\n//g;
        print PARSEDMESH "|";
        print PARSEDMESH $data;
    }
    else {
    }
}

##What to do if you run into an unacceptable tag
sub default {
    my ( $parseinst, $data ) = @_;
}

close PARSEDMESH;
