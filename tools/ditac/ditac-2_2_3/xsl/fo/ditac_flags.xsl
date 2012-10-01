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
                xmlns:rx="http://www.renderx.com/XSL/Extensions"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs u ditac"
                version="2.0">

  <xsl:attribute-set name="ditac-flags-block-container">
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-block-start-block">
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-block-start-image">
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-text">
    <xsl:attribute name="font-size">small</xsl:attribute>
    <xsl:attribute name="color">gray</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-block-start-text" 
                     use-attribute-sets="ditac-flags-text">
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-block">
    <xsl:attribute name="border-right-color">gray</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-block-end-block">
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-block-end-image">
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-block-end-text" 
                     use-attribute-sets="ditac-flags-text">
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-inline-container">
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-inline-start-image">
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-inline-start-text" 
                     use-attribute-sets="ditac-flags-text">
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-inline">
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-inline-end-image">
  </xsl:attribute-set>

  <xsl:attribute-set name="ditac-flags-inline-end-text" 
                     use-attribute-sets="ditac-flags-text">
  </xsl:attribute-set>

  <xsl:template match="ditac:flags">
    <xsl:variable name="canFlag" select="u:canFlag(child::*)"/>
    <xsl:choose>
      <xsl:when test="$canFlag eq 1">
        <fo:block xsl:use-attribute-sets="ditac-flags-block-container">
          <xsl:call-template name="addChangeBarBegin"/>

          <xsl:if test="@startImage or @startText">
            <fo:block xsl:use-attribute-sets="ditac-flags-block-start-block">
              <xsl:if test="@startImage">
                <fo:external-graphic src="{concat('url(', @startImage, ')')}" 
                     xsl:use-attribute-sets="ditac-flags-block-start-image"/>
              </xsl:if>

              <xsl:if test="@startText">
                <fo:inline
                  xsl:use-attribute-sets="ditac-flags-block-start-text">
                  <xsl:value-of select="@startText"/>
                </fo:inline>
              </xsl:if>
            </fo:block>
          </xsl:if>

          <fo:block xsl:use-attribute-sets="ditac-flags-block">
            <xsl:call-template name="flagsStyle">
              <xsl:with-param name="setChangebar" 
                select="$foProcessor ne 'XEP' and $foProcessor ne 'AHF'"/>
            </xsl:call-template>

            <xsl:apply-templates/>
          </fo:block>

          <xsl:if test="@endImage or @endText">
            <fo:block xsl:use-attribute-sets="ditac-flags-block-end-block">
              <xsl:if test="@endImage">
                <fo:external-graphic src="{concat('url(', @endImage, ')')}" 
                     xsl:use-attribute-sets="ditac-flags-block-end-image"/>
              </xsl:if>

              <xsl:if test="@endText">
                <fo:inline xsl:use-attribute-sets="ditac-flags-block-end-text">
                  <xsl:value-of select="@endText"/>
                </fo:inline>
              </xsl:if>
            </fo:block>
          </xsl:if>

          <xsl:call-template name="addChangeBarEnd"/>
        </fo:block>
      </xsl:when>

      <xsl:when test="$canFlag eq 2">
        <fo:inline xsl:use-attribute-sets="ditac-flags-inline-container">
          <xsl:if test="@startImage">
            <fo:external-graphic src="{concat('url(', @startImage, ')')}" 
                 xsl:use-attribute-sets="ditac-flags-inline-start-image"/>
          </xsl:if>

          <xsl:if test="@startText">
            <fo:inline xsl:use-attribute-sets="ditac-flags-inline-start-text">
              <xsl:value-of select="@startText"/>
            </fo:inline>
          </xsl:if>

          <fo:inline xsl:use-attribute-sets="ditac-flags-inline">
            <xsl:call-template name="flagsStyle">
              <xsl:with-param name="setChangebar" select="false()"/>
            </xsl:call-template>

            <xsl:apply-templates/>
          </fo:inline>

          <xsl:if test="@endImage">
            <fo:external-graphic  src="{concat('url(', @endImage, ')')}" 
                 xsl:use-attribute-sets="ditac-flags-inline-end-image" />
          </xsl:if>

          <xsl:if test="@endText">
            <fo:inline xsl:use-attribute-sets="ditac-flags-inline-end-text">
              <xsl:value-of select="@endText"/>
            </fo:inline>
          </xsl:if>
        </fo:inline>
      </xsl:when>

      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="flagsStyle">
    <xsl:param name="setChangebar" select="false()"/>

    <xsl:copy-of select="@color"/>
    <xsl:copy-of select="@background-color"/>
    <xsl:copy-of select="@font-weight"/>
    <xsl:copy-of select="@font-style"/>
    <xsl:copy-of select="@text-decoration"/>

    <xsl:if test="@changebar and $setChangebar">
      <xsl:attribute name="border-right-color">gray</xsl:attribute>
      <xsl:attribute name="border-right-width">1pt</xsl:attribute>
      <xsl:attribute name="border-right-style">solid</xsl:attribute>
      <xsl:attribute name="padding-right">0.25em</xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:attribute-set name="ditac-flags-change-bar">
    <xsl:attribute name="change-bar-placement">end</xsl:attribute>
    <xsl:attribute name="change-bar-offset">6pt</xsl:attribute>
    <xsl:attribute name="change-bar-color">gray</xsl:attribute>
    <xsl:attribute name="change-bar-width">1pt</xsl:attribute>
    <xsl:attribute name="change-bar-style">solid</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template name="addChangeBarBegin">
    <xsl:if test="exists(@changebar)">
      <xsl:choose>
        <xsl:when test="$foProcessor eq 'XEP'">
          <rx:change-bar-begin change-bar-class="{generate-id(.)}" 
                               xsl:use-attribute-sets="ditac-flags-change-bar"/>
        </xsl:when>
        <xsl:when test="$foProcessor eq 'AHF'">
          <fo:change-bar-begin change-bar-class="{generate-id(.)}" 
                               xsl:use-attribute-sets="ditac-flags-change-bar"/>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="addChangeBarEnd">
    <xsl:if test="exists(@changebar)">
      <xsl:choose>
        <xsl:when test="$foProcessor eq 'XEP'">
          <rx:change-bar-end change-bar-class="{generate-id(.)}"/>
        </xsl:when>
        <xsl:when test="$foProcessor eq 'AHF'">
          <fo:change-bar-end change-bar-class="{generate-id(.)}"/>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
