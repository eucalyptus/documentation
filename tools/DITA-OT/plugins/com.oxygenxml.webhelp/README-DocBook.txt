INTRODUCTION
=============

This directory contains the files necessary for running the DocBook Webhelp version 15.2 family of transformations from a command line. The Webhelp output files are exactly the same as for the DocBook Webhelp transformations executed inside the Oxygen XML Editor 15.2 application.

There are 3 Webhelp transformations in this family:

webhelp           - The Webhelp transformation for desktop output

webhelp-feedback  - The Webhelp transformation for desktop output with a section for 
                    user comments at the bottom of each XHTML output page

webhelp-mobile    - The Webhelp transformation for mobile devices output


More details about all the Webhelp transformations are available on the Oxygen website:

http://www.oxygenxml.com/xml_editor/webhelp.html 


LICENSE TERMS
==============

The license terms of the Oxygen Webhelp distribution are set forth in the file EULA_Webhelp.txt located in the same directory as this README file. 


REQUIREMENTS
=============

The Webhelp transformation runs as an ANT build script, so the requirements are:

- ANT 1.8 or later

- Java Virtual Machine 1.6 or later

- DocBook XSL 1.78.1 or later

- Saxon 6.5.5 processor

- Saxon 9.1.0.8 processor


INSTALL
========

1. Download and install a Java Virtual Machine 1.6 or later and an ANT 1.8 or later if you don't have them already installed:

http://www.oracle.com/technetwork/java/javase/downloads/index.html

http://www.apache.org/dist/ant/binaries/

2. Download and unzip on your computer the Docbook XSL distribution from:

http://sourceforge.net/projects/docbook/files/docbook-xsl-ns/

3. Unzip the Webhelp distribution package in the DocBook XSL install directory, that is the directory where the files VERSION and README of the DocBook XSL distribution are located. The result will be a new sub-directory called 'com.oxygenxml.webhelp' and two new files called 'oxygen_custom.xsl' and 'oxygen_custom_html.xsl' added in the DocBook XSL install directory.

4. Download and unzip on your computer the saxon6-5-5.zip file containing the Saxon 6.5.5 processor from:

http://prdownloads.sourceforge.net/saxon/saxon6-5-5.zip

5. Download and unzip on your computer the saxonb9-1-0-8j.zip file containing the Saxon 9.1.0.8 processor from:

http://sourceforge.net/projects/saxon/files/Saxon-B/9.1.0.8/


REGISTER YOUR OXYGEN LICENSE
=============================

Create a text file called 'licensekey.txt' in the subdirectory 'com.oxygenxml.webhelp' of the Docbook XSL directory. Copy and paste in this file your Oxygen Scripting license key which you purchased for your Oxygen Webhelp plugin. The Webhelp transformation will read the Oxygen license key from this file. If this file does not exist or it contains an invalid license key an error message will be displayed.


RUN THE WEBHELP TRANSFORMATION
===============================

The following command will run the Webhelp transformation. This command is available also as a script file in the same directory as this README file, called docbook.sh for Unix/Linux based system and docbook.bat for Windows systems. Just set the correct values of the script variables at the beginning at the script file before calling the script in an automated process or from a command line.


"[JVM-install-dir]/bin/java" -Xmx512m -classpath "[ANT-install-dir]/lib/ant-launcher.jar" "-Dant.home=[ANT-install-dir]" org.apache.tools.ant.launch.Launcher -lib "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/lib/xercesImpl.jar" -lib "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/lib/xml-apis.jar" -lib "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/lib/xml-apis-ext.jar" -lib "[Saxon-6.5.5-dir]/saxon.jar" -lib "[Saxon-9.1.0.8-dir]/saxon9.jar" -lib "[Saxon-9.1.0.8-dir]/saxon9-dom.jar" -lib "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/lib/license.jar" -lib "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/lib/webhelpXsltExtensions.jar" -lib "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/lib/log4j.jar" -lib "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/lib/resolver.jar" -lib "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/lib/ant-contrib-1.0b3.jar" -lib "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/lib/lucene-analyzers-common-4.0.0.jar" -lib "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/lib/lucene-core-4.0.0.jar" -lib "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/lib/xhtml-indexer.jar" -lib "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/lib/xslthl-2.0.1.jar" -lib "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/lib/webhelpXsltExtensions.jar" -lib "[Docbook-XSL-install-dir]/extensions/saxon65.jar" -f "[Docbook-XSL-install-dir]/com.oxygenxml.webhelp/build_docbook.xml" [webhelp-transtype] "-Dpart.autolabel=0" "-Droot.filename=oxygen-main" "-Dinherit.keywords=0" "-Dchunk.first.sections=1" "-Dreference.autolabel=0" "-Dsuppress.navigation=0" "-Dxml.file=[input-dir]/[XML-input-file]" "-Duse.stemming=false" "-Dpara.propagates.style=1" "-Doutput.dir=[output-dir]" "-Dsection.autolabel=0" "-Dchunker.output.encoding=UTF-8" "-Dappendix.autolabel=0" "-Dsuppress.footer.navigation=0" "-Dbase.dir=[output-dir]" "-Dchunker.output.indent=no" "-Dmenuchoice.menu.separator=→" "-Dchapter.autolabel=0" "-Dchunk.section.depth=3" "-Dwebhelp.language=en" "-Dhighlight.xslthl.config=[Docbook-XSL-install-dir-URL]/highlighting/xslthl-config.xml" "-Dnavig.showtitles=0" "-Dhighlight.source=1" "-Dinput.dir=[input-dir]" "-Dgenerate.index=1" "-Dhtml.ext=.html" "-Dadmon.graphics=0" "-Dsection.label.includes.component.label=1" "-Dmanifest.in.base.dir=0" "-Duse.id.as.filename=1" "-Dqandadiv.autolabel=0" "-Dgenerate.section.toc.level=5" "-Dphrase.propagates.style=1" "-Dcomponent.label.includes.part.label=1" "-Ddraft.mode=no"


