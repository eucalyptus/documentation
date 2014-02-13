@echo off

REM  Oxygen Webhelp plugin
REM  Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
REM  Licensed under the terms stated in the license file EULA_Webhelp.txt 
REM  available in the base directory of this Oxygen Webhelp plugin.


REM The path of the Java Virtual Machine install directory
set JVM_INSTALL_DIR=C:\Program Files\Java\jdk1.6.0_38

REM The path of the ANT tool install directory
set ANT_INSTALL_DIR=E:\test\webhelp\apache-ant-1.9.1

REM The path of the Saxon 6.5.5 install directory  
set SAXON_6_DIR=E:\test\webhelp\saxon6-5-5

REM The path of the Saxon 9.1.0.8 install directory  
set SAXON_9_DIR=E:\test\webhelp\saxonb9-1-0-8j

REM The path of the Docbook XSL install directory  
set DOCBOOK_XSL_DIR=E:\test\webhelp\docbook-xsl-ns-1.78.1

REM One of the following three values: 
REM      webhelp
REM      webhelp-feedback
REM      webhelp-mobile
set TRANSTYPE=webhelp

REM The path of the input directory, containing the input XML file
set INPUT_DIR=E:\test\OxygenXMLEditor\samples\docbook\v5

REM The name of the input XML file
set XML_INPUT_FILE=sample.xml

REM The path of the output directory, where the output files will be generated
set OUTPUT_DIR=E:\test\OxygenXMLEditor\samples\docbook\v5\out\%TRANSTYPE%

REM The path of the Docbook XSL install directory in URL format  
set DOCBOOK_XSL_DIR_URL=file:/%DOCBOOK_XSL_DIR%


"%JVM_INSTALL_DIR%/bin/java"^
 -Xmx512m^
 -classpath^
 "%ANT_INSTALL_DIR%/lib/ant-launcher.jar"^
 "-Dant.home=%ANT_INSTALL_DIR%" org.apache.tools.ant.launch.Launcher^
 -lib "%DOCBOOK_XSL_DIR%/com.oxygenxml.webhelp/lib/xercesImpl.jar"^
 -lib "%DOCBOOK_XSL_DIR%/com.oxygenxml.webhelp/lib/xml-apis.jar"^
 -lib "%DOCBOOK_XSL_DIR%/com.oxygenxml.webhelp/lib/xml-apis-ext.jar"^
 -lib "%SAXON_6_DIR%/saxon.jar"^
 -lib "%SAXON_9_DIR%/saxon9.jar"^
 -lib "%SAXON_9_DIR%/saxon9-dom.jar"^
 -lib "%DOCBOOK_XSL_DIR%/com.oxygenxml.webhelp/lib/license.jar"^
 -lib "%DOCBOOK_XSL_DIR%/com.oxygenxml.webhelp/lib/log4j.jar"^
 -lib "%DOCBOOK_XSL_DIR%/com.oxygenxml.webhelp/lib/resolver.jar"^
 -lib "%DOCBOOK_XSL_DIR%/com.oxygenxml.webhelp/lib/ant-contrib-1.0b3.jar"^
 -lib "%DOCBOOK_XSL_DIR%/com.oxygenxml.webhelp/lib/lucene-analyzers-common-4.0.0.jar"^
 -lib "%DOCBOOK_XSL_DIR%/com.oxygenxml.webhelp/lib/lucene-core-4.0.0.jar"^
 -lib "%DOCBOOK_XSL_DIR%/com.oxygenxml.webhelp/lib/xhtml-indexer.jar"^
 -lib "%DOCBOOK_XSL_DIR%/com.oxygenxml.webhelp/lib/xslthl-2.0.1.jar"^
 -lib "%DOCBOOK_XSL_DIR%/com.oxygenxml.webhelp/lib/webhelpXsltExtensions.jar"^
 -lib "%DOCBOOK_XSL_DIR%/extensions/saxon65.jar"^
 -f "%DOCBOOK_XSL_DIR%/com.oxygenxml.webhelp/build_docbook.xml"^
 %TRANSTYPE%^
 "-Dpart.autolabel=0"^
 "-Droot.filename=oxygen-main"^
 "-Dinherit.keywords=0"^
 "-Dchunk.first.sections=1"^
 "-Dreference.autolabel=0"^
 "-Dsuppress.navigation=0"^
 "-Dxml.file=%INPUT_DIR%/%XML_INPUT_FILE%"^
 "-Duse.stemming=false"^
 "-Dpara.propagates.style=1"^
 "-Doutput.dir=%OUTPUT_DIR%"^
 "-Dsection.autolabel=0"^
 "-Dchunker.output.encoding=UTF-8"^
 "-Dappendix.autolabel=0"^
 "-Dsuppress.footer.navigation=0"^
 "-Dbase.dir=%OUTPUT_DIR%"^
 "-Dchunker.output.indent=no"^
 "-Dmenuchoice.menu.separator=→"^
 "-Dchapter.autolabel=0"^
 "-Dchunk.section.depth=3"^
 "-Dwebhelp.language=en"^
 "-Dhighlight.xslthl.config=%DOCBOOK_XSL_DIR_URL%/highlighting/xslthl-config.xml"^
 "-Dnavig.showtitles=0"^
 "-Dhighlight.source=1"^
 "-Dinput.dir=%INPUT_DIR%"^
 "-Dgenerate.index=1" "-Dhtml.ext=.html"^
 "-Dadmon.graphics=0"^
 "-Dsection.label.includes.component.label=1"^
 "-Dmanifest.in.base.dir=0"^
 "-Duse.id.as.filename=1"^
 "-Dqandadiv.autolabel=0"^
 "-Dgenerate.section.toc.level=5"^
 "-Dphrase.propagates.style=1"^
 "-Dcomponent.label.includes.part.label=1"^
 "-Ddraft.mode=no"