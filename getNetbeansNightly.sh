echo "Starting compilation..."
DOWN_DIR=~/Downloads/netbeans-nightly
NETBEANS_ZIP=netbeans-nightly.zip
NETBEANS_NIGHTLY_DIR=~/netbeans

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
cd $NETBEANS_NIGHTLY_DIR/nbbuild
ant | tee > build.log

ln -s ~/bin/nbdev $NETBEANS_NIGHTLY_DIR/nbbuild/netbeans/bin/netbeans
