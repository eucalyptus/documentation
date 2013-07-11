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
  <xsl:import href="highlight.xsl"/>
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

  <xsl:param name="sectionQName" select="'div'"/>
  <xsl:param name="navQName" select="'div'"/>

  <!-- Keys ============================================================== -->

  <xsl:key name="footnoteXref"
           match="*[contains(@class,' topic/xref ') and (@type eq 'fn')]" 
           use="substring-after(@href, '#')"/>

  <!-- Here generate-id() is just used to key simpleBorderTable. -->
  <xsl:key name="simpleBorderTable"
           match="*[contains(@class,' topic/table ') and 
                    (empty(@frame) or @frame eq 'all') and
                    (count(./*[contains(@class,' topic/tgroup ')]) eq 1) and
                    (count(.//@rowsep[. eq '0']) eq 0) and
                    (count(.//@colsep[. eq '0']) eq 0)]" 
           use="generate-id(.)"/>

  <!-- / ================================================================= -->

  <xsl:template match="/">
    <xsl:if test="$xhtmlVersion eq '5.0'">
      <xsl:text
        disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&#xA;</xsl:text>
    </xsl:if>

    <html>
      <head>
        <xsl:choose>
          <xsl:when test="starts-with($xhtmlVersion, '-')">
            <meta http-equiv="Content-Type" 
              content="{concat('text/html; charset=', $xhtmlEncoding)}"/>
          </xsl:when>
          <xsl:when test="$xhtml-mime-type ne ''">
            <meta http-equiv="Content-Type" 
              content="{concat($xhtml-mime-type, '; charset=', $xhtmlEncoding)}"/>
          </xsl:when>
          <xsl:when test="$xhtmlVersion eq '5.0'">
            <meta charset="{$xhtmlEncoding}"/>
          </xsl:when>
        </xsl:choose>

        <xsl:call-template name="pageTitle"/>
        <xsl:call-template name="cssMeta"/>
        <xsl:call-template name="keywordsMeta"/>
        <xsl:call-template name="otherMeta"/>
      </head>
      <body>
        <xsl:variable name="chunkCount" select="u:chunkCount()"/>
        <xsl:if test="$chunkCount gt 1 and 
                      ($chain-pages eq 'top' or $chain-pages eq 'both')">
          <xsl:call-template name="chainPages">
            <xsl:with-param name="isTop" select="true()"/>
          </xsl:call-template>
        </xsl:if>

        <xsl:apply-templates/>
        <xsl:call-template name="footnotes"/>

        <xsl:if test="$chunkCount gt 1 and 
                      ($chain-pages eq 'bottom' or $chain-pages eq 'both')">
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
            <xsl:when test="$chunkTitle ne ''">
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
        <xsl:when test="$css ne ''">
          <xsl:value-of select="$css"/>
        </xsl:when>
        <xsl:when test="$css-name ne ''">
          <xsl:value-of select="concat($xslResourcesDir, $css-name)"/>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$cssURI ne ''">
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

  <xsl:template name="otherMeta">
    <xsl:call-template name="otherMetaImpl"/>
  </xsl:template>

  <xsl:template name="otherMetaImpl">
    <xsl:if test="$generator-info ne ''">
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
        <table class="fn-layout">
          <tr>
            <td>
              <xsl:call-template name="tableLayoutAttributes">
                <xsl:with-param name="valign" select="'baseline'"/>
              </xsl:call-template>

              <xsl:text>&#xA0;</xsl:text>
              <xsl:call-template name="footnoteCallout">
                <xsl:with-param name="footnote" select="."/>
              </xsl:call-template>
            </td>
            <td>
              <xsl:call-template name="tableLayoutAttributes">
                <xsl:with-param name="valign" select="'baseline'"/>
              </xsl:call-template>

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
      <xsl:element name="{if ($xhtmlVersion ne '5.0') 
                          then 'div'
                          else if ($isTop) then 'header' else 'footer'}">
        <xsl:attribute name="class" select="'page-navigation-bar'"/>

        <xsl:if test="not($isTop)">
        	
        	<div id="disqus_thread"></div>
        	<script type="text/javascript">
        		<xsl:text>
        		/* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
        		var disqus_shortname = 'eucatest'; // required: replace example with your forum shortname
        		
        		/* * * DON'T EDIT BELOW THIS LINE * * */
        		(function() {
        		var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
        		dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
        		(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        		})();
        		</xsl:text>
        	</script>
        	<noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
        	<a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
        	
          <hr class="page-navigation-bottom-separator"/>
        </xsl:if>

        <table class="page-navigation-layout">
          <xsl:call-template name="tableLayoutAttributes">
            <xsl:with-param name="width" select="'100%'"/>
          </xsl:call-template>

          <tr>
            <td>
              <xsl:call-template name="tableLayoutAttributes">
                <xsl:with-param name="valign" select="'top'"/>
                <xsl:with-param name="align" select="'left'"/>
              </xsl:call-template>

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

                <td>
                  <xsl:call-template name="tableLayoutAttributes">
                    <xsl:with-param name="valign" select="'top'"/>
                    <xsl:with-param name="align" select="'left'"/>
                  </xsl:call-template>

                  <xsl:call-template name="navigationIcon">
                    <xsl:with-param name="name" select="'previous'"/>
                    <xsl:with-param name="type" select="'previousPage'"/>
                    <xsl:with-param name="href" select="$prevChunk/@file"/>
                    <xsl:with-param name="target" select="$prevChunkTitle"/>
                    <!-- P like Previous -->
                    <xsl:with-param name="accessKey" select="'P'"/>
                  </xsl:call-template>
                </td>

                <td>
                  <xsl:call-template name="tableLayoutAttributes">
                    <xsl:with-param name="valign" select="'top'"/>
                    <xsl:with-param name="align" select="'left'"/>
                    <xsl:with-param name="width" select="'25%'"/>
                  </xsl:call-template>

                  <span class="page-navigation-previous">
                    <xsl:value-of select="$prevChunkTitle"/>
                  </span>
                </td>
              </xsl:when>
              <xsl:otherwise>
                <td>
                  <xsl:call-template name="tableLayoutAttributes">
                    <xsl:with-param name="valign" select="'top'"/>
                    <xsl:with-param name="align" select="'left'"/>
                  </xsl:call-template>

                  <xsl:call-template name="navigationIcon">
                    <xsl:with-param name="name" select="'previous'"/>
                    <xsl:with-param name="type" select="'previousPage'"/>
                  </xsl:call-template>
                </td>

                <td>
                  <xsl:call-template name="tableLayoutAttributes">
                    <xsl:with-param name="valign" select="'top'"/>
                    <xsl:with-param name="align" select="'left'"/>
                    <xsl:with-param name="width" select="'25%'"/>
                  </xsl:call-template>

                  <xsl:text>&#xA0;</xsl:text>
                </td>
              </xsl:otherwise>
            </xsl:choose>

            <td>
              <xsl:call-template name="tableLayoutAttributes">
                <xsl:with-param name="valign" select="'top'"/>
                <xsl:with-param name="align" select="'center'"/>
                <xsl:with-param name="width" select="'40%'"/>
              </xsl:call-template>

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

                <td>
                  <xsl:call-template name="tableLayoutAttributes">
                    <xsl:with-param name="valign" select="'top'"/>
                    <xsl:with-param name="align" select="'right'"/>
                    <xsl:with-param name="width" select="'25%'"/>
                  </xsl:call-template>

                  <span class="page-navigation-next">
                    <xsl:value-of select="$nextChunkTitle"/>
                  </span>
                </td>

                <td>
                  <xsl:call-template name="tableLayoutAttributes">
                    <xsl:with-param name="valign" select="'top'"/>
                    <xsl:with-param name="align" select="'right'"/>
                  </xsl:call-template>

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
                <td>
                  <xsl:call-template name="tableLayoutAttributes">
                    <xsl:with-param name="valign" select="'top'"/>
                    <xsl:with-param name="align" select="'right'"/>
                    <xsl:with-param name="width" select="'25%'"/>
                  </xsl:call-template>

                  <xsl:text>&#xA0;</xsl:text>
                </td>

                <td>
                  <xsl:call-template name="tableLayoutAttributes">
                    <xsl:with-param name="valign" select="'top'"/>
                    <xsl:with-param name="align" select="'right'"/>
                  </xsl:call-template>

                  <xsl:call-template name="navigationIcon">
                    <xsl:with-param name="name" select="'next'"/>
                    <xsl:with-param name="type" select="'nextPage'"/>
                  </xsl:call-template>
                </td>
              </xsl:otherwise>
            </xsl:choose>

            <td>
              <xsl:call-template name="tableLayoutAttributes">
                <xsl:with-param name="valign" select="'top'"/>
                <xsl:with-param name="align" select="'right'"/>
              </xsl:call-template>

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
      </xsl:element>
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
      <xsl:when test="$href ne ''">
        <a href="{$href}" class="navigation-link">
          <xsl:attribute name="title" 
            select="concat($label, $colonSeparator, $target)" />

          <xsl:if test="$accessKey ne ''">
            <xsl:attribute name="accesskey" select="$accessKey" />
          </xsl:if>

          <img class="navigation-icon">
            <xsl:attribute name="src"
                           select="concat($xslResourcesDir, $name,
                                          $navigation-icon-suffix)"/>
            <xsl:attribute name="alt" select="$label"/>
            <xsl:if test="$navigation-icon-width ne ''">
              <xsl:attribute name="width" select="$navigation-icon-width"/>
            </xsl:if>
            <xsl:if test="$navigation-icon-height ne ''">
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
          <xsl:if test="$navigation-icon-width ne ''">
            <xsl:attribute name="width" select="$navigation-icon-width"/>
          </xsl:if>
          <xsl:if test="$navigation-icon-height ne ''">
            <xsl:attribute name="height" select="$navigation-icon-height"/>
          </xsl:if>
        </img>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
