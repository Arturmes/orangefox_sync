#!/bin/bash
# ***************************************************************************************
# - Script to set up things for building OrangeFox with a minimal build system
# - Syncs the relevant twrp minimal manifest, and patches it for building OrangeFox
# - Pulls in the OrangeFox recovery sources and vendor tree
# - Author:  DarthJabba9
# - Version: generic:007
# - Date:    30 April 2022
#
# 	* Changes for v007 (20220430) - make it clear that fox_12.1 is not ready
#
# ***************************************************************************************

# the version number of this script
SCRIPT_VERSION="20220430";

# the base version of the current OrangeFox
FOX_BASE_VERSION="R11.1";

# Our starting point (Fox base dir)
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )";

# default directory for the new manifest
MANIFEST_DIR="";

# colours
NC='\033[0m';
RED='\033[0;31m';
BLUE='\033[0;34m';
GREEN='\033[0;32m';
ORANGE='\033[0;33m';
WHITEONRED='\033[0;41m';
WHITEONGREEN='\033[0;42m';
WHITEONORANGE='\033[0;43m';

# functions to set up things for each supported manifest branch
do_fox_121() {
	echo -e $RED"ERROR: fox_12.1 is not ready. Quitting."$NC;
	exit 1;

	BASE_VER=12;
	FOX_BRANCH="fox_12.1";
	FOX_DEF_BRANCH="fox_12.1";
	TWRP_BRANCH="twrp-12.1";
	DEVICE_BRANCH="android-12.1";
	test_build_device="miatoll"; # the device whose tree we can clone for compiling a test build
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
	echo "-- NOTE: the \"$FOX_BRANCH\" branch is still BETA as far as Virtual A/B (\"VAB\") devices are concerned. Treat it as such.";
}

do_fox_110() {
	BASE_VER=11;
	FOX_BRANCH="fox_11.0";
	FOX_DEF_BRANCH="fox_11.0";
	TWRP_BRANCH="twrp-11";
	DEVICE_BRANCH="android-11";
	test_build_device="vayu"; # the device whose tree we can clone for compiling a test build
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
	echo -e $WHITEONORANGE"-- NOTE: the \"$FOX_BRANCH\" branch is still BETA as far as Virtual A/B (\"VAB\") devices are concerned. Treat it as such."$NC;
}

do_fox_100() {
	BASE_VER=10;
	FOX_BRANCH="fox_10.0";
	FOX_DEF_BRANCH="fox_10.0";
	TWRP_BRANCH="twrp-10.0-deprecated";
	DEVICE_BRANCH="android-10";
	test_build_device="miatoll";
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git";
	CLONE_COMMONSYS_REPO="true";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
}

do_fox_90() {
	BASE_VER=9;
	FOX_BRANCH="fox_9.0";
	FOX_DEF_BRANCH="fox_9.0";
	TWRP_BRANCH="twrp-9.0";
	DEVICE_BRANCH="android-9.0";
	test_build_device="mido";
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git";
	CLONE_COMMONSYS_REPO="true";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
}

do_fox_81() {
	BASE_VER=8;
	FOX_BRANCH="fox_9.0";
	FOX_DEF_BRANCH="fox_8.1";
	TWRP_BRANCH="twrp-8.1";
	DEVICE_BRANCH="android-8.1";
	test_build_device="kenzo";
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
}

do_fox_71() {
	BASE_VER=6;
	FOX_BRANCH="fox_9.0";
	FOX_DEF_BRANCH="fox_7.1";
	TWRP_BRANCH="twrp-7.1";
	DEVICE_BRANCH="android-7.1";
	test_build_device="hermes";
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
}

do_fox_60() {
	BASE_VER=6;
	FOX_BRANCH="fox_9.0";
	FOX_DEF_BRANCH="fox_6.0";
	TWRP_BRANCH="twrp-6.0";
	DEVICE_BRANCH="android-6.0";
	test_build_device="klte";
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
}

