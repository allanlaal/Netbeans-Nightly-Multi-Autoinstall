# NB! you have to manually clean this directory! Sorry, no auto-uninstaller :)
NETBEANS_NIGHTLY_DIR=/opt/netbeans

TMP_DIR="$NETBEANS_NIGHTLY_DIR/tmp"
#TMP_DIR=/opt/netbeans/tmp

# Type of install:
#	
#	full:
#		linux.sh 
#
#	limited to language:
#		cpp-linux.sh
#		javaee-linux.sh
#		javase-linux.sh
#		php-linux.sh
#
TYPE='linux.sh'

# no trailing slash!!
BUNDLE_URL="http://bits.netbeans.org/download/trunk/nightly/latest/bundles"

SYMLINK_PREFIX="netbeans-link-autonightly-"