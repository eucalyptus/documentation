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
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                xmlns:URI="java:com.xmlmind.ditac.xslt.URI"
                exclude-result-prefixes="xs u ditac URI"
                version="2.0">

  <!-- ``System parameter'' automatically specified by the application hosting
       ditac. -->
  <xsl:param name="ditacListsURI" required="yes"/>
  <xsl:variable name="ditacLists" select="doc($ditacListsURI)/ditac:lists"/>

  <xsl:variable name="title-prefix-separator2" 
                select="u:localize('commaSeparator', $ditacLists)"/>

  <xsl:variable name="index-term-separator"
                select="u:localize('commaSeparator', $ditacLists)"/>
  <xsl:variable name="index-term-see-separator" 
                select="u:localize('periodSeparator', $ditacLists)"/>
  <xsl:variable name="index-hierarchical-term-separator" 
                select="u:localize('commaSeparator', $ditacLists)"/>
  <xsl:variable name="index-see-separator" 
                select="u:localize('semiColonSeparator', $ditacLists)"/>

  <!-- hasIndex ========================================================== -->

  <xsl:function name="u:hasIndex" as="xs:boolean">
    <!-- Non empty indexList and 
         a chunk which contains an index placeholder. -->
    <xsl:sequence
      select="exists($ditacLists/ditac:indexList/*) and 
             exists($ditacLists/ditac:chunkList/ditac:chunk/ditac:indexList)"/>
  </xsl:function>

  <!-- currentChunk ====================================================== -->

  <xsl:function name="u:currentChunk" as="element()">
    <xsl:param name="docURI" as="xs:anyURI"/>

    <xsl:variable name="rootName" select="u:chunkRootName($docURI)"/>

    <xsl:sequence 
      select="$ditacLists/ditac:chunkList/ditac:chunk[u:matchRootName(@file, 
                                                                 $rootName)]"/>
  </xsl:function>

  <xsl:function name="u:chunkRootName" as="xs:string">
    <xsl:param name="docURI" as="xs:anyURI"/>

    <!-- $docURI is something like "file:/tmp/foo.ditac", 
         while chunk/@file is something like "foo.html". -->
    
    <xsl:variable name="baseName" select="u:basename($docURI)"/>

    <xsl:sequence select="substring-before($baseName, '.ditac')"/>
  </xsl:function>

  <xsl:function name="u:matchRootName" as="xs:boolean">
    <xsl:param name="baseName" as="xs:string"/>
    <xsl:param name="rootName" as="xs:string"/>

    <xsl:variable name="ext" select="u:extension($baseName)" />

    <xsl:sequence select="$baseName eq concat($rootName, '.', $ext)" />
  </xsl:function>

  <!-- chunkIndex ======================================================== -->

  <xsl:function name="u:chunkIndex" as="xs:integer">
    <xsl:param name="docURI" as="xs:anyURI"/>

    <xsl:variable name="rootName" select="u:chunkRootName($docURI)"/>

    <xsl:for-each select="$ditacLists/ditac:chunkList/ditac:chunk">
      <xsl:choose>
        <xsl:when test="u:matchRootName(@file, $rootName)">
          <xsl:sequence select="position()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <!-- chunkCount ======================================================== -->

  <xsl:function name="u:chunkCount" as="xs:integer">
    <xsl:sequence select="count($ditacLists/ditac:chunkList/ditac:chunk)"/>
  </xsl:function>

  <!-- joinLinkTarget ==================================================== -->

  <xsl:function name="u:joinLinkTarget" as="xs:string">
    <xsl:param name="file" as="xs:string"/>
    <xsl:param name="id" as="xs:string"/>

    <xsl:sequence select="if (u:chunkCount() gt 1) then
                              concat($file, '#', $id)
                          else
                              concat('#', $id)"/>
  </xsl:function>

  <!-- chunk ============================================================= -->

  <xsl:function name="u:chunk" as="element()">
    <xsl:param name="index" as="xs:integer"/>

    <xsl:sequence select="$ditacLists/ditac:chunkList/ditac:chunk[$index]"/>
  </xsl:function>

  <!-- topicEntry ======================================================== -->

  <xsl:key name="topicEntries" 
           match="ditac:chunkList/ditac:chunk/ditac:topic" use="string(@id)"/>

  <xsl:function name="u:topicEntry" as="element()?">
    <xsl:param name="id" as="xs:string"/>

    <xsl:sequence select="(key('topicEntries', $id, $ditacLists))[1]"/>
  </xsl:function>

  <!-- longChunkTitle ==================================================== -->

  <xsl:function name="u:longChunkTitle" as="xs:string">
    <xsl:param name="chunk" as="element()"/>

    <xsl:variable name="firstChild" select="$chunk/*[1]"/>
    <xsl:variable name="firstChildName" select="local-name($firstChild)"/>

    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="$firstChildName eq 'titlePage'">
          <xsl:value-of select="u:documentTitle()"/>
        </xsl:when>

        <xsl:when test="$firstChildName eq 'topic'">
          <xsl:value-of 
            select="u:autoTitle($firstChild/@title, $chunk)"/>
        </xsl:when>

        <xsl:otherwise>
          <xsl:value-of
            select="u:localize(lower-case($firstChildName), $chunk)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="prefix">
      <xsl:choose>
        <xsl:when test="$firstChildName eq 'topic'">
          <xsl:value-of
            select="u:longTitlePrefix(string($firstChild/@number), $chunk)"/>
        </xsl:when>

        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$prefix ne ''">
        <xsl:sequence 
          select="concat($prefix, $title-prefix-separator1, $title)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$title"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- documentTitle ===================================================== -->

  <xsl:function name="u:documentTitle" as="xs:string">
    <xsl:variable name="title" 
     select="$ditacLists/ditac:titlePage/*[contains(@class,' topic/title ')]"/>

    <xsl:choose>
      <!-- When PreProcess option forceTitlePage is set to true, 
           ditac:titlePage/title may be empty. -->
      <xsl:when test="string($title) ne ''">
        <!-- bookmap/booktitle is a specialization of topic/title. -->
        <xsl:variable name="bookTitle"
          select="$title//*[contains(@class,' bookmap/mainbooktitle ')]"/>

        <xsl:choose>
          <xsl:when test="exists($bookTitle)">
            <xsl:sequence select="normalize-space(string($bookTitle))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="normalize-space(string($title))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <!-- Use the title of the first topic -->
        <xsl:variable name="firstTopic"
          select="$ditacLists/ditac:chunkList/*/ditac:topic[1]"/>
        <xsl:sequence
          select="u:autoTitle($firstTopic/@title, $firstTopic)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- documentLang ====================================================== -->

  <xsl:function name="u:documentLang" as="xs:string">
    <xsl:variable name="lang" select="$ditacLists/@xml:lang"/>
    <xsl:sequence select="if (exists($lang)) then string($lang) else 'en'"/>
  </xsl:function>

  <!-- autoId ============================================================ -->

  <xsl:function name="u:tocEntryAutoId" as="xs:string">
    <xsl:param name="entry" as="element()"/>

    <xsl:sequence select="u:autoId($entry/@id)"/>
  </xsl:function>

  <xsl:param name="tocId" select="'__TOC'"/>
  <xsl:param name="figurelistId" select="'__LOF'"/>
  <xsl:param name="tablelistId" select="'__LOT'"/>
  <xsl:param name="examplelistId" select="'__LOE'"/>
  <xsl:param name="indexlistId" select="'__IDX'"/>

  <xsl:function name="u:autoId" as="xs:string">
    <xsl:param name="id" as="xs:string"/>

    <xsl:variable name="role" select="u:autoTextRole($id)"/>
    <xsl:choose>
      <xsl:when test="$role eq ''">
        <xsl:sequence select="$id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$role eq 'toc'">
            <xsl:sequence select="$tocId"/>
          </xsl:when>
          <xsl:when test="$role eq 'figurelist'">
            <xsl:sequence select="$figurelistId"/>
          </xsl:when>
          <xsl:when test="$role eq 'tablelist'">
            <xsl:sequence select="$tablelistId"/>
          </xsl:when>
          <xsl:when test="$role eq 'examplelist'">
            <xsl:sequence select="$examplelistId"/>
          </xsl:when>
          <xsl:when test="$role eq 'indexlist'">
            <xsl:sequence select="$indexlistId"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="concat('__', upper-case($role))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="u:autoTextRole" as="xs:string">
    <xsl:param name="autoText" as="xs:string"/>
    
    <xsl:sequence select="if (starts-with($autoText, '__AUTO__') and 
                              ends-with($autoText, '__'))
                          then substring($autoText, 9, 
                                         string-length($autoText) - 10)
                          else ''"/>
  </xsl:function>

  <!-- autoTitle ========================================================= -->

  <xsl:function name="u:tocEntryAutoTitle" as="xs:string">
    <xsl:param name="entry" as="element()"/>

    <xsl:sequence select="u:autoTitle($entry/@title, $entry)"/>
  </xsl:function>

  <xsl:function name="u:autoTitle" as="xs:string">
    <xsl:param name="title" as="xs:string"/>
    <xsl:param name="context" as="element()"/>

    <xsl:variable name="role" select="u:autoTextRole($title)"/>
    <xsl:choose>
      <xsl:when test="$role eq ''">
        <xsl:sequence select="$title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="u:localize($role, $context)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- tocEntry ========================================================== -->

  <xsl:key name="tocEntries" 
           match="ditac:toc//ditac:tocEntry" use="string(@id)"/>

  <xsl:function name="u:tocEntry" as="element()?">
    <xsl:param name="id" as="xs:string"/>

    <xsl:sequence select="(key('tocEntries', $id, $ditacLists))[1]"/>
  </xsl:function>

  <!-- shortTOCEntryTitle ================================================ -->

  <xsl:function name="u:shortTOCEntryTitle" as="xs:string">
    <xsl:param name="tocEntry" as="element()"/>

    <xsl:variable name="title" select="u:tocEntryAutoTitle($tocEntry)"/>

    <xsl:variable name="prefix" 
                  select="u:shortTitlePrefix(string($tocEntry/@number),
                                             $tocEntry)"/>

    <xsl:choose>
      <xsl:when test="$prefix ne ''">
        <xsl:sequence
          select="concat($prefix, $title-prefix-separator1, $title)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$title"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- shortTitlePrefix ================================================== -->

  <xsl:function name="u:shortTitlePrefix" as="xs:string">
    <xsl:param name="spec" as="xs:string"/>
    <xsl:param name="context" as="element()"/>
    
    <xsl:variable name="parts" select="u:splitSpec($spec)"/>
    <xsl:variable name="lastPart" select="$parts[last()]"/>

    <xsl:choose>
      <!-- format part|chapter|appendix -->
      <xsl:when test="(starts-with($lastPart, 'part.') and 
                       (index-of($numberList, 'all') ge 1 or 
                        index-of($numberList, 'topic') ge 1 or 
                        index-of($numberList, 'chapter-only') ge 1))
                      or
                      (starts-with($lastPart, 'chapter.') and 
                       (index-of($numberList, 'all') ge 1 or 
                        index-of($numberList, 'topic') ge 1 or 
                        index-of($numberList, 'chapter-only') ge 1))
                      or
                      (starts-with($lastPart, 'appendix.') and 
                       (index-of($numberList, 'all') ge 1 or 
                        index-of($numberList, 'topic') ge 1 or 
                        index-of($numberList, 'chapter-only') ge 1))">
        <xsl:variable name="label" 
                      select="u:localize(substring-before($lastPart, '.'), 
                                         $context)"/>

        <xsl:variable name="num"
                      select="u:formatNumbers($lastPart, $number-separator1)"/>

        <xsl:sequence select="concat($label, '&#xA0;', $num)"/>
      </xsl:when>

      <!-- Format everything after section1. 
           If option prepend-chapter-to-section-number, 
           prepend (chapter|appendix)? -->
      <xsl:when test="((starts-with($lastPart, 'section1.') or 
                        starts-with($lastPart, 'section2.') or 
                        starts-with($lastPart, 'section3.') or 
                        starts-with($lastPart, 'section4.') or 
                        starts-with($lastPart, 'section5.') or 
                        starts-with($lastPart, 'section6.') or 
                        starts-with($lastPart, 'section7.') or 
                        starts-with($lastPart, 'section8.') or 
                        starts-with($lastPart, 'section9.')) and 
                       (index-of($numberList, 'all') ge 1 or 
                        index-of($numberList, 'topic') ge 1))">
        <xsl:variable name="label" select="u:localize('section', $context)"/>

        <xsl:variable name="first"
                      select="for $part in $parts
                              return 
                                  if (starts-with($part, 'section1.')) then
                                      index-of($parts, $part)
                                  else
                                      ()"/>

        <xsl:choose>
          <xsl:when test="$first ge 1">
            <xsl:variable name="from"
              select="if ($prepend-chapter-to-section-number eq 'yes' and
                          $first gt 1 and 
                          (starts-with($parts[$first - 1], 'chapter.') or 
                           starts-with($parts[$first - 1], 'appendix.'))) then
                          $first - 1
                      else
                          $first"/>

            <xsl:variable name="partRange" select="subsequence($parts,$from)"/>
            <xsl:variable name="num"
              select="u:formatNumbers($partRange, $number-separator1)"/>

            <xsl:sequence select="concat($label, '&#xA0;', $num)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="num"
              select="u:formatNumbers($lastPart, $number-separator1)"/>

            <xsl:sequence select="concat($label, '&#xA0;', $num)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- Format (chapter|appendix)? table|figure|example.
           Note that 'all' includes 'table' and 'figure' but not 'example'.  -->
      <xsl:when test="(starts-with($lastPart, 'table.') and 
                       (index-of($numberList, 'all') ge 1 or 
                        index-of($numberList, 'table') ge 1))
                      or
                      (starts-with($lastPart, 'figure.') and 
                       (index-of($numberList, 'all') ge 1 or 
                        index-of($numberList, 'fig') ge 1))
                      or
                      (starts-with($lastPart, 'example.') and 
                       index-of($numberList, 'example') ge 1)">
        <xsl:variable name="label" 
                      select="u:localize(substring-before($lastPart, '.'), 
                                         $context)"/>

        <xsl:variable name="partRange" 
                      select="if (starts-with($parts[1], 'part.')) then 
                                  remove($parts, 1) 
                              else 
                                  $parts"/>
        <xsl:variable name="num"
          select="u:formatNumbers($partRange, $number-separator2)"/>

        <xsl:sequence select="concat($label, '&#xA0;', $num)"/>
      </xsl:when>

      <!-- Examples: preface, glossary, etc, which are never numbered. -->
      <xsl:otherwise>
        <xsl:sequence select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="u:splitSpec" as="xs:string*">
    <xsl:param name="spec" as="xs:string"/>

    <xsl:variable name="parts" select="tokenize($spec, '\s+')"/>

    <!-- There is at most a single appendices element per bookmap.  
         Therefore it does not make sense to number it. -->

    <xsl:sequence select="if ($parts[1] eq 'appendices.1') 
                          then subsequence($parts, 2)
                          else $parts" />
  </xsl:function>

  <xsl:function name="u:formatNumbers" as="xs:string">
    <xsl:param name="parts" as="xs:string*"/>
    <xsl:param name="separator" as="xs:string"/>

    <!-- There is at most a single 'appendices'. It's not numbered.
         ('appendices.1' has already been filtered out from the tocEntry
         number.) -->

    <xsl:variable name="numList" 
      select="for $part in $parts
              return
                  if (substring-before($part, '.') eq 'part') then
                      u:formatNumber(number(substring-after($part, '.')),
                                     $part-number-format)
                  else
                      if (substring-before($part, '.') eq 'appendix') then
                          u:formatNumber(number(substring-after($part, '.')),
                                         $appendix-number-format)
                      else
                          substring-after($part, '.')"/>

    <xsl:sequence select="string-join($numList, $separator)"/>
  </xsl:function>

  <xsl:function name="u:formatNumber" as="xs:string">
    <xsl:param name="number" as="xs:double"/>
    <xsl:param name="format" as="xs:string"/>

    <!-- Works because the text node created by xsl:number is converted to
         xs:string. -->
    <xsl:choose>
      <xsl:when test="$format eq 'a'">
        <xsl:number value="$number" format="a"/>
      </xsl:when>
      <xsl:when test="$format eq 'A'">
        <xsl:number value="$number" format="A"/>
      </xsl:when>
      <xsl:when test="$format eq 'i'">
        <xsl:number value="$number" format="i"/>
      </xsl:when>
      <xsl:when test="$format eq 'I'">
        <xsl:number value="$number" format="I"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:number value="$number" format="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- longTitlePrefix =================================================== -->

  <xsl:function name="u:longTitlePrefix" as="xs:string">
    <xsl:param name="spec" as="xs:string"/>
    <xsl:param name="context" as="element()"/>

    <xsl:sequence select="string-join(u:titlePrefixSegments($spec, $context), 
                                      $title-prefix-separator2)"/>
  </xsl:function>

  <xsl:function name="u:titlePrefixSegments" as="xs:string*">
    <xsl:param name="spec" as="xs:string"/>
    <xsl:param name="context" as="element()"/>
    
    <xsl:variable name="prefix" select="u:shortTitlePrefix($spec, $context)"/>

    <xsl:choose>
      <xsl:when test="$prefix ne ''">
        <xsl:variable name="parts" select="u:splitSpec($spec)"/>
        <xsl:variable name="lastPart" select="$parts[last()]"/>

        <xsl:choose>
          <xsl:when test="starts-with($lastPart, 'section1.') or
                          starts-with($lastPart, 'section2.') or
                          starts-with($lastPart, 'section3.') or
                          starts-with($lastPart, 'section4.') or
                          starts-with($lastPart, 'section5.') or
                          starts-with($lastPart, 'section6.') or
                          starts-with($lastPart, 'section7.') or
                          starts-with($lastPart, 'section8.') or
                          starts-with($lastPart, 'section9.')
                          or
                          starts-with($lastPart, 'figure.') or
                          starts-with($lastPart, 'table.') or
                          starts-with($lastPart, 'example.')">
            <!-- Prepend "Part N, Chapter M" or "Appendix L", if any. -->

            <!-- Notes:
                 * Prepending "Part N, Chapter M" or "Appendix L" to
                   a figure, table or example may be a bit redundant 
                   but at least, it's crystal clear. -->

            <xsl:variable name="end"
                          select="for $part in $parts
                                  return 
                                      if (starts-with($part, 'section1.') or
                                          starts-with($part, 'figure.') or
                                          starts-with($part, 'table.') or
                                          starts-with($part, 'example.')) then
                                          index-of($parts, $part)
                                      else
                                          ()"/>
            <xsl:choose>
              <xsl:when test="$end gt 1">
                <xsl:variable name="partRange" 
                              select="subsequence($parts, 1, $end - 1)"/>

                <xsl:sequence 
                  select="(u:formatSegments($partRange, $context), $prefix)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="$prefix"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <xsl:when test="starts-with($lastPart, 'chapter.') or
                          starts-with($lastPart, 'appendix.')">
            <!-- Prepend "Part N", if any -->
            <xsl:variable name="firstPart" 
                          select="if (starts-with($parts[1], 'part.')) then 
                                      $parts[1]
                                  else 
                                      ()"/>

            <xsl:choose>
              <xsl:when test="exists($firstPart)">
                <xsl:sequence 
                  select="(u:formatSegments($firstPart, $context), $prefix)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="$prefix"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <xsl:otherwise>
            <xsl:sequence select="$prefix"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="u:formatSegments" as="xs:string*">
    <xsl:param name="parts" as="xs:string*"/>
    <xsl:param name="context" as="element()"/>

    <xsl:sequence 
      select="for $part in $parts
              return
                  concat(u:localize(substring-before($part, '.'), $context), 
                         '&#xA0;', 
                         u:formatNumbers($part, $number-separator1))"/>
  </xsl:function>

  <!-- runningSection1Title ============================================== -->

  <xsl:function name="u:runningSection1Title" as="xs:string">
    <xsl:param name="id" as="xs:string"/>

    <xsl:variable name="tocEntry" select="u:tocEntry($id)"/>
    <xsl:choose>
      <xsl:when test="exists($tocEntry)">
        <xsl:variable name="role" select="string($tocEntry/@role)"/>
        <xsl:choose>
          <xsl:when test="$role eq 'part' or
                          $role eq 'chapter' or
                          $role eq 'appendices' or
                          $role eq 'appendix'">
            <xsl:variable name="prefix" 
              select="u:shortTitlePrefix(string($tocEntry/@number),
                                         $tocEntry)"/>
            <xsl:choose>
              <xsl:when test="$prefix ne ''">
                <xsl:sequence select="concat($prefix, $title-prefix-separator1,
                                             u:tocEntryAutoTitle($tocEntry))"/>
              </xsl:when>
              <xsl:otherwise>
                <!-- Not numbered -->
                <xsl:sequence select="u:tocEntryAutoTitle($tocEntry)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <xsl:when test="$role eq 'section1'">
            <xsl:variable name="prefix" 
              select="u:shortTitlePrefix(string($tocEntry/@number),
                                         $tocEntry)"/>
            <xsl:choose>
              <xsl:when test="$prefix ne ''">
                <!-- Do not keep the leading 'Section' -->
                <xsl:value-of 
                  select="concat(substring-after($prefix, '&#xA0;'),
                                 $title-prefix-separator1,
                                 u:tocEntryAutoTitle($tocEntry))"/>
              </xsl:when>
              <xsl:otherwise>
                <!-- Not numbered -->
                <xsl:sequence select="u:tocEntryAutoTitle($tocEntry)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <xsl:otherwise>
            <!-- Not a part, chapter, appendix or section1. -->
            <xsl:sequence select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <!-- Should not happen -->
        <xsl:sequence select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- topicTitleClass =================================================== -->

  <xsl:template name="topicTitleClass">
    <xsl:variable name="topicId" select="../@id"/>
    <xsl:variable name="topicEntry" select="u:topicEntry($topicId)"/>

    <xsl:choose>
      <xsl:when test="exists($topicEntry)">
        <xsl:variable name="role" select="string($topicEntry/@role)"/>
        <xsl:choose>
          <xsl:when test="$role eq 'part' or
                          $role eq 'chapter' or
                          $role eq 'appendices' or
                          $role eq 'appendix' or
                          $role eq 'section1' or
                          $role eq 'section2' or
                          $role eq 'section3' or
                          $role eq 'section4' or
                          $role eq 'section5' or
                          $role eq 'section6' or
                          $role eq 'section7' or
                          $role eq 'section8' or
                          $role eq 'section9' or
                          $role eq 'frontmattersection' or
                          $role eq 'backmattersection' or
                          $role eq 'amendments' or
                          $role eq 'bookabstract' or
                          $role eq 'colophon' or
                          $role eq 'dedication' or
                          $role eq 'draftintro' or
                          $role eq 'preface' or
                          $role eq 'notices' or
                          $role eq 'abbrevlist' or
                          $role eq 'bibliolist' or
                          $role eq 'glossarylist' or
                          $role eq 'trademarklist'">
            <xsl:value-of select="concat($role, '-title')"/>
          </xsl:when>
          <xsl:otherwise>topic-title</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>topic-title</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- titlePrefix ======================================================= -->

  <xsl:template name="titlePrefix">
    <xsl:variable name="parent" select="parent::*"/>
    <xsl:variable name="id" select="string($parent/@id)"/>

    <xsl:if test="$id ne ''">
      <xsl:choose>
        <xsl:when test="contains($parent/@class,' topic/topic ')">
          <xsl:variable name="tocEntry" select="u:tocEntry($id)"/>
          <xsl:if test="exists($tocEntry)">
            <xsl:variable name="prefix" 
                          select="u:shortTitlePrefix(string($tocEntry/@number),
                                                     $tocEntry)"/>
            <xsl:if test="$prefix ne ''">
              <xsl:variable name="role" select="string($tocEntry/@role)"/>
              <xsl:choose>
                <xsl:when test="$role eq 'section1' or
                                $role eq 'section2' or
                                $role eq 'section3' or
                                $role eq 'section4' or
                                $role eq 'section5' or
                                $role eq 'section6' or
                                $role eq 'section7' or
                                $role eq 'section8' or
                                $role eq 'section9'">
                  <!-- Do not keep the leading 'Section' -->
                  <xsl:value-of 
                    select="concat(substring-after($prefix, '&#xA0;'),
                                   $title-prefix-separator1)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat($prefix,
                                               $title-prefix-separator1)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
            <!-- Otherwise, chapters, sections, etc, are not numbered. -->
          </xsl:if>
          <!-- Topics contained in front/backmatter, even if found in the
               extended TOC, are not not numbered. -->
        </xsl:when>

        <xsl:when test="contains($parent/@class,' topic/fig ')">
          <xsl:variable name="figure" 
            select="$ditacLists/ditac:figureList/ditac:figure[@id eq $id]"/>
          <xsl:if test="exists($figure)">
            <xsl:variable name="prefix" 
                          select="u:shortTitlePrefix(string($figure/@number), 
                                                     $figure)"/>
            <xsl:if test="$prefix ne ''">
              <xsl:value-of select="concat($prefix,
                                           $title-prefix-separator1)"/>
            </xsl:if>
            <!-- Otherwise, figure are not numbered. -->
          </xsl:if>
          <!-- Figures having no title are not added to figureList. -->
        </xsl:when>

        <xsl:when test="contains($parent/@class,' topic/table ')">
          <xsl:variable name="table" 
            select="$ditacLists/ditac:tableList/ditac:table[@id eq $id]"/>
          <xsl:if test="exists($table)">
            <xsl:variable name="prefix" 
                          select="u:shortTitlePrefix(string($table/@number),
                                                     $table)"/>
            <xsl:if test="$prefix ne ''">
              <xsl:value-of select="concat($prefix,
                                           $title-prefix-separator1)"/>
            </xsl:if>
            <!-- Otherwise, tables are not numbered. -->
          </xsl:if>
          <!-- Tables having no title are not added to tableList. -->
        </xsl:when>

        <xsl:when test="contains($parent/@class,' topic/example ')">
          <xsl:variable name="example" 
            select="$ditacLists/ditac:exampleList/ditac:example[@id eq $id]"/>
          <xsl:if test="exists($example)">
            <xsl:variable name="prefix" 
                          select="u:shortTitlePrefix(string($example/@number), 
                                                     $example)"/>

            <xsl:if test="$prefix ne ''">
              <xsl:value-of select="concat($prefix,
                                    $title-prefix-separator1)"/>
            </xsl:if>
            <!-- Otherwise, examples are not numbered. -->
          </xsl:if>
          <!-- Examples having no title are not added to exampleList. -->
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- linkPrefix ======================================================== -->

  <xsl:template name="linkPrefix">
    <xsl:variable name="id" select="u:linkTargetId(string(@href))"/>

    <!-- The preprocessor never generates nested topics. -->
    <xsl:variable name="topicId" 
                  select="ancestor::*[contains(@class,' topic/topic ')]/@id"/>
    <xsl:variable name="topicEntry" select="u:tocEntry($topicId)"/>
    <xsl:variable name="topicNumber" 
                  select="if (exists($topicEntry)) then 
                              string($topicEntry/@number) 
                          else 
                              ''"/>

    <xsl:if test="$id ne ''">
      <xsl:variable name="tocEntry" select="u:tocEntry($id)"/>
      <xsl:choose>
        <xsl:when test="exists($tocEntry)">
          <xsl:variable name="prefix" 
            select="u:relativeTitlePrefix(string($tocEntry/@number),
                                          $topicNumber,
                                          $tocEntry)"/>
          <xsl:if test="$prefix ne ''">
            <xsl:value-of select="concat($prefix,
                                         $title-prefix-separator1)"/>
          </xsl:if>
        </xsl:when>

        <xsl:otherwise>
          <xsl:variable name="figure" 
            select="$ditacLists/ditac:figureList/ditac:figure[@id eq $id]"/>
          <xsl:choose>
            <xsl:when test="exists($figure)">
              <xsl:variable name="prefix" 
                select="u:relativeTitlePrefix(string($figure/@number),
                                              $topicNumber,
                                              $figure)"/>
              <xsl:if test="$prefix ne ''">
                <xsl:value-of select="concat($prefix,
                                             $title-prefix-separator1)"/>
              </xsl:if>
            </xsl:when>

            <xsl:otherwise>
              <xsl:variable name="table" 
                select="$ditacLists/ditac:tableList/ditac:table[@id eq $id]"/>
              <xsl:choose>
                <xsl:when test="exists($table)">
                  <xsl:variable name="prefix" 
                    select="u:relativeTitlePrefix(string($table/@number),
                                                  $topicNumber,
                                                  $table)"/>
                  <xsl:if test="$prefix ne ''">
                    <xsl:value-of select="concat($prefix,
                                                 $title-prefix-separator1)"/>
                  </xsl:if>
                </xsl:when>

                <xsl:otherwise>
                  <xsl:variable name="example" 
                    select="$ditacLists/ditac:exampleList/ditac:example[@id eq $id]"/>
                  <xsl:if test="exists($example)">
                    <xsl:variable name="prefix" 
                      select="u:relativeTitlePrefix(string($example/@number),
                                                    $topicNumber,
                                                    $example)"/>
                    <xsl:if test="$prefix ne ''">
                      <xsl:value-of select="concat($prefix,
                                                   $title-prefix-separator1)"/>
                    </xsl:if>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:function name="u:linkTargetId">
    <xsl:param name="href" as="xs:string"/>

    <!-- The preprocessor always appends #flat_id to local links. -->
    <xsl:sequence select="if (contains($href, '#') and 
                              not(contains($href, '/'))) then
                              URI:decodeURI(substring-after($href, '#'))
                          else
                              ''"/>
  </xsl:function>

  <xsl:function name="u:relativeTitlePrefix" as="xs:string">
    <xsl:param name="spec" as="xs:string"/>
    <xsl:param name="baseSpec" as="xs:string"/>
    <xsl:param name="context" as="element()"/>
    
    <xsl:choose>
      <xsl:when test="$baseSpec ne ''">
        <xsl:variable name="prefix" 
                      select="u:shortTitlePrefix($spec, $context)"/>

        <xsl:choose>
          <xsl:when test="$prefix ne ''">
            <xsl:variable name="parts1" select="u:splitSpec($spec)"/>
            <xsl:variable name="parts2" select="u:splitSpec($baseSpec)"/>

            <xsl:variable name="commonList" 
              select="for $p1 in $parts1, $p2 in $parts2
                      return
                          if ($p1 eq $p2 and
                              (starts-with($p1, 'part.') or
                               starts-with($p1, 'chapter.') or 
                               starts-with($p1, 'appendix.'))) then
                              $p1
                          else
                              ()"/>
            <xsl:variable name="common" select="$commonList[last()]"/>

            <xsl:choose>
              <xsl:when test="starts-with($common, 'chapter.') or 
                              starts-with($common, 'appendix.')">
                <!-- It is OK if spec and baseSpec are the same chapter or
                     appendix. -->
                <xsl:sequence select="$prefix"/>
              </xsl:when>

              <xsl:when test="starts-with($common, 'part.')">
                <!-- Discard leading 'Part NNN, ' -->

                <xsl:choose>
                  <xsl:when test="count($parts1) eq 1">
                    <!-- Spec specifies a part. Nothing to discard. -->
                    <xsl:sequence select="$prefix"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:variable name="longPrefix"
                                  select="u:longTitlePrefix($spec, $context)"/>
                    <xsl:sequence 
                        select="substring-after($longPrefix, 
                                                $title-prefix-separator2)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>

              <xsl:otherwise>
                <!-- Fallback. Also happens when spec and/or baseSpec have
                     no part/chapter/appendix at all. -->
                <xsl:sequence select="u:longTitlePrefix($spec, $context)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <xsl:otherwise>
            <xsl:sequence select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <xsl:sequence select="u:longTitlePrefix($spec, $context)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- canFlag =========================================================== -->

  <!-- ===================================================================
       About flaggableBlockElements: these elements are the children of body.
       Notes:
       * parml specializes dl 
       * codeblock, msgblock, screen specialize pre
       * syntaxdiagram, imagemap specialize fig
       * image, foreign, data, data-about, etc, are considered to be inline

       About flaggableInlineElements: these elements are the children of ph.
       Notes:
       * Most omitted elements specialize ph or keyword.
       * Elements such as indexterm, data, unknown, etc, are not rendered.
       * Element fn is neither an inline or a block.
       =================================================================== -->

  <xsl:variable name="flaggableBlockElements" 
                select="'topic/topic', 
                        'topic/p', 
                        'topic/lq', 
                        'topic/note', 
                        'topic/dl', 
                        'topic/ul', 
                        'topic/ol', 
                        'topic/sl', 
                        'topic/pre', 
                        'topic/lines', 
                        'topic/fig', 
                        'topic/object', 
                        'topic/table', 
                        'topic/simpletable', 
                        'topic/section', 
                        'topic/example'"/>
  <xsl:variable name="flaggableInlineElements" 
                select="'topic/ph',
                        'topic/term', 
                        'topic/xref', 
                        'topic/cite', 
                        'topic/q', 
                        'topic/boolean', 
                        'topic/state', 
                        'topic/keyword', 
                        'topic/tm', 
                        'topic/image', 
                        'topic/foreign'"/>

  <xsl:function name="u:canFlag" as="xs:integer">
    <xsl:param name="subject" as="element()"/>

    <xsl:variable name="class" select="tokenize($subject/@class, '\s+')"/>
    <xsl:choose>
      <xsl:when test="u:intersects($flaggableBlockElements, $class)">
        <xsl:sequence select="1"/>
      </xsl:when>
      <xsl:when test="u:intersects($flaggableInlineElements, $class)">
        <xsl:sequence select="2"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="u:intersects" as="xs:boolean">
    <xsl:param name="list1" as="xs:string*"/>
    <xsl:param name="list2" as="xs:string*"/>

    <xsl:variable name="result" select="for $item2 in $list2 
                                        return index-of($list1, $item2)"/>
    <xsl:choose>
      <xsl:when test="empty($result)">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="true()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>

