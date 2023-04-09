use strict;
use warnings;
use LWP::Simple;
use CAM::PDF;

# Download the PDF file
my $url = 'https://www.dgc.ca/assets/Uploads/Hotlist1364.pdf';
my $filename = 'Hotlist1364.pdf';
my $status = getstore($url, $filename);
die "Cannot download PDF file: $status" unless is_success($status);

