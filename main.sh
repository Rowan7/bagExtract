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

./jsonPopulate.sh $A_TARGET_BAG_DIR
cd $A_TARGET_BAG_DIR

for jsonFile in ./*json; do
    if [ -f ${jsonFile%.*}.bag ]; then
        # is ${jsonFile%.*}.bag in missing.txt
        echo "bagFile jsonFile Pair Found: $jsonFile"
        python3 $A_PROGRAM_HOME/getRoute.py ./$jsonFile $A_ROUTE_ROOT  ### -p ROUTE_DIR 
    fi
    # PATH IS MADE
    # USE NETWORK INPUT TO EXTRACT THEM
done
