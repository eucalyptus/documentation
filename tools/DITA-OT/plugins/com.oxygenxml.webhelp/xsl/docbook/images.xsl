<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:XSLTExtensionIOUtil="java:ro.sync.io.XSLTExtensionIOUtil"
  xmlns:opf="http://www.idpf.org/2007/opf"
  exclude-result-prefixes="XSLTExtensionIOUtil"
  version="1.0">
  
  <!-- Dir of input XML. -->
  <xsl:param name="inputDir"/>
  
  <!-- Dir of output HTML. -->
  <xsl:param name="outputDir"/>
  
  <!-- Dir of images. -->
  <xsl:param name="imagesDir"/>
  
   <xsl:output omit-xml-declaration="yes"
       doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
       doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
    
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@src[parent::xhtml:img]">
    <xsl:variable name="imagePath" select="XSLTExtensionIOUtil:copyFile($inputDir, ., $outputDir, $imagesDir)"/>
    <xsl:attribute name="src"><xsl:value-of select="$imagePath"/></xsl:attribute>
  </xsl:template>
  
  <xsl:template match="@data[parent::xhtml:object[@type='image/svg+xml']]">
    <xsl:variable name="imagePath" select="XSLTExtensionIOUtil:copyFile($inputDir, ., $outputDir, $imagesDir)"/>
    <xsl:attribute name="data"><xsl:value-of select="$imagePath"/></xsl:attribute>
  </xsl:template>
</xsl:stylesheet>