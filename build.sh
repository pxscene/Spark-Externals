#!/bin/bash
set -e
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

banner() {
  msg="# $* #"
  edge=$(echo "$msg" | sed 's/./#/g')
  echo " "
  echo "$edge"
  echo "$msg"
  echo "$edge"
  echo " "
}

#--------- Args

NODE_VER="10.15.3"
OPENSSL_DIR="`pwd`/openssl-1.0.2o"

while (( "$#" )); do
  case "$1" in
    --node-version)
      NODE_VER=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
  esac
done

EXT_INSTALL_PATH=$PWD/extlibs
mkdir -p $EXT_INSTALL_PATH

make_parallel=3

if [ "$(uname)" = "Darwin" ]; then
    make_parallel="$(sysctl -n hw.ncpu)"
    LIBEXTN=dylib
elif [ "$(uname)" = "Linux" ]; then
    make_parallel="$(cat /proc/cpuinfo | grep '^processor' | wc --lines)"
    LIBEXTN=so
fi

#--------- OPENSSL
export CCACHE_DISABLE=true
cd ${OPENSSL_DIR}
if [ "$(uname)" != "Darwin" ]
then
./config -shared  --prefix=`pwd`
else
./Configure darwin64-x86_64-cc -shared --prefix=`pwd`
fi
echo "before clean"
find . -name "libcrypto.so*"
make clean
echo "after clean"
find . -name libcrypto.so*
make "-j1"
echo "after build"
make install -i
rm -rf libcrypto.a
rm -rf libssl.a
rm -rf lib/libcrypto.a
rm -rf lib/libssl.a
cd ..
export LD_LIBRARY_PATH="${OPENSSL_DIR}/:$LD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH="${OPENSSL_DIR}/:$DYLD_LIBRARY_PATH"
unset CCACHE_DISABLE
ln -s ${OPENSSL_DIR} openssl

#--------graphite2

if [ ! -e $EXT_INSTALL_PATH/lib/libgraphite2.la ]
then
  banner "graphite2"

  ./graphite2/build.sh
fi

#--------

#-------- pcre

if [ ! -e $EXT_INSTALL_PATH/lib/libpcre.la ]
then
  banner "pcre"

  ./pcre/build.sh
fi

#--------

#--------icu

if [ ! -e $EXT_INSTALL_PATH/lib/libicudata.$LIBEXTN ]
then
  banner "icu"

  ./icu/build.sh
fi

#--------

#-------- libffi

if [ ! -e $EXT_INSTALL_PATH/lib/libffi.la ]
then
  banner "libffi"

  ./libffi/build.sh
fi

#--------

#--------gettext

if [ ! -e $EXT_INSTALL_PATH/lib/libintl.la ]
then
  banner "gettext"

  ./gettext/build.sh
fi

#--------

#--------glib

if [ ! -e $EXT_INSTALL_PATH/lib/libglib-2.0.la ]
then
  banner "glib"

  ./glib/build.sh
fi

#--------

#--------- FT

if [ ! -e ./ft/objs/.libs/libfreetype.6.dylib ] ||
   [ "$(uname)" != "Darwin" ]
then

  banner "FT"

  cd ft

  LIBPNG_LIBS="-L../png/.libs -lpng16" PKG_CONFIG_PATH=$EXT_INSTALL_PATH/lib/pkgconfig:$PKG_CONFIG_PATH ./configure --with-png=no --with-harfbuzz=no --prefix=$EXT_INSTALL_PATH
  make all "-j${make_parallel}"
  make install
  cd ..

fi
#---------

if [ ! -e $EXT_INSTALL_PATH/lib/libfontconfig.$LIBEXTN ]
then
  banner "Fontconfig"

  PKG_CONFIG_PATH=$EXT_INSTALL_PATH/lib/pkgconfig:$PKG_CONFIG_PATH ./fontconfig/build.sh
fi

#--------

#--------harfbuzz

if [ ! -e $EXT_INSTALL_PATH/lib/libharfbuzz.la ]
then
  banner "harfbuzz"

  ./harfbuzz/build.sh
fi

#-------- openssl