# help
help_screen() {
  echo "Script to set up things for building OrangeFox with a twrp minimal manifest";
  echo "Usage = $0 <arguments>";
  echo "Arguments:";
  echo "    -h, -H, --help 			print this help screen and quit";
  echo "    -d, -D, --debug 			debug mode: print each command being executed";
  echo "    -s, -S, --ssh <'0' or '1'>		set 'USE_SSH' to '0' or '1'";
  echo "    -p, -P, --path <absolute_path>	sync the minimal manifest into the directory '<absolute_path>'";
  echo "    -b, -B, --branch <branch>		get the minimal manifest for '<branch>'";
  echo "    	'<branch>' must be one of the following branches:";
  echo "    		11.0";
  echo "    		10.0";
  echo "    		9.0";
  echo "    		8.1";
  echo "    		7.1";
  echo "    		6.0";
  echo "Examples:";
  echo "    $0 --branch 11.0 --path ~/OrangeFox_11.0";
  echo "    $0 --branch 10.0 --path ~/OrangeFox_10 --ssh 1";
  echo "    $0 --branch 9.0 --path ~/OrangeFox/9.0 --debug";
  echo "";
  echo "- You *must* supply an *absolute* path for the '--path' switch";
  exit 0;
}

#######################################################################
# test the command line arguments
Process_CMD_Line() {
   if [ -z "$1" ]; then
      help_screen;
   fi

   while (( "$#" )); do

        case "$1" in
            # debug mode - show some verbose outputs
                -d | -D | --debug)
                        set -o xtrace;
                ;;
             # help
                -h | -H | --help)
                        help_screen;
                ;;
             # ssh
                -s | -S | --ssh)
                        shift;
                        [ "$1" = "0" -o "$1" = "1" ] && USE_SSH=$1 || USE_SSH=0;
                ;;
             # path
                -p | -P | --path)
                        shift;
                        [ -n "$1" ] && MANIFEST_DIR=$1;
                ;;
             # branch
                -b | -B | --branch)
                	shift;
                 	if [ "$1" = "12.1" ]; then do_fox_121;
               			elif [ "$1" = "11.0" ]; then do_fox_110;
               			elif [ "$1" = "10.0" ]; then do_fox_100;
                		elif [ "$1" = "9.0" ]; then do_fox_90;
                		elif [ "$1" = "8.1" ]; then do_fox_81;
                		elif [ "$1" = "7.1" ]; then do_fox_71;
                		elif [ "$1" = "6.0" ]; then do_fox_60;
                	else
                  	   	echo -e $RED"Invalid branch \"$1\". Read the help screen below."$NC;
                  	   	echo "";
                  	   	help_screen;
                	fi
                ;;

        esac
     shift
   done

   # do we have all the necessary branch information?
   if [ -z "$FOX_BRANCH" -o -z "$TWRP_BRANCH" -o -z "$DEVICE_BRANCH" -o -z "$FOX_DEF_BRANCH" ]; then
   	echo -e $RED"No branch has been specified. Read the help screen below."$NC;
   	echo "";
   	help_screen;
   fi

  # do we have a manifest directory?
  if [ -z "$MANIFEST_DIR" ]; then
   	echo -e $RED"No path has been specified for the manifest. Read the help screen below."$NC;
   	echo "";
   	help_screen;
  fi
}
#######################################################################

# print message and quit
abort() {
  echo -e $RED"$@"$NC;
  exit 1;
}

# update the environment after processing the command line
update_environment() {
  # where to log the location of the manifest directory upon successful sync and patch
  SYNC_LOG="$BASE_DIR"/"$FOX_DEF_BRANCH"_"manifest.sav";

  # by default, don't use SSH for the "git clone" commands; to use SSH, you can also export USE_SSH=1 before starting
  [ -z "$USE_SSH" ] && USE_SSH="0";

  # the "diff" file that will be used to patch the original manifest
  PATCH_FILE="$BASE_DIR/patches/patch-manifest-$FOX_DEF_BRANCH.diff";

  # the directory in which the patch of the manifest will be executed
  MANIFEST_BUILD_DIR="$MANIFEST_DIR/build";
}

