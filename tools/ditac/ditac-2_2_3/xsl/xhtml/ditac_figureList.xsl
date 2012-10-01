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

  <xsl:template match="ditac:figureList">
    <div class="booklist-container" id="{$figurelistId}">
      <h1 class="booklist-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'figurelist'"/>
        </xsl:call-template>
      </h1>
      <table border="0" cellspacing="0" class="booklist">
        <xsl:apply-templates 
          select="$ditacLists/ditac:figureList/ditac:figure"/>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="ditac:tableList">
    <div class="booklist-container" id="{$tablelistId}">
      <h1 class="booklist-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'tablelist'"/>
        </xsl:call-template>
      </h1>
      <table border="0" cellspacing="0" class="booklist">
        <xsl:apply-templates 
          select="$ditacLists/ditac:tableList/ditac:table"/>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="ditac:exampleList">
    <div class="booklist-container" id="{$examplelistId}">
      <h1 class="booklist-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'examplelist'"/>
        </xsl:call-template>
      </h1>
      <table border="0" cellspacing="0" class="booklist">
        <xsl:apply-templates 
          select="$ditacLists/ditac:exampleList/ditac:example"/>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="ditac:figure|ditac:table|ditac:example">
    <tr valign="top">
      <td class="booklist-item-number">
        <xsl:variable name="num"
                      select="u:shortTitlePrefix(string(@number), .)"/>
        <xsl:choose>
          <xsl:when test="$num != ''">
            <!-- Discard leading 'Figure ', 'Table ', 'Example '. -->
            <xsl:value-of select="concat(substring-after($num, '&#xA0;'), 
                                         $title-prefix-separator1)"/>
          </xsl:when>
          <xsl:otherwise>&#xA0;</xsl:otherwise>
        </xsl:choose>
      </td>

      <td class="booklist-item">
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
