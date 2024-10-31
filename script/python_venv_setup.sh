#!/bin/bash -e

sudo apt-get update
sudo apt-get install build-essential libbz2-dev libdb-dev   libreadline-dev libffi-dev libgdbm-dev liblzma-dev   libncursesw5-dev libsqlite3-dev libssl-dev   zlib1g-dev uuid-dev tk-dev -y
sudo apt-get install python3.12-venv -y

python -V

# python venv
VENV_DIR="path/to/project"
cd $VENV_DIR

# create python venv
python -m venv venv
source ./venv/bin/activate

python -m pip install --upgrade pip
pip install -r requirements.txt 
pip freeze

deactivate
