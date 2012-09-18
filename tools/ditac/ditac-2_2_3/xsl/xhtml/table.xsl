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
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                exclude-result-prefixes="xs u"
                version="2.0">
  
  <!-- table ============================================================= -->

  <xsl:template match="*[contains(@class,' topic/table ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="descToTitleAttribute"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="processTable"/>
    </div>
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

  <xsl:template match="*[contains(@class,' topic/tgroup ')]">
    <xsl:call-template name="namedAnchor"/>
    <table>
      <xsl:call-template name="commonAttributes"/>

      <xsl:choose>
        <xsl:when test="u:isSimpleBorderTable(.)">
          <!-- ========== table having simple borders ========== -->
          <xsl:attribute name="border">1</xsl:attribute>

          <xsl:choose>
            <xsl:when test="exists(../@pgwide)">
              <!-- LIMITATION: @pgwide partially supported:
                   100%, no matter the value of @pgwide -->
              <xsl:attribute name="width">100%</xsl:attribute>
            </xsl:when>
            <xsl:when test="$default-table-width != ''">
              <xsl:attribute name="width" select="$default-table-width"/>
            </xsl:when>
          </xsl:choose>

          <!-- Display attributes -->

          <xsl:variable name="style">
            <xsl:if test="@scale">
              font-size: <xsl:value-of select="@scale"/>%;
            </xsl:if>

            <xsl:if
            test="(index-of($centerList,u:classToElementName(../@class)) ge 1) 
                  and empty(../@pgwide)">
              margin-left: auto; margin-right: auto;
            </xsl:if>
          </xsl:variable>

          <xsl:if test="$style != ''">
            <xsl:attribute name="style" select="normalize-space($style)"/>
          </xsl:if>
        </xsl:when>

        <xsl:otherwise>
          <!-- ========== table having complex borders ========== -->
          <xsl:attribute name="width">100%</xsl:attribute>
          <xsl:attribute name="cellspacing">0</xsl:attribute>

          <xsl:variable name="style">
            margin: 0;

            <!-- Display attributes -->

            <xsl:if test="@scale">
              font-size: <xsl:value-of select="@scale"/>%;
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
              border-top-width: 1px;
              border-top-style: solid;
            </xsl:if>
            <xsl:if test="$bottom">
              border-bottom-width: 1px;
              border-bottom-style: solid;
            </xsl:if>
            <xsl:if test="$left">
              border-left-width: 1px; 
              border-left-style: solid; 
            </xsl:if>
            <xsl:if test="$right">
              border-right-width: 1px;
              border-right-style: solid;
            </xsl:if>
          </xsl:variable>

          <xsl:if test="$style != ''">
            <xsl:attribute name="style" select="normalize-space($style)"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="number(@cols) gt 0">
          <xsl:variable name="cols" select="xs:integer(@cols)"/>

          <xsl:variable name="colspecs0" 
                        select="./*[contains(@class,' topic/colspec ')]"/>
          <xsl:variable name="colspecs" 
                        select="if (count($colspecs0) gt $cols) 
                                then subsequence($colspecs0, 1, $cols) 
                                else $colspecs0"/>

          <xsl:if test="count($colspecs) gt 0">
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
                <col class="colspec"/>
              </xsl:for-each>

              <xsl:apply-templates select="$colspec"/>
            </xsl:for-each>
          </xsl:if>
        </xsl:when>

        <xsl:otherwise>
          <xsl:message
            terminate="yes">Missing or invalid "cols" attribute.</xsl:message>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="./*[contains(@class,' topic/thead ')]"/>
      <xsl:apply-templates select="./*[contains(@class,' topic/tbody ')]"/>
    </table>
  </xsl:template>

  <xsl:function name="u:isSimpleBorderTable" as="xs:boolean">
    <xsl:param name="elem" as="element()"/>

    <xsl:for-each select="$elem">
      <!-- Remember that a table can contain another table. -->
      <xsl:variable name="table"
        select="(ancestor-or-self::*[contains(@class,' topic/table ')])[last()]"/>

      <xsl:choose>
        <xsl:when test="exists($table)">
          <!-- Here generate-id() is just used to key simpleBorderTable. -->
          <xsl:sequence
            select="exists(key('simpleBorderTable', generate-id($table[1])))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <!-- colspec =========================================================== -->

  <xsl:template match="*[contains(@class,' topic/colspec ')]">
    <col>
      <xsl:call-template name="commonAttributes"/>

      <xsl:call-template name="colWidthAttribute"/>

      <!-- col's @align, @char, @charoff are very poorly supported by Web
           browsers.  Therefore we will not generate these attributes
           here. -->

      <xsl:apply-templates/>
    </col>
  </xsl:template>

  <xsl:template name="colWidthAttribute">
    <xsl:if test="exists(@colwidth)">
      <xsl:variable name="length" select="xs:string(@colwidth)"/>

      <xsl:variable name="colwidth">
        <xsl:choose>
          <xsl:when test="contains($length, '*')">
            <!-- No browser seems to support "N*" values. 
                 Convert this relative value to a percentage. -->
            <!-- LIMITATION: colwidth="2*+3pt" is approximated to "2*". -->
            
            <xsl:variable name="prop" select="u:toProportion($length)"/>

            <xsl:variable name="allProps">
              <xsl:call-template name="allProportions"/>
            </xsl:variable>

            <xsl:sequence
              select="concat(round(($prop * 100.0) div $allProps), '%')"/>
          </xsl:when>

          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="ends-with($length, 'pt')">
                <xsl:variable name="value"
                  select="number(substring-before($length, 'pt'))"/>
                <xsl:choose>
                  <xsl:when test="$value gt 0">
                    <xsl:sequence
                        select="round(($value div 72.0) * $screen-resolution)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- Not a number -->
                    <xsl:sequence select="()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>

              <xsl:when test="ends-with($length, 'pi')">
                <xsl:variable name="value"
                  select="number(substring-before($length, 'pi'))"/>
                <xsl:choose>
                  <xsl:when test="$value gt 0">
                    <xsl:sequence
                      select="round(($value div 6.0) * $screen-resolution)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- Not a number -->
                    <xsl:sequence select="()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>

              <xsl:when test="ends-with($length, 'cm')">
                <xsl:variable name="value"
                  select="number(substring-before($length, 'cm'))"/>
                <xsl:choose>
                  <xsl:when test="$value gt 0">
                    <xsl:sequence
                      select="round(($value div 2.54) * $screen-resolution)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- Not a number -->
                    <xsl:sequence select="()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>

              <xsl:when test="ends-with($length, 'mm')">
                <xsl:variable name="value"
                  select="number(substring-before($length, 'mm'))"/>
                <xsl:choose>
                  <xsl:when test="$value gt 0">
                    <xsl:sequence
                      select="round(($value div 25.4) * $screen-resolution)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- Not a number -->
                    <xsl:sequence select="()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>

              <xsl:when test="ends-with($length, 'in')">
                <xsl:variable name="value"
                  select="number(substring-before($length, 'in'))"/>
                <xsl:choose>
                  <xsl:when test="$value gt 0">
                    <xsl:sequence select="round($value * $screen-resolution)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- Not a number -->
                    <xsl:sequence select="()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>

              <xsl:otherwise>
                <xsl:variable name="value" select="number($length)"/>
                <xsl:choose>
                  <xsl:when test="$value gt 0">
                    <!-- Implicit pt -->
                    <xsl:sequence
                      select="round(($value div 72.0) * $screen-resolution)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- Unit not supported -->
                    <xsl:sequence select="()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="exists($colwidth)">
        <xsl:attribute name="width" select="$colwidth"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:function name="u:toProportion">
    <xsl:param name="length" as="xs:string"/>

    <xsl:choose>
      <xsl:when test="contains($length, '*')">
        <!-- Something like: 2*+3pt. Not supported: 3pt+2* -->
        <xsl:variable name="prop"
                      select="normalize-space(substring-before($length, '*'))"/>

        <xsl:choose>
          <xsl:when test="number($prop) gt 0">
            <xsl:sequence select="number($prop)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <!-- This is a gross approximation. -->
        <xsl:sequence select="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template name="allProportions">
    <xsl:variable name="tgroup" select="parent::*"/>
    <xsl:variable name="colspecs" 
      select="$tgroup/*[contains(@class,' topic/colspec ')]"/>

    <xsl:variable name="allProps" 
      select="for $c in $colspecs
              return
                if (exists($c/@colwidth)) 
                then u:toProportion($c/@colwidth)
                else 1"/>

    <!-- @cols already checked by the "tgroup" template. -->
    <xsl:variable name="colCount" select="xs:integer($tgroup/@cols)"/>

    <xsl:sequence select="sum($allProps) + ($colCount - count($colspecs))"/>
  </xsl:template>

  <!-- thead ============================================================ -->

  <xsl:template match="*[contains(@class,' topic/thead ')]">
    <thead>
      <xsl:call-template name="commonAttributes"/>

      <!-- Inherit align attribute from the tgroup parent. -->
      <xsl:for-each select="parent::*">
        <xsl:call-template name="alignAttribute"/>
      </xsl:for-each>
      <xsl:call-template name="valignAttribute"/>

      <xsl:variable name="bodyLayout" select="u:bodyLayout(.)"/>
      <xsl:apply-templates>
        <xsl:with-param name="bodyLayout" select="$bodyLayout"/>
      </xsl:apply-templates>
    </thead>
  </xsl:template>

  <xsl:template name="alignAttribute">
    <!-- align="char" does not seem to be supported by Web browsers. -->
    <xsl:if test="@align">
      <xsl:attribute name="align" select="@align"/>
    </xsl:if>
    <xsl:if test="@char">
      <xsl:attribute name="char" select="@char"/>
    </xsl:if>
    <xsl:if test="@charoff">
      <xsl:attribute name="charoff" select="@charoff"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="valignAttribute">
    <xsl:if test="@valign">
      <xsl:attribute name="valign" select="@valign"/>
    </xsl:if>
  </xsl:template>

  <!-- tbody ============================================================ -->

  <xsl:template match="*[contains(@class,' topic/tbody ')]">
    <tbody>
      <xsl:call-template name="commonAttributes"/>

      <!-- Inherit align attribute from the tgroup parent. -->
      <xsl:for-each select="parent::*">
        <xsl:call-template name="alignAttribute"/>
      </xsl:for-each>
      <xsl:call-template name="valignAttribute"/>

      <xsl:variable name="bodyLayout" select="u:bodyLayout(.)"/>
      <xsl:apply-templates>
        <xsl:with-param name="bodyLayout" select="$bodyLayout"/>
      </xsl:apply-templates>
    </tbody>
  </xsl:template>

  <!-- row =============================================================== -->

  <xsl:template match="*[contains(@class,' topic/row ')]">
    <xsl:param name="bodyLayout" select="()"/>

    <tr>
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
            <td/>
          </xsl:if>
        </xsl:for-each>

        <xsl:call-template name="processEntry">
          <xsl:with-param name="bodyLayout" select="$bodyLayout"/>
        </xsl:call-template>
      </xsl:for-each>
    </tr>
  </xsl:template>

  <!-- entry ============================================================= -->

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
        <th>
          <xsl:call-template name="cellAttributes">
            <xsl:with-param name="classPrefix" select="'header-'"/>
            <xsl:with-param name="bodyLayout" select="$bodyLayout"/>
          </xsl:call-template>
          <xsl:call-template name="namedAnchor"/>
          <xsl:call-template name="processCellContents"/>
        </th>
      </xsl:when>
      <xsl:otherwise>
        <td>
          <xsl:call-template name="cellAttributes">
            <xsl:with-param name="bodyLayout" select="$bodyLayout"/>
          </xsl:call-template>
          <xsl:call-template name="namedAnchor"/>
          <xsl:call-template name="processCellContents"/>
        </td>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="cellAttributes">
    <xsl:param name="classPrefix" select="''"/>
    <xsl:param name="bodyLayout" select="()"/>

    <xsl:call-template name="commonAttributes">
      <xsl:with-param name="classPrefix" select="$classPrefix"/>
    </xsl:call-template>

    <xsl:variable name="colspec" select="u:entryColspec(., $bodyLayout)"/>
    <xsl:choose>
      <xsl:when test="empty(@align) and 
                      exists($colspec) and 
                      exists($colspec/@align)">
        <!-- col's @align, @char, @charoff are very poorly supported by Web
             browsers. Therefore we need to generate these attributes
             here. -->
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

    <xsl:if test="not(u:isSimpleBorderTable(.))">
      <xsl:call-template name="cellSeparAttributes">
        <xsl:with-param name="bodyLayout" select="$bodyLayout"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="cellSpanAttributes">
    <xsl:variable name="rowspan" select="u:entryRowSpan(.)"/>
    <xsl:if test="$rowspan gt 1">
      <xsl:attribute name="rowspan" select="$rowspan"/>
    </xsl:if>

    <xsl:variable name="colspan" select="u:entryColSpan(.)"/>
    <xsl:if test="$colspan gt 1">
      <xsl:attribute name="colspan" select="$colspan"/>
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

    <xsl:variable name="tgroup" 
      select="(ancestor::*[contains(@class,' topic/tgroup ')])[last()]"/>
    <!-- @cols already checked by the "tgroup" template. -->
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

    <xsl:variable name="style">
      <xsl:if test="$rowsep != '0'">
        border-bottom-width: 1px;
        border-bottom-style: solid;
      </xsl:if>
      <xsl:if test="$colsep != '0'">
        border-right-width: 1px;
        border-right-style: solid;
      </xsl:if>
    </xsl:variable>

    <xsl:if test="$style != ''">
      <xsl:attribute name="style" select="normalize-space($style)"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
