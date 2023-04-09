use strict;
use warnings;

use PDF::API2;

my $filename = 'Hotlist1364.pdf';
my $pdf = PDF::API2->open($filename);

# Extract text from each page starting on page 2
for my $page_num (2 .. $pdf->pages()) {
    my $page = $pdf->openpage($page_num);
    my $content = $page->text();
    print "Page $page_num:\n$content\n";
}
