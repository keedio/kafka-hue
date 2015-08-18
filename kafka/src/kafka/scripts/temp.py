#!/usr/bin/env python

import sys,os
import subprocess

sCommand = subprocess.Popen(['ls -la'], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
output,err = sCommand.communicate()

print "ERROR: ", err
print "OUTPUT: ", output
