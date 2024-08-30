#!/bin/bash -e

# 
sudo apt-get install build-essential libbz2-dev libdb-dev   libreadline-dev libffi-dev libgdbm-dev liblzma-dev   libncursesw5-dev libsqlite3-dev libssl-dev   zlib1g-dev uuid-dev tk-dev -y
sudo apt-get install python3.12-venv -y
sudo apt-get install xclip -y


# python venv
VENV_DIR="path/to/project"
cd $VENV_DIR

# create python venv
python3 -m venv venv
source ./venv/bin/activate
echo "venv python version:"
python3 -V

python3 -m pip install --upgrade pip
pip install -r requirements.txt 
pip freeze

deactivate
echo "hosts python version:"
python3 -V
