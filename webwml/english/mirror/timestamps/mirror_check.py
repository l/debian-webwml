#!/usr/bin/python
import sys, urllib, htmllib, httplib, formatter, urlparse, re

# given a list of addresses, e.g. 'www.debian.org, www.uk.debian.org',
# the timestamp files are retrieved and printed out.

sites = sys.argv
sites.pop(0)
mailto = re.compile('mailto')
for site in sites:
	mirror = 'http://' + site + '/mirror/timestamps/'
	print mirror
	try:
		parts = urlparse.urlparse(mirror)
		h = httplib.HTTP(parts[1])
		h.putrequest('HEAD', parts[2])
		h.putheader('Host', parts[1])
		h.endheaders()
		errcode, errmsg, headers = h.getreply()
	except IOError:
		print '  site does not have a timestamp dir'
		continue
	if errcode != 200:
		print '  Site returned Error Code ' + str(errcode)
		continue
	# site must be good so actually download it
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
