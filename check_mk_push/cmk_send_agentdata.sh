#!/bin/bash
# +------------------------------------------------------------------+
# |             ____ _               _        __  __ _  __           |
# |            / ___| |__   ___  ___| | __   |  \/  | |/ /           |
# |           | |   | '_ \ / _ \/ __| |/ /   | |\/| | ' /            |
# |           | |___| | | |  __/ (__|   <    | |  | | . \            |
# |            \____|_| |_|\___|\___|_|\_\___|_|  |_|_|\_\           |
# |                                                                  |
# | Copyright Jonas Nickl 2016             development@ichalsroot.de |
# +------------------------------------------------------------------+
#
# This file is an addon for Check_MK.
# The official homepage for this check is at https://blog.ichalsroot.de
#
# check_mk is free software;  you can redistribute it and/or modify it
# under the  terms of the  GNU General Public License  as published by
# the Free Software Foundation in version 2.  check_mk is  distributed
# in the hope that it will be useful, but WITHOUT ANY WARRANTY;  with-
# out even the implied warranty of  MERCHANTABILITY  or  FITNESS FOR A
# PARTICULAR PURPOSE. See the  GNU General Public License for more de-
# tails. You should have  received  a copy of the  GNU  General Public
# License along with GNU Make; see the file  COPYING.  If  not,  write
# to the Free Software Foundation, Inc., 51 Franklin St,  Fifth Floor,
# Boston, MA 02110-1301 USA.

HOSTNAME=`hostname`
MK_CONFDIR=/etc/check_mk

## DEBUG Level (BOOL)
if [ "$1" == "--debug" ] ; then DEBUG="1"; fi

be_done()
{
    echo "RC=$STATUS"
    ## bad returncode if status nok
    if [ "$STATUS" != "OK" ]; then exit 1; fi
}

validate()
## Verify config dir exists and that the config file exists
{
    if [ -d $MK_CONFDIR ]                                    && 
       [ -r $MK_CONFDIR/cmkserver.cfg ]                      &&
         OMDURL=`grep OMDURL      $MK_CONFDIR/cmkserver.cfg | cut -f2 -d\= | sed 's/"//g'` &&
         OMDUSER=`grep OMDUSER    $MK_CONFDIR/cmkserver.cfg | cut -f2 -d\= | sed 's/"//g'` &&
         OMDPASS=`grep OMDPASS    $MK_CONFDIR/cmkserver.cfg | cut -f2 -d\= | sed 's/"//g'`    
    then
        export OMDURL OMDUSER OMDPASS
    else
        echo "Please set OMDURL, OMDUSER and OMDPASS in"
        echo "$MK_CONFDIR/cmkserver.cfg"
        exit 1
    fi
    if ! `which check_mk_agent >/dev/null`; then
        echo "check_mk_agent was not found in path, please install it." 
        exit 1
    fi
    if ! `which curl >/dev/null`; then
        echo "curl was not found in path, please install it." 
        exit 1
    fi

}

get_result()
{
   ## decode agent output with base64, remove line breaks and replace plus with html +
   export DATA=$(check_mk_agent | base64 --wrap=0 | sed 's/+/%2b/g' )
}

send_result()
{
    [ $DEBUG ] && echo "curl -X POST --silent --user $OMDUSER:$OMDPASS --data \"DATA=$DATA&HOSTNAME=$HOSTNAME&DEBUG=$DEBUG\" $OMDURL" 
    STATUS=$(curl -X POST --silent --user $OMDUSER:$OMDPASS --data "DATA=$DATA&HOSTNAME=$HOSTNAME&DEBUG=$DEBUG" "$OMDURL")
    
    if [ $? != 0 ]; then
        echo "Failed to submit agent output via CURL"
    fi
}

   ## main :)
   validate    &&
   get_result  &&
   send_result 
   ## print return
   be_done
