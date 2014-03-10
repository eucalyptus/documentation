INTRODUCTION
=============

This directory contains the Oxygen Webhelp plugin version 15.2 for DITA Open Toolkit. The Webhelp output files are exactly the same as for the DITA Webhelp transformations executed inside the Oxygen XML Editor 15.2 application. The plugin must be first integrated in the DITA Open Toolkit for adding the following transformation types to the DITA Open Toolkit:

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

The requirements of the Oxygen Webhelp plugin for DITA Open Toolkit are the following:

- Java Virtual Machine 1.6 or later

- DITA Open Toolkit 1.6.x or 1.7.x (the 'full easy install' distribution)

- Saxon 9.1.0.8 processor


INSTALL THE WEBHELP PLUGIN IN DITA-OT
======================================

1. Download and install a Java Virtual Machine 1.6 or later and a DITA Open Toolkit 1.6.x or 1.7.x (the 'full easy install' distribution) if you don't have them already installed:

http://www.oracle.com/technetwork/java/javase/downloads/index.html

http://sourceforge.net/projects/dita-ot/files/DITA-OT%20Stable%20Release/

2. Copy the parent directory of this README file, called 'com.oxygenxml.webhelp', and the directory called 'com.oxygenxml.highlight', in the 'plugins' subdirectory of the install directory of the DITA Open Toolkit where you want to run the Oxygen Webhelp transformation.

3. Run the following command in the directory of DITA Open Toolkit:
   
   ant -f integrator.xml

The integrator.xml file is located in the DITA Open Toolkit install directory. This will add two plugins to DITA-OT: Oxygen Webhelp plugin (directory com.oxygenxml.webhelp) and Oxygen highlight plugin (directory com.oxygenxml.highlight). 

4. Download and unzip on your computer the saxonb9-1-0-8j.zip file containing the Saxon 9.1.0.8 processor from:

http://sourceforge.net/projects/saxon/files/Saxon-B/9.1.0.8/


REGISTER YOUR OXYGEN LICENSE IN THE WEBHELP PLUGIN
===================================================

Create a text file called 'licensekey.txt' in the directory [DITA-OT-install-dir]/plugins/com.oxygenxml.webhelp. Copy and paste in this file your Oxygen Scripting license key which you purchased for your Oxygen Webhelp plugin. The Webhelp transformation will read the Oxygen license key from this file. If this file does not exist or it contains an invalid license key an error message will be displayed.


RUN THE WEBHELP TRANSFORMATION in DITA-OT
==========================================

The following command will run the Webhelp transformation. This command is available also as a script file in the same directory as this README file, called dita.sh for Unix/Linux based system and dita.bat for Windows systems. Just set the correct values of the script variables at the beginning at the script file before calling the script in an automated process or from a command line.


"[JVM-install-dir]/bin/java" -Xmx512m -classpath "[DITA-OT-install-dir]/tools/ant/lib/ant-launcher.jar" "-Dant.home=[DITA-OT-install-dir]/tools/ant" org.apache.tools.ant.launch.Launcher -lib "[DITA-OT-install-dir]/plugins/com.oxygenxml.webhelp/lib/xercesImpl.jar" -lib "[DITA-OT-install-dir]/plugins/com.oxygenxml.webhelp/lib/xml-apis.jar" -lib "[DITA-OT-install-dir]/plugins/com.oxygenxml.webhelp/lib/xml-apis-ext.jar" -lib "[DITA-OT-install-dir]" -lib "[DITA-OT-install-dir]/lib" -lib "[Saxon-9.1.0.8-dir]/saxon9.jar" -lib "[Saxon-9.1.0.8-dir]/saxon9-dom.jar" -lib "[DITA-OT-install-dir]/plugins/com.oxygenxml.webhelp/lib/license.jar" -lib "[DITA-OT-install-dir]/plugins/com.oxygenxml.webhelp/lib/log4j.jar" -lib "[DITA-OT-install-dir]/plugins/com.oxygenxml.webhelp/lib/resolver.jar" -lib "[DITA-OT-install-dir]/plugins/com.oxygenxml.webhelp/lib/ant-contrib-1.0b3.jar" -lib "[DITA-OT-install-dir]/plugins/com.oxygenxml.webhelp/lib/lucene-analyzers-common-4.0.0.jar" -lib "[DITA-OT-install-dir]/plugins/com.oxygenxml.webhelp/lib/lucene-core-4.0.0.jar" -lib "[DITA-OT-install-dir]/plugins/com.oxygenxml.webhelp/lib/xhtml-indexer.jar" -lib "[DITA-OT-install-dir]/plugins/com.oxygenxml.highlight/lib/xslthl-2.1.0.jar" -lib "[DITA-OT-install-dir]/plugins/com.oxygenxml.webhelp/lib/webhelpXsltExtensions.jar" -f "[DITA-OT-install-dir]/build.xml" "-Dtranstype=[webhelp.transtype]" "-Dbasedir=[DITA-map-base-dir]" "-Doutput.dir=[DITA-map-base-dir]/out/[webhelp.transtype]" "-Ddita.temp.dir=[DITA-map-base-dir]/temp/[webhelp.transtype]" "-Dargs.filter=[DITAVAL-dir]/[file.ditaval]" "-Ddita.input.valfile=[DITAVAL-dir]/[file.ditaval]" "-Dargs.hide.parent.link=no" "-Ddita.dir=[DITA-OT-install-dir]" "-Dargs.xhtml.classattr=yes" "-Dargs.input=[DITA-map-base-dir]/[input-DITA-map-file.ditamap]" "-DbaseJVMArgLine=-Xmx384m"


