<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2010-2013 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                exclude-result-prefixes="xs u"
                version="2.0">

  <!-- URI of a PNG or JPEG image file. The size of this image must be at most
       1000x1000px.
       If the URI is relative, it is relative to the current 
       working directory. -->
  <xsl:param name="cover-image" select="''" />
  <xsl:param name="coverImageName" 
             select="if ($cover-image ne '') then
                         concat('cover.', u:extension($cover-image))
                     else 
                         ''" />

  <xsl:param name="epub-identifier" select="''" />

  <!-- Applies only to EPUB3 -->
  <xsl:param name="generate-epub-trigger" select="'yes'"/>

  <!-- Allowed values are 'yes' and 'no' -->
  <xsl:param name="number-toc-entries">no</xsl:param>

  <xsl:param name="ignore-navigation-links" select="'yes'"/>

  <xsl:param name="defaultXSLResourcesDir" 
             select="resolve-uri('resources/', document-uri(doc('')))"/>

</xsl:stylesheet>
