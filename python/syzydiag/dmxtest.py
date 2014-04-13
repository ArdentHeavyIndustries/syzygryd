#!/usr/bin/env python
"""
    Syzygryd Diagnostic Tool

    I was tired of dealing with Processing to test Syzygryd cubes. So I made a
    command-line Python script. Bon appetit. For your eyes!

    It uses a hacked together version of PySimpleDMX:
    https://github.com/c0z3n/pySimpleDMX

    Author:     Mike Juarez
    Date:       April 12, 2014
    Contact:    http://github.com/mjuarez

"""

import pysimpledmx
import argparse
from time import sleep
from random import randrange
import struct

parser = argparse.ArgumentParser(
	description="Program to test Syzygryd cubes.")
parser.add_argument('--cube', help="Cube number")
parser.add_argument('--color', help="Color in HEX format (aabbcc)")
parser.add_argument('--entec', help="full path of enttec device")
parser.add_argument('--cycle', help="Cycle through the arm")
args = parser.parse_args()

mydmx = pysimpledmx.DMXConnection(args.entec)

color = args.color

def changeCube(cube, color):
	tup = struct.unpack('BBB',color.decode('hex'))
	r = (cube*3)-2
	g = (cube*3)-1
	b = cube*3
	mydmx.setChannel(r,tup[0])
	mydmx.setChannel(g,tup[1])
	mydmx.setChannel(b,tup[2])
	mydmx.render()

if args.cube is not None:
	cube = int(args.cube)
	changeCube(cube, color)
	exit()

if args.cycle is not None:
	if args.cycle == "pulsate":
		up=True
		while True:
			for i in range(0,255):
				for c in range(1,510):
					mydmx.setChannel(c,i)
				mydmx.render()
				sleep(0.01)
			for i in reversed(range(0,255)):
				for c in range(1,510):
					mydmx.setChannel(c,i)
				mydmx.render()
				sleep(0.01)
	elif args.cycle == "random":
		while True:
			cube = randrange(1,36)
			r = (cube*3)-2
			g = (cube*3)-1
			b = cube*3
			mydmx.setChannel(r,randrange(0,255))
			mydmx.setChannel(g,randrange(0,255))
			mydmx.setChannel(b,randrange(0,255))
			mydmx.render()
			sleep(0.1)
	elif args.cycle == "seizure":
		while True:
			for i in range(1,510):
				mydmx.setChannel(i,randrange(0,255))
			mydmx.render()
	else:
		cubes = range(1, 36)
		for i in cubes:
			print "Cube %s" % str(i)
			changeCube(i,color)
			sleep(0.1)