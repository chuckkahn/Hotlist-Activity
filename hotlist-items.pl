#!/usr/bin/perl

use strict;
use warnings;

use CAM::PDF;
use Text::CSV;

my $filename = 'Hotlist1364.pdf';
my $pdf = CAM::PDF->new($filename);

# Set up CSV writer
my $csv = Text::CSV->new({binary => 1, auto_diag => 2, eol => "\n"});
open my $fh, ">:encoding(utf8)", "output.csv" or die "output.csv: $!";

# Write CSV header
$csv->print($fh, ['Page', 'Production Name', 'Start Date', 'End Date']);

# Loop through each page, skipping the first
for my $page_num (2 .. $pdf->numPages()) {
    my $text = $pdf->getPageText($page_num);

    # Split text into lines
    my @lines = split /\n/, $text;
    my $num_lines = scalar(@lines);

    # Initialize variables for current production name, start date, and end date
    my ($production_name, $start_date, $end_date);

    # Loop through each line and extract information as appropriate
    for (my $i = 0; $i < $num_lines; $i++) {
        my $line = $lines[$i];

        # Look for "Production stage:" delimiter
        if ($line =~ /^Production stage:/) {
            # Write previous production name, start date, and end date to CSV
            if ($production_name) {
                $csv->print($fh, [$page_num, $production_name, $start_date, $end_date]);
            }

            # Extract new production name
            $production_name = $lines[$i+1] . ' ' . $lines[$i+2];

            # Skip lines until the start date
            while ($i < $num_lines - 1 and $lines[++$i] !~ /^Production$/) {
            }

            # Extract start and end dates
            $start_date = $lines[++$i];
            $end_date = $lines[++$i];
        } elsif ($line =~ /^Production$/) {
            # Extract start and end dates
            $start_date = $lines[++$i];
            $end_date = $lines[++$i];
        }
    }

    # Write final production name, start date, and end date to CSV
    if ($production_name) {
        $csv->print($fh, [$page_num, $production_name, $start_date, $end_date]);
    }
}

close $fh;
