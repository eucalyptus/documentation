<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2009 Pixware SARL. All rights reserved.
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

  <!-- msgph ============================================================= -->

  <xsl:attribute-set name="msgph" use-attribute-sets="monospace-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' sw-d/msgph ')]">
    <fo:inline xsl:use-attribute-sets="msgph">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- msgblock ========================================================== -->

  <xsl:attribute-set name="msgblock"
    use-attribute-sets="monospace-block-style split-border-style">
    <xsl:attribute name="background-color">#E0E0F0</xsl:attribute>
    <xsl:attribute name="padding">0.25em</xsl:attribute>
    <xsl:attribute name="margin-left">1pt</xsl:attribute>
    <xsl:attribute name="margin-right">1pt</xsl:attribute>
    <!-- Add actual border using the frame attribute. -->
    <xsl:attribute name="border-color">#C0C0F0</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' sw-d/msgblock ')]">
    <fo:block xsl:use-attribute-sets="msgblock">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="displayAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- msgnum ============================================================ -->

  <xsl:attribute-set name="msgnum" use-attribute-sets="monospace-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' sw-d/msgnum ')]">
    <fo:inline xsl:use-attribute-sets="msgnum">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- cmdname =========================================================== -->

  <xsl:attribute-set name="cmdname" use-attribute-sets="monospace-style">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' sw-d/cmdname ')]">
    <fo:inline xsl:use-attribute-sets="cmdname">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- varname =========================================================== -->

  <xsl:attribute-set name="varname" use-attribute-sets="monospace-style">
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' sw-d/varname ')]">
    <fo:inline xsl:use-attribute-sets="varname">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- filepath =========================================================== -->

  <xsl:attribute-set name="filepath" use-attribute-sets="monospace-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' sw-d/filepath ')]">
    <fo:inline xsl:use-attribute-sets="filepath">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- userinput ========================================================= -->

  <xsl:attribute-set name="userinput" use-attribute-sets="monospace-style">
    <xsl:attribute name="background-color">#C0E0C0</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' sw-d/userinput ')]">
    <fo:inline xsl:use-attribute-sets="userinput">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- systemoutput ====================================================== -->

  <xsl:attribute-set name="systemoutput" use-attribute-sets="monospace-style">
    <xsl:attribute name="background-color">#F0F0C0</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' sw-d/systemoutput ')]">
    <fo:inline xsl:use-attribute-sets="systemoutput">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

</xsl:stylesheet>
