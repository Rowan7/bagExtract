#!/usr/bin/python
import sys
import os
import json


#
# This script goes through a target pathName.json file ($1) in target directory and reads the file to make a path variable, it then returns the master path to the bash script
# It then moves the .bagFile to the specified path for extraction.
# $1 - .jsonPathName
# $2 - routeRoot
#
# USAGE HELP:          python3 pathCreate .jsonPathName
# USAGE EXAMPLE:       python3 pathCreate.py ../bags/carrot_pearce_RGBIRD_.json
#
#

attributeArray = ["Crop", "Location", "Format"]
valueArray = []


def main():

    try:
        str; jsonPathName = sys.argv[1]
        str; A_PROGRAM_HOME = os.getcwd()
        str; A_jsonPathName = os.path.abspath(jsonPathName) # If user gives relative path, convert it to absolute path and use that.
        str; A_jsonPath = os.path.split(A_jsonPathName)[0]  # Separate bagfile.bag from path               
        str; jsonName = os.path.split(A_jsonPathName)[1]
        str; jsonBaseName = os.path.splitext(jsonName)[0]
        str; r_ROUTE_ROOT = sys.argv[2]
        str; A_ROUTE_ROOT = os.path.abspath(r_ROUTE_ROOT)

    except:
        raise KeyError("ERROR: Incorrect Usage, please see USAGE.")
    try:                                                     # PUT TRY AND EXCEPT CATCHES IN HERE
        os.chdir(A_jsonPath)
        jsonFile = open(jsonName)
        contents = json.load(jsonFile)
        jsonFile.close()
    except:
        raise NameError("ERROR: Cannot Locate Path of .jsonFile") #Cannot go to path and open .jsonFile

    try: # Catch if any attributes are missing / misspelt
        for attribute in attributeArray: 
            try:
                str; value = str(contents[attribute])
                valueArray.append(value)
            except KeyError as e:
                raise KeyError("ERROR: No " + attribute + " Key Value Pair Found. Err: {}".format(e))


    ## If nothing was caught
        print ("Successfully found all Key Values")
        str; MASTER_PATH = ""
        MASTER_PATH ="/".join(valueArray)                                                               
        MASTER_PATH=MASTER_PATH+"/"+jsonBaseName        # Fixed bug, now adds the .bagName as a directory too

        try:
            os.chdir(A_ROUTE_ROOT)
            os.makedirs(MASTER_PATH)
        except FileExistsError:
            print ("Successfully Located Existing Path: " + MASTER_PATH)
        else:
            print ("Path Created: " + MASTER_PATH)

        print ("MASTER_PATH: " + A_ROUTE_ROOT + "/" + MASTER_PATH)


    except KeyError as e:
        print("ERROR WARNING: Cannot create path. Missing attributes. Err: {}".format(e)) 
    except Exception as e: 
        raise RuntimeError("FATAL ERROR: Cannot Make MASTER PATH. Err: {}".format(e))

main()
