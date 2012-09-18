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

  <!-- apiname =========================================================== -->

  <xsl:template match="*[contains(@class,' pr-d/apiname ')]">
    <tt>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </tt>
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

  <xsl:template match="*[contains(@class,' pr-d/codeph ')]">
    <tt>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </tt>
  </xsl:template>

  <!-- option ============================================================ -->

  <xsl:template match="*[contains(@class,' pr-d/option ')]">
    <b>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </b>
  </xsl:template>

  <!-- parmname ========================================================== -->

  <xsl:template match="*[contains(@class,' pr-d/parmname ')]">
    <i>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </i>
  </xsl:template>

  <!-- LIKE: dl, parml -->
  <!-- LIKE: dlentry, plentry -->
  <!-- LIKE: dt, pt -->
  <!-- LIKE: dd, pd -->

  <!-- synph ============================================================= -->

  <xsl:template match="*[contains(@class,' pr-d/synph ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- OMITTED: syntaxdiagram groupseq groupchoice groupcomp fragment 
       fragref synblk synnote synnoteref repsep -->

  <xsl:template match="*[contains(@class,' pr-d/syntaxdiagram ')]"/>

  <!-- kwd =============================================================== -->

  <xsl:template match="*[contains(@class,' pr-d/kwd ')]">
    <b>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </b>
  </xsl:template>

  <!-- var =============================================================== -->

  <xsl:template match="*[contains(@class,' pr-d/var ')]">
    <i>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </i>
  </xsl:template>

  <!-- oper ============================================================== -->

  <xsl:template match="*[contains(@class,' pr-d/oper ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- delim ============================================================= -->

  <xsl:template match="*[contains(@class,' pr-d/delim ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- sep =============================================================== -->

  <xsl:template match="*[contains(@class,' pr-d/sep ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

</xsl:stylesheet>
