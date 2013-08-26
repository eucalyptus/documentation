<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2012 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
		xmlns:xslthl="http://xslthl.sf.net"
                exclude-result-prefixes="xslthl"
                version="2.0">

  <!-- Programming languages ============================================= -->

  <xsl:attribute-set name="hl-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="hl-keyword" use-attribute-sets="hl-style">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="color">#602060</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="xslthl:keyword">
    <fo:inline
      xsl:use-attribute-sets="hl-keyword"><xsl:apply-templates/></fo:inline>
  </xsl:template>

  <xsl:attribute-set name="hl-string" use-attribute-sets="hl-style">
    <xsl:attribute name="color">#A00000</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="xslthl:string">
    <fo:inline
      xsl:use-attribute-sets="hl-string"><xsl:apply-templates/></fo:inline>
  </xsl:template>

  <xsl:attribute-set name="hl-number" use-attribute-sets="hl-style">
    <xsl:attribute name="color">#B08000</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="xslthl:number">
    <fo:inline
      xsl:use-attribute-sets="hl-number"><xsl:apply-templates/></fo:inline>
  </xsl:template>
  
  <xsl:attribute-set name="hl-comment" use-attribute-sets="hl-style">
    <xsl:attribute name="font-style">italic</xsl:attribute>
    <xsl:attribute name="color">#808080</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="xslthl:comment">
    <fo:inline
      xsl:use-attribute-sets="hl-comment"><xsl:apply-templates/></fo:inline>
  </xsl:template>

  <xsl:attribute-set name="hl-doccomment" use-attribute-sets="hl-style">
    <xsl:attribute name="color">#008080</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="xslthl:doccomment">
    <fo:inline
      xsl:use-attribute-sets="hl-doccomment"><xsl:apply-templates/></fo:inline>
  </xsl:template>

  <xsl:attribute-set name="hl-directive" use-attribute-sets="hl-style">
    <xsl:attribute name="color">#00A000</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="xslthl:directive">
    <fo:inline
      xsl:use-attribute-sets="hl-directive"><xsl:apply-templates/></fo:inline>
  </xsl:template>

  <xsl:attribute-set name="hl-annotation" use-attribute-sets="hl-style">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="color">#808080</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="xslthl:annotation">
    <fo:inline
      xsl:use-attribute-sets="hl-annotation"><xsl:apply-templates/></fo:inline>
  </xsl:template>

  <!-- XML =============================================================== -->

  <xsl:attribute-set name="hl-tag" use-attribute-sets="hl-style">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="color">#602060</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="xslthl:tag">
    <fo:inline
      xsl:use-attribute-sets="hl-tag"><xsl:apply-templates/></fo:inline>
  </xsl:template>

  <xsl:attribute-set name="hl-attribute" use-attribute-sets="hl-style">
    <xsl:attribute name="color">#0050A0</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="xslthl:attribute">
    <fo:inline
      xsl:use-attribute-sets="hl-attribute"><xsl:apply-templates/></fo:inline>
  </xsl:template>

  <xsl:attribute-set name="hl-value" use-attribute-sets="hl-style">
    <xsl:attribute name="color">#A00000</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="xslthl:value">
    <fo:inline
      xsl:use-attribute-sets="hl-value"><xsl:apply-templates/></fo:inline>
  </xsl:template>

  <!-- comment, directive (= processing instruction) -->

  <xsl:attribute-set name="hl-doctype" use-attribute-sets="hl-style">
    <xsl:attribute name="color">#008080</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="xslthl:doctype">
    <fo:inline
      xsl:use-attribute-sets="hl-doctype"><xsl:apply-templates/></fo:inline>
  </xsl:template>

</xsl:stylesheet>