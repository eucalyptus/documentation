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
                xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs u ditac"
                version="2.0">

  <xsl:attribute-set name="booklist-container">
  </xsl:attribute-set>

  <xsl:attribute-set name="booklist-title" use-attribute-sets="title">
    <xsl:attribute name="font-size">180%</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="booklist" use-attribute-sets="block-style">
    <xsl:attribute
        name="provisional-distance-between-starts">4em</xsl:attribute>
    <xsl:attribute name="provisional-label-separation">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="ditac:figureList">
    <fo:block xsl:use-attribute-sets="booklist-container" id="{$figurelistId}">
      <fo:block xsl:use-attribute-sets="booklist-title">
        <xsl:call-template name="outlineLevel1"/>

        <xsl:variable name="title">
          <xsl:call-template name="localize">
            <xsl:with-param name="message" select="'figurelist'"/>
          </xsl:call-template>
        </xsl:variable>

        <fo:marker marker-class-name="topic-title">
          <xsl:value-of select="$title"/>
        </fo:marker>

        <xsl:value-of select="$title"/>
      </fo:block>

      <fo:list-block xsl:use-attribute-sets="booklist">
        <xsl:apply-templates 
          select="$ditacLists/ditac:figureList/ditac:figure"/>
      </fo:list-block>
    </fo:block>
  </xsl:template>

  <xsl:template match="ditac:tableList">
    <fo:block xsl:use-attribute-sets="booklist-container" id="{$tablelistId}">
      <fo:block xsl:use-attribute-sets="booklist-title">
        <xsl:call-template name="outlineLevel1"/>

        <xsl:variable name="title">
          <xsl:call-template name="localize">
            <xsl:with-param name="message" select="'tablelist'"/>
          </xsl:call-template>
        </xsl:variable>

        <fo:marker marker-class-name="topic-title">
          <xsl:value-of select="$title"/>
        </fo:marker>

        <xsl:value-of select="$title"/>
      </fo:block>

      <fo:list-block xsl:use-attribute-sets="booklist">
        <xsl:apply-templates 
          select="$ditacLists/ditac:tableList/ditac:table"/>
      </fo:list-block>
    </fo:block>
  </xsl:template>

  <xsl:template match="ditac:exampleList">
    <fo:block xsl:use-attribute-sets="booklist-container" id="{$examplelistId}">
      <fo:block xsl:use-attribute-sets="booklist-title">
        <xsl:call-template name="outlineLevel1"/>

        <xsl:variable name="title">
          <xsl:call-template name="localize">
            <xsl:with-param name="message" select="'examplelist'"/>
          </xsl:call-template>
        </xsl:variable>

        <fo:marker marker-class-name="topic-title">
          <xsl:value-of select="$title"/>
        </fo:marker>

        <xsl:value-of select="$title"/>
      </fo:block>

      <fo:list-block xsl:use-attribute-sets="booklist">
        <xsl:apply-templates 
          select="$ditacLists/ditac:exampleList/ditac:example"/>
      </fo:list-block>
    </fo:block>
  </xsl:template>

  <xsl:attribute-set name="booklist-item"
                     use-attribute-sets="compact-block-style">
    <xsl:attribute name="relative-align">baseline</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="booklist-item-number">
  </xsl:attribute-set>

  <xsl:attribute-set name="booklist-item-title">
  </xsl:attribute-set>

  <xsl:attribute-set name="booklist-item-description"
                     use-attribute-sets="semi-compact-block-style">
    <xsl:attribute
      name="keep-with-previous.within-column">always</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="ditac:figure|ditac:table|ditac:example">
    <fo:list-item xsl:use-attribute-sets="booklist-item">
      <fo:list-item-label end-indent="label-end()">
        <fo:block xsl:use-attribute-sets="booklist-item-number"
                  text-align="end">
          <xsl:variable name="num"
                        select="u:shortTitlePrefix(string(@number), .)"/>
          <xsl:choose>
            <xsl:when test="$num != ''">
              <!-- Discard leading 'Figure ', 'Table ', 'Example '. -->
              <xsl:variable name="label"
                            select="concat(substring-after($num, '&#xA0;'), 
                                           $title-prefix-separator1)"/>

              <xsl:choose>
                <xsl:when test="$foProcessor = 'XFC'">
                  <!-- XFC infers the type of the list using the label of the
                       first item. We don't want that. Therefore we insert an
                       nbsp char before the actual label. -->
                  <xsl:value-of select="concat('&#xA0;', $label)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$label"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>&#xA0;</xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </fo:list-item-label>

      <fo:list-item-body start-indent="body-start()">
        <fo:block xsl:use-attribute-sets="booklist-item-title"
                  text-align-last="justify">
          <fo:basic-link internal-destination="{@id}">
            <xsl:value-of select="@title"/>
          </fo:basic-link>
          <xsl:text> </xsl:text>
          <fo:leader leader-pattern="dots"
                     keep-with-next.within-line="always">
            <xsl:if test="$foProcessor = 'XFC'">
              <xsl:attribute name="xfc:tab-position">-30pt</xsl:attribute>
              <xsl:attribute name="xfc:tab-align">right</xsl:attribute>
            </xsl:if>
          </fo:leader>
          <xsl:text> </xsl:text>
          <fo:page-number-citation ref-id="{@id}"/>
        </fo:block>

        <xsl:if test="exists(./ditac:description)">
          <fo:block xsl:use-attribute-sets="booklist-item-description">
            <xsl:apply-templates select="./ditac:description/node()"/>
          </fo:block>
        </xsl:if>
      </fo:list-item-body>
    </fo:list-item>
  </xsl:template>

</xsl:stylesheet>
