#!/usr/bin/python
import sys, urllib, htmllib, formatter, urlparse, re

# given a list of addresses, e.g. 'www.debian.org, www.uk.debian.org',
# the timestamp files are retrieved and printed out.

sites = sys.argv
sites.pop(0)
mailto = re.compile('mailto')
for site in sites:
	mirror = 'http://' + site + '/mirror/timestamps/'
	print mirror
	current = urllib.urlopen(mirror)
	parse = htmllib.HTMLParser(formatter.NullFormatter())
	parse.feed(current.read())
	parse.close()
	links = parse.anchorlist
	# typical list is
	# ['?N=D', '?M=A', '?S=A', '?D=A', '/mirror/', 'klecker.debian.org']
	while links[0] != '/mirror/':
		links.pop(0)
	links.pop(0)
	for url in parse.anchorlist:
		if mailto.match(url):
			continue
		fullurl = urlparse.urljoin(mirror, url)
		current = urllib.urlopen(fullurl)
		print '  ' + url + '  ' + current.readline()[:-1]
