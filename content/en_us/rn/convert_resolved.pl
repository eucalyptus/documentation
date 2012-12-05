#!/usr/bin/perl

open(IN_FILE, "<$ARGV[0]");
while(<IN_FILE>) {
	if($_=~ '.*\<key id=.*\>(.*)\<\/key\>.*\n') {
	       print "\<row\>\<entry\>\<xref format=\"html\" href=\"https://eucalyptus.atlassian.net/browse/$1\"\>$1\<\/xref\>\<\/entry\>", "\n";
	}
	if($_=~ '.*\<summary\>\n*(.*)\<\/summary\>.*\n') {
	       print "\<entry\>$1\<\/entry\>\<\/row\>", "\n"; 
	}

}

close(IN_FILE);