# init the script, ensure we have the patch file, and create the manifest directory
init_script() {
  echo -e $ORANGE"-- Starting the script ..."$NC;
  [ ! -f "$PATCH_FILE" ] && abort "-- I cannot find the patch file: $PATCH_FILE - quitting!";

  echo -e $ORANGE"-- The new build system will be located in \"$MANIFEST_DIR\""$NC;
  mkdir -p $MANIFEST_DIR;
  [ "$?" != "0" -a ! -d $MANIFEST_DIR ] && {
    abort "-- Invalid directory: \"$MANIFEST_DIR\". Quitting.";
  }
}

# repo init and repo sync
get_twrp_minimal_manifest() {
  cd $MANIFEST_DIR;
  echo -e $ORANGE"-- Initialising the $TWRP_BRANCH minimal manifest repo ..."$NC;
  repo init --depth=1 -u $MIN_MANIFEST -b $TWRP_BRANCH;
  [ "$?" != "0" ] && {
   abort "-- Failed to initialise the minimal manifest repo. Quitting.";
  }
  echo -e $ORANGE"-- Done."$NC;

  echo -e $ORANGE"-- Syncing the $TWRP_BRANCH minimal manifest repo ..."$NC;
  repo sync;
  [ "$?" != "0" ] && {
   abort $RED"-- Failed to Sync the minimal manifest repo. Quitting.";
  }
  echo -e $ORANGE"-- Done."$NC;
}

# patch the build system for OrangeFox
patch_minimal_manifest() {
   echo -e $ORANGE"-- Patching the $TWRP_BRANCH minimal manifest for building OrangeFox for native $DEVICE_BRANCH devices ..."$NC;
   cd $MANIFEST_BUILD_DIR;
   patch -p1 < $PATCH_FILE;
   [ "$?" = "0" ] && echo -e $ORANGE"-- The $TWRP_BRANCH minimal manifest has been patched successfully" || abort "-- Failed to patch the $TWRP_BRANCH minimal manifest! Quitting.";

   # save location of manifest dir
   echo "#" &> $SYNC_LOG;
   echo "MANIFEST_DIR=$MANIFEST_DIR" >> $SYNC_LOG;
   echo "#" >> $SYNC_LOG;
}

# get the qcom/twrp common stuff
clone_common() {
   cd $MANIFEST_DIR/;

   if [ ! -d "device/qcom/common" ]; then
   	echo -e $ORANGE"-- Cloning qcom common ..."$NC;
	git clone https://github.com/TeamWin/android_device_qcom_common -b $DEVICE_BRANCH device/qcom/common;
   fi

   if [ ! -d "device/qcom/twrp-common" ]; then
   	echo -e $ORANGE"-- Cloning twrp-common ..."$NC;
   	git clone https://github.com/TeamWin/android_device_qcom_twrp-common -b $DEVICE_BRANCH device/qcom/twrp-common;
   fi
}

# Clone the commonsys repo
clone_commonsys(){
	 cd $MANIFEST_DIR/;
	 if [ "$CLONE_COMMONSYS_REPO" = "true" ]; then
		if [ ! -d vendor/qcom/opensource/commonsys ]; then
			echo -e $ORANGE"-- Cloning qcom commonsys ..."$NC;
			git clone --depth=1 https://github.com/TeamWin/android_vendor_qcom_opensource_commonsys.git -b $DEVICE_BRANCH vendor/qcom/opensource/commonsys;
		fi
	fi
}

