#!/bin/bash

rm -rf bin obj gen output HelloWorld.apk

mkdir bin
mkdir obj
mkdir gen
mkdir output

aapt package -f -m \
	-J gen \
	-M AndroidManifest.xml \
	-S res \
	-I android-30.jar

JAVAFILES=""
for JAVAFILE in $(find . -type f -name "*.java")
do
    JAVAFILES="$JAVAFILES $JAVAFILE"
done

javac -cp android-30.jar -d obj $JAVAFILES

d8 $(find obj -name '*.class') --lib android-30.jar --output output

aapt package -f -m \
	-J gen \
    -S res \
    -M AndroidManifest.xml \
    -I android-30.jar \
    -F bin/HelloWorld.apk \
    output

zipalign -v 4 bin/HelloWorld.apk bin/HelloWorld-aligned.apk

apksigner sign --ks android.keystore --ks-key-alias android --ks-pass pass:android --key-pass pass:android bin/HelloWorld-aligned.apk

cp bin/HelloWorld-aligned.apk HelloWorld.apk
