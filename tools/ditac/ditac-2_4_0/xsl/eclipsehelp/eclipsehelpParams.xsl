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
  <xsl:param name="number-toc-entries">no</xsl:param>

  <xsl:param name="plugin-name">EDIT HERE: title of this help</xsl:param>
  <xsl:param 
    name="plugin-id">EDIT HERE: unique.id.of.this.plugin</xsl:param>
  <xsl:param 
    name="plugin-provider">EDIT HERE: author, company or organization</xsl:param>
  <xsl:param name="plugin-version">1.0.0</xsl:param>

  <xsl:param name="plugin-toc-basename">toc.xml</xsl:param>
  <xsl:param name="plugin-index-basename">index.xml</xsl:param>

  <xsl:param name="ignore-navigation-links" select="'yes'"/>

  <xsl:param name="defaultXSLResourcesDir" 
             select="resolve-uri('resources/', document-uri(doc('')))"/>

</xsl:stylesheet>
