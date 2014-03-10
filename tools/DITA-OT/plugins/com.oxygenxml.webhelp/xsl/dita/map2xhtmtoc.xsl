<?xml version="1.0" encoding="UTF-8" ?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="../../../../xsl/map2xhtmtoc.xsl"/>
  <xsl:import href="map2webhelptoc.xsl"/>
  <xsl:import href="../localization.xsl"/>

  <xsl:param name="TOC_FILE_NAME" select="'toc.html'"/>
  <xsl:param name="BASEDIR"/>
  <xsl:param name="OUTPUTDIR"/>
  <xsl:param name="LANGUAGE" select="'en-us'"/>
  
  <xsl:output method="xml" encoding="UTF-8"
                    indent="no"
                    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
                    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
                    omit-xml-declaration="yes"/>
</xsl:stylesheet>