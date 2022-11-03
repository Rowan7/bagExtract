#!/usr/bin/python
import sys
import os
import json

#
# This script goes through a target pathName.json file ($1) in target directory and reads the file to make a path variable, it then returns the master path to the bash script
# It then moves the .bagFile to the specified path for extraction.
# $1 - .jsonPathName
#
# USAGE HELP:          python3 pathCreate .jsonPathName
# USAGE EXAMPLE:       python3 pathCreate.py ../bags/carrot_pearce_RGBIRD_.json
#
#

def main():
    str; jsonPathName = sys.argv[1]

    str; A_PROGRAM_HOME = os.getcwd()
    str; A_jsonPathName = os.path.abspath(jsonPathName) # If user gives relative path, convert it to absolute path and use that.
    str; A_jsonPath = os.path.split(A_jsonPathName)[0]  # Separate bagfile.bag from path               
    str; jsonName = os.path.split(A_jsonPathName)[1]
    str; jsonBaseName = os.path.splitext(jsonName)[0]

    os.chdir(A_jsonPath)
    jsonFile = open(jsonName)
    contents = json.load(jsonFile)
    jsonFile.close()
    str; cropValue = str(contents['Crop'])
    str; locationValue = str(contents['Location'])
    str; formatValue = str(contents['Format'])
    str; MASTER_PATH = cropValue+"/"+locationValue+"/"+formatValue+"/"+jsonBaseName
    return MASTER_PATH

print(main())