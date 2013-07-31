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
                exclude-result-prefixes="xs u"
                version="2.0">
  
  <!-- simpletable ======================================================= -->

  <xsl:template match="*[contains(@class,' topic/simpletable ')]">
    <div class="simpletable-container">
      <xsl:call-template name="namedAnchor"/>

      <!-- XHTML5 allows border=1. -->
      <table border="1">
        <xsl:call-template name="commonAttributes"/>

        <!-- Display attributes -->
        <!-- LIMITATION: @expanse partially supported:
             100%, no matter the value of @expanse. -->

        <xsl:variable name="width" 
                      select="if (exists(@expanse)) 
                              then '100%'
                              else if ($default-table-width ne '') 
                              then $default-table-width
                              else ''"/>

        <!-- LIMITATION: @frame not supported. -->

        <xsl:variable name="extraStyles">
          <xsl:if test="@scale">
            font-size: <xsl:value-of select="@scale"/>%;
          </xsl:if>

          <xsl:if
            test="(index-of($centerList,u:classToElementName(@class)) ge 1) and
                  empty(@expanse)">
            margin-left: auto; margin-right: auto;
          </xsl:if>
        </xsl:variable>

        <xsl:call-template name="tableLayoutAttributes">
          <xsl:with-param name="width" select="$width"/>
          <xsl:with-param name="extraStyles" select="$extraStyles"/>
        </xsl:call-template>

        <xsl:if test="@relcolwidth">
          <xsl:variable name="relWidths"
            select="for $i in 
                     tokenize(normalize-space(translate(@relcolwidth,'*',' ')),
                              '\s+')
                    return number($i)"/>

          <xsl:variable name="totalWidth" select="sum($relWidths)"/>

          <xsl:if test="$totalWidth gt 0">
            <xsl:for-each select="$relWidths">
              <!-- XHTML5 does not allow col. -->
              <colgroup>
                <xsl:if test=". gt 0">
                  <xsl:call-template name="tableLayoutAttributes">
                    <xsl:with-param name="width"
                      select="concat(round((. div $totalWidth)*100),'%')"/>
                  </xsl:call-template>
                </xsl:if>
              </colgroup>
            </xsl:for-each>
          </xsl:if>
        </xsl:if>

        <xsl:variable name="header"
                      select="./*[contains(@class,' topic/sthead ')]"/>
        <xsl:choose>
          <xsl:when test="exists($header)">
            <thead>
              <xsl:apply-templates select="$header"/>
            </thead>
          </xsl:when>

          <xsl:when test="contains(@class,' task/choicetable ')">
            <!-- Generate a chhead containing Option and Description when such
                 header is absent. -->
            <thead>
              <tr class="chhead">
                <td class="choptionhd">
                  <xsl:call-template name="localize">
                    <xsl:with-param name="message" select="'option'"/>
                  </xsl:call-template>
                </td>
                <td class="chdeschd">
                  <xsl:call-template name="localize">
                    <xsl:with-param name="message" select="'description'"/>
                  </xsl:call-template>
                </td>
              </tr>
            </thead>
          </xsl:when>
        </xsl:choose>

        <tbody>
          <xsl:apply-templates select="./*[contains(@class,' topic/strow ')]"/>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <!-- sthead ============================================================ -->

  <xsl:template match="*[contains(@class,' topic/sthead ')]">
    <tr>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>

  <!-- strow ============================================================= -->

  <xsl:template match="*[contains(@class,' topic/strow ')]">
    <tr>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>

  <!-- stentry =========================================================== -->

  <xsl:template match="*[contains(@class,' topic/stentry ')]">
    <xsl:variable name="column" select="position()" />

    <xsl:variable name="isHeader" 
      select="parent::*[contains(@class,' topic/sthead ')] or 
              ancestor::*[contains(@class,' topic/simpletable ') and 
                          number(@keycol) eq $column]"/>

    <xsl:choose>
      <xsl:when test="$isHeader">
        <th>
          <xsl:call-template name="commonAttributes">
            <xsl:with-param name="classPrefix" select="'header-'"/>
          </xsl:call-template>
          <xsl:call-template name="namedAnchor"/>
          <xsl:call-template name="processCellContents"/>
        </th>
      </xsl:when>
      <xsl:otherwise>
        <td>
          <xsl:call-template name="commonAttributes"/>
          <xsl:call-template name="namedAnchor"/>
          <xsl:call-template name="processCellContents"/>
        </td>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
