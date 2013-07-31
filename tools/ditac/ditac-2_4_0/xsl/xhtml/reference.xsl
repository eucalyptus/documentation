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
                exclude-result-prefixes="xs"
                version="2.0">
  
  <!-- reference LIKE topic -->
  <!-- refbody LIKE body -->
  <!-- refbodydiv LIKE bodydiv -->

  <!-- refsyn LIKE section -->

  <!-- properties LIKE simpletable -->

  <!-- prophead ========================================================== -->

  <xsl:template match="*[contains(@class,' reference/prophead ')]">
    <tr>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>

  <!-- proptypehd ======================================================== -->

  <xsl:template match="*[contains(@class,' reference/proptypehd ')]">
    <td>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <!-- propvaluehd ======================================================= -->

  <xsl:template match="*[contains(@class,' reference/propvaluehd ')]">
    <td>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <!-- propdeschd ======================================================== -->

  <xsl:template match="*[contains(@class,' reference/propdeschd ')]">
    <td>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <!-- property ========================================================== -->

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

    <tr>
      <xsl:call-template name="commonAttributes"/>

      <xsl:choose>
        <xsl:when test="exists($type)">
          <xsl:apply-templates select="$type[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$headerHasType">
            <td class="proptype">&#xA0;</td>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="exists($value)">
          <xsl:apply-templates select="$value[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$headerHasValue">
            <td class="propvalue">&#xA0;</td>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="exists($desc)">
          <xsl:apply-templates select="$desc[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$headerHasDesc">
            <td class="propdesc">&#xA0;</td>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </tr>
  </xsl:template>

  <!-- proptype ========================================================== -->

  <xsl:template match="*[contains(@class,' reference/proptype ')]">
    <td>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <!-- propvalue ========================================================= -->

  <xsl:template match="*[contains(@class,' reference/propvalue ')]">
    <td>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <!-- propdesc ========================================================== -->

  <xsl:template match="*[contains(@class,' reference/propdesc ')]">
    <td>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

</xsl:stylesheet>
