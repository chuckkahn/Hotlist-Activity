
for (my $page = 0; $page <= 100; $page += 10) {


    # create a Text::CSV object for writing to CSV
    my $csv = Text::CSV->new({ binary => 1, auto_diag => 1, eol => "\n" });
