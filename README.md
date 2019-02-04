# Information Retrieval Engine (PERL)
This is a simple web information retrieval engine developed using perl script.  The program takes a set of keyword searches as an input and forms a query vector by computing tf-idf weights for each search term. The program then, retrieves list of documents containing at least one of the query keywords and constructs the document vectors. Finally, the cosine similarity of a document vector and the query vector is calculated for each of the retrieved documents. The retrieved documents are ranked by their cosine similarity values in a descending order. These ranked documents are then formatted to json output such that  each document is represented by document title and its original web link.


