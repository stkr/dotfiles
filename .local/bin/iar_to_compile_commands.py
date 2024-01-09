#!/usr/bin/env python

import json
import os
import pathlib
import argparse
import logging
import shutil
import subprocess

def find_iarbuild():
    if shutil.which("iarbuild") is not None:
        return "iarbuild"

    paths = [pathlib.Path(os.environ["USERPROFILE"]).joinpath(
        "AppData/Roaming/IAR Systems/Embedded Workbench 9.1/common/bin/iarbuild.exe")]
    for p in paths:
        if p.is_file():
            return p
    raise ValueError("Unable to determine location of iarbuild")


def create_compile_commands(iarbuild, project_path, output):
    subprocess.run([iarbuild, project_path, "-jsondb", "debug", "-output", output])

def cleanup_compile_commands(compile_commands):
    with open(compile_commands, "r") as fp:
        contents = json.load(fp)

    # IAR puts a "type" in the dictionary. Clangd cannot deal with additional keys in the
    # dictionary, so we need to remove it.
    for item in contents:
        if "type" in item:
            del (item["type"])

    # IAR also has a "header" kind of element which is not a file. Remove those which are not a
    # file also.
    contents = list(filter(lambda i: "file" in i, contents))

    with open(compile_commands, "w") as fp:
        json.dump(contents, fp, indent=4)


def main():
    logging.basicConfig(level=logging.INFO, format='%(message)s')
    parser = argparse.ArgumentParser(
        description="Create compile_commands.json file from IAR project file using iarbuild.")
    parser.add_argument("-p", "--project_path", required=True, type=pathlib.Path,
                        help="Path of the project file to convert.")
    parser.add_argument("--output", type=pathlib.Path, default="compile_commands.json",
                        help="Output path for the compile commands file.")
    parser.add_argument("--iarbuild", type=pathlib.Path, help="Path to the iarbuild executable")
    args = parser.parse_args()
    if args.iarbuild is None:
        args.iarbuild = find_iarbuild()
    create_compile_commands(args.iarbuild, args.project_path, args.output)
    cleanup_compile_commands(args.output)


if __name__ == "__main__":
    main()
