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
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                exclude-result-prefixes="xs u"
                version="2.0">
  
  <!-- table ============================================================= -->

  <xsl:attribute-set name="table" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/table ')]">
    <fo:block xsl:use-attribute-sets="table">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="processTable"/>
    </fo:block>
  </xsl:template>

  <xsl:template name="processTable">
    <xsl:variable name="title" select="./*[contains(@class,' topic/title ')]"/>

    <xsl:choose>
      <xsl:when test="$title">
        <xsl:choose>
          <xsl:when
            test="index-of($titleAfterList,u:classToElementName(@class)) ge 1">
            <xsl:apply-templates select="./* except $title"/>
            <xsl:apply-templates select="$title"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- tgroup ============================================================ -->

  <xsl:attribute-set name="tgroup">
    <!-- Justify gives ugly results inside table cells. -->
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="width">100%</xsl:attribute>
    <xsl:attribute name="border-color">#404040</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/tgroup ')]">
    <fo:table xsl:use-attribute-sets="tgroup">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="alignAttribute"/>

      <!-- LIMITATION: $center not supported: table width is always 100% -->

      <!-- Display attributes -->
      <!-- LIMITATION: @pgwide not supported -->

      <xsl:if test="@scale">
        <xsl:attribute name="font-size" select="concat(string(@scale), '%')"/>
      </xsl:if>

      <xsl:variable name="isFirstTgroup" 
        select="count(preceding-sibling::*[contains(@class,' topic/tgroup ')]) eq 0"/>
      <xsl:variable name="isLastTgroup" 
        select="count(following-sibling::*[contains(@class,' topic/tgroup ')]) eq 0"/>

      <!-- No @frame means all. No @rowsep, @colsep means 1. -->
      <xsl:variable name="top" 
        select="$isFirstTgroup and
                (../@frame = 'top' or ../@frame = 'topbot' or 
                 ../@frame = 'all' or empty(../@frame))"/>
      <xsl:variable name="bottom" 
        select="$isLastTgroup and
                (../@frame = 'bottom' or ../@frame = 'topbot' or 
                 ../@frame = 'all' or empty(../@frame))"/>
      <xsl:variable name="left"
        select="(../@frame = 'sides' or ../@frame = 'all' or 
                 empty(../@frame))"/>
      <xsl:variable name="right" select="$left"/>

      <xsl:if test="$top">
        <xsl:attribute name="border-top-width">0.5pt</xsl:attribute>
        <xsl:attribute name="border-top-style">solid</xsl:attribute>
      </xsl:if>
      <xsl:if test="$bottom">
        <xsl:attribute name="border-bottom-width">0.5pt</xsl:attribute>
        <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
      </xsl:if>
      <xsl:if test="$left">
        <xsl:attribute name="border-left-width">0.5pt</xsl:attribute>
        <xsl:attribute name="border-left-style">solid</xsl:attribute>
      </xsl:if>
      <xsl:if test="$right">
        <xsl:attribute name="border-right-width">0.5pt</xsl:attribute>
        <xsl:attribute name="border-right-style">solid</xsl:attribute>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="number(@cols) gt 0">
          <xsl:variable name="cols" select="xs:integer(@cols)"/>

          <xsl:variable name="colspecs0" 
                        select="./*[contains(@class,' topic/colspec ')]"/>
          <xsl:variable name="colspecs" 
                        select="if (count($colspecs0) gt $cols) 
                                then subsequence($colspecs0, 1, $cols) 
                                else $colspecs0"/>

          <xsl:choose>
            <xsl:when test="count($colspecs) gt 0">
              <xsl:attribute name="table-layout">fixed</xsl:attribute>

              <xsl:for-each select="$colspecs">
                <xsl:variable name="colspec" select="."/>
                <xsl:variable name="previousColspec" 
                  select="(preceding-sibling::*[contains(@class,' topic/colspec ')])[last()]"/>

                <xsl:variable name="colspecNum" 
                              select="u:colspecNumber($colspec)"/>
                <xsl:variable name="previousColspecNum" 
                              select="if (exists($previousColspec)) 
                                      then u:colspecNumber($previousColspec)
                                      else 0"/>

                <xsl:for-each
                  select="($previousColspecNum + 1) to ($colspecNum - 1)">
                  <fo:table-column xsl:use-attribute-sets="colspec"
                    column-number="{.}" 
                    column-width="proportional-column-width(1)"/>
                </xsl:for-each>

                <xsl:apply-templates select="$colspec"/>

                <xsl:variable name="nextColspecs"
                  select="following-sibling::*[contains(@class,' topic/colspec ')]"/>
                <xsl:if test="empty($nextColspecs)">
                  <xsl:for-each select="($colspecNum + 1) to $cols">
                    <fo:table-column xsl:use-attribute-sets="colspec"
                      column-number="{.}" 
                      column-width="proportional-column-width(1)"/>
                  </xsl:for-each>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
            
            <xsl:when test="$foProcessor = 'FOP'">
              <xsl:attribute name="table-layout">fixed</xsl:attribute>

              <xsl:for-each select="1 to $cols">
                <fo:table-column xsl:use-attribute-sets="colspec"
                                 column-number="{.}" 
                                 column-width="proportional-column-width(1)"/>
              </xsl:for-each>
            </xsl:when>

            <xsl:otherwise>
              <xsl:attribute name="table-layout">auto</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <xsl:otherwise>
          <xsl:message
            terminate="yes">Missing or invalid "cols" attribute.</xsl:message>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="./*[contains(@class,' topic/thead ')]"/>
      <xsl:apply-templates select="./*[contains(@class,' topic/tbody ')]"/>
    </fo:table>
  </xsl:template>

  <!-- colspec =========================================================== -->

  <xsl:attribute-set name="colspec">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/colspec ')]">
    <fo:table-column xsl:use-attribute-sets="colspec">
      <xsl:call-template name="commonAttributes"/>

      <xsl:attribute name="column-number" select="u:colspecNumber(.)"/>

      <xsl:attribute name="column-width">
        <xsl:choose>
          <xsl:when test="@colwidth">
            <xsl:call-template name="columnWidth">
              <xsl:with-param name="colwidth" select="@colwidth"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>proportional-column-width(1)</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <xsl:apply-templates/>
    </fo:table-column>
  </xsl:template>

  <xsl:template name="columnWidth">
    <xsl:param name="colwidth">1*</xsl:param>

    <xsl:if test="contains($colwidth, '*')">
      <xsl:variable name="propSpec"
        select="normalize-space(substring-before($colwidth, '*'))"/>

      <xsl:variable name="prop">
        <xsl:choose>
          <xsl:when test="number($propSpec) gt 0">
            <xsl:sequence select="$propSpec"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:text>proportional-column-width(</xsl:text>
      <xsl:value-of select="$prop"/>
      <xsl:text>)</xsl:text>
    </xsl:if>

    <xsl:variable name="width-units">
      <xsl:choose>
        <xsl:when test="contains($colwidth, '*')">
          <xsl:value-of
               select="normalize-space(substring-after($colwidth, '*'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space($colwidth)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="width"
       select="normalize-space(translate($width-units,
                                         '+-0123456789.abcdefghijklmnopqrstuvwxyz',
                                         '+-0123456789.'))"/>

    <xsl:variable name="units"
       select="normalize-space(translate($width-units,
                                         'abcdefghijklmnopqrstuvwxyz+-0123456789.',
                                         'abcdefghijklmnopqrstuvwxyz'))"/>

    <xsl:value-of select="$width"/>

    <xsl:choose>
      <xsl:when test="$units = 'pi'">pc</xsl:when>
      <xsl:when test="$units = '' and $width != ''">pt</xsl:when>
      <xsl:otherwise><xsl:value-of select="$units"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- thead ============================================================ -->

  <xsl:attribute-set name="thead">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/thead ')]">
    <fo:table-header xsl:use-attribute-sets="thead">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="valignAttribute"/>

      <xsl:variable name="bodyLayout" select="u:bodyLayout(.)"/>
      <xsl:apply-templates>
        <xsl:with-param name="bodyLayout" select="$bodyLayout"/>
      </xsl:apply-templates>
    </fo:table-header>
  </xsl:template>

  <!-- tbody ============================================================ -->

  <xsl:attribute-set name="tbody">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/tbody ')]">
    <fo:table-body xsl:use-attribute-sets="tbody">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="valignAttribute"/>

      <xsl:variable name="bodyLayout" select="u:bodyLayout(.)"/>
      <xsl:apply-templates>
        <xsl:with-param name="bodyLayout" select="$bodyLayout"/>
      </xsl:apply-templates>
    </fo:table-body>
  </xsl:template>

  <!-- row =============================================================== -->

  <xsl:attribute-set name="row">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/row ')]">
    <xsl:param name="bodyLayout" select="()"/>

    <fo:table-row xsl:use-attribute-sets="row">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="valignAttribute"/>

      <xsl:variable name="rowIndex0"
        select="u:indexOfNode(parent::*/*[contains(@class,' topic/row ')], .)"/>
      <xsl:variable name="rowIndex" 
                    select="if (exists($rowIndex0)) then $rowIndex0 else 0"/>

      <xsl:for-each select="*[contains(@class,' topic/entry ')]">
        <xsl:variable name="startColumn" 
                      select="u:entryStartColumn(., $bodyLayout)"/>

        <xsl:variable name="previousEntry" 
          select="(preceding-sibling::*[contains(@class,' topic/entry')])[last()]"/>
        <xsl:variable name="previousEntryEndColumn" 
                      select="if (exists($previousEntry))
                              then u:entryEndColumn($previousEntry, $bodyLayout)
                              else 0"/>

        <xsl:for-each
          select="($previousEntryEndColumn + 1) to ($startColumn - 1)">
          <xsl:if test="not(u:bodyLayoutContains($bodyLayout, $rowIndex, .))">
            <fo:table-cell><fo:block/></fo:table-cell>
          </xsl:if>
        </xsl:for-each>

        <xsl:call-template name="processEntry">
          <xsl:with-param name="bodyLayout" select="$bodyLayout"/>
        </xsl:call-template>
      </xsl:for-each>
    </fo:table-row>
  </xsl:template>

  <!-- entry ============================================================= -->

  <xsl:attribute-set name="entry">
    <xsl:attribute name="border-color">#404040</xsl:attribute>
    <xsl:attribute name="padding">0.2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="header-entry" use-attribute-sets="entry">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="background-color">#E0E0E0</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template name="processEntry">
    <xsl:param name="bodyLayout" select="()"/>

    <xsl:variable name="startColumn" 
                  select="u:entryStartColumn(., $bodyLayout)"/>
    <!-- Remember that a table can contain another table. -->
    <xsl:variable name="thead" 
      select="(ancestor::*[contains(@class,' topic/thead ')])[last()]"/>
    <xsl:variable name="table" 
      select="(ancestor::*[contains(@class,' topic/table ')])[last()]"/>
    <xsl:variable name="isHeader"
      select="exists($thead) or
              (exists($table) and 
               $table[./@rowheader = 'firstcol'] and 
               $startColumn eq 1)"/>

    <xsl:choose>
      <xsl:when test="$isHeader">
        <fo:table-cell start-indent="0"
                       xsl:use-attribute-sets="header-entry">
          <xsl:call-template name="cellAttributes">
            <xsl:with-param name="bodyLayout" select="$bodyLayout"/>
          </xsl:call-template>
          <fo:block>
            <xsl:call-template name="processCellContents"/>
          </fo:block>
        </fo:table-cell>
      </xsl:when>
      <xsl:otherwise>
        <fo:table-cell start-indent="0" xsl:use-attribute-sets="entry">
          <xsl:call-template name="cellAttributes">
            <xsl:with-param name="bodyLayout" select="$bodyLayout"/>
          </xsl:call-template>
          <fo:block>
            <xsl:call-template name="processCellContents"/>
          </fo:block>
        </fo:table-cell>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="cellAttributes">
    <xsl:param name="bodyLayout" select="()"/>

    <xsl:call-template name="commonAttributes"/>

    <xsl:variable name="colspec" select="u:entryColspec(., $bodyLayout)"/>
    <xsl:choose>
      <xsl:when test="empty(@align) and 
                      exists($colspec) and 
                      exists($colspec/@align)">
        <!-- text-align cannot be specified on fo:table-column, therefore we
             cannot simply use from-table-column(). -->
        <xsl:for-each select="$colspec">
          <xsl:call-template name="alignAttribute"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="alignAttribute"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:call-template name="valignAttribute"/>

    <xsl:call-template name="cellSpanAttributes"/>

    <xsl:call-template name="cellSeparAttributes">
      <xsl:with-param name="bodyLayout" select="$bodyLayout"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="cellSpanAttributes">
    <xsl:variable name="rowspan" select="u:entryRowSpan(.)"/>
    <xsl:if test="$rowspan gt 1">
      <xsl:attribute name="number-rows-spanned" select="$rowspan"/>
    </xsl:if>

    <xsl:variable name="colspan" select="u:entryColSpan(.)"/>
    <xsl:if test="$colspan gt 1">
      <xsl:attribute name="number-columns-spanned" select="$colspan"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="cellSeparAttributes">
    <xsl:param name="bodyLayout" select="()"/>

    <!-- Remember that a table can contain another table. -->
    <xsl:variable name="table" 
      select="(ancestor::*[contains(@class,' topic/table ')])[last()]"/>
    <xsl:variable name="rows"
                  select="$table/*/*/*[contains(@class,' topic/row ')]"/>
    <xsl:variable name="rowCount" select="count($rows)"/>
    <xsl:variable name="parent" select="parent::*"/>
    <xsl:variable name="row" select="u:indexOfNode($rows, $parent)" />
    <xsl:variable name="nextRow" select="$row + u:entryRowSpan(.)"/>

    <xsl:variable name="colspec" select="u:entryColspec(., $bodyLayout)"/>

    <xsl:variable name="rowsep">
      <xsl:choose>
        <!-- A border is never needed at the very bottom edge of the table. -->
        <xsl:when test="$nextRow gt $rowCount">0</xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <!-- entry -->
            <xsl:when test="@rowsep">
              <xsl:value-of select="@rowsep"/>
            </xsl:when>
            <!-- row -->
            <xsl:when test="../@rowsep">
              <xsl:value-of select="../@rowsep"/>
            </xsl:when>
            <!-- colspec -->
            <xsl:when test="exists($colspec) and $colspec/@rowsep">
              <xsl:value-of select="$colspec/@rowsep"/>
            </xsl:when>
            <!-- tbody has no rowsep attribute -->
            <!-- tgroup -->
            <xsl:when test="../../../@rowsep">
              <xsl:value-of select="../../../@rowsep"/>
            </xsl:when>
            <!-- table -->
            <xsl:when test="../../../../@rowsep">
              <xsl:value-of select="../../../../@rowsep"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- @cols already checked by the "tgroup" template. -->
    <xsl:variable name="tgroup" 
      select="(ancestor::*[contains(@class,' topic/tgroup ')])[last()]"/>
    <xsl:variable name="colCount" select="xs:integer($tgroup/@cols)"/>

    <xsl:variable name="endColumn" select="u:entryEndColumn(., $bodyLayout)"/>

    <xsl:variable name="colsep">
      <xsl:choose>
        <!-- A border is never needed at the very right edge of the table. -->
        <xsl:when test="$endColumn eq $colCount">0</xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <!-- entry -->
            <xsl:when test="@colsep">
              <xsl:value-of select="@colsep"/>
            </xsl:when>
            <!-- colspec -->
            <xsl:when test="exists($colspec) and $colspec/@colsep">
              <xsl:value-of select="$colspec/@colsep"/>
            </xsl:when>
            <!-- row and tbody have no colsep attribute -->
            <!-- tgroup -->
            <xsl:when test="../../../@colsep">
              <xsl:value-of select="../../../@colsep"/>
            </xsl:when>
            <!-- table -->
            <xsl:when test="../../../../@colsep">
              <xsl:value-of select="../../../../@colsep"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$rowsep != '0'">
      <xsl:attribute name="border-bottom-width">0.5pt</xsl:attribute>
      <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
    </xsl:if>
    <xsl:if test="$colsep != '0'">
      <xsl:attribute name="border-right-width">0.5pt</xsl:attribute>
      <xsl:attribute name="border-right-style">solid</xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="alignAttribute">
    <xsl:if test="@align">
      <xsl:attribute name="text-align">
        <xsl:choose>
          <xsl:when test="@align = 'char'">
            <xsl:choose>
              <xsl:when test="@align/../@char">
                <xsl:value-of select="@align/../@char"/>
              </xsl:when>
              <xsl:otherwise>.</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@align"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="valignAttribute">
    <xsl:choose>
      <xsl:when test="@valign = 'top'">
        <xsl:attribute name="display-align">before</xsl:attribute>
      </xsl:when>
      <xsl:when test="@valign = 'middle'">
        <xsl:attribute name="display-align">center</xsl:attribute>
      </xsl:when>
      <xsl:when test="@valign = 'bottom'">
        <xsl:attribute name="display-align">after</xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
