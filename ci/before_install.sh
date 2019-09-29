#!/bin/sh

travis_retry() {
  local result=0
  local count=1
  while [ $count -le 3 ]; do
    [ $result -ne 0 ] && {
      echo -e "\n$The command \"$@\" failed *******************. Retrying, $count of 3.\n" >&2
    }
    "$@"
    result=$?
    [ $result -eq 0 ] && break
    count=$(($count + 1))
    sleep 1
  done

  [ $count -gt 3 ] && {
    echo -e "\n$The command \"$@\" failed 3 times *******************.\n" >&2
  }

  return $result
}

#start the monitor
$TRAVIS_BUILD_DIR/ci/monitor.sh &

#install necessary basic packages for linux and mac 
if [ "$TRAVIS_OS_NAME" = "linux" ] ;
then
  travis_retry sudo apt-get update
  travis_retry sudo apt-get install git libglew-dev freeglut3 freeglut3-dev zlib1g-dev g++ nasm autoconf libyaml-dev quilt libuv-dev xmlto yasm bison flex python
fi

if [ "$TRAVIS_OS_NAME" = "osx" ] ;
then
  brew update;
  brew install yasm bison flex python
  ln -sf /usr/local/opt/bison/bin/bison /usr/local/bin/bison
  brew install quilt
  brew install libuv
  brew install xmlto
  brew install pkg-config glfw3 glew
  sudo /usr/sbin/DevToolsSecurity --enable
  cmake --version
fi
