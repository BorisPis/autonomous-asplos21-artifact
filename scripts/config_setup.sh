#!/bin/bash

source ./TestSuite/Conf/config_dante732.sh
./TestSuite/Conf/setup.sh

ssh $loader1 "source ./TestSuite/Conf/config_danger38.sh; ./TestSuite/Scripts/nvmet_file.sh;"
