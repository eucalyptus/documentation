<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2011-2013 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                xmlns:whc="http://www.xmlmind.com/whc/schema/whc"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="xs u ditac"
                version="2.0">

  <xsl:import href="webhelpParams.xsl"/>

  <!-- Output ============================================================ -->

  <!-- ditac:toc, figureList, tableList, exampleList, indexList ========== -->
  <!-- All suppressed. -->

  <xsl:template match="ditac:toc"/>
  <xsl:template match="ditac:figureList"/>
  <xsl:template match="ditac:tableList"/>
  <xsl:template match="ditac:exampleList"/>
  <xsl:template match="ditac:indexList"/>

  <!-- ditac:chunk ======================================================= -->

  <xsl:template match="ditac:chunk">
    <xsl:if test="u:chunkIndex(base-uri()) eq 1">
      <xsl:call-template name="generateTOC"/>
      <xsl:if test="u:hasIndex()">
        <xsl:call-template name="generateIndex"/>
      </xsl:if>
    </xsl:if>

    <xsl:apply-templates/>
  </xsl:template>

  <!-- generateTOC ======================================================= -->

  <xsl:output name="xmlOutputFormat"
    method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:template name="generateTOC">
    <xsl:result-document 
      href="{resolve-uri($whc-toc-basename, base-uri())}"
      format="xmlOutputFormat">
      <whc:toc>
        <xsl:variable name="frontmatterTOCEntries"
                      select="$ditacLists/ditac:frontmatterTOC/ditac:tocEntry"/>
        <xsl:if test="($extended-toc eq 'frontmatter' or 
                       $extended-toc eq 'both') and
                       exists($frontmatterTOCEntries)">
          <xsl:apply-templates select="$frontmatterTOCEntries" mode="fmbmTOC"/>
        </xsl:if>

        <xsl:apply-templates select="$ditacLists/ditac:toc/ditac:tocEntry"
                             mode="bodyTOC"/>

        <xsl:variable name="backmatterTOCEntries"
                      select="$ditacLists/ditac:backmatterTOC/ditac:tocEntry"/>
        <xsl:if test="($extended-toc eq 'backmatter' or 
                       $extended-toc eq 'both') and
                       exists($backmatterTOCEntries)">
          <xsl:apply-templates select="$backmatterTOCEntries" mode="fmbmTOC"/>
        </xsl:if>
      </whc:toc>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="ditac:tocEntry" mode="fmbmTOC">
    <xsl:if test="not((@role eq 'toc' or 
                       @role eq 'figurelist' or 
                       @role eq 'tablelist' or 
                       @role eq 'examplelist' or 
                       @role eq 'indexlist') and starts-with(@id, '__AUTO__'))">
      <xsl:variable name="id" select="u:tocEntryAutoId(.)"/>
      <xsl:variable name="title" select="u:tocEntryAutoTitle(.)"/>

      <whc:entry href="{concat(@file, '#', $id)}">
        <whc:title>
          <span class="webhelp-extended-toc-entry">
            <xsl:value-of select="$title"/>
          </span>
        </whc:title>

        <xsl:apply-templates mode="fmbmTOC"/>
      </whc:entry>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ditac:tocEntry" mode="bodyTOC">
    <xsl:variable name="num" 
                  select="if ($number-toc-entries eq 'yes') then
                              u:shortTitlePrefix(string(@number), .)
                          else
                              ''"/>

    <xsl:variable name="titlePrefix">
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
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <whc:entry href="{concat(@file, '#', @id)}">
      <whc:title>
        <span class="{concat('webhelp-toc-', string(@role), '-entry')}">
          <xsl:value-of select="concat($titlePrefix, u:tocEntryAutoTitle(.))"/>
        </span>
      </whc:title>

      <xsl:apply-templates mode="bodyTOC"/>
    </whc:entry>
  </xsl:template>

  <!-- generateIndex ===================================================== -->

  <xsl:template name="generateIndex">
    <xsl:result-document 
      href="{resolve-uri($whc-index-basename, base-uri())}"
      format="xmlOutputFormat">
      <whc:index termSeparator="{$index-term-separator}" mergeAndSort="false">
        <xsl:apply-templates 
            select="$ditacLists/ditac:indexList/*/ditac:indexEntry"/>
      </whc:index>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="ditac:indexEntry">
    <xsl:if
      test="exists(ditac:indexSee/@ref|ditac:indexAnchor|ditac:indexEntry)">
      <whc:entry>
        <xsl:copy-of select="@xml:id"/>
        <whc:term>
          <xsl:value-of select="@term"/>
        </whc:term>

        <xsl:apply-templates/>
      </whc:entry>
    </xsl:if>
    <!-- Otherwise, unusable by whc. -->
  </xsl:template>

  <xsl:template match="ditac:indexAnchor">
    <whc:anchor href="{concat(@file, '#', @id)}">
      <xsl:if test="exists(@file2)">
        <xsl:attribute name="href2" select="concat(@file2, '#', @id2)"/>
      </xsl:if>
    </whc:anchor>
  </xsl:template>

  <xsl:template match="ditac:indexSee">
    <xsl:if test="exists(@ref)">
      <whc:see ref="{@ref}"/>
    </xsl:if>
    <!-- Otherwise (should not happen often because it's an author mistake), 
         unusable by whc. -->
  </xsl:template>

  <xsl:template match="ditac:indexSeeAlso">
    <xsl:if test="exists(@ref)">
      <whc:seeAlso ref="{@ref}"/>
    </xsl:if>
    <!-- Otherwise (should not happen often because it's an author mistake), 
         unusable by whc. -->
  </xsl:template>

</xsl:stylesheet>
