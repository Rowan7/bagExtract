import os
from typing import Optional

CORRECTIONS = {
    'pearce_': 'frognall_',
    'peasgood_': 'frognall_',
    'gs_': 'ely_',
    'engine_farm_': 'ely_',
    'beet_': 'sugarbeet_',
    'leak_': 'leek_',
    'letuce_': 'lettuce_',
    'none_none_auto_none_': 'wheat_papley_',
    'RGBIRD2': '_RGBIRD_',
}

REMOVE = [
    '_none',
    'none_',
    '_leak',
    '_letuce',
    '_beet',
]


def correct_filename(filename: str) -> Optional[str]:
    """
    correct a filename

    return:
        corrected filename or None if filename is correct
    """

    original_filename = filename

    for keyword, correction in CORRECTIONS.items():
        filename.replace(keyword, correction)

    for keyword in REMOVE:
        filename.replace(keyword, '')

    if filename != original_filename:
        return filename
    return None


def run(directory: str):
    """
    format bags and tidy them before they are used elsewhere
    """

    with os.scandir(directory) as it:
        for entry in it:
            if entry.is_file():
                if new_filename := correct_filename(entry.name):
                    print(f'correcting {entry.name} to {new_filename}')
                    os.rename(entry.path, os.path.join(directory, new_filename))
            else:
                print(f'ignoring dir {entry.path}')
