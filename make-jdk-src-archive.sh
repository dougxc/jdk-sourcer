#!/bin/bash
#
# Utility for creating a src.zip from *all* the Java source files in a JDK workspace.
#

#set -x
if [ $# -eq 2 ]; then
    archive_dir=$(dirname $2)
    mkdir -p $archive_dir || { echo "Could not create $archive_dir"; exit 1; }
    pushd $archive_dir >/dev/null
    src_zip=$(/bin/pwd)/$(basename $2)
    popd >/dev/null

    if [ -e $src_zip ]; then
        echo "Cannot overwrite $src_zip - please delete it first"
        exit 1
    fi
    jdk_root=$1
elif [ $# -eq 1 ]; then
    jdk_tag=$1
    src_zip=${PWD}/${jdk_tag}.src.zip
    if [[ $jdk_tag =~ ^jdk-([0-9]+)(\.[0-9]+\.[0-9]+)?(\+([0-9]+))$ ]]; then
        MAJOR_VERSION=${BASH_REMATCH[1]}
        MINOR_UPDATE=${BASH_REMATCH[2]}
        if [ -n "${MINOR_UPDATE}" ]; then
            REPO=jdk${MAJOR_VERSION}u
        else
            REPO=jdk${MAJOR_VERSION}
        fi
        TOP_ARCHIVE_DIR=${REPO}-${jdk_tag/+/-}
        url=https://github.com/openjdk/${REPO}/archive/refs/tags/${jdk_tag}.zip
    else
        echo "JDK tag does not match expected pattern: $jdk_tag"
        echo "Expected pattern: jdk-<major>[.<minor>.<update>][+<build>]"
        exit 1
    fi
    if [ ! -e downloaded-${jdk_tag}.zip ]; then
        echo "Downloading $url"
        if type -p wget >/dev/null ; then
            wget -O downloaded-${jdk_tag}.zip $url
        elif type -p curl >/dev/null ; then
            curl -o downloaded-${jdk_tag}.zip $url
        else
            echo "Neither wget nor curl are available"
            exit 1
        fi
    fi
    echo "Unzipping downloaded-${jdk_tag}.zip ..."
    unzip -q downloaded-${jdk_tag}.zip "${TOP_ARCHIVE_DIR}/src/*"
    jdk_root=${PWD}/${TOP_ARCHIVE_DIR}
else
    echo "Usage: $0 <path to JDK repo> <path to zipfile>"
    echo "   or: $0 <tag at https://github.com/openjdk/jdk${JDK_VERSION}u/archive/refs/tags/jdk-${JDK_VERSION}.zip>"
    echo ""
    echo "Examples:"
    echo "  $0 ~/closed/jdk8u251 jdk8u251.src.zip"
    echo "  $0 ~/jdk-jdk/open jdk-snapshot.src.zip"
    echo "  $0 13+21"
    echo "  $0 jdk-13+25"
    exit 1;
fi

dirs=""
src_root=$jdk_root/src
if [ -d $src_root/jdk.internal.vm.ci ]; then
    # JDK >= 10
    for d in $(find $src_root -name classes -a -type d); do
        alt_layout_dirs=$(ls -d $d/*/src 2>/dev/null)
        if [ -n "$alt_layout_dirs" ]; then
            dirs="$dirs $alt_layout_dirs"
        else
            dirs="$dirs $d"
        fi
    done
    archive_py=archive.py
    archive_py_args="$src_zip $src_root $dirs"
else
    # JDK < 9
    dirs=$(find $jdk_root -maxdepth 6 -name classes -a -type d)
    archive_py=archive8.py
    archive_py_args="$src_zip $dirs"
fi

source="${BASH_SOURCE[0]}"
while [ -h "$source" ] ; do source="$(readlink "$source")"; done
DIR="$( cd -P "$( dirname "$source" )" && pwd )"
python ${DIR}/${archive_py} ${archive_py_args}

if [ $# -eq 1 ]; then
    echo "Removing ${TOP_ARCHIVE_DIR} ..."
    rm -rf ${TOP_ARCHIVE_DIR}
fi

echo "Created ${src_zip}"

if type -p shasum >/dev/null ; then
    shasum ${src_zip} | awk '{print $1}' > ${src_zip}.sha1
    echo "Created ${src_zip}.sha1"
elif type -p sha1sum >/dev/null ; then
    sha1sum ${src_zip} | awk '{print $1}' > ${src_zip}.sha1
    echo "Created ${src_zip}.sha1"
else
    echo "Neither sha1sum not shasum is available - skipping generation of ${src_zip}.sha1"
fi
