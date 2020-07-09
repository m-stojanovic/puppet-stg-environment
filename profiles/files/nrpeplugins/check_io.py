#!/usr/bin/python -tt

"""
Nagios nrpe plugin to check IO disk status. 
"""

#Make it a bit more like home :)
from __future__ import print_function
from __future__ import nested_scopes
from __future__ import division
from __future__ import with_statement

#Standard imports:
import sys
import signal
import argparse
import os
import time

#Constants:
DEFAULT_TIMEOUT = 6
DEFAULT_AVERAGING_PERIOD = 2
DEFAULT_VERBOSE = False
DISKSTASTS_PATH = '/proc/diskstats'
DEFAULT_UTIL_WARN = 80
DEFAULT_UTIL_CRIT = 90


class CustomException(Exception):
  pass


class ScriptTimeout(CustomException):
  """
  Used to signal timeout after user specifed time has
  passed
  """
  def __init__(self,timeout_value=-1):
    self.timeout_value=timeout_value
  pass


class NagiosData(object):
  def __init__(self):
    self.exit_status=0
    self.exit_message=''

  def exit(self):
    if self.exit_message:
      print(self.exit_message)
    elif self.exit_status == 0:
      print("Everything is OK")
    else:  
      print('Script terminated abnormally for unknown reason')
      self.exit_status=3
    sys.exit(self.exit_status)

  def updateData(self,*new_data):
    new_data = list(new_data)
    while True:
      new_exit_status = new_data.pop(0)
      new_exit_message = new_data.pop(0)
      if self.exit_status < new_exit_status:
        self.exit_status =  new_exit_status
      self.exit_message += new_exit_message + ' '
      if not new_data: break

  def setData(self,new_exit_status,new_exit_message):
    self.exit_status =  new_exit_status
    self.exit_message = new_exit_message


class Device(object):
  def __init__(self,name,averaging_period,sread_warn,sread_crit,swrite_warn,swrite_crit,util_warn,util_crit):
    self.name=name  #ID of the object
    self.averaging_period=averaging_period
    self.sread_warn=sread_warn
    self.sread_crit=sread_crit
    self.swrite_warn=swrite_warn
    self.swrite_crit=swrite_crit
    self.util_warn=util_warn
    self.util_crit=util_crit
    self.performance_data = []
  
  def __str__(self): #just for debug purposes
    return "[{0}] {1}:\n\taveraging_period: {2}, sread_warn: {3}, sread_crit: {4}, swrite_warn: {5}, swrite_crit: {6}, util_warn: {7}, util_crit: {8}, performance_data: {9}\n".format(
                  self.__class__.__name__,
                  self.name,
                  self.averaging_period,
                  self.sread_warn,
                  self.sread_crit,
                  self.swrite_warn,
                  self.swrite_crit,
                  self.util_warn,
                  self.util_crit,
                  self.performance_data
                )

  def addPerformanceData(self,data):
    self.performance_data.append(data)

  def checkLimits(self):
    #Be paranoid:
    if len(self.performance_data) < 2:
      return [3,"Cannot determine the state of the device {0}".format(self.name)]
    sread = self.performance_data[1][2] - self.performance_data[0][2]
    swrite = self.performance_data[1][6] - self.performance_data[0][6]
    tbusy = self.performance_data[1][9] - self.performance_data[0][9]
    #check if we had overflows in the meantime:
    #sys.maxsize is x86/x86_64 dependant, so we do not have to put more logic here
    if sread < 0: sread += sys.maxsize 
    if swrite < 0: swrite += sys.maxsize
    if tbusy < 0: tbusy += sys.maxsize 
    #Calculate relative values:
    status = 0
    message = "Device {0}: ".format(self.name)
    if self.sread_crit: #any of them will do
      if sread > self.sread_crit:
        status = 2
        tmp = sread-self.sread_crit
        message += "sectors read/s critical threshold exceeded by {0}/{1:.2f}%, ".format(tmp, 100 * (tmp)/self.sread_crit)
      elif sread > self.sread_warn:
        if status < 1: status = 1
        tmp = sread-self.sread_warn
        message += "sectors read/s warning threshold exceeded by {0}/{1:.2f}%, ".format(tmp, 100 * (tmp)/self.sread_warn)
      if swrite > self.swrite_crit:
        status = 2
        tmp = swrite-self.swrite_crit
        message += "sectors write/s critical threshold exceeded by {0}/{1:.2f}%, ".format(tmp, 100 * (tmp)/self.swrite_crit)
      elif swrite > self.swrite_warn:
        if status < 1: status = 1
        tmp = swrite-self.swrite_warn
        message += "sectors write/s warning threshold exceeded by {0}/{1:.2f}%, ".format(tmp, 100 * (tmp)/self.swrite_warn)
    tmp = 100 * tbusy / (1000 * self.averaging_period)
    if tmp > self.util_crit:
      status = 2
      message += "I/O utilization critical threshold exceeded ({0:.2f}%>{1}%)".format(tmp, self.util_crit)
    elif tmp > self.util_warn:
      if status < 1: status = 1
      message += "I/O utilization warning threshold exceeded ({0:.2f}%>{1}%)".format(tmp, self.util_warn)
    if status == 0: message += "OK"
    return [status,message]

