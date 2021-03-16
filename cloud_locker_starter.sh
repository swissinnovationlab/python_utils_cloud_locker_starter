#!/usr/bin/bash

CLOUD_LOCKERS_PATH="${HOME}/git/swissinnovationlab/cloud_lockers"
LOCAL_MANAGER_PATH="${CLOUD_LOCKERS_PATH}/python_utils_cloud_locker_manager"
REMOTE_MANAGER_PATH="https://github.com/swissinnovationlab/python_utils_cloud_locker_manager"
LOCAL_MANAGER_PATH_LINE="export PATH=\$PATH:${LOCAL_MANAGER_PATH}/src"
SHELL_CONFIG_FILE="${HOME}/.bashrc"

echo "Creating dir"
mkdir -p ${CLOUD_LOCKERS_PATH}

echo "Checking linux dependencies"
if [ -z "$(command -v git)" ]; then sudo pacman -S git; fi
if [ -z "$(command -v python)" ]; then sudo pacman -S python; fi
if [ -z "$(command -v pip)" ]; then sudo pacman -S python-pip; fi

echo "Cloning manager"
if [ ! -d "${LOCAL_MANAGER_PATH}" ]; then
    git clone ${REMOTE_MANAGER_PATH} ${LOCAL_MANAGER_PATH}
    chmod +x ${LOCAL_MANAGER_PATH}/src/manager.py
fi

echo "Setting up PATH"
if ! grep -Fxq "${LOCAL_MANAGER_PATH_LINE}" ${SHELL_CONFIG_FILE}; then
  echo ${LOCAL_MANAGER_PATH_LINE} >> ${SHELL_CONFIG_FILE}
  source ${SHELL_CONFIG_FILE}
fi

echo
echo "Finished. Run following command for futher installation:"
echo "  source ${SHELL_CONFIG_FILE}"
echo "  manager.py install"
