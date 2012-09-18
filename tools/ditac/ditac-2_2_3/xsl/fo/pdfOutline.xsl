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

  <!-- xsl11PDFOutline =================================================== -->
  <!-- Standard XSL 1.1 facility supported by FOP. -->

  <xsl:template name="xsl11PDFOutline">
    <fo:bookmark-tree>
      <!-- A PDF outline is considered to be a kind of TOC. The main
           difference is that the actual TOC may itself appear in the PDF
           outline. -->
      <xsl:variable name="frontmatterTOCEntries"
                    select="$ditacLists/ditac:frontmatterTOC/ditac:tocEntry"/>
      <xsl:if test="($extended-toc eq 'frontmatter' or 
                     $extended-toc eq 'both') and
                     exists($frontmatterTOCEntries)">
        <xsl:apply-templates select="$frontmatterTOCEntries"
                             mode="xsl11-fmbm-outline"/>
      </xsl:if>

      <xsl:apply-templates select="$ditacLists/ditac:toc/ditac:tocEntry" 
                           mode="xsl11-body-outline"/>

      <xsl:variable name="backmatterTOCEntries"
                    select="$ditacLists/ditac:backmatterTOC/ditac:tocEntry"/>
      <xsl:if test="($extended-toc eq 'backmatter' or 
                     $extended-toc eq 'both') and
                     exists($backmatterTOCEntries)">
        <xsl:apply-templates select="$backmatterTOCEntries"
                             mode="xsl11-fmbm-outline"/>
      </xsl:if>
    </fo:bookmark-tree>
  </xsl:template>

  <xsl:template match="ditac:tocEntry" mode="xsl11-fmbm-outline">
    <xsl:variable name="id" select="u:fmbmTOCEntryId(.)"/>
    <xsl:variable name="title" select="u:fmbmTOCEntryTitle(.)"/>

    <!-- starting-state=show | hide. Default: show -->
    <fo:bookmark internal-destination="{$id}" starting-state="hide">
      <fo:bookmark-title><xsl:value-of select="$title"/></fo:bookmark-title>

      <xsl:apply-templates mode="xsl11-fmbm-outline"/>
    </fo:bookmark>
  </xsl:template>

  <xsl:template match="ditac:tocEntry" mode="xsl11-body-outline">
    <fo:bookmark internal-destination="{@id}" starting-state="hide">
      <fo:bookmark-title>
        <xsl:variable name="num"
                      select="u:shortTitlePrefix(string(@number), .)"/>
        <xsl:if test="$num != ''">
          <xsl:value-of select="concat($num, $title-prefix-separator1)"/>
        </xsl:if>
        <xsl:value-of select="@title"/>
      </fo:bookmark-title>

      <xsl:apply-templates mode="xsl11-body-outline"/>
    </fo:bookmark>
  </xsl:template>

  <!-- xepPDFOutline ===================================================== -->

  <xsl:template name="xepPDFOutline">
    <rx:outline>
      <xsl:variable name="frontmatterTOCEntries"
                    select="$ditacLists/ditac:frontmatterTOC/ditac:tocEntry"/>
      <xsl:if test="($extended-toc eq 'frontmatter' or 
                     $extended-toc eq 'both') and
                     exists($frontmatterTOCEntries)">
        <xsl:apply-templates select="$frontmatterTOCEntries"
                             mode="xep-fmbm-outline"/>
      </xsl:if>

      <xsl:apply-templates select="$ditacLists/ditac:toc/ditac:tocEntry" 
                           mode="xep-body-outline"/>

      <xsl:variable name="backmatterTOCEntries"
                    select="$ditacLists/ditac:backmatterTOC/ditac:tocEntry"/>
      <xsl:if test="($extended-toc eq 'backmatter' or 
                     $extended-toc eq 'both') and
                     exists($backmatterTOCEntries)">
        <xsl:apply-templates select="$backmatterTOCEntries"
                             mode="xep-fmbm-outline"/>
      </xsl:if>
    </rx:outline>
  </xsl:template>

  <xsl:template match="ditac:tocEntry" mode="xep-fmbm-outline">
    <xsl:variable name="id" select="u:fmbmTOCEntryId(.)"/>
    <xsl:variable name="title" select="u:fmbmTOCEntryTitle(.)"/>

    <!-- collapse-subtree=false | true -->
    <rx:bookmark internal-destination="{$id}" collapse-subtree="true">
      <rx:bookmark-label><xsl:value-of select="$title"/></rx:bookmark-label>

      <xsl:apply-templates mode="xep-fmbm-outline"/>
    </rx:bookmark>
  </xsl:template>

  <xsl:template match="ditac:tocEntry" mode="xep-body-outline">
    <rx:bookmark internal-destination="{@id}" collapse-subtree="true">
      <rx:bookmark-label>
        <xsl:variable name="num"
                      select="u:shortTitlePrefix(string(@number), .)"/>
        <xsl:if test="$num != ''">
          <xsl:value-of select="concat($num, $title-prefix-separator1)"/>
        </xsl:if>
        <xsl:value-of select="@title"/>
      </rx:bookmark-label>

      <xsl:apply-templates mode="xep-body-outline"/>
    </rx:bookmark>
  </xsl:template>

</xsl:stylesheet>
