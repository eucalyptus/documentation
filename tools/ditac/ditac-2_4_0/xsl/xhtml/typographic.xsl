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
  
  <!-- b ================================================================= -->

  <xsl:template match="*[contains(@class,' hi-d/b ')]">
    <b>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </b>
  </xsl:template>

  <!-- i ================================================================= -->

  <xsl:template match="*[contains(@class,' hi-d/i ')]">
    <i>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </i>
  </xsl:template>

  <!-- u ================================================================= -->

  <xsl:template match="*[contains(@class,' hi-d/u ')]">
    <!-- No u element in XHTML 1.0 Strict and in XHTML 1.1. 
         (Note that ditac generates XHTML 1.0 Transitional and 
          not XHTML 1.0 Strict.) -->
    <xsl:element name="{ if ($xhtmlVersion eq '1.1') then 'span' else 'u' }">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- tt ================================================================ -->

  <xsl:template match="*[contains(@class,' hi-d/tt ')]">
    <!-- No tt element in HTML 5. -->
    <xsl:element name="{ if ($xhtmlVersion eq '5.0') then 'span' else 'tt' }">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- sup =============================================================== -->

  <xsl:template match="*[contains(@class,' hi-d/sup ')]">
    <sup>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </sup>
  </xsl:template>

  <!-- sub =============================================================== -->

  <xsl:template match="*[contains(@class,' hi-d/sub ')]">
    <sub>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </sub>
  </xsl:template>

</xsl:stylesheet>
