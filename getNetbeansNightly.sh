#!/bin/bash
echo "Starting compilation..."

echo "Loading config file..."
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


	echo "Setting up directories..."
	mkdir -p $DOWN_DIR
	mkdir -p $NETBEANS_NIGHTLY_DIR

	echo "Downloading Netbeans Nightly Build..."
	cd $DOWN_DIR
	lynx -dump http://bits.netbeans.org/download/trunk/nightly/latest/zip | grep http://bits.netbeans.org/download/trunk/nightly/latest/zip/netbeans | awk '{print $2}' | tail -1 | wget -i - --output-document=$DOWN_DIR/$NETBEANS_ZIP

	echo "Unzipping Netbeans..."
	unzip -uo $DOWN_DIR/$NETBEANS_ZIP -d $NETBEANS_NIGHTLY_DIR

	echo "Building Netbeans..."
	export ANT_OPTS="-Xmx256m -XX:MaxPermSize=96m"
	mkdir -p cd $NETBEANS_NIGHTLY_DIR/nbbuild
	cd $NETBEANS_NIGHTLY_DIR/nbbuild
	ant | tee > build.log

	ln -s ~/bin/nbdev $NETBEANS_NIGHTLY_DIR/nbbuild/netbeans/bin/netbeans


	echo "All done!"
	
	echo "Current space usage: "
	du -hc -d 1 $NETBEANS_NIGHTLY_DIR

else
	echo "copy the contents of config.example.sh to config.sh and modify the paths in that file as needed"
fi