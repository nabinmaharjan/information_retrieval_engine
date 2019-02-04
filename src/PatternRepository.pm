use strict;
use warnings;

sub getHashLinkPattern(){
	return "(?:#[^/]*)\$";
}

sub getTextLinkPattern(){
	return "/(?:[^/]+[.]txt)(\$|[?])";
}

sub getpdfLinkPattern(){
	return "/(?:[^/]+[.]pdf)(\$|[?])";
}

sub getHtmlLinkPattern(){
	return "/(?:[^/]+[.](?:htm|html|asp|aspx|jsp|php))(\$|[?])";
}

sub getIgnoredFilePattern(){
	return "/(?:[^/]+[.](?:ppt|pptx|doc|docx|img|png|jpg|jpeg|gif|xls|xlsx|css|js|ico|swf))(\$|[?])";
}

sub getMemphisDomainPattern(){
	return "(?:http|https)://(?:[^/]+(?:memphis.edu)(?:[^/]+)?)(?:.*)";
}
1;