<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2009-2012 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs"
                version="2.0">

  <!-- Allowed values are 'yes' and 'no' -->
  <xsl:param name="add-toc-root">yes</xsl:param>

  <!-- Allowed values are 'yes' and 'no' -->
  <xsl:param name="number-toc-entries">no</xsl:param>

  <xsl:param name="chmBasename">help.chm</xsl:param>
  <xsl:param name="hhpBasename">project.hhp</xsl:param>
  <xsl:param name="hhc-basename">toc.hhc</xsl:param>
  <xsl:param name="hhx-basename">index.hhx</xsl:param>

  <xsl:param name="hhp-template"
             select="resolve-uri('template.hhp', document-uri(doc('')))"/>
  <xsl:param name="hhpTemplate"
             select="unparsed-text($hhp-template, 'UTF-8')"/>

  <xsl:param name="ignore-navigation-links" select="'yes'"/>

  <xsl:param name="defaultXSLResourcesDir" 
             select="resolve-uri('resources/', document-uri(doc('')))"/>

</xsl:stylesheet>
