$fields[2] =~ s/"//g;
$fields[3] =~ s/"//g;

 New CPAN.pm version (v2.34) available.
  [Currently running version is v2.22]
  You might want to try
    install CPAN
    reload cpan
  to both upgrade CPAN.pm and run the new version without leaving
  the current session.

my ($start_year, $start_month, $start_day) = split('-', $start_date);
my ($earliest_year, $earliest_month, $earliest_day) = split('-', $earliest_start_date);
my $days_diff = Delta_Days($start_year, $start_month, $start_day, $earliest_year, $earliest_month, $earliest_day);
my $gantt = "<div style='background-color: blue; width: " . ($gantt_width + 1) . "px; margin-left: " . ($days_diff + 1) . "px;'>&nbsp;</div>";
