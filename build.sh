#!/bin/bash
set -e
export CCACHE_DISABLE=true

NODE_VER="10.15.3"

#mention dirs for other externals directory
BREAKPAD_LIB_DIR="`pwd`/breakpad-chrome_55/src/client/linux/"
NANOSVG_DIR="`pwd`/nanosvg"
BREAKPAD_INCLUDE_DIR="`pwd`/breakpad-chrome_55"
NODE_DIR="`pwd`/libnode-v10.15.3"
GIF_LIB_DIR="`pwd`/gif/.libs/"
SQLITE_LIB_DIR="`pwd`/sqlite-autoconf-3280000/.libs"
DUKTAPE_LIB_DIR="`pwd`/dukluv/build/"
NODE_LIB_DIR="`pwd`/libnode-v${NODE_VER}/out/Release/obj.target"
OPENSSL_LIB_DIR="`pwd`/openssl-1.0.2o/"
SPARK_WEBGL_DIR="`pwd`/spark-webgl/build/Release/"

#copy to external directories
EXT_INSTALL_PATH=$PWD/artifacts/${TRAVIS_OS_NAME}
EXT_INSTALL_LIB_PATH=${EXT_INSTALL_PATH}/lib
EXT_INSTALL_INCLUDE_PATH=${EXT_INSTALL_PATH}/include
EXT_INSTALL_BIN_PATH=${EXT_INSTALL_PATH}/bin
NODE_MODULES_PATH=${EXT_INSTALL_PATH}/node_modules

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
modified_component_list=()

#build flags
artifacts_build=0
aampbr_build=0
aamp_build=0
breakpadchrome_build=0
cjson_build=0
curl_build=0
dukluv_build=0
fontconfig_build=0
freetype_build=0
gettext_build=0
giflib_build=0
glib_build=0
graphite2_build=0
gstlibav_build=0
gstpluginsbad_build=0
gstpluginsbase_build=0
gstpluginsgood_build=0
gstpluginsugly_build=0
gstreamer_build=0
harfbuzz_build=0
icu_build=0
jpeg9a_build=0
libdash_build=0
libffi_build=0
libjpegturbo_build=0
libnode_build=1
libpng_build=0
libxml2_build=0
nanosvg_build=0
openssl_build=0
orc_build=0
osspuuid_build=0
pcre_build=0
sparkwebgl_build=1
sqliteautoconf_build=0
#this may not be needed
uwebsockets_build=0
xz_build=0
zlib_build=0

#depends information
openssl_depends=("openssl")
libpng_depends=("libpng")
jpeg9a_depends=("jpeg9a")
pcre_depends=("pcre")
icu_depends=("icu")
libffi_depends=("libffi")
giflib_depends=("giflib")
freetype_depends=("freetype")
zlib_depends=("zlib")
libjpegturbo_depends=("libjpegturbo")
breakpadchrome_depends=("breakpadchrome")
dukluv_depends=("dukluv")
sqliteautoconf_depends=("sqliteautoconf")
cjson_depends=("cjson")
orc_depends=("orc")
nanosvg_depends=("nanosvg")
osspuuid_depends=("osspuuid")
xz_depends=("xz")
libxml2_depends=("libxml2")
gstreamer_depends=("gstreamer")
harfbuzz_depends=("harfbuzz")
aampbr_depends=("aampbr")
curl_depends=("curl" "openssl")
graphite2_depends=("graphite2" "freetype")
gettext_depends=("gettext" "pcre")
glib_depends=("glib" "libffi")
fontconfig_depends=("fontconfig" "freetype")
libnode_depends=("libnode" "openssl")
uwebsockets_depends=("uwebsockets" "openssl")
sparkwebgl_depends=("sparkwebgl" "libnode")
libdash_depends=("libdash" "curl" "libxml2")
gstpluginsbase_depends=("gstpluginsbase" "gstreamer")
gstpluginsgood_depends=("gstpluginsgood" "gstpluginsbase")
gstpluginsbad_depends=("gstpluginsbad" "gstpluginsbase")
gstpluginsugly_depends=("gstpluginsugly" "gstpluginsbase")
gstlibav_depends=("gstlibav" "gstpluginsbase")
aamp_depends=("aamp" "libdash" "cjson" "openssl" "gstreamer" "libxml2")