if [ ! -e $EXT_INSTALL_PATH/lib/libcrypto.$LIBEXTN ]
then
  banner "openssl"

  cp -r ${OPENSSL_DIR}/* $EXT_INSTALL_PATH
fi

#--------

#--------- LIBNODE

if [ ! -e "libnode-v${NODE_VER}/libnode.dylib" ] ||
   [ "$(uname)" != "Darwin" ]
then

  banner "NODE"
  if [ -e "node-v${NODE_VER}_mods.patch" ]
  then
    git apply "node-v${NODE_VER}_mods.patch"
    git apply "openssl_1.0.2_compatibility.patch"
  fi

  cd "libnode-v${NODE_VER}"
  ./configure --shared --shared-openssl --shared-openssl-includes="${OPENSSL_DIR}/include/" --shared-openssl-libpath="${OPENSSL_DIR}/lib"
  make "-j${make_parallel}"

  if [ "$(uname)" != "Darwin" ]
  then
    ln -sf out/Release/obj.target/libnode.so.* ./
    ln -sf libnode.so.* libnode.so
  else
    ln -sf out/Release/libnode.*.dylib ./
    ln -sf libnode.*.dylib libnode.dylib
  fi

  cd ..
  if [ -e "node" ]
  then
    rm -rf node
  fi
  ln -sf "libnode-v${NODE_VER}" node
fi
#---------

#-------- spark-webgl
export NODE_PATH=$NODE_PATH:`pwd`/../node_modules
export PATH=`pwd`/node/deps/npm/bin/node-gyp-bin/:`pwd`/node/out/Release:$PATH
cd spark-webgl
node-gyp rebuild
cd ..

#-------- 
#if [[ $# -eq 1 ]] && [[ $1 == "SPARK_ENABLE_VIDEO" ]]; then
#-------- cJSON

if [ ! -e $EXT_INSTALL_PATH/lib/libcjson.$LIBEXTN ]
then
  banner "cJSON"

  ./cJSON/build.sh
fi

#--------

#--------orc

if [ ! -e $EXT_INSTALL_PATH/lib/liborc-0.4.la ]
then
  banner "orc"

  ./orc/build.sh
fi

#--------


#--------ossp-uuid

if [ ! -e $EXT_INSTALL_PATH/lib/libuuid.la ]
then
  banner "ossp-uuid"

  ./ossp-uuid/build.sh
fi

#--------

#--------libxml2

if [ ! -e $EXT_INSTALL_PATH/lib/libxml2.la ]
then
  banner "libxml2"

  ./libxml2/build.sh
fi

#--------

#-------- libdash

if [ ! -e $EXT_INSTALL_PATH/lib/libdash.$LIBEXTN ]
then
  banner "libdash"

  LD_LIBRARY_PATH="$EXT_INSTALL_PATH/lib:$LD_LIBRARY_PATH" PKG_CONFIG_PATH=$EXT_INSTALL_PATH/lib/pkgconfig:$PKG_CONFIG_PATH ./libdash/libdash/build.sh
fi

#--------

#-------- xz-5.2.2

if [ ! -e $EXT_INSTALL_PATH/lib/liblzma.la ]
then
  banner "xz"

  ./xz/build.sh
fi

#--------

#-------- gstreamer-1.16

#if [ ! -e $EXT_INSTALL_PATH/lib/libgstreamer-1.0.la ]
#then
#  banner "gstreamer-1.16"
#
#  ./gstreamer/build.sh
#fi
#
##--------
#
##-------- gst-plugin-base
#
#if [ ! -e $EXT_INSTALL_PATH/lib/libgstapp-1.0.la ]
#then
#  banner "gst-plugins-base"
#
#  ./gst-plugins-base/build.sh
#fi
#
##--------
##-------- gst-plugin-bad
#
#if [ ! -e $EXT_INSTALL_PATH/lib/libgstbadaudio-1.0.la ]
#then
#  banner "gst-plugins-bad"
#
#  ./gst-plugins-bad/build.sh
#fi
#
##--------
##-------- gst-plugin-ugly
#
#if [ ! -e $EXT_INSTALL_PATH/lib/gstreamer-1.0/libgstx264.la ]
#then
#  banner "gst-plugins-ugly"
#
#  ./gst-plugins-ugly/build.sh
#fi
#
##--------
##-------- gst-plugin-good
#
#if [ ! -e $EXT_INSTALL_PATH/lib/gstreamer-1.0/libgstavi.la ]
#then
#  banner "gst-plugins-good"
#
#  ./gst-plugins-good/build.sh
#fi

#--------
#-------- gst-libav

#if [ ! -e $EXT_INSTALL_PATH/lib/gstreamer-1.0/libgstlibav.la ]
#then
#  banner "gst-libav"
#
#  ./gst-libav/build.sh
#fi
#
##--------
#
##-------- aampabr
#
#if [ ! -e $EXT_INSTALL_PATH/lib/libabr.$LIBEXTN ]
#then
#  banner "aampabr"
#
#  ./aampabr/build.sh
#fi
#
##--------
#
##-------- aamp
#
#if [ ! -e $EXT_INSTALL_PATH/lib/libaamp.$LIBEXTN ]
#then
#  banner "aamp"
#
#  ./aamp/build.sh
#fi

#--------
