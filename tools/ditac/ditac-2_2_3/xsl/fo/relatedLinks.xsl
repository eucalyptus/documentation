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
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs u ditac"
                version="2.0">
  
  <!-- link ============================================================== -->

  <xsl:attribute-set name="link" use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="link-bullet">
  </xsl:attribute-set>

  <xsl:attribute-set name="link-link" use-attribute-sets="link-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/link ')]">
    <fo:block xsl:use-attribute-sets="link">
      <xsl:call-template name="commonAttributes"/>

      <fo:inline xsl:use-attribute-sets="link-bullet">
        <xsl:value-of select="$link-bullet"/>
      </fo:inline>
      <xsl:text> </xsl:text>

      <!-- In some cases the preprocessor may have removed the href. -->

      <xsl:choose>
        <xsl:when test="@href">
          <fo:basic-link xsl:use-attribute-sets="link-link">
            <xsl:call-template name="linkDestination">
              <xsl:with-param name="href" select="string(@href)"/>
            </xsl:call-template>

            <xsl:call-template name="linkText">
              <xsl:with-param name="text">
                <xsl:apply-templates
                    select="./*[contains(@class,' topic/linktext ')]"/>
              </xsl:with-param>
              <xsl:with-param name="autoText" select="$linkAutoText"/>
            </xsl:call-template>
          </fo:basic-link>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates
            select="./*[contains(@class,' topic/linktext ')]"/>
        </xsl:otherwise>
      </xsl:choose>
    </fo:block>
  </xsl:template>

  <!-- linkText is also used to process xref. -->

  <xsl:template name="linkText">
    <xsl:param name="text" select="()"/>
    <xsl:param name="autoText" select="()"/>

    <xsl:variable name="hasText" select="string($text) != ''"/>
    <xsl:choose>
      <xsl:when test="$hasText and empty(@ditac:filled)">
        <!-- Show the text when it has actually been specified by the
             author and that's it. -->
        <xsl:copy-of select="$text"/>
        <xsl:call-template name="showLinkInfo"/>
      </xsl:when>

      <xsl:otherwise>
        <!-- Auto-generated text. -->
        <xsl:variable name="showLabel"
                      select="index-of($autoText, 'number') ge 1"/>

        <xsl:variable name="showText"
                      select="index-of($autoText, 'text') ge 1"/>

        <xsl:variable name="label">
          <xsl:call-template name="linkPrefix"/>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$label != ''">
            <xsl:choose>
              <xsl:when test="$hasText">
                <xsl:if test="$showLabel">
                  <!-- Discard the '. ' found at the end of the label. -->
                  <xsl:value-of 
                      select="substring-before($label,
                                               $title-prefix-separator1)"/>
                </xsl:if>
                <xsl:if test="$showText">
                  <xsl:if test="$showLabel">
                    <xsl:value-of select="$title-prefix-separator1"/>
                  </xsl:if>
                  <xsl:copy-of select="$text"/>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of 
                    select="substring-before($label,
                                             $title-prefix-separator1)"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="showLinkInfo"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$hasText">
                <xsl:copy-of select="$text"/>
                <xsl:call-template name="showLinkInfo"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@href"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="showLinkInfo">
    <xsl:call-template name="showExternalLink"/>

    <xsl:if test="($show-xref-page = 'yes' and 
                   self::*[contains(@class,' topic/xref ')]) or 
                  ($show-link-page = 'yes' and 
                   self::*[contains(@class,' topic/link ')])">
      <xsl:call-template name="showLinkPage"/>
    </xsl:if>
  </xsl:template>

  <xsl:attribute-set name="external-href">
  </xsl:attribute-set>

  <xsl:template name="showExternalLink">
    <xsl:variable name="href" select="string(@href)"/>

    <xsl:if test="$show-external-links = 'yes' and
                  (@scope = 'external' or contains($href, '://'))">
      <fo:inline xsl:use-attribute-sets="external-href">
        <xsl:value-of select="concat($external-href-before,
                                     $href, 
                                     $external-href-after)"/>
      </fo:inline>
    </xsl:if>
  </xsl:template>

  <xsl:attribute-set name="page-ref">
  </xsl:attribute-set>

  <xsl:template name="showLinkPage">
    <xsl:variable name="id" select="u:linkTargetId(string(@href))"/>
    <xsl:if test="$id != ''">
      <fo:inline xsl:use-attribute-sets="page-ref">
        <xsl:value-of select="$page-ref-before"/>
        <fo:page-number-citation ref-id="{$id}"/>
        <xsl:value-of select="$page-ref-after"/>
      </fo:inline>
    </xsl:if>
  </xsl:template>

  <!-- linktext ========================================================== -->

  <xsl:template match="*[contains(@class,' topic/linktext ')]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- linkpool ========================================================== -->

  <xsl:template match="*[contains(@class,' topic/linkpool ')]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- linklist ========================================================== -->

  <xsl:attribute-set name="linklist" use-attribute-sets="block-style">
    <xsl:attribute name="margin-left">2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/linklist ')]">
    <fo:block xsl:use-attribute-sets="linklist">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- linkinfo ========================================================== -->

  <xsl:attribute-set name="linkinfo" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/linkinfo ')]">
    <fo:block xsl:use-attribute-sets="linkinfo">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>
