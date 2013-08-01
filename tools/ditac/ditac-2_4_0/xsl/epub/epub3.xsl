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
                xmlns:htm="http://www.w3.org/1999/xhtml"
                xmlns:mml="http://www.w3.org/1998/Math/MathML"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs htm mml svg u ditac"
                version="2.0">

  <xsl:import href="../xhtml/xhtml5.xsl"/>
  <xsl:import href="epubParams.xsl"/>
  <xsl:import href="epubCommon.xsl"/>
  <xsl:import href="cover.xsl"/>
  <xsl:import href="toc.xsl"/>

  <!-- Overrides ========================================================= -->

  <xsl:template name="otherMeta">
    <xsl:call-template name="otherMetaImpl"/>

    <xsl:choose>
      <xsl:when test="$generate-epub-trigger eq 'yes'">
        <xsl:for-each select="//processing-instruction('onclick')">
          <xsl:call-template name="onclickPIToTriggers"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="exists(//processing-instruction('onclick'))">
          <xsl:call-template name="onclickPIScript"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="otherAttributes">
    <xsl:param name="class" select="''"/>
    <xsl:param name="classPrefix" select="''"/>

    <xsl:call-template name="otherAttributesImpl">
      <xsl:with-param name="class" select="$class"/>
      <xsl:with-param name="classPrefix" select="$classPrefix"/>
    </xsl:call-template>

    <xsl:if test="$generate-epub-trigger ne 'yes'">
      <xsl:for-each select="processing-instruction('onclick')">
        <xsl:call-template name="processOnclickPI"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <!-- ditac:chunk ======================================================= -->

  <xsl:template match="ditac:chunk">
    <!-- Generate content.opf and __toc__.xhtml just before the first chunk is
         being processed. -->

    <xsl:if test="u:chunkIndex(base-uri()) eq 1">
      <xsl:if test="$coverImageName ne ''">
        <!-- With EPUB3, an XHTML page containing the cover image 
             is not useful. -->
        <xsl:call-template name="copyCoverImage"/>
      </xsl:if>

      <xsl:call-template name="generateContent"/>
      <xsl:call-template name="generateTOC">
        <xsl:with-param name="basename" select="'__toc__.xhtml'"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:apply-templates/>
  </xsl:template>

  <!-- generateContent =================================================== -->

  <xsl:output name="contentOutputFormat"
              method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:template name="generateContent">
    <xsl:result-document href="{resolve-uri('content.opf', base-uri())}"
                         format="contentOutputFormat">
      <opf:package version="3.0" unique-identifier="__ID">
        <xsl:call-template name="generateMetadata"/>
        <xsl:call-template name="generateManifest"/>
        <xsl:call-template name="generateSpine"/>
      </opf:package>
    </xsl:result-document>
  </xsl:template>

  <!-- ========== metadata ========== -->

  <xsl:template name="generateMetadata">
    <opf:metadata>
      <dc:identifier id="__ID">
        <xsl:call-template name="epubIdentifier"/>
      </dc:identifier>

      <dc:title>
        <xsl:value-of select="u:documentTitle()"/>
      </dc:title>

      <dc:language>
        <xsl:value-of select="u:documentLang()"/>
      </dc:language>

      <xsl:for-each select="$ditacLists/ditac:titlePage">
        <xsl:call-template name="generateMetadata2"/>
      </xsl:for-each>

      <opf:meta property="dcterms:modified">
        <xsl:value-of
          select="format-dateTime(
                    adjust-dateTime-to-timezone(current-dateTime(), 
                                                xs:dayTimeDuration('PT0S')),
                   '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z', 'en', (), 'US')"/>
      </opf:meta>
    </opf:metadata>
  </xsl:template>

  <xsl:template name="generateMetadata2">
    <!-- Trick: use titlePage templates to generate the text of the meta.
         These templates generate one or more <div class="XXX"> elements.
         possibly containing one or more nested <div> elements. -->

    <xsl:variable name="author">
      <xsl:call-template name="titlePage_author">
        <xsl:with-param name="authorOptions" select="''" tunnel="yes"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="$author/htm:div[@class eq 'document-author']">
      <dc:creator>
        <xsl:value-of select="if (./htm:div) then ./htm:div[1] else ."/>
      </dc:creator>
    </xsl:for-each>

    <xsl:variable name="publisher">
      <xsl:call-template name="titlePage_publisher">
        <xsl:with-param name="publisherOptions" select="''" tunnel="yes"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="$publisher/htm:div[@class eq 'document-publisher']">
      <dc:publisher>
        <xsl:value-of select="if (./htm:div) then ./htm:div[1] else ."/>
      </dc:publisher>
    </xsl:for-each>

    <xsl:variable name="date" 
      select="*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/critdates ')]/*[last()]"/>
    <xsl:if test="exists($date)">
      <xsl:choose>
        <!-- Ignore a date unless it contains YYYY[-MM[-DD]]. -->
        <xsl:when test="matches(string($date/@golive),
                                '^\d\d\d\d(-\d\d(-\d\d)?)?$')">
          <dc:date><!--publication-->
            <xsl:value-of select="string($date/@golive)"/>
          </dc:date>
        </xsl:when>
        <xsl:when test="matches(string($date/@modified),
                                '^\d\d\d\d(-\d\d(-\d\d)?)?$')">
          <dc:date><!--modification-->
            <xsl:value-of select="string($date/@modified)"/>
          </dc:date>
        </xsl:when>
        <xsl:when test="matches(string($date/@date),
                                '^\d\d\d\d(-\d\d(-\d\d)?)?$')">
          <dc:date><!--creation-->
            <xsl:value-of select="string($date/@date)"/>
          </dc:date>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- ========== manifest ========== -->

  <xsl:template name="generateManifest">
    <opf:manifest>
      <!-- nav -->

      <opf:item id="__TOC" properties="nav" 
                href="__toc__.xhtml" media-type="application/xhtml+xml"/>

      <!-- cover-image -->

      <xsl:if test="$coverImageName ne ''">
        <!-- With EPUB3, an XHTML page containing the cover image 
             is not useful. -->
        <opf:item id="cover-image" properties="cover-image" 
                  href="{$coverImageName}">
          <xsl:call-template name="mediaTypeAttribute">
            <xsl:with-param name="path" select="$coverImageName"/>
          </xsl:call-template>
        </opf:item>
      </xsl:if>

      <!-- XHTML files -->

      <xsl:for-each select="$ditacLists/ditac:chunkList/ditac:chunk">
        <xsl:variable name="file" select="string(@file)"/>
        <xsl:variable name="chunkPath" 
          select="concat(substring-before($file, u:suffix($file)), '.ditac')"/>

        <xsl:variable name="chunk"
                      select="doc(resolve-uri($chunkPath, $ditacListsURI))"/>

        <xsl:variable name="properties">
          <!-- SVG embedded by inclusion or by reference. -->
          <xsl:if 
            test="exists($chunk//svg:svg) or
                  exists($chunk//*[contains(@class,' topic/image ') and
                                   (ends-with(@href, '.svg') or
                                    ends-with(@href, '.svgz'))])">svg</xsl:if>

          <xsl:if test="exists($chunk//mml:math)">
            <xsl:text> mathml</xsl:text>
          </xsl:if>

          <xsl:if test="$generate-epub-trigger ne 'yes'">
            <xsl:if test="exists($chunk//processing-instruction('onclick'))">
              <xsl:text> scripted</xsl:text>
            </xsl:if>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="properties2" select="normalize-space($properties)"/>

        <opf:item id="{generate-id(.)}" 
                  href="{string(@file)}" media-type="application/xhtml+xml">
          <xsl:if test="$properties2 ne ''">
            <xsl:attribute name="properties" select="$properties2"/>
          </xsl:if>
        </opf:item>
      </xsl:for-each>

      <!-- Resource (e.g. images) files -->
      <!-- XSL resource files. -->
      <!-- (Custom XSL resources, custom CSS file not supported.) -->

      <xsl:call-template name="generateResourceItems"/>

    </opf:manifest>
  </xsl:template>

  <!-- ========== spine ========== -->

  <xsl:template name="generateSpine">
    <opf:spine>
      <!-- No need to reference __toc__.xhtml here. -->

      <xsl:for-each select="$ditacLists/ditac:chunkList/ditac:chunk">
        <opf:itemref idref="{generate-id(.)}"/>
      </xsl:for-each>
    </opf:spine>
  </xsl:template>

</xsl:stylesheet>
