#!/bin/env bash
#
# This script first looks for existing error files in target directory ($1): example "incompleteFormat.txt", and either creates them if they don't exist, or clears them if they already do. DONE
# It then searches for bag files in target directory ($1) checks if there's a .json file with the same name as the bag file, if there isn't, it makes one.                                   DONE
# It then adds Key Value pairs in the .json file for each attribute identified and collected.                                                                                                DONE
# If It doesn't find a certain Key Value pair, it writes to an error file and informs the user.                                                                                              DONE                                                                  
#
# USAGE HELP:          ./jsonPopulate where(bagDirectory)
# USAGE EXAMPLE:       ./jsonPopulate ../bags
#


#=== Initial Variables and arrays # Used for clearer navigation.
attributeArray=("Crop" "Location" "Format") # Array of all attributes collected in each bag file Except from dateCreated as this doesn't involve keywords

arrayCrop=("Carrot" "Celery" "Springwheat")
arrayLocation=("Pearce" "Lincoln")
arrayFormat=("_RGB_" "_RGBD_" "_IRD_" "_RGBIRD_")

A_PROGRAM_HOME=`pwd`

r_TARGET_BAG_DIR=$1
cd $r_TARGET_BAG_DIR
A_TARGET_BAG_DIR=`pwd` # $1 can be a relative path, convert to absolute path for future use.
cd ~-

cd $A_TARGET_BAG_DIR

#FOR TOM <<================ If you want a text file for each missing attribute then use the code below,
#for item in ${attributeArray[@]}; do    # For attribute in attributeArray, create or overwrite .txt file
    #>missing${item}.txt
#done
    #>missingDateCreated.txt # Have to do this one seperately because attributeArray is used for other functions

> missing.txt # Otherwise, just make 1 error file to hold all the missing information.

for bagFile in ./*bag; do    # For each bagFile in target directory
    for attribute in ${attributeArray[@]}; do # Go through each attribute in attribute array, which holds arrays of arrays
        currentArray=array$attribute[@]
        found=0     # Missing Flag
        for value in ${!currentArray}; do   # Go through each item (in each array)
            #Look through the bagFile's file name and count the value matches for each key(crop then location then format...)
            keywordCount=$(find . -type f \( -iname "*$value*" -a -name "${bagFile##*/}" \) -exec python3 $A_PROGRAM_HOME/addKeyValue.py ./{} $attribute ${value//_/} \; | wc -l)
            if [ ! $keywordCount -eq 0 ]; then # If it goes through the whole array and finds a successful keyword, put away the flag:
                found=1
            fi
        done
        if [ $found -eq 0 ];then # If the flag is still up after going through an array:
        errorFile=missing.txt   # Write to the relevent error file
        echo "Missing $attribute: ${bagFile##*/}" >> $errorFile
        fi
    done
    epochTime=` date -r ${bagFile##*/} "+%s"`                                                # After adding the rest of the key value pairs, it adds the date it was created    
    epochToUTC=` date --utc --date "1970-01-01 $epochTime seconds" +"%Y-%m-%d-%H-%M-%S"`     # I think this has to be hardcoded at the end because you can't hold all the dates in an array.
    keywordCount=$(python3 $A_PROGRAM_HOME/addKeyValue.py ./${bagFile##*/} "dateCreated" $epochToUTC)      # FOR TOM <<===== I don't think this can have an error flag because it's impossible for a file
done                                                                                         #                 to not have a date created, it will ALWAYS find it

if [ ! -s $errorFile ]; then
    echo "WARNING: $errorFile has been appended to."
fi

