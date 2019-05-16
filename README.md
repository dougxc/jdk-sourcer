A tool for creating a src.zip containing *all* the Java sources for Java classes in a JDK.
Only the JDK source layout introduced in JDK 10 is currently supported.

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

## Prebuilt Source Archives

[jdk-11+20.src.zip](https://github.com/dougxc/jdk-sourcer/releases/download/jdk-11%2B20/jdk-11+20.src.zip.sha1)
[jdk-11+20.src.zip.sha1](https://github.com/dougxc/jdk-sourcer/releases/download/jdk-11%2B20/jdk-11+20.src.zip.sha1)
