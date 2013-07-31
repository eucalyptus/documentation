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

  <xsl:param name="helpset-basename">jhelpset.hs</xsl:param>
  <xsl:param name="map-basename">jhelpmap.jhm</xsl:param>
  <xsl:param name="toc-basename">jhelptoc.xml</xsl:param>
  <xsl:param name="index-basename">jhelpidx.xml</xsl:param>
  <xsl:param name="indexer-directory-basename">JavaHelpSearch</xsl:param>

  <xsl:param name="css-name" select="'javahelp.css'"/>

  <xsl:param name="ignore-navigation-links" select="'yes'"/>

  <xsl:param name="defaultXSLResourcesDir" 
             select="resolve-uri('resources/', document-uri(doc('')))"/>

</xsl:stylesheet>
