#!/bin/bash

set -eu

SCRIPTS_DIR=$(cd `dirname $0`; pwd)
if [ -h $0 ]
then
    CMD=$(readlink $0)
    SCRIPTS_DIR=$(dirname $CMD)
fi
cd $SCRIPTS_DIR
cd ../
TOP_DIR=$(pwd)

cd ${TOP_DIR}/${BUILDROOT_SRC}
export FORCE_UNSAFE_CONFIGURE=1
if [ ! -f ${BUILDROOT_OUTDIR}/.config ]; then
    make ${TARGET_BUILDROOT_CONFIG}
else
    echo "using .config file"
fi
unset FORCE_UNSAFE_CONFIGURE

make source -j$(nproc)
RET=$?
if [ $RET -ne 0 ]; then
	make source -j1
	RET=$?
	if [ $RET -ne 0 ]; then
		exit 1
	fi
fi

rm -f /tmp/buildroot-make-j$(nproc)-log.txt
rm -f /tmp/buildroot-make-j1-log.txt
env > /tmp/buildroot-make-env.txt

make -j$(nproc) 2>&1 | tee /tmp/buildroot-make-j$(nproc)-log.txt
RET=$?
if [ $RET -eq 0 ]; then
	exit 0
fi

make -j1 V=s 2>&1 | tee /tmp/buildroot-make-j1-log.txt
RET=$?
if [ $RET -eq 0 ]; then
	exit 0
fi

exit 1
