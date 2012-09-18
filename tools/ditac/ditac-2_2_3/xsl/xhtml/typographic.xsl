<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
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
    <span style="text-decoration: underline;">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- tt ================================================================ -->

  <xsl:template match="*[contains(@class,' hi-d/tt ')]">
    <tt>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </tt>
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