# get the OrangeFox recovery sources
clone_fox_recovery() {
local URL="";
local BRANCH=$FOX_BRANCH;
   if [ "$USE_SSH" = "0" ]; then
      URL="https://gitlab.com/OrangeFox/bootable/Recovery.git";
   else
      URL="git@gitlab.com:OrangeFox/bootable/Recovery.git";
   fi

   mkdir -p $MANIFEST_DIR/bootable;
   [ ! -d $MANIFEST_DIR/bootable ] && {
      echo -e $WHITEONORANGE"-- Invalid directory: $MANIFEST_DIR/bootable"$NC;
      return;
   }

   cd $MANIFEST_DIR/bootable/;
   [ -d recovery/ ] && {
      echo -e $ORANGE"-- Moving the TWRP recovery sources to /tmp"$NC;
      rm -rf /tmp/recovery;
      mv recovery /tmp;
   }

   echo -e $ORANGE"-- Pulling the OrangeFox recovery sources ..."$NC;
   git clone --recurse-submodules $URL -b $BRANCH recovery;
   [ "$?" = "0" ] && echo -e $WHITEONGREEN"-- The OrangeFox sources have been cloned successfully"$NC || echo -e $WHITEONRED"-- Failed to clone the OrangeFox sources!"$NC;

   # check that the themes are correctly downloaded
   if [ ! -f recovery/gui/theme/portrait_hdpi/ui.xml ]; then
      	echo -e $ORANGE"-- Themes not found! Trying again to pull the themes ..."$NC;
   	if [ "$USE_SSH" = "0" ]; then
      	   URL="https://gitlab.com/OrangeFox/misc/theme.git";
   	else
      	   URL="git@gitlab.com:OrangeFox/misc/theme.git";
   	fi
      	[ -d recovery/gui/theme ] && rm -rf recovery/gui/theme;
      	git clone $URL recovery/gui/theme;
      	[ "$?" = "0" ] && echo -e $ORANGE"-- The themes have been cloned successfully"$NC || echo -e $RED"-- Failed to clone the themes!"$NC;
   fi

   # cleanup /tmp/recovery/
   echo -e $ORANGE"-- Cleaning up the TWRP recovery sources from /tmp"$NC;
   rm -rf /tmp/recovery;

   # create the directory for Xiaomi device trees
   mkdir -p $MANIFEST_DIR/device/xiaomi;
}

# get the OrangeFox vendor
clone_fox_vendor() {
local URL="";
local BRANCH=$FOX_BRANCH;
   [ "$BASE_VER" -lt 10 ] && BRANCH="master"; # less than fox_10.0 use the "master" branch
   
   if [ "$USE_SSH" = "0" ]; then
      URL="https://gitlab.com/OrangeFox/vendor/recovery.git";
   else
      URL="git@gitlab.com:OrangeFox/vendor/recovery.git";
   fi

   echo -e $ORANGE"-- Preparing for cloning the OrangeFox vendor tree ..."$NC;
   rm -rf $MANIFEST_DIR/vendor/recovery;
   mkdir -p $MANIFEST_DIR/vendor;
   [ ! -d $MANIFEST_DIR/vendor ] && {
      echo -e $RED"-- Invalid directory: $MANIFEST_DIR/vendor"$NC;
      return;
   }

   cd $MANIFEST_DIR/vendor;
   echo -e $ORANGE"-- Pulling the OrangeFox vendor tree ..."$NC;
   git clone $URL -b $BRANCH recovery;
   [ "$?" = "0" ] && echo -e $WHITEONGREEN"-- The OrangeFox vendor tree has been cloned successfully"$NC || echo -e $RED"-- Failed to clone the OrangeFox vendor tree!"$NC;
}

