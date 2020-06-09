#!/bin/bash
#
# Utility for creating a src.zip from *all* the Java source files in a JDK workspace.
#

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
    url=http://hg.openjdk.java.net/jdk/jdk${JDK_VERSION}/archive/${jdk_tag}.zip/src/
    if [ ! -e downloaded-${jdk_tag}.zip ]; then
        echo "Downloading $url"
        if type -p curl >/dev/null ; then
            curl -o downloaded-${jdk_tag}.zip $url
        elif type -p wget >/dev/null ; then
            wget -O downloaded-${jdk_tag}.zip $url
        else
            "Neither wget nor curl are available"
            exit 1
        fi
    fi
    if [ -e downloaded-${jdk_tag} ]; then
        echo "Removing downloaded-${jdk_tag} ..."
        rm -rf downloaded-${jdk_tag}
    fi
    echo "Unzipping downloaded-${jdk_tag}.zip ..."
    unzip -q downloaded-${jdk_tag}.zip "jdk${JDK_VERSION}-${jdk_tag}/src/*"
    jdk_root=${PWD}/jdk${JDK_VERSION}-${jdk_tag}
else
    echo "Usage: $0 <path to JDK repo> <path to zipfile>"
    echo "   or: $0 <tag at http://hg.openjdk.java.net/jdk/jdk\${JDK_VERSION}>"
    echo ""
    echo "Examples:"
    echo "  $0 ~/closed/jdk8u251 jdk8u251.src.zip"
    echo "  $0 ~/jdk-jdk/open jdk-snapshot.src.zip"
    echo "  $0 jdk-13+21"
    echo "  env JDK_VERSION=13 $0 jdk-13+25"
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
    echo "Removing jdk-${jdk_tag} ..."
    rm -rf jdk-${jdk_tag}
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
