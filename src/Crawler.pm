use strict;
use warnings;
use File::Basename;
use LWP::Simple;
use WWW::Mechanize;
use Try::Tiny;
use lib dirname(__FILE__);
require ir;
require PatternRepository;
require DocumentParser;
require FileUtils;

my $crawlWaitTime = 2;#2 sec delay 
my $numberOfDocumentsToCrawl = 10000;
my @urlWorkListQueue;
my %completedListQueue;
my %urlWithLessThanFiftyTokens;
my %invalidUrlList;
sub crawlWebsites(){

	@urlWorkListQueue = @_;
	my %urlMap;
	my $processedFolder = dirname(__FILE__)."/../processed/";
	my $outputFolder = dirname(__FILE__)."/../output/";
	my $documentID=0;
	print "starting with the seed url..\n";
	while((my $url= shift @urlWorkListQueue)){
		try{
				if($documentID >= $numberOfDocumentsToCrawl){
				last;
				}
				
				if(exists($completedListQueue{$url})){
					print "already processed: ".$url."\n";
					next;
				}
				
				if(exists($invalidUrlList{$url})){
					print "already processed as invalid: ".$url."\n";
					next;
				}
				
				if(exists($urlWithLessThanFiftyTokens{$url})){
					print "already processed as document with less than fifty tokens: ".$url."\n";
					next;
				}
				my $document;
				my $pattern = &getTextLinkPattern();
				if($url =~ /$pattern/igs){
					#print $url;
					sleep $crawlWaitTime;
					$document = get($url);
					if(!$document){
						$invalidUrlList{$url}=1;
						print "Invalid Url: $url\n";
						next;
					}
					#print $document;
				}
				else{
					$pattern = &getpdfLinkPattern();
					if($url =~/$pattern/igs){
						sleep $crawlWaitTime;
						my $file = $processedFolder."/temp.pdf";
						getstore($url, $file);
						my $pdf = CAM::PDF->new($file);
						if(!$pdf){
							$invalidUrlList{$url}=1;
							print "Invalid Url: $url\n";
							next;
						}
						$document = &getContentFromPdfFile($file);
					}
					else{
						my $mech = WWW::Mechanize->new;
						sleep $crawlWaitTime;
						$mech->get($url);
						if($mech->is_html() == 1){
							#print "content length:".$mech->response->header('Content-Length');
							#if($mech->response->header('Content-Length') > 500){
								#print $url;
								my @relevantLinks = ();
								@relevantLinks = &getRelevantUrlsOnly($mech->links());
								#print "I am here!!1";
								push @urlWorkListQueue,@relevantLinks;
								
								$document = &getContentFromHtml($url);
								#foreach my $myLink(@relevantLinks){
									#print $myLink."\n";
								#}
							#}
						}else{
							$invalidUrlList{$url}=1;
							print "Invalid Html Url: $url\n";
							next;
						}
					}
				}
				#print $url."\n";
				#print "$document\n";
			my @processedDocument = ();
			@processedDocument = &getProcessedDocument($document);
			my $numberOfTokens = @processedDocument;
			if($numberOfTokens<50){
				$urlWithLessThanFiftyTokens{$url}=1;
				next;
			}
			$documentID++;
			my $file = $processedFolder."/".$documentID.".txt";
			my @headInfo=();
			my $summaryText = &extractSummaryText($document);
			push @headInfo,$documentID;
			push @headInfo,$url;
			push @headInfo,$summaryText;
			push @headInfo,"****";
			&saveContentsToFile(\@headInfo,\@processedDocument,$file);
			$completedListQueue{$url}=1;
			print "completed processing document: $documentID with url: $url\n";
		}
		catch{
				print "caught error: $_\n";
				$invalidUrlList{$url}=1;
		};		
	}

	#save urls with < 50 tokens
	my $file=$outputFolder."/DocumentsWithLessThanFiftyTokens.txt";
	my @headInfo = ("List of document urls that have less than fifty tokens:");
	my @lessThanFiftyTokenList = keys %urlWithLessThanFiftyTokens;
	&saveContentsToFile(\@headInfo,\@lessThanFiftyTokenList,$file);
	
	#save documents with invalid urls
	$file=$outputFolder."/DocumentsWithInvalidUrls.txt";
	@headInfo = ("List of document urls with invalid urls:");
	my @invalidList = keys %invalidUrlList;
	&saveContentsToFile(\@headInfo,\@invalidList,$file);
	
	#save processed document urls
	$file=$outputFolder."/ProcessedDocumentList.txt";
	@headInfo = ("List of document urls processed by Crawler:");
	my @completedList = keys %completedListQueue;
	&saveContentsToFile(\@headInfo,\@completedList,$file);
	print "Crawling completed!!!";
}

1;