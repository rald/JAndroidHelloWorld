#!/bin/bash

rm -rf obj gen output HelloWorld.apk

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

ecj -cp android-30.jar -d obj $JAVAFILES

dx --dex --output=output/classes.dex obj

aapt package -f -m \
		-J gen \
    -S res \
    -M AndroidManifest.xml \
    -I android-30.jar \
    -F output/HelloWorld.apk \
    output

#zip -u output/HelloWorld.apk output/classes.dex

zipalign -v 4 output/HelloWorld.apk output/HelloWorld-aligned.apk

apksigner sign --ks android.jks --ks-key-alias android --ks-pass pass:android --key-pass pass:android output/HelloWorld-aligned.apk

cp output/HelloWorld-aligned.apk HelloWorld.apk
