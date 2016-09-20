#!/bin/bash

echo "Installing Ansible..."
apt-get install -y apt-transport-https libssl-dev libffi-dev python-dev build-essential python-setuptools
easy_install pip
pip install -U setuptools cryptography markupsafe
pip install -U ansible boto
