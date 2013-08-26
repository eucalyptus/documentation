#!/bin/sh

rm -rf makefile tests

for i in *.java; do
    cp $i /tmp/rename_package.tmp
    sed -e 's^legal.txt^LEGAL.txt^g' /tmp/rename_package.tmp > $i
done

cp SystemUtil.java /tmp/rename_package.tmp
sed -e 's^XMLEditor5^ditac^g' \
    -e 's^"xxe5"^"ditac"^g' \
    /tmp/rename_package.tmp > SystemUtil.java

