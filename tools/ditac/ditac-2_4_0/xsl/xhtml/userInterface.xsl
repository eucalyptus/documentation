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

  <!-- uicontrol ========================================================= -->

  <xsl:template match="*[contains(@class,' ui-d/uicontrol ')]">
    <b>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </b>
  </xsl:template>

  <!-- wintitle ========================================================== -->

  <xsl:template match="*[contains(@class,' ui-d/wintitle ')]">
    <b>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </b>
  </xsl:template>

  <!-- menucascade ======================================================= -->

  <xsl:template match="*[contains(@class,' ui-d/menucascade ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>

      <xsl:apply-templates select="./*[1]"/>

      <xsl:for-each select="./*[position() gt 1]">
        <xsl:text> &#8594; </xsl:text>
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </span>
  </xsl:template>

  <!-- shortcut ========================================================== -->

  <xsl:template match="*[contains(@class,' ui-d/shortcut ')]">
    <!-- No u element in XHTML 1.0 Strict and in XHTML 1.1. 
         (Note that ditac generates XHTML 1.0 Transitional and 
          not XHTML 1.0 Strict.) -->
    <xsl:element name="{ if ($xhtmlVersion eq '1.1') then 'span' else 'u' }">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- screen ============================================================ -->

  <xsl:template match="*[contains(@class,' ui-d/screen ')]">
    <pre>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="displayAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </pre>
  </xsl:template>

</xsl:stylesheet>
