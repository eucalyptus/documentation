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
                xmlns:mml="http://www.w3.org/1998/Math/MathML"
                xmlns:svg="http://www.w3.org/2000/svg"
                exclude-result-prefixes="xs mml svg"
                version="2.0">

  <!-- dita ============================================================== -->

  <xsl:template match="dita">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- draft-comment ===================================================== -->

  <xsl:template match="*[contains(@class,' topic/draft-comment ')]">
    <xsl:if test="$show-draft-comments eq 'yes'">
      <div>
        <xsl:call-template name="commonAttributes"/>
        <xsl:call-template name="namedAnchor"/>

        <xsl:if test="@author or @time or @disposition">
          <span class="draft-comment-info">
            <xsl:value-of
                select="string-join((@time, @author, @disposition), ', ')"/>
            <xsl:text>: </xsl:text>
          </span>
        </xsl:if>

        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- fn ================================================================ -->

  <xsl:template match="*[contains(@class,' topic/fn ')]">
    <xsl:if test="not(@id)">
      <xsl:call-template name="footnoteLink">
        <xsl:with-param name="footnote" select="."/>
      </xsl:call-template>
    </xsl:if>
    <!-- Otherwise it is use-by-reference footnote. -->
  </xsl:template>

  <!-- indexterm ========================================================= -->

  <xsl:template match="*[contains(@class,' topic/indexterm ')]">
    <a id="{@id}">
      <xsl:if test="$xhtmlVersion ne '1.1' and $xhtmlVersion ne '5.0'">
        <xsl:attribute name="name" select="string(@id)"/>
      </xsl:if>
    </a>
  </xsl:template>

  <!-- OMITTED: index-base, index-see, index-see-also, index-sort-as -->

  <!-- indextermref ====================================================== -->

  <xsl:template match="*[contains(@class,' topic/indextermref ')]"/>

  <!-- tm ================================================================ -->

  <xsl:template match="*[contains(@class,' topic/tm ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
      <xsl:choose>
        <xsl:when test="@tmtype eq 'reg'">&#x00AE;</xsl:when>
        <xsl:when test="@tmtype eq 'service'">&#x2120;</xsl:when>
        <xsl:otherwise>&#x2122;</xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <!-- data-about ======================================================== -->

  <xsl:template match="*[contains(@class,' topic/data-about ')]"/>

  <!-- data ============================================================== -->

  <xsl:template match="*[contains(@class,' topic/data ')]"/>

  <!-- foreign =========================================================== -->

  <xsl:template match="*[contains(@class,' topic/foreign ')]">
    <xsl:for-each select="./svg:svg">
      <xsl:call-template name="processSVG"/>
    </xsl:for-each>

    <xsl:for-each select="./mml:math">
      <xsl:call-template name="processMathML"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="processSVG">
    <!-- Force use of http://www.w3.org/2000/svg 
         as the default namespace. -->
    <xsl:apply-templates select="." mode="svg"/>
  </xsl:template>

  <xsl:template match="svg:*" xmlns:svg="http://www.w3.org/2000/svg" mode="svg">
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/2000/svg">
      <xsl:apply-templates select="@*|node()" mode="svg"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@xlink:*" xmlns:xlink="http://www.w3.org/1999/xlink" 
                mode="svg mathml">
    <xsl:attribute name="{concat('xlink:', local-name())}" 
                   namespace="http://www.w3.org/1999/xlink">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@*|node()" mode="svg">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="svg"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="processMathML">
    <!-- Force use of http://www.w3.org/1998/Math/MathML 
         as the default namespace. -->
    <xsl:apply-templates select="." mode="mathml"/>
  </xsl:template>

  <xsl:template match="mml:*" xmlns:mml="http://www.w3.org/1998/Math/MathML" 
                mode="mathml">
    <xsl:element name="{local-name()}" 
                 namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:apply-templates select="@*|node()" mode="mathml"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*|node()" mode="mathml">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="mathml"/>
    </xsl:copy>
  </xsl:template>

  <!-- unknown =========================================================== -->

  <xsl:template match="*[contains(@class,' topic/unknown ')]"/>

</xsl:stylesheet>
