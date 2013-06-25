#!/bin/sh

rm -rf out/*

echo "Converting sample.ditamap to XHTML..."

../../../bin/ditac -plugin sample_plugin \
    -chunk single \
    -p xsl-resources-directory resources \
    -p css resources/sample.css \
    out/sample.html sample.ditamap

cp sample.css out/resources

echo "Converting sample.ditamap to PDF..."

../../../bin/ditac -plugin sample_plugin \
    out/sample.pdf sample.ditamap