where:

- [JVM-install-dir] must be replaced with the path of the Java Virtual Machine install directory

- [ANT-install-dir] must be replaced with the path of the ANT tool install directory

- [Docbook-XSL-install-dir] must be replaced with the Docbook XSL install directory

- [Docbook-XSL-install-dir-URL] must be replaced with the Docbook XSL install directory in URL format, for example:  file:/C:/programs/docbook-xsl

- [Saxon-6.5.5-dir] must be replaced with the path of the directory were the Saxon 6.5.5 archive file (saxon6-5-5.zip) was unzipped

- [Saxon-9.1.0.8-dir] must be replaced with the path of the directory were the Saxon 9.1.0.8 archive file (saxonb9-1-0-8j.zip) was unzipped

- [webhelp.transtype] must be one of the values: webhelp, webhelp-feedback, webhelp-mobile

- [input-dir] must be the path of the input directory, that is the directory of file [XML-input-file] 

- [XML-input-file] must be the XML input file name

- [output-dir] must be the path of the output directory


CONFIGURE DATABASE (ONLY FOR WEBHELP WITH FEEDBACK TRANSFORMATIONS)
====================================================================

For the transformations that generate Webhelp pages allowing user comments (webhelp-feedback) the database with the user comments must be configured. This is done by following the installation instructions from the file:

[output-dir]/oxygen-webhelp/resources/installation.html


OTHER PARAMETERS OF WEBHELP TRANSFORMATION
===========================================

The Webhelp parameters that can be appended to the command line that runs the Webhelp transformation:

  -Dwebhelp.copyright (text string value) - The copyright note that will be added in the footer of the Table of Contents frame (the left side frame of the WebHelp output).

  -Dwebhelp.footer.include (possible values: 'yes', 'no') - If set to 'no' no footer is added to the Webhelp pages. If set to 'yes' and the webhelp.footer.file parameter has a value, then the content of that file is used as footer in each Webhelp output page. If webhelp.footer.file has no value then the default Oxygen footer is inserted in each Webhelp page.

  -Dwebhelp.footer.file (file path of XHTML file) - Specifies the location of a well-formed XHTML file containing your custom footer for the document body. Corresponds to XSLT parameter WEBHELP_FOOTER_FILE. The fragment must be well-formed XHTML, with a single root element. Common practice is to place all content into a <div>.

  -Dwebhelp.product.id (text string value, required for the transformations with user feedback) - A short name for the documentation target (product). All user comments that will be posted in the Webhelp output pages and will be added in the comments database on the server will be bound to this product ID. Examples: 'mobile-phone-user-guide', 'hvac-installation-guide', etc. Documentation for multiple products can be deployed on the same server.

  -Dwebhelp.product.version (text string value, required for the transformations with user feedback) - The documentation version number, for example: 1.0, 2.5, etc. New user comments are bound to this version. Multiple documentation versions can be deployed on the same server.


Other Docbook XSL parameters that are needed for a customization of the Webhelp transformation can be appended to the above command line following the model of the -D parameters like 'chunk.first.sections' and 'output.dir'. For example the 'html.stylesheet' parameter can be appended in the form:

"-Dhtml.stylesheet=/path/to/directory/of/stylesheet.css"
