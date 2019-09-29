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

##copy to external directories
EXT_INSTALL_PATH=$PWD/artifacts/${TRAVIS_OS_NAME}
EXT_INSTALL_LIB_PATH=${EXT_INSTALL_PATH}/lib
EXT_INSTALL_INCLUDE_PATH=${EXT_INSTALL_PATH}/include
EXT_INSTALL_BIN_PATH=${EXT_INSTALL_PATH}/bin
NODE_MODULES_PATH=${EXT_INSTALL_PATH}/node_modules

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
