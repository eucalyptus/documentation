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
                xmlns:rx="http://www.renderx.com/XSL/Extensions"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs ditac"
                version="2.0">

  <xsl:attribute-set name="index-container">
  </xsl:attribute-set>

  <xsl:attribute-set name="index-title" use-attribute-sets="title">
    <xsl:attribute name="font-size">180%</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="index" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="ditac:indexList">
    <fo:block xsl:use-attribute-sets="index-container" id="{$indexlistId}">
      <fo:block xsl:use-attribute-sets="index-title">
        <xsl:call-template name="outlineLevel1"/>

        <xsl:variable name="title">
          <xsl:call-template name="localize">
            <xsl:with-param name="message" select="'indexlist'"/>
          </xsl:call-template>
        </xsl:variable>

        <fo:marker marker-class-name="topic-title">
          <xsl:value-of select="$title"/>
        </fo:marker>

        <xsl:value-of select="$title"/>
      </fo:block>

      <fo:block xsl:use-attribute-sets="index">
        <xsl:apply-templates select="$ditacLists/ditac:indexList/ditac:div"/>
      </fo:block>
    </fo:block>
  </xsl:template>

  <xsl:attribute-set name="index-div-container">
  </xsl:attribute-set>

  <xsl:attribute-set name="index-div-title" use-attribute-sets="title">
    <xsl:attribute name="font-size">140%</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0em</xsl:attribute>
    <xsl:attribute name="space-after.minimum">0em</xsl:attribute>
    <xsl:attribute name="space-after.maximum">0.2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="index-div" use-attribute-sets="block-style">
    <xsl:attribute name="space-before.optimum">0em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">0em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">0.2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="ditac:div">
    <fo:block xsl:use-attribute-sets="index-div-container">
      <xsl:if test="exists(@title)">
        <fo:block xsl:use-attribute-sets="index-div-title">
          <xsl:choose>
            <xsl:when test="@title = 'symbols'">
              <xsl:call-template name="localize">
                <xsl:with-param name="message" select="'symbols'"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <!-- A simple letter. Use as is. -->
              <xsl:value-of select="@title"/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </xsl:if>
      <fo:block xsl:use-attribute-sets="index-div">
        <xsl:apply-templates select="child::ditac:indexEntry"/>
      </fo:block>
    </fo:block>
  </xsl:template>

  <xsl:attribute-set name="index-entry-container"
                     use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="index-entry"
                     use-attribute-sets="compact-block-style">
    <xsl:attribute name="text-align">left</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="index-term">
  </xsl:attribute-set>

  <xsl:attribute-set name="index-see">
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="index-see-also"
                     use-attribute-sets="index-see">
  </xsl:attribute-set>

  <xsl:attribute-set name="index-nested-entries"
                     use-attribute-sets="compact-block-style">
    <xsl:attribute name="margin-left">2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="ditac:indexEntry">
    <fo:block xsl:use-attribute-sets="index-entry-container">
      <fo:block xsl:use-attribute-sets="index-entry">
        <fo:inline xsl:use-attribute-sets="index-term">
          <xsl:value-of select="@term"/>
        </fo:inline>

        <xsl:variable name="anchors" select="child::ditac:indexAnchor"/>
        <xsl:if test="exists($anchors)">
          <!-- Note that it is not possible to have indexterms after the
               indexlist because both XEP and AHF do their index entry
               processing in a single pass. -->

          <xsl:choose>
            <xsl:when test="$foProcessor eq 'XEP'">
              <xsl:value-of select="$index-term-separator"/>
              <rx:page-index>
                <rx:index-item ref-key="{@xml:id}"
                               range-separator="{$index-range-separator}"
                               merge-subsequent-page-numbers="false"
                               link-back="true"/>
              </rx:page-index>
            </xsl:when>

            <xsl:when test="$foProcessor eq 'AHF'">
              <xsl:value-of select="$index-term-separator"/>
              <fo:index-page-citation-list
                merge-sequential-page-numbers="merge">
                <fo:index-page-citation-list-separator><xsl:value-of
                select="$index-term-separator"/></fo:index-page-citation-list-separator>
                <fo:index-page-citation-range-separator><xsl:value-of
                select="$index-range-separator"/></fo:index-page-citation-range-separator>

                <fo:index-key-reference ref-index-key="{@xml:id}"
                                        page-number-treatment="link"/>
              </fo:index-page-citation-list>
            </xsl:when>

            <xsl:otherwise>
              <xsl:for-each select="$anchors">
                <xsl:value-of select="$index-term-separator"/>
                <xsl:apply-templates select="."/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>

        <xsl:variable name="see" select="child::ditac:indexSee"/>
        <xsl:variable name="seeAlso" select="child::ditac:indexSeeAlso"/>
        <xsl:if test="exists($see) or exists($seeAlso)">
          <xsl:value-of select="$index-term-see-separator"/>
        </xsl:if>

        <xsl:if test="exists($see)">
          <fo:inline xsl:use-attribute-sets="index-see">
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'see'"/>
            </xsl:call-template>
          </fo:inline>

          <xsl:text> </xsl:text>
            
          <xsl:for-each select="$see">
            <xsl:if test="position() gt 1">
              <xsl:value-of select="$index-see-separator"/>
            </xsl:if>

            <xsl:variable name="hierarchicalTerm"
              select="string-join(tokenize(@term, '&#xA;'), 
                                  $index-hierarchical-term-separator)"/>
            <fo:inline xsl:use-attribute-sets="index-term">
              <xsl:value-of select="$hierarchicalTerm"/>
            </fo:inline>
          </xsl:for-each>
        </xsl:if>

        <xsl:if test="exists($seeAlso)">
          <fo:inline xsl:use-attribute-sets="index-see">
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'seeAlso'"/>
            </xsl:call-template>
          </fo:inline>

          <xsl:text> </xsl:text>
            
          <xsl:for-each select="$seeAlso">
            <xsl:if test="position() gt 1">
              <xsl:value-of select="$index-see-separator"/>
            </xsl:if>

            <xsl:variable name="hierarchicalTerm"
              select="string-join(tokenize(@term, '&#xA;'), 
                                  $index-hierarchical-term-separator)"/>
            <fo:inline xsl:use-attribute-sets="index-term">
              <xsl:value-of select="$hierarchicalTerm"/>
            </fo:inline>
          </xsl:for-each>
        </xsl:if>
      </fo:block>

      <xsl:variable name="nested" select="child::ditac:indexEntry"/>
      <xsl:if test="exists($nested)">
        <fo:block xsl:use-attribute-sets="index-nested-entries">
          <xsl:apply-templates select="$nested"/>
        </fo:block>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:attribute-set name="index-anchor-ref">
  </xsl:attribute-set>

  <xsl:template match="ditac:indexAnchor">
    <fo:basic-link internal-destination="{@id}"
                   xsl:use-attribute-sets="index-anchor-ref">
      <fo:page-number-citation ref-id="{@id}"/>
    </fo:basic-link>

    <xsl:if test="exists(@id2)">
      <xsl:value-of select="$index-range-separator"/>

      <fo:basic-link internal-destination="{@id2}"
                     xsl:use-attribute-sets="index-anchor-ref">
        <fo:page-number-citation ref-id="{@id2}"/>
      </fo:basic-link>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
