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

MANAGER_REPO_NAME="python_utils_cloud_locker_manager"
LOCAL_MANAGER_PATH="${CLOUD_LOCKERS_PATH}/${MANAGER_REPO_NAME}"
REMOTE_MANAGER_PATH="https://github.com/swissinnovationlab/${MANAGER_REPO_NAME}"
echo "Cloning manager and common"
if [ ! -d "$(eval echo ${LOCAL_MANAGER_PATH})" ]; then
  git clone $(eval echo ${REMOTE_MANAGER_PATH} ${LOCAL_MANAGER_PATH})
  chmod +x $(eval echo ${LOCAL_MANAGER_PATH})/src/manager.py
fi

EXPORT_CLOUD_LOCKERS_PATH="export CLOUD_LOCKERS_PATH=${CLOUD_LOCKERS_PATH}"
EXPORT_MANAGER_PATH="export PATH=\$PATH:\$CLOUD_LOCKERS_PATH/${MANAGER_REPO_NAME}/src"
CLOUD_LOCKERS_ENV="${CLOUD_LOCKERS_PATH}/cloud_lockers.env"
echo "Setting up PATH in " ${CLOUD_LOCKERS_ENV} 
if [ ! -f "$CLOUD_LOCKERS_ENV" ]; then
  touch $CLOUD_LOCKERS_ENV
fi
if ! grep -Fxq "${EXPORT_CLOUD_LOCKERS_PATH}" $(eval echo ${CLOUD_LOCKERS_ENV}); then
  echo ${EXPORT_CLOUD_LOCKERS_PATH} >> $(eval echo ${CLOUD_LOCKERS_ENV})
fi
if ! grep -Fxq "${EXPORT_MANAGER_PATH}" $(eval echo ${CLOUD_LOCKERS_ENV}); then
  echo ${EXPORT_MANAGER_PATH} >> $(eval echo ${CLOUD_LOCKERS_ENV})
fi

echo
echo "Finished."
echo "Put next line in your shell environment:"
echo "    source ${CLOUD_LOCKERS_ENV}"
echo "After that restart your terminal and run:"
echo "    manager.py install"
