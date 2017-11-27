#!/bin/bash
#npm install
set -e
if [ ! -f ./build/compiled.log ];then
truffle compile
echo '' >> ./contracts/SafeMath.sol 
echo '' >> ./contracts/metadata.sol 
truffle compile
touch ./build/compiled.log
fi