prepare_modified_component_list()
{
  gitoutput=`git show --pretty="format:" --name-only HEAD`
  SAVEIFS=$IFS   # Save current IFS
  IFS=$'\n'      # Change IFS to new line
  changedfiles=($gitoutput) # split to array $names
  IFS=$SAVEIFS   # Restore IFS
  
  lastcomponent=""
  for (( i=0; i<${#changedfiles[@]}; i++ ))
  do
      component_name="$(echo ${changedfiles[$i]}|cut -d'/' -f1)"
      #avoid duplicate names
      if [[ "$lastcomponent" != "$component_name" ]]; then
        modified_component_list+=("$component_name")
        lastcomponent=$component_name
      fi
  done
  echo "Number of changed components : ${#modified_component_list[@]}"
  echo "list of changed components are below:"
  echo "${modified_component_list[@]}"
}

#enable build flag for a specific component
enable_build_flags()
{
  input_component_name=$1
  case $input_component_name in
        graphite2)
                graphite2_build=1
        	;;
        pcre)
                pcre_build=1
        	;;
        icu)
                icu_build=1
        	;;
        libffi)
                libffi_build=1
        	;;
        gettext)
                gettext_build=1
        	;;
        glib)
                glib_build=1
        	;;
        fontconfig)
                fontconfig_build=1
        	;;
        dukluv)
                dukluv_build=1
        	;;
        cJSON)
                cjson_build=1
        	;;
        orc)
                orc_build=1
        	;;
        nanosvg)
                nanosvg_build=1
        	;;
        libxml2)
                libxml2_build=1
        	;;
        libdash)
                libdash_build=1
        	;;
        gstreamer)
                gstreamer_build=1
        	;;
        harfbuzz)
                harfbuzz_build=1
        	;;
        aampbr)
                aampbr_build=1
        	;;
        aamp)
                aamp_build=1
        	;;
        libpng-1.6.28)
                libpng_build=1
        	;;
        uWebSockets-0.14.8)
                uwebsockets_build=1
        	;;
        zlib-1.2.11)
                zlib_build=1
        	;;
        openssl-1.0.2o)
                openssl_build=1
        	;;
        libjpeg-turbo-1.5.1)
                libjpegturbo_build=1
        	;;
        sqlite-autoconf-3280000)
                sqliteautoconf_build=1
        	;;
        xz)
                xz_build=1
        	;;
        libnode-v10.15.3)
                libnode_build=1
        	;;
        ossp-uuid)
                osspuuid_build=1
        	;;
        spark-webgl)
                sparkwebgl_build=1
        	;;
        gst-plugins-base)
                gstpluginsbase_build=1
        	;;
        gst-plugins-good)
                gstpluginsgood_build=1
        	;;
        gst-plugins-bad)
                gstpluginsbad_build=1
        	;;
        gst-plugins-ugly)
                gstpluginsugly_build=1
        	;;
        gst-libav)
                gstlibav_build=1
        	;;
        breakpad-chrome_55)
                breakpadchrome_build=1
        	;;
        giflib-5.1.9)
                giflib_build=1
        	;;
        curl-7.40.0)
                curl_build=1
        	;;
        freetype-2.8.1)
                freetype_build=1
        	;;
        jpeg-9a)
                jpeg9a_build=1
        	;;
        *)
        	;;
  esac
  return 0
}

