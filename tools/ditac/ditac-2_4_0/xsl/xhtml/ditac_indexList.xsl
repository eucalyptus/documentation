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

  <xsl:template match="ditac:indexList">
    <xsl:element name="{$navQName}">
      <xsl:attribute name="class" select="'index-container'"/>
      <xsl:attribute name="id" select="$indexlistId"/>

      <h1 class="index-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'indexlist'"/>
        </xsl:call-template>
      </h1>
      <div class="index">
        <xsl:apply-templates select="$ditacLists/ditac:indexList/ditac:div"/>
      </div>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ditac:div">
    <div class="index-div-container">
      <xsl:if test="exists(@title)">
        <h2 class="index-div-title">
          <xsl:choose>
            <xsl:when test="@title eq 'symbols'">
              <xsl:call-template name="localize">
                <xsl:with-param name="message" select="'symbols'"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <!-- A simple letter. Use as is. -->
              <xsl:value-of select="@title"/>
            </xsl:otherwise>
          </xsl:choose>
        </h2>
      </xsl:if>
      <div class="index-div">
        <xsl:apply-templates select="child::ditac:indexEntry"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="ditac:indexEntry">
    <div class="index-entry-container">
      <p class="index-entry">
        <span class="index-term">
          <xsl:value-of select="@term"/>
        </span>

        <xsl:for-each select="child::ditac:indexAnchor">
          <xsl:value-of select="$index-term-separator"/>
          <xsl:apply-templates select="."/>
        </xsl:for-each>

        <xsl:variable name="see" select="child::ditac:indexSee"/>
        <xsl:variable name="seeAlso" select="child::ditac:indexSeeAlso"/>
        <xsl:if test="exists($see) or exists($seeAlso)">
          <xsl:value-of select="$index-term-see-separator"/>
        </xsl:if>

        <xsl:if test="exists($see)">
          <span class="index-see">
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'see'"/>
            </xsl:call-template>
          </span>

          <xsl:text> </xsl:text>
            
          <xsl:for-each select="$see">
            <xsl:if test="position() gt 1">
              <xsl:value-of select="$index-see-separator"/>
            </xsl:if>

            <xsl:variable name="hierarchicalTerm"
              select="string-join(tokenize(@term, '&#xA;'), 
                                  $index-hierarchical-term-separator)"/>
            <span class="index-term">
              <xsl:value-of select="$hierarchicalTerm"/>
            </span>
          </xsl:for-each>
        </xsl:if>

        <xsl:if test="exists($seeAlso)">
          <span class="index-see">
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'seeAlso'"/>
            </xsl:call-template>
          </span>

          <xsl:text> </xsl:text>
            
          <xsl:for-each select="$seeAlso">
            <xsl:if test="position() gt 1">
              <xsl:value-of select="$index-see-separator"/>
            </xsl:if>

            <xsl:variable name="hierarchicalTerm"
              select="string-join(tokenize(@term, '&#xA;'), 
                                  $index-hierarchical-term-separator)"/>
            <span class="index-term">
              <xsl:value-of select="$hierarchicalTerm"/>
            </span>
          </xsl:for-each>
        </xsl:if>
      </p>

      <xsl:variable name="nested" select="child::ditac:indexEntry"/>
      <xsl:if test="exists($nested)">
        <div class="index-nested-entries">
          <xsl:apply-templates select="$nested"/>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="ditac:indexAnchor">
    <a href="{u:joinLinkTarget(@file, @id)}" class="index-anchor-ref">
      <xsl:value-of select="@number"/>
    </a>

    <xsl:if test="exists(@id2)">
      <xsl:value-of select="$index-range-separator"/>

      <a href="{u:joinLinkTarget(@file2, @id2)}" class="index-anchor-ref">
        <xsl:value-of select="@number2"/>
      </a>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
