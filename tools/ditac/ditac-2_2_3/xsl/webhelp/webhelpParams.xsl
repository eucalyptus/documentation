<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2011-2012 Pixware SARL. All rights reserved.
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
  <xsl:param name="number-toc-entries">yes</xsl:param>

  <!-- These parameters are useful in the unlikely case where the default
       basenames conflict with the basenames of the HTML pages generated
       by the webhelp.xsl stylesheet. -->
  <xsl:param name="whc-toc-basename">whc_toc.xml</xsl:param>
  <xsl:param name="whc-index-basename">whc_index.xml</xsl:param>

  <xsl:param name="css-name">webhelp.css</xsl:param>

  <xsl:param name="ignore-navigation-links">yes</xsl:param>

  <xsl:param name="defaultXSLResourcesDir" 
             select="resolve-uri('resources/', document-uri(doc('')))"/>

</xsl:stylesheet>
