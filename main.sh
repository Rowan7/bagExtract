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
# ./main.sh /home/In-Row-Bags/sugarbeet-pearce-23/ /home/In-Row-Bags/In-Row-Images/extractedBags
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
# Format bags and tidy them up before they are used elsewhere.
$A_PROGRAM_HOME/formatBags.sh $A_TARGET_BAG_DIR
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
            echo "Complete bagFile/jsonFile Pair Found: ${bagFile%.bag}"
            getRouteReturn=$(python3 $A_PROGRAM_HOME/getRoute.py $jsonPathName $A_ROUTE_ROOT)
            if [[ $getRouteReturn == *"ERROR"* ]]; then
                echo "Error found in getRoute, skipping .bag Extraction"
            else
                echo "Formatting Master Path"
                MASTER_PATH=${getRouteReturn##*MASTER_PATH: }
                echo " Bag file path: ${bagPathName} save path: ${MASTER_PATH}"
                networkInputReturn=$(timeout --foreground -k 10 ${TIMEOUT} /home/Garford_RoboEye/build/projects/networkInput/./networkInput -b ${bagPathName} -x ${MASTER_PATH} -m "INROW")
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

#formatBags
jsonPopulate
#extract


