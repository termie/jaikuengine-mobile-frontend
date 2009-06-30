#!/bin/sh
ulimit -v $((512*1024))
cd DJabberd
exec ./djabberd --conffile ../djabberdjabberdd.conf 2>&1
