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
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                exclude-result-prefixes="xs"
                version="2.0">

  <!-- uicontrol ========================================================= -->

  <xsl:attribute-set name="uicontrol">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' ui-d/uicontrol ')]">
    <fo:inline xsl:use-attribute-sets="uicontrol">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- wintitle ========================================================== -->

  <xsl:attribute-set name="wintitle">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' ui-d/wintitle ')]">
    <fo:inline xsl:use-attribute-sets="wintitle">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- menucascade ======================================================= -->

  <xsl:attribute-set name="menucascade">
  </xsl:attribute-set>

  <xsl:attribute-set name="menucascade-separator">
    <xsl:attribute name="font-family" 
                   select="if ($foProcessor = 'XFC')
                           then $body-font-family
                           else 'Symbol'"/>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' ui-d/menucascade ')]">
    <fo:inline xsl:use-attribute-sets="menucascade">
      <xsl:call-template name="commonAttributes"/>

      <xsl:apply-templates select="./*[1]"/>

      <xsl:for-each select="./*[position() gt 1]">
        <fo:inline xsl:use-attribute-sets="menucascade-separator">
          <xsl:text> </xsl:text>
          <xsl:value-of select="$menucascade-separator"/>
          <xsl:text> </xsl:text>
        </fo:inline>

        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </fo:inline>
  </xsl:template>

  <!-- shortcut ========================================================== -->

  <xsl:attribute-set name="shortcut">
    <xsl:attribute name="text-decoration">underline</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' ui-d/shortcut ')]">
    <fo:inline xsl:use-attribute-sets="shortcut">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- screen ============================================================ -->

  <xsl:attribute-set name="screen"
    use-attribute-sets="monospace-block-style split-border-style">
    <xsl:attribute name="background-color">#E0F0E0</xsl:attribute>
    <xsl:attribute name="padding">0.25em</xsl:attribute>
    <xsl:attribute name="margin-left">1pt</xsl:attribute>
    <xsl:attribute name="margin-right">1pt</xsl:attribute>
    <!-- Add actual border using the frame attribute. -->
    <xsl:attribute name="border-color">#C0F0C0</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' ui-d/screen ')]">
    <fo:block xsl:use-attribute-sets="screen">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="displayAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>
