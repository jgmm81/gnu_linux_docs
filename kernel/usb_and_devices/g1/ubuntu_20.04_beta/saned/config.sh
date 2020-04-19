#!/bin/bash

#systemctl stop colord.service

RUN_AS_USER=saned
usermod -a -G lp saned

date >> /opt/saned/date.log

#RUN_AS_USER=colord
#usermod -a -G lp colord