def fetchPerformanceData():
  with open(DISKSTASTS_PATH) as fh:
    def toInt(str):
      try:
        return int(str)
      except ValueError:
        return str
    return [[toInt(y) for y in x.split()] for x in list(fh)]

class IntRangeValidator(object):
  def __init__(self, lower_range, upper_range, statement=None):
    self.lower_range=lower_range
    self.upper_range=upper_range
    #Join the fields accordingly:
    tmp="Value must be an integer"
    if lower_range or upper_range:
      tmp += ","
      if lower_range is not None:
        tmp += "higher than " + str(lower_range) + " "
        if upper_range:
          tmp += "and "
      if upper_range is not None:
        tmp += "lower than " + str(upper_range)
    tmp += "."
    self.statement=tmp

  def __call__(self, string):
    try:
      val=int(string)
    except ValueError:
      raise argparse.ArgumentError(None, self.statement)
    if self.lower_range is not None and self.lower_range >= val:
      raise argparse.ArgumentError(None, self.statement)
    if self.upper_range is not None and self.upper_range <= val:
      raise argparse.ArgumentError(None, self.statement)
    return val


def device_validator(string):
  if not string in [ x[2] for x in fetchPerformanceData()]:
    raise argparse.ArgumentError(None,"Device {0} does not exists".format(string))
  return string

