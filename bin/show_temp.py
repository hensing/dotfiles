#! /usr/bin/env python
# -*- coding: utf-8 -*-
"""
show_temp.py, by S.Porz 24.02.2012

Shows series of temperature values for different hosts, taken from a csv file.

Parameters
----------
hostcostrain : string
	Temperature is only plotted for hostnames containing this substring.
	Defaults to '' (any host).
Settings that can be changed within script:
	The path to the csv-file, that will be copied to script location via scp.
	The delimiter of the csv-file.
	The timezone to plot data with.

Returns
-------
out : Pylab window.
	Shows the temperature series of the chosen hosts.
"""

import os
import csv
import sys
import pylab
import numpy
from matplotlib import dates
import datetime

# settings
user = 'hensing'
host = 'localhost'
path = '/home/hensing'
logfile = 'temperatures.log'
csvdelimiter = ' '
logpath = user + '@' + host + ':' + path + '/' + logfile


# timezone gmt
class GMT1(datetime.tzinfo):
	"""GMT1(datetime.tzinfo)

		A class that can be used as tz (timezone information). Realises GMT +1.
	"""
	def utcoffset(self, dt):
		return datetime.timedelta(hours=1) + self.dst(dt)
	def dst(self, dt):
		# DST starts last Sunday in March
		# ends last Sunday in October
		d = datetime.datetime(dt.year, 4, 1)
		dston = d - datetime.timedelta(days=d.weekday() + 1)
		d = datetime.datetime(dt.year, 11, 1)
		dstoff = d - datetime.timedelta(days=d.weekday() + 1)

		if dston <=  dt.replace(tzinfo=None) < dstoff:
			return datetime.timedelta(hours=1)
		else:
			return datetime.timedelta(0)
	def tzname(self,dt):
		return "GMT +1"

tz = GMT1()

# fetch logfile
#os.spawnvp(os.P_WAIT, 'scp', ['scp', logpath, '.'])

if len(sys.argv) > 1:
	constraint = sys.argv[1]
else:
	constraint = ''

csv_reader = csv.reader(open(logfile, 'r'), delimiter=csvdelimiter)
hosts = {}
for row in csv_reader:
	hostname = row[1]
	if constraint in hostname:
		if hostname in hosts:
			hosts[hostname].append((row[0],row[2]))
		else:
			hosts[hostname] = [(row[0],row[2])]

fig = pylab.figure()
ax = fig.add_subplot(111)
hostnames = hosts.keys()
hostnames.sort()
for hostname in hostnames:
	seriesvec = numpy.array(hosts[hostname], dtype='float').transpose()
	seriesvec[0] = numpy.array(dates.epoch2num(seriesvec[0]))
	ax.plot(seriesvec[0], seriesvec[1], label=hostname)

ax.legend(loc="lower left")
ax.xaxis_date(tz=tz)
fig.autofmt_xdate()
pylab.show()
