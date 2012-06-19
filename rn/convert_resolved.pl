#!/usr/bin/perl

open(IN_FILE, "<$ARGV[0]");
while(<IN_FILE>) {
	if($_=~ '.*\<a href=(.*)\<\/a\>\] -\s*([a-zA-Z].*)\n') {
	       print "\<row\>\<entry\>\<xref href=$1\<\/xref\>\<\/entry\>\<entry\>$2\<\/entry\>\<\/row\>", "\n";
	}
}

close(IN_FILE);
