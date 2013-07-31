<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2013 Pixware SARL. All rights reserved.
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

  <xsl:import href="xhtmlBase.xsl"/>

  <!-- Output ============================================================ -->

  <xsl:param name="xhtmlVersion" select="'5.0'"/>

  <!-- By default, we generate a meta charset= -->
  <xsl:param name="xhtml-mime-type" select="''"/>

  <!-- Specify the output encoding here and also below. -->
  <!-- Important: if encoding is not UTF-8, change below 
       omit-xml-declaration from yes to no. -->
  <xsl:param name="xhtmlEncoding" select="'UTF-8'"/>

  <!-- Note that doctype-public="" doctype-system="" will not generate
       the HTML5 DOCTYPE. -->
  <xsl:output method="xhtml" encoding="UTF-8" omit-xml-declaration="yes"/>

  <!-- Overrides ========================================================= -->

  <xsl:param name="sectionQName" select="'section'"/>
  <xsl:param name="navQName" select="'nav'"/>

  <xsl:template name="otherMeta">
    <xsl:call-template name="otherMetaImpl"/>

    <xsl:if test="exists(//processing-instruction('onclick'))">
      <xsl:call-template name="onclickPIScript"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="otherAttributes">
    <xsl:param name="class" select="''"/>
    <xsl:param name="classPrefix" select="''"/>

    <xsl:call-template name="otherAttributesImpl">
      <xsl:with-param name="class" select="$class"/>
      <xsl:with-param name="classPrefix" select="$classPrefix"/>
    </xsl:call-template>

    <xsl:for-each select="processing-instruction('onclick')">
      <xsl:call-template name="processOnclickPI"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="processOnclickPI">
    <xsl:variable name="triggers">
      <xsl:call-template name="onclickPIToTriggers"/>
    </xsl:variable>

    <xsl:variable name="script">
      <xsl:for-each select="$triggers/*">
        <xsl:text> onclickPI_</xsl:text>
        <xsl:value-of select="@action"/>
        <xsl:text>('</xsl:text>
        <xsl:value-of select="@ref"/>
        <xsl:text>');</xsl:text>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="script2" select="normalize-space($script)"/>
    <xsl:if test="$script2 ne ''">
      <xsl:for-each select="parent::*">
        <xsl:attribute name="onclick"
                       select="concat($script2, ' return false;')"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
