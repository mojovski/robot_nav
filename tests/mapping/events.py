#!/usr/bin/env python

from __future__ import print_function
import os, sys
import yaml
import argparse
import subprocess 
import inspect
import collections
import time
import docker
from shutil import copyfile
import os
import re 
import redis
import numpy as np
import json

def callCmd(cmd):
	p = subprocess.Popen([cmd], stderr=subprocess.PIPE, shell=True, stdout = subprocess.PIPE)
	p.wait()
	out=p.stdout.read()
	return out


def getCurrentRobotPosition():
	#todo
	return np.array([0,0,0])


def onBeforeStart(**kwargs):
	return

def onRun(container):

	print("Started "+str(__file__)+".onRun")
	print("Container: "+str(container))

	if container==None:
		raise Exception("The mapping.onRun requires an instance of a container as parameter. Please recheck!")

	return


def onBeforeExit(**kwargs):
	return 




