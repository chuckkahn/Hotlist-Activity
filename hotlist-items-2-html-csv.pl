#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use HTML::TreeBuilder;
use Text::CSV;

# create a UserAgent object
my $ua = LWP::UserAgent->new;
$ua->agent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3');

# create a CSV object with the desired settings
my $csv = Text::CSV->new({ binary => 1, auto_diag => 1, eol => "\n" });

# specify the URL to scrape
my $url_template = "https://www.dgc.ca/en/ontario/avails-and-production-lists/ontario-productions/ProductionSearchForm?productionName=&type=0&Submit=Submit&directory=&start=%d";

# loop through each page and extract the production information
my @rows;
for (my $start = 0; $start <= 100; $start += 10) {
    my $url = sprintf($url_template, $start);

    # send a GET request and get the response
    my $response = $ua->get($url);

    # check if the request was successful
    if ($response->is_success) {
        # parse the HTML content using HTML::TreeBuilder
        my $tree = HTML::TreeBuilder->new_from_content($response->decoded_content);

        # find all <a> tags that have a "href" attribute containing "productionViewForm?p="
        my @links = $tree->look_down(
            _tag => "a",
            href => qr/productionViewForm\?p=\d+/
        );

        # loop through each link and extract the production information
        foreach my $link (@links) {
            my $name = $link->as_trimmed_text;
            my $url = "https://www.dgc.ca" . $link->attr("href");
            my ($production_number) = $url =~ /p=(\d+)/;
            push @rows, [$production_number, $name, $url];
        }

        # clean up the HTML::TreeBuilder object
        $tree->delete;
    }
    else {
        # print the HTTP status code and error message
        print "Error: " . $response->status_line . "\n";
    }
}

# sort the rows by production number
@rows = sort { $a->[0] <=> $b->[0] } @rows;

# write the rows to a CSV file
my $csv_file = "productions.csv";
open(my $fh, ">:encoding(utf8)", $csv_file) or die "Cannot open CSV file $csv_file: $!";
$csv->print($fh, ["Production Number", "Production Name", "URL"]);
foreach my $row (@rows) {
    $csv->print($fh, $row);
}
close($fh);
print "CSV file $csv_file written successfully\n";
