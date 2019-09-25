#!/bin/bash

checkError()
{
  if [ "$1" -ne 0 ]
  then
    printf "\n\n*********************************************************************";
    printf "\n********************* SCRIPT FAIL DETAILS *****************************";
    printf "\nCI failure reason: $2"
    printf "\nCause: $3"
    printf "\nReproduction/How to fix: $4"
    printf "\n*********************************************************************\n\n";
    exit 1
  fi
}

NODE_VER="10.15.3"

#mention dirs for other externals directory
BREAKPAD_LIB_DIR="`pwd`/breakpad-chrome_55/src/client/linux/"
GIF_LIB_DIR="`pwd`/gif/.libs/"
NODE_LIB_DIR="`pwd`/libnode-v${NODE_VER}/out/Release/obj.target"
OPENSSL_LIB_DIR="`pwd`/openssl-1.0.2o/"
SPARK_WEBGL_DIR="`pwd`/spark-webgl/build/Release/"
#EXT_LIBS_DIR=`pwd`/extlibs/lib
#EXT_INCLUDE_DIR=`pwd`/extlibs/include

#copy to external directories
EXT_INSTALL_PATH=$PWD/artifacts/${TRAVIS_OS_NAME}
EXT_INSTALL_LIB_PATH=${EXT_INSTALL_PATH}/lib
EXT_INSTALL_INCLUDE_PATH=${EXT_INSTALL_PATH}/include
EXT_INSTALL_BIN_PATH=${EXT_INSTALL_PATH}/bin
NODE_MODULES_PATH=${EXT_INSTALL_PATH}/node_modules

find $EXT_INSTALL_PATH -name "*.o"|xargs rm -rf

if [ "$(uname)" != "Darwin" ]
then
  cp -R ${NODE_LIB_DIR}/libnode.so.64 ${EXT_INSTALL_LIB_PATH}/.
  cp -R ${NODE_LIB_DIR}/../node ${EXT_INSTALL_BIN_PATH}/.
  cp -R ${BREAKPAD_LIB_DIR}/libbreakpad_client.a ${EXT_INSTALL_LIB_PATH}/.
  find ${GIF_LIB_DIR} -name libgif*
  cp -R ${GIF_LIB_DIR}/libgif.so ${EXT_INSTALL_LIB_PATH}/.
  cp -R ${GIF_LIB_DIR}/libutil.so ${EXT_INSTALL_LIB_PATH}/.
else
  cp -R ${NODE_LIB_DIR}/../libnode.*.dylib ${EXT_INSTALL_LIB_PATH}/.
  cp -R ${NODE_LIB_DIR}/../node ${EXT_INSTALL_LIB_PATH}/.
  find ${GIF_LIB_DIR} -name libgif*
  cp -R ${GIF_LIB_DIR}/libgif.*.dylib ${EXT_INSTALL_LIB_PATH}/.
  cp -R ${GIF_LIB_DIR}/libutil.*.dylib ${EXT_INSTALL_LIB_PATH}/.
fi
cp ${SPARK_WEBGL_DIR}/gles2.node ${NODE_MODULES_PATH}/.

#copy all externals dirs
#cp -R ${EXT_LIBS_DIR}/* ${EXT_INSTALL_LIB_PATH}/.
#cp -R ${EXT_INCLUDE_DIR}/* ${EXT_INSTALL_INCLUDE_PATH}/.

#perform git commit
git checkout $TRAVIS_BRANCH
REPO_USER_NAME=`echo $TRAVIS_REPO_SLUG | cut -d'/' -f 1`
REPO_NAME=`echo $TRAVIS_REPO_SLUG | cut -d'/' -f 2`
git pull https://$REPO_USER_NAME:$GH_TOKEN@github.com/$REPO_USER_NAME/$REPO_NAME.git master
git add ${EXT_INSTALL_PATH}
if [ "$TRAVIS_PULL_REQUEST" != "false" ]
then
  git status .
  exit 0;
fi
git commit -m "update ${TRAVIS_OS_NAME} externals [skip ci]"
git push --repo="https://$REPO_USER_NAME:$GH_TOKEN@github.com/$REPO_USER_NAME/$REPO_NAME.git" 
checkError $? "unable to commit data to repo" "" "check the credentials"
