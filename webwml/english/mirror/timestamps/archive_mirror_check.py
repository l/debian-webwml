#!/usr/bin/python
import sys, urllib, htmllib, httplib, formatter, urlparse, re
import string, time, socket, signal

# Checks mirror sites to see if they are up to date
# Usage: archive_mirror_check.py mirrorlist
# with no hosts listed, check every site in the mirrorlist file
# Usage: archive_mirror_check.py mirrorlist host1 host2...
# if hosts are listed, only they are checked

# Could easily be modified to check non-http access methods to see if
# they work.

# Any site more STALE_AGE days old is listed as being out of date
STALE_AGE = 7
# oodtime is current time - STALE_AGE (in seconds)
oodtime = time.time() - STALE_AGE * 24 * 60 * 60

months = {'Jan':1, 'Feb':2, 'Mar':3, 'Apr':4, 'May':5, 'Jun':6, 'Jul':7, 'Aug':8, 'Sep':9, 'Oct':10, 'Nov':11, 'Dec':12}
daysofweek = {'Mon':0, 'Tue':1, 'Wed':2, 'Thu':3, 'Fri':4, 'Sat':5, 'Sun':6}

mailto = re.compile('mailto')
cont_line = re.compile('\s')

# length of time to wait for a site to respond
TIMEOUT = 25
def handler(signum, frame):
	# print 'Signal handler called with signal', signum
	raise IOError, "gave up on site (" + repr(TIMEOUT) + " second limit)"

itemre = re.compile(r'(.*?): (.*)\n')
def process_line(line, site):
	if line == '':
		return
	res = itemre.match(line)
	if not res:
		print "  bad line found: " + line[:-1]
	else:
		site[string.lower(res.group(1))] = res.group(2)
	line = ''

goodlink = re.compile(r'(^\w[\w.-]+$|^.+/trace/[\w-]+[^/])');
def check_site(hostname, loc):
	mirror = 'http://' + hostname + loc + 'project/trace/'
	try:
		hostaddress = socket.gethostbyname(hostname)
	except socket.error:
		'Could not resolve host ', hostname
		return
	print mirror + ' (' + hostaddress + ')'
	sys.stdout.flush()
	try:
		signal.signal(signal.SIGALRM, handler)
		signal.alarm(TIMEOUT)
		parts = urlparse.urlparse(mirror)
		h = httplib.HTTP(parts[1])
		h.putrequest('HEAD', parts[2])
		h.putheader('Host', parts[1])
		h.endheaders()
		errcode, errmsg, headers = h.getreply()
		signal.alarm(0)
	except (IOError, socket.error), arg:
		print '  Error accessing site:', arg.args[0]
		return
	if errcode != 200:
		print '  Error: site returned Error Code ' + str(errcode)
		return
	# site must be good so actually download it
	current = urllib.urlopen(mirror)
	parse = htmllib.HTMLParser(formatter.NullFormatter())
	parse.feed(current.read())
	parse.close()
	alllinks = parse.anchorlist
	links = [];
	for tmp in alllinks:
		if goodlink.search(tmp) and not links.count(tmp):
			urlparts = string.split(tmp, '/')
			links.append(urlparts[-1])
	if not links:
		print '  Error with page: no useful links'
		return
	urls = {}
	for url in links:
		fullurl = urlparse.urljoin(mirror, url)
		try:
			current = urllib.urlopen(fullurl)
		except IOError, args:
			print "  Error: ", args
			return
		# Fri Apr 20 17:43:33 UTC 2001
		# %a  %b  %d %X       %Z  %Y
		data = current.readline()[:-1]
		try:
			upmirroradd = socket.gethostbyname(url)
		except socket.error:
			out = '  ' + string.ljust(url+' (does not resolve)', 50) + data
		else:
			out = '  ' + string.ljust(url+' ('+upmirroradd + ')', 50) + data
		# Not be 100% correct, but should work. doc says mktime uses
		# localtime, but times are in UTC. Since all times may be off by the
		# same amount, it shouldn't matter.
		try:
			(dow, mon, dom, tim, zone, year) = string.split(data)
			(hr, min, sec) = string.split(tim, ':')
			epochtime = time.mktime((int(year), months[mon], int(dom), int(hr), int(min), int(sec), daysofweek[dow], 0, 0))
		except:
			print "  Error with file " + url
			print "  Data = " + data
			return
		if (epochtime - oodtime) < 0:
			urls[epochtime] = out + ' (OUT OF DATE)'
		else:
			urls[epochtime] = out
	tmp = urls.keys()
	tmp.sort()
	for times in tmp:
		print urls[times]
	sys.stdout.flush()

ignored = re.compile('(http.us.debian.org|mirror.aarnet.edu.au|ibiblio.org|llug.sep.bnl.gov|ftp.wa.au.debian.org)')
def ignored_site(site, currentsite):
	if ignored.match(site) and not currentsite:
		print "Ignoring site " + site
		return 1
	return 0


def check(currentsite = ''):
	site = {}
	sitenotempty = 0
	line = ''
	mirrorlistfd = open(mirrorlist, 'r')
	newline = mirrorlistfd.readline()
	while 1:
		if (newline == '\n' or newline == '') and sitenotempty:
			process_line(line, site)
			if not ignored_site(site['site'], currentsite):
				if (site.has_key('site') and site.has_key('archive-http')) and (not currentsite or site['site'] == currentsite):
					check_site(site['site'], site['archive-http'])
					if site.has_key('maintainer'):
						print "  Maintainer: " + site['maintainer']
				if site.has_key('site') and site.has_key('nonus-http') and (not currentsite or site['site'] == currentsite):
					check_site(site['site'], site['nonus-http'])
					if site.has_key('maintainer'):
						print "  Maintainer: " + site['maintainer']
			if site['site'] == currentsite:
				return
			site = {}
			sitenotempty = 0
		elif cont_line.match(newline):
			# previous line is continued so append it
			line = line + newline[1:]
		else:
			process_line(line, site)
			line = newline
			sitenotempty = 1
		if newline == '':
			break
		newline = mirrorlistfd.readline()
	mirrorlistfd.close()

mirrorlist = sys.argv.pop(1)
if len(sys.argv) > 1:
	while sys.argv:
		check(sys.argv.pop())
	sys.exit(1)
else:
	check()
