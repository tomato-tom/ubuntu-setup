#!/bin/bash

# Node.js setup
# https://nodejs.org/en/download/package-manager

# installs nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# During the above installation, necessary settings are added to .bachrc,
# so that it actually reflects them.
source ~/.bashrc

echo "download and install Node.js"
nvm install 20

echo "verifies the right Node.js version is in the environment"
node -v # should print `v20.17.0`

echo "verifies the right npm version is in the environment"
npm -v # should print `10.8.2`

# `npm`: Tools for installing and managing Node.js libraries and modules.
# `nvm`: Tools to manage and switch between multiple Node.js versions.

