# Utility functions
# Copyright (C) 2000, 2001, 2002  James Troup <james@nocrew.org>
# Copyright (C) 2002  Martin Michlmayr <tbm@cyrius.com>
# $Id$

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

import os

Error = 'Message Error';

def send_mail(message):
    sendmail = os.popen("/usr/sbin/sendmail -t", "w")
    sendmail.write(message)
    if sendmail.close():
         raise Error, "Sendmail gave a non-zero return code";


################################################################################

# The following is taken from katie

################################################################################

cant_open_exc = "Can't read file.";

def open_file(filename, mode='r'):
    try:
        f = open(filename, mode);
    except IOError:
        raise cant_open_exc, filename
    return f

# Perform a substition of template
def TemplateSubst(map, filename):
    file = open_file(filename);
    template = file.read();
    for x in map.keys():
        template = template.replace(x,map[x]);
    file.close();
    return template;

