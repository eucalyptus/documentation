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
                exclude-result-prefixes="xs"
                version="2.0">

  <!-- dita ============================================================== -->

  <xsl:template match="dita">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- draft-comment ===================================================== -->

  <xsl:template match="*[contains(@class,' topic/draft-comment ')]">
    <xsl:if test="$show-draft-comments = 'yes'">
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
      <xsl:if test="$xhtmlVersion != '1.1'">
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
        <xsl:when test="@tmtype = 'reg'">&#x00AE;</xsl:when>
        <xsl:when test="@tmtype = 'service'">&#x2120;</xsl:when>
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
    <xsl:for-each select="./svg:svg|./mml:math"                
                  xmlns:mml="http://www.w3.org/1998/Math/MathML"
                  xmlns:svg="http://www.w3.org/2000/svg">
      <xsl:copy-of select="."/>
    </xsl:for-each>
  </xsl:template>

  <!-- unknown =========================================================== -->

  <xsl:template match="*[contains(@class,' topic/unknown ')]"/>

</xsl:stylesheet>
