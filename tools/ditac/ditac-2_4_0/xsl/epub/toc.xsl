<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2013 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:URI="java:com.xmlmind.ditac.xslt.URI"
                exclude-result-prefixes="xs ditac u URI"
                version="2.0">

  <xsl:template name="generateTOC">
    <xsl:param name="basename" select="''"/>

    <xsl:variable name="srcURI" 
                  select="resolve-uri($cover-image, URI:userDirectory())" />
    <xsl:variable name="dstURI" 
                  select="resolve-uri($coverImageName, base-uri())" />

    <xsl:result-document href="{resolve-uri($basename, base-uri())}"
                         format="{if ($xhtmlVersion eq '5.0') 
                                  then 'outputFormatXHTML5'
                                  else 'outputFormatXHTML1_1'}">

      <xsl:text
          disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&#xA;</xsl:text>

      <html xml:lang="{u:documentLang()}">
        <head>
          <meta charset="UTF-8"/>
          <title><xsl:value-of select="u:localize('toc', .)"/></title>
        </head>

        <body>
          <nav epub:type="toc" xmlns:epub="http://www.idpf.org/2007/ops">
            <h1><xsl:value-of select="u:localize('toc', .)"/></h1>

            <xsl:variable name="hasTOCEntries1" 
              select="($extended-toc eq 'frontmatter' or 
                       $extended-toc eq 'both') and
                      exists($ditacLists/ditac:frontmatterTOC/ditac:tocEntry)"/>
            <xsl:variable name="tocEntries1"
              select="if ($hasTOCEntries1)
                      then $ditacLists/ditac:frontmatterTOC//ditac:tocEntry[not(@role eq 'toc' and starts-with(@id, '__AUTO__'))]
                      else ()"/>

            <xsl:variable name="tocEntries2"
              select="$ditacLists/ditac:toc//ditac:tocEntry"/>

            <xsl:variable name="hasTOCEntries3" 
              select="($extended-toc eq 'backmatter' or 
                       $extended-toc eq 'both') and
                      exists($ditacLists/ditac:backmatterTOC/ditac:tocEntry)"/>
            <xsl:variable name="tocEntries3"
              select="if ($hasTOCEntries3)
                      then $ditacLists/ditac:backmatterTOC//ditac:tocEntry
                      else ()"/>

            <ol>
              <xsl:if test="$hasTOCEntries1">
                <xsl:apply-templates mode="fmbmTOC" 
                  select="$ditacLists/ditac:frontmatterTOC/ditac:tocEntry"/>
              </xsl:if>

              <xsl:apply-templates mode="bodyTOC"
                select="$ditacLists/ditac:toc/ditac:tocEntry"/>

              <xsl:if test="$hasTOCEntries3">
                <xsl:apply-templates mode="fmbmTOC"
                  select="$ditacLists/ditac:backmatterTOC/ditac:tocEntry"/>
              </xsl:if>
            </ol>
          </nav>
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="ditac:tocEntry" mode="fmbmTOC">
    <xsl:if test="not(@role eq 'toc' and starts-with(@id, '__AUTO__'))">
      <xsl:variable name="id" select="u:tocEntryAutoId(.)"/>
      <xsl:variable name="title" select="u:tocEntryAutoTitle(.)"/>

      <li>
        <a href="{concat(@file, '#', $id)}"><xsl:value-of select="$title"/></a>
        
        <xsl:if test="exists(./ditac:tocEntry)">
          <ol>
            <xsl:apply-templates select="./ditac:tocEntry" mode="fmbmTOC"/>
          </ol>
        </xsl:if>
      </li>
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

    <li>
      <a href="{concat(@file, '#', @id)}">
        <xsl:value-of select="concat($titlePrefix, u:tocEntryAutoTitle(.))"/>
      </a>

      <xsl:if test="exists(./ditac:tocEntry)">
        <ol>
          <xsl:apply-templates select="./ditac:tocEntry" mode="bodyTOC"/>
        </ol>
      </xsl:if>
    </li>
  </xsl:template>

</xsl:stylesheet>
