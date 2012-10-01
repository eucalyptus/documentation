<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
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
                exclude-result-prefixes="xs u"
                version="2.0">

  <xsl:template name="commonAttributes">
    <xsl:param name="class" select="''"/>
    <xsl:param name="classPrefix" select="''"/>
    
    <xsl:call-template name="idAttribute"/>
    <xsl:call-template name="localizationAttributes"/>
    <xsl:call-template name="otherAttributes">
      <xsl:with-param name="class" select="$class"/>
      <xsl:with-param name="classPrefix" select="$classPrefix"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="commonAttributes2">
    <xsl:param name="class" select="''"/>
    <xsl:param name="classPrefix" select="''"/>
    
    <xsl:call-template name="idAttribute2"/>
    <xsl:call-template name="localizationAttributes"/>
    <xsl:call-template name="otherAttributes">
      <xsl:with-param name="class" select="$class"/>
      <xsl:with-param name="classPrefix" select="$classPrefix"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="idAttribute">
    <xsl:copy-of select="@id"/>
  </xsl:template>

  <xsl:template name="idAttribute2">
    <xsl:attribute name="id">
      <xsl:choose>
        <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('I_', generate-id(), '_')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="localizationAttributes">
    <xsl:copy-of select="@xml:lang"/>
    <xsl:if test="$xhtmlVersion != '1.1' and exists(@xml:lang)">
      <xsl:attribute name="lang" select="string(@xml:lang)"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="otherAttributes">
    <xsl:param name="class" select="''"/>
    <xsl:param name="classPrefix" select="''"/>

    <xsl:choose>
      <xsl:when test="@outputclass and 
                      matches(@outputclass, '^[a-zA-Z0-9][a-zA-Z0-9-]*$')">
        <xsl:attribute name="class" select="@outputclass"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$class">
            <xsl:attribute name="class" select="$class"/>
          </xsl:when>
          <xsl:when test="@class">
            <xsl:attribute name="class"
              select="concat($classPrefix, u:classToElementName(@class))"/>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="namedAnchor">
    <!-- This is a hack created uniquely to support JavaHelp which cannot
         scroll to id="XXX" and instead insists on having a name="XXX". 
         Note that the HTML 3.2 created by these XSLT stylesheets 
         cannot be valid in all cases. -->
    <xsl:if test="exists(@id) and $xhtmlVersion = '-3.2'">
      <a name="{string(@id)}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="namedAnchor2">
    <xsl:if test="$xhtmlVersion = '-3.2'">
      <xsl:variable name="id">
        <xsl:choose>
          <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('I_', generate-id(), '_')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <a name="{$id}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="displayAttributes">
    <!-- @expanse not implemented here -->
    <xsl:variable name="style">
      <xsl:if test="@scale">
        font-size: <xsl:value-of select="@scale"/>%;
      </xsl:if>

      <xsl:if test="@frame">
        <!-- Do not use shorthand properties and do no specify border
             color. This allows the user to specify a custom border color in
             her/his CSS. -->
        <xsl:choose>
          <xsl:when test="@frame = 'top'">
            border-top-width: 1px;
            border-top-style: solid;
            padding-top: 0.5ex;
          </xsl:when>
          <xsl:when test="@frame = 'bottom'">
            border-bottom-width: 1px;
            border-bottom-style: solid;
            padding-bottom: 0.5ex;
          </xsl:when>
          <xsl:when test="@frame = 'topbot'">
            border-top-width: 1px;
            border-top-style: solid;
            border-bottom-width: 1px;
            border-bottom-style: solid;
            padding-top: 0.5ex;
            padding-bottom: 0.5ex;
          </xsl:when>
          <xsl:when test="@frame = 'all'">
            border-width: 1px;
            border-style: solid;
            padding: 0.5ex;
          </xsl:when>
          <xsl:when test="@frame = 'sides'">
            border-left-width: 1px; 
            border-left-style: solid; 
            border-right-width: 1px;
            border-right-style: solid;
            padding-left: 0.5ex;
            padding-right: 0.5ex;
          </xsl:when>
        </xsl:choose>
      </xsl:if>

      <xsl:if test="contains(@class,' topic/fig ') and 
                (index-of($centerList, u:classToElementName(@class)) ge 1) and
                exists(./*[contains(@class,' topic/image ')])">
        text-align: center;
      </xsl:if>
    </xsl:variable>

    <xsl:if test="$style != ''">
      <xsl:attribute name="style" select="normalize-space($style)"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="scopeAttribute">
    <!-- No need to lookup for @scope: the preprocessor has cascaded 
         this attribute in the related-links section. -->
    <xsl:if test="@scope = 'external' and $xhtmlVersion != '1.1'">
      <xsl:attribute name="target">_blank</xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="externalLinkIcon">
    <!-- No need to lookup for @scope: the preprocessor has cascaded 
         this attribute in the related-links section. -->
    <xsl:if test="@scope = 'external'">
      <xsl:call-template name="addExternalLinkIcon"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="addExternalLinkIcon">
    <xsl:if test="$mark-external-links = 'yes' and $xhtmlVersion != '1.1'">
      <xsl:text> </xsl:text>
      <img border="0">
        <xsl:attribute name="src"
                       select="concat($xslResourcesDir,
                                      $external-link-icon-name)"/>
        <xsl:attribute name="alt">
          <xsl:call-template name="localize">
            <xsl:with-param name="message" select="'newWindow'"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:if test="$external-link-icon-width != ''">
          <xsl:attribute name="width" select="$external-link-icon-width"/>
        </xsl:if>
        <xsl:if test="$external-link-icon-height != ''">
          <xsl:attribute name="height" select="$external-link-icon-height"/>
        </xsl:if>
      </img>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
