#!/usr/bin/python
import sys, urllib, htmllib, httplib, formatter, urlparse, re, string, time

# given a list of addresses, e.g. 'www.debian.org, www.uk.debian.org',
# the timestamp files are retrieved and printed out.

months = {'Jan':1, 'Feb':2, 'Mar':3, 'Apr':4, 'May':5, 'Jun':6, 'Jul':7, 'Aug':8, 'Sep':9, 'Oct':10, 'Nov':11, 'Dec':12}
daysofweek = {'Mon':0, 'Tue':1, 'Wed':2, 'Thu':3, 'Fri':4, 'Sat':5, 'Sun':6}
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
		print '  Problem accessing site'
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
	urls = {}
	for url in parse.anchorlist:
		# urls.append(url)
		if mailto.match(url):
			continue
		fullurl = urlparse.urljoin(mirror, url)
		current = urllib.urlopen(fullurl)
		# Fri Apr 20 17:43:33 UTC 2001
		# %a  %b  %d %X       %Z  %Y
		data = current.readline()[:-1]
		out = '  ' + string.ljust(url, 25) + ' ' + data
		(dow, mon, dom, tim, zone, year) = string.split(data)
		(hr, min, sec) = string.split(tim, ':')
		# Not be 100% correct, but should work. doc says mktime uses
		# localtime, but times are in UTC. Since all times may be off by the
		# same amount, it shouldn't matter.
		epochtime = time.mktime((int(year), months[mon], int(dom), int(hr), int(min), int(sec), daysofweek[dow], 0, 0))
		urls[epochtime] = out
	tmp = urls.keys()
	tmp.sort()
	for times in tmp:
		print urls[times]
