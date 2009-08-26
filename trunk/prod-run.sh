#!/bin/sh
ulimit -v $((512*1024))
cd DJabberd
exec ./djabberd --conffile ../../djabberd.conf 2>&1