def main():
  nagios=NagiosData()
  args=lambda x: x #Hack - create an empty namespace
  args.verbose=None
  try:
    #Gather command line arguments:  
    parser = argparse.ArgumentParser( 
                                      description='Nagios I/O check plugin', 
                                      epilog="Author: Pawel Rozlach",
                                      add_help=True,
                                    )
    parser.add_argument(  '--version', 
                          action='version', 
                          version='check_io.py version 1.0')  
    parser.add_argument(  "-v", "--verbose", 
                          action='store_true', 
                          default=DEFAULT_VERBOSE, 
                          help="Be verbose/show debbuging output.")
    parser.add_argument(   "-t", "--timeout", 
                          action='store', 
                          default=DEFAULT_TIMEOUT, 
                          type=IntRangeValidator(0,None), 
                          help="Timeout after which script will terminate itself.")
    parser.add_argument(   "-a", "--averaging-period", 
                          action='store', 
                          default=DEFAULT_AVERAGING_PERIOD,
                          type=IntRangeValidator(0,None), 
                          help="Time to spent collecting IO data from kernel counters.")
    volume_limits_group = parser.add_argument_group(title="Throughput limits")
    volume_limits_group.add_argument(   "--sread-warn", 
                          action='store', 
                          type=IntRangeValidator(0,None), 
                          help="Warning threashold for the number of sectors read per second.")
    volume_limits_group.add_argument(   "--sread-crit", 
                          action='store', 
                          type=IntRangeValidator(0,None), 
                          help="Critical threashold for the number of sectors read per second.")
    volume_limits_group.add_argument(   "--swrite-warn", 
                          action='store', 
                          type=IntRangeValidator(0,None), 
                          help="Warning threashold for the number of sectors written per second.")
    volume_limits_group.add_argument(   "--swrite-crit", 
                          action='store', 
                          type=IntRangeValidator(0,None), 
                          help="Critical threashold for the number of sectors written per second.")
    utilization_limits_group = parser.add_argument_group(title="Device utilization limits")
    utilization_limits_group.add_argument(   "--util-warn", 
                          action='store', 
                          default=DEFAULT_UTIL_WARN,
                          type=IntRangeValidator(0,99), 
                          help="Warning threshhold for the device utilization in percents.")
    utilization_limits_group.add_argument(   "--util-crit", 
                          action='store', 
                          default=DEFAULT_UTIL_CRIT,
                          type=IntRangeValidator(1,100), 
                          help="Critical threshhold for the device utilization in percents.")
    parser.add_argument(   "--devices", 
                          action='store', 
                          nargs="+",
                          type=device_validator,
                          help="List of devices to check.")
    args=parser.parse_args()
  
    if args.verbose: print("Command line arguments: \n\t",args) 

    #Set timeout:
    def raiseTimeout(signum,frame):
      raise ScriptTimeout(args.timeout)
    signal.signal(signal.SIGALRM, raiseTimeout)
    signal.alarm(args.timeout)    

    #Validate command line arguments (some of it are mimicing missing argparse functionalities):
      #Timeout vs averaging period:
    if args.timeout + 1 <= args.averaging_period:
      nagios.setData(3,"Averaging period must be at least one second lower than script timeout.")
      nagios.exit()
      #Utilization  limits:
    if args.util_warn >= args.util_crit:
      nagios.setData(3,"Utilization warning threshold has to be less than critical threshold")
      nagios.exit()
      #Throughput limits:
    if (args.sread_warn or args.sread_crit or args.swrite_warn or args.swrite_crit) and not \
          ( args.sread_warn and args.sread_crit and args.swrite_warn and args.swrite_crit):
      nagios.setData(3,"All throughput limits should be defined (or none of them).")
      nagios.exit()
    elif args.sread_warn: #could be any of them
      if args.sread_warn >= args.sread_crit:
        nagios.setData(3,"Read throughput warning threshold has to be lower than critical threshold") 
        nagios.exit()
      if args.swrite_warn >= args.swrite_crit:
        nagios.setData(3,"Write throughput warning threshold has to be lower than critical threshold") 
        nagios.exit()

    if args.devices: 
      device_names = set(args.devices)
    else:
      #If user did not specify what to monitor - fetch all block devices
      compaq_majors = [72,73,74,75,76,77,78,79,104,105,106,107,108,109,110,111] #Compaq SMART and CIS arrays
      ide_majors = [3,22,33,34,56,57,88,89,90,91] #IDE controlers
      scsi_majors = [8,21,65,66,67,68,69,70,71,128,129,130,131,132,133,134,135]
      virt_majors = [202,254] #Xen & VirtIO
      diskmapper_majors = [253]
      drbd_majors = [147]
      misc_majors = [114] #ATA raids
      
      #explanation of all major numbers can be found in </include/linux/major.h> @ kernel sources  
      device_names=[x[2] for x in fetchPerformanceData() if ((x[0] in \
                                                                compaq_majors + \
                                                                ide_majors + \
                                                                scsi_majors + \
                                                                virt_majors ) 
                                                              and not x[2][-1].isdigit()) 
                                                            or
                                                            (x[0] in \
                                                                diskmapper_majors + \
                                                                drbd_majors + \
                                                                misc_majors)
                                                          ]
      if args.verbose: print("Auto-find devices: " + ''.join(device_names)) 

    #Create all the objects
    devices = {}
    for device_name in device_names:
      devices[device_name]=Device(
                                device_name,
                                args.averaging_period,
                                args.sread_warn,
                                args.sread_crit,
                                args.swrite_warn,
                                args.swrite_crit,
                                args.util_warn,
                                args.util_crit) #FIXME - add per device limits here,
 
    #Start the timer...
    time_start=time.time()
    #and fetch the current data from proc
    [devices[x[2]].addPerformanceData(x[3:])  for x in fetchPerformanceData() if (x[2] in list(devices.keys()))]

    #Sleep the remainig time
    time.sleep(args.averaging_period - (time.time() - time_start))
    
    #Fetch the current data from proc and update objects:
    [devices[x[2]].addPerformanceData(x[3:])  for x in fetchPerformanceData() if (x[2] in list(devices.keys()))]

    if args.verbose: print(''.join([str(x) for x in list(devices.values())])) 
  
    #Check the data, update Nagios plugin status:
    for device in list(devices.keys()):
      nagios.updateData(*devices[device].checkLimits())

    #And finally (we cannot put it in "finally" block - sometimes we do not work as nagios plugin):    
    nagios.exit()

  except ScriptTimeout as e:
    nagios.setData(1,"Script timed out after " + str(e.timeout_value) + " seconds.")
    nagios.exit()
  except CustomException as e:
    nagios.setData(2,str(e))
    nagios.exit()
  except IOError as e:
    import errno
    nagios.setData(1,"Problem occured while openning the file {0}: {1}".format(e.filename,errno.errorcode[e.args[0]]))
    nagios.exit()
  except Exception as e:
    if not args.verbose:
      nagios.setData(2,"Exception occured: {0}, please inspect the script with --verbose option set.".format(e.__class__.__name__) )
      nagios.exit()
    else:
      import traceback
      print(traceback.format_exc())

if __name__ == '__main__':
  main()
