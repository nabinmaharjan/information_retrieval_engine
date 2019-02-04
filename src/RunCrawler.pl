use strict;
use warnings;
use File::Basename;
use lib dirname(__FILE__);
require Crawler;


print "Starting crawling...\n";
my @website = ("http://www.cs.memphis.edu/~vrus/teaching/ir-websearch","http://www.memphis.edu");
&crawlWebsites(@website);