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
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                xmlns:URI="java:com.xmlmind.ditac.xslt.URI"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                exclude-result-prefixes="xs u ditac URI"
                version="2.0">

  <xsl:attribute-set name="first-title-page">
    <xsl:attribute name="border-width">0.5pt</xsl:attribute>
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="border-color">#404040</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template name="layoutMasterSet">
    <fo:layout-master-set>
      <!-- simple-page-masters =========================================== -->

      <!-- blank-page ========== -->

      <fo:simple-page-master master-name="blank-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-outer-margin}"
                             margin-right="{$page-inner-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"/>
        <fo:region-after extent="{$footer-height}"/>
      </fo:simple-page-master>

      <!-- title-page ========== -->

      <fo:simple-page-master master-name="first-title-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <xsl:choose>
          <xsl:when test="$foProcessor = 'XEP'">
            <!-- The border around the region-body is a XEP extension 
                 (Border and Padding on Regions).
                 In both XSL 1.0 and 1.1, the values of the padding and 
                 border-width traits must be "0".  -->
            <fo:region-body margin-top="{$body-top-margin}"
                            margin-bottom="{$body-bottom-margin}"
                            xsl:use-attribute-sets="first-title-page"/>
          </xsl:when>
          <xsl:otherwise>
            <fo:region-body margin-top="{$body-top-margin}"
                            margin-bottom="{$body-bottom-margin}"/>
          </xsl:otherwise>
        </xsl:choose>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="first-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="first-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="odd-title-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="odd-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="odd-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="even-title-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-outer-margin}"
                             margin-right="{$page-inner-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="even-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="even-page-footer"/>
      </fo:simple-page-master>

      <!-- toc-page ========== -->

      <fo:simple-page-master master-name="first-toc-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="first-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="first-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="odd-toc-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="odd-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="odd-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="even-toc-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-outer-margin}"
                             margin-right="{$page-inner-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="even-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="even-page-footer"/>
      </fo:simple-page-master>

      <!-- booklist-page ========== -->

      <fo:simple-page-master master-name="first-booklist-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="first-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="first-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="odd-booklist-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="odd-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="odd-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="even-booklist-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-outer-margin}"
                             margin-right="{$page-inner-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="even-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="even-page-footer"/>
      </fo:simple-page-master>

      <!-- frontmatter-page ========== -->

      <fo:simple-page-master master-name="first-frontmatter-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="first-page-header"/>
        <fo:region-after extent="{$footer-height}"
                          display-align="after"
                          region-name="first-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="odd-frontmatter-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="odd-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="odd-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="even-frontmatter-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-outer-margin}"
                             margin-right="{$page-inner-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="even-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="even-page-footer"/>
      </fo:simple-page-master>

      <!-- body-page ========== -->

      <fo:simple-page-master master-name="first-body-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="first-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="first-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="odd-body-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="odd-page-header"/>
        <fo:region-after extent="{$footer-height}"
                          display-align="after"
                          region-name="odd-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="even-body-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-outer-margin}"
                             margin-right="{$page-inner-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="even-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="even-page-footer"/>
      </fo:simple-page-master>

      <!-- backmatter-page ========== -->

      <fo:simple-page-master master-name="first-backmatter-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="first-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="first-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="odd-backmatter-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="odd-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="odd-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="even-backmatter-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-outer-margin}"
                             margin-right="{$page-inner-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="even-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="even-page-footer"/>
      </fo:simple-page-master>

      <!-- index-page ========== -->

      <fo:simple-page-master master-name="first-index-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"
                        column-count="{$index-column-count}" 
                        column-gap="{$index-column-gap}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="first-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="first-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="odd-index-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-inner-margin}"
                             margin-right="{$page-outer-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"
                        column-count="{$index-column-count}" 
                        column-gap="{$index-column-gap}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="odd-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="odd-page-footer"/>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="even-index-page"
                             page-width="{$page-width}"
                             page-height="{$page-height}"
                             margin-top="{$page-top-margin}"
                             margin-bottom="{$page-bottom-margin}"
                             margin-left="{$page-outer-margin}"
                             margin-right="{$page-inner-margin}">
        <fo:region-body margin-top="{$body-top-margin}"
                        margin-bottom="{$body-bottom-margin}"
                        column-count="{$index-column-count}" 
                        column-gap="{$index-column-gap}"/>
        <fo:region-before extent="{$header-height}"
                          display-align="before"
                          region-name="even-page-header"/>
        <fo:region-after extent="{$footer-height}"
                         display-align="after"
                         region-name="even-page-footer"/>
      </fo:simple-page-master>

      <!-- page-sequence-masters ========================================= -->

      <!-- title ========== -->

      <fo:page-sequence-master master-name="title">
        <fo:repeatable-page-master-alternatives>
          <fo:conditional-page-master-reference 
            master-reference="blank-page"
            blank-or-not-blank="blank"/>
          <fo:conditional-page-master-reference 
            master-reference="first-title-page"
            page-position="first"/>
          <fo:conditional-page-master-reference
            master-reference="odd-title-page"
            odd-or-even="odd"/>
          <fo:conditional-page-master-reference 
            odd-or-even="even" 
            master-reference="even-title-page"/>
        </fo:repeatable-page-master-alternatives>
      </fo:page-sequence-master>

      <!-- toc ========== -->

      <fo:page-sequence-master master-name="toc">
        <fo:repeatable-page-master-alternatives>
          <fo:conditional-page-master-reference 
            master-reference="blank-page"
            blank-or-not-blank="blank"/>
          <fo:conditional-page-master-reference 
            master-reference="first-toc-page"
            page-position="first"/>
          <fo:conditional-page-master-reference
            master-reference="odd-toc-page"
            odd-or-even="odd"/>
          <fo:conditional-page-master-reference 
            odd-or-even="even" 
            master-reference="even-toc-page"/>
        </fo:repeatable-page-master-alternatives>
      </fo:page-sequence-master>

      <!-- booklist ========== -->

      <fo:page-sequence-master master-name="booklist">
        <fo:repeatable-page-master-alternatives>
          <fo:conditional-page-master-reference 
            master-reference="blank-page"
            blank-or-not-blank="blank"/>
          <fo:conditional-page-master-reference 
            master-reference="first-booklist-page"
            page-position="first"/>
          <fo:conditional-page-master-reference
            master-reference="odd-booklist-page"
            odd-or-even="odd"/>
          <fo:conditional-page-master-reference 
            odd-or-even="even" 
            master-reference="even-booklist-page"/>
        </fo:repeatable-page-master-alternatives>
      </fo:page-sequence-master>

      <!-- frontmatter ========== -->

      <fo:page-sequence-master master-name="frontmatter">
        <fo:repeatable-page-master-alternatives>
          <fo:conditional-page-master-reference 
            master-reference="blank-page"
            blank-or-not-blank="blank"/>
          <fo:conditional-page-master-reference 
            master-reference="first-frontmatter-page"
            page-position="first"/>
          <fo:conditional-page-master-reference
            master-reference="odd-frontmatter-page"
            odd-or-even="odd"/>
          <fo:conditional-page-master-reference 
            odd-or-even="even" 
            master-reference="even-frontmatter-page"/>
        </fo:repeatable-page-master-alternatives>
      </fo:page-sequence-master>

      <!-- body ========== -->

      <fo:page-sequence-master master-name="body">
        <fo:repeatable-page-master-alternatives>
          <fo:conditional-page-master-reference 
            master-reference="blank-page"
            blank-or-not-blank="blank"/>
          <fo:conditional-page-master-reference 
            master-reference="first-body-page"
            page-position="first"/>
          <fo:conditional-page-master-reference
            master-reference="odd-body-page"
            odd-or-even="odd"/>
          <fo:conditional-page-master-reference 
            odd-or-even="even" 
            master-reference="even-body-page"/>
        </fo:repeatable-page-master-alternatives>
      </fo:page-sequence-master>

      <!-- backmatter ========== -->

      <fo:page-sequence-master master-name="backmatter">
        <fo:repeatable-page-master-alternatives>
          <fo:conditional-page-master-reference 
            master-reference="blank-page"
            blank-or-not-blank="blank"/>
          <fo:conditional-page-master-reference 
            master-reference="first-backmatter-page"
            page-position="first"/>
          <fo:conditional-page-master-reference
            master-reference="odd-backmatter-page"
            odd-or-even="odd"/>
          <fo:conditional-page-master-reference 
            odd-or-even="even" 
            master-reference="even-backmatter-page"/>
        </fo:repeatable-page-master-alternatives>
      </fo:page-sequence-master>

      <!-- index ========== -->

      <fo:page-sequence-master master-name="index">
        <fo:repeatable-page-master-alternatives>
          <fo:conditional-page-master-reference 
            master-reference="blank-page"
            blank-or-not-blank="blank"/>
          <fo:conditional-page-master-reference 
            master-reference="first-index-page"
            page-position="first"/>
          <fo:conditional-page-master-reference
            master-reference="odd-index-page"
            odd-or-even="odd"/>
          <fo:conditional-page-master-reference 
            odd-or-even="even" 
            master-reference="even-index-page"/>
        </fo:repeatable-page-master-alternatives>
      </fo:page-sequence-master>
    </fo:layout-master-set>
  </xsl:template>

  <!-- configurePageSequence ============================================= -->

  <xsl:template name="configurePageSequence">
    <!-- The context node is the element (titlePage, toc, chapter, etc) which
         is the head of this page sequence. -->

    <xsl:param name="sequenceName" select="''"/>
    <xsl:param name="frontmatterNames" select="()"/>
    <xsl:param name="bodyNames" select="()"/>
    <xsl:param name="backmatterNames" select="()"/>
    <xsl:param name="topicInfo" select="element()"/>
    <xsl:param name="documentTitle" select="''"/>
    <xsl:param name="documentDate" select="''"/>

    <xsl:variable name="type" select="substring-before($sequenceName, '.')"/>

    <xsl:variable name="masterName">
      <xsl:choose>
        <xsl:when test="$type = 'titlePage'">
          <xsl:value-of select="'title'"/>
        </xsl:when>
        <xsl:when test="$type = 'toc'">
          <xsl:value-of select="'toc'"/>
        </xsl:when>
        <xsl:when test="$type = 'figureList' or 
                        $type = 'tableList' or 
                        $type = 'exampleList'">
          <xsl:value-of select="'booklist'"/>
        </xsl:when>
        <xsl:when test="$type = 'indexList'">
          <xsl:value-of select="'index'"/>
        </xsl:when>
        <xsl:when test="$type = 'part' or
                        $type = 'chapter' or
                        $type = 'appendices' or
                        $type = 'appendix' or
                        $type = 'section1' or
                        $type = 'section2' or
                        $type = 'section3' or
                        $type = 'section4' or
                        $type = 'section5' or
                        $type = 'section6' or
                        $type = 'section7' or
                        $type = 'section8' or
                        $type = 'section9'">
          <xsl:value-of select="'body'"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Frontmatter or backmatter other than toc, figureList, etc. That
               is, hand-written frontmatter or backmatter. Example:
               glossarylist. -->
          <xsl:value-of
            select="if (index-of($frontmatterNames, $sequenceName) ge 1) then 
                        'frontmatter' 
                    else 
                        'backmatter'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="configureMasterReference">
      <xsl:with-param name="sequenceName" select="$sequenceName"/>
      <xsl:with-param name="frontmatterNames" select="$frontmatterNames"/>
      <xsl:with-param name="bodyNames" select="$bodyNames"/>
      <xsl:with-param name="backmatterNames" select="$backmatterNames"/>
      <xsl:with-param name="topicInfo" select="$topicInfo"/>
      <xsl:with-param name="documentTitle" select="$documentTitle"/>
      <xsl:with-param name="documentDate" select="$documentDate"/>
      <xsl:with-param name="masterName" select="$masterName"/>
    </xsl:call-template>

    <xsl:call-template name="configureHyphenate">
      <xsl:with-param name="sequenceName" select="$sequenceName"/>
      <xsl:with-param name="frontmatterNames" select="$frontmatterNames"/>
      <xsl:with-param name="bodyNames" select="$bodyNames"/>
      <xsl:with-param name="backmatterNames" select="$backmatterNames"/>
      <xsl:with-param name="topicInfo" select="$topicInfo"/>
      <xsl:with-param name="documentTitle" select="$documentTitle"/>
      <xsl:with-param name="documentDate" select="$documentDate"/>
      <xsl:with-param name="masterName" select="$masterName"/>
    </xsl:call-template>

    <xsl:call-template name="configureInitialPageNumber">
      <xsl:with-param name="sequenceName" select="$sequenceName"/>
      <xsl:with-param name="frontmatterNames" select="$frontmatterNames"/>
      <xsl:with-param name="bodyNames" select="$bodyNames"/>
      <xsl:with-param name="backmatterNames" select="$backmatterNames"/>
      <xsl:with-param name="topicInfo" select="$topicInfo"/>
      <xsl:with-param name="documentTitle" select="$documentTitle"/>
      <xsl:with-param name="documentDate" select="$documentDate"/>
      <xsl:with-param name="masterName" select="$masterName"/>
    </xsl:call-template>

    <xsl:call-template name="configureForcePageCount">
      <xsl:with-param name="sequenceName" select="$sequenceName"/>
      <xsl:with-param name="frontmatterNames" select="$frontmatterNames"/>
      <xsl:with-param name="bodyNames" select="$bodyNames"/>
      <xsl:with-param name="backmatterNames" select="$backmatterNames"/>
      <xsl:with-param name="topicInfo" select="$topicInfo"/>
      <xsl:with-param name="documentTitle" select="$documentTitle"/>
      <xsl:with-param name="documentDate" select="$documentDate"/>
      <xsl:with-param name="masterName" select="$masterName"/>
    </xsl:call-template>

    <xsl:call-template name="configureFormat">
      <xsl:with-param name="sequenceName" select="$sequenceName"/>
      <xsl:with-param name="frontmatterNames" select="$frontmatterNames"/>
      <xsl:with-param name="bodyNames" select="$bodyNames"/>
      <xsl:with-param name="backmatterNames" select="$backmatterNames"/>
      <xsl:with-param name="topicInfo" select="$topicInfo"/>
      <xsl:with-param name="documentTitle" select="$documentTitle"/>
      <xsl:with-param name="documentDate" select="$documentDate"/>
      <xsl:with-param name="masterName" select="$masterName"/>
    </xsl:call-template>

    <xsl:call-template name="configureFootnoteSeparator">
      <xsl:with-param name="sequenceName" select="$sequenceName"/>
      <xsl:with-param name="frontmatterNames" select="$frontmatterNames"/>
      <xsl:with-param name="bodyNames" select="$bodyNames"/>
      <xsl:with-param name="backmatterNames" select="$backmatterNames"/>
      <xsl:with-param name="topicInfo" select="$topicInfo"/>
      <xsl:with-param name="documentTitle" select="$documentTitle"/>
      <xsl:with-param name="documentDate" select="$documentDate"/>
      <xsl:with-param name="masterName" select="$masterName"/>
    </xsl:call-template>

    <xsl:call-template name="configureHeadersAndFooters">
      <xsl:with-param name="sequenceName" select="$sequenceName"/>
      <xsl:with-param name="frontmatterNames" select="$frontmatterNames"/>
      <xsl:with-param name="bodyNames" select="$bodyNames"/>
      <xsl:with-param name="backmatterNames" select="$backmatterNames"/>
      <xsl:with-param name="topicInfo" select="$topicInfo"/>
      <xsl:with-param name="documentTitle" select="$documentTitle"/>
      <xsl:with-param name="documentDate" select="$documentDate"/>
      <xsl:with-param name="masterName" select="$masterName"/>
    </xsl:call-template>
  </xsl:template>

  <!-- configureMasterReference ========================================== -->

  <xsl:template name="configureMasterReference">
    <xsl:param name="sequenceName" select="''"/>
    <xsl:param name="frontmatterNames" select="()"/>
    <xsl:param name="bodyNames" select="()"/>
    <xsl:param name="backmatterNames" select="()"/>
    <xsl:param name="topicInfo" select="element()"/>
    <xsl:param name="documentTitle" select="''"/>
    <xsl:param name="documentDate" select="''"/>
    <xsl:param name="masterName" select="''"/>

    <xsl:attribute name="master-reference" select="$masterName"/>
  </xsl:template>

  <!-- configureHyphenate ================================================ -->

  <xsl:template name="configureHyphenate">
    <xsl:param name="sequenceName" select="''"/>
    <xsl:param name="frontmatterNames" select="()"/>
    <xsl:param name="bodyNames" select="()"/>
    <xsl:param name="backmatterNames" select="()"/>
    <xsl:param name="topicInfo" select="element()"/>
    <xsl:param name="documentTitle" select="''"/>
    <xsl:param name="documentDate" select="''"/>
    <xsl:param name="masterName" select="''"/>

    <!-- For hyphenation use -->
    <xsl:attribute name="language" select="u:documentLang()"/>

    <xsl:choose>
      <xsl:when test="$masterName = 'body' or 
                      $masterName = 'frontmatter' or 
                      $masterName = 'backmatter'">
        <xsl:attribute name="hyphenate" 
          select="if ($hyphenate = 'yes') then 'true' else 'false'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="hyphenate">false</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- configureInitialPageNumber ======================================== -->

  <xsl:template name="configureInitialPageNumber">
    <xsl:param name="sequenceName" select="''"/>
    <xsl:param name="frontmatterNames" select="()"/>
    <xsl:param name="bodyNames" select="()"/>
    <xsl:param name="backmatterNames" select="()"/>
    <xsl:param name="topicInfo" select="element()"/>
    <xsl:param name="documentTitle" select="''"/>
    <xsl:param name="documentDate" select="''"/>
    <xsl:param name="masterName" select="''"/>

    <xsl:attribute name="initial-page-number">
      <xsl:choose>
        <xsl:when
          test="u:startsOnPage1($sequenceName, $frontmatterNames, $bodyNames, 
                                $backmatterNames)">1</xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when 
              test="$two-sided = 'yes' and 
                    u:startsOnOddPage($sequenceName, $frontmatterNames, 
                                      $bodyNames, 
                                      $backmatterNames)">auto-odd</xsl:when>
            <xsl:otherwise>auto</xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:function name="u:startsOnPage1" as="xs:boolean">
    <xsl:param name="sequenceName" as="xs:string"/>
    <xsl:param name="frontmatterNames" as="xs:string*"/>
    <xsl:param name="bodyNames" as="xs:string*"/>
    <xsl:param name="backmatterNames" as="xs:string*"/>

    <xsl:variable name="frontmatterPos" 
                  select="index-of($frontmatterNames, $sequenceName)"/>

    <xsl:sequence 
      select="($frontmatterPos eq 1) or
              ($frontmatterPos gt 1 and 
               substring-before($frontmatterNames[$frontmatterPos - 1], 
                                '.') = 'titlePage') or
              (index-of($bodyNames, $sequenceName) eq 1) or
              (index-of($backmatterNames, $sequenceName) eq 1)"/>
  </xsl:function>

  <xsl:function name="u:startsOnOddPage" as="xs:boolean">
    <xsl:param name="sequenceName" as="xs:string"/>
    <xsl:param name="frontmatterNames" as="xs:string*"/>
    <xsl:param name="bodyNames" as="xs:string*"/>
    <xsl:param name="backmatterNames" as="xs:string*"/>

    <xsl:variable name="type" select="substring-before($sequenceName, '.')"/>

    <xsl:sequence select="$type = 'toc' or
                          $type = 'part' or
                          $type = 'chapter' or
                          $type = 'appendices' or
                          $type = 'appendix' or
                          $type = 'indexList' or
                          u:startsOnPage1($sequenceName, $frontmatterNames, 
                                          $bodyNames, $backmatterNames)"/>
  </xsl:function>

  <!-- configureForcePageCount =========================================== -->

  <xsl:template name="configureForcePageCount">
    <xsl:param name="sequenceName" select="''"/>
    <xsl:param name="frontmatterNames" select="()"/>
    <xsl:param name="bodyNames" select="()"/>
    <xsl:param name="backmatterNames" select="()"/>
    <xsl:param name="topicInfo" select="element()"/>
    <xsl:param name="documentTitle" select="''"/>
    <xsl:param name="documentDate" select="''"/>
    <xsl:param name="masterName" select="''"/>

    <xsl:variable name="nextSequenceName" 
                  select="u:nextSequenceName($sequenceName, $frontmatterNames, 
                                             $bodyNames, $backmatterNames)"/>

    <xsl:attribute name="force-page-count" 
                   select="if ($two-sided = 'yes' and
                               $nextSequenceName != '' and
                               u:startsOnOddPage($nextSequenceName,
                                                 $frontmatterNames, $bodyNames,
                                                 $backmatterNames)) then 
                               'end-on-even'
                           else
                               'no-force'"/>
  </xsl:template>

  <xsl:function name="u:nextSequenceName" as="xs:string">
    <xsl:param name="sequenceName" as="xs:string"/>
    <xsl:param name="frontmatterNames" as="xs:string*"/>
    <xsl:param name="bodyNames" as="xs:string*"/>
    <xsl:param name="backmatterNames" as="xs:string*"/>

    <xsl:variable name="list" 
                  select="$frontmatterNames, $bodyNames, $backmatterNames"/>
    <xsl:variable name="pos" select="index-of($list, $sequenceName)"/>
    <xsl:sequence 
      select="if ($pos ge 1 and $pos lt count($list)) then
                  $list[$pos + 1]
              else
                  ''"/>
  </xsl:function>

  <!-- configureFormat =================================================== -->

  <xsl:template name="configureFormat">
    <xsl:param name="sequenceName" select="''"/>
    <xsl:param name="frontmatterNames" select="()"/>
    <xsl:param name="bodyNames" select="()"/>
    <xsl:param name="backmatterNames" select="()"/>
    <xsl:param name="topicInfo" select="element()"/>
    <xsl:param name="documentTitle" select="''"/>
    <xsl:param name="documentDate" select="''"/>
    <xsl:param name="masterName" select="''"/>

    <xsl:attribute name="format" 
                   select="if (index-of($bodyNames, $sequenceName) ge 1) then 
                               '1' 
                           else 
                               'i'"/>
  </xsl:template>

  <!-- configureFootnoteSeparator ======================================== -->

  <xsl:template name="configureFootnoteSeparator">
    <xsl:param name="sequenceName" select="''"/>
    <xsl:param name="frontmatterNames" select="()"/>
    <xsl:param name="bodyNames" select="()"/>
    <xsl:param name="backmatterNames" select="()"/>
    <xsl:param name="topicInfo" select="element()"/>
    <xsl:param name="documentTitle" select="''"/>
    <xsl:param name="documentDate" select="''"/>
    <xsl:param name="masterName" select="''"/>

    <xsl:if test="$masterName = 'body' or 
                  $masterName = 'frontmatter' or 
                  $masterName = 'backmatter'">
      <xsl:call-template name="footnoteSeparator"/>
    </xsl:if>
  </xsl:template>

  <xsl:attribute-set name="footnote-separator">
    <xsl:attribute name="leader-pattern">rule</xsl:attribute>
    <xsl:attribute name="leader-length">30%</xsl:attribute>
    <xsl:attribute name="rule-style">solid</xsl:attribute>
    <xsl:attribute name="color">#404040</xsl:attribute>
    <xsl:attribute name="rule-thickness">0.25pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template name="footnoteSeparator">
    <fo:static-content flow-name="xsl-footnote-separator">
      <fo:block>
        <fo:leader xsl:use-attribute-sets="footnote-separator"/>
      </fo:block>
    </fo:static-content>
  </xsl:template>

  <!-- configureHeadersAndFooters ======================================== -->

  <xsl:template name="configureHeadersAndFooters">
    <xsl:param name="sequenceName" select="''"/>
    <xsl:param name="frontmatterNames" select="()"/>
    <xsl:param name="bodyNames" select="()"/>
    <xsl:param name="backmatterNames" select="()"/>
    <xsl:param name="topicInfo" select="element()"/>
    <xsl:param name="documentTitle" select="''"/>
    <xsl:param name="documentDate" select="''"/>
    <xsl:param name="masterName" select="''"/>

    <xsl:if test="$masterName != 'title'">
      <xsl:call-template name="headersAndFooters">
        <xsl:with-param name="sequenceName" select="$sequenceName"/>
        <xsl:with-param name="frontmatterNames" select="$frontmatterNames"/>
        <xsl:with-param name="bodyNames" select="$bodyNames"/>
        <xsl:with-param name="backmatterNames" select="$backmatterNames"/>
        <xsl:with-param name="topicInfo" select="$topicInfo"/>
        <xsl:with-param name="documentTitle" select="$documentTitle"/>
        <xsl:with-param name="documentDate" select="$documentDate"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="headersAndFooters">
    <xsl:param name="sequenceName" select="''"/>
    <xsl:param name="frontmatterNames" select="()"/>
    <xsl:param name="bodyNames" select="()"/>
    <xsl:param name="backmatterNames" select="()"/>
    <xsl:param name="topicInfo" select="element()"/>
    <xsl:param name="documentTitle" select="''"/>
    <xsl:param name="documentDate" select="''"/>

    <xsl:variable name="pageSequence" 
                  select="lower-case(substring-before($sequenceName, '.'))"/>

    <xsl:variable name="chapterTitle">
      <xsl:if test="$pageSequence = 'part' or 
                    $pageSequence = 'chapter' or 
                    $pageSequence = 'appendices' or 
                    $pageSequence = 'appendix'">
        <xsl:variable name="chapterTitlePrefix" 
                      select="u:shortTitlePrefix(string($topicInfo/@number), 
                                                 $topicInfo)" />

        <xsl:sequence select="if ($chapterTitlePrefix != '')
                              then concat($chapterTitlePrefix,
                                          $title-prefix-separator1, 
                                          $topicInfo/@title)
                              else string($topicInfo/@title)"/>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="section1Title">
      <fo:retrieve-marker retrieve-class-name="section1-title"/>
    </xsl:variable>

    <xsl:variable name="topicTitle">
      <fo:retrieve-marker retrieve-class-name="topic-title"/>
    </xsl:variable>

    <xsl:variable name="pageNumber">
      <fo:page-number/>
    </xsl:variable>

    <xsl:variable name="pageCount">
      <xsl:choose>
        <xsl:when test="index-of($frontmatterNames, $sequenceName) ge 1">
          <fo:page-number-citation ref-id="__EOFM"/>
        </xsl:when>
        <xsl:when test="index-of($bodyNames, $sequenceName) ge 1">
          <fo:page-number-citation ref-id="__EOBO"/>
        </xsl:when>
        <xsl:when test="index-of($backmatterNames, $sequenceName) ge 1">
          <fo:page-number-citation ref-id="__EOBM"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="lineBreak">
      <fo:block/>
    </xsl:variable>

    <xsl:variable name="hl1" 
      select="u:evalHeaderOrFooter($header-left,
                                   $pageSequence, 'first', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>
    <xsl:variable name="hc1" 
      select="u:evalHeaderOrFooter($header-center,
                                   $pageSequence, 'first', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>
    <xsl:variable name="hr1" 
      select="u:evalHeaderOrFooter($header-right,
                                   $pageSequence, 'first', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>

    <xsl:variable name="hl1W" 
      select="u:evalHeaderOrFooterWidth($header-left-width,
                                        $pageSequence, 'first')"/>
    <xsl:variable name="hc1W" 
      select="u:evalHeaderOrFooterWidth($header-center-width,
                                        $pageSequence, 'first')"/>
    <xsl:variable name="hr1W" 
      select="u:evalHeaderOrFooterWidth($header-right-width,
                                        $pageSequence, 'first')"/>

    <xsl:if test="exists($hl1) or exists($hc1) or exists($hr1)">
      <fo:static-content flow-name="first-page-header">
        <xsl:call-template name="tabularHeader">
          <xsl:with-param name="left" select="$hl1"/>
          <xsl:with-param name="center" select="$hc1"/>
          <xsl:with-param name="right" select="$hr1"/>
          <xsl:with-param name="isFooter" select="false()"/>
          <xsl:with-param name="leftWidth" select="$hl1W"/>
          <xsl:with-param name="centerWidth" select="$hc1W"/>
          <xsl:with-param name="rightWidth" select="$hr1W"/>
        </xsl:call-template>
      </fo:static-content>
    </xsl:if>

    <xsl:variable name="hlo" 
      select="u:evalHeaderOrFooter($header-left,
                                   $pageSequence, 'odd', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>
    <xsl:variable name="hco" 
      select="u:evalHeaderOrFooter($header-center,
                                   $pageSequence, 'odd', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>
    <xsl:variable name="hro" 
      select="u:evalHeaderOrFooter($header-right,
                                   $pageSequence, 'odd', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>

    <xsl:variable name="hloW" 
      select="u:evalHeaderOrFooterWidth($header-left-width,
                                        $pageSequence, 'odd')"/>
    <xsl:variable name="hcoW" 
      select="u:evalHeaderOrFooterWidth($header-center-width,
                                        $pageSequence, 'odd')"/>
    <xsl:variable name="hroW" 
      select="u:evalHeaderOrFooterWidth($header-right-width,
                                        $pageSequence, 'odd')"/>

    <xsl:if test="exists($hlo) or exists($hco) or exists($hro)">
      <fo:static-content flow-name="odd-page-header">
        <xsl:call-template name="tabularHeader">
          <xsl:with-param name="left" select="$hlo"/>
          <xsl:with-param name="center" select="$hco"/>
          <xsl:with-param name="right" select="$hro"/>
          <xsl:with-param name="isFooter" select="false()"/>
          <xsl:with-param name="leftWidth" select="$hloW"/>
          <xsl:with-param name="centerWidth" select="$hcoW"/>
          <xsl:with-param name="rightWidth" select="$hroW"/>
        </xsl:call-template>
      </fo:static-content>
    </xsl:if>

    <xsl:variable name="hle"
      select="u:evalHeaderOrFooter($header-left,
                                   $pageSequence, 'even', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>
    <xsl:variable name="hce" 
      select="u:evalHeaderOrFooter($header-center,
                                   $pageSequence, 'even', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>
    <xsl:variable name="hre" 
      select="u:evalHeaderOrFooter($header-right,
                                   $pageSequence, 'even', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>

    <xsl:variable name="hleW"
      select="u:evalHeaderOrFooterWidth($header-left-width,
                                        $pageSequence, 'even')"/>
    <xsl:variable name="hceW" 
      select="u:evalHeaderOrFooterWidth($header-center-width,
                                        $pageSequence, 'even')"/>
    <xsl:variable name="hreW" 
      select="u:evalHeaderOrFooterWidth($header-right-width,
                                        $pageSequence, 'even')"/>

    <xsl:if test="exists($hle) or exists($hce) or exists($hre)">
      <fo:static-content flow-name="even-page-header">
        <xsl:call-template name="tabularHeader">
          <xsl:with-param name="left" select="$hle"/>
          <xsl:with-param name="center" select="$hce"/>
          <xsl:with-param name="right" select="$hre"/>
          <xsl:with-param name="isFooter" select="false()"/>
          <xsl:with-param name="leftWidth" select="$hleW"/>
          <xsl:with-param name="centerWidth" select="$hceW"/>
          <xsl:with-param name="rightWidth" select="$hreW"/>
        </xsl:call-template>
      </fo:static-content>
    </xsl:if>

    <xsl:variable name="fl1" 
      select="u:evalHeaderOrFooter($footer-left,
                                   $pageSequence, 'first', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>
    <xsl:variable name="fc1" 
      select="u:evalHeaderOrFooter($footer-center,
                                   $pageSequence, 'first', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>
    <xsl:variable name="fr1" 
      select="u:evalHeaderOrFooter($footer-right,
                                   $pageSequence, 'first', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>

    <xsl:variable name="fl1W" 
      select="u:evalHeaderOrFooterWidth($footer-left-width,
                                        $pageSequence, 'first')"/>
    <xsl:variable name="fc1W" 
      select="u:evalHeaderOrFooterWidth($footer-center-width,
                                        $pageSequence, 'first')"/>
    <xsl:variable name="fr1W" 
      select="u:evalHeaderOrFooterWidth($footer-right-width,
                                        $pageSequence, 'first')"/>

    <xsl:if test="exists($fl1) or exists($fc1) or exists($fr1)">
      <fo:static-content flow-name="first-page-footer">
        <xsl:call-template name="tabularHeader">
          <xsl:with-param name="left" select="$fl1"/>
          <xsl:with-param name="center" select="$fc1"/>
          <xsl:with-param name="right" select="$fr1"/>
          <xsl:with-param name="isFooter" select="true()"/>
          <xsl:with-param name="leftWidth" select="$fl1W"/>
          <xsl:with-param name="centerWidth" select="$fc1W"/>
          <xsl:with-param name="rightWidth" select="$fr1W"/>
        </xsl:call-template>
      </fo:static-content>
    </xsl:if>

    <xsl:variable name="flo" 
      select="u:evalHeaderOrFooter($footer-left,
                                   $pageSequence, 'odd', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>
    <xsl:variable name="fco" 
      select="u:evalHeaderOrFooter($footer-center,
                                   $pageSequence, 'odd', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>
    <xsl:variable name="fro" 
      select="u:evalHeaderOrFooter($footer-right,
                                   $pageSequence, 'odd', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>

    <xsl:variable name="floW" 
      select="u:evalHeaderOrFooterWidth($footer-left-width,
                                        $pageSequence, 'odd')"/>
    <xsl:variable name="fcoW" 
      select="u:evalHeaderOrFooterWidth($footer-center-width,
                                        $pageSequence, 'odd')"/>
    <xsl:variable name="froW" 
      select="u:evalHeaderOrFooterWidth($footer-right-width,
                                        $pageSequence, 'odd')"/>

    <xsl:if test="exists($flo) or exists($fco) or exists($fro)">
      <fo:static-content flow-name="odd-page-footer">
        <xsl:call-template name="tabularHeader">
          <xsl:with-param name="left" select="$flo"/>
          <xsl:with-param name="center" select="$fco"/>
          <xsl:with-param name="right" select="$fro"/>
          <xsl:with-param name="isFooter" select="true()"/>
          <xsl:with-param name="leftWidth" select="$floW"/>
          <xsl:with-param name="centerWidth" select="$fcoW"/>
          <xsl:with-param name="rightWidth" select="$froW"/>
        </xsl:call-template>
      </fo:static-content>
    </xsl:if>

    <xsl:variable name="fle" 
      select="u:evalHeaderOrFooter($footer-left, 
                                   $pageSequence, 'even', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>
    <xsl:variable name="fce" 
      select="u:evalHeaderOrFooter($footer-center, 
                                   $pageSequence, 'even', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>
    <xsl:variable name="fre" 
      select="u:evalHeaderOrFooter($footer-right, 
                                   $pageSequence, 'even', 
                                   $documentTitle, $documentDate,
                                   $chapterTitle, $section1Title, $topicTitle,
                                   $pageNumber, $pageCount,
                                   $lineBreak)"/>

    <xsl:variable name="fleW" 
      select="u:evalHeaderOrFooterWidth($footer-left-width, 
                                        $pageSequence, 'even')"/>
    <xsl:variable name="fceW" 
      select="u:evalHeaderOrFooterWidth($footer-center-width, 
                                        $pageSequence, 'even')"/>
    <xsl:variable name="freW" 
      select="u:evalHeaderOrFooterWidth($footer-right-width, 
                                        $pageSequence, 'even')"/>

    <xsl:if test="exists($fle) or exists($fce) or exists($fre)">
      <fo:static-content flow-name="even-page-footer">
        <xsl:call-template name="tabularHeader">
          <xsl:with-param name="left" select="$fle"/>
          <xsl:with-param name="center" select="$fce"/>
          <xsl:with-param name="right" select="$fre"/>
          <xsl:with-param name="isFooter" select="true()"/>
          <xsl:with-param name="leftWidth" select="$fleW"/>
          <xsl:with-param name="centerWidth" select="$fceW"/>
          <xsl:with-param name="rightWidth" select="$freW"/>
        </xsl:call-template>
      </fo:static-content>
    </xsl:if>
  </xsl:template>

  <xsl:function name="u:evalHeaderOrFooterWidth" as="xs:string">
    <xsl:param name="spec" as="xs:string"/>

    <xsl:param name="pageSequence" as="xs:string"/>
    <xsl:param name="firstOrEvenOrOdd" as="xs:string"/>

    <xsl:variable name="spec2" select="normalize-space($spec)"/>
    <xsl:choose>
      <xsl:when test="number($spec2) ge 1">
        <!-- Simple, most common case: no conditions (e.g. "2"). -->
        <xsl:sequence select="$spec2"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name="filter" 
          select="u:createFilter($pageSequence, $firstOrEvenOrOdd)"/>

        <xsl:variable name="valueSpecs"
                      select="for $case in tokenize($spec2, ';;')
                              return
                                  u:testCase($case, $filter)"/>
        <xsl:variable name="valueSpec" select="$valueSpecs[1]"/>

        <xsl:choose>
          <xsl:when test="number($valueSpec) ge 1">
            <xsl:sequence select="$valueSpec"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes" 
              select="concat('cannot evaluate &quot;', $spec2, 
                             '&quot; as a proportional column width')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="u:evalHeaderOrFooter" as="item()*">
    <xsl:param name="spec" as="xs:string"/>

    <xsl:param name="pageSequence" as="xs:string"/>
    <xsl:param name="firstOrEvenOrOdd" as="xs:string"/>

    <xsl:param name="documentTitle" as="xs:string?"/>
    <xsl:param name="documentDate" as="xs:string?"/>

    <xsl:param name="chapterTitle" as="xs:string?"/>
    <xsl:param name="section1Title" as="item()*"/>
    <xsl:param name="topicTitle" as="item()*"/>

    <xsl:param name="pageNumber" as="item()*"/>
    <xsl:param name="pageCount" as="item()*"/>

    <xsl:param name="lineBreak" as="item()*"/>

    <xsl:variable name="filter" 
                  select="u:createFilter($pageSequence, $firstOrEvenOrOdd)"/>

    <xsl:variable name="valueSpecs"
                  select="for $case in tokenize($spec, ';;')
                          return
                              u:testCase($case, $filter)"/>
    <xsl:variable name="valueSpec" select="$valueSpecs[1]"/>

    <xsl:choose>
      <xsl:when test="$valueSpec ne ''">
        <!-- The Private Use Area of the Unicode Basic Multilingual Plane is 
             E000 to F8FF. 
             We'll use:
             E000 = value separator
             E001 = page-sequence
             E002 = document-title
             E003 = document-date
             E004 = chapter-title
             E005 = section1-title
             E006 = topic-title
             E007 = page-number
             E008 = page-count
             E009 = break
             E00A = image() -->

        <xsl:variable name="valueSpec1" 
          select="if (contains($valueSpec, '{{page-sequence}}'))
                  then replace($valueSpec, '\{\{page-sequence\}\}', 
                               '&#xE000;&#xE001;&#xE000;')
                  else $valueSpec"/>
        <xsl:variable name="valueSpec2" 
          select="if (contains($valueSpec1, '{{document-title}}'))
                  then replace($valueSpec1, '\{\{document-title\}\}', 
                               '&#xE000;&#xE002;&#xE000;')
                  else $valueSpec1"/>
        <xsl:variable name="valueSpec3" 
          select="if (contains($valueSpec2, '{{document-date}}'))
                  then replace($valueSpec2, '\{\{document-date\}\}', 
                               '&#xE000;&#xE003;&#xE000;')
                  else $valueSpec2"/>
        <xsl:variable name="valueSpec4" 
          select="if (contains($valueSpec3, '{{chapter-title}}'))
                  then replace($valueSpec3, '\{\{chapter-title\}\}', 
                               '&#xE000;&#xE004;&#xE000;')
                  else $valueSpec3"/>
        <xsl:variable name="valueSpec5" 
          select="if (contains($valueSpec4, '{{section1-title}}'))
                  then replace($valueSpec4, '\{\{section1-title\}\}', 
                               '&#xE000;&#xE005;&#xE000;')
                  else $valueSpec4"/>
        <xsl:variable name="valueSpec6" 
          select="if (contains($valueSpec5, '{{topic-title}}'))
                  then replace($valueSpec5, '\{\{topic-title\}\}', 
                               '&#xE000;&#xE006;&#xE000;')
                  else $valueSpec5"/>
        <xsl:variable name="valueSpec7" 
          select="if (contains($valueSpec6, '{{page-number}}'))
                  then replace($valueSpec6, '\{\{page-number\}\}', 
                               '&#xE000;&#xE007;&#xE000;')
                  else $valueSpec6"/>
        <xsl:variable name="valueSpec8" 
          select="if (contains($valueSpec7, '{{page-count}}'))
                  then replace($valueSpec7, '\{\{page-count\}\}', 
                               '&#xE000;&#xE008;&#xE000;')
                  else $valueSpec7"/>
        <xsl:variable name="valueSpec9" 
          select="if (contains($valueSpec8, '{{break}}'))
                  then replace($valueSpec8, '\{\{break\}\}', 
                               '&#xE000;&#xE009;&#xE000;')
                  else $valueSpec8"/>
        <xsl:variable name="valueSpecA" 
          select="if (contains($valueSpec9, '{{image(' ))
                  then replace($valueSpec9, '\{\{image\(([^)]+)\)\}\}', 
                               '&#xE000;&#xE00A;$1&#xE000;')
                  else $valueSpec9"/>

        <xsl:sequence 
          select="for $t in tokenize($valueSpecA, '&#xE000;')
                  return
                    if ($t eq '&#xE001;') then $pageSequence
                    else 
                      if ($t eq '&#xE002;') then $documentTitle
                      else 
                        if ($t eq '&#xE003;') then $documentDate
                        else 
                          if ($t eq '&#xE004;') then $chapterTitle
                          else 
                            if ($t eq '&#xE005;') then $section1Title
                            else 
                              if ($t eq '&#xE006;') then $topicTitle
                              else 
                                if ($t eq '&#xE007;') then $pageNumber
                                else 
                                  if ($t eq '&#xE008;') then $pageCount
                                  else 
                                    if ($t eq '&#xE009;') then $lineBreak
                                    else 
                                      if (starts-with($t, '&#xE00A;')) 
                                      then u:toExternalGraphic(substring($t, 2))
                                      else
                                        if ($t ne '') then $t else ()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="u:testCase" as="xs:string?">
    <xsl:param name="case" as="xs:string"/>
    <xsl:param name="filter" as="xs:string+"/>

    <xsl:variable name="conditions" select="tokenize($case, '::')"/>
    <xsl:variable name="conditionCount" select="count($conditions)"/>

    <xsl:choose>
      <xsl:when test="$conditionCount eq 0">
        <!-- Empty case (e.g. "foo:: bar;; ;;"). Skip it. -->
        <xsl:sequence select="()"/>
      </xsl:when>

      <xsl:when test="$conditionCount eq 1">
        <!-- Simple case having no condition (e.g. "bar"). -->
        <xsl:sequence select="normalize-space($case)"/>
      </xsl:when>

      <xsl:otherwise>
        <!-- May be the empty string (e.g. "foo:: ;;"). -->
        <xsl:variable name="valueSpec" 
                      select="normalize-space($conditions[last()])"/>

        <xsl:variable name="matches"
          select="for $cond in subsequence($conditions, 1, $conditionCount - 1)
                  return
                      if (u:testCondition($cond, $filter))
                      then true()
                      else ()"/>

        <xsl:sequence
          select="if (exists($matches)) then $valueSpec else ()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="u:createFilter" as="xs:string+">
    <xsl:param name="pageSequence" as="xs:string"/>
    <xsl:param name="firstOrEvenOrOdd" as="xs:string"/>

    <!-- Example: ('single-sided', 'section1', 'even') -->
    <xsl:sequence select="(if ($two-sided eq 'yes') 
                           then 'two-sides' 
                           else 'one-side', 
                           $pageSequence, 
                           $firstOrEvenOrOdd)"/>
  </xsl:function>

  <xsl:function name="u:testCondition" as="xs:boolean">
    <xsl:param name="condition" as="xs:string"/>
    <xsl:param name="filter" as="xs:string+"/>

    <xsl:variable name="condition2" select="normalize-space($condition)"/>
    <xsl:choose>
      <xsl:when test="$condition2 eq ''">
        <!-- Empty condition means no condition (e.g. ":: bar;;"). -->
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="simpleConditions" 
                      select="tokenize($condition2, '\s+')"/>

        <xsl:variable name="matches"
          select="for $simpleCondition in $simpleConditions
                  return
                      if (u:testSimpleCondition($simpleCondition, $filter))
                      then true()
                      else ()"/>

        <xsl:sequence select="count($matches) eq count($simpleConditions)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="u:testSimpleCondition" as="xs:boolean">
    <xsl:param name="simpleCondition" as="xs:string"/>
    <xsl:param name="filter" as="xs:string+"/>

    <!-- Note that whitespace before and after "||" is not supported. -->
    <!-- Skip an empty alternative. -->
    <xsl:variable name="matches"
      select="for $alternative in tokenize($simpleCondition, '\|\|')
              return
                  if ($alternative ne '' and 
                      exists(index-of($filter, $alternative)))
                  then true()
                  else ()"/>

    <xsl:sequence select="exists($matches)"/>
  </xsl:function>

  <xsl:function name="u:toExternalGraphic" as="element()">
    <xsl:param name="uri" as="xs:string"/>

    <fo:external-graphic
      src="{concat('url(', resolve-uri($uri, URI:userDirectory()), ')')}"/>
  </xsl:function>

  <!-- tabularHeader ========== -->

  <xsl:attribute-set name="header-or-footer">
    <xsl:attribute name="hyphenate">false</xsl:attribute>
    <xsl:attribute name="font-family">sans-serif</xsl:attribute>
    <xsl:attribute name="font-size">70%</xsl:attribute>
    <xsl:attribute name="color">#404040</xsl:attribute>
    <xsl:attribute name="border-color">#404040</xsl:attribute>
    <xsl:attribute name="border-width">0.25pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="header" use-attribute-sets="header-or-footer"/>

  <xsl:attribute-set name="footer" use-attribute-sets="header-or-footer"/>

  <xsl:attribute-set name="header-or-footer-left">
    <xsl:attribute name="text-align">left</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="header-or-footer-center">
    <xsl:attribute name="text-align">center</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="header-or-footer-right">
    <xsl:attribute name="text-align">right</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="header-left" 
                     use-attribute-sets="header-or-footer-left"/>
  <xsl:attribute-set name="header-center" 
                     use-attribute-sets="header-or-footer-center"/>
  <xsl:attribute-set name="header-right" 
                     use-attribute-sets="header-or-footer-right"/>

  <xsl:attribute-set name="footer-left" 
                     use-attribute-sets="header-or-footer-left"/>
  <xsl:attribute-set name="footer-center" 
                     use-attribute-sets="header-or-footer-center"/>
  <xsl:attribute-set name="footer-right" 
                     use-attribute-sets="header-or-footer-right"/>

  <xsl:template name="tabularHeader">
    <xsl:param name="left" select="()"/>
    <xsl:param name="center" select="()"/>
    <xsl:param name="right" select="()"/>
    <xsl:param name="isFooter" select="false()"/>
    <xsl:param name="leftWidth" select="'2'"/>
    <xsl:param name="centerWidth" select="'6'"/>
    <xsl:param name="rightWidth" select="'2'"/>

    <xsl:choose>
      <xsl:when test="$isFooter">
        <fo:block xsl:use-attribute-sets="footer">
          <xsl:if test="$footer-separator = 'yes'">
            <xsl:attribute name="border-top-style">solid</xsl:attribute>
            <xsl:attribute name="padding-top">0.125em</xsl:attribute>
          </xsl:if>

          <fo:table table-layout="fixed" width="100%">
            <fo:table-column column-number="1" 
                             column-width="{concat('proportional-column-width(',
                                                   $leftWidth, ')')}"/>
            <fo:table-column column-number="2" 
                             column-width="{concat('proportional-column-width(',
                                                   $centerWidth, ')')}"/>
            <fo:table-column column-number="3" 
                             column-width="{concat('proportional-column-width(',
                                                   $rightWidth, ')')}"/>
            <fo:table-body>
              <fo:table-row>
                <fo:table-cell start-indent="0" display-align="before"
                               xsl:use-attribute-sets="footer-left">
                  <fo:block>
                    <xsl:choose>
                      <xsl:when test="exists($left)">
                        <xsl:copy-of select="$left"/>
                      </xsl:when>
                      <xsl:otherwise>&#xA0;</xsl:otherwise>
                    </xsl:choose>
                  </fo:block>
                </fo:table-cell>
                <fo:table-cell start-indent="0" display-align="before"
                               xsl:use-attribute-sets="footer-center">
                  <fo:block>
                    <xsl:choose>
                      <xsl:when test="exists($center)">
                        <xsl:copy-of select="$center"/>
                      </xsl:when>
                      <xsl:otherwise>&#xA0;</xsl:otherwise>
                    </xsl:choose>
                  </fo:block>
                </fo:table-cell>
                <fo:table-cell start-indent="0" display-align="before"
                               xsl:use-attribute-sets="footer-right">
                  <fo:block>
                    <xsl:choose>
                      <xsl:when test="exists($right)">
                        <xsl:copy-of select="$right"/>
                      </xsl:when>
                      <xsl:otherwise>&#xA0;</xsl:otherwise>
                    </xsl:choose>
                  </fo:block>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>
        </fo:block>
      </xsl:when>

      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="header">
          <xsl:if test="$header-separator = 'yes'">
            <xsl:attribute name="padding-bottom">0.125em</xsl:attribute>
            <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
          </xsl:if>

          <fo:table table-layout="fixed" width="100%">
            <fo:table-column column-number="1" 
                             column-width="{concat('proportional-column-width(',
                                                   $leftWidth, ')')}"/>
            <fo:table-column column-number="2" 
                             column-width="{concat('proportional-column-width(',
                                                   $centerWidth, ')')}"/>
            <fo:table-column column-number="3" 
                             column-width="{concat('proportional-column-width(',
                                                   $rightWidth, ')')}"/>
            <fo:table-body>
              <fo:table-row>
                <fo:table-cell start-indent="0" display-align="after"
                               xsl:use-attribute-sets="header-left">
                  <fo:block>
                    <xsl:choose>
                      <xsl:when test="exists($left)">
                        <xsl:copy-of select="$left"/>
                      </xsl:when>
                      <xsl:otherwise>&#xA0;</xsl:otherwise>
                    </xsl:choose>
                  </fo:block>
                </fo:table-cell>
                <fo:table-cell start-indent="0" display-align="after"
                               xsl:use-attribute-sets="header-center">
                  <fo:block>
                    <xsl:choose>
                      <xsl:when test="exists($center)">
                        <xsl:copy-of select="$center"/>
                      </xsl:when>
                      <xsl:otherwise>&#xA0;</xsl:otherwise>
                    </xsl:choose>
                  </fo:block>
                </fo:table-cell>
                <fo:table-cell start-indent="0" display-align="after"
                               xsl:use-attribute-sets="header-right">
                  <fo:block>
                    <xsl:choose>
                      <xsl:when test="exists($right)">
                        <xsl:copy-of select="$right"/>
                      </xsl:when>
                      <xsl:otherwise>&#xA0;</xsl:otherwise>
                    </xsl:choose>
                  </fo:block>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
