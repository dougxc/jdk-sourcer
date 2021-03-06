A tool for creating a src.zip containing *all* the Java sources for Java classes in a JDK.

To create a src.zip from a local JDK repo:
```
./make-jdk-src-archive.sh <path to JDK repo> <path to zipfile>
```
For example:
```
./make-jdk-src-archive.sh ~/jdk-jdk/open jdk-snapshot.src.zip
```


To archive the sources at http://hg.openjdk.java.net/jdk/jdk corresponding to a tagged commit:
```
./make-jdk-src-archive.sh <JDK tag>
```
For example:
```
./make-jdk-src-archive.sh jdk-11+20
```

The above will create a file named `jdk-11+20.src.zip`.

You can specify a specific JDK version with the JDK_VERSION environment variable. For example:
```
env JDK_VERSION=13 ./make-jdk-src-archive.sh jdk-13+25
```

## Prebuilt Source Archives

[jdk-11+20.src.zip](https://github.com/dougxc/jdk-sourcer/releases/download/jdk-11%2B20/jdk-11+20.src.zip)([sha1](https://github.com/dougxc/jdk-sourcer/releases/download/jdk-11%2B20/jdk-11+20.src.zip.sha1))

[jdk-13+21.src.zip](https://github.com/dougxc/jdk-sourcer/releases/download/jdk-13%2B21/jdk-13+21.src.zip)([sha1](https://github.com/dougxc/jdk-sourcer/releases/download/jdk-13%2B21/jdk-13+21.src.zip.sha1))

[jdk-13+25.src.zip](https://github.com/dougxc/jdk-sourcer/releases/download/jdk-13%2B25/jdk-13+25.src.zip)([sha1](https://github.com/dougxc/jdk-sourcer/releases/download/jdk-13%2B25/jdk-13+25.src.zip.sha1))
