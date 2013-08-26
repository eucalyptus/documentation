<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2009-2010 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                exclude-result-prefixes="xs"
                version="2.0">

  <!-- reference LIKE topic -->
  <!-- refbody LIKE body -->
  <!-- refbodydiv LIKE bodydiv -->

  <!-- refsyn ============================================================ -->

  <xsl:attribute-set name="refsyn" use-attribute-sets="section">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' reference/refsyn ')]">
    <fo:block xsl:use-attribute-sets="refsyn">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- properties LIKE simpletable -->

  <!-- prophead ========================================================== -->

  <xsl:attribute-set name="prophead" use-attribute-sets="sthead">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' reference/prophead ')]">
    <fo:table-row xsl:use-attribute-sets="prophead">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:table-row>
  </xsl:template>

  <!-- proptypehd ======================================================== -->

  <xsl:attribute-set name="proptypehd" use-attribute-sets="header-stentry">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' reference/proptypehd ')]">
    <fo:table-cell start-indent="0" xsl:use-attribute-sets="proptypehd">
      <xsl:call-template name="commonAttributes"/>
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <!-- propvaluehd ======================================================= -->

  <xsl:attribute-set name="propvaluehd" use-attribute-sets="header-stentry">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' reference/propvaluehd ')]">
    <fo:table-cell start-indent="0" xsl:use-attribute-sets="propvaluehd">
      <xsl:call-template name="commonAttributes"/>
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <!-- propdeschd ======================================================== -->

  <xsl:attribute-set name="propdeschd" use-attribute-sets="header-stentry">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' reference/propdeschd ')]">
    <fo:table-cell start-indent="0" xsl:use-attribute-sets="propdeschd">
      <xsl:call-template name="commonAttributes"/>
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <!-- property ========================================================== -->

  <xsl:attribute-set name="property" use-attribute-sets="strow">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' reference/property ')]">
    <!-- Implicit header has type, value and desc -->

    <xsl:variable name="header"
                  select="../*[contains(@class,' reference/prophead ')]"/>

    <xsl:variable name="headerHasType" 
      select="empty($header) or
            exists($header[1]/*[contains(@class,' reference/proptypehd ')])"/>

    <xsl:variable name="headerHasValue" 
      select="empty($header) or
            exists($header[1]/*[contains(@class,' reference/propvaluehd ')])"/>

    <xsl:variable name="headerHasDesc" 
      select="empty($header) or
            exists($header[1]/*[contains(@class,' reference/propdeschd ')])"/>

    <xsl:variable name="type"
                  select="./*[contains(@class,' reference/proptype ')]"/>
    <xsl:variable name="value"
                  select="./*[contains(@class,' reference/propvalue ')]"/>
    <xsl:variable name="desc"
                  select="./*[contains(@class,' reference/propdesc ')]"/>

    <fo:table-row xsl:use-attribute-sets="property">
      <xsl:call-template name="commonAttributes"/>

      <xsl:choose>
        <xsl:when test="exists($type)">
          <xsl:apply-templates select="$type[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$headerHasType">
            <fo:table-cell start-indent="0" xsl:use-attribute-sets="proptype">
              <fo:block>&#xA0;</fo:block>
            </fo:table-cell>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="exists($value)">
          <xsl:apply-templates select="$value[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$headerHasValue">
            <fo:table-cell start-indent="0" xsl:use-attribute-sets="propvalue">
              <fo:block>&#xA0;</fo:block>
            </fo:table-cell>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="exists($desc)">
          <xsl:apply-templates select="$desc[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$headerHasDesc">
            <fo:table-cell start-indent="0" xsl:use-attribute-sets="propdesc">
              <fo:block>&#xA0;</fo:block>
            </fo:table-cell>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </fo:table-row>
  </xsl:template>

  <!-- proptype ========================================================== -->

  <xsl:attribute-set name="proptype" use-attribute-sets="stentry">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' reference/proptype ')]">
    <fo:table-cell  start-indent="0" xsl:use-attribute-sets="proptype">
      <xsl:call-template name="commonAttributes"/>
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <!-- propvalue ========================================================= -->

  <xsl:attribute-set name="propvalue" use-attribute-sets="stentry">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' reference/propvalue ')]">
    <fo:table-cell start-indent="0" xsl:use-attribute-sets="propvalue">
      <xsl:call-template name="commonAttributes"/>
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <!-- propdesc ========================================================== -->

  <xsl:attribute-set name="propdesc" use-attribute-sets="stentry">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' reference/propdesc ')]">
    <fo:table-cell start-indent="0" xsl:use-attribute-sets="propdesc">
      <xsl:call-template name="commonAttributes"/>
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

</xsl:stylesheet>
