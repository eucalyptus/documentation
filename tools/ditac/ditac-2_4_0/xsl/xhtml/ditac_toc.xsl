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
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs u ditac"
                version="2.0">

  <xsl:template match="ditac:toc">
    <xsl:element name="{$navQName}">
      <xsl:attribute name="class" select="'toc-container'"/>
      <xsl:attribute name="id" select="$tocId"/>

      <h1 class="toc-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'toc'"/>
        </xsl:call-template>
      </h1>

      <xsl:variable name="frontmatterTOCEntries"
                    select="$ditacLists/ditac:frontmatterTOC/ditac:tocEntry"/>
      <xsl:if test="($extended-toc eq 'frontmatter' or 
                     $extended-toc eq 'both') and
                     exists($frontmatterTOCEntries)">
        <div class="toc">
          <xsl:apply-templates select="$frontmatterTOCEntries" mode="fmbmTOC"/>
        </div>
      </xsl:if>

      <div class="toc">
        <xsl:apply-templates select="$ditacLists/ditac:toc/ditac:tocEntry"
                             mode="bodyTOC"/>
      </div>

      <xsl:variable name="backmatterTOCEntries"
                    select="$ditacLists/ditac:backmatterTOC/ditac:tocEntry"/>
      <xsl:if test="($extended-toc eq 'backmatter' or 
                     $extended-toc eq 'both') and
                     exists($backmatterTOCEntries)">
        <div class="toc">
          <xsl:apply-templates select="$backmatterTOCEntries" mode="fmbmTOC"/>
        </div>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ditac:tocEntry" mode="fmbmTOC">
    <xsl:if test="not(@role eq 'toc' and starts-with(@id, '__AUTO__'))">
      <div class="toc-entry-container">
        <xsl:variable name="id" select="u:tocEntryAutoId(.)"/>
        <xsl:variable name="title" select="u:tocEntryAutoTitle(.)"/>

        <p class="extended-toc-entry">
          <a href="{u:joinLinkTarget(@file, $id)}" 
             class="toc-entry-title"><xsl:value-of select="$title"/></a>
        </p>

        <xsl:variable name="nested" select="child::ditac:tocEntry"/>
        <xsl:if test="exists($nested)">
          <div class="toc-nested-entries">
            <xsl:apply-templates select="$nested" mode="fmbmTOC"/>
          </div>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ditac:tocEntry" mode="bodyTOC">
    <xsl:variable name="isDiv" 
      select="((@role eq 'part' or @role eq 'appendices') and 
               u:indexOfNode(parent::ditac:toc/ditac:tocEntry, .) ge 2) or
              (@role eq 'appendix' and 
               empty(parent::ditac:tocEntry[@role eq 'appendices']) and 
               empty(preceding::ditac:tocEntry[@role eq 'appendix']))" />

    <div class="{if ($isDiv) 
                 then 'toc-entry-division'
                 else 'toc-entry-container'}">
      <p class="{concat('toc-', string(@role), '-entry')}">
        <span class="toc-entry-number">
          <xsl:variable name="num"
                        select="u:shortTitlePrefix(string(@number), .)"/>
          <xsl:choose>
            <xsl:when test="$num ne ''">
              <xsl:choose>
                <xsl:when test="@role eq 'part' or
                                @role eq 'chapter' or
                                @role eq 'appendix'">
                  <xsl:value-of 
                    select="concat($num, $title-prefix-separator1)"/>
                </xsl:when>
                <xsl:otherwise>
                  <!-- Discard leading 'Section '. -->
                  <xsl:value-of 
                    select="concat(substring-after($num, '&#xA0;'), 
                                   $title-prefix-separator1)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>&#xA0;</xsl:otherwise>
          </xsl:choose>
        </span>

        <a href="{u:joinLinkTarget(@file, @id)}" 
          class="toc-entry-title"><xsl:value-of select="u:tocEntryAutoTitle(.)"/></a>
      </p>

      <xsl:variable name="nested" select="child::ditac:tocEntry"/>
      <xsl:if test="exists($nested)">
        <div class="toc-nested-entries">
          <xsl:apply-templates select="$nested" mode="bodyTOC"/>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

</xsl:stylesheet>
