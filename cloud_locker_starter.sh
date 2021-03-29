#!/usr/bin/sh

echo "Install linux dependencies [git, python, pip]"
if [ -z "$(command -v git)" ]; then sudo pacman -S git; fi
if [ -z "$(command -v python)" ]; then sudo pacman -S python; fi
if [ -z "$(command -v pip)" ]; then sudo pacman -S python-pip; fi

echo "Install python dependencies [typer]"
if [ -z $(python -c "import typer") ]; then pip install --user typer; fi

CLOUD_LOCKERS_PATH="~/git/swissinnovationlab/cloud_lockers"
read -p "Enter CLOUD_LOKERS_PATH [$CLOUD_LOCKERS_PATH]: " path
if [ ! -z "$path" ]; then
  CLOUD_LOCKERS_PATH=$path
fi
echo "Creating dir" ${CLOUD_LOCKERS_PATH}
mkdir -p $(eval echo ${CLOUD_LOCKERS_PATH})

LOCAL_MANAGER_PATH="${CLOUD_LOCKERS_PATH}/python_utils_cloud_locker_manager"
REMOTE_MANAGER_PATH="https://github.com/swissinnovationlab/python_utils_cloud_locker_manager"
echo "Cloning manager and common"
if [ ! -d "$(eval echo ${LOCAL_MANAGER_PATH})" ]; then
  git clone $(eval echo ${REMOTE_MANAGER_PATH} ${LOCAL_MANAGER_PATH})
  chmod +x $(eval echo ${LOCAL_MANAGER_PATH})/src/manager.py
fi

MANAGER_SHELL_PATH="export PATH=\$PATH:${LOCAL_MANAGER_PATH}/src"
CLOUD_LOCKERS_ENV="${CLOUD_LOCKERS_PATH}/cloud_lockers.env"
echo "Setting up PATH in " ${CLOUD_LOCKERS_ENV} 
if ! grep -Fxq "${MANAGER_SHELL_PATH}" $(eval echo ${CLOUD_LOCKERS_ENV}); then
  echo ${MANAGER_SHELL_PATH} >> $(eval echo ${CLOUD_LOCKERS_ENV})
fi

echo
echo "Finished."
echo "Put next line in your shell environment:"
echo "    source ${CLOUD_LOCKERS_ENV}"
echo "After that restart your terminal and run:"
echo "    manager.py install"
