<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2012-2013 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"    
		xmlns:xslthl="http://xslthl.sf.net"
                exclude-result-prefixes="xslthl"
                version="2.0">

  <!-- Programming languages ============================================= -->

  <xsl:template match="xslthl:keyword">
    <span class="hl-keyword"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="xslthl:string">
    <span class="hl-string"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="xslthl:number">
    <span class="hl-number"><xsl:apply-templates/></span>
  </xsl:template>
  
  <xsl:template match="xslthl:comment">
    <span class="hl-comment"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="xslthl:doccomment">
    <span class="hl-doccomment"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="xslthl:directive">
    <span class="hl-directive"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="xslthl:annotation">
    <span class="hl-annotation"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- XML =============================================================== -->

  <xsl:template match="xslthl:tag">
    <span class="hl-tag"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="xslthl:attribute">
    <span class="hl-attribute"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="xslthl:value">
    <span class="hl-value"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- comment, directive (= processing instruction) -->

  <xsl:template match="xslthl:doctype">
    <span class="hl-doctype"><xsl:apply-templates/></span>
  </xsl:template>

</xsl:stylesheet>