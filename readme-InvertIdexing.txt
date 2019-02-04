1. The program uses JSON::XS module to save or read inverted index file. 
	a. Install cpanm module if it's not installed already
		- cpan App::cpanminus
	b. Install JSON::XS module
		- cpanm JSON::XS
2. Run the perl script from command line
	- perl src/InvertIndexing.pl
5. The program will generate Indexing.dat and documentLength.dat files inside  src/output folder. Copy these files to data folder before running the next step, i.e., information retrieval step.