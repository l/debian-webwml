#!/usr/bin/python
import sys, urllib, htmllib, httplib, formatter, urlparse, re
import string, time, socket

# Reads deb files from a file and checks the timestamps.
# Not quite. It currently looks for '^Site: .*debian.org$'
# from stdin (format of mirrorlist file) and checks those that have
# an Archive-http: line.
# Could easily be modified to check non-http access methods to see if
# they work.

months = {'Jan':1, 'Feb':2, 'Mar':3, 'Apr':4, 'May':5, 'Jun':6, 'Jul':7, 'Aug':8, 'Sep':9, 'Oct':10, 'Nov':11, 'Dec':12}
daysofweek = {'Mon':0, 'Tue':1, 'Wed':2, 'Thu':3, 'Fri':4, 'Sat':5, 'Sun':6}

mailto = re.compile('mailto')
cont_line = re.compile('\s')

itemre = re.compile(r'(.*?): (.*)\n')
def process_line(line):
	if line == '':
		return
	res = itemre.match(line)
	if not res:
		print "  bad line found: " + line[:-1]
	else:
		site[string.lower(res.group(1))] = res.group(2)
	line = ''

def check_site(url, uplink):
	#mirror = 'http://' + site + '/mirror/timestamps/'
	print mirror
	sys.stdout.flush()
	try:
		parts = urlparse.urlparse(mirror)
		h = httplib.HTTP(parts[1])
		h.putrequest('HEAD', parts[2])
		h.putheader('Host', parts[1])
		h.endheaders()
		errcode, errmsg, headers = h.getreply()
	except (IOError, socket.error):
		print '  Problem accessing site'
		#continue
		return
	if errcode != 200:
		print '  Site returned Error Code ' + str(errcode)
		#continue
		return
	# site must be good so actually download it
	current = urllib.urlopen(mirror)
	parse = htmllib.HTMLParser(formatter.NullFormatter())
	parse.feed(current.read())
	parse.close()
	links = parse.anchorlist
	# typical list is
	# ['?N=D', '?M=A', '?S=A', '?D=A', '/mirror/', 'klecker.debian.org']
	while links and links[0] != uplink:
		links.pop(0)
	if not links:
		print '  Problem with page'
		return
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
		# Not be 100% correct, but should work. doc says mktime uses
		# localtime, but times are in UTC. Since all times may be off by the
		# same amount, it shouldn't matter.
		try:
			(dow, mon, dom, tim, zone, year) = string.split(data)
			(hr, min, sec) = string.split(tim, ':')
			epochtime = time.mktime((int(year), months[mon], int(dom), int(hr), int(min), int(sec), daysofweek[dow], 0, 0))
		except:
			print "  Problem with file " + url
			print "  Data = " + data
			return
		urls[epochtime] = out
	tmp = urls.keys()
	tmp.sort()
	for times in tmp:
		print urls[times]
	sys.stdout.flush()

site = {}
sitenotempty = 0
line = ''
official = re.compile('debian.org')
newline = sys.stdin.readline()
while 1:
	if (newline == '\n' or newline == '') and sitenotempty:
		process_line(line)
		# print " site = " + site + " and archhttp = " + archhttp
		if site.has_key('site') and site.has_key('archive-http'):
			# and official.search(site['site']):
			mirror = 'http://' + site['site'] + site['archive-http'] + 'project/trace/'
			check_site(mirror, site['archive-http'] + 'project/')
			if site.has_key('maintainer'):
				print "  Maintainer: " + site['maintainer']
		if site.has_key('site') and site.has_key('nonus-http') and official.search(site['site']):
			mirror = 'http://' + site['site'] + site['nonus-http'] + 'project/trace/'
			check_site(mirror, site['nonus-http'] + 'project/')
			if site.has_key('maintainer'):
				print "  Maintainer: " + site['maintainer']
		site = {}
		sitenotempty = 0
	elif cont_line.match(newline):
		# previous line is continued
		line = line + newline[1:]
	else:
		process_line(line)
		line = newline
		sitenotempty = 1
	if newline == '':
		break
	newline = sys.stdin.readline()
