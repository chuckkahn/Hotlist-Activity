#!/usr/bin/perl

use Date::Calc::XS qw(Delta_Days Today);

open my $fh_in, '<', 'output.csv' or die "Failed to open file: $!";

my $output = '<html><head><title>Hotlist Items Gantt Chart</title></head><body><table border="1"><tr><th>Production Name</th><th>Start Date</th><th>End Date</th><th></th></tr>';

# initialize variables for keeping track of the Gantt chart bar position
my $earliest_start_date;
my $latest_end_date;
my $total_days;

while (my $line = <$fh_in>) {
  chomp $line;
  my @fields = split /,/, $line;

  $fields[2] =~ s/"//g;
  $fields[3] =~ s/"//g;

  if ($fields[0] =~ /^\d+$/ && $fields[2] && $fields[3]) {
    my ($start_month, $start_day, $start_year) = split /\s+/, $fields[2];
    my ($end_month, $end_day, $end_year) = split /\s+/, $fields[3];

    if ($start_month && $start_day && $start_year && $end_month && $end_day && $end_year) {
      my $start_date = sprintf("%04d-%02d-%02d", $start_year, month_to_number($start_month), $start_day);
      my $end_date = sprintf("%04d-%02d-%02d", $end_year, month_to_number($end_month), $end_day);

      if (Delta_Days(int($start_year), month_to_number($start_month), int($start_day),
                      int($end_year), month_to_number($end_month), int($end_day)) >= 0) {

        # calculate the width of the Gantt chart bar based on the difference in days
        my $gantt_width = Delta_Days(int($start_year), month_to_number($start_month), int($start_day),
                            int($end_year), month_to_number($end_month), int($end_day));

        # update earliest start date and latest end date if necessary
        if (!$earliest_start_date || $start_date lt $earliest_start_date) {
          $earliest_start_date = $start_date;
        }
        if (!$latest_end_date || $end_date gt $latest_end_date) {
          $latest_end_date = $end_date;
        }

        if ($gantt_width >= 0) {

print "start_date is [$start_date]\n";
print "end_date is [$end_date]\n";

my ($start_year, $start_month, $start_day) = split('-', $start_date);
my ($earliest_year, $earliest_month, $earliest_day) = split('-', $earliest_start_date);
my $days_diff = Delta_Days($start_year, $start_month, $start_day, $earliest_year, $earliest_month, $earliest_day);
my $gantt = "<div style='background-color: blue; width: " . ($gantt_width + 1) . "px; margin-left: " . ($days_diff + 1) . "px;'>&nbsp;</div>";

          $output .= "<tr><td>$fields[1]</td><td>$start_date</td><td>$end_date</td><td style='position: relative; z-index: -1;'>$gantt</td></tr>";

my ($latest_end_year, $latest_end_month, $latest_end_day) = split /-/, $latest_end_date;
my ($earliest_start_year, $earliest_start_month, $earliest_start_day) = split /-/, $earliest_start_date;

$total_days = Delta_Days($latest_end_year, $latest_end_month, $latest_end_day, $earliest_start_year, $earliest_start_month, $earliest_start_day) + $gantt_width;

        } else {
          print "Invalid date range: $start_date - $end_date\n";
        }
      } else {
        print "Skipping record with empty date: $line\n";
      }
   

    }
  }
}

$output .= '</table></body></html>';

open my $fh_out, '>', 'hotlist-items-gantt2.html' or die "Failed to open file: $!";
print $fh_out $output;
close $fh_out;

close $fh_in;

sub month_to_number {
  my %month_map = (
    'JAN' => 1,
    'FEB' => 2,
    'MAR' => 3,
    'APR' => 4,
    'MAY' => 5,
    'JUN' => 6,
    'JUL' => 7,
    'AUG' => 8,
    'SEP' => 9,
    'OCT' => 10,
    'NOV' => 11,
    'DEC' => 12,
  );
  my $month = shift;
  return $month_map{uc substr($month, 0, 3)} // 0;
}

