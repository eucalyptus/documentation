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
                xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs u ditac"
                version="2.0">

  <xsl:attribute-set name="toc-container">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-title" use-attribute-sets="title">
    <xsl:attribute name="font-size">180%</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="toc" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="ditac:toc">
    <fo:block xsl:use-attribute-sets="toc-container" id="{$tocId}">
      <fo:block xsl:use-attribute-sets="toc-title">
        <xsl:call-template name="outlineLevel1"/>

        <xsl:variable name="title">
          <xsl:call-template name="localize">
            <xsl:with-param name="message" select="'toc'"/>
          </xsl:call-template>
        </xsl:variable>

        <fo:marker marker-class-name="topic-title">
          <xsl:value-of select="$title"/>
        </fo:marker>

        <xsl:value-of select="$title"/>
      </fo:block>

      <xsl:variable name="frontmatterTOCEntries"
                    select="$ditacLists/ditac:frontmatterTOC/ditac:tocEntry"/>
      <xsl:if test="($extended-toc eq 'frontmatter' or 
                     $extended-toc eq 'both') and
                     exists($frontmatterTOCEntries)">
        <fo:block xsl:use-attribute-sets="toc">
          <xsl:apply-templates select="$frontmatterTOCEntries" mode="fmbmTOC"/>
        </fo:block>
      </xsl:if>

      <fo:block xsl:use-attribute-sets="toc">
        <xsl:apply-templates select="$ditacLists/ditac:toc/ditac:tocEntry"
                             mode="bodyTOC"/>
      </fo:block>

      <xsl:variable name="backmatterTOCEntries"
                    select="$ditacLists/ditac:backmatterTOC/ditac:tocEntry"/>
      <xsl:if test="($extended-toc eq 'backmatter' or 
                     $extended-toc eq 'both') and
                     exists($backmatterTOCEntries)">
        <fo:block xsl:use-attribute-sets="toc">
          <xsl:apply-templates select="$backmatterTOCEntries" mode="fmbmTOC"/>
        </fo:block>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:attribute-set name="toc-entry-container"
                     use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-entry-division"
                     use-attribute-sets="toc-entry-container">
    <xsl:attribute name="space-before.optimum">1.5em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">1em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-part-entry"
                     use-attribute-sets="semi-compact-block-style">
    <xsl:attribute name="font-size">120%</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-chapter-entry"
                     use-attribute-sets="semi-compact-block-style">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-appendices-entry"
                     use-attribute-sets="toc-part-entry">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-appendix-entry"
                     use-attribute-sets="semi-compact-block-style">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-section1-entry"
                     use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-section2-entry"
                     use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-section3-entry"
                     use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-section4-entry"
                     use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-section5-entry"
                     use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-section6-entry"
                     use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-section7-entry"
                     use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-section8-entry"
                     use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-section9-entry"
                     use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="extended-toc-entry"
                     use-attribute-sets="semi-compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-entry-number">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-entry-title">
  </xsl:attribute-set>

  <xsl:attribute-set name="toc-nested-entries"
                     use-attribute-sets="compact-block-style">
    <xsl:attribute name="margin-left">2em</xsl:attribute>
  </xsl:attribute-set>

  <!-- fmbmTOC ========== -->

  <xsl:template match="ditac:tocEntry" mode="fmbmTOC">
    <xsl:if test="not(@role = 'toc' and @id = '__AUTO__')">
      <fo:block xsl:use-attribute-sets="toc-entry-container">
        <xsl:variable name="id" select="u:fmbmTOCEntryId(.)"/>
        <xsl:variable name="title" select="u:fmbmTOCEntryTitle(.)"/>

        <fo:block xsl:use-attribute-sets="toc-entry-container">
          <fo:block xsl:use-attribute-sets="extended-toc-entry"
                    text-align-last="justify">
            <fo:basic-link internal-destination="{$id}"
               xsl:use-attribute-sets="toc-entry-title">
               <xsl:value-of select="$title"/>
            </fo:basic-link>
            <xsl:text> </xsl:text>
            <fo:leader leader-pattern="dots"
                       keep-with-next.within-line="always">
              <xsl:if test="$foProcessor = 'XFC'">
                <xsl:attribute name="xfc:tab-position">-30pt</xsl:attribute>
                <xsl:attribute name="xfc:tab-align">right</xsl:attribute>
              </xsl:if>
            </fo:leader>
            <xsl:text> </xsl:text>
            <fo:page-number-citation ref-id="{$id}"/>
          </fo:block>
        </fo:block>

        <xsl:variable name="nested" select="child::ditac:tocEntry"/>
        <xsl:if test="exists($nested)">
          <fo:block xsl:use-attribute-sets="toc-nested-entries">
            <xsl:apply-templates select="$nested" mode="fmbmTOC"/>
          </fo:block>
        </xsl:if>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <!-- bodyTOC ========== -->

  <xsl:template match="ditac:tocEntry" mode="bodyTOC">
    <xsl:variable name="isDiv" 
      select="((@role = 'part' or @role = 'appendices') and 
               u:indexOfNode(parent::ditac:toc/ditac:tocEntry, .) ge 2) or
              (@role = 'appendix' and 
               empty(parent::ditac:tocEntry[@role = 'appendices']) and 
               empty(preceding::ditac:tocEntry[@role = 'appendix']))" />

    <xsl:choose>
      <xsl:when test="$isDiv">
        <fo:block xsl:use-attribute-sets="toc-entry-division">
          <xsl:call-template name="bodyTOCEntryContainer"/>
        </fo:block>
      </xsl:when>

      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="toc-entry-container">
          <xsl:call-template name="bodyTOCEntryContainer"/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="bodyTOCEntryContainer">
    <xsl:choose>
      <xsl:when test="@role = 'part'">
        <fo:block xsl:use-attribute-sets="toc-part-entry"
                  text-align-last="justify">
          <xsl:call-template name="bodyTOCEntry"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="@role = 'chapter'">
        <fo:block xsl:use-attribute-sets="toc-chapter-entry"
                  text-align-last="justify">
          <xsl:call-template name="bodyTOCEntry"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="@role = 'appendices'">
        <fo:block xsl:use-attribute-sets="toc-appendices-entry"
                  text-align-last="justify">
          <xsl:call-template name="bodyTOCEntry"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="@role = 'appendix'">
        <fo:block xsl:use-attribute-sets="toc-appendix-entry"
                  text-align-last="justify">
          <xsl:call-template name="bodyTOCEntry"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="@role = 'section1'">
        <fo:block xsl:use-attribute-sets="toc-section1-entry"
                  text-align-last="justify">
          <xsl:call-template name="bodyTOCEntry"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="@role = 'section2'">
        <fo:block xsl:use-attribute-sets="toc-section2-entry"
                  text-align-last="justify">
          <xsl:call-template name="bodyTOCEntry"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="@role = 'section3'">
        <fo:block xsl:use-attribute-sets="toc-section3-entry"
                  text-align-last="justify">
          <xsl:call-template name="bodyTOCEntry"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="@role = 'section4'">
        <fo:block xsl:use-attribute-sets="toc-section4-entry"
                  text-align-last="justify">
          <xsl:call-template name="bodyTOCEntry"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="@role = 'section5'">
        <fo:block xsl:use-attribute-sets="toc-section5-entry"
                  text-align-last="justify">
          <xsl:call-template name="bodyTOCEntry"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="@role = 'section6'">
        <fo:block xsl:use-attribute-sets="toc-section6-entry"
                  text-align-last="justify">
          <xsl:call-template name="bodyTOCEntry"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="@role = 'section7'">
        <fo:block xsl:use-attribute-sets="toc-section7-entry"
                  text-align-last="justify">
          <xsl:call-template name="bodyTOCEntry"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="@role = 'section8'">
        <fo:block xsl:use-attribute-sets="toc-section8-entry"
                  text-align-last="justify">
          <xsl:call-template name="bodyTOCEntry"/>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="toc-section9-entry"
                  text-align-last="justify">
          <xsl:call-template name="bodyTOCEntry"/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:variable name="nested" select="child::ditac:tocEntry"/>
    <xsl:if test="exists($nested)">
      <fo:block xsl:use-attribute-sets="toc-nested-entries">
        <xsl:apply-templates select="$nested" mode="bodyTOC"/>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <xsl:template name="bodyTOCEntry">
    <fo:inline xsl:use-attribute-sets="toc-entry-number">
      <xsl:variable name="num"
                    select="u:shortTitlePrefix(string(@number), .)"/>
      <xsl:choose>
        <xsl:when test="$num != ''">
          <xsl:choose>
            <xsl:when test="@role = 'part' or
                            @role = 'chapter' or
                            @role = 'appendix'">
              <xsl:value-of select="concat($num, $title-prefix-separator1)"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- Discard leading 'Section '. -->
              <xsl:value-of select="concat(substring-after($num, '&#xA0;'), 
                                           $title-prefix-separator1)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>&#xA0;</xsl:otherwise>
      </xsl:choose>
    </fo:inline>

    <fo:basic-link internal-destination="{@id}"
       xsl:use-attribute-sets="toc-entry-title">
       <xsl:value-of select="@title"/>
    </fo:basic-link>
    <xsl:text> </xsl:text>
    <fo:leader leader-pattern="dots"
               keep-with-next.within-line="always">
      <xsl:if test="$foProcessor = 'XFC'">
        <xsl:attribute name="xfc:tab-position">-30pt</xsl:attribute>
        <xsl:attribute name="xfc:tab-align">right</xsl:attribute>
      </xsl:if>
    </fo:leader>
    <xsl:text> </xsl:text>
    <fo:page-number-citation ref-id="{@id}"/>
  </xsl:template>

</xsl:stylesheet>
