<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2010-2013 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:htm="http://www.w3.org/1999/xhtml"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcterms="http://purl.org/dc/terms/"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs htm u ditac"
                version="2.0">

  <xsl:import href="../xhtml/xhtml1_1.xsl"/>
  <xsl:import href="epubParams.xsl"/>
  <xsl:import href="epubCommon.xsl"/>
  <xsl:import href="cover.xsl"/>

  <!-- Overrides ========================================================= -->

  <xsl:param name="xhtml-mime-type" select="'application/xhtml+xml'"/>

  <xsl:template name="linkBullet">
    <!-- &#x2023; not displayed by ADE, IE6, etc. -->
    <b>&#xBB; </b>
  </xsl:template>

  <!-- ditac:chunk ======================================================= -->

  <xsl:template match="ditac:chunk">
    <!-- Generate content.opf and toc.ncx just before the first chunk is being
         processed. -->

    <xsl:if test="u:chunkIndex(base-uri()) eq 1">
      <xsl:if test="$coverImageName ne ''">
        <xsl:call-template name="generateCover">
          <!-- Should be cover.html -->
          <xsl:with-param name="basename" select="'cover.xml'"/>
        </xsl:call-template>
      </xsl:if>

      <xsl:call-template name="generateContent"/>
      <xsl:call-template name="generateTOC"/>
    </xsl:if>

    <xsl:apply-templates/>
  </xsl:template>

  <!-- generateContent =================================================== -->

  <xsl:output name="contentOutputFormat"
              method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:template name="generateContent">
    <xsl:result-document href="{resolve-uri('content.opf', base-uri())}"
                         format="contentOutputFormat">
      <opf:package version="2.0" unique-identifier="__ID">
        <xsl:call-template name="generateMetadata"/>
        <xsl:call-template name="generateManifest"/>
        <xsl:call-template name="generateSpine"/>
        <xsl:call-template name="generateGuide"/>
      </opf:package>
    </xsl:result-document>
  </xsl:template>

  <!-- ========== metadata ========== -->

  <xsl:template name="generateMetadata">
    <opf:metadata>
      <dc:title>
        <xsl:value-of select="u:documentTitle()"/>
      </dc:title>

      <dc:language>
        <xsl:value-of select="u:documentLang()"/>
      </dc:language>

      <dc:identifier id="__ID">
        <xsl:call-template name="epubIdentifier"/>
      </dc:identifier>

      <xsl:for-each select="$ditacLists/ditac:titlePage">
        <xsl:call-template name="generateMetadata2"/>
      </xsl:for-each>

      <!-- See Best practices in ePub cover images
           http://blog.threepress.org/2009/11/20/
               best-practices-in-epub-cover-images/ -->
      <xsl:if test="$coverImageName ne ''">
        <opf:meta name="cover" content="cover-image"/>
      </xsl:if>
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
          <dc:date opf:event="publication">
            <xsl:value-of select="string($date/@golive)"/>
          </dc:date>
        </xsl:when>
        <xsl:when test="matches(string($date/@modified),
                                '^\d\d\d\d(-\d\d(-\d\d)?)?$')">
          <dc:date opf:event="modification">
            <xsl:value-of select="string($date/@modified)"/>
          </dc:date>
        </xsl:when>
        <xsl:when test="matches(string($date/@date),
                                '^\d\d\d\d(-\d\d(-\d\d)?)?$')">
          <dc:date opf:event="creation">
            <xsl:value-of select="string($date/@date)"/>
          </dc:date>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- ========== manifest ========== -->

  <xsl:template name="generateManifest">
    <opf:manifest>
      <!-- TOC -->

      <opf:item id="__TOC" href="toc.ncx" 
                media-type="application/x-dtbncx+xml" />

      <!-- Cover -->
      <!-- See Best practices in ePub cover images
           http://blog.threepress.org/2009/11/20/
               best-practices-in-epub-cover-images/ -->

      <xsl:if test="$coverImageName ne ''">
        <opf:item id="cover" href="cover.xml" 
                  media-type="application/xhtml+xml"/>

        <opf:item id="cover-image" href="{$coverImageName}">
          <xsl:call-template name="mediaTypeAttribute">
            <xsl:with-param name="path" select="$coverImageName"/>
          </xsl:call-template>
        </opf:item>
      </xsl:if>

      <!-- XHTML files -->

      <xsl:for-each select="$ditacLists/ditac:chunkList/ditac:chunk">
        <opf:item id="{generate-id(.)}" href="{string(@file)}" 
                  media-type="application/xhtml+xml"/>
      </xsl:for-each>

      <!-- Resource (e.g. images) files -->
      <!-- XSL resource files. -->
      <!-- (Custom XSL resources, custom CSS file not supported.) -->

      <xsl:call-template name="generateResourceItems"/>

    </opf:manifest>
  </xsl:template>

  <!-- ========== spine ========== -->

  <xsl:template name="generateSpine">
    <opf:spine toc="__TOC">
      <!-- See Best practices in ePub cover images
           http://blog.threepress.org/2009/11/20/
               best-practices-in-epub-cover-images/ -->
      <xsl:if test="$coverImageName ne ''">
        <opf:itemref idref="cover" linear="no"/>
      </xsl:if>

      <xsl:for-each select="$ditacLists/ditac:chunkList/ditac:chunk">
        <opf:itemref idref="{generate-id(.)}"/>
      </xsl:for-each>
    </opf:spine>
  </xsl:template>

  <!-- ========== guide ========== -->

  <xsl:template name="generateGuide">
    <opf:guide>
      <!-- See Best practices in ePub cover images
           http://blog.threepress.org/2009/11/20/
               best-practices-in-epub-cover-images/ -->
      <xsl:if test="$coverImageName ne ''">
        <opf:reference type="cover" title="{u:localize('cover', .)}" 
                       href="cover.xml"/>
      </xsl:if>

      <xsl:variable name="firstTopic"
        select="($ditacLists/ditac:chunkList/ditac:chunk/ditac:topic)[1]"/>

      <xsl:for-each select="$ditacLists/ditac:chunkList/ditac:chunk">
        <xsl:variable name="file" select="string(@file)"/>

        <xsl:for-each select="*">
          <xsl:choose>
            <xsl:when test=". is $firstTopic">
              <opf:reference type="text" title="{u:autoTitle(@title, .)}" 
                             href="{concat($file, '#', @id)}"/>
            </xsl:when>

            <xsl:when test="self::ditac:titlePage and $title-page ne 'none'">
              <opf:reference type="title-page" 
                             title="{u:localize('titlePage', .)}" 
                             href="{concat($file, '#__TP')}"/>
            </xsl:when>

            <xsl:when test="self::ditac:figureList">
              <opf:reference type="loi" title="{u:localize('figurelist', .)}" 
                             href="{concat($file, '#', $figurelistId)}"/>
            </xsl:when>

            <xsl:when test="self::ditac:tableList">
              <opf:reference type="lot" title="{u:localize('tablelist', .)}" 
                             href="{concat($file, '#', $tablelistId)}"/>
            </xsl:when>

            <!-- Not supported by EPUB: loe.

            <xsl:when test="self::ditac:exampleList">
              <opf:reference type="loe" title="{u:localize('examplelist', .)}" 
                             href="{concat($file, '#', $examplelistId)}"/>
            </xsl:when>

            -->

            <xsl:when test="self::ditac:indexList">
              <opf:reference type="index" title="{u:localize('indexlist', .)}" 
                             href="{concat($file, '#', $indexlistId)}"/>
            </xsl:when>

          </xsl:choose>
        </xsl:for-each>
      </xsl:for-each>
    </opf:guide>
  </xsl:template>

  <!-- generateTOC ======================================================= -->

  <xsl:output name="tocOutputFormat"
    method="xml" encoding="UTF-8" indent="yes"
    doctype-public="-//NISO//DTD ncx 2005-1//EN"
    doctype-system="http://www.daisy.org/z3986/2005/ncx-2005-1.dtd"/>

  <xsl:template name="generateTOC">
    <xsl:result-document href="{resolve-uri('toc.ncx', base-uri())}"
                         format="tocOutputFormat">

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

      <xsl:variable name="tocEntries"
                    select="($tocEntries1, $tocEntries2, $tocEntries3)"/>

      <xsl:variable name="tocDepth" 
        select="max(for $e in $tocEntries
                    return
                        count($e/ancestor-or-self::ditac:tocEntry))"/>

      <ncx:ncx version="2005-1">
        <ncx:head>
          <ncx:meta name="dtb:uid">
            <xsl:attribute name="content">
              <xsl:call-template name="epubIdentifier"/>
            </xsl:attribute>
          </ncx:meta>
          <ncx:meta name="dtb:depth" content="{$tocDepth}"/>
          <ncx:meta name="dtb:totalPageCount" content="0"/>
          <ncx:meta name="dtb:maxPageNumber" content="0"/>
        </ncx:head>

        <ncx:docTitle>
          <ncx:text><xsl:value-of select="u:documentTitle()"/></ncx:text>
        </ncx:docTitle>

        <ncx:navMap>
          <xsl:if test="$hasTOCEntries1">
            <xsl:apply-templates mode="fmbmTOC" 
              select="$ditacLists/ditac:frontmatterTOC/ditac:tocEntry">
              <xsl:with-param name="tocEntries" select="$tocEntries"/>
            </xsl:apply-templates>
          </xsl:if>

          <xsl:apply-templates mode="bodyTOC"
            select="$ditacLists/ditac:toc/ditac:tocEntry">
            <xsl:with-param name="tocEntries" select="$tocEntries"/>
          </xsl:apply-templates>

          <xsl:if test="$hasTOCEntries3">
            <xsl:apply-templates mode="fmbmTOC"
              select="$ditacLists/ditac:backmatterTOC/ditac:tocEntry">
              <xsl:with-param name="tocEntries" select="$tocEntries"/>
            </xsl:apply-templates>
          </xsl:if>
        </ncx:navMap>
      </ncx:ncx>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="ditac:tocEntry" mode="fmbmTOC">
    <xsl:param name="tocEntries" select="()"/>

    <xsl:if test="not(@role eq 'toc' and starts-with(@id, '__AUTO__'))">
      <xsl:variable name="id" select="u:tocEntryAutoId(.)"/>
      <xsl:variable name="title" select="u:tocEntryAutoTitle(.)"/>

      <xsl:variable name="playOrder" select="u:indexOfNode($tocEntries, .)"/>

      <ncx:navPoint id="{concat('__TOCE', $playOrder)}" 
                    playOrder="{$playOrder}">
        <ncx:navLabel>
          <ncx:text><xsl:value-of select="$title"/></ncx:text>
        </ncx:navLabel>
        <ncx:content src="{concat(@file, '#', $id)}"/>

        <xsl:apply-templates select="./ditac:tocEntry" mode="fmbmTOC">
          <xsl:with-param name="tocEntries" select="$tocEntries"/>
        </xsl:apply-templates>
      </ncx:navPoint>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ditac:tocEntry" mode="bodyTOC">
    <xsl:param name="tocEntries" select="()"/>

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

    <xsl:variable name="playOrder" select="u:indexOfNode($tocEntries, .)"/>

    <ncx:navPoint id="{concat('__TOCE', $playOrder)}" 
                  playOrder="{$playOrder}">
      <ncx:navLabel>
        <ncx:text>
          <xsl:value-of select="concat($titlePrefix, u:tocEntryAutoTitle(.))"/>
        </ncx:text>
      </ncx:navLabel>
      <ncx:content src="{concat(@file, '#', @id)}"/>

      <xsl:apply-templates select="./ditac:tocEntry" mode="bodyTOC">
        <xsl:with-param name="tocEntries" select="$tocEntries"/>
      </xsl:apply-templates>
    </ncx:navPoint>
  </xsl:template>

</xsl:stylesheet>
