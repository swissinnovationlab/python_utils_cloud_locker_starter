#!/usr/bin/sh

CLOUD_LOCKERS_PATH="~/git/swissinnovationlab/cloud_lockers"

LOCAL_MANAGER_PATH="${CLOUD_LOCKERS_PATH}/python_utils_cloud_locker_manager"
REMOTE_MANAGER_PATH="https://github.com/swissinnovationlab/python_utils_cloud_locker_manager"

MANAGER_SHELL_PATH="export PATH=\$PATH:${LOCAL_MANAGER_PATH}/src"

SHELL_CONFIG_FILE="~/.bashrc"

echo "Creating dir" ${CLOUD_LOCKERS_PATH}
mkdir -p $(eval echo ${CLOUD_LOCKERS_PATH})

echo "Checking linux dependencies [git, python, pip]"
if [ -z "$(command -v git)" ]; then sudo pacman -S git; fi
if [ -z "$(command -v python)" ]; then sudo pacman -S python; fi
if [ -z "$(command -v pip)" ]; then sudo pacman -S python-pip; fi

echo "Install python dependencies [typer]"
if [ -z $(python -c "import typer") ]; then pip install --user typer; fi

echo "Cloning manager and common"
if [ ! -d "$(eval echo ${LOCAL_MANAGER_PATH})" ]; then
  git clone $(eval echo ${REMOTE_MANAGER_PATH} ${LOCAL_MANAGER_PATH})
  chmod +x $(eval echo ${LOCAL_MANAGER_PATH})/src/manager.py
fi

echo "Setting up PATH and PYTHONPATH in " ${SHELL_CONFIG_FILE} 
if ! grep -Fxq "${MANAGER_SHELL_PATH}" $(eval echo ${SHELL_CONFIG_FILE}); then
  echo ${MANAGER_SHELL_PATH} >> $(eval echo ${SHELL_CONFIG_FILE})
fi

echo
echo "Finished. Run following command for futher installation:"
echo "  source ${SHELL_CONFIG_FILE}"
echo "  manager.py install"
