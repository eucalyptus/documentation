<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2009-2010 Pixware SARL. All rights reserved.
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
  
  <!-- itemgroup ========================================================= -->

  <xsl:attribute-set name="itemgroup" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/itemgroup ')]">
    <fo:block xsl:use-attribute-sets="itemgroup">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- no-topic-nesting ================================================== -->
  <!-- Not intended for use by authors, and has no associated 
       output processing. -->

  <xsl:template match="*[contains(@class,' topic/no-topic-nesting ')]"/>

  <!-- required-cleanup ================================================== -->
  <!-- DITA processors are required to strip this element from output 
       by default. -->

  <xsl:template match="*[contains(@class,' topic/required-cleanup ')]"/>

  <!-- state ============================================================= -->

  <xsl:attribute-set name="state">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/state ')]">
    <fo:inline xsl:use-attribute-sets="state">
      <xsl:call-template name="commonAttributes"/>
      <xsl:value-of select="@name"/>
      <xsl:text>:&#xA0;</xsl:text>
      <xsl:value-of select="@value"/>
    </fo:inline>
  </xsl:template>

  <!-- boolean =========================================================== -->

  <xsl:attribute-set name="boolean">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/boolean ')]">
    <fo:inline xsl:use-attribute-sets="boolean">
      <xsl:call-template name="commonAttributes"/>
      <xsl:value-of select="@state"/>
    </fo:inline>
  </xsl:template>

</xsl:stylesheet>