# get the OrangeFox busybox sources
clone_fox_busybox() {
local URL="";
local BRANCH="android-9.0";
   [ "$BASE_VER" != "9" ] && return; # only clone busybox for 9.0

   if [ "$USE_SSH" = "0" ]; then
      URL="https://gitlab.com/OrangeFox/external/busybox.git";
   else
      URL="git@gitlab.com:OrangeFox/external/busybox.git";
   fi

   echo -e $ORANGE"-- Preparing for cloning the OrangeFox busybox sources ..."$NC;
   cd $MANIFEST_DIR/external;
   echo -e $ORANGE"-- Pulling the OrangeFox busybox sources ..."$NC;
   git clone $URL -b $BRANCH busybox;
   [ "$?" = "0" ] && echo -e $WHITEONGREEN"-- The OrangeFox busybox sources have been cloned successfully"$NC || echo -e $RED"-- Failed to clone the OrangeFox busybox sources!"$NC;
}

# get device trees
get_device_tree() {
local DIR=$MANIFEST_DIR/device/xiaomi;
   mkdir -p $DIR;
   cd $DIR;
   [ "$?" != "0" ] && {
      abort "-- get_device_tree() - Invalid directory: $DIR";
   }

   # test device
   local URL=git@gitlab.com:OrangeFox/device/"$test_build_device".git;
   [ "$USE_SSH" = "0" ] && URL=https://gitlab.com/OrangeFox/device/"$test_build_device".git;
   echo -e $ORANGE"-- Pulling the $test_build_device device tree ..."$NC;
   git clone $URL -b "$FOX_DEF_BRANCH" "$test_build_device";

   # done
   if [ -d "$test_build_device" -a -d "$test_build_device/recovery" ]; then
      echo -e $ORANGE"-- Finished fetching the OrangeFox $test_build_device device tree."$NC;
   else
      abort "-- get_device_tree() - could not fetch the OrangeFox $test_build_device device tree.";
   fi
}

# test build
test_build() {
   # clone the device tree
   get_device_tree;

   # proceed with the test build
   export FOX_VERSION="$FOX_BASE_VERSION"_"$FOX_DEF_BRANCH";
   export LC_ALL="C";
   export FOX_BUILD_TYPE="Alpha";
   export ALLOW_MISSING_DEPENDENCIES=true;
   export FOX_BUILD_DEVICE="$test_build_device";
   export OUT_DIR=$BASE_DIR/BUILDS/"$test_build_device";

   cd $BASE_DIR/;
   mkdir -p $OUT_DIR;

   cd $MANIFEST_DIR/;
   echo -e $ORANGE"-- Compiling a test build for device \"$test_build_device\". This may take a *VERY* long time ..."$NC;
   echo -e $ORANGE"-- Start compiling: "$NC;
   . build/envsetup.sh;

   # what are we lunching (AOSP or Omni)>
   if [ "$BASE_VER" -gt 10 ]; then
   	lunch twrp_"$test_build_device"-eng;
   else
   	lunch omni_"$test_build_device"-eng;
   fi

   # build for the device
   # are we building for a virtual A/B (VAB) device? (default is "no")
   local FOX_VAB_DEVICE=0;
   if [ "$FOX_VAB_DEVICE" = "1" ]; then
   	mka adbd bootimage;
   else
   	mka adbd recoveryimage;
   fi

   # any results?
   ls -all $(find "$OUT_DIR" -name "OrangeFox-*");
}

# do all the work!
WorkNow() {
    echo "$0, v$SCRIPT_VERSION";

    local START=$(date);

    Process_CMD_Line "$@";

    update_environment;

    init_script;

    get_twrp_minimal_manifest;

    patch_minimal_manifest;

    clone_common;

    clone_commonsys;

    [ "$BASE_VER" != "12" ] && clone_fox_recovery; # no fox_12.1 yet

    clone_fox_vendor;

    clone_fox_busybox;

    # test_build; # comment this out - don't do a test build by default

    local STOP=$(date);
    echo -e $BLUE"-- Stop time =$STOP"$NC;
    echo -e $BLUE"-- Start time=$START"$NC;
    echo -e $GREEN"-- Now, clone your device trees to the correct locations!"$NC;
    exit 0;
}

# --- main() ---
WorkNow "$@";
# --- end main() ---
