#!/bin/env bash
#
# This script formats bags and tidies them up before they are used elsewhere.
#
# Current Cleanup:
# Replace all instances of "beet_" with "sugarbeet_"
# Replace all instances of "leak_" with "leek_"
# Replace all instances of "letuce_" with "lettuce_"
# Replace all instances of "none_none_auto_none" with "wheat_papley"
#
# Place "ely_" infront of all instances of "gs_"
# Place "ely_" infront of all instances of "engine_farm"
# Place "frognall_" infront of all instances of "pearce_"
# Place "frognall_" infront of all instances of "peasgood_"
# 
#
# $1 (bagPath)
#
# USAGE HELP:          ./formatBags where(bagDirectory)
# USAGE EXAMPLE:       ./formatBags bags/
#
#

A_PROGRAM_HOME=`pwd`
r_TARGET_BAG_DIR=$1
echo $r_TARGET_BAG_DIR
A_TARGET_BAG_DIR=$( realpath ${r_TARGET_BAG_DIR} )



main() {
# Format the bag names nicely before they're populated with .json files.
# Clean up and format bag files in target directory
echo "Formatting Bags"

declare -A keywordCorrection=( # Declare an associative array containing known keyword targets and their respective corrections.
                                # Note: associative arrays are non-indexable/orderable as they are represented as a hash function.
   #["keyword"]="correction" \
    ["pearce_"]="frognall_" \
    ["peasgood_"]="frognall_" \
    ["gs_"]="ely_" \
    ["engine_farm"]="ely_" \
    ["beet_"]="sugarbeet_" \
    ["leak_"]="leek_" \
    ["letuce_"]="lettuce_" \
    ["none_none_auto_none_"]="wheat_papley_" \
)
# Add each correction in front of keyword, then delete all necessary keywords afterwards in seperate loop (this is because some keywords don't want replacing e.g pearce, but delete all misspellings of leek.)
index=0
for keyword in ${!keywordCorrection[@]}; do # For keyword in the associated array:
    correction=${keywordCorrection[${keyword}]} # The correction is the Value of that key value pair in the array.
   
    #echo "Target Keyword: $keyword"
    #echo "Correction: $correction"
    #echo "Index: $index"

  # go through each item in the above array, if it contains keyword: check if it already contains correction
  # if it already contains correction, pass, else: add correction infront of the first instance of keyword found

    find ${A_TARGET_BAG_DIR} -type f \( -iname *"$keyword"* -and -not -iname *"$correction"*  \) | while read line; # We want to also check there's no instances of sugarbeet
    do

            newFileName=${line/$keyword/${correction}${keyword}}
            echo "'$keyword' Keyword found in $line, adding '$correction'"
            mv $line $newFileName #Rename it
            echo "New File Name: $newFileName"

    done

    #echo ""
    ((index++))
done

removalArray=("_none" "none_" "_leak" "_beet") 
# if there's any instances of any items in removalArray in the filename, remove them.
# Remove the underscore befor eit as there will ALWAYS be items before it unless the item starts with none_.

for keyword in ${removalArray[@]}; do 
    find ${A_TARGET_BAG_DIR} -type f \( -iname *"${keyword}"* \) | while read line;
    do 
        newFileName=${line//${keyword}/}
        echo "'${keyword}' keyword found in $line, Removing.."
        mv $line $newFileName
    done
done
echo "Bag Formatting Complete"
}

main