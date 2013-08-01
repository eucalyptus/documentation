<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2009-2013 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="xs"
                version="2.0">
  
  <!-- itemgroup ========================================================= -->

  <xsl:template match="*[contains(@class,' topic/itemgroup ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
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

  <xsl:template match="*[contains(@class,' topic/state ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:value-of select="@name"/>
      <xsl:text>:&#xA0;</xsl:text>
      <xsl:value-of select="@value"/>
    </span>
  </xsl:template>

  <!-- boolean =========================================================== -->

  <xsl:template match="*[contains(@class,' topic/boolean ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:value-of select="@state"/>
    </span>
  </xsl:template>

</xsl:stylesheet>
