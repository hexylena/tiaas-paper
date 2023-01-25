#!/usr/bin/env python
import iso3166
import sys

data = open(sys.argv[1], 'r').readlines()
data = [x.strip() for x in data]

for row in data:
    try:
        print(','.join((row, iso3166.countries[row].alpha2)))
    except:
        print(','.join((row, '')))
