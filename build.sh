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
  rm node
  ln -sf "libnode-v${NODE_VER}" node
fi
#---------

#-------- spark-webgl
export NODE_PATH=$NODE_PATH:`pwd`/../node_modules
export PATH=`pwd`/node/deps/npm/bin/node-gyp-bin/:`pwd`/node/out/Release:$PATH
cd spark-webgl
node-gyp rebuild
cd ..
