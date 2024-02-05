#!/bin/bash

echo $((($(date +%s) - $(date +%s -r "/tmp/speed.txt")) / 60))
