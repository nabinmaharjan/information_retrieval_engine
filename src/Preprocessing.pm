use strict;
use warnings;

sub filterOutNonWordCharactersFromText(){
	my $text = $_[0];
	
	#filtered out special chars and numeric values
	$text =~ s/[<>%~\$!=?#*"',&{}\(\)\[\]]|\b\d+\b//g;
	
	#filtered numeric value from AM/PM e.g 20PM or 10AM
	$text =~ s/\d+(am|pm)/$1/gi;
	
	#replace [-.:\/\|] characters with a white space
	$text =~ s/[-.:;@\\\/\|]/ /g;

	#squeeze white space characters to space character
	$text =~ s/\s+/ /g;
	
	return $text;
}

sub removeUrl(){
	my $text = $_[0];
	my $urlPattern = qw(http://(?:www)?(?:[.]\w+)+(?:(?:[/]\w+)+[.]\w+|[/]?));
	$text =~ s/$urlPattern//gi;
	return $text;
}

sub removeHtmlTag(){
	my $text = $_[0];
	my $htmlPattern = qw((?:<\w+.*?>.*?</\w+.*?>));
	$text =~ s/$htmlPattern//sgi;
	return $text;
}

sub removeScriptAndStyleContents(){
	my $text = $_[0];
	my $scriptStylePattern = qw((?:<(script|style).*?>.*?</\1.*?>));
	$text =~ s/$scriptStylePattern//sgi;
	return $text;
}

sub convertToLowerCase(){
	my $text = $_[0];
	#convert all word to small case
	$text =~ tr/[A-Z]/[a-z]/;
	return $text;
}

sub removeEmptyElementFromList(){
	my @words = grep $_ ne "",@_;
	return @words;
}

sub removeStopWordsFromText(){

	my $text = $_[0];
	my $input_stop_word_list = $_[1];
	open INPUTFILE,"<$input_stop_word_list" or die "cannot open $input_stop_word_list.\n";
	my @stopWordList = <INPUTFILE>;
	close INPUTFILE;
	
	#remove newline character
	foreach my $word (@stopWordList){
	chomp($word);
	}

	my $stopWordListString = join "|", @stopWordList;
	
	#print $stopWordListString."\n";
	#print $text."\n";
	
	$text =~ s/\b(?:$stopWordListString)\b//gi;
	
	
	return $text;
}

1;