#!/usr/bin/sh

if [[ $EUID -eq 0 ]]; then
   echo "This script must be run as user" 
   exit 1
fi

echo "Install linux dependencies [git, python, pip]"
if [ -z "$(command -v git)" ]; then sudo pacman -S git; fi
if [ -z "$(command -v python)" ]; then sudo pacman -S python; fi
if [ -z "$(command -v pip)" ]; then sudo pacman -S python-pip; fi

echo "Install python dependencies [typer]"
if [ -z $(python -c "import typer") ]; then pip install --user typer; fi
if [ -z $(python -c "import git") ]; then pip install --user gitpython; fi

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
  if [ -z "$TAG" ]
  then
    git clone $(eval echo ${REMOTE_MANAGER_PATH} ${LOCAL_MANAGER_PATH})
  else
    git clone --branch $TAG $(eval echo ${REMOTE_MANAGER_PATH} ${LOCAL_MANAGER_PATH})
  fi
  chmod +x $(eval echo ${LOCAL_MANAGER_PATH})/src/manager.py
fi

EXPORT_CLOUD_LOCKERS_PATH="export CLOUD_LOCKERS_PATH=${CLOUD_LOCKERS_PATH}"
EXPORT_MANAGER_PATH="export PATH=\$PATH:\$CLOUD_LOCKERS_PATH/${MANAGER_REPO_NAME}/src"
EXPORT_DISPLAY="export DISPLAY=:0"
CLOUD_LOCKERS_ENV="${CLOUD_LOCKERS_PATH}/cloud_lockers.env"
echo "Setting up PATH in " ${CLOUD_LOCKERS_ENV} 
if [ ! -f "$CLOUD_LOCKERS_ENV" ]; then
  touch $(eval echo ${CLOUD_LOCKERS_ENV})
fi
if ! grep -Fxq "${EXPORT_CLOUD_LOCKERS_PATH}" $(eval echo ${CLOUD_LOCKERS_ENV}); then
  echo ${EXPORT_CLOUD_LOCKERS_PATH} >> $(eval echo ${CLOUD_LOCKERS_ENV})
fi
if ! grep -Fxq "${EXPORT_MANAGER_PATH}" $(eval echo ${CLOUD_LOCKERS_ENV}); then
  echo ${EXPORT_MANAGER_PATH} >> $(eval echo ${CLOUD_LOCKERS_ENV})
fi
if ! grep -Fxq "${EXPORT_DISPLAY}" $(eval echo ${CLOUD_LOCKERS_ENV}); then
  echo ${EXPORT_DISPLAY} >> $(eval echo ${CLOUD_LOCKERS_ENV})
fi

echo
echo "Finished."
echo "Put next line in your shell environment:"
echo "    source ${CLOUD_LOCKERS_ENV}"
echo "After that restart your terminal and run:"
echo "    manager.py --env-prod install"
echo "You can add password ENV variable to ${CLOUD_LOCKERS_ENV}"
echo "    export CLOUD_LOCKERS_PASSWORD=\"\""