#parse through modified component list and enable build flags
prepare_build_data()
{
  for (( i=0; i<${#modified_component_list[@]}; i++ ))
  do
    component_name="$(echo ${modified_component_list[$i]})"
    echo "Enabling build for changed component - $component_name"
    enable_build_flags "$component_name"
  done
}

#determine whether this component needs rebuild or not
need_component_rebuild()
{
  need_rebuild=0
  depends_list=("$@")
  current_component_name=${depends_list[0]}
  current_component_build="$(echo ${current_component_name})_build"
  if [ ${!current_component_build} -ne 1 ]; then
    for (( i=0; i<${#depends_list[@]}; i++ ))
    do
      component_name="$(echo ${depends_list[$i]})_build"
      need_rebuild=$(($need_rebuild || ${!component_name}))
    done
    if [ $need_rebuild -eq 1 ]; then
      echo "Enabling build for dependent component - $current_component_name"
      enable_build_flags "$current_component_name"
    fi
  fi
}

#determine whether this component needs rebuild or not
prepare_dependent_component_list()
{
  need_component_rebuild "${openssl_depends[@]}"
  need_component_rebuild "${libpng_depends[@]}"
  need_component_rebuild "${jpeg9a_depends[@]}"
  need_component_rebuild "${pcre_depends[@]}"
  need_component_rebuild "${icu_depends[@]}"
  need_component_rebuild "${libffi_depends[@]}"
  need_component_rebuild "${giflib_depends[@]}"
  need_component_rebuild "${freetype_depends[@]}"
  need_component_rebuild "${zlib_depends[@]}"
  need_component_rebuild "${libjpegturbo_depends[@]}"
  need_component_rebuild "${breakpadchrome_depends[@]}"
  need_component_rebuild "${dukluv_depends[@]}"
  need_component_rebuild "${sqliteautoconf_depends[@]}"
  need_component_rebuild "${cjson_depends[@]}"
  need_component_rebuild "${orc_depends[@]}"
  need_component_rebuild "${nanosvg_depends[@]}"
  need_component_rebuild "${osspuuid_depends[@]}"
  need_component_rebuild "${xz_depends[@]}"
  need_component_rebuild "${libxml2_depends[@]}"
  need_component_rebuild "${gstreamer_depends[@]}"
  need_component_rebuild "${harfbuzz_depends[@]}"
  need_component_rebuild "${aampbr_depends[@]}"
  need_component_rebuild "${curl_depends[@]}"
  need_component_rebuild "${graphite2_depends[@]}"
  need_component_rebuild "${gettext_depends[@]}"
  need_component_rebuild "${glib_depends[@]}"
  need_component_rebuild "${fontconfig_depends[@]}"
  need_component_rebuild "${libnode_depends[@]}"
  need_component_rebuild "${uwebsockets_depends[@]}"
  need_component_rebuild "${sparkwebgl_depends[@]}"
  need_component_rebuild "${libdash_depends[@]}"
  need_component_rebuild "${gstpluginsbase_depends[@]}"
  need_component_rebuild "${gstpluginsgood_depends[@]}"
  need_component_rebuild "${gstpluginsbad_depends[@]}"
  need_component_rebuild "${gstpluginsugly_depends[@]}"
  need_component_rebuild "${gstlibav_depends[@]}"
  need_component_rebuild "${aamp_depends[@]}"
}

echo "Preparing modified components list ...."
prepare_modified_component_list
prepare_build_data
echo "Preparing dependent components list ...."
prepare_dependent_component_list

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
ln -s $PWD/artifacts/${TRAVIS_OS_NAME} extlibs

make_parallel=3

if [ "$(uname)" = "Darwin" ]; then
    make_parallel="$(sysctl -n hw.ncpu)"
    LIBEXTN=dylib
elif [ "$(uname)" = "Linux" ]; then
    make_parallel="$(cat /proc/cpuinfo | grep '^processor' | wc --lines)"
    LIBEXTN=so
fi

export LD_LIBRARY_PATH="${EXT_INSTALL_PATH}/:$LD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH="${EXT_INSTALL_PATH}/:$DYLD_LIBRARY_PATH"
export PKG_CONFIG_PATH=$EXT_INSTALL_PATH/lib/pkgconfig:$PKG_CONFIG_PATH
#--------- OPENSSL
if [ $openssl_build -eq 1 ]; then
  export CCACHE_DISABLE=true
  cd ${OPENSSL_DIR}
  if [ "$(uname)" != "Darwin" ]
  then
  ./config -shared  --prefix=$EXT_INSTALL_PATH
  else
  ./Configure darwin64-x86_64-cc -shared --prefix=$EXT_INSTALL_PATH
  fi
  make clean
  make "-j1"
  make install -i
  rm -rf libcrypto.a
  rm -rf libssl.a
  rm -rf lib/libcrypto.a
  rm -rf lib/libssl.a
  cd ..
  unset CCACHE_DISABLE
  ln -s ${OPENSSL_DIR} openssl
fi

if [ $libpng_build -eq 1 ]; then

  banner "PNG"

  cd png
  ./configure --prefix=$EXT_INSTALL_PATH
  make all "-j${make_parallel}"
  #grep -rn "__cg_png_create_info_struct" .
  make install
  cd ..

fi
#---------

#--------- JPG
#
if [ $jpeg9a_build -eq 1 ]; then

  banner "JPG"

  cd jpg
  ./configure --prefix=$EXT_INSTALL_PATH
  make all "-j${make_parallel}"
  make install
  cd ..

fi

#--------graphite2
if [ $graphite2_build -eq 1 ]; then
  banner "graphite2"

  ./graphite2/build.sh
fi

#--------

#-------- pcre
if [ $pcre_build -eq 1 ]; then
  banner "pcre"

  ./pcre/build.sh
fi

#--------

#--------icu

if [ $icu_build -eq 1 ]; then
  banner "icu"

  ./icu/build.sh
fi

#--------

#-------- libffi

if [ $libffi_build -eq 1 ]; then
  banner "libffi"

  ./libffi/build.sh
fi

#--------

#--------gettext

if [ $gettext_build -eq 1 ]; then
  banner "gettext"

  ./gettext/build.sh
fi

#--------

#--------glib

if [ $glib_build -eq 1 ]; then
  banner "glib"

  ./glib/build.sh
fi

#--------
##--------- GIF
#
if [ $giflib_build -eq 1 ]; then
  banner "GIF"
  
  cd giflib-5.1.9
  if [ "$(uname)" == "Darwin" ]; then
  
  [ -d patches ] || mkdir -p patches
  [ -d patches/series ] || echo 'giflib-5.1.9.patch' >patches/series
  cp ../giflib-5.1.9.patch patches/
  
  if [[ "$#" -eq "1" && "$1" == "--clean" ]]; then
  	quilt pop -afq || test $? = 2
  	rm -rf .libs/*
  elif [[ "$#" -eq "1" && "$1" == "--force-clean" ]]; then
  	git clean -fdx .
  	git checkout .
  	rm -rf .libs/*
  else
  	quilt push -aq || test $? = 2
  fi
  
  fi
  
  if [ ! -e ./.libs/libgif.7.dylib ] ||
  [ "$(uname)" != "Darwin" ]
  then
      make
  [ -d .libs ] || mkdir -p .libs
  if [ -e libgif.7.dylib ]
  then
      cp libgif.7.dylib .libs/libgif.7.dylib
      cp libutil.7.dylib .libs/libutil.7.dylib
  
  
  elif [ -e libgif.so ]
  then
      cp libgif.so .libs/libgif.so
      cp libutil.so .libs/libutil.so
  fi
  fi

  cp -f gif_lib.h ${EXT_INSTALL_INCLUDE_PATH}/.
  
  cd ..
  if [ "$(uname)" != "Darwin" ]
  then
    cp -R ${GIF_LIB_DIR}/libgif.so ${EXT_INSTALL_LIB_PATH}/.
    cp -R ${GIF_LIB_DIR}/libutil.so ${EXT_INSTALL_LIB_PATH}/.
  else
    cp -R ${GIF_LIB_DIR}/libgif.*.dylib ${EXT_INSTALL_LIB_PATH}/.
    cp -R ${GIF_LIB_DIR}/libutil.*.dylib ${EXT_INSTALL_LIB_PATH}/.
  fi
fi

#--------- FT

if [ $freetype_build -eq 1 ]; then
  banner "FT"

  cd ft

  LIBPNG_LIBS="-L../png/.libs -lpng16" PKG_CONFIG_PATH=$EXT_INSTALL_PATH/lib/pkgconfig:$PKG_CONFIG_PATH ./configure --with-png=no --with-harfbuzz=no --prefix=$EXT_INSTALL_PATH
  make all "-j${make_parallel}"
  make install
  cd ..

fi
#---------

if [ $fontconfig_build -eq 1 ]; then
  banner "Fontconfig"

  PKG_CONFIG_PATH=$EXT_INSTALL_PATH/lib/pkgconfig:$PKG_CONFIG_PATH ./fontconfig/build.sh
fi

#--------

#--------harfbuzz

if [ $harfbuzz_build -eq 1 ]; then
  banner "harfbuzz"

  ./harfbuzz/build.sh
fi

#-------- openssl

if [ $openssl_build -eq 1 ]; then
  banner "openssl"

  cp -r ${OPENSSL_DIR}/* $EXT_INSTALL_PATH
fi

#--------- CURL

if [ $curl_build -eq 1 ]; then

  banner "CURL"

  cd curl

  CPPFLAGS="-I${EXT_INSTALL_PATH}/include -I${EXT_INSTALL_PATH}/openssl/include" LDFLAGS="-L${EXT_INSTALL_PATH}/lib -Wl,-rpath,${EXT_INSTALL_PATH}/lib " LIBS="-ldl -lpthread" PKG_CONFIG_PATH="${EXT_INSTALL_PATH}/lib/pkgconfig:$PKG_CONFIG_PATH" ./configure --with-ssl="${EXT_INSTALL_PATH}" --prefix=$EXT_INSTALL_PATH

  if [ "$(uname)" = "Darwin" ]; then
    #Removing api definition for Yosemite compatibility.
    sed -i '' '/#define HAVE_CLOCK_GETTIME_MONOTONIC 1/d' lib/curl_config.h
  fi

  
  make all "-j${make_parallel}"
  make install
  cd ..

fi
#---------

#--------- ZLIB

if [ $zlib_build -eq 1 ]; then

  banner "ZLIB"

  cd zlib
  ./configure --prefix=$EXT_INSTALL_PATH
  make all "-j${make_parallel}"
  make install
  cd ..

fi
#---------

#--------- LIBJPEG TURBO (Non -macOS)

if [ "$(uname)" != "Darwin" ]
then
  if [ $libjpegturbo_build -eq 1 ]; then
  
    banner "TURBO"
  
    cd libjpeg-turbo
    git update-index --assume-unchanged Makefile.in
    git update-index --assume-unchanged aclocal.m4
    git update-index --assume-unchanged ar-lib
    git update-index --assume-unchanged compile
    git update-index --assume-unchanged config.guess
    git update-index --assume-unchanged config.h.in
    git update-index --assume-unchanged config.sub
    git update-index --assume-unchanged configure
    git update-index --assume-unchanged depcomp
    git update-index --assume-unchanged install-sh
    git update-index --assume-unchanged java/Makefile.in
    git update-index --assume-unchanged ltmain.sh
    git update-index --assume-unchanged md5/Makefile.in
    git update-index --assume-unchanged missing
    git update-index --assume-unchanged simd/Makefile.in
  
    autoreconf -f -i
    ./configure --prefix=$EXT_INSTALL_PATH
    make "-j${make_parallel}"
    make install
    cd ..
  
  fi
fi
#--------

#--------- LIBNODE

if [ $libnode_build -eq 1 ]; then
  banner "NODE"
  if [ -e "${EXT_INSTALL_PATH}/include/unicode" ]
  then
    mv ${EXT_INSTALL_PATH}/include/unicode ${EXT_INSTALL_PATH}/include/unicode_old
  fi
  if [ -e "node-v${NODE_VER}_mods.patch" ]
  then
    git apply "node-v${NODE_VER}_mods.patch"
    git apply "openssl_1.0.2_compatibility.patch"
  fi

  cd "libnode-v${NODE_VER}"
  ./configure --shared --shared-openssl --shared-openssl-includes="${EXT_INSTALL_PATH}/include/" --shared-openssl-libpath="${EXT_INSTALL_PATH}/lib"
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
  if [ -e "${EXT_INSTALL_PATH}/include/unicode_old" ]
  then
    mv ${EXT_INSTALL_PATH}/include/unicode_old ${EXT_INSTALL_PATH}/include/unicode
  fi

  mkdir -p ${EXT_INSTALL_INCLUDE_PATH}/node
  cp ${NODE_DIR}/src/node.h ${EXT_INSTALL_INCLUDE_PATH}/node/.
  cp ${NODE_DIR}/src/node_contextify_mods.h ${EXT_INSTALL_INCLUDE_PATH}/node/.
  cp ${NODE_DIR}/src/node_internals.h ${EXT_INSTALL_INCLUDE_PATH}/node/.
  cp ${NODE_DIR}/src/module_wrap.h ${EXT_INSTALL_INCLUDE_PATH}/node/.
  cp ${NODE_DIR}/src/env-inl.h ${EXT_INSTALL_INCLUDE_PATH}/node/.
  cp ${NODE_DIR}/src/env.h ${EXT_INSTALL_INCLUDE_PATH}/node/.
  cp ${NODE_DIR}/src/stream_wrap.h ${EXT_INSTALL_INCLUDE_PATH}/node/.
  cp ${NODE_DIR}/src/tcp_wrap.h ${EXT_INSTALL_INCLUDE_PATH}/node/.
  cp ${NODE_DIR}/src/node_crypto.h ${EXT_INSTALL_INCLUDE_PATH}/node/.
  if [ "$(uname)" != "Darwin" ]
  then
    cp -R ${NODE_LIB_DIR}/libnode.so.64 ${EXT_INSTALL_LIB_PATH}/.
    cp -R ${NODE_LIB_DIR}/../node ${EXT_INSTALL_BIN_PATH}/.
  else
    cp -R ${NODE_LIB_DIR}/../libnode.*.dylib ${EXT_INSTALL_LIB_PATH}/.
    cp -R ${NODE_LIB_DIR}/../node ${EXT_INSTALL_LIB_PATH}/.
  fi
fi
##---------
#
if [ "$(uname)" != "Darwin" ]
then
  if [ $breakpadchrome_build -eq 1 ]; then
    ./breakpad/build.sh
    cp -R ${BREAKPAD_LIB_DIR}/libbreakpad_client.a ${EXT_INSTALL_LIB_PATH}/.
    mkdir -p ${EXT_INSTALL_INCLUDE_PATH}/breakpad
    cp -R ${BREAKPAD_INCLUDE_DIR}/src/* ${EXT_INSTALL_INCLUDE_PATH}/breakpad/.
    find ${EXT_INSTALL_INCLUDE_PATH}/breakpad/ -type f ! -name "*.h" -exec rm -rf {} \;
  fi
fi
#---------

if [ $nanosvg_build -eq 1 ]; then
#-------- NANOSVG

  banner "NANOSVG"

  ./nanosvg/build.sh
  mkdir -p ${EXT_INSTALL_INCLUDE_PATH}/nanosvg
  cp ${NANOSVG_DIR}/src/nanosvgrast.h ${EXT_INSTALL_INCLUDE_PATH}/nanosvg/.
fi
#---------

#-------- DUKTAPE

if [ $dukluv_build -eq 1 ]; then
  banner "DUCKTAPE"

  ./dukluv/build.sh
  cp -R ${DUKTAPE_LIB_DIR}/*.a ${EXT_INSTALL_LIB_PATH}/.
fi

#-------- spark-webgl
if [ $sparkwebgl_build -eq 1 ]; then
  export NODE_PATH=$NODE_PATH:`pwd`/../node_modules
  export PATH=`pwd`/node/deps/npm/bin/node-gyp-bin/:`pwd`/node/out/Release:$PATH
  cd spark-webgl
  node-gyp rebuild
  cd ..
  cp ${SPARK_WEBGL_DIR}/gles2.node ${NODE_MODULES_PATH}/.
fi

#--------- uWebSockets
if [ $uwebsockets_build -eq 1 ]; then

  banner "uWEBSOCKETS"

  cd uWebSockets

  if [ -e Makefile.build ]
  then
    mv Makefile.build Makefile
  fi

  CPPFLAGS="-I${EXT_INSTALL_PATH} -I${EXT_INSTALL_PATH}/openssl/include" LDFLAGS="-L${EXT_INSTALL_PATH}/lib -Wl,-rpath,${EXT_INSTALL_PATH}/lib " make
  cd ..

fi

if [ $sqliteautoconf_build -eq 1 ]; then
  banner "SQLITE"

  cd sqlite
  autoreconf -f -i
  ./configure --prefix=$EXT_INSTALL_PATH
  make -j3
  #grep -rn "_sqlite3_intarray_bind" .
  make install
  ls -rlt ${SQLITE_LIB_DIR}
  cd ..
  if [ "$(uname)" != "Darwin" ]
  then
    cp ${SQLITE_LIB_DIR}/libsqlite*.so* ${EXT_INSTALL_LIB_PATH}/.
    cp ${SQLITE_LIB_DIR}/libsqlite*.a* ${EXT_INSTALL_LIB_PATH}/.
  else
    cp ${SQLITE_LIB_DIR}/libsqlite* ${EXT_INSTALL_LIB_PATH}/.
    #cp ${SQLITE_LIB_DIR}/libsqlite* ${EXT_INSTALL_LIB_PATH}/.
  fi
fi

#-------- cJSON

if [ $cjson_build -eq 1 ]; then
  banner "cJSON"

  ./cJSON/build.sh
fi

#--------

#--------orc

if [ $orc_build -eq 1 ]; then
  banner "orc"

  ./orc/build.sh
fi

#--------


#--------ossp-uuid

if [ $osspuuid_build -eq 1 ]; then
  banner "ossp-uuid"

  ./ossp-uuid/build.sh
fi

#--------

#--------libxml2

if [ $libxml2_build -eq 1 ]; then
  banner "libxml2"

  ./libxml2/build.sh
fi

#--------

#-------- libdash

if [ $libdash_build -eq 1 ]; then
  banner "libdash"

  LD_LIBRARY_PATH="$EXT_INSTALL_PATH/lib:$LD_LIBRARY_PATH" PKG_CONFIG_PATH=$EXT_INSTALL_PATH/lib/pkgconfig:$PKG_CONFIG_PATH ./libdash/libdash/build.sh
fi

#--------

#-------- xz-5.2.2

if [ $xz_build -eq 1 ]; then
  banner "xz"

  ./xz/build.sh
fi

#--------

#-------- gstreamer-1.16

if [ $gstreamer_build -eq 1 ]; then
  banner "gstreamer-1.16"

  ./gstreamer/build.sh
fi

#--------

#-------- gst-plugin-base

if [ $gstpluginsbase_build -eq 1 ]; then
  banner "gst-plugins-base"

  ./gst-plugins-base/build.sh
fi

#--------
#-------- gst-plugin-bad

if [ $gstpluginsbad_build -eq 1 ]; then
  banner "gst-plugins-bad"

  ./gst-plugins-bad/build.sh
fi

#--------
#-------- gst-plugin-ugly

if [ $gstpluginsugly_build -eq 1 ]; then
  banner "gst-plugins-ugly"

  ./gst-plugins-ugly/build.sh
fi

#--------
#-------- gst-plugin-good

if [ $gstpluginsgood_build -eq 1 ]; then
  banner "gst-plugins-good"

  ./gst-plugins-good/build.sh
fi

#--------
#-------- gst-libav

if [ $gstlibav_build -eq 1 ]; then
  banner "gst-libav"

  ./gst-libav/build.sh
fi

#--------

#-------- aampabr

if [ $aampbr_build -eq 1 ]; then
  banner "aampabr"

  ./aampabr/build.sh
fi

#--------

#-------- aamp

if [ $aamp_build -eq 1 ]; then
  banner "aamp"

  ./aamp/build.sh
fi

#--------
rm -rf extlibs
unset CCACHE_DISABLE
