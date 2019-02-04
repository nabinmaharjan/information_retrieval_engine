 1. The program uses CAM::PDF module to convert pdf to text file. Assuming strawberry perl is installed in windows, install following from command line. 
	a. Install cpanm module if it's not installed already
		- cpan App::cpanminus
	b. Install CAM::PDF module
		- cpanm CAM::PDF
2. Run the perl script from command line as:
	- perl src/RunCrawler.pl
	- Configure a list of seed urls for crawling in RunCrawler.pl
	- configure delay time between each crawling and maximum number of documents to crawl in Crawler.pm module
3. The crawled files will be generated inside src/processed folder in a clean pre-processed format. Also, some list files are generated that records some relevant information about the crawling process.