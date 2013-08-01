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
  
  <!-- imagemap ========================================================== -->

  <xsl:template match="*[contains(@class,' ut-d/imagemap ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="displayAttributes"/>
      <xsl:call-template name="namedAnchor"/>

      <xsl:variable name="id" select="concat('I_', generate-id(), '_')"/>

      <xsl:variable name="image"
                    select="./*[contains(@class,' topic/image ')]"/>

      <object usemap="#{$id}">
        <xsl:if test="exists($image)">
          <xsl:variable name="href" select="$image[1]/@href"/>

          <xsl:attribute name="data" select="$href"/>

          <xsl:attribute name="type">
            <xsl:call-template name="suffixToMIMEType">
              <xsl:with-param name="suffix" select="$href"/>
            </xsl:call-template>
          </xsl:attribute>

          <xsl:for-each select="$image[1]">
            <xsl:call-template name="imageSizeAttributes"/>
          </xsl:for-each>
        </xsl:if>

        <map id="{$id}">
          <xsl:if test="$xhtmlVersion ne '1.1'">
            <xsl:attribute name="name" select="$id"/><!--Allowed by XHTML5-->
          </xsl:if>

          <xsl:apply-templates select="./*[contains(@class,' ut-d/area ')]"/>
        </map>
      </object>
    </div>
  </xsl:template>

  <xsl:template name="suffixToMIMEType">
    <xsl:param name="suffix" select="'.png'" />

    <xsl:choose>
      <xsl:when test="substring($suffix, 1+string-length($suffix)-4) eq '.png'"
        >image/png</xsl:when>
      <xsl:when test="substring($suffix, 1+string-length($suffix)-4) eq '.gif'"
        >image/gif</xsl:when>
      <xsl:when test="substring($suffix, 1+string-length($suffix)-4) eq '.jpg'"
        >image/jpeg</xsl:when>
      <xsl:when test="substring($suffix, 1+string-length($suffix)-5) eq '.jpeg'"
        >image/jpeg</xsl:when>
      <xsl:when test="substring($suffix, 1+string-length($suffix)-4) eq '.svg'"
        >image/svg+xml</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- area ============================================================== -->

  <xsl:template match="*[contains(@class,' ut-d/area ')]">
    <xsl:variable name="shape"
                  select="./*[contains(@class,' ut-d/shape ')]"/>
    <xsl:variable name="coords"
                  select="./*[contains(@class,' ut-d/coords ')]"/>
    <xsl:variable name="xref"
                  select="./*[contains(@class,' topic/xref ')]"/>

    <area>
      <xsl:call-template name="commonAttributes"/>

      <xsl:if test="exists($shape)">
        <xsl:attribute name="shape" select="string($shape[1])"/>
      </xsl:if>

      <xsl:if test="exists($coords)">
        <xsl:attribute name="coords" select="string($coords[1])"/>
      </xsl:if>

      <xsl:if test="exists($xref)">
        <xsl:attribute name="href" select="$xref[1]/@href"/>

        <!-- Use the text contained in the xref and/or in its desc child. -->
        <xsl:variable name="alt" select="normalize-space(string($xref[1]))"/>
        <xsl:if test="$alt ne ''">
          <xsl:attribute name="alt" select="$alt"/>
        </xsl:if>
      </xsl:if>
    </area>
  </xsl:template>

</xsl:stylesheet>
