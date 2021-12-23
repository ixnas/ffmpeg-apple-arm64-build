#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = libvpx version

# load functions
. $1/functions.sh

SOFTWARE=vpx

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
  git clone --depth 1 https://chromium.googlesource.com/webm/libvpx
  checkStatus $? "download of ${SOFTWARE} failed"
  cd "libvpx/"
  checkStatus $? "change directory failed"

}

configure_build () {

  cd "$2/${SOFTWARE}/libvpx/"
  checkStatus $? "change directory failed"

# prepare build
sed -i.original -e 's/-march=armv8-a//g' build/make/configure.sh

./configure --prefix="$3" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --enable-vp8 \
                    --enable-vp9 \
                    --enable-internal-stats \
                    --enable-pic \
                    --enable-postproc \
                    --enable-multithread \
                    --enable-experimental \
                    --disable-install-docs \
                    --disable-debug-libs
  
  checkStatus $? "configuration of vpx failed"

}

make_clean() {

  cd "$2/${SOFTWARE}/libvpx/"
  checkStatus $? "change directory failed"
  make clean
  checkStatus $? "make clean for $SOFTWARE failed"

}

make_compile () {

  cd "$2/${SOFTWARE}/libvpx/"
  checkStatus $? "change directory failed"

  # build
  make -j $4
  checkStatus $? "build of ${SOFTWARE} failed"

  # install
  make install
  checkStatus $? "installation of ${SOFTWARE} failed"

}

build_main () {

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
