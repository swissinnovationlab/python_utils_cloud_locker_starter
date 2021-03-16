#!/usr/bin/sh

CLOUD_LOCKERS_PATH="~/git/swissinnovationlab/cloud_lockers"

LOCAL_COMMON_PATH="${CLOUD_LOCKERS_PATH}/python_common_cloud_locker"
REMOTE_COMMON_PATH="https://github.com/swissinnovationlab/python_common_cloud_locker"

LOCAL_MANAGER_PATH="${CLOUD_LOCKERS_PATH}/python_utils_cloud_locker_manager"
REMOTE_MANAGER_PATH="https://github.com/swissinnovationlab/python_utils_cloud_locker_manager"

MANAGER_SHELL_PATH="export PATH=\$PATH:${LOCAL_MANAGER_PATH}/src"
MANAGER_PYTHON_PATH="export PYTHONPATH=\$PYTHONPATH:${LOCAL_MANAGER_PATH}/src"
COMMON_PYTHON_PATH="export PYTHONPATH=\$PYTHONPATH:${LOCAL_COMMON_PATH}/common_cloud_locker"

SHELL_CONFIG_FILE="~/.bashrc"

echo "Creating dir" ${CLOUD_LOCKERS_PATH}
mkdir -p $(eval echo ${CLOUD_LOCKERS_PATH})

echo "Checking linux dependencies" "[git, python, pip]"
if [ -z "$(command -v git)" ]; then sudo pacman -S git; fi
if [ -z "$(command -v python)" ]; then sudo pacman -S python; fi
if [ -z "$(command -v pip)" ]; then sudo pacman -S python-pip; fi

echo "Cloning manager and common"
if [ ! -d "$(eval echo ${LOCAL_MANAGER_PATH})" ]; then
  git clone $(eval echo ${REMOTE_MANAGER_PATH} ${LOCAL_MANAGER_PATH})
  chmod +x $(eval echo ${LOCAL_MANAGER_PATH})/src/manager.py
fi
if [ ! -d "$(eval echo ${LOCAL_COMMON_PATH})" ]; then
  git clone $(eval echo ${REMOTE_COMMON_PATH} ${LOCAL_COMMON_PATH})
fi

echo "Setting up PATH and PYTHONPATH in " ${SHELL_CONFIG_FILE} 
if ! grep -Fxq "${MANAGER_SHELL_PATH}" $(eval echo ${SHELL_CONFIG_FILE}); then
  echo ${MANAGER_SHELL_PATH} >> $(eval echo ${SHELL_CONFIG_FILE})
fi
if ! grep -Fxq "${MANAGER_PYTHON_PATH}" $(eval echo ${SHELL_CONFIG_FILE}); then
  echo ${MANAGER_PYTHON_PATH} >> $(eval echo ${SHELL_CONFIG_FILE})
fi
if ! grep -Fxq "${COMMON_PYTHON_PATH}" $(eval echo ${SHELL_CONFIG_FILE}); then
  echo ${COMMON_PYTHON_PATH} >> $(eval echo ${SHELL_CONFIG_FILE})
fi

echo
echo "Finished. Run following command for futher installation:"
echo "  source ${SHELL_CONFIG_FILE}"
echo "  manager.py install"
