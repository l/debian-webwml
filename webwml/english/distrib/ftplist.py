#!/usr/bin/python
import sys, urllib, htmllib, httplib, ftplib, formatter, urlparse, socket, string;
import re, signal
from sgmllib import SGMLParser

# check_http and check_ftp are subroutines that can be used to check whether
# a url is valid. They are not currently being used.

# The file resulting from running this program, ftplist.data, is not sorted
# so the countries come out in random order. Ideally, template/debian/countries.wml
# will be modified appropriately and a sorting function written so that the
# list is sorted according to rules for each language.

# Until fixed, ftplist.data should be sorted alphabetically by hand before
# being committed.

# Running
# no arguments are needed. It uses the file ../mirror/Mirrors.masterlist as
# input and the output is written to ftplist.data 

TIMEOUT = 15
mirror_file = '../mirror/Mirrors.masterlist'
ftplist_file = 'ftplist.data'

def check_http(url, parts):
	# must do http connection using httplib so can parse the return codes
	# only if the url is good should it be added to httplist
	# print "entering check_http with url =", url
	try:
		# print "host =", parts[1]
		# print "file =", parts[2]
		signal.signal(signal.SIGALRM, handler)
		signal.alarm(TIMEOUT)
		h = httplib.HTTP(parts[1])
		h.putrequest('HEAD', url)
		h.putheader('Accept', '*/*')
		h.endheaders()
		errcode, errmsg, headers = h.getreply()
		signal.alarm(0)
		# print "    errcode =",errcode
		# print "    errmsg  =",errmsg
		# print "    headers =",headers
		if errcode == 200 or errcode == 302:
			msg = " : (" + str(errcode) + ") " + errmsg 
			add_url(url)
		elif errcode == 301:
			headers = str(headers)
			#print "    headers =", headers
			result = re.findall("Location:\s*(.*)\n", headers)
			if result[0]:
				msg = " : Error = (" + str(errcode) + ") " + errmsg + ". New URL: " + result[0]
			else:
				msg = " : Error = (" + str(errcode) + ") " + errmsg
		elif errcode == 400 or errcode == 403 or errcode == 404:
			signal.signal(signal.SIGALRM, handler)
			signal.alarm(TIMEOUT)
			h = httplib.HTTP(parts[1])
			h.putrequest('HEAD', parts[2])
			h.endheaders()
			errcode, errmsg, headers = h.getreply()
			signal.alarm(0)
			# print "    headers =", headers
			if errcode == 200 or errcode == 302:
				add_url(url)
				msg = " : (" + str(errcode) + ") " + errmsg 
			else:
				msg = " : Error = (" + str(errcode) + ") " + errmsg 
		else:
			msg = " : Error = (" + str(errcode) + ") " + errmsg 
	except IOError, arg:
		msg = " : IOError: " + arg.args[0]
	except socket.error, arg:
		msg = " : Error: " + str(arg.args)
	return msg

def ftp_file_exists(string):
	kluge[0] = 1

def check_ftp(url, parts):
	try:
		signal.signal(signal.SIGALRM, handler)
		signal.alarm(TIMEOUT)
		ftp = ftplib.FTP(parts[1])
		ftp.login()
		# listcmd = "LIST " + parts[2]
		# print "    listcmd =", listcmd
		#ftp.retrlines(listcmd)
		kluge[0] = 0
		ftp.dir(parts[2], ftp_file_exists)
		if kluge[0]:
			msg = " : is ok"
		else:
			msg = " : Error: file doesn't exist"
		ftp.quit()
		signal.alarm(0)
	except socket.error, arg:
		msg = " : Error: " + str(arg.args)
	except (IOError, ftplib.error_perm, ftplib.error_temp, EOFError), arg:
		msg = " : Error: " + str(arg)
	#retrlines (command[, callback])
	#dir (argument[, ...])
	#cwd (pathname)
	return msg

# BEGIN MAIN PROGRAM

debug=0

httplist = []
ftplist = []

f = open(mirror_file, 'r')
g = open(ftplist_file, 'w')
g.write('#use wml::debian::countries\n<define-tag ftpmirrors>\n<UL>\n')
lines = f.readlines()
sitep = ''
http = ''
ftp = ''
site = '';
for line in lines:
	sitep = re.findall('^Site: ftp\.(..)\.debian.org', line)
	httpl = re.findall('^Archive-http: (.*)$', line)
	ftpl = re.findall('^Archive-ftp: (.*)$', line)
	new = re.findall('^$', line)
	if sitep:
		[site] = sitep
		sitep = ''
	elif httpl and site:
		[http] = httpl
		# httplist.append('http://' + site + http)
		httpl = ''
	elif ftpl and site:
		[ftp] = ftpl
		# ftplist.append('ftp://' + site + ftp)
		ftpl = ''
	elif new:
		if http:
			str = 'http://ftp.' + site + '.debian.org' + http
			g.write('<LI><a href="' + str + '"><' + string.upper(site) + 'c></a>\n')
		if ftp and http:
			str = 'ftp://ftp.' + site + '.debian.org' + ftp
			g.write(' (<a href="' + str + '">ftp</a>)\n')
		elif ftp:
			str = 'ftp://ftp.' + site + '.debian.org' + ftp
			g.write('<LI><a href="' + str + '"><' + string.upper(site) + 'c></a>\n')
	 	http = ''
		ftp = ''
		site = ''
		new = ''
g.write('</UL>\n</define-tag>\n')
f.close()
g.close()

print "Program Finished Normally"
