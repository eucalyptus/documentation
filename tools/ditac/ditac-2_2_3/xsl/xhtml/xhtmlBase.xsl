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
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs u ditac"
                version="2.0">

  <!-- Import (do not include) files in that order: 
       first generic elements (e.g. body.xsl) then specialized elements 
       (e.g. typographic.xsl). -->

  <xsl:import href="../common/ditacUtil.xsl"/>
  <xsl:import href="../common/commonParams.xsl"/>
  <xsl:import href="xhtmlParams.xsl"/>
  <xsl:import href="../common/commonUtil.xsl"/>
  <xsl:import href="xhtmlUtil.xsl"/>

  <xsl:import href="topic.xsl"/>
  <xsl:import href="body.xsl"/>
  <xsl:import href="simpleTable.xsl"/>
  <xsl:import href="table.xsl"/>
  <xsl:import href="prolog.xsl"/>
  <xsl:import href="relatedLinks.xsl"/>
  <xsl:import href="miscellaneous.xsl"/>
  <xsl:import href="specialization.xsl"/>

  <!-- No specific rules for concept elements. 
       Examples: conbody LIKE body, conbodydiv LIKE bodydiv, etc. -->
  <xsl:import href="reference.xsl"/>
  <xsl:import href="task.xsl"/>
  <xsl:import href="glossary.xsl"/>

  <xsl:import href="typographic.xsl"/>
  <xsl:import href="programming.xsl"/>
  <xsl:import href="software.xsl"/>
  <xsl:import href="userInterface.xsl"/>
  <xsl:import href="utilities.xsl"/>
  <xsl:import href="hazardStatement.xsl"/>

  <xsl:import href="ditac_titlePage.xsl"/>
  <xsl:import href="ditac_toc.xsl"/>
  <xsl:import href="ditac_figureList.xsl"/>
  <xsl:import href="ditac_indexList.xsl"/>
  <xsl:import href="ditac_chunk.xsl"/>
  <xsl:import href="ditac_anchor.xsl"/>
  <xsl:import href="ditac_flags.xsl"/>

  <!-- Output ============================================================ -->

  <!-- With method="html" and include-content-type="yes", the http-equiv
       should be automatically added as the first child of the {}head
       element. Unfortunately, in the case of the html.xsl stylesheet we
       always have a {http://www.w3.org/1999/xhtml}head element. 

       With method="xhtml" and include-content-type="yes", the http-equiv
       contains "text/html" rather than "application/xhtml+xml".
       This is not an error as XHTML 1.0 may be served as HTML or XML.
       However is some cases (e.g. rendering of MathML equations 
       by Web browsers such as Firefox and Opera), you'll want 
       the XHTML to be served as XML. -->
  <xsl:output include-content-type="no"/>

  <!-- Keys ============================================================== -->

  <xsl:key name="footnoteXref"
           match="*[contains(@class,' topic/xref ') and (@type = 'fn')]" 
           use="substring-after(@href, '#')"/>

  <!-- Here generate-id() is just used to key simpleBorderTable. -->
  <xsl:key name="simpleBorderTable"
           match="*[contains(@class,' topic/table ') and 
                    (empty(@frame) or @frame = 'all') and
                    (count(./*[contains(@class,' topic/tgroup ')]) eq 1) and
                    (count(.//@rowsep[. = '0']) eq 0) and
                    (count(.//@colsep[. = '0']) eq 0)]" 
           use="generate-id(.)"/>

  <!-- / ================================================================= -->

  <xsl:template match="/">
    <html>
      <head>
        <xsl:choose>
          <xsl:when test="starts-with($xhtmlVersion, '-')">
            <meta http-equiv="Content-Type" 
              content="{concat('text/html; charset=', $xhtmlEncoding)}"/>
          </xsl:when>
          <xsl:when test="$xhtml-mime-type != ''">
            <meta http-equiv="Content-Type" 
              content="{concat($xhtml-mime-type, '; charset=', $xhtmlEncoding)}"/>
          </xsl:when>
        </xsl:choose>

        <xsl:call-template name="pageTitle"/>
        <xsl:call-template name="cssMeta"/>
        <xsl:call-template name="keywordsMeta"/>
        <xsl:call-template name="generatorMeta"/>
      </head>
      <body>
        <xsl:variable name="chunkCount" select="u:chunkCount()"/>
        <xsl:if test="$chunkCount gt 1 and 
                      ($chain-pages = 'top' or $chain-pages = 'both')">
          <xsl:call-template name="chainPages">
            <xsl:with-param name="isTop" select="true()"/>
          </xsl:call-template>
        </xsl:if>

        <xsl:apply-templates/>
        <xsl:call-template name="footnotes"/>

        <xsl:if test="$chunkCount gt 1 and 
                      ($chain-pages = 'bottom' or $chain-pages = 'both')">
          <xsl:call-template name="chainPages">
            <xsl:with-param name="isTop" select="false()"/>
          </xsl:call-template>
        </xsl:if>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="pageTitle">
    <title>
      <xsl:variable name="firstTopic"
                    select="(/*/*[contains(@class,' topic/topic ')])[1]" />

      <xsl:variable name="searchTitle"
        select="if (exists($firstTopic)) 
                then $firstTopic/*/*[contains(@class,' topic/searchtitle ')]
                else ()" />

      <xsl:choose>
        <xsl:when test="exists($searchTitle)">
          <xsl:value-of select="$searchTitle"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="chunkTitle"
                        select="u:longChunkTitle(u:currentChunk(base-uri()))"/>
          <xsl:choose>
            <xsl:when test="$chunkTitle != ''">
              <xsl:value-of select="$chunkTitle"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="u:documentTitle()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </title>
  </xsl:template>

  <xsl:template name="cssMeta">
    <xsl:variable name="cssURI">
      <xsl:choose>
        <xsl:when test="$css != ''">
          <xsl:value-of select="$css"/>
        </xsl:when>
        <xsl:when test="$css-name != ''">
          <xsl:value-of select="concat($xslResourcesDir, $css-name)"/>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$cssURI != ''">
      <link rel="stylesheet" type="text/css" href="{$cssURI}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="keywordsMeta">
    <xsl:variable name="keywords1"
      select="$ditacLists/ditac:titlePage//*[contains(@class,' topic/keywords ')]/*[contains(@class,' topic/keyword ')]"/>

    <xsl:variable name="keywords2"
      select="//*[contains(@class,' topic/keywords ')]/*[contains(@class,' topic/keyword ')]"/>

    <xsl:if test="exists($keywords1) or exists($keywords2)">
      <meta name="keywords"
        content="{string-join(distinct-values(($keywords1,$keywords2)),',')}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="generatorMeta">
    <xsl:if test="$generator-info != ''">
      <meta name="generator" content="{$generator-info}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="footnotes">
    <xsl:variable name="list"
      select="//*[contains(@class,' topic/fn ') and 
                  not(contains(@class,' pr-d/synnote ')) and 
                  (not(@id) or exists(key('footnoteXref', @id)))]"/>

    <xsl:if test="exists($list)">
      <hr class="footnote-separator"/>

      <xsl:for-each select="$list">
        <table border="0" cellspacing="0" cellpadding="0" class="fn-layout">
          <tr>
            <td valign="baseline">
              <xsl:text>&#xA0;</xsl:text>
              <xsl:call-template name="footnoteCallout">
                <xsl:with-param name="footnote" select="."/>
              </xsl:call-template>
            </td>
            <td valign="baseline">
              <xsl:call-template name="commonAttributes2"/>
              <xsl:call-template name="namedAnchor2"/>
              <xsl:apply-templates/>
            </td>
          </tr>
        </table>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <!-- ===================================================================
       Page navigation
       =================================================================== -->

  <xsl:template name="chainPages">
    <xsl:param name="isTop" select="false()"/>

    <xsl:variable name="chunkIndex" select="u:chunkIndex(base-uri())"/>
    <xsl:variable name="chunkCount" select="u:chunkCount()"/>

    <xsl:if test="$chunkCount gt 0">
      <div class="page-navigation-bar">
        <xsl:if test="not($isTop)">
          <hr class="page-navigation-bottom-separator"/>
        </xsl:if>

        <table border="0" cellspacing="0" width="100%"
               class="page-navigation-layout">
          <tr valign="top">
            <td align="left">
              <xsl:choose>
                <xsl:when test="$chunkIndex gt 1">
                  <xsl:variable name="firstChunk" select="u:chunk(1)"/>

                  <xsl:call-template name="navigationIcon">
                    <xsl:with-param name="name" select="'first'"/>
                    <xsl:with-param name="type" select="'firstPage'"/>
                    <xsl:with-param name="href" select="$firstChunk/@file"/>
                    <xsl:with-param name="target" 
                                    select="u:longChunkTitle($firstChunk)"/>
                    <!-- S like Start -->
                    <xsl:with-param name="accessKey" select="'S'"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="navigationIcon">
                    <xsl:with-param name="name" select="'first'"/>
                    <xsl:with-param name="type" select="'firstPage'"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </td>

            <xsl:choose>
              <xsl:when test="$chunkIndex gt 1">
                <xsl:variable name="prevChunk" 
                              select="u:chunk($chunkIndex - 1)"/>
                <xsl:variable name="prevChunkTitle" 
                              select="u:longChunkTitle($prevChunk)"/>

                <td align="left">
                  <xsl:call-template name="navigationIcon">
                    <xsl:with-param name="name" select="'previous'"/>
                    <xsl:with-param name="type" select="'previousPage'"/>
                    <xsl:with-param name="href" select="$prevChunk/@file"/>
                    <xsl:with-param name="target" select="$prevChunkTitle"/>
                    <!-- P like Previous -->
                    <xsl:with-param name="accessKey" select="'P'"/>
                  </xsl:call-template>
                </td>

                <td width="25%" align="left">
                  <span class="page-navigation-previous">
                    <xsl:value-of select="$prevChunkTitle"/>
                  </span>
                </td>
              </xsl:when>
              <xsl:otherwise>
                <td align="left">
                  <xsl:call-template name="navigationIcon">
                    <xsl:with-param name="name" select="'previous'"/>
                    <xsl:with-param name="type" select="'previousPage'"/>
                  </xsl:call-template>
                </td>

                <td width="25%" align="left">
                  <xsl:text>&#xA0;</xsl:text>
                </td>
              </xsl:otherwise>
            </xsl:choose>

            <td width="40%" align="center">
              <xsl:variable name="currentChunk" select="u:chunk($chunkIndex)"/>

              <span class="page-navigation-current">
                <xsl:value-of select="u:longChunkTitle($currentChunk)"/>
              </span>
              <xsl:text> </xsl:text>
              <span class="page-navigation-page">
                <xsl:text>(</xsl:text>
                <xsl:value-of select="$chunkIndex"/>
                <xsl:text>&#xA0;/&#xA0;</xsl:text>
                <xsl:value-of select="$chunkCount"/>
                <xsl:text>)</xsl:text>
              </span>
            </td>

            <xsl:choose>
              <xsl:when test="$chunkIndex lt $chunkCount">
                <xsl:variable name="nextChunk"
                              select="u:chunk($chunkIndex + 1)"/>
                <xsl:variable name="nextChunkTitle"
                              select="u:longChunkTitle($nextChunk)"/>

                <td width="25%" align="right">
                  <span class="page-navigation-next">
                    <xsl:value-of select="$nextChunkTitle"/>
                  </span>
                </td>

                <td align="right">
                  <xsl:call-template name="navigationIcon">
                    <xsl:with-param name="name" select="'next'"/>
                    <xsl:with-param name="type" select="'nextPage'"/>
                    <xsl:with-param name="href" select="$nextChunk/@file"/>
                    <xsl:with-param name="target" select="$nextChunkTitle"/>
                    <!-- N like Next -->
                    <xsl:with-param name="accessKey" select="'N'"/>
                  </xsl:call-template>
                </td>
              </xsl:when>
              <xsl:otherwise>
                <td width="25%" align="right">
                  <xsl:text>&#xA0;</xsl:text>
                </td>

                <td align="right">
                  <xsl:call-template name="navigationIcon">
                    <xsl:with-param name="name" select="'next'"/>
                    <xsl:with-param name="type" select="'nextPage'"/>
                  </xsl:call-template>
                </td>
              </xsl:otherwise>
            </xsl:choose>

            <td align="right">
              <xsl:choose>
                <xsl:when test="$chunkIndex lt $chunkCount">
                  <xsl:variable name="lastChunk"
                                select="u:chunk($chunkCount)"/>

                  <xsl:call-template name="navigationIcon">
                    <xsl:with-param name="name" select="'last'"/>
                    <xsl:with-param name="type" select="'lastPage'"/>
                    <xsl:with-param name="href" select="$lastChunk/@file"/>
                    <xsl:with-param name="target" 
                                    select="u:longChunkTitle($lastChunk)"/>
                    <!-- E like End -->
                    <xsl:with-param name="accessKey" select="'E'"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="navigationIcon">
                    <xsl:with-param name="name" select="'last'"/>
                    <xsl:with-param name="type" select="'lastPage'"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
        </table>

        <xsl:if test="$isTop">
          <hr class="page-navigation-top-separator"/>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="navigationIcon">
    <xsl:param name="name" select="'first'"/>
    <xsl:param name="type" select="'firstPage'"/>
    <xsl:param name="href" select="''"/>
    <xsl:param name="target" select="''"/>
    <xsl:param name="accessKey" select="''"/>

    <xsl:variable name="label">
      <xsl:call-template name="localize">
        <xsl:with-param name="message" select="$type"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="colonSeparator">
      <xsl:call-template name="localize">
        <xsl:with-param name="message" select="'colonSeparator'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$href != ''">
        <a href="{$href}" class="navigation-link">
          <xsl:attribute name="title" 
            select="concat($label, $colonSeparator, $target)" />

          <xsl:if test="$accessKey != ''">
            <xsl:attribute name="accesskey" select="$accessKey" />
          </xsl:if>

          <img class="navigation-icon">
            <xsl:attribute name="src"
                           select="concat($xslResourcesDir, $name,
                                          $navigation-icon-suffix)"/>
            <xsl:attribute name="alt" select="$label"/>
            <xsl:if test="$navigation-icon-width != ''">
              <xsl:attribute name="width" select="$navigation-icon-width"/>
            </xsl:if>
            <xsl:if test="$navigation-icon-height != ''">
              <xsl:attribute name="height" select="$navigation-icon-height"/>
            </xsl:if>
          </img>
        </a>
      </xsl:when>

      <xsl:otherwise>
        <img class="navigation-icon-disabled">
          <xsl:attribute name="src"
                         select="concat($xslResourcesDir, $name, '_disabled',
                                        $navigation-icon-suffix)"/>
          <xsl:attribute name="alt" select="$label"/>
          <xsl:attribute name="title" select="$label"/>
          <xsl:if test="$navigation-icon-width != ''">
            <xsl:attribute name="width" select="$navigation-icon-width"/>
          </xsl:if>
          <xsl:if test="$navigation-icon-height != ''">
            <xsl:attribute name="height" select="$navigation-icon-height"/>
          </xsl:if>
        </img>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
