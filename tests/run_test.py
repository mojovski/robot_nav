#!/usr/bin/env python


"""
this file starts many docker compose files, which are defines in a directory
passed as argument.
The directory (e.g. test_name) should contain:
docker-compose-files.yml
eval.py

The yml file contains a list of all docker-compose files to be loaded. 
See the files inside finepos as a reference example
"""

from __future__ import print_function
import os, sys
import yaml
import argparse
import subprocess 
import inspect
import collections
import time
import docker
from multiprocessing import Process

def load_env(filename):
	"""
	parses a simple
	key=val
	file and returns is as a dict
	"""
	env_dict = {}
	with open(filename) as myfile:
		for line in myfile:
			if line.strip()=='':
				continue
			name, var = line.partition("=")[::2]
			env_dict[name.strip()] = var.strip()
	return env_dict


def call_docker_compose(env_file, context_dir, files_dir, files):
	"""
	starts a command like docker-compose -f file_i 
	and returns the pid of the process to kill later
	"""
	env_dict=load_env(env_file)
	print("env_dict: "+str(env_dict))
	# #debug, print all input
	# frame = inspect.currentframe()
	# args, _, _, values = inspect.getargvalues(frame)
	# print 'function name "%s"' % inspect.getframeinfo(frame)[2]
	# for i in args:
	# 	print "    %s = %s" % (i, values[i])

	#construct the command
	cmd="docker-compose "
	for fi in files:
		cmd+="-f "+files_dir+"/"+fi+" "
	cmd += "up"

	print("cmd: "+str(cmd))
	p = subprocess.Popen(cmd, shell=True, env=env_dict, cwd=context_dir, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
	#call p.kill() later
	return p

def kill_dockers(context_dir, files_dir, files):
	cmd="docker-compose "
	for fi in files:
		cmd+="-f "+files_dir+"/"+fi+" "
	cmd += " kill"

	print("cmd: "+str(cmd))
	p = subprocess.Popen(cmd, shell=True, cwd=context_dir, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
	#wait for the call to finish
	(output, err) = p.communicate()
	#print(output)



def flatten(d):
	"""
	receives an array of dicts and put all of them into one dict
	"""
	out={}
	for di in d:
		for ki, vi in di.iteritems():
			out[ki]=vi
	return out

def run_test_cmd(container_name, cmd, workdir, trials=9, callbacks=None):
	#time.sleep(130)
	#return 1,1


	client=docker.from_env()

	
	#find the requried container
	trial=0
	cnt=None
	while trial<trials:
		containers=client.containers.list()
		for ci in containers:
			#see https://docker-py.readthedocs.io/en/stable/containers.html#docker.models.containers.Container
			#print("ci: "+str(ci.name))
			if ci.name==container_name:
				cnt=ci
				break
		print("retry connecting to the container "+str(container_name))
		time.sleep(2)
		trial+=1
		if cnt!=None:
			break
	if cnt==None:
		raise Exception("No container with name "+str(container_name)+" found!")
	time.sleep(3)
	print("!! Runnig command "+str(cmd)+" inside the container "+container_name)
	#logs=cnt.logs(stream=True, follow=True)#, tail=1)
	#see https://docker-py.readthedocs.io/en/stable/containers.html#docker.models.containers.Container.exec_run
	detaching=False
	#if callbacks!=None:
	#	detaching=True
	exit_code, logs=cnt.exec_run(cmd, stream=True, workdir=workdir, detach=detaching, tty=True)#, socket=True)

	#TODO: Detach the exec_run (use detach=True) and call callbacks periodically
	print("Current state of the container is: "+str(cnt.status)+", detaching: "+str(detaching))

	#create a subprocess
	p=None
	if callbacks!=None:
		p = Process(target=callbacks.onRun, args=(cnt,))
		p.start()

	
	print("type of logs output: "+str(type(logs)))
	all_lines=[]
	for line in logs:
	 	#line=output.recv(8)
	 	#print(line)#, end='')
	 	all_lines.append(line)

	if callbacks!=None:
		print("Trying to join the onRun subprocess")
		p.join()
		print("done. Subprocess joined")

	print("-------------------")
	print("done callind cmd: "+str(cmd))
	return exit_code, all_lines

	


def report_test_result_to_ci(result):
	#TODO, parse the result for "error"
	return True

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description='Starts a bunch of docker-compose files.')
	parser.add_argument("--testdir", help="The directory, which contains the tests", default="finepos")
	args, unknown = parser.parse_known_args()

	dirname=args.testdir
	print("dirname: "+str(dirname))
	stream=open(dirname+"/docker-compose-files.yml", 'r')
	test_env=yaml.load(stream)
	print("test_env: "+str(test_env))


	#execute the callbacks 
	import importlib
	has_event_module=False
	try:
		callbacks = importlib.import_module(args.testdir+'.events') #importlib.import_module(args.testdir)
		print("Loaded callbacks: "+str(callbacks))
		print("Executing callbacks.onBeforeStart")
		callbacks.onBeforeStart()
		has_event_module=True
	except Exception as e:
		print("No event module found."+str(e))
		sys.exit(-1)

	time.sleep(1)
	try:
		test_item=None
		#iterate over groups:
		for key, val in test_env.iteritems():
			print("=========================="+key+"====================================")
			if key=="test":
				test_item=val
				continue
			v=flatten(val)
			print("v:"+str(v))
			context_dir=v['context-dir']
			files_dir=v['files-dir']
			env_file=v['env-file']
			files=v['files']
			proc=call_docker_compose(env_file, context_dir, files_dir, files)

		#now run the test itme
		time.sleep(1)
		print("test_item: "+str(test_item))
		cmd=test_item['cmd']
		container_name=test_item['container_name']
		print("-- running the test, container: "+str(container_name)+", cmd: "+str(cmd))

		#if this drops a timeout, it refers to the timeout that the output of the called command
		#has not sent any new lines to the output stream for some longer amount of time...
		res=run_test_cmd(container_name, cmd, workdir=test_item['workdir'], callbacks=callbacks)
		report_test_result_to_ci(res)
	except Exception as e:
		print("Error on executing the test: "+str(e))

	#time.sleep(12)
	for key, val in test_env.iteritems():
		if key=="test":
			continue
		print("==========================KILLING "+key+"====================================")
		v=flatten(val)
		print("v:"+str(v))
		context_dir=v['context-dir']
		files_dir=v['files-dir']
		env_file=v['env-file']
		files=v['files']
		kill_dockers(context_dir, files_dir, files)
		#print("key: "+str(key)+", val: "+str(val))

	print("Executing callbacks.onBeforeExit")
	if has_event_module:
		callbacks.onBeforeExit()

