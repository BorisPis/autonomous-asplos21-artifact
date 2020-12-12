#!/bin/bash

if lscpu | grep -q aes
then
	echo AES-NI OK
else
	echo AES-NI is missing
	exit -1
fi

if lscpu | grep -q erms
then
	echo ERMS OK
else
	echo ERMS is missing
	exit -1
fi

exit 0
