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
  <xsl:import href="javahelpParams.xsl"/>

  <!-- Output ============================================================ -->

  <xsl:param name="xhtmlVersion" select="'-3.2'"/>

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
    <!-- Generate the Helpset, Map, TOC and Index files just before the first
         chunk is being processed. -->

    <xsl:if test="u:chunkIndex(base-uri()) eq 1">
      <xsl:call-template name="generateHelpSet"/>
      <xsl:call-template name="generateMap"/>
      <xsl:call-template name="generateTOC"/>
      <xsl:call-template name="generateIndex"/>
    </xsl:if>

    <xsl:apply-templates/>
  </xsl:template>

  <!-- generateHelpSet =================================================== -->

  <xsl:output name="helpSetOutputFormat"
    method="xml" encoding="UTF-8" indent="yes"
    doctype-public="-//Sun Microsystems Inc.//DTD JavaHelp HelpSet Version 2.0//EN"

    doctype-system="http://java.sun.com/products/javahelp/helpset_2_0.dtd"/>

  <xsl:template name="generateHelpSet">
    <xsl:result-document href="{resolve-uri($helpset-basename, base-uri())}"
                         format="helpSetOutputFormat">
      <helpset version="2.0">
        <title>
          <xsl:value-of select="u:documentTitle()"/>
        </title>
        <maps>
          <homeID>
            <xsl:value-of
              select="$ditacLists/ditac:toc/ditac:tocEntry[1]/@id"/>
          </homeID>
          <mapref location="{$map-basename}"/>
        </maps>
        <view>
          <name>TOC</name>
          <label>TOC</label>
          <type>javax.help.TOCView</type>
          <data><xsl:value-of select="$toc-basename"/></data>
        </view>
        <view>
          <name>Index</name>
          <label>Index</label>
          <type>javax.help.IndexView</type>
          <data><xsl:value-of select="$index-basename"/></data>
        </view>
        <view>
          <name>Search</name>
          <label>Search</label>
          <type>javax.help.SearchView</type>
          <data engine="com.sun.java.help.search.DefaultSearchEngine">
            <xsl:value-of select="$indexer-directory-basename"/>
          </data>
        </view>
      </helpset>
    </xsl:result-document>
  </xsl:template>

  <!-- generateMap ======================================================= -->

  <xsl:output name="mapOutputFormat"
    method="xml" encoding="UTF-8" indent="yes"
    doctype-public="-//Sun Microsystems Inc.//DTD JavaHelp Map Version 2.0//EN"
    doctype-system="http://java.sun.com/products/javahelp/map_2_0.dtd"/>

  <xsl:template name="generateMap">
    <xsl:result-document href="{resolve-uri($map-basename, base-uri())}"
                         format="mapOutputFormat">
      <map version="2.0">
        <xsl:variable name="titlePage" 
          select="$ditacLists/ditac:chunkList/ditac:chunk/ditac:titlePage"/>

        <xsl:if test="$title-page ne 'none' and exists($titlePage)">
          <mapID target="__TP"
                 url="{concat($titlePage/../@file, '#__TP')}"/>
        </xsl:if>

        <xsl:for-each select="$ditacLists/ditac:chunkList/ditac:chunk">
          <xsl:variable name="file" select="string(@file)" />

          <xsl:variable name="chunkPath" 
            select="concat(substring-before($file, '.html'), '.ditac')"/>

          <xsl:variable name="chunk"
                        select="doc(resolve-uri($chunkPath, $ditacListsURI))"/>

          <xsl:for-each select="$chunk//*/(@id|@xml:id)">
            <xsl:variable name="id" select="string(.)" />
            <mapID target="{$id}" url="{concat($file, '#', $id)}"/>
          </xsl:for-each>
        </xsl:for-each>
      </map>
    </xsl:result-document>
  </xsl:template>

  <!-- generateTOC ======================================================= -->

  <xsl:output name="tocOutputFormat"
    method="xml" encoding="UTF-8" indent="yes"
    doctype-public="-//Sun Microsystems Inc.//DTD JavaHelp TOC Version 2.0//EN"
    doctype-system="http://java.sun.com/products/javahelp/toc_2_0.dtd"/>

  <xsl:template name="generateTOC">
    <xsl:result-document href="{resolve-uri($toc-basename, base-uri())}"
                         format="tocOutputFormat">
      <toc version="2.0">
        <xsl:choose>
          <xsl:when test="$add-toc-root eq 'yes'">
            <xsl:variable name="titlePage" 
              select="$ditacLists/ditac:chunkList/ditac:chunk/ditac:titlePage"/>

            <xsl:variable name="tocRootId">
              <xsl:choose>
                <xsl:when test="$title-page ne 'none' and 
                                exists($titlePage)">__TP</xsl:when>
                <xsl:otherwise>
                  <xsl:value-of 
                    select="$ditacLists/ditac:toc/ditac:tocEntry[1]/@id"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <tocitem text="{u:documentTitle()}" target="{$tocRootId}">
              <xsl:call-template name="generateTOCEntries"/>
            </tocitem>
          </xsl:when>

          <xsl:otherwise>
            <xsl:call-template name="generateTOCEntries"/>
          </xsl:otherwise>
        </xsl:choose>
      </toc>
    </xsl:result-document>
  </xsl:template>

  <xsl:template name="generateTOCEntries">
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
  </xsl:template>

  <xsl:template match="ditac:tocEntry" mode="fmbmTOC">
    <xsl:if test="not((@role eq 'toc' or 
                       @role eq 'figurelist' or 
                       @role eq 'tablelist' or 
                       @role eq 'examplelist' or 
                       @role eq 'indexlist') and starts-with(@id, '__AUTO__'))">
      <xsl:variable name="id" select="u:tocEntryAutoId(.)"/>
      <xsl:variable name="title" select="u:tocEntryAutoTitle(.)"/>

      <tocitem text="{$title}" target="{$id}">
        <xsl:apply-templates mode="fmbmTOC"/>
      </tocitem>
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

    <tocitem text="{concat($titlePrefix, u:tocEntryAutoTitle(.))}" 
             target="{@id}">
      <xsl:apply-templates mode="bodyTOC"/>
    </tocitem>
  </xsl:template>

  <!-- generateIndex ===================================================== -->

  <xsl:output name="indexOutputFormat"
    method="xml" encoding="UTF-8" indent="yes"
    doctype-public="-//Sun Microsystems Inc.//DTD JavaHelp Index Version 2.0//EN"
    doctype-system="http://java.sun.com/products/javahelp/index_2_0.dtd"/>

  <xsl:template name="generateIndex">
    <xsl:result-document href="{resolve-uri($index-basename, base-uri())}"
                         format="indexOutputFormat">
      <index version="2.0">
        <xsl:apply-templates
          select="$ditacLists/ditac:indexList/*/ditac:indexEntry"/>
      </index>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="ditac:indexEntry">
    <xsl:variable name="see" select="./ditac:indexSee"/>
    <xsl:choose>
      <xsl:when test="exists($see)">
        <xsl:variable name="title">
          <xsl:value-of select="@term"/>

          <xsl:value-of select="$index-term-see-separator"/>

          <xsl:call-template name="localize">
            <xsl:with-param name="message" select="'see'"/>
          </xsl:call-template>

          <xsl:text> </xsl:text>

          <xsl:for-each select="$see">
            <xsl:if test="position() gt 1">
              <xsl:value-of select="$index-see-separator"/>
            </xsl:if>

            <xsl:variable name="hierarchicalTerm"
              select="string-join(tokenize(@term, '&#xA;'), 
                                  $index-hierarchical-term-separator)"/>
            <xsl:value-of select="$hierarchicalTerm"/>
          </xsl:for-each>
        </xsl:variable>

        <indexitem text="{$title}"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name="seeAlso" select="./ditac:indexSeeAlso"/>
        <xsl:variable name="title">
          <xsl:value-of select="@term"/>

          <xsl:if test="exists($seeAlso)">
            <xsl:value-of select="$index-term-see-separator"/>

            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'seeAlso'"/>
            </xsl:call-template>

            <xsl:text> </xsl:text>

            <xsl:for-each select="$seeAlso">
              <xsl:if test="position() gt 1">
                <xsl:value-of select="$index-see-separator"/>
              </xsl:if>

              <xsl:variable name="hierarchicalTerm"
                select="string-join(tokenize(@term, '&#xA;'), 
                                    $index-hierarchical-term-separator)"/>
              <xsl:value-of select="$hierarchicalTerm"/>
            </xsl:for-each>
          </xsl:if>
        </xsl:variable>

        <indexitem text="{$title}">
          <xsl:variable name="anchor" select="./ditac:indexAnchor[1]"/>
          <xsl:if test="exists($anchor)">
            <xsl:attribute name="target" select="$anchor/@id"/>
          </xsl:if>

          <xsl:apply-templates select="./ditac:indexEntry"/>
        </indexitem>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- li ================================================================ -->

  <!-- Workaround a limitation of the JavaHelp viewer: a HTML li whose first
       child is a div has a bullet/number not vertically aligned with the
       baseline of the div. This limitation makes the JavaHelp looks awful. -->

  <xsl:template match="*[contains(@class,' topic/li ')]">
    <li>
      <xsl:call-template name="commonAttributes"/>

      <xsl:variable name="firstPara" 
                    select="./node()[1][contains(@class,' topic/p ')]"/>
      <xsl:choose>
        <xsl:when test="exists($firstPara)">
          <xsl:if test="exists($firstPara/@id)">
            <span id="{$firstPara/@id}"><xsl:text> </xsl:text></span>
          </xsl:if>
          <xsl:apply-templates select="$firstPara/node()"/>

          <xsl:apply-templates select="./node() except $firstPara"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </li>
  </xsl:template>

  <!-- otherAttributes =================================================== -->

  <!-- Workaround a limitation of the JavaHelp viewer: elements
       having multiple values in their class attribute (e.g. class="foo bar")
       cannot be properly styled. -->

  <xsl:template name="otherAttributes">
    <xsl:param name="class" select="''"/>
    <xsl:param name="classPrefix" select="''"/>

    <xsl:variable name="baseClass">
      <xsl:choose>
        <xsl:when test="$class">
          <xsl:value-of select="$class"/>
        </xsl:when>
        <xsl:when test="@class">
          <xsl:value-of 
              select="concat($classPrefix, u:classToElementName(@class))"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
 
    <xsl:attribute name="class" select="$baseClass"/>
  </xsl:template>

</xsl:stylesheet>
