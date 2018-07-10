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
    url=http://hg.openjdk.java.net/jdk/jdk/archive/${jdk_tag}.zip/src/
    if [ ! -e jdk-${jdk_tag}.zip ]; then
        echo "Downloading $url"
        if type -p curl >/dev/null ; then
            curl -o jdk-${jdk_tag}.zip $url
        elif type -p wget >/dev/null ; then
            wget -O jdk-${jdk_tag}.zip $url
        else
            "Neither wget nor curl are available"
            exit 1
        fi
    fi
    if [ -e jdk-${jdk_tag} ]; then
        echo "Removing jdk-${jdk_tag} ..."
        rm -rf jdk-${jdk_tag}
    fi
    echo "Unzipping jdk-${jdk_tag}.zip ..."
    unzip -q jdk-${jdk_tag}.zip "jdk-${jdk_tag}/src/*"
    jdk_root=${PWD}/jdk-${jdk_tag}
else
    echo "Usage: $0 <path to JDK repo> <path to zipfile>"
    echo "   or: $0 <JDK tag>"
    exit 1;
fi

pushd $jdk_root >/dev/null
dirs=""
if [ -d src/jdk.internal.vm.ci ]; then
    # JDK >= 10
    for d in $(find src -name classes -a -type d); do
        alt_layout_dirs=$(ls -d $d/*/src 2>/dev/null)
        if [ -n "$alt_layout_dirs" ]; then
            dirs="$dirs $alt_layout_dirs"
        else
            dirs="$dirs $d"
        fi
    done
else
    echo "Unsupported/unknown JDK layout"
    exit 1
fi

for classes_dir in $dirs; do
    echo "Adding sources from $classes_dir ..."
    pushd $classes_dir >/dev/null
    zip -r -q -u $src_zip . -i \*.java -x \*SCCS\*
    popd >/dev/null
done
popd >/dev/null

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
