#!/usr/bin/perl -w
use strict;
use IO::File;
use GO::Parser;
use LWP::UserAgent;

my $usage = "\n
Description:
		Accepts obo formatted file, and collects all http links. 
		Tests to see if their valid links.
		Output is status code and link from obo file.
		Output is status of all links not just dead ones.
USAGE: 
        	./OBO_Crawler.pl <obo file>
\n";

# I/O for object and files 
my $input = shift || die "$usage\n"; 
my $obo_file = IO::File->new($input, 'r') || die "Can't open IO\n";

#==================================================#

# go-perl does not capture the xrefs from synonyms
# so this loop does.
my @syn_links;
while (defined (my $file = <$obo_file>)) {
	chomp $file;

	if ($file =~ /^synonym:.+\[(.+:\/\/.+)\]$/) {
		my $syn_link = $1;
		push @syn_links, $syn_link;	
	}
}

#==================================================#

# Collects xrefs using go-perl. #

# Make the iterator object.
my $parser = new GO::Parser( { handler => 'obj' } );
$parser->parse($input);

# make graph object
my $graph = $parser->handler->graph;

# make iterator object
my $it = eval { $graph->create_iterator };

# Using go-perl object to collect http links to pass to bot.
my @links;
my @def_links;
while ( my $ni = $it->next_node_instance ) {

	my $term     = $ni->term;
	my $def_xref = $term->definition_dbxref_list;
	my $xrefs    = $term->dbxref_list();


	foreach my $xref (@$xrefs) {
		my $refs = $xref->xref_key;
		
		if ($refs =~ /^http.+/g) {
			push @links, $refs;
		}
	}

	foreach my $def (@$def_xref) {
		my $url = $def->xref_key;
		if ($url =~ /^http.+/) {
			push @def_links, $url;
		}	
	}
}

# Combine the link lists together.
push(@links, @def_links, @syn_links);


#==================================================#

# Using LWP::UserAgent to create bot agent.

my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;

foreach my $link (@links) { 
	chomp $link;

	my $head = $ua->head($link);
	my $status = $head->status_line;

	push (my @status, $status);

	foreach my $i (@status) {
		if ($i =~ /200/){
			next;
		}
		else {
			print "Dead link: \t$i => $link\n";
		}
	}
}


#==================================================#

print "\n

Errors in the range of 400-449, and 500-510  are error messages.
Forbidden is common, due to the server rejecting the bot.
Error 404 seem the best to identify bad links.
Check error code here: http://search.cpan.org/~gaas/HTTP-Message-6.02/lib/HTTP/Status.pm#CONSTANTS

\n";
			
