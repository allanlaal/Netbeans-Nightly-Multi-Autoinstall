#!/bin/bash
echo "
@desc Netbeans Nightly Multi Autoinstall script
Install a new Netbeans nightly copy and move the older links 1 day to the past

optional arguments:
--keep-open - setting this will keep the terminal window open


@example when todays nightly is already installed, it overwrites it cleanly
@version 2.0 for Netbeans 8+
@author Allan Laal <allan@permanent.ee>
"

/bin/echo "Loading config file"
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

if [ -f "$DIR/config.sh" ]
then
	source "$DIR/config.sh"

	/bin/echo "Setting up directories"
	mkdir -p $TMP_DIR
	mkdir -p $NETBEANS_NIGHTLY_DIR

	/bin/echo "Downloading Netbeans Nightly Build"

#	http://bits.netbeans.org/download/trunk/nightly/latest/bundles/


	FILE_URL=`lynx -dump "$BUNDLE_URL/" | /bin/grep $BUNDLE_URL | /bin/grep "[0-9]\+\-${TYPE}" | /usr/bin/awk '{print $2}' | /usr/bin/tail -1`
	FILE_NAME=${FILE_URL/$BUNDLE_URL\//}
	BUILD_NR=`/bin/echo "$FILE_NAME" | /bin/grep -o "[0-9]\+"`
	FUTURE_DIR="$NETBEANS_NIGHTLY_DIR/netbeans-autonightly-$BUILD_NR"
	/bin/echo "installer url: $FILE_URL"
	/bin/echo "installer filename: $FILE_NAME"
	/bin/echo "build: $BUILD_NR"
	/bin/echo "install directory: $FUTURE_DIR"
	
	TMP_FILE="$TMP_DIR/$FILE_NAME"
	/bin/rm -f TMP_FILE
	/usr/bin/wget -t 1 "${FILE_URL}" -O "${TMP_FILE}" --

	# remove old dir and (expecting one) link pointing to it (if exists) and install Netbeans:
	/bin/rm -rf $FUTURE_DIR
	/bin/ls -l | /bin/grep "$FUTURE_DIR" | /bin/grep $SYMLINK_PREFIX | /usr/bin/awk '{print $9}' | /usr/bin/xargs rm -rf
	# TODO: delete >1 symlinks [low]

	
	/bin/echo "Installing Netbeans nightly $BUILD_NR to $FUTURE_DIR"
	/bin/mkdir -p $FUTURE_DIR
	`/bin/chmod +x $TMP_FILE`
	`$TMP_FILE --silent "-J-Dnb-base.installation.location=$FUTURE_DIR"`

	# move all symlinks forward:
	# hardcoded to 1000 symlinks, very unrealistic someone is gonna hit that
	/bin/rm -f "$SYMLINK_PREFIX_1000"
	for CURRENT in {999..0..-1}; do
		OLDER=$(($CURRENT + 1))
		/bin/mv -f "${NETBEANS_NIGHTLY_DIR}/${SYMLINK_PREFIX}${CURRENT}" "${NETBEANS_NIGHTLY_DIR}/${SYMLINK_PREFIX}${OLDER}" 2>/dev/null
		#echo "/bin/mv -f ${NETBEANS_NIGHTLY_DIR}/${SYMLINK_PREFIX}${CURRENT} ${NETBEANS_NIGHTLY_DIR}/${SYMLINK_PREFIX}${OLDER}"
	done

	/bin/ln -s "${FUTURE_DIR}" "${NETBEANS_NIGHTLY_DIR}/${SYMLINK_PREFIX}0"
	echo "/bin/ln -s ${FUTURE_DIR} '${NETBEANS_NIGHTLY_DIR}/${SYMLINK_PREFIX}0'"

	# remove the downloaded file to keep ./tmp empty
	/bin/rm -f $TMP_FILE

	/bin/echo "All done!"
	
	/bin/echo "Current space usage: "
	/usr/bin/du -hc -d 1 $NETBEANS_NIGHTLY_DIR

else
	/bin/echo "copy the contents of config.example.sh to config.sh and modify the paths in that file as needed"
fi


# if --keep-open argument is set, keep the window open
if [ "$1" = "--keep-open" ]; then
	printf "Press any key to continue or 'CTRL+C' to exit : "
	(tty_state=$(stty -g)
	stty -icanon
	LC_ALL=C dd bs=1 count=1 >/dev/null 2>&1
	stty "$tty_state"
	) </dev/tty
fi