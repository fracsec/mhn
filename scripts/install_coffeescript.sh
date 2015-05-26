#!/bin/bash

wget http://nodejs.org/dist/v0.8.20/node-v0.8.20.tar.gz
mkdir nodejs
tar xf node-v0.8.20.tar.gz -C ~/nodejs && cd ~/nodejs/node-v0.8.20
./configure
make
make install

npm install -g coffee-script
