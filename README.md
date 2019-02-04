# Information Retrieval Engine (PERL)
This is a simple web information retrieval engine developed using perl script.  The program takes a set of keyword searches as an input and forms a query vector by computing tf-idf weights for each search term. The program then, retrieves list of documents containing at least one of the query keywords and constructs the document vectors. Finally, the cosine similarity of a document vector and the query vector is calculated for each of the retrieved documents. The retrieved documents are ranked by their cosine similarity values in a descending order. These ranked documents are then formatted to json output such that  each document is represented by document title and its original web link.

The program consists of three steps.
1. Run **RunCrawler.pl** to crawl the documents from the web. See **readme-RunCrawler.txt** for configuring settings.
2. Run **InvertIndexing.pl** to generate inverted index file. See **readme-InvertIdexing.txt** for configuring settings.
3. Finally, run **RetrieveRankedDocument.pl** to fetch a ranked list of documents that match a given list of keyword searches. The RetrieveRankedDocument.pl can be configured as a **perl-cgi script** to mediate between perl information retrieval backend engine and web UI for user keyword searches and associated results.
 
The keyword searches are set by assigning **$query** variable with a list of keywords separated by space, e.g.,"information retrieval".
