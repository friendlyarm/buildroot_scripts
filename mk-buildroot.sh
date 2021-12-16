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

TARGET_BUILDROOT_CONFIG=$1
BUILDROOT_SRC_PATHNAME=$2
echo "============Start building friendlywrt============"
echo "TARGET_BUILDROOT_CONFIG = $TARGET_BUILDROOT_CONFIG"
echo "BUILDROOT_SRC_PATHNAME = $BUILDROOT_SRC_PATHNAME"
echo "=========================================="

cd ${TOP_DIR}/${BUILDROOT_SRC_PATHNAME}
export FORCE_UNSAFE_CONFIGURE=1
if [ ! -f .config ]; then
    make ${TARGET_BUILDROOT_CONFIG}
else
    echo "using .config file"
fi

make source -j$(nproc)
RET=$?
if [ $RET -ne 0 ]; then
    exit 1
fi

make -j$(nproc) V=s
RET=$?
if [ $RET -ne 0 ]; then
    exit 1
fi

exit 0
