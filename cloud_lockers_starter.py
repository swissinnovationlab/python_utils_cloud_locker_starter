#!/usr/bin/env python3

import os
import shutil
import importlib
import pip
import pty
from subprocess import Popen
import select
from time import sleep
import sys
from getpass import getpass
import unittest

linux_dependencies = {
    "git": "git",
    "python": "python",
    "pip": "python-pip",
}

python_dependencies = {
    "typer": "typer",
    "git": "gitpython",
}

linux_password = None

variables = {
    "CLOUD_LOCKERS_PATH": "~/git/swissinnovationlab/cloud_lockers",
    "CLOUD_LOCKERS_PASSWORD": "",
    "CLOUD_LOCKERS_PROD": "true"
}

static_variables = {
    "PATH": "$PATH:$CLOUD_LOCKERS_PATH/python_utils_cloud_locker_manager/src",
    "DISPLAY": ":0"
}


class Base:
    # Foreground:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    # Formatting
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    # End colored text
    END = '\033[0m'
    NC = '\x1b[0m'  # No Color


def run_bash_cmd(cmd, echo=False, interaction={}, return_lines=True, return_code=False, cr_as_newline=False):
    if echo:
        print("CMD:", cmd)
    master_fd, slave_fd = pty.openpty()
    line = ""
    lines = []
    with Popen(cmd, shell=True, preexec_fn=os.setsid, stdin=slave_fd, stdout=slave_fd, stderr=slave_fd, universal_newlines=True) as p:
        while p.poll() is None:
            r, w, e = select.select([sys.stdin, master_fd], [], [], 0.01)
            if master_fd in r:
                o = os.read(master_fd, 10240).decode("UTF-8")
                if o:
                    for c in o:
                        if cr_as_newline and c == "\r":
                            c = "\n"
                        if c == "\n":
                            if line and line not in interaction.values():
                                clean = line.strip().split('\r')[-1]
                                lines.append(clean)
                                if echo:
                                    print("STD:", line)
                            line = ""
                        else:
                            line += c
            if line:  # pass password to prompt
                for key in interaction:
                    if key in line:
                        if echo:
                            print("PMT:", line)
                        sleep(1)
                        os.write(master_fd, ("%s" %
                                             (interaction[key])).encode())
                        os.write(master_fd, "\r\n".encode())
                        line = ""
        if line:
            clean = line.strip().split('\r')[-1]
            lines.append(clean)

    os.close(master_fd)
    os.close(slave_fd)

    if return_lines and return_code:
        return lines, p.returncode
    elif return_code:
        return p.returncode
    else:
        return lines


def is_root():
    return os.geteuid() == 0

##### LINUX start #####


def is_exe(cmd):
    return shutil.which(cmd) is not None


def get_sudo_password():
    global linux_password
    if linux_password is None:
        linux_password = getpass("Enter [sudo] password: ")
    return linux_password


def install_pacman_package(name):
    cmd = "sudo pacman -S %s" % (name)
    interaction = {
        "[sudo]": get_sudo_password(),
        "Proceed with installation": "Y",
        "are in conflict. Remove": "y",
    }
    return run_bash_cmd(cmd, echo=True, interaction=interaction, return_lines=False, return_code=True) == 0


def remove_pacman_package(name):
    cmd = "sudo pacman -R %s" % (name)
    interaction = {
        "[sudo]": get_sudo_password(),
        "Do you want to remove these packages": "Y",
        "are in conflict. Remove": "y",
    }
    return run_bash_cmd(cmd, echo=True, interaction=interaction, return_lines=False, return_code=True) == 0

##### LINUX end #####
##### PYTHON start #####


def is_module_installed(name):
    return importlib.util.find_spec(name) is not None


def install_module(name):
    return pip.main(['install', name]) == 0


def remove_module(name):
    return pip.main(['uninstall', name, '--yes']) == 0

##### PYTHON end #####
##### VARIABLES start #####


def get_full_path(path):
    return os.path.realpath(os.path.expanduser(path))


def check_if_path_exists(path):
    return os.path.exists(get_full_path(path))


def create_path(path):
    os.makedirs(get_full_path(path), exist_ok=True)


def remove_path(path):
    if check_if_path_exists(path):
        shutil.rmtree(get_full_path(path))


def remove_file(path):
    os.remove(get_full_path(path))


def write_lines_to_file(lines, filename):
    filename = get_full_path(filename)
    with open(filename, 'w') as f:
        f.write("\n".join(lines))


def read_lines_from_file(filename):
    filename = get_full_path(filename)
    with open(filename, 'r') as f:
        lines = f.read().splitlines()
    return lines


def change_variables():
    global variables
    for key in variables:
        value = input("%s [\"%s\"]: " % (key, variables[key]))
        if value:
            variables[key] = value


def is_line_in_file(line, filename):
    lines = read_lines_from_file(filename)
    for fline in lines:
        if line in fline:
            return True
    return False


def insert_line_in_file(line, filename):
    lines = read_lines_from_file(filename)
    lines.append(line)
    write_lines_to_file(lines, filename)


def remove_line_from_file(line, filename):
    lines = read_lines_from_file(filename)
    lines_to_remove = []
    for i in range(len(lines)):
        if line in lines[i]:
            lines_to_remove.append(i)
    lines_to_remove.reverse()
    print(lines_to_remove)
    for i in lines_to_remove:
        lines.pop(i)
    write_lines_to_file(lines, filename)
    print(lines)


