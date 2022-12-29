#!/bin/sh

SBCL_VERSION="2.3.0"

apt-get install make clang zstd git

sbcl_xc_host="sbcl"

if ! command -v sbcl > /dev/null
then
    if ! command -v ecl > /dev/null
    then
        git clone git@gitlab.com:embeddable-common-lisp/ecl.git
        cd ecl
        ./configure --prefix=/data/data/com.termux/files/usr/
        make -j8
        make install
        cd ..
    fi
    sbcl_xc_host="ecl --c-stack 16777217 --norc"
fi

curl -L "http://downloads.sourceforge.net/project/sbcl/sbcl/$SBCL_VERSION/sbcl-$SBCL_VERSION-source.tar.bz2" -o "sbcl-$SBCL_VERSION-source.tar.bz2"
tar -xvjf "sbcl-$SBCL_VERSION-source.tar.bz2"
cd "sbcl-$SBCL_VERSION"
sed -i "s/#ifdef SVR4/#if defined(SVR4) || defined(LISP_FEATURE_ANDROID)/" src/runtime/run-program.c
sed -i "/#+android (\"src\/code\/android-os\" :not-host)/d" src/cold/build-order.lisp-expr
sh make.sh --xc-host="$sbcl_xc_host" --with-android --fancy --prefix=/data/data/com.termux/files/usr/ --without-gcc-tls
cd ..
