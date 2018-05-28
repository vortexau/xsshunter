#!/usr/bin/env bash

cd /xsshunter/api
./apiserver.py &
cd /xsshunter/gui
./guiserver.py &
