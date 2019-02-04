use strict;
use warnings;
use File::Basename;
use JSON;
use lib dirname(__FILE__);
require ir;
require FileUtils;

sub getRankedRelevantDocuments(){	
	my $queryText = $_[0];#"information retrieval";
	my $indexingFile = dirname(__FILE__)."/../data/indexing.dat";
	my $documentLengthFile = dirname(__FILE__)."/../data/documentLength.dat";
	my $docDirectory = dirname(__FILE__)."/../processed";

	my %invertedIndex = &readInvertedIndexFile($indexingFile);
	my %documentVectorLength = &readHashFromFile($documentLengthFile);

	my $numOfDocuments = keys %documentVectorLength;
	my %retrievedDocuments;

	#stem the query
	my @queryTokens = split /\s/,$queryText;
	@queryTokens = &stemQuery(@queryTokens);
	my %queryTermFrequencyMap = &getTermFrequencyMapForDocument(@queryTokens);
	my $queryVectorLength = 0;

	foreach my $queryToken(keys %queryTermFrequencyMap){
		if(!exists($invertedIndex{$queryToken})){
			next;
		}
		my $df = $invertedIndex{$queryToken}{df};
		my $idf = log($numOfDocuments/$df);
		my $queryTokenWeight = $idf * $queryTermFrequencyMap{$queryToken};
		$queryVectorLength += $queryTokenWeight ** 2;
		my @documentList = @{$invertedIndex{$queryToken}{docs}};
		foreach my $entry (@documentList){
			my $tf = $entry->{tf};
			my $document = $entry->{Id};
			if(!exists($retrievedDocuments{$document})){
				$retrievedDocuments{$document} = 0;
			}
			$retrievedDocuments{$document} += $queryTokenWeight * $tf * $idf;
		}
	}

	#compute length of vector Q
	$queryVectorLength = $queryVectorLength ** (1/2);

	#normalize cosine similarity of retrieved documents with query Q
	foreach my $document(keys %retrievedDocuments){
		$retrievedDocuments{$document} = $retrievedDocuments{$document}/($queryVectorLength * $documentVectorLength{$document});
	}

	my @rankedDocuments = ();
	#rank the documents in the descending order of cosine similarity
	foreach my $document(sort{$retrievedDocuments{$b} <=> $retrievedDocuments{$a}} keys %retrievedDocuments){
		my @summaryInfo = &getSummaryInfoForRetrievedDocument($docDirectory."/".$document.".txt"); 
		chomp(@summaryInfo);
		push @rankedDocuments,{title=>$summaryInfo[1],url=>$summaryInfo[0]};
	}
	
	my $json = new JSON;
	my $json_text=$json->encode(\@rankedDocuments);
	return $json_text;
}

1;