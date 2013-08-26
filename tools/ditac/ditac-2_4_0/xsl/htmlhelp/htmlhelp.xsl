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
                xmlns:URI="java:com.xmlmind.ditac.xslt.URI"
                exclude-result-prefixes="xs u ditac URI"
                version="2.0">

  <xsl:import href="../xhtml/xhtmlBase.xsl"/>
  <xsl:import href="htmlhelpParams.xsl"/>

  <!-- Output ============================================================ -->

  <xsl:param name="xhtmlVersion" select="'-4.01'"/>

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
              <xsl:when test="$add-toc-root eq 'yes'">
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
    <xsl:if test="not((@role eq 'toc' or 
                       @role eq 'figurelist' or 
                       @role eq 'tablelist' or 
                       @role eq 'examplelist' or 
                       @role eq 'indexlist') and starts-with(@id, '__AUTO__'))">
      <xsl:variable name="id" select="u:tocEntryAutoId(.)"/>
      <xsl:variable name="title" select="u:tocEntryAutoTitle(.)"/>

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

    <LI><OBJECT type="text/sitemap"><xsl:text>&#xA;</xsl:text>
      <param name="Name"
      value="{concat($titlePrefix, u:tocEntryAutoTitle(.))}"></param><xsl:text>&#xA;</xsl:text>
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
      <xsl:when test="$lang eq 'af'">
        <xsl:sequence select="'0x0436 Afrikaans'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'sq'">
        <xsl:sequence select="'0x041C Albanian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar'">
        <xsl:sequence select="'0x0C01 Arabic (EGYPT)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-eg'">
        <xsl:sequence select="'0x0C01 Arabic (EGYPT)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-ae'">
        <xsl:sequence select="'0x3801 Arabic (UNITED ARAB EMIRATES)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-bh'">
        <xsl:sequence select="'0x3C01 Arabic (BAHRAIN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-dz'">
        <xsl:sequence select="'0x1401 Arabic (ALGERIA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-iq'">
        <xsl:sequence select="'0x0801 Arabic (IRAQ)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-jo'">
        <xsl:sequence select="'0x2C01 Arabic (JORDAN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-kw'">
        <xsl:sequence select="'0x3401 Arabic (KUWAIT)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-lb'">
        <xsl:sequence select="'0x3001 Arabic (LEBANON)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-ly'">
        <xsl:sequence select="'0x1001 Arabic (LIBYA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-ma'">
        <xsl:sequence select="'0x1801 Arabic (MOROCCO)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-om'">
        <xsl:sequence select="'0x2001 Arabic (OMAN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-qa'">
        <xsl:sequence select="'0x4001 Arabic (QATAR)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-sa'">
        <xsl:sequence select="'0x0401 Arabic (SAUDI ARABIA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-sy'">
        <xsl:sequence select="'0x2801 Arabic (SYRIA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-tn'">
        <xsl:sequence select="'0x1C01 Arabic (TUNISIA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ar-ye'">
        <xsl:sequence select="'0x2401 Arabic (YEMEN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'hy'">
        <xsl:sequence select="'0x042B Armenian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'az'">
        <xsl:sequence select="'0x042C Azeri (LATIN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'az-az'">
        <xsl:sequence select="'0x042C Azeri (LATIN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'az-cryl-az'">
        <xsl:sequence select="'0x082C Azeri (CYRILLIC)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'eu'">
        <xsl:sequence select="'0x042D Basque'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'be'">
        <xsl:sequence select="'0x0423 Belarusian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'bg'">
        <xsl:sequence select="'0x0402 Bulgarian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ca'">
        <xsl:sequence select="'0x0403 Catalan'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'zh'">
        <xsl:sequence select="'0x0804 Chinese (CHINA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'zh-cn'">
        <xsl:sequence select="'0x0804 Chinese (CHINA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'zh-hk'">
        <xsl:sequence select="'0x0C04 Chinese (HONG KONG SAR)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'zh-mo'">
        <xsl:sequence select="'0x1404 Chinese (MACAU SAR)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'zh-sg'">
        <xsl:sequence select="'0x1004 Chinese (SINGAPORE)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'zh-tw'">
        <xsl:sequence select="'0x0404 Chinese (TAIWAN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'hr'">
        <xsl:sequence select="'0x041A Croatian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'cs'">
        <xsl:sequence select="'0x0405 Czech'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'da'">
        <xsl:sequence select="'0x0406 Danish'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'nl'">
        <xsl:sequence select="'0x0413 Dutch (NETHERLANDS)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'nl-nl'">
        <xsl:sequence select="'0x0413 Dutch (NETHERLANDS)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'nl-be'">
        <xsl:sequence select="'0x0813 Dutch (BELGIUM)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'en'">
        <xsl:sequence select="'0x0409 English (UNITED STATES)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'en-us'">
        <xsl:sequence select="'0x0409 English (UNITED STATES)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'en-au'">
        <xsl:sequence select="'0x0C09 English (AUSTRALIA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'en-bz'">
        <xsl:sequence select="'0x2809 English (BELIZE)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'en-ca'">
        <xsl:sequence select="'0x1009 English (CANADA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'en-cb'">
        <xsl:sequence select="'0x2409 English (CARIBBEAN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'en-ie'">
        <xsl:sequence select="'0x1809 English (IRELAND)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'en-jm'">
        <xsl:sequence select="'0x2009 English (JAMAICA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'en-nz'">
        <xsl:sequence select="'0x1409 English (NEW ZEALAND)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'en-ph'">
        <xsl:sequence select="'0x3409 English (PHILLIPPINES)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'en-za'">
        <xsl:sequence select="'0x1C09 English (SOUTHERN AFRICA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'en-tt'">
        <xsl:sequence select="'0x2C09 English (TRINIDAD)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'en-gb'">
        <xsl:sequence select="'0x0809 English (GREAT BRITAIN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'et'">
        <xsl:sequence select="'0x0425 Estonian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'fa'">
        <xsl:sequence select="'0x0429 Farsi'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'fi'">
        <xsl:sequence select="'0x040B Finnish'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'fo'">
        <xsl:sequence select="'0x0438 Faroese'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'fr'">
        <xsl:sequence select="'0x040C French (FRANCE)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'fr-fr'">
        <xsl:sequence select="'0x040C French (FRANCE)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'fr-be'">
        <xsl:sequence select="'0x080C French (BELGIUM)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'fr-ca'">
        <xsl:sequence select="'0x0C0C French (CANADA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'fr-lu'">
        <xsl:sequence select="'0x140C French (LUXEMBOURG)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'fr-ch'">
        <xsl:sequence select="'0x100C French (SWITZERLAND)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'gd'">
        <xsl:sequence select="'0x083C Gaelic (IRELAND)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'gd-ie'">
        <xsl:sequence select="'0x083C Gaelic (IRELAND)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'gd'">
        <xsl:sequence select="'0x043C Gaelic (SCOTLAND)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'de'">
        <xsl:sequence select="'0x0407 German (GERMANY)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'de-de'">
        <xsl:sequence select="'0x0407 German (GERMANY)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'de-at'">
        <xsl:sequence select="'0x0C07 German (AUSTRIA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'de-li'">
        <xsl:sequence select="'0x1407 German (LIECHTENSTEIN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'de-lu'">
        <xsl:sequence select="'0x1007 German (LUXEMBOURG)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'de-ch'">
        <xsl:sequence select="'0x0807 German (SWITZERLAND)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'el'">
        <xsl:sequence select="'0x0408 Greek'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'he'">
        <xsl:sequence select="'0x040D Hebrew'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'hi'">
        <xsl:sequence select="'0x0439 Hindi'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'hu'">
        <xsl:sequence select="'0x040E Hungarian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'is'">
        <xsl:sequence select="'0x040F Icelandic'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'id'">
        <xsl:sequence select="'0x0421 Indonesian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'it'">
        <xsl:sequence select="'0x0410 Italian (ITALY)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'it-it'">
        <xsl:sequence select="'0x0410 Italian (ITALY)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'it-ch'">
        <xsl:sequence select="'0x0810 Italian (SWITZERLAND)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ja'">
        <xsl:sequence select="'0x0411 Japanese'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ko'">
        <xsl:sequence select="'0x0412 Korean'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'lv'">
        <xsl:sequence select="'0x0426 Latvian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'lt'">
        <xsl:sequence select="'0x0427 Lithuanian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'mk'">
        <xsl:sequence select="'0x042F F.Y.R.O. Macedonia'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ms'">
        <xsl:sequence select="'0x043E Malay (MALAYSIA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ms-my'">
        <xsl:sequence select="'0x043E Malay (MALAYSIA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ms-bn'">
        <xsl:sequence select="'0x083E Malay (BRUNEI)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'mt'">
        <xsl:sequence select="'0x043A Maltese'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'mr'">
        <xsl:sequence select="'0x044E Marathi'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'no'">
        <xsl:sequence select="'0x0414 Norwegian (BOKML)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'no-no'">
        <xsl:sequence select="'0x0414 Norwegian (BOKML)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'no-no'">
        <xsl:sequence select="'0x0814 Norwegian (NYNORSK)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'pl'">
        <xsl:sequence select="'0x0415 Polish'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'pt'">
        <xsl:sequence select="'0x0816 Portuguese (PORTUGAL)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'pt-pt'">
        <xsl:sequence select="'0x0816 Portuguese (PORTUGAL)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'pt-br'">
        <xsl:sequence select="'0x0416 Portuguese (BRAZIL)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'rm'">
        <xsl:sequence select="'0x0417 Raeto-Romance'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ro'">
        <xsl:sequence select="'0x0418 Romanian (ROMANIA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ro-mo'">
        <xsl:sequence select="'0x0818 Romanian (REPUBLIC OF MOLDOVA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ru'">
        <xsl:sequence select="'0x0419 Russian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ru-mo'">
        <xsl:sequence select="'0x0819 Russian (REPUBLIC OF MOLDOVA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'sa'">
        <xsl:sequence select="'0x044F Sanskrit'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'sr'">
        <xsl:sequence select="'0x0C1A Serbian (CYRILLIC)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'sr-sp'">
        <xsl:sequence select="'0x0C1A Serbian (CYRILLIC)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'sr-latn-sp'">
        <xsl:sequence select="'0x081A Serbian (LATIN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'tn'">
        <xsl:sequence select="'0x0432 Setsuana'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'sl'">
        <xsl:sequence select="'0x0424 Slovenian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'sk'">
        <xsl:sequence select="'0x041B Slovak'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'sb'">
        <xsl:sequence select="'0x042E Sorbian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es'">
        <xsl:sequence select="'0x040A Spanish (SPAIN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-es'">
        <xsl:sequence select="'0x040A Spanish (SPAIN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-ar'">
        <xsl:sequence select="'0x2C0A Spanish (ARGENTINA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-bo'">
        <xsl:sequence select="'0x400A Spanish (BOLIVIA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-cl'">
        <xsl:sequence select="'0x340A Spanish (CHILE)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-co'">
        <xsl:sequence select="'0x240A Spanish (COLOMBIA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-cr'">
        <xsl:sequence select="'0x140A Spanish (COSTA RICA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-do'">
        <xsl:sequence select="'0x1C0A Spanish (DOMINICAN REPUBLIC)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-ec'">
        <xsl:sequence select="'0x300A Spanish (ECUADOR)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-gt'">
        <xsl:sequence select="'0x100A Spanish (GUATEMALA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-hn'">
        <xsl:sequence select="'0x480A Spanish (HONDURAS)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-mx'">
        <xsl:sequence select="'0x080A Spanish (MEXICO)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-ni'">
        <xsl:sequence select="'0x4C0A Spanish (NICARAGUA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-pa'">
        <xsl:sequence select="'0x180A Spanish (PANAMA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-pe'">
        <xsl:sequence select="'0x280A Spanish (PERU)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-pr'">
        <xsl:sequence select="'0x500A Spanish (PUERTO RICO)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-py'">
        <xsl:sequence select="'0x3C0A Spanish (PARAGUAY)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-sv'">
        <xsl:sequence select="'0x440A Spanish (EL SALVADOR)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-uy'">
        <xsl:sequence select="'0x380A Spanish (URUGUAY)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'es-ve'">
        <xsl:sequence select="'0x200A Spanish (VENEZUELA)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'st'">
        <xsl:sequence select="'0x0430 Southern Sotho'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'sw'">
        <xsl:sequence select="'0x0441 Swahili'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'sv'">
        <xsl:sequence select="'0x041D Swedish (SWEDEN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'sv-se'">
        <xsl:sequence select="'0x041D Swedish (SWEDEN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'sv-fi'">
        <xsl:sequence select="'0x081D Swedish (FINLAND)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ta'">
        <xsl:sequence select="'0x0449 Tamil'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'tt'">
        <xsl:sequence select="'0X0444 Tatar'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'th'">
        <xsl:sequence select="'0x041E Thai'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'tr'">
        <xsl:sequence select="'0x041F Turkish'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ts'">
        <xsl:sequence select="'0x0431 Tsonga'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'uk'">
        <xsl:sequence select="'0x0422 Ukrainian'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'ur'">
        <xsl:sequence select="'0x0420 Urdu'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'uz'">
        <xsl:sequence select="'0x0443 Uzbek (LATIN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'uz-uz'">
        <xsl:sequence select="'0x0443 Uzbek (LATIN)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'uz-cryl-uz'">
        <xsl:sequence select="'0x0843 Uzbek (CYRILLIC)'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'vi'">
        <xsl:sequence select="'0x042A Vietnamese'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'xh'">
        <xsl:sequence select="'0x0434 Xhosa'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'yi'">
        <xsl:sequence select="'0x043D Yiddish'"/>
      </xsl:when>
      <xsl:when test="$lang eq 'zu'">
        <xsl:sequence select="'0x0435 Zulu'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'0x0409 English (UNITED STATES)'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
