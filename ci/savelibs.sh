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
NODE_LIB_DIR="`pwd`/libnode-v${NODE_VER}/out/Release/obj.target/"
OPENSSL_LIB_DIR="`pwd`/openssl-1.0.2o/"
SPARK_WEBGL_DIR="`pwd`/spark-webgl/build/Release/"

#copy to external directories
EXT_INSTALL_PATH=$PWD/artifacts/${TRAVIS_OS_NAME}
if [ "$(uname)" != "Darwin" ]
then
  cp -R ${NODE_LIB_DIR}/libnode.so.64 ${EXT_INSTALL_PATH}/.
  cp -R ${NODE_LIB_DIR}/../node ${EXT_INSTALL_PATH}/.
  cp -R ${OPENSSL_LIB_DIR}/libcrypto.so.1.0.0 ${EXT_INSTALL_PATH}/.
  cp -R ${OPENSSL_LIB_DIR}/libssl.so.1.0.0 ${EXT_INSTALL_PATH}/.
else
  cp -R ${NODE_LIB_DIR}/../libnode.*.dylib ${EXT_INSTALL_PATH}/.
  cp -R ${NODE_LIB_DIR}/../node ${EXT_INSTALL_PATH}/.
  cp -R ${OPENSSL_LIB_DIR}/libcrypto.*.dylib ${EXT_INSTALL_PATH}/.
  cp -R ${OPENSSL_LIB_DIR}/libssl.*.dylib ${EXT_INSTALL_PATH}/.
fi
cp ${SPARK_WEBGL_DIR}/gles2.node ${EXT_INSTALL_PATH}/.

#perform git commit
git checkout $TRAVIS_BRANCH
REPO_USER_NAME=`echo $TRAVIS_REPO_SLUG | cut -d'/' -f 1`
REPO_NAME=`echo $TRAVIS_REPO_SLUG | cut -d'/' -f 2`
git pull https://$REPO_USER_NAME:$GH_TOKEN@github.com/$REPO_USER_NAME/$REPO_NAME.git master
git add ${EXT_INSTALL_PATH}
git commit -m "update ${TRAVIS_OS_NAME} externals [skip ci]"
git push --repo="https://$REPO_USER_NAME:$GH_TOKEN@github.com/$REPO_USER_NAME/$REPO_NAME.git" 
checkError $? "unable to commit data to repo" "" "check the credentials"
