@echo off

del /q out\*.*

echo "Converting sample.ditamap to XHTML..."

call ..\..\..\bin\ditac.bat -plugin sample_plugin -chunk single -p xsl-resources-directory resources -p css resources/sample.css out\sample.html sample.ditamap

copy sample.css out\resources

echo "Converting sample.ditamap to PDF..."

call ..\..\..\bin\ditac.bat -plugin sample_plugin out\sample.pdf sample.ditamap

