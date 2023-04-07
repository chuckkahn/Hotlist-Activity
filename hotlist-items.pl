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

# Loop through each page, skipping the first
for my $page_num (2 .. $pdf->numPages()) {
    my $text = $pdf->getPageText($page_num);

    # Split text into lines and search for Production Names
    my @lines = split /\n/, $text;
    for (my $i = 0; $i < scalar(@lines); $i++) {
        if ($lines[$i] =~ /Production stage:/) {
            my $production_name = $lines[$i+1] . ' ' . $lines[$i+2];
print "$page_num - $i\n";
            # Write production name to CSV
            $csv->print($fh, [$production_name]);
        }
    }
}

close $fh;
