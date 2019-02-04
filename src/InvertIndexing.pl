use strict;
use warnings;
use File::Basename;
use lib dirname(__FILE__);
use Data::Dumper;
require FileUtils;
require ir;

my $skipLines = 4;
my $indexingFile = dirname(__FILE__)."/../output/indexing.dat";
my $documentLengthFile = dirname(__FILE__)."/../output/documentLength.dat";

my %invertedIndex;
my %documentVectorLength;
print "Indexing started....\n";

my $dir = dirname(__FILE__)."/../processed";
my @files = &getListOfFilesFromDirectory($dir);

foreach my $file(@files){
	#print "$dir/$file\n";
	my $filePattern = "(\\d+)[.]txt\$";
	my $docId;
	if($file =~ /$filePattern/igs){
		$docId = $1;
		#print $docId."\n";
	}
	my @words = &getListOfLinesFromFileAfterSkipping("$dir/$file",$skipLines);
	my %termFrequencyMap = &getTermFrequencyMapForDocument(@words);
	&buildInvertedIndex(\%invertedIndex,\%termFrequencyMap,$docId);
	$documentVectorLength{$docId}=0;
}

#compute IDF and documentLength now
my $numOfDocuments = @files;
#&computeIDF(\%invertedIndex,$numOfDocuments);
foreach my $token(keys %invertedIndex){
	my $df = $invertedIndex{$token}{df};
	my $idf = log($numOfDocuments/$df);
	#$invertedIndex{$token}{idf} = $idf;
	my @documentList = @{$invertedIndex{$token}{docs}};
	foreach my $entry (@documentList){
		my $value = $entry->{tf} * $idf;
		$documentVectorLength{$entry->{Id}} += $value ** 2;
	}	
}

foreach my $doc(keys %documentVectorLength){
	my $value = $documentVectorLength{$doc};
	$documentVectorLength{$doc} =  $value ** (1/2);
}

&saveInvertedIndexFile(\%invertedIndex,$indexingFile);
&saveHashToFile(\%documentVectorLength,$documentLengthFile);

print "Indexing completed....\n";
#my %read = &readInvertedIndexFile($indexingFile);
#my %read1 = &readHashFromFile($documentLengthFile);

#print Dumper \%read;
#print Dumper \%read1;
#print $read{word1}{documentList}[0]->{docId};
