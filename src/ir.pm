use strict;
use warnings;
use File::Basename;
use Try::Tiny;
use lib dirname(__FILE__);
use WWW::Mechanize;
require Preprocessing;
require porter;
require PatternRepository;

sub getProcessedDocument(){
	my $document = $_[0];

	#convert to lower case
	$document = &convertToLowerCase($document);
	
	#remove url
	$document = &removeUrl($document);
	
	#remove html tags
	$document = &removeHtmlTag($document);
	
	#remove stop words
	my $stopWordListFile = dirname(__FILE__)."/../english.stopwords.txt";
	$document = &removeStopWordsFromText($document,$stopWordListFile);
	
	
	#filter out punctuation, digit, symbol characters
	$document = &filterOutNonWordCharactersFromText($document);
	
	#remove non-words
	$document =~ s/\W+/ /ig;
	
	#print $document;
	#remove white space characters
	my @words = split /\s/,$document;
	
	#remove newline characters
	chomp(@words);
	
	#print @words;
	#remove any empty element in the word list
	my @indexTerms = &removeEmptyElementFromList(@words);
	
	#DO stemming
	#convert indexTerms array to hash to remove duplicate Terms
	my %indexTermsHash = map {$_=>1} @indexTerms;
	
	@indexTerms = ();
	foreach my $index(sort keys %indexTermsHash){
		my $stem = porter($index);
		push @indexTerms, $stem;
	}
	
	#again remove duplicate stems if any
	%indexTermsHash=();
	%indexTermsHash = map {$_=>1} @indexTerms;
	return keys %indexTermsHash;
	
}

sub stemQuery(){
	my @words = @_;
	
	my @stemmedWords = ();
	foreach my $rawWord(@words){
		my $stem = porter($rawWord);
		push @stemmedWords, $stem;
	}
	return @stemmedWords;
}
sub getTermFrequencyMapForDocument(){
	my %wordVocabulary;
	my @words = @_;

	foreach my $word (@words){
		#convert all word to small case
		$word =~ tr/[A-Z]/[a-z]/;
		
		if(!exists($wordVocabulary{$word})){
			$wordVocabulary{$word} = 1;
		}
		else{
			$wordVocabulary{$word}++;
		}
	}
	return %wordVocabulary;
}

sub buildInvertedIndex(){

my $invertedIndex = $_[0]; # only get the reference to the hash
my %termFrequencyMap = %{$_[1]};# get the copy of hash
my $docId = $_[2];

foreach my $token(keys %termFrequencyMap){
	my %record;
	if(!exists($$invertedIndex{$token})){
		$record{df} = 1;
		my @documentList = ();
		push @documentList, {Id => $docId, tf => $termFrequencyMap{$token}};
		@{$record{docs}} = @documentList;
		%{$$invertedIndex{$token}} = %record;
	}else{
		%record = %{$$invertedIndex{$token}};
		$record{df}++;
		push @{$record{docs}}, {Id => $docId, tf => $termFrequencyMap{$token}};
		%{$$invertedIndex{$token}} = %record;
	}
}
}

sub getAbsoluteUrl(){
 my $baseurl = $_[0];
 my $resourceUrl = $_[1];
 if(!($resourceUrl =~ /^http:/igs)){
    $resourceUrl = $baseurl.$resourceUrl;
	}
	return $resourceUrl;
 
}

sub getRelevantUrlsOnly(){
  my @urlList = @_;
  my @returnUrlList;
  my %tempUrlMap;
  #e.g.  http://www.cs.memphis.edu/~vrus/teaching/ir-websearch/#schedule
  my $hashLinkPattern = &getHashLinkPattern();#"(?:#[^/]*)\$";
  my $ignoreFilePattern = &getIgnoredFilePattern();#"/(?:[^/]+[.](?:ppt|pptx|doc|docx|img|png|jpg|jpeg|gif|xls|xlsx))(\$|[?])";
  
  my $memphisDomainPattern = &getMemphisDomainPattern();#"(?:http|https)://(?:[^/]+(?:memphis.edu)(?:[^/]+)?)(?:.*)";
  foreach my $mechUrl(@urlList){
		
		my $url = $mechUrl->url_abs();
		#print "Start processing url: ".$url."\n";
		my $addUrl = 0;
		#filter out the urls that are not from memphis.edu domain
		if(!($url =~ $memphisDomainPattern)){
		  next;
		}
		
		#filter our #links e.g.  http://www.cs.memphis.edu/~vrus/teaching/ir-websearch/#schedule
		if($url =~ /$hashLinkPattern/igs){
			next;
		}
		
		#filter our doc, ppt url links e.g.  http://www.cs.memphis.edu/~vrus/teaching/ir-websearch/abc.ppt
		if($url =~ /$ignoreFilePattern/igs){
			next;
		}
		
	my $normalizedUrl = &normalizeAbsoluteUrl($url);
	#print "normalzedUrl: ".$normalizedUrl."\n";
	$tempUrlMap{$normalizedUrl} = 1;	
	}
	@returnUrlList = keys %tempUrlMap;
}
sub normalizeAbsoluteUrl(){ 
 	my $url = $_[0];
	
	my $pattern = "(http|https)://([^/]+)(.*)";
	my $restUrlPattern = "(.*)(?:/|/#)\$";
	my $defaultPortPattern = "(.*):80";
	my $domainWithHashPattern = "(.*)#\$";
	my $domain;
	my $http;
	my $restUrl;
	my $returnUrl;
	if($url =~ /$pattern/igs){
		$http = $1;
		$domain = $2;
		$restUrl = $3;
	}
	
	$http = lc($http);
	
	#change https to http
	if($http eq lc("https")){
		$http = "http";
	}
	
	#lowercase website domain
	$domain = lc($domain);
	
	#strip default port 80 in domain if any
	if($domain =~ /$defaultPortPattern/igs){
		$domain = $1;
	}
	
	#check if domain has # at the end
	if($domain =~ /$domainWithHashPattern/igs){
		$domain = $1;
	}
	
	#remove / at the end of url if any
	if($restUrl ne ""){
		if($restUrl =~ /$restUrlPattern/igs){
			$restUrl = $1;
		}	
	}
	
	$returnUrl = $http."://".$domain.$restUrl;
	return $returnUrl;
}

sub buildIndexTermsFromDocument(){
	my $document = $_[0];
	my @processedDocument = &getProcessedDocument($document);
	return @processedDocument;
}

1;