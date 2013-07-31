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

  <xsl:template match="ditac:figureList">
    <xsl:element name="{$navQName}">
      <xsl:attribute name="class" select="'booklist-container'"/>
      <xsl:attribute name="id" select="$figurelistId"/>

      <h1 class="booklist-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'figurelist'"/>
        </xsl:call-template>
      </h1>

      <xsl:variable name="items" 
                    select="$ditacLists/ditac:figureList/ditac:figure"/>
      <xsl:if test="exists($items)">
        <table class="booklist">
          <xsl:apply-templates select="$items"/>
        </table>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ditac:tableList">
    <xsl:element name="{$navQName}">
      <xsl:attribute name="class" select="'booklist-container'"/>
      <xsl:attribute name="id" select="$tablelistId"/>

      <h1 class="booklist-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'tablelist'"/>
        </xsl:call-template>
      </h1>

      <xsl:variable name="items" 
                    select="$ditacLists/ditac:tableList/ditac:table"/>
      <xsl:if test="exists($items)">
        <table class="booklist">
          <xsl:apply-templates select="$items"/>
        </table>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ditac:exampleList">
    <xsl:element name="{$navQName}">
      <xsl:attribute name="class" select="'booklist-container'"/>
      <xsl:attribute name="id" select="$examplelistId"/>

      <h1 class="booklist-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'examplelist'"/>
        </xsl:call-template>
      </h1>

      <xsl:variable name="items" 
                    select="$ditacLists/ditac:exampleList/ditac:example"/>
      <xsl:if test="exists($items)">
        <table class="booklist">
          <xsl:apply-templates select="$items"/>
        </table>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ditac:figure|ditac:table|ditac:example">
    <tr>
      <td class="booklist-item-number">
        <xsl:call-template name="tableLayoutAttributes">
          <xsl:with-param name="valign" select="'baseline'"/>
        </xsl:call-template>

        <xsl:variable name="num"
                      select="u:shortTitlePrefix(string(@number), .)"/>
        <xsl:choose>
          <xsl:when test="$num ne ''">
            <!-- Discard leading 'Figure ', 'Table ', 'Example '. -->
            <xsl:value-of select="concat(substring-after($num, '&#xA0;'), 
                                         $title-prefix-separator1)"/>
          </xsl:when>
          <xsl:otherwise>&#xA0;</xsl:otherwise>
        </xsl:choose>
      </td>

      <td class="booklist-item">
        <xsl:call-template name="tableLayoutAttributes">
          <xsl:with-param name="valign" select="'baseline'"/>
        </xsl:call-template>
              
        <a href="{u:joinLinkTarget(@file, @id)}" 
           class="booklist-item-title"><xsl:value-of select="@title"/></a>

        <xsl:if test="exists(./ditac:description)">
          <p class="booklist-item-description">
            <xsl:apply-templates select="./ditac:description/node()"/>
          </p>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
