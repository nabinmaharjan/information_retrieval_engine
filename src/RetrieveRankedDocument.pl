use strict;
use warnings;
use File::Basename;
use lib dirname(__FILE__);
#
require InformationRetrieval;

my $query = "retriev";
my $json_text = &getRankedRelevantDocuments($query);
print $json_text;
