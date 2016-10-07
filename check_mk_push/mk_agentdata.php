<?php
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

## just for debug
#error_reporting(E_ALL);

## read given data
$HOSTNAME = $_POST["HOSTNAME"];
$MESSAGE = base64_decode($_POST["DATA"]);
$DEBUG = $_POST["DEBUG"];

## Check if data given
if (!$HOSTNAME){ die( "No hostname!"); }
if (!$MESSAGE){ die( "No data!"); }

## get omd path
$FULLPATH = getcwd();
$SITEROOT = str_replace("var/www", "", "$FULLPATH");

## debug output
if ($DEBUG){ echo "[DEBUG] SITEROOT = $SITEROOT"; }

## open filehandle
$FILEHANDLE = fopen( $SITEROOT."var/tmp/cmkresult.".$HOSTNAME,"w");

## write agentoutput
fwrite($FILEHANDLE, $MESSAGE );

## check if file written correctly
if ($FILEHANDLE === false) {
        die("ERROR: Unable to write cmkresult_".$HOSTNAME);
} else {
        if ($DEBUG){ echo "DEBUG=$MESSAGE"; }
        echo "OK";

}
fclose($FILEHANDLE);

?>
