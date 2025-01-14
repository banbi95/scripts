#!/bin/bash
#
# remove temp files under /tmp directory priodically
#
#
# author: Devin
# date: 2023-03-09
# check if dir is provided
TEMP_DIR=/tmp
find $TEMP_DIR -type f -mtime +7 -exec rm -rf {} \;
echo "$(date):clean temp files done"

