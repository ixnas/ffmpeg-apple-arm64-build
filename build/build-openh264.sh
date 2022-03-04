#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# start in working directory
SOFTWARE=openh264

make_directories() {

  # start in working directory
  cd "$2"
  checkStatus $? "change directory failed"
  mkdir ${SOFTWARE}
  checkStatus $? "create directory failed"
  cd ${SOFTWARE}
  checkStatus $? "change directory failed"

}

download_code () {

  cd "$2/${SOFTWARE}"
  checkStatus $? "change directory failed"
  # download source
  git clone --depth 1 https://github.com/cisco/openh264.git
  checkStatus $? "download of ${SOFTWARE} failed"


}

configure_build () {

  #no configure or cmake
  echo "No configure or cmake for $SOFTWARE"

}

make_clean() {

  cd "$2/${SOFTWARE}/openh264/"
  checkStatus $? "change directory failed"
  make PREFIX="$3" clean
  checkStatus $? "make clean for $SOFTWARE failed"


}

make_compile () {

  cd "$2/${SOFTWARE}/openh264/"
  checkStatus $? "change directory failed"

  # compatibility patch until ffmpeg changes its include paths from wels to openh264.
  patch -p1 < $1/patches/openh264.patch
  checkStatus $? "patch of ${SOFTWARE} failed"

  # build
  make PREFIX="$3" -j $4
  checkStatus $? "build of ${SOFTWARE} failed"

  # install
  make PREFIX="$3" install
  checkStatus $? "installation of ${SOFTWARE} failed"

  # remove dynamic lib
  rm $3/lib/libopenh264*.dylib

}

build_main () {


set -x

  if [[ -d "$2/${SOFTWARE}" && "${ACTION}" == "skip" ]]
  then
      return 0
  elif [[ -d "$2/${SOFTWARE}" && -z "${ACTION}" ]]
  then
      echo "${SOFTWARE} build directory already exists but no action set. Exiting script"
      exit 0
  fi


  if [[ ! -d "$2/${SOFTWARE}" ]]
  then
    make_directories $@
    download_code $@
    configure_build $@
  fi

  make_clean $@
  make_compile $@

}

build_main $@


