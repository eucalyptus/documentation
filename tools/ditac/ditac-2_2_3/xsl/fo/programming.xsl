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
                exclude-result-prefixes="xs"
                version="2.0">

  <!-- apiname =========================================================== -->

  <xsl:attribute-set name="apiname" use-attribute-sets="monospace-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' pr-d/apiname ')]">
    <fo:inline xsl:use-attribute-sets="apiname">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- LIKE: pre, codeblock -->

  <!-- coderef =========================================================== -->

  <xsl:template match="*[contains(@class,' pr-d/coderef ')]">
    <xsl:variable name="href" select="string(@href)"/>
    <xsl:if test="$href != ''">
      <xsl:choose>
        <xsl:when test="$text-file-encoding != ''">
          <xsl:value-of select="unparsed-text($href, $text-file-encoding)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="unparsed-text($href)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- codeph ============================================================ -->

  <xsl:attribute-set name="codeph" use-attribute-sets="monospace-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' pr-d/codeph ')]">
    <fo:inline xsl:use-attribute-sets="codeph">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- option ============================================================ -->

  <xsl:attribute-set name="option" use-attribute-sets="monospace-style">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' pr-d/option ')]">
    <fo:inline xsl:use-attribute-sets="option">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- parmname ========================================================== -->

  <xsl:attribute-set name="parmname" use-attribute-sets="monospace-style">
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' pr-d/parmname ')]">
    <fo:inline xsl:use-attribute-sets="parmname">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- LIKE: dl, parml -->
  <!-- LIKE: dlentry, plentry -->
  <!-- LIKE: dt, pt -->
  <!-- LIKE: dd, pd -->

  <!-- synph ============================================================= -->

  <xsl:attribute-set name="synph" use-attribute-sets="monospace-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' pr-d/synph ')]">
    <fo:inline xsl:use-attribute-sets="synph">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- OMITTED: syntaxdiagram groupseq groupchoice groupcomp fragment 
       fragref synblk synnote synnoteref repsep -->

  <xsl:template match="*[contains(@class,' pr-d/syntaxdiagram ')]"/>

  <!-- kwd =============================================================== -->

  <xsl:attribute-set name="kwd" use-attribute-sets="monospace-style">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' pr-d/kwd ')]">
    <fo:inline xsl:use-attribute-sets="kwd">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- var =============================================================== -->

  <xsl:attribute-set name="var" use-attribute-sets="monospace-style">
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' pr-d/var ')]">
    <fo:inline xsl:use-attribute-sets="var">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- oper ============================================================== -->

  <xsl:attribute-set name="oper" use-attribute-sets="monospace-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' pr-d/oper ')]">
    <fo:inline xsl:use-attribute-sets="oper">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- delim ============================================================= -->

  <xsl:attribute-set name="delim" use-attribute-sets="monospace-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' pr-d/delim ')]">
    <fo:inline xsl:use-attribute-sets="delim">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- sep =============================================================== -->

  <xsl:attribute-set name="sep" use-attribute-sets="monospace-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' pr-d/sep ')]">
    <fo:inline xsl:use-attribute-sets="sep">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

</xsl:stylesheet>