where:

- [JVM-install-dir] must be replaced with the path of the Java Virtual Machine install directory

- [DITA-OT-install-dir] must be replaced with the path of the DITA Open Toolkit install directory

- [Saxon-9.1.0.8-dir] must be replaced with the path of the directory were the Saxon 9 archive file (saxonb9-1-0-8j.zip) was unzipped

- [webhelp.transtype] must be one of the values: webhelp, webhelp-feedback, webhelp-mobile

- [DITA-map-base-dir] must be replaced with the path of the directory of the input DITA map file

- [DITAVAL-dir] must be replaced with the path of the directory of [file.ditaval] which sets the DITAVAL input filter

- [file.ditaval] must be replaced with the name of the DITAVAL input filter file that will be applied to the input map

- [input-DITA-map-file.ditamap] must be replaced with the name of the input DITA map file


The '-Dargs.filter' and '-Ddita.input.valfile' parameters are optional. 

The Webhelp output pages are generated in the directory that is set in the parameter 'output.dir', by default [DITA-map-base-dir]/out/[transtype].


CONFIGURE DATABASE (ONLY FOR WEBHELP WITH FEEDBACK TRANSFORMATIONS)
====================================================================

For the transformations that generate Webhelp pages allowing user comments (webhelp-feedback) the database with the user comments must be configured. This is done by opening the following file in a Web browser and following the installation instructions from this file:

[DITA-map-base-dir]/out/[transtype]/oxygen-webhelp/resources/installation.html


OTHER PARAMETERS OF WEBHELP TRANSFORMATION
===========================================

The Webhelp parameters that can be appended to the command line that runs the Webhelp transformation:

  -Dwebhelp.copyright (text string value) - The copyright note that will be added in the footer of the Table of Contents frame (the left side frame of the WebHelp output).

  -Dwebhelp.footer.include (possible values: 'yes', 'no') - If set to 'no' no footer is added to the Webhelp pages. If set to 'yes' and the webhelp.footer.file parameter has a value, then the content of that file is used as footer in each Webhelp output page. If webhelp.footer.file has no value then the default Oxygen footer is inserted in each Webhelp page.

  -Dwebhelp.footer.file (file path of XHTML file) - Specifies the location of a well-formed XHTML file containing your custom footer for the document body. Corresponds to XSLT parameter WEBHELP_FOOTER_FILE. The fragment must be well-formed XHTML, with a single root element. Common practice is to place all content into a <div>.

  -Dwebhelp.product.id (text string value, required for the transformations with user feedback) - A short name for the documentation target (product). All user comments that will be posted in the Webhelp output pages and will be added in the comments database on the server will be bound to this product ID. Examples: 'mobile-phone-user-guide', 'hvac-installation-guide', etc. Documentation for multiple products can be deployed on the same server.

  -Dwebhelp.product.version (text string value, required for the transformations with user feedback) - The documentation version number, for example: 1.0, 2.5, etc. New user comments are bound to this version. Multiple documentation versions can be deployed on the same server.


Other DITA-OT parameters that are needed for a customization of the Webhelp transformation can be appended to the above command line following the model of the -D parameters like 'args.hide.parent.link' and 'args.xhtml.classattr'. For example the 'args.hdr' parameter can be appended in the form:

"-Dargs.hdr=/path/to/directory/of/header-file.html"

where [dir-of-header-file] will be replaced with the path of the directory containing the header file.
