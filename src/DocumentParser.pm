use strict;
use warnings;
use File::Basename;
use LWP::Simple;
use HTML::Parser;
use CAM::PDF;
use CAM::PDF::PageText;

use lib dirname(__FILE__);
require FileUtils;

sub getContentFromHtml(){
	my $file = $_[0];
	my $document = get($file);
	
	#strip javascript and  css
	$document = &removeScriptAndStyleContents($document);
	
	my @data;
	#strip html tags from text
	HTML::Parser->new(text_h => [\my @accum, "text"])->parse($document);
	push @data,map $_->[0], @accum;
	
	my $htmlText = "";
	foreach my $text(@data){
		$htmlText= $htmlText."\n".$text;
	}
	return $htmlText;	
}

sub getContentFromTextFile(){
   my $file = $_[0];
   return &getContentAsStringFromFile($file);
}

sub getContentFromPdfFile(){
	my $file = $_[0];
	my $pdf = CAM::PDF->new($file);
	my $document="";
	foreach(1..($pdf->numPages())){
		my $content = CAM::PDF::PageText->render($pdf->getPageContentTree($_));
		$document = $document.$content."\n";
	}
	return $document;
}

1;