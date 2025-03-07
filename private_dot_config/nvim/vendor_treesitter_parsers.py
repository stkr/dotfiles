import json
import pathlib

import re
import shutil
import subprocess
import logging

import luadata


logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

nvim_treesitter_path = pathlib.Path.home().joinpath(".local/share/nvim/lazy/nvim-treesitter")

destination_path = pathlib.Path("tree-sitter-source").absolute()
wanted_parsers = [
    "bash", "c", "c_sharp", "cmake", "cpp", "css", "csv", "devicetree",
    "dockerfile", "dot", "doxygen", "dtd", "fish", "gdscript", "git_config", "git_rebase",
    "gitattributes", "gitcommit", "gitignore", "godot_resource", "gpg", "html", "http",
    "java", "javascript", "json5", "kconfig", "kotlin", "lua", "luap", "make", "markdown",
    "markdown_inline", "matlab", "ninja", "objdump", "pem", "perl", "proto", "python",
    "regex", "rst", "ruby", "rust", "sql", "ssh_config", "toml", "verilog",
    "vim", "vimdoc", "xml", "yaml",
]


def read_parser_info():
    parsers_path = nvim_treesitter_path.joinpath("lua/nvim-treesitter/parsers.lua")
    logging.info(f"Loading parser info from [{str(parsers_path)}]")
    info = {}
    with open(parsers_path, "r") as fp:
        parser_name = None
        info_str = None
        for line in fp:

            match = re.search(r"^\s*list\.([\w]*)", line)
            if match is not None:
                parser_name = match.group(1)
                info_str = "{"
                continue

            if line.startswith("}") and parser_name is not None:
                info_str += line
                info[parser_name] = luadata.unserialize(info_str)
                parser_name = None
                info_str = None
                continue

            if parser_name is not None:
                info_str += line
    return info



def add_parser_revision(info):
    with open(nvim_treesitter_path.joinpath("lockfile.json"), "r") as fp:
        revisions = json.load(fp)
    for parser_name in revisions.keys():
        info[parser_name]["install_info"]["revision"] = revisions[parser_name]["revision"]


def download_parsers(info):
    logging.info(f"Downloading parsers to [{str(destination_path)}]")

    destination_path.mkdir(parents=True, exist_ok=True)

    cloned_urls = set()
    for parser_name in wanted_parsers:
        url = info[parser_name]['install_info']['url']
        revision = info[parser_name]['install_info']['revision']
        parser_dir = pathlib.Path(re.match(r".*/(.*)", url).group(1))

        if url not in cloned_urls:
            subprocess.run(["git", "clone", url], cwd=destination_path, check=True)
            cloned_urls.add(url)
        subprocess.run(["git", "checkout", revision], cwd=destination_path.joinpath(parser_dir), check=True)

    for parser_name in wanted_parsers:
        url = info[parser_name]['install_info']['url']
        parser_dir = pathlib.Path(re.match(r".*/(.*)", url).group(1))
        shutil.rmtree(destination_path.joinpath(parser_dir).joinpath(".git"))

    #
    # with (tempfile.TemporaryDirectory() as tmpdirname):
    #     print('Created temporary directory', tmpdirname)
    #     tmpdir = pathlib.Path(tmpdirname)
    #
    #     cloned_urls = set()
    #     for parser_name in wanted_parsers:
    #         url = info[parser_name]['install_info']['url']
    #         revision = info[parser_name]['install_info']['revision']
    #         files = info[parser_name]['install_info']['files']
    #         parser_dir = pathlib.Path(re.match(r".*/(.*)", url).group(1))
    #
    #         if url not in cloned_urls:
    #             subprocess.run(["git", "clone", url], cwd=tmpdir, check=True)
    #             cloned_urls.add(url)
    #
    #         subprocess.run(["git", "checkout", revision], cwd=tmpdir.joinpath(parser_dir), check=True)
    #
    #         for f in files:
    #             relative_path = parser_dir
    #             if 'location' in info[parser_name]['install_info']:
    #                 relative_path = relative_path.joinpath(info[parser_name]['install_info']['location'])

    #             relative_path = relative_path.joinpath(f)
    #
    #             src = tmpdir.joinpath(relative_path)
    #             dst = destination_path.joinpath(relative_path)
    #             dst.parent.mkdir(parents=True, exist_ok=True)
    #             shutil.copy(src, dst)


def main():
    info = read_parser_info()
    add_parser_revision(info)
    download_parsers(info)



main()

