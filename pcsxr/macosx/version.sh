#!/bin/bash

VER=`git rev-list --count HEAD`
#VER=`expr ${VER} + 0`
echo $VER
