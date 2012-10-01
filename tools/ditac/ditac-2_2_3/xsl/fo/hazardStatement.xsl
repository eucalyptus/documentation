<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2010 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                exclude-result-prefixes="xs u"
                version="2.0">

  <!--  hazardstatement ================================================== -->

  <xsl:attribute-set name="hazardstatement" use-attribute-sets="display-style">
    <xsl:attribute name="font-family">sans-serif</xsl:attribute>
    <xsl:attribute name="border-width">1pt</xsl:attribute>
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="border-color">black</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' hazard-d/hazardstatement ')]">
    <fo:table xsl:use-attribute-sets="hazardstatement">
      <xsl:call-template name="commonAttributes"/>
      <xsl:choose>
        <xsl:when test="$foProcessor = 'FOP'">
          <!-- FOP does not support table-layout=auto. -->
          <xsl:attribute name="table-layout">fixed</xsl:attribute>
          <xsl:attribute name="width">90%</xsl:attribute>
        </xsl:when>

        <xsl:otherwise>
          <xsl:attribute name="table-layout">auto</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>

      <fo:table-body>
        <xsl:call-template name="hazardStatementHead" />

        <xsl:variable name="symbols" 
          select="./*[contains(@class,' hazard-d/hazardsymbol ')]"/>
        <xsl:apply-templates select="$symbols"/>

        <xsl:apply-templates select="./* except $symbols"/>
      </fo:table-body>
    </fo:table>
  </xsl:template>

  <xsl:attribute-set name="hazardstatement-part">
    <xsl:attribute name="padding">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-head"
                     use-attribute-sets="hazardstatement-part">
    <xsl:attribute name="text-align">center</xsl:attribute>

    <xsl:attribute name="font-size">160%</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>

    <xsl:attribute name="color">white</xsl:attribute>
    <xsl:attribute name="background-color">green</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-note-head"
                     use-attribute-sets="hazardstatement-head">
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-tip-head"
                     use-attribute-sets="hazardstatement-head">
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-fastpath-head"
                     use-attribute-sets="hazardstatement-head">
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-restriction-head"
                     use-attribute-sets="hazardstatement-head">
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-important-head"
                     use-attribute-sets="hazardstatement-head">
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-remember-head"
                     use-attribute-sets="hazardstatement-head">
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-attention-head"
                     use-attribute-sets="hazardstatement-head">
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-notice-head"
                     use-attribute-sets="hazardstatement-head">
    <xsl:attribute name="color">white</xsl:attribute>
    <xsl:attribute name="background-color">blue</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-caution-head"
                     use-attribute-sets="hazardstatement-head">
    <xsl:attribute name="color">black</xsl:attribute>
    <xsl:attribute name="background-color">yellow</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-warning-head"
                     use-attribute-sets="hazardstatement-head">
    <xsl:attribute name="color">black</xsl:attribute>
    <!-- orange -->
    <xsl:attribute name="background-color">#FFA500</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-danger-head"
                     use-attribute-sets="hazardstatement-head">
    <xsl:attribute name="color">black</xsl:attribute>
    <xsl:attribute name="background-color">red</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-other-head"
                     use-attribute-sets="hazardstatement-head">
  </xsl:attribute-set>

  <xsl:attribute-set name="hazardstatement-head-icon">
    <xsl:attribute name="padding-right">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template name="hazardStatementHead">
    <xsl:choose>
      <xsl:when test="@type = 'note'">
        <fo:table-row>
          <fo:table-cell start-indent="0" 
            xsl:use-attribute-sets="hazardstatement-note-head">
            <xsl:call-template name="hazardStatementHeadContent" />
          </fo:table-cell>
        </fo:table-row>
      </xsl:when>

      <xsl:when test="@type = 'tip'">
        <fo:table-row>
          <fo:table-cell start-indent="0" 
            xsl:use-attribute-sets="hazardstatement-tip-head">
            <xsl:call-template name="hazardStatementHeadContent" />
          </fo:table-cell>
        </fo:table-row>
      </xsl:when>

      <xsl:when test="@type = 'fastpath'">
        <fo:table-row>
          <fo:table-cell start-indent="0" 
            xsl:use-attribute-sets="hazardstatement-fastpath-head">
            <xsl:call-template name="hazardStatementHeadContent" />
          </fo:table-cell>
        </fo:table-row>
      </xsl:when>

      <xsl:when test="@type = 'restriction'">
        <fo:table-row>
          <fo:table-cell start-indent="0" 
            xsl:use-attribute-sets="hazardstatement-restriction-head">
            <xsl:call-template name="hazardStatementHeadContent" />
          </fo:table-cell>
        </fo:table-row>
      </xsl:when>

      <xsl:when test="@type = 'important'">
        <fo:table-row>
          <fo:table-cell start-indent="0" 
            xsl:use-attribute-sets="hazardstatement-important-head">
            <xsl:call-template name="hazardStatementHeadContent" />
          </fo:table-cell>
        </fo:table-row>
      </xsl:when>

      <xsl:when test="@type = 'remember'">
        <fo:table-row>
          <fo:table-cell start-indent="0" 
            xsl:use-attribute-sets="hazardstatement-remember-head">
            <xsl:call-template name="hazardStatementHeadContent" />
          </fo:table-cell>
        </fo:table-row>
      </xsl:when>

      <xsl:when test="@type = 'attention'">
        <fo:table-row>
          <fo:table-cell start-indent="0" 
            xsl:use-attribute-sets="hazardstatement-attention-head">
            <xsl:call-template name="hazardStatementHeadContent" />
          </fo:table-cell>
        </fo:table-row>
      </xsl:when>

      <xsl:when test="@type = 'caution'">
        <fo:table-row>
          <fo:table-cell start-indent="0" 
            xsl:use-attribute-sets="hazardstatement-caution-head">
            <xsl:call-template name="hazardStatementHeadContent" />
          </fo:table-cell>
        </fo:table-row>
      </xsl:when>

      <xsl:when test="@type = 'notice'">
        <fo:table-row>
          <fo:table-cell start-indent="0" 
            xsl:use-attribute-sets="hazardstatement-notice-head">
            <xsl:call-template name="hazardStatementHeadContent" />
          </fo:table-cell>
        </fo:table-row>
      </xsl:when>

      <xsl:when test="@type = 'danger'">
        <fo:table-row>
          <fo:table-cell start-indent="0" 
            xsl:use-attribute-sets="hazardstatement-danger-head">
            <xsl:call-template name="hazardStatementHeadContent" />
          </fo:table-cell>
        </fo:table-row>
      </xsl:when>

      <xsl:when test="@type = 'warning'">
        <fo:table-row>
          <fo:table-cell start-indent="0" 
            xsl:use-attribute-sets="hazardstatement-warning-head">
            <xsl:call-template name="hazardStatementHeadContent" />
          </fo:table-cell>
        </fo:table-row>
      </xsl:when>

      <xsl:otherwise>
        <fo:table-row>
          <fo:table-cell start-indent="0" 
             xsl:use-attribute-sets="hazardstatement-other-head">
            <xsl:call-template name="hazardStatementHeadContent" />
          </fo:table-cell>
        </fo:table-row>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="hazardStatementHeadContent">
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="exists(@type)">
          <xsl:value-of select="@type"/>
        </xsl:when>
        <xsl:otherwise>other</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$type = 'other'">
        <fo:block>
          <xsl:value-of select="normalize-space(string(@othertype))"/>
        </fo:block>
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name="label">
          <xsl:call-template name="localize">
            <xsl:with-param name="message" select="$type"/>
          </xsl:call-template>
        </xsl:variable>

        <fo:block>
          <fo:external-graphic
            xsl:use-attribute-sets="hazardstatement-head-icon">
            <xsl:attribute name="src" 
                           select="concat('url(', $xslResourcesDir, 
                                          $type, $note-icon-suffix, ')')"/>
            <xsl:if test="$note-icon-width != ''">
              <xsl:attribute name="content-width"
                             select="u:checkLength($note-icon-width)"/>
            </xsl:if>
            <xsl:if test="$note-icon-height != ''">
              <xsl:attribute name="content-height" 
                             select="u:checkLength($note-icon-height)"/>
            </xsl:if>
            <xsl:attribute name="role" select="$label"/>
          </fo:external-graphic>

          <xsl:value-of select="$label"/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- hazardsymbol ====================================================== -->

  <xsl:attribute-set name="hazardsymbol"
                     use-attribute-sets="hazardstatement-part">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' hazard-d/hazardsymbol ')]">
    <fo:table-row>
      <fo:table-cell start-indent="0"
                     xsl:use-attribute-sets="hazardsymbol">
        <fo:block>
          <xsl:if test="@align = 'left' or
                        @align = 'right' or
                        @align = 'center'">
            <xsl:attribute name="text-align" select="string(@align)"/>
          </xsl:if>
          
          <xsl:call-template name="imageToExternalGraphic"/>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <!-- messagepanel ====================================================== -->

  <xsl:attribute-set name="messagepanel"
                     use-attribute-sets="hazardstatement-part">
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="font-size">120%</xsl:attribute>
    <xsl:attribute name="color">white</xsl:attribute>
    <xsl:attribute name="background-color">blue</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' hazard-d/messagepanel ')]">
    <fo:table-row>
      <fo:table-cell start-indent="0"
                     xsl:use-attribute-sets="messagepanel">
        <fo:block>
          <xsl:call-template name="commonAttributes"/>
          <xsl:apply-templates/>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <!-- typeofhazard ====================================================== -->

  <xsl:attribute-set name="typeofhazard" 
                     use-attribute-sets="compact-block-style">
    <xsl:attribute name="font-size">140%</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' hazard-d/typeofhazard ')]">
    <fo:block xsl:use-attribute-sets="typeofhazard">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- consequence ======================================================= -->

  <xsl:attribute-set name="consequence" 
                     use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' hazard-d/consequence ')]">
    <fo:block xsl:use-attribute-sets="consequence">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- howtoavoid ======================================================== -->

  <xsl:attribute-set name="howtoavoid"
                     use-attribute-sets="compact-block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' hazard-d/howtoavoid ')]">
    <fo:block xsl:use-attribute-sets="howtoavoid">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>
