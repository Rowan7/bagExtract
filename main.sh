#!/bin/env bash
#
# This script populates target directory ($1) with .jsonFiles through ./jsonPopulate.sh then for each .bag.json File Pair, 
# Then it gets the desired path starting at routeRoot ($2) through reading the .jsonFile through calling getRoute.py
# Then it goes to the routeRoot and follows the path, (or builds it if it doesn't exist)                                                         
#
# $1 - (bagPath)
# $2 - routeRoot (where the path wants to be built from)
#
# USAGE HELP:          ./main.sh bagDirectory routeRoot
# USAGE EXAMPLE:       /main.sh ../bags ../sorted
#

A_PROGRAM_HOME=`pwd`

r_TARGET_BAG_DIR=$1
cd $r_TARGET_BAG_DIR
A_TARGET_BAG_DIR=`pwd` # $1 can be a relative path, convert to absolute path for future use.
cd ~-
r_ROUTE_ROOT=$2
cd $r_ROUTE_ROOT
A_ROUTE_ROOT=`pwd` # $2 can be a relative path, convert to absolute path for future use.
cd ~-
errorPath=$A_TARGET_BAG_DIR/failed.txt
errorFile=failed.txt
TIMEOUT=5m # Max BagFile Extraction Time Limit
SUCCESS=0
FAILURE=1
TIMEDOUT=125


formatBags() {

# FORMAT BAG NAMES HERE BEFORE THEY'RE POPULATED WITH .JSON
# Clean up and format bag files in target directory
echo "Formatting Bags"

declare -A keywordCorrection=( # Declare an associative array containing known keyword targets and their respective corrections.
                               # Note: associative arrays are non-indexable/orderable as they are represented as a hash function.
    ["pearce_"]="frognall_" \
    ["peasgood_"]="frognall_" \
    ["gs_"]="ely_" \
    ["leak_"]="leek_" \
    ["beet_"]="sugarbeet_" \
    ["none_none_auto_none_"]="wheat_papley_" \

)

# Add each correction in front of keyword, then delete all necessary keywords afterwards in seperate loop (this is because some keywords don't want replacing e.g pearce, but delete all misspellings of leek.)
index=0
for keyword in ${!keywordCorrection[@]}; do
    correction=${keywordCorrection[${keyword}]}
  # echo variables 
    echo "Target Keyword: $keyword"
    echo "Correction: $correction"
    echo "Index: $index"

  # go through each item in the above array, if it contains keyword: check if it already contains correction
  # if it already contains correction, pass, else: add correction infront of the first instance of keyword found
    find ${A_TARGET_BAG_DIR} -type f \( -iname "*$keyword*" \) | while read line;
    do
        if [[ "$line" != "*$correction*" ]]; then
            newFileName=${line/$keyword/${correction}${keyword}}
            echo "'$keyword' Keyword found in $line, adding '$correction'"
            mv $line $newFileName
            echo "New File Name: $newFileName"
        else
            echo "$line already contains $correction, not renaming."
        fi
    done
    echo "==================================="
    ((index++))
done

removalArray=("none_" "leak_" "beet_") #ONLY REMOVE BEET_ IF THERE ISN'T SUGAR INFRONT OF IT
# if there's any instances of any items in removalArray in the filename, remove them.
# If it finds an instance of "beet_", only remove it if it's not got sugar preceeding it.. BUG
# don't add instances of sugarbeet when beet_ is already preceeded by sugar.
# don't remove instances of beet_ if it is preceeded by sugar <--- PERFECT SOLUTION
# My solution is imperfect, it will only get rid of instances of _beet_ | this won't work correctly when filename starts with "beet_frognall_pearce_RGB.bag"
for keyword in ${removalArray[@]}; do 
    find ${A_TARGET_BAG_DIR} -type f \( -iname "*${keyword}*" \) | while read line;
    do 
        newFileName=${line//${keyword}/}
        echo "'${keyword}' keyword found in $line, Removing.."
        mv $line $newFileName
    done
done

}

jsonPopulate() {

# Populate with .json files and add key values for each detected attribute.
$A_PROGRAM_HOME/jsonPopulate.sh $A_TARGET_BAG_DIR

}


extract() {
# go through each .jsonFile .bagFile pair and if it's not missing any attributes, create it a path to be stored.
for jsonPathName in $A_TARGET_BAG_DIR/*json; do
    bagPathName=${jsonPathName%.*}.bag
    bagFile=$(basename ${bagPathName})
    jsonFile=$(basename ${jsonPathName})
    if [ -f $A_TARGET_BAG_DIR/$bagFile ]; then
        if  $(! grep -q $bagFile $errorPath)  ; then
            #echo "Complete bagFile/jsonFile Pair Found: ${bagFile%.bag}"
            getRouteReturn=$(python3 $A_PROGRAM_HOME/getRoute.py $jsonPathName $A_ROUTE_ROOT)
            if [[ $getRouteReturn == *"ERROR"* ]]; then
                echo "Error found in getRoute, skipping .bag Extraction"
            else
                #echo "Formatting Master Path"
                MASTER_PATH=${getRouteReturn##*MASTER_PATH: }
                #echo " Bag file path: ${bagPathName} save path: ${MASTER_PATH}"
                networkInputReturn=$(timeout --foreground -k 10 ${TIMEOUT} /home/Garford_RoboEye/build/projects/networkInput/./networkInput -b ${bagPathName} -x ${MASTER_PATH})
                if [ "$?" -eq "$SUCCESS" ]; then
                    echo "STATUS: Processing bagFile: ${bagFile} SUCCESS"
                elif [ "$?" -eq "$FAILURE" ]; then 
                    echo "ERROR: Processing bagFile: ${bagFile} FAILED! OUTPUT: $?"
                    echo "Failed to Extract: ${bagFile##*/}" >> "$errorPath" # Add to Error File
                else 
                    echo "STATUS: Processing bagFile: ${bagFile} TIMED OUT (Timeout Limit Reached: ${TIMEOUT} Minutes)"
                    echo "Failed to Extract: ${bagFile##*/}, Timed Out" >> "$errorPath" # ADD TO FAILED.TXT TIMEOUT
                fi
            fi
        else
            echo "$bagFile found in $errorFile, skipping path creation."
        fi
    else
        echo "$jsonFile found without matching bagFile, skipping skipping path creation."
    fi

done
echo "FILE EXTRACTION COMPLETE"
}

formatBags

# jsonPopulate()
# extract()

