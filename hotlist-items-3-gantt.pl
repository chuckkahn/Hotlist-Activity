#!/usr/bin/perl

use Date::Calc qw(Delta_Days);

open my $fh_in, '<', 'output.csv' or die "Failed to open file: $!";

my $output = '<html><head><title>Hotlist Items Gantt Chart</title></head><body><table border="1"><tr><th>Production Name</th><th>Start Date</th><th>End Date</th></tr>';

while (my $line = <$fh_in>) {
  chomp $line;
  my @fields = split /,/, $line;

  if ($fields[0] =~ /^\d+$/ && $fields[2] && $fields[3]) {
    my ($start_month, $start_day, $start_year) = split /\s+/, $fields[2];
    my ($end_month, $end_day, $end_year) = split /\s+/, $fields[3];

    my $start_date = "$start_year-$start_month-$start_day";
    my $end_date = "$end_year-$end_month-$end_day";

    if (Delta_Days(split(/-/, $start_date), split(/-/, $end_date)) >= 0) {
      $output .= "<tr><td>$fields[1]</td><td>$start_date</td><td>$end_date</td></tr>";
    } else {
      print "Invalid date range: $start_date - $end_date\n";
    }
  } else {
    print "Skipping line: $line\n";
  }
}

$output .= '</table></body></html>';

open my $fh_out, '>', 'hotlist-items-gantt.html' or die "Failed to open file: $!";
print $fh_out $output;
close $fh_out;

close $fh_in;
