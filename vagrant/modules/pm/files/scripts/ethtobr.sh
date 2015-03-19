#!/bin/bash

ETHEXT=$1

ip -o addr show dev $ETHEXT | awk '!/^[0-9]*: ?lo|link\/ether/ {print $4}' | while read ipeth; do
  ip a del $ipeth dev $ETHEXT
  ip a add $ipeth dev brex
done