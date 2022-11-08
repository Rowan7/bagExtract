#!/usr/bin/python
import sys
import os
import json

# 
# This Program Takes 3 Compulsory Parameters
# $1 - .bagfile Path and Filename
# $2 - Key
# $3 - Value
# $4 - modifier (optional)
#
#
# Example USAGE: python3 addKeyValue.py ~/Desktop/projects/bash/bags/organised/Lettuce/Pearce/lettuce_auto_pearce_0_RGBIRD_13-08-21_08:47:18_435_.bag Location Pearce
# Example USAGE: python3 addKeyValue.py ./sugarbeet_auto_lincoln_0_RGBIRD_13-08-21_08:47:18_435_ .bag Location Lincoln
# 

# GATHER ARGUMENTS

def parseCMDArgs(): 
    str; scriptName = sys.argv[0]

    if (len(sys.argv) == 1): 
        raise KeyError("ERROR: No cmd arguments specified. Please specify PATH, KEY and VALUE")

    try:
        str; bagPathName = sys.argv[1]

        try: 
            str; key = sys.argv[2]  
        except: 
            raise KeyError("ERROR: No Key CMD argument specified. Please specify KEY")

        str; value = sys.argv[3]
        try:
            str; modifier = sys.argv[4] # Optional parameter, Example Usage: -f
        except:
            modifier = None
    except KeyError as e:
        raise RuntimeError("ERROR: Can't start program. CMD not entered correctly. Err: {}".format(e))
        print ("WARNING: Incorrect Usage:")
        print ("Example Usage: addKeyValue.py ./test/test.bag Location Lincoln")
    

    str; A_bagPathName = os.path.abspath(bagPathName) # If user gives relative path, convert it to absolute path and use that.
    str; A_bagPath = os.path.split(A_bagPathName)[0]  # Separate bagfile.bag from path               
    str; bagName = os.path.split(A_bagPathName)[1]
    str; bagBaseName = os.path.splitext(bagName)[0]   # Take off the .bag and store just the name 
    str; target = bagBaseName + ".json"          # the .json file will have the same filename as the .bag file just with .json on the end

    return A_bagPath, bagName, target, key, value, modifier 

# VARIABLE MANIPULATION AND FORMATING


def force(modifier):
    if modifier == "-f":
        return True
    else:
        return False


# 0:.bagFile Not Found | 1: .bag and .json successfully found | 2: .bag found, not .json found
def checkJSON(A_bagPath, bagName):                   # This function splits the path name into path and filename, then paths and checks if there is a JSON file with the same name as filename, 
    str; bagBaseName = os.path.splitext(bagName)[0]  #   If there isn't it creates a blank one.
    str; target = bagBaseName + ".json" 
    os.chdir(A_bagPath)                          # goto path to look for the bagFile;
    if os.path.exists (bagName):                 
        if os.path.exists(target):          
            return 1                    # both .bagfile and .json file found;
        else:                               
            return 2             # .bagfile found but .json file doesn't exist;    
    else:                                
        return 0     # .bagfile isn't found;


def printJSON(A_bagPath, target):
    os.chdir(A_bagPath) 
    jsonFile = open(target)
    data = json.load(jsonFile)
    print(data)
    jsonFile.close()

def writeJSON(target, key, value):
    try:   
        file = open(target, 'r')
        data = json.load(file)
        file.close()
        newData = {key: value}
        data.update(newData)
        file = open(target, 'w')
        json.dump(data, file, indent=2)
        file.close()
        print ("Key: " + key + " has been added with value: "+ value + " in: " + target) 
        return 1
    except FileExistsError as e:
        print ("Error, Unable to write to: {} err: {}".format(target, e)) 
        return 0
  

# 0:Key Not Found | 1:Existing Key Found | 2:Empty Key Found
def checkKeyExist(A_bagPath, target, key): # does the input key already exist in the .json file, Should already be in the correct directory (A_bagPath)
    os.chdir(A_bagPath) 
    try:
        jsonFile = open(target)
        data = json.load(jsonFile)
        str; keyString = data[key] 
        if (keyString == None): # Key is found, value is null;
            return 2
        else:                
            return 1  # Key is found, value is not null;
    except:
        return 0      # Key isn't found




#===================================================================================================================================================================
# 0: .bagFile Not Found | 1: .bagFile Found, .json not Found, creates .json, adds key:value | 2: .bagFile Found, .json Found, Key not already exists, adds key:value
# 3: .bagFile Found, .json Found, Existing Key Found, Force Modifier Applied, Overwritten | 4 .bagFile Found, .json Found, Existing Key Found, not overwritten
# 5: .bagFile Found, .json Found, Existing Key Found, Existing Key is null; auto overwritten irrelevent of Force modifier.

def main(A_bagPath, bagName, target, key, value, modifier):
   
    try:
        os.chdir(A_bagPath) 
    except FileNotFoundError as e: 
        raise FileNotFoundError("ERROR: Incorrect bag path specified. Bag file directory does not exist! Err: {}".format(e))
    
    if (checkJSON(A_bagPath, bagName) == 0): # 0:.bagFile Not Found
        print ("Error: " + bagName + " was not found in: " + A_bagPath)
        return 0
    elif (checkJSON(A_bagPath, bagName) == 1): # 1: .bag and .json successfully found
        #print (bagName + " and: " + target + " were successfully found!")
        pass
    elif (checkJSON(A_bagPath, bagName) == 2):# 2: .bag found, not .json found
        print (bagName + " found, creating .json: " + target)
        with open(target, 'w') as f:
            json.dump({}, f)
            print(target + " has been created")
        writeJSON(target, key, value) # If the .json file isn't there, the input key will definitely not be found, so auto passes 2nd check        # Semi Bug Here
        return 1

    # At this point, checkJSON is over and in all cases below, there is a .bagFile and .jsonFile already found 
    if (checkKeyExist(A_bagPath, target, key) == 0): # 0:Key Not Found
        writeJSON(target, key, value)
        return 2
    elif (checkKeyExist(A_bagPath, target, key) == 1): # 1:Existing Key Found 
        if (force(modifier)):
            writeJSON(target, key, value)
            return 3
        else:
            jsonFile = open(target)
            data = json.load(jsonFile)
            print ("Key: " + key + " already found in " + target + " with value: " + data[key] + ". To force overwrite, please use the -f modifier, see Example Usage.") 
            jsonFile.close()
            return 4
    elif (checkKeyExist(A_bagPath, target, key) == 2):# 2:Empty Key Found
        print ("Key: " + key + " already found in " + target + " with value: null; Overwriting..") 
        writeJSON(target, key, value)
        return 5

if __name__ == "__main__":
    
    A_bagPath, bagName, target, key, value, modifier = parseCMDArgs()
    main(A_bagPath, bagName, target, key, value, modifier)