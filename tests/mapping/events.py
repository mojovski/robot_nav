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

def getCurrentUptime():
	cmd_uptime="docker exec -it ros_core rostopic echo /hardware_status -n 1 | grep uptime"
	out=callCmd(cmd_uptime)
	uptime=float(re.findall(r': (.+)\r',out)[0])
	print("Uptime: "+str(uptime))
	return uptime

def getCurrentRobotPosition():
	#todo
	cmd="docker exec -it xxx ./src/xxx/scripts/cmd_get_robot_pose.py map base_link"
	json_str=callCmd(cmd)
	pose=json.loads(json_str)
	return np.array(pose['t'])


def onBeforeStart(**kwargs):
	return

def onRun(container):

	print("Started "+str(__file__)+".onRun")
	print("Container: "+str(container))

	if container==None:
		raise Exception("The mapping.onRun requires an instance of a container as parameter. Please recheck!")


	#todo check and compare the robot pose
	uptime=0.0

	#remeber the first landmark
	#print("Waiting to check some stuff at time 221")
	#while uptime<221:
	#	time.sleep(1)
	#	uptime=getCurrentUptime()
	
	#todo: check now at time 221

	#print("Exiting onRun")
	return


def onBeforeExit(**kwargs):
	return 




