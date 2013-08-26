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
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs u ditac"
                version="2.0">

  <xsl:import href="../xhtml/xhtmlBase.xsl"/>
  <xsl:import href="eclipsehelpParams.xsl"/>

  <!-- Output ============================================================ -->

  <xsl:param name="xhtmlVersion" select="'-4.01'"/>

  <!-- Specify the output encoding here and also everywhere below. -->
  <xsl:param name="xhtmlEncoding" select="'UTF-8'"/>

  <xsl:output method="html" encoding="UTF-8" indent="no"/>

  <!-- ditac:toc, figureList, tableList, exampleList, indexList ========== -->
  <!-- All suppressed. -->

  <xsl:template match="ditac:toc"/>
  <xsl:template match="ditac:figureList"/>
  <xsl:template match="ditac:tableList"/>
  <xsl:template match="ditac:exampleList"/>
  <xsl:template match="ditac:indexList"/>

  <!-- ditac:chunk ======================================================= -->

  <xsl:template match="ditac:chunk">
    <!-- Generate the plugin.xml and toc.xml files just before the first
         chunk is being processed. -->

    <xsl:if test="u:chunkIndex(base-uri()) eq 1">
      <xsl:call-template name="generatePlugin"/>
      <xsl:call-template name="generateTOC"/>
      <xsl:if test="u:hasIndex()">
        <xsl:call-template name="generateIndex"/>
      </xsl:if>
    </xsl:if>

    <xsl:apply-templates/>
  </xsl:template>

  <!-- generatePlugin =================================================== -->

  <xsl:output name="xmlOutputFormat"
    method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:template name="generatePlugin">
    <xsl:result-document href="{resolve-uri('plugin.xml', base-uri())}"
                         format="xmlOutputFormat">
      <plugin>
        <xsl:attribute name="name" select="$plugin-name"/>
        <xsl:attribute name="id" select="$plugin-id"/>
        <xsl:attribute name="version" select="$plugin-version"/>
        <xsl:attribute name="provider-name" select="$plugin-provider"/>

        <extension point="org.eclipse.help.toc">
          <toc file="{$plugin-toc-basename}" primary="true"/>
        </extension>

        <xsl:if test="u:hasIndex()">
          <extension point="org.eclipse.help.index">
            <index file="{$plugin-index-basename}"/>
          </extension>
        </xsl:if>
      </plugin>
    </xsl:result-document>
  </xsl:template>

  <!-- generateTOC ======================================================= -->

  <xsl:template name="generateTOC">
    <xsl:result-document 
      href="{resolve-uri($plugin-toc-basename, base-uri())}"
      format="xmlOutputFormat">
      <xsl:variable name="firstChunkFile" 
                    select="$ditacLists/ditac:chunkList/ditac:chunk[1]/@file"/>
      <toc label="{u:documentTitle()}" topic="{$firstChunkFile}">
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
      </toc>
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

      <topic label="{$title}" href="{concat(@file, '#', $id)}">
        <xsl:apply-templates mode="fmbmTOC"/>
      </topic>
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

    <topic label="{concat($titlePrefix, u:tocEntryAutoTitle(.))}"
           href="{concat(@file, '#', @id)}">
      <xsl:apply-templates mode="bodyTOC"/>
    </topic>
  </xsl:template>

  <!-- generateIndex ===================================================== -->

  <xsl:template name="generateIndex">
    <xsl:result-document 
      href="{resolve-uri($plugin-index-basename, base-uri())}"
      format="xmlOutputFormat">
      <index>
        <xsl:apply-templates
          select="$ditacLists/ditac:indexList/*/ditac:indexEntry"/>
      </index>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="ditac:indexEntry">
    <xsl:if test="exists(ditac:indexAnchor|ditac:indexEntry)">
      <entry keyword="{@term}">
        <xsl:apply-templates/>
      </entry>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ditac:indexAnchor">
    <topic href="{concat(@file, '#', @id)}"/>
  </xsl:template>

  <xsl:template match="ditac:indexSee"/>
  <xsl:template match="ditac:indexSeeAlso"/>

</xsl:stylesheet>