def get_env_file_path():
    return "%s/%s" % (variables['CLOUD_LOCKERS_PATH'], "cloud_lockers.env")

##### VARIABLES end #####
##### GIT start #####

def clone_git_repo(repo, path):
    cmd = "git clone %s %s" % (repo, path)
    return os.system(cmd)

##### GIT end #####
##### TESTS start #####


class Tests(unittest.TestCase):

    def test_linux(self):
        name = "cmatrix"
        self.assertFalse(is_exe(name))
        self.assertTrue(install_pacman_package(name))
        self.assertTrue(is_exe(name))
        self.assertTrue(remove_pacman_package(name))
        self.assertFalse(is_exe(name))

    def test_python(self):
        name = "snakegame"
        self.assertFalse(is_module_installed(name))
        self.assertTrue(install_module(name))
        self.assertTrue(is_module_installed(name))
        self.assertTrue(remove_module(name))
        self.assertFalse(is_module_installed(name))

    def test_paths(self):
        path = "/tmp/test_path1/test_path2/test_path3"
        filename = "test.txt"
        path_and_filename = "%s/%s" % (path, filename)
        self.assertFalse(check_if_path_exists(path))
        create_path(path)
        self.assertTrue(check_if_path_exists(path))
        self.assertFalse(check_if_path_exists(path_and_filename))
        write_lines_to_file(["test", "123"], path_and_filename)
        self.assertTrue(check_if_path_exists(path_and_filename))
        self.assertFalse(is_line_in_file("inside", path_and_filename))
        write_lines_to_file(["no touching", "inside", "dont touch"], path_and_filename)
        self.assertTrue(is_line_in_file("inside", path_and_filename))
        remove_line_from_file("inside", path_and_filename)
        self.assertFalse(is_line_in_file("inside", path_and_filename))
        remove_file(path_and_filename)
        self.assertFalse(check_if_path_exists(path_and_filename))
        remove_path(path)
        self.assertFalse(check_if_path_exists(path))


def tests():
    suite = unittest.TestSuite()
    suite.addTest(Tests('test_linux'))
    suite.addTest(Tests('test_python'))
    suite.addTest(Tests('test_paths'))
    unittest.TextTestRunner().run(suite)

##### TESTS end #####
##### INSTALLER start #####


class Installer(unittest.TestCase):

    def install_linux(self):
        for key, value in linux_dependencies.items():
            try:
                self.assertTrue(is_exe(key))
            except:
                print("##### Installing %s #####" % (key))
                self.assertTrue(install_pacman_package(value))
                self.assertTrue(is_exe(key))

    def install_python(self):
        for key, value in python_dependencies.items():
            try:
                self.assertTrue(is_module_installed(key))
            except:
                print("##### Installing %s #####" % (key))
                self.assertTrue(install_module(value))
                self.assertTrue(is_module_installed(key))

    def install_variables(self):
        #change_variables()
        path = variables["CLOUD_LOCKERS_PATH"]
        filename = "cloud_lockers.env"
        path_and_filename = "%s/%s" % (path, filename)
        try:
            self.assertTrue(check_if_path_exists(path_and_filename))
        except:
            print("##### Creating %s #####" % (path_and_filename))
            create_path(path)
            write_lines_to_file([], path_and_filename)
            self.assertTrue(check_if_path_exists(path_and_filename))
        for key, value in variables.items():
            try:
                self.assertTrue(is_line_in_file(key, path_and_filename))
            except:
                insert_line_in_file("export %s=%s" % (key, value), path_and_filename)
                self.assertTrue(is_line_in_file(key, path_and_filename))
        for key, value in static_variables.items():
            try:
                self.assertTrue(is_line_in_file(key, path_and_filename))
            except:
                insert_line_in_file("export %s=%s" % (key, value), path_and_filename)
                self.assertTrue(is_line_in_file(key, path_and_filename))
                
    def install_git(self):
        path = variables["CLOUD_LOCKERS_PATH"]
        repo_base = "https://github.com/swissinnovationlab"
        name = "python_utils_cloud_locker_manager"
        path_and_name = "%s/%s" % (path, name)
        repo_base_and_name = "%s/%s.git" % (repo_base, name)
        try:
            self.assertTrue(check_if_path_exists, path)
        except:
            create_path(path)
            self.assertTrue(check_if_path_exists, path)
        try:
            self.assertTrue(check_if_path_exists(path_and_name))
        except:
            clone_git_repo(repo_base_and_name, path_and_name)
            self.assertTrue(check_if_path_exists(path_and_name))

def main():
    suite = unittest.TestSuite()
    suite.addTest(Installer('install_linux'))
    suite.addTest(Installer('install_python'))
    suite.addTest(Installer('install_variables'))
    suite.addTest(Installer('install_git'))
    unittest.TextTestRunner().run(suite)

##### INSTALLER end #####


if __name__ == "__main__" and not sys.flags.inspect:
    print("Starting installer")
    change_variables()
    main()
    print("Installation finished")
    path = variables["CLOUD_LOCKERS_PATH"]
    filename = "cloud_lockers.env"
    path_and_filename = "%s/%s" % (path, filename)
    line = "source %s" % (path_and_filename)
    bashrc = "~/.bashrc"
    if not is_line_in_file(line, bashrc):
        anwser = input("Do you want to add source to .bashrc [Y/n]: ")
        if anwser in ["Y", ""]:
            insert_line_in_file(line, bashrc)