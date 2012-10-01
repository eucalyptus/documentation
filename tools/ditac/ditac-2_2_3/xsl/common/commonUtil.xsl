<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:Image="java:com.xmlmind.ditac.xslt.Image"
                exclude-result-prefixes="xs u Image"
                version="2.0">

  <!-- basename ========================================================== -->

  <xsl:function name="u:basename" as="xs:string">
    <xsl:param name="path" as="xs:string"/>

    <xsl:sequence select="if ($path != '') then
                              tokenize($path, '/')[last()]
                          else 
                              ''" />
  </xsl:function>

  <!-- extension ========================================================= -->

  <xsl:function name="u:extension" as="xs:string">
    <xsl:param name="path" as="xs:string"/>

    <xsl:variable name="basename" select="u:basename($path)" />

    <xsl:sequence select="if ($basename != '') then
                              tokenize($basename, '\.')[last()]
                          else 
                              ''" />
  </xsl:function>

  <!-- indexOfNode ======================================================= -->

  <xsl:function name="u:indexOfNode" as="xs:integer*">
    <xsl:param name="nodeSequence" as="node()*"/>
    <xsl:param name="searchedNode" as="node()"/>

    <xsl:for-each select="$nodeSequence">
      <xsl:if test=". is $searchedNode">
        <xsl:sequence select="position()"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>

  <!-- classToElementName ================================================ -->

  <xsl:function name="u:classToElementName" as="xs:string">
    <xsl:param name="class" as="xs:string"/>

    <xsl:sequence select="tokenize(normalize-space($class), '/|\s+')[last()]"/>
  </xsl:function>

  <!-- imageWidth ======================================================== -->

  <xsl:template name="imageWidth">
    <xsl:param name="path" select="''"/>

    <xsl:sequence select="Image:getWidth(resolve-uri($path, base-uri()))"/>
  </xsl:template>

  <!-- noteType ========================================================== -->

  <xsl:template name="noteType">
    <xsl:choose>
      <xsl:when test="@type = 'other' and @othertype">
        <xsl:value-of select="normalize-space(@othertype)"/>
      </xsl:when>
      <xsl:when test="@type and @type != 'other'">
        <xsl:value-of select="@type"/>
      </xsl:when>
      <xsl:otherwise>note</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Table processing utilities ======================================== -->

  <xsl:template name="processCellContents">
    <xsl:choose>
      <xsl:when test="exists(./text()|./*)">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>&#xA0;</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="u:entryRowSpan" as="xs:integer">
    <xsl:param name="entry" as="element()"/>

    <xsl:for-each select="$entry">
      <xsl:choose>
        <!-- number() returns NaN instead of raising an error. -->
        <xsl:when test="number(@morerows) gt 0">
          <xsl:sequence select="xs:integer(@morerows) + 1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="u:entryColSpan" as="xs:integer">
    <xsl:param name="entry" as="element()"/>

    <xsl:for-each select="$entry">
      <!-- Remember that a table can contain another table. -->
      <xsl:variable name="tgroup" 
        select="(ancestor::*[contains(@class,' topic/tgroup ')])[last()]"/>
      <xsl:variable name="colspecs" 
        select="$tgroup/*[contains(@class,' topic/colspec ')]"/>

      <xsl:variable name="namest" select="@namest"/>
      <xsl:variable name="nameend" select="@nameend"/>

      <xsl:choose>
        <xsl:when test="exists($colspecs) and 
                        exists($namest) and exists($nameend)">
          <xsl:variable name="colst" 
                        select="($colspecs[./@colname = $namest])[1]"/>
          <xsl:variable name="colend" 
                        select="($colspecs[./@colname = $nameend])[1]"/>
          
          <xsl:choose>
            <xsl:when test="exists($colst) and exists($colend)">
              <xsl:variable name="colnumst" 
                            select="u:colspecNumber($colst)"/>
              <xsl:variable name="colnumend" 
                            select="u:colspecNumber($colend)"/>

              <xsl:choose>
                <xsl:when test="$colnumend gt $colnumst">
                  <xsl:sequence select="$colnumend - $colnumst + 1"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="1"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="u:colspecNumber" as="xs:integer">
    <xsl:param name="colspec" as="element()"/>

    <xsl:for-each select="$colspec">
      <xsl:variable name="previousColspec" 
        select="(preceding-sibling::*[contains(@class,' topic/colspec ')])[last()]"/>

      <xsl:variable name="nextColspecNumber" as="xs:integer">
        <xsl:choose>
          <xsl:when test="exists($previousColspec)">
            <xsl:sequence select="u:colspecNumber($previousColspec) + 1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
        <!-- number() returns NaN instead of raising an error. -->
        <xsl:when test="exists(@colnum) and 
                        (number(@colnum) ge $nextColspecNumber)">
          <xsl:sequence select="xs:integer(@colnum)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$nextColspecNumber"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="u:bodyLayout" as="xs:string*">
    <xsl:param name="body" as="element()"/>

    <xsl:for-each select="$body">
      <xsl:variable name="firstRow" 
                    select="(*[contains(@class,' topic/row ')])[1]"/>
      <xsl:sequence select="if (exists($firstRow))
                            then u:rowLayout($firstRow, 1, ())
                            else ()"/>
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="u:rowLayout" as="xs:string*">
    <xsl:param name="row" as="element()"/>
    <xsl:param name="rowIndex" as="xs:integer"/>
    <xsl:param name="bodyLayout" as="xs:string*"/>

    <xsl:for-each select="$row">
      <xsl:variable name="firstEntry" 
                    select="(*[contains(@class,' topic/entry ')])[1]"/>
      <xsl:variable name="bodyLayout2" 
        select="if (exists($firstEntry))
                then u:entryLayout($firstEntry, $rowIndex, $bodyLayout)
                else ()"/>

      <xsl:variable name="nextRow" 
        select="(following-sibling::*[contains(@class,' topic/row ')])[1]"/>
      <xsl:choose>
        <xsl:when test="exists($nextRow)">
          <xsl:sequence
            select="u:rowLayout($nextRow, $rowIndex + 1, $bodyLayout2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$bodyLayout2"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="u:entryLayout" as="xs:string*">
    <xsl:param name="entry" as="element()"/>
    <xsl:param name="rowIndex" as="xs:integer"/>
    <xsl:param name="bodyLayout" as="xs:string*"/>

    <xsl:for-each select="$entry">
      <xsl:variable name="id" select="generate-id($entry)"/>
      <xsl:variable name="rowSpan" select="u:entryRowSpan($entry)"/>
      <xsl:variable name="colSpan" select="u:entryColSpan($entry)"/>

      <xsl:variable name="explicitColspec" select="u:entryColspec(., ())"/>
      <xsl:variable name="colIndex" as="xs:integer">
        <xsl:choose>
          <xsl:when test="exists($explicitColspec)">
            <xsl:sequence select="u:colspecNumber($explicitColspec)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="previousEntry" 
              select="(preceding-sibling::*[contains(@class,' topic/entry ')])[last()]"/>
            <xsl:variable name="colIndex0" 
              select="if (exists($previousEntry))
                      then (u:entryEndColumn($previousEntry, $bodyLayout) + 1)
                      else 1"/>

            <xsl:sequence
              select="u:nextFreeColIndex($bodyLayout, $rowIndex, $colIndex0)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="added"
        select="for $r in ($rowIndex to ($rowIndex + $rowSpan - 1))
                return
                  for $c in ($colIndex to ($colIndex + $colSpan - 1))
                  return concat($id, '_', $r, '_', $c)"/>

      <xsl:variable name="bodyLayout2" select="($bodyLayout, $added)"/>

      <xsl:variable name="nextEntry" 
        select="(following-sibling::*[contains(@class,' topic/entry ')])[1]"/>
      <xsl:choose>
        <xsl:when test="exists($nextEntry)">
          <xsl:sequence
            select="u:entryLayout($nextEntry, $rowIndex, $bodyLayout2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$bodyLayout2"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="u:nextFreeColIndex" as="xs:integer">
    <xsl:param name="bodyLayout" as="xs:string*"/>
    <xsl:param name="rowIndex" as="xs:integer"/>
    <xsl:param name="colIndex" as="xs:integer"/>

    <xsl:variable name="tail"
                  select="concat('_', $rowIndex, '_', $colIndex)"/>
    <xsl:variable name="match" 
                  select="for $s in $bodyLayout
                          return
                            if (ends-with($s, $tail))
                            then $s
                            else ()"/>

    <xsl:sequence
      select="if (exists($match))
              then u:nextFreeColIndex($bodyLayout, $rowIndex, $colIndex + 1)
              else $colIndex"/>
  </xsl:function>

  <xsl:function name="u:bodyLayoutContains" as="xs:boolean">
    <xsl:param name="bodyLayout" as="xs:string*"/>
    <xsl:param name="rowIndex" as="xs:integer"/>
    <xsl:param name="colIndex" as="xs:integer"/>

    <xsl:variable name="tail"
                  select="concat('_', $rowIndex, '_', $colIndex)"/>
    <xsl:variable name="match" 
                  select="for $s in $bodyLayout
                          return
                            if (ends-with($s, $tail))
                            then $s
                            else ()"/>

    <xsl:sequence select="exists($match)"/>
  </xsl:function>

  <xsl:function name="u:entryStartColumn" as="xs:integer">
    <xsl:param name="entry" as="element()"/>
    <xsl:param name="bodyLayout" as="xs:string*"/>

    <xsl:sequence select="u:entryColumn($entry, $bodyLayout, false())"/>
  </xsl:function>

  <xsl:function name="u:entryEndColumn" as="xs:integer">
    <xsl:param name="entry" as="element()"/>
    <xsl:param name="bodyLayout" as="xs:string*"/>

    <xsl:sequence select="u:entryColumn($entry, $bodyLayout, true())"/>
  </xsl:function>

  <xsl:function name="u:entryColumn" as="xs:integer">
    <xsl:param name="entry" as="element()"/>
    <xsl:param name="bodyLayout" as="xs:string*"/>
    <xsl:param name="isEndColumn" as="xs:boolean"/>

    <xsl:variable name="id" select="generate-id($entry)"/>
    <xsl:variable name="head" select="concat($id, '_')"/>
    <xsl:variable name="cols" as="xs:integer*"
                  select="for $s in $bodyLayout
                          return
                            if (starts-with($s, $head))
                            then u:parseEntryColumn($s)
                            else ()"/>

    <xsl:variable name="uniqueCols" select="distinct-values($cols)"/>
    <xsl:variable name="sortedCols" as="xs:integer*">
      <xsl:choose>
        <xsl:when test="count($uniqueCols) gt 1">
          <xsl:perform-sort select="$uniqueCols">
            <xsl:sort select="." data-type="number"/>
          </xsl:perform-sort>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$uniqueCols"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="empty($sortedCols)">
        <xsl:message
          terminate="yes">Internal error in u:entryColumn().</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$isEndColumn">
            <xsl:sequence select="$sortedCols[last()]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$sortedCols[1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="u:parseEntryColumn" as="xs:integer">
    <xsl:param name="spec" as="xs:string"/>

    <xsl:variable name="split" select="tokenize($spec, '_')"/>
    <xsl:sequence select="xs:integer($split[3])"/>
  </xsl:function>

  <xsl:function name="u:entryColspec" as="element()?">
    <xsl:param name="entry" as="element()"/>
    <xsl:param name="bodyLayout" as="xs:string*"/>

    <xsl:for-each select="$entry">
      <!-- Remember that a table can contain another table. -->
      <xsl:variable name="tgroup" 
        select="(ancestor::*[contains(@class,' topic/tgroup ')])[last()]"/>
      <xsl:variable name="colspecs" 
                    select="$tgroup/*[contains(@class,' topic/colspec ')]"/>

      <xsl:choose>
        <xsl:when test="exists($colspecs)">
          <xsl:variable name="colname" select="@colname"/>
          <xsl:variable name="namest" select="@namest"/>

          <xsl:choose>
            <xsl:when test="exists($colname)">
              <xsl:sequence select="($colspecs[./@colname = $colname])[1]"/>
            </xsl:when>
            <xsl:when test="exists($namest)">
              <xsl:sequence select="($colspecs[./@colname = $namest][1])"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="count($bodyLayout) gt 0">
                  <xsl:variable name="startColumn" 
                    select="u:entryStartColumn($entry, $bodyLayout)"/>
                  <xsl:sequence
                      select="for $colspec in $colspecs
                              return
                                if (u:colspecNumber($colspec) eq $startColumn)
                                then $colspec
                                else ()"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="()"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <xsl:otherwise>
          <xsl:sequence select="()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <!-- localize ========================================================== -->

  <xsl:param name="messageFileNames"
             select="'en', 'fr', 'de', 'es', 'ru', 'cs'"/>

  <xsl:template name="localize">
    <xsl:param name="message" select="''"/>

    <xsl:variable name="lang">
      <xsl:call-template name="lang"/>
    </xsl:variable>

    <xsl:variable name="messageFileName">
      <xsl:choose>
        <xsl:when test="index-of($messageFileNames, $lang) ge 1">
          <xsl:value-of select="$lang"/>
        </xsl:when>
        <xsl:otherwise>en</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="messageFile"
                  select="concat('messages/', $messageFileName, '.xml')"/>

    <!-- Hope that documents loaded using document() are cached. -->
    <xsl:variable name="messages"
                  select="document($messageFile)/messages"/>

    <xsl:choose>
      <xsl:when test="$messages/message[@name=$message]">
        <xsl:value-of select="string($messages/message[@name=$message])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$message"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="lang">
    <xsl:variable name="lang"
      select="lower-case(if (ancestor-or-self::*/@xml:lang) then 
                             string((ancestor-or-self::*/@xml:lang)[last()])
                         else 
                             'en')"/>
    
    <xsl:choose>
      <xsl:when test="contains($lang, '-')">
        <xsl:value-of select="substring-before($lang, '-')"/>
      </xsl:when>
      <xsl:when test="contains($lang, '_')">
        <xsl:value-of select="substring-before($lang, '_')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$lang"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Function variant -->

  <xsl:function name="u:localize" as="xs:string">
    <xsl:param name="message" as="xs:string"/>
    <xsl:param name="context" as="element()"/>

    <xsl:for-each select="$context">
      <xsl:call-template name="localize">
        <xsl:with-param name="message" select="$message"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:function>

</xsl:stylesheet>
