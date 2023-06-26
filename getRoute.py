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

ATTRIBUTES = ['Crop', 'Location', 'Format']


def parse_values(attributes: dict) -> list[str]:
    values = []
    for attribute in ATTRIBUTES:
        try:
            value = str(attributes[attribute])
            values.append(value)
        except KeyError as e:
            raise KeyError(f'ERROR: No {attribute} Key Value Pair Found. Err: {e}')

    return values


def generate_master_path(attribute_values: list[str], json_base_name: str) -> str:
    path = '/'.join(attribute_values)
    path = f'{path}/{json_base_name}'
    return path


def load_json(path: str) -> dict:
    try:
        with open(path, 'r') as json_file:
            return json.load(json_file)
    except Exception as e:
        raise NameError(f'ERROR: {e} Cannot Locate Path of .jsonFile')  # Cannot go to path and open .json file


def main():
    try:
        json_path_name = sys.argv[1]
        absolute_json_path_name = os.path.abspath(json_path_name)  # If user gives relative path, convert it to absolute path and use that.
        absolute_json_path = os.path.split(absolute_json_path_name)[0]  # Separate bagfile.bag from path
        json_name = os.path.split(absolute_json_path_name)[1]
        json_base_name = os.path.splitext(json_name)[0]
        relative_route_root = sys.argv[2]
        absolute_route_root = os.path.abspath(relative_route_root)
    except Exception as e:
        raise KeyError(f'ERROR: {e} Incorrect Usage, please see USAGE.')

    contents = load_json(os.path.join(absolute_json_path, json_name))

    try:  # Catch if any attributes are missing / misspelt
        attribute_values = parse_values(contents)

        print('Successfully found all Key Values')
        master_path = generate_master_path(attribute_values, json_base_name)

        try:
            os.chdir(absolute_route_root)
            os.makedirs(master_path)
        except FileExistsError:
            print('Successfully Located Existing Path: ' + master_path)
        else:
            print('Path Created: ' + master_path)

        print('MASTER_PATH: ' + absolute_route_root + '/' + master_path)

    except KeyError as e:
        print(f'ERROR WARNING: Cannot create path. Missing attributes. Err: {e}')
    except Exception as e:
        raise RuntimeError(f'FATAL ERROR: Cannot Make MASTER PATH. Err: {e}')


if __name__ == '__main__':
    main()
