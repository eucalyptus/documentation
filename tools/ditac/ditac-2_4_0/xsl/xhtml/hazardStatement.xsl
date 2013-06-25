<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2010-2013 Pixware SARL. All rights reserved.
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

  <!--  hazardstatement ================================================== -->

  <xsl:template match="*[contains(@class,' hazard-d/hazardstatement ')]">
    <xsl:call-template name="namedAnchor"/>
    <table>
      <xsl:call-template name="commonAttributes"/>

      <xsl:call-template name="hazardStatementHead" />

      <xsl:variable name="symbols" 
        select="./*[contains(@class,' hazard-d/hazardsymbol ')]"/>
      <xsl:apply-templates select="$symbols"/>

      <xsl:apply-templates select="./* except $symbols"/>
    </table>
  </xsl:template>

  <xsl:template name="hazardStatementHead">
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="exists(@type)">
          <xsl:value-of select="@type"/>
        </xsl:when>
        <xsl:otherwise>other</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <tr>
      <td class="{concat('hazardStatement-', $type, '-head')}">
        <xsl:choose>
          <xsl:when test="$type eq 'other'">
            <xsl:value-of select="normalize-space(string(@othertype))"/>
          </xsl:when>

          <xsl:otherwise>
            <xsl:variable name="label">
              <xsl:call-template name="localize">
                <xsl:with-param name="message" select="$type"/>
              </xsl:call-template>
            </xsl:variable>

            <img class="hazardStatement-head-icon">
              <xsl:attribute name="src"
                             select="concat($xslResourcesDir,
                                            $type, $note-icon-suffix)"/>
              <xsl:attribute name="alt" select="$label"/>
              <xsl:if test="$note-icon-width ne ''">
                <xsl:attribute name="width" select="$note-icon-width"/>
              </xsl:if>
              <xsl:if test="$note-icon-height ne ''">
                <xsl:attribute name="height" select="$note-icon-height"/>
              </xsl:if>
            </img>

            <xsl:value-of select="$label"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>

  <!-- hazardsymbol ====================================================== -->

  <xsl:template match="*[contains(@class,' hazard-d/hazardsymbol ')]">
    <tr>
      <td>
        <xsl:call-template name="commonAttributes"/>
        <xsl:if test="@align eq 'left' or
                      @align eq 'right' or
                      @align eq 'center'">
          <xsl:attribute name="style"
            select="concat('text-align: ', string(@align), ';')"/>
        </xsl:if>

        <xsl:call-template name="namedAnchor"/>
        <xsl:call-template name="imageToImg"/>
      </td>
    </tr>
  </xsl:template>

  <!-- messagepanel ====================================================== -->

  <xsl:template match="*[contains(@class,' hazard-d/messagepanel ')]">
    <tr>
      <td>
        <xsl:call-template name="commonAttributes"/>
        <xsl:call-template name="namedAnchor"/>
        <xsl:apply-templates/>
      </td>
    </tr>
  </xsl:template>

  <!-- typeofhazard ====================================================== -->

  <xsl:template match="*[contains(@class,' hazard-d/typeofhazard ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- consequence ======================================================= -->

  <xsl:template match="*[contains(@class,' hazard-d/consequence ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- howtoavoid ======================================================== -->

  <xsl:template match="*[contains(@class,' hazard-d/howtoavoid ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

</xsl:stylesheet>
