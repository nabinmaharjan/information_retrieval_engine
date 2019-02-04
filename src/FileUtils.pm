use strict;
use warnings;
use JSON::XS qw(encode_json decode_json);

sub getContentAsListOfLinesFromFile(){
	my $file = $_[0];
	open INPUTFILE,"<$file" or die "cannot open $file.\n";
	my @data = <INPUTFILE>;
	close INPUTFILE;
	return @data;
}

sub saveInvertedIndexFile(){
	&saveHashToFile($_[0],$_[1]);
}

sub saveHashToFile(){

my %invertedIndex = %{$_[0]};
my $outfile = $_[1];
my $json = encode_json \%invertedIndex;
open OUTPUTFILE, ">$outfile" or die "cannot open $outfile for writing.\n";
print OUTPUTFILE $json;
close OUTPUTFILE;

}
sub readInvertedIndexFile(){
	return &readHashFromFile($_[0]);
}

sub readHashFromFile(){
	my $file = $_[0];
	open INPUTFILE,"<$file" or die "cannot open $file.\n";
	my $json = <INPUTFILE>;
	close INPUTFILE;
	my %indexFile = %{ decode_json $json };
	return %indexFile;
}

sub saveContentsToFile(){
    my @headerList = @{$_[0]};
	my @contentList = @{$_[1]};
	my $outfile = $_[2];
	open OUTPUTFILE, ">$outfile" or die "cannot open $outfile for writing.\n";
	
	foreach my $headLine(@headerList){
		print OUTPUTFILE $headLine."\n";
	}
	
	foreach my $contentLine(@contentList){
		print OUTPUTFILE $contentLine."\n";
	}
	close OUTPUTFILE;
}
sub getListOfFilesFromDirectory(){
	my $dir = $_[0];
	my @filePathList;
	opendir(DIR, $dir) or die "cannot access directory $dir.\n";

    while (my $file = readdir(DIR)) {

	# Use -d to test for a directory
	next unless (-f "$dir/$file");

	#print "$dir/$file\n";
	push @filePathList,$file;
    }

    closedir(DIR);
	return @filePathList;
}

sub extractSummaryText(){
  my $document = $_[0];
  my @lines = split /\n/, $document;
  #chomp(@lines);
  my $returnLine = "";
  foreach my $line(@lines){
	$line =~ s/(^\s+|\s+$)//g;
	if($line ne "")
	{
		$returnLine = $line;
		last;
	}
  }
  return $returnLine;
}
sub getContentAsStringFromFile(){
	my $file = $_[0];
	open INPUTFILE,"<$file" or die "cannot open $file.\n";
	my $text="";
	#read line by line from input file and write to output file
	while(<INPUTFILE>)
	{	
		$text = $text.$_;
	}

	#print $text;
	close INPUTFILE;
	return $text;
}

sub getListOfLinesFromFileAfterSkipping(){
	my $file = $_[0];
	my $skipLines = $_[1];
	my @lines = ();
	open INPUTFILE,"<$file" or die "cannot open $file.\n";
	$. = 0;
	while(<INPUTFILE>){
		next if $. <= $skipLines;
		$_ =~ s/(^\s+|\s+$)//g;
		if($_ ne "")
		{
			push @lines,$_;
		}
	}
	return @lines;
}

sub getSummaryInfoForRetrievedDocument(){
	my $file = $_[0];
	my @lines = ();
	open INPUTFILE,"<$file" or die "cannot open $file.\n";
	$. = 0;
	while(<INPUTFILE>){
		if ($. == 2 || $. == 3)
		{
			push @lines,$_;
		}
		if( $. > 2)
		{
			last;
		}
	}
	return @lines;
}

1;