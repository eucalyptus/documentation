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
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                xmlns:URI="java:com.xmlmind.ditac.xslt.URI"
                exclude-result-prefixes="xs u ditac URI"
                version="2.0">

  <xsl:import href="../xhtml/xhtmlBase.xsl"/>
  <xsl:import href="htmlhelpParams.xsl"/>

  <!-- Output ============================================================ -->

  <xsl:param name="xhtmlVersion" select="'-4.1'"/>

  <!-- Specify the output encoding here and also everywhere below. -->
  <xsl:param name="xhtmlEncoding" select="'iso-8859-1'"/>

  <xsl:output method="html" encoding="iso-8859-1" indent="no"/>

  <!-- ditac:toc, figureList, tableList, exampleList, indexList ========== -->
  <!-- All suppressed. -->

  <xsl:template match="ditac:toc"/>
  <xsl:template match="ditac:figureList"/>
  <xsl:template match="ditac:tableList"/>
  <xsl:template match="ditac:exampleList"/>
  <xsl:template match="ditac:indexList"/>

  <!-- ditac:chunk ======================================================= -->

  <xsl:template match="ditac:chunk">
    <!-- Generate the Project, TOC and Index files just before the first chunk
         is being processed. -->

    <xsl:if test="u:chunkIndex(base-uri()) eq 1">
      <xsl:call-template name="generateProject"/>
      <xsl:call-template name="generateTOC"/>
      <xsl:if test="u:hasIndex()">
        <xsl:call-template name="generateIndex"/>
      </xsl:if>
    </xsl:if>

    <xsl:apply-templates/>
  </xsl:template>

  <!-- generateProject =================================================== -->

  <xsl:output name="projectOutputFormat"
    method="text" encoding="iso-8859-1"/>

  <xsl:template name="generateProject">
    <xsl:variable name="language" 
                  select="u:toHTMLHelpLang(string($ditacLists/@xml:lang))"/>
    <!-- Here we use filenames, not (quoted) relative URLs. -->
    <xsl:variable name="chmFileName" select="URI:decodeURI($chmBasename)"/>
    <xsl:variable name="hhpFileName" select="URI:decodeURI($hhpBasename)"/>
    <xsl:variable name="hhcFileName" select="URI:decodeURI($hhc-basename)"/>
    <xsl:variable name="hhxFileName" select="URI:decodeURI($hhx-basename)"/>

    <!-- We output plain text, not xml.
         Therefore we are really limited to iso-8859-1 chars! -->
    <xsl:variable name="quot">&quot;&#x2013;&#x2014;</xsl:variable>
    <xsl:variable name="apos">&apos;--</xsl:variable>
    <xsl:variable name="title" 
                  select="translate(u:documentTitle(), $quot, $apos)"/>
    <xsl:variable name="defaultTopic" 
                  select="$ditacLists/ditac:toc/ditac:tocEntry[1]/@file"/>
    <xsl:variable name="files" 
                  select="$ditacLists/ditac:chunkList/ditac:chunk/@file"/>

    <xsl:variable name="hasIndex" select="u:hasIndex()"/>
    <xsl:variable name="indexFileLine">
      <xsl:choose>
        <xsl:when test="$hasIndex">
          <xsl:value-of select="concat('Index file=', $hhxFileName)"/>
        </xsl:when>
        <xsl:otherwise>;;;Index file=</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="quotedIndexFile">
      <xsl:choose>
        <xsl:when test="$hasIndex">
          <xsl:variable name="quot">&quot;</xsl:variable>
          <xsl:value-of select="concat($quot, $hhxFileName, $quot)"/>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="project" 
      select="replace($hhpTemplate, '%compiledFile%', $chmFileName)"/>
    <xsl:variable name="project2" 
      select="replace($project, '%contentsFile%', $hhcFileName)"/>
    <xsl:variable name="project3" 
      select="replace($project2, '%language%', $language)"/>
    <xsl:variable name="project4" 
      select="replace($project3, '%title%', $title)"/>
    <xsl:variable name="project5" 
      select="replace($project4, '%defaultTopic%', $defaultTopic)"/>
    <xsl:variable name="project6" 
      select="replace($project5, '%files%', 
                      string-join($files, '&#xD;&#xA;'))"/>
    <xsl:variable name="project7" 
      select="replace($project6, '%indexFileLine%', $indexFileLine)"/>
    <xsl:variable name="project8" 
      select="replace($project7, '%quotedIndexFile%', $quotedIndexFile)"/>

    <xsl:result-document href="{resolve-uri($hhpBasename, base-uri())}"
      format="projectOutputFormat"
      ><xsl:value-of select="$project8"/></xsl:result-document>
  </xsl:template>

  <!-- generateTOC ======================================================= -->

  <xsl:character-map name="crLF">
    <xsl:output-character character="&#xA;" string="&#xD;&#xA;" />
  </xsl:character-map>

  <xsl:output name="hhcOutputFormat"
    method="html" encoding="iso-8859-1" use-character-maps="crLF"
    indent="no" include-content-type="no"/>

  <xsl:template name="generateTOC">
    <xsl:result-document href="{resolve-uri($hhc-basename, base-uri())}"
                         format="hhcOutputFormat">

      <HTML><xsl:text>&#xA;</xsl:text>
        <HEAD><xsl:text>&#xA;</xsl:text>
        </HEAD><xsl:text>&#xA;</xsl:text>
        <BODY><xsl:text>&#xA;</xsl:text>
          <UL><xsl:text>&#xA;</xsl:text>
            <xsl:choose>
              <xsl:when test="$add-toc-root = 'yes'">
                <xsl:variable name="firstChunkFile" 
                  select="$ditacLists/ditac:chunkList/ditac:chunk[1]/@file"/>

                <LI><OBJECT type="text/sitemap"><xsl:text>&#xA;</xsl:text>
                  <param name="Name" 
                  value="{u:documentTitle()}"></param><xsl:text>&#xA;</xsl:text>
                  <param name="Local" 
                    value="{$firstChunkFile}"></param><xsl:text>&#xA;</xsl:text>
                </OBJECT></LI><xsl:text>&#xA;</xsl:text>

                <UL><xsl:text>&#xA;</xsl:text>
                  <xsl:call-template name="generateTOCEntries"/>
                </UL>
              </xsl:when>

              <xsl:otherwise>
                <xsl:call-template name="generateTOCEntries"/>
              </xsl:otherwise>
            </xsl:choose>
          </UL><xsl:text>&#xA;</xsl:text>
        </BODY></HTML><xsl:text>&#xA;</xsl:text>
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
    <xsl:if test="not((@role = 'toc' or 
                       @role = 'figurelist' or 
                       @role = 'tablelist' or 
                       @role = 'examplelist' or 
                       @role = 'indexlist') and @id = '__AUTO__')">
      <xsl:variable name="id" select="u:fmbmTOCEntryId(.)"/>
      <xsl:variable name="title" select="u:fmbmTOCEntryTitle(.)"/>

      <LI><OBJECT type="text/sitemap"><xsl:text>&#xA;</xsl:text>
        <param name="Name"
        value="{$title}"></param><xsl:text>&#xA;</xsl:text>
        <param name="Local" 
        value="{concat(@file, '#', $id)}"></param><xsl:text>&#xA;</xsl:text>
      </OBJECT></LI><xsl:text>&#xA;</xsl:text>

      <!-- Note that UL is not contained in its parent LI.
           Here UL seems to mean indent by one level. -->

      <xsl:if test="exists(./ditac:tocEntry)">
        <UL><xsl:text>&#xA;</xsl:text>
          <xsl:apply-templates mode="fmbmTOC"/>
        </UL>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ditac:tocEntry" mode="bodyTOC">
    <xsl:variable name="num" 
                  select="if ($number-toc-entries = 'yes') then
                              u:shortTitlePrefix(string(@number), .)
                          else
                              ''"/>

    <xsl:variable name="titlePrefix">
      <xsl:choose>
        <xsl:when test="$num != ''">
          <xsl:choose>
            <xsl:when test="@role = 'part' or
                            @role = 'chapter' or
                            @role = 'appendix'">
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

    <LI><OBJECT type="text/sitemap"><xsl:text>&#xA;</xsl:text>
      <param name="Name"
      value="{concat($titlePrefix, @title)}"></param><xsl:text>&#xA;</xsl:text>
      <param name="Local" 
      value="{concat(@file, '#', @id)}"></param><xsl:text>&#xA;</xsl:text>
    </OBJECT></LI><xsl:text>&#xA;</xsl:text>

    <xsl:if test="exists(./ditac:tocEntry)">
      <UL><xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates mode="bodyTOC"/>
      </UL>
    </xsl:if>
  </xsl:template>

  <!-- generateIndex ===================================================== -->

  <xsl:template name="generateIndex">
    <xsl:result-document href="{resolve-uri($hhx-basename, base-uri())}"
                         format="hhcOutputFormat">
      <HTML><xsl:text>&#xA;</xsl:text>
        <HEAD><xsl:text>&#xA;</xsl:text>
        </HEAD><xsl:text>&#xA;</xsl:text>
        <BODY><xsl:text>&#xA;</xsl:text>
          <UL><xsl:text>&#xA;</xsl:text>
            <xsl:apply-templates
              select="$ditacLists/ditac:indexList/*/ditac:indexEntry"/>
          </UL><xsl:text>&#xA;</xsl:text>
        </BODY></HTML><xsl:text>&#xA;</xsl:text>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="ditac:indexEntry">
    <xsl:if test="empty(./ditac:indexSee)">
      <xsl:variable name="anchor" select="./ditac:indexAnchor[1]"/>

      <LI><OBJECT type="text/sitemap"><xsl:text>&#xA;</xsl:text>
        <param name="Name"
          value="{@term}"></param><xsl:text>&#xA;</xsl:text>
        <xsl:choose>
          <xsl:when test="exists($anchor)">
            <param name="Local" 
              value="{concat($anchor/@file, '#', $anchor/@id)}"></param>
            <xsl:text>&#xA;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <!-- Trick to make this non-leaf entry appear in the viewer. -->
            <param name="See Also"
              value="{@term}"></param><xsl:text>&#xA;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </OBJECT></LI><xsl:text>&#xA;</xsl:text>

      <!-- Note that UL is not contained in its parent LI.
           Here UL seems to mean indent by one level. -->

      <xsl:if test="exists(./ditac:indexEntry)">
        <UL><xsl:text>&#xA;</xsl:text>
          <xsl:apply-templates select="./ditac:indexEntry"/>
        </UL>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- u:toHTMLHelpLang ================================================== -->

  <xsl:function name="u:toHTMLHelpLang" as="xs:string">
    <xsl:param name="language" as="xs:string"/>

    <xsl:variable name="lang"
                  select="lower-case(translate($language, '_', '-'))"/>
    <xsl:choose>
      <xsl:when test="$lang = 'af'">
        <xsl:sequence select="'0x0436 Afrikaans'"/>
      </xsl:when>
      <xsl:when test="$lang = 'sq'">
        <xsl:sequence select="'0x041C Albanian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar'">
        <xsl:sequence select="'0x0C01 Arabic (EGYPT)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-eg'">
        <xsl:sequence select="'0x0C01 Arabic (EGYPT)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-ae'">
        <xsl:sequence select="'0x3801 Arabic (UNITED ARAB EMIRATES)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-bh'">
        <xsl:sequence select="'0x3C01 Arabic (BAHRAIN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-dz'">
        <xsl:sequence select="'0x1401 Arabic (ALGERIA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-iq'">
        <xsl:sequence select="'0x0801 Arabic (IRAQ)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-jo'">
        <xsl:sequence select="'0x2C01 Arabic (JORDAN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-kw'">
        <xsl:sequence select="'0x3401 Arabic (KUWAIT)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-lb'">
        <xsl:sequence select="'0x3001 Arabic (LEBANON)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-ly'">
        <xsl:sequence select="'0x1001 Arabic (LIBYA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-ma'">
        <xsl:sequence select="'0x1801 Arabic (MOROCCO)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-om'">
        <xsl:sequence select="'0x2001 Arabic (OMAN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-qa'">
        <xsl:sequence select="'0x4001 Arabic (QATAR)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-sa'">
        <xsl:sequence select="'0x0401 Arabic (SAUDI ARABIA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-sy'">
        <xsl:sequence select="'0x2801 Arabic (SYRIA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-tn'">
        <xsl:sequence select="'0x1C01 Arabic (TUNISIA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ar-ye'">
        <xsl:sequence select="'0x2401 Arabic (YEMEN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'hy'">
        <xsl:sequence select="'0x042B Armenian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'az'">
        <xsl:sequence select="'0x042C Azeri (LATIN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'az-az'">
        <xsl:sequence select="'0x042C Azeri (LATIN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'az-cryl-az'">
        <xsl:sequence select="'0x082C Azeri (CYRILLIC)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'eu'">
        <xsl:sequence select="'0x042D Basque'"/>
      </xsl:when>
      <xsl:when test="$lang = 'be'">
        <xsl:sequence select="'0x0423 Belarusian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'bg'">
        <xsl:sequence select="'0x0402 Bulgarian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ca'">
        <xsl:sequence select="'0x0403 Catalan'"/>
      </xsl:when>
      <xsl:when test="$lang = 'zh'">
        <xsl:sequence select="'0x0804 Chinese (CHINA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'zh-cn'">
        <xsl:sequence select="'0x0804 Chinese (CHINA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'zh-hk'">
        <xsl:sequence select="'0x0C04 Chinese (HONG KONG SAR)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'zh-mo'">
        <xsl:sequence select="'0x1404 Chinese (MACAU SAR)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'zh-sg'">
        <xsl:sequence select="'0x1004 Chinese (SINGAPORE)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'zh-tw'">
        <xsl:sequence select="'0x0404 Chinese (TAIWAN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'hr'">
        <xsl:sequence select="'0x041A Croatian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'cs'">
        <xsl:sequence select="'0x0405 Czech'"/>
      </xsl:when>
      <xsl:when test="$lang = 'da'">
        <xsl:sequence select="'0x0406 Danish'"/>
      </xsl:when>
      <xsl:when test="$lang = 'nl'">
        <xsl:sequence select="'0x0413 Dutch (NETHERLANDS)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'nl-nl'">
        <xsl:sequence select="'0x0413 Dutch (NETHERLANDS)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'nl-be'">
        <xsl:sequence select="'0x0813 Dutch (BELGIUM)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'en'">
        <xsl:sequence select="'0x0409 English (UNITED STATES)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'en-us'">
        <xsl:sequence select="'0x0409 English (UNITED STATES)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'en-au'">
        <xsl:sequence select="'0x0C09 English (AUSTRALIA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'en-bz'">
        <xsl:sequence select="'0x2809 English (BELIZE)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'en-ca'">
        <xsl:sequence select="'0x1009 English (CANADA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'en-cb'">
        <xsl:sequence select="'0x2409 English (CARIBBEAN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'en-ie'">
        <xsl:sequence select="'0x1809 English (IRELAND)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'en-jm'">
        <xsl:sequence select="'0x2009 English (JAMAICA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'en-nz'">
        <xsl:sequence select="'0x1409 English (NEW ZEALAND)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'en-ph'">
        <xsl:sequence select="'0x3409 English (PHILLIPPINES)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'en-za'">
        <xsl:sequence select="'0x1C09 English (SOUTHERN AFRICA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'en-tt'">
        <xsl:sequence select="'0x2C09 English (TRINIDAD)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'en-gb'">
        <xsl:sequence select="'0x0809 English (GREAT BRITAIN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'et'">
        <xsl:sequence select="'0x0425 Estonian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'fa'">
        <xsl:sequence select="'0x0429 Farsi'"/>
      </xsl:when>
      <xsl:when test="$lang = 'fi'">
        <xsl:sequence select="'0x040B Finnish'"/>
      </xsl:when>
      <xsl:when test="$lang = 'fo'">
        <xsl:sequence select="'0x0438 Faroese'"/>
      </xsl:when>
      <xsl:when test="$lang = 'fr'">
        <xsl:sequence select="'0x040C French (FRANCE)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'fr-fr'">
        <xsl:sequence select="'0x040C French (FRANCE)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'fr-be'">
        <xsl:sequence select="'0x080C French (BELGIUM)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'fr-ca'">
        <xsl:sequence select="'0x0C0C French (CANADA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'fr-lu'">
        <xsl:sequence select="'0x140C French (LUXEMBOURG)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'fr-ch'">
        <xsl:sequence select="'0x100C French (SWITZERLAND)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'gd'">
        <xsl:sequence select="'0x083C Gaelic (IRELAND)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'gd-ie'">
        <xsl:sequence select="'0x083C Gaelic (IRELAND)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'gd'">
        <xsl:sequence select="'0x043C Gaelic (SCOTLAND)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'de'">
        <xsl:sequence select="'0x0407 German (GERMANY)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'de-de'">
        <xsl:sequence select="'0x0407 German (GERMANY)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'de-at'">
        <xsl:sequence select="'0x0C07 German (AUSTRIA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'de-li'">
        <xsl:sequence select="'0x1407 German (LIECHTENSTEIN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'de-lu'">
        <xsl:sequence select="'0x1007 German (LUXEMBOURG)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'de-ch'">
        <xsl:sequence select="'0x0807 German (SWITZERLAND)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'el'">
        <xsl:sequence select="'0x0408 Greek'"/>
      </xsl:when>
      <xsl:when test="$lang = 'he'">
        <xsl:sequence select="'0x040D Hebrew'"/>
      </xsl:when>
      <xsl:when test="$lang = 'hi'">
        <xsl:sequence select="'0x0439 Hindi'"/>
      </xsl:when>
      <xsl:when test="$lang = 'hu'">
        <xsl:sequence select="'0x040E Hungarian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'is'">
        <xsl:sequence select="'0x040F Icelandic'"/>
      </xsl:when>
      <xsl:when test="$lang = 'id'">
        <xsl:sequence select="'0x0421 Indonesian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'it'">
        <xsl:sequence select="'0x0410 Italian (ITALY)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'it-it'">
        <xsl:sequence select="'0x0410 Italian (ITALY)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'it-ch'">
        <xsl:sequence select="'0x0810 Italian (SWITZERLAND)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ja'">
        <xsl:sequence select="'0x0411 Japanese'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ko'">
        <xsl:sequence select="'0x0412 Korean'"/>
      </xsl:when>
      <xsl:when test="$lang = 'lv'">
        <xsl:sequence select="'0x0426 Latvian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'lt'">
        <xsl:sequence select="'0x0427 Lithuanian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'mk'">
        <xsl:sequence select="'0x042F F.Y.R.O. Macedonia'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ms'">
        <xsl:sequence select="'0x043E Malay (MALAYSIA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ms-my'">
        <xsl:sequence select="'0x043E Malay (MALAYSIA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ms-bn'">
        <xsl:sequence select="'0x083E Malay (BRUNEI)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'mt'">
        <xsl:sequence select="'0x043A Maltese'"/>
      </xsl:when>
      <xsl:when test="$lang = 'mr'">
        <xsl:sequence select="'0x044E Marathi'"/>
      </xsl:when>
      <xsl:when test="$lang = 'no'">
        <xsl:sequence select="'0x0414 Norwegian (BOKML)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'no-no'">
        <xsl:sequence select="'0x0414 Norwegian (BOKML)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'no-no'">
        <xsl:sequence select="'0x0814 Norwegian (NYNORSK)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'pl'">
        <xsl:sequence select="'0x0415 Polish'"/>
      </xsl:when>
      <xsl:when test="$lang = 'pt'">
        <xsl:sequence select="'0x0816 Portuguese (PORTUGAL)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'pt-pt'">
        <xsl:sequence select="'0x0816 Portuguese (PORTUGAL)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'pt-br'">
        <xsl:sequence select="'0x0416 Portuguese (BRAZIL)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'rm'">
        <xsl:sequence select="'0x0417 Raeto-Romance'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ro'">
        <xsl:sequence select="'0x0418 Romanian (ROMANIA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ro-mo'">
        <xsl:sequence select="'0x0818 Romanian (REPUBLIC OF MOLDOVA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ru'">
        <xsl:sequence select="'0x0419 Russian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ru-mo'">
        <xsl:sequence select="'0x0819 Russian (REPUBLIC OF MOLDOVA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'sa'">
        <xsl:sequence select="'0x044F Sanskrit'"/>
      </xsl:when>
      <xsl:when test="$lang = 'sr'">
        <xsl:sequence select="'0x0C1A Serbian (CYRILLIC)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'sr-sp'">
        <xsl:sequence select="'0x0C1A Serbian (CYRILLIC)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'sr-latn-sp'">
        <xsl:sequence select="'0x081A Serbian (LATIN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'tn'">
        <xsl:sequence select="'0x0432 Setsuana'"/>
      </xsl:when>
      <xsl:when test="$lang = 'sl'">
        <xsl:sequence select="'0x0424 Slovenian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'sk'">
        <xsl:sequence select="'0x041B Slovak'"/>
      </xsl:when>
      <xsl:when test="$lang = 'sb'">
        <xsl:sequence select="'0x042E Sorbian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es'">
        <xsl:sequence select="'0x040A Spanish (SPAIN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-es'">
        <xsl:sequence select="'0x040A Spanish (SPAIN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-ar'">
        <xsl:sequence select="'0x2C0A Spanish (ARGENTINA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-bo'">
        <xsl:sequence select="'0x400A Spanish (BOLIVIA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-cl'">
        <xsl:sequence select="'0x340A Spanish (CHILE)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-co'">
        <xsl:sequence select="'0x240A Spanish (COLOMBIA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-cr'">
        <xsl:sequence select="'0x140A Spanish (COSTA RICA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-do'">
        <xsl:sequence select="'0x1C0A Spanish (DOMINICAN REPUBLIC)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-ec'">
        <xsl:sequence select="'0x300A Spanish (ECUADOR)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-gt'">
        <xsl:sequence select="'0x100A Spanish (GUATEMALA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-hn'">
        <xsl:sequence select="'0x480A Spanish (HONDURAS)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-mx'">
        <xsl:sequence select="'0x080A Spanish (MEXICO)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-ni'">
        <xsl:sequence select="'0x4C0A Spanish (NICARAGUA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-pa'">
        <xsl:sequence select="'0x180A Spanish (PANAMA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-pe'">
        <xsl:sequence select="'0x280A Spanish (PERU)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-pr'">
        <xsl:sequence select="'0x500A Spanish (PUERTO RICO)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-py'">
        <xsl:sequence select="'0x3C0A Spanish (PARAGUAY)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-sv'">
        <xsl:sequence select="'0x440A Spanish (EL SALVADOR)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-uy'">
        <xsl:sequence select="'0x380A Spanish (URUGUAY)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'es-ve'">
        <xsl:sequence select="'0x200A Spanish (VENEZUELA)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'st'">
        <xsl:sequence select="'0x0430 Southern Sotho'"/>
      </xsl:when>
      <xsl:when test="$lang = 'sw'">
        <xsl:sequence select="'0x0441 Swahili'"/>
      </xsl:when>
      <xsl:when test="$lang = 'sv'">
        <xsl:sequence select="'0x041D Swedish (SWEDEN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'sv-se'">
        <xsl:sequence select="'0x041D Swedish (SWEDEN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'sv-fi'">
        <xsl:sequence select="'0x081D Swedish (FINLAND)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ta'">
        <xsl:sequence select="'0x0449 Tamil'"/>
      </xsl:when>
      <xsl:when test="$lang = 'tt'">
        <xsl:sequence select="'0X0444 Tatar'"/>
      </xsl:when>
      <xsl:when test="$lang = 'th'">
        <xsl:sequence select="'0x041E Thai'"/>
      </xsl:when>
      <xsl:when test="$lang = 'tr'">
        <xsl:sequence select="'0x041F Turkish'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ts'">
        <xsl:sequence select="'0x0431 Tsonga'"/>
      </xsl:when>
      <xsl:when test="$lang = 'uk'">
        <xsl:sequence select="'0x0422 Ukrainian'"/>
      </xsl:when>
      <xsl:when test="$lang = 'ur'">
        <xsl:sequence select="'0x0420 Urdu'"/>
      </xsl:when>
      <xsl:when test="$lang = 'uz'">
        <xsl:sequence select="'0x0443 Uzbek (LATIN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'uz-uz'">
        <xsl:sequence select="'0x0443 Uzbek (LATIN)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'uz-cryl-uz'">
        <xsl:sequence select="'0x0843 Uzbek (CYRILLIC)'"/>
      </xsl:when>
      <xsl:when test="$lang = 'vi'">
        <xsl:sequence select="'0x042A Vietnamese'"/>
      </xsl:when>
      <xsl:when test="$lang = 'xh'">
        <xsl:sequence select="'0x0434 Xhosa'"/>
      </xsl:when>
      <xsl:when test="$lang = 'yi'">
        <xsl:sequence select="'0x043D Yiddish'"/>
      </xsl:when>
      <xsl:when test="$lang = 'zu'">
        <xsl:sequence select="'0x0435 Zulu'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'0x0409 English (UNITED STATES)'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
