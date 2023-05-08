#!/usr/bin/perl

use strict;
use warnings;
use Text::CSV;

# Set up CSV objects
my $csv = Text::CSV->new({ binary => 1, auto_diag => 1, eol => "\n" });
my $csv_in = Text::CSV->new({ binary => 1, auto_diag => 1 });
my $csv_out = Text::CSV->new({ binary => 1, auto_diag => 1 });

# Open input CSV files
open(my $prod_fh, "<", "productions.csv") or die "Can't open productions.csv: $!";
open(my $out_fh, "<", "output.csv") or die "Can't open output.csv: $!";

# Open output CSV files
open(my $merged_fh, ">", "merged.csv") or die "Can't create merged.csv: $!";
open(my $unmerged_fh, ">", "unmerged.csv") or die "Can't create unmerged.csv: $!";

# Write headers to merged and unmerged CSV files
$csv->print($merged_fh, ["Production Number", "Production Name", "URL", "Start Date", "End Date"]);
$csv->print($unmerged_fh, ["Production Number", "Production Name"]);

# Read productions.csv and store production names and URLs in a hash
my %prod_names_urls;
while (my $row = $csv_in->getline($prod_fh)) {
    my ($prod_num, $prod_name, $url) = @$row;
    $prod_names_urls{$prod_name} = $url;
}

# Read output.csv and merge with productions.csv data
my %unmerged;
while (my $row = $csv_out->getline($out_fh)) {
    my ($page, $prod_name, $start_date, $end_date) = @$row;
    my $url = $prod_names_urls{$prod_name};
    if ($url) {
        $csv->print($merged_fh, [$page, $prod_name, $url, $start_date, $end_date]);
    } else {
        $unmerged{$prod_name} = 1;
    }
}

# Write unmerged productions to unmerged.csv
foreach my $prod_name (sort keys %unmerged) {
    $csv->print($unmerged_fh, [$prod_name]);
}

# Close all file handles
close $prod_fh;
close $out_fh;
close $merged_fh;
close $unmerged_fh;

print "Merge complete.\n";
