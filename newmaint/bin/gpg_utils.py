# Utility functions for the GPG Signing Coordination page
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


def print_places(begin, finish, city, country):
    if city:
        out = "%s, %s: " % (city, country)
    else:
        out = "%s: " % (country)

    if (not begin and not finish):
        out += "always";
    elif (begin and not finish):
        out += "starting on %s" % begin
    elif (not begin and finish):
        out += "until %s" % finish
    else:
        out += "%s to %s" % (begin, finish)

    return out


# vim:set ts=4:
# vim:set expandtab:
# vim:set shiftwidth=4:
