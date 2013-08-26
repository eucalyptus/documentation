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
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs u ditac"
                version="2.0">
  
  <!-- p ================================================================= -->

  <xsl:attribute-set name="p" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/p ')]">
    <fo:block xsl:use-attribute-sets="p">
      <xsl:if test="$foProcessor eq 'XEP' and
                    parent::*[contains(@class,' topic/li ')] and
                    empty(following-sibling::*)">
        <!-- Minimal workaround for implementation limit in XEP:
             space-after.conditionality="discard" is not implemented,
             fallback value is "retain".
             space-after each paragraph is stacked instead of being 
             overlapped. As a result, there is much too space between 
             list items. 
             There is no such problem with FOP or XFC. -->
        <xsl:attribute name="space-after.optimum">0em</xsl:attribute>
        <xsl:attribute name="space-after.minimum">0em</xsl:attribute>
        <xsl:attribute name="space-after.maximum">0em</xsl:attribute>
      </xsl:if>

      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- note ============================================================== -->

  <xsl:attribute-set name="note" use-attribute-sets="display-style">
    <xsl:attribute name="font-size">90%</xsl:attribute>
    <xsl:attribute name="margin-left">4em</xsl:attribute>
    <xsl:attribute name="margin-right">4em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="note-with-icon">
    <xsl:attribute name="provisional-label-separation">0.5em</xsl:attribute>
    <xsl:attribute name="provisional-distance-between-starts"
                   select="if ($note-icon-width ne '') then
                               concat(u:checkLength($note-icon-width), 
                                      ' + 0.5em')
                           else 
                               '32px + 0.5em'" />
  </xsl:attribute-set>

  <xsl:attribute-set name="note-head">
    <xsl:attribute name="font-size">larger</xsl:attribute>
    <xsl:attribute name="font-family">sans-serif</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="hyphenate">false</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0.5em</xsl:attribute>
    <xsl:attribute name="space-after.minimum">0.4em</xsl:attribute>
    <xsl:attribute name="space-after.maximum">0.6em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="note-body">
  </xsl:attribute-set>

  <xsl:attribute-set name="note-icon">
    <xsl:attribute name="padding-right">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="note-text">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/note ')]">
    <xsl:variable name="type">
      <xsl:call-template name="noteType"/>
    </xsl:variable>

    <xsl:variable name="label">
      <xsl:call-template name="localize">
        <xsl:with-param name="message" select="$type"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="icon">
      <xsl:if test="$use-note-icon eq 'yes' and
                    index-of($noteIconList, $type) ge 1">
        <fo:external-graphic>
          <xsl:attribute name="src" select="concat('url(', $xslResourcesDir, 
                                                   $type, $note-icon-suffix, 
                                                   ')')"/>
          <xsl:if test="$note-icon-width ne ''">
            <xsl:attribute name="content-width"
                           select="u:checkLength($note-icon-width)"/>
          </xsl:if>
          <xsl:if test="$note-icon-height ne ''">
            <xsl:attribute name="content-height" 
                           select="u:checkLength($note-icon-height)"/>
          </xsl:if>
          <xsl:attribute name="role" select="$label"/>
        </fo:external-graphic>
      </xsl:if>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$icon/* instance of element()">
        <xsl:choose>
          <xsl:when test="$foProcessor eq 'XFC'">
            <!-- XFC does not sypport list-item/@relative-align. -->
            <fo:table xsl:use-attribute-sets="note" table-layout="auto">
              <fo:table-body>
                <fo:table-row>
                  <fo:table-cell start-indent="0" 
                                 xsl:use-attribute-sets="note-icon">
                    <fo:block>
                      <xsl:copy-of select="$icon"/>
                    </fo:block>
                  </fo:table-cell>

                  <fo:table-cell start-indent="0" 
                                 xsl:use-attribute-sets="note-text">
                    <fo:block xsl:use-attribute-sets="note-head">
                      <xsl:value-of select="$label" />
                    </fo:block>

                    <fo:block xsl:use-attribute-sets="note-body">
                      <xsl:apply-templates/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-body>
            </fo:table>
          </xsl:when>

          <xsl:otherwise>
            <fo:list-block xsl:use-attribute-sets="note note-with-icon">
              <xsl:call-template name="commonAttributes"/>

              <fo:list-item relative-align="before">
                <fo:list-item-label end-indent="label-end()">
                  <fo:block text-align="end">
                    <xsl:copy-of select="$icon"/>
                  </fo:block>
                </fo:list-item-label>

                <fo:list-item-body start-indent="body-start()">
                  <fo:block xsl:use-attribute-sets="note-head">
                    <xsl:value-of select="$label" />
                  </fo:block>

                  <fo:block xsl:use-attribute-sets="note-body">
                    <xsl:apply-templates/>
                  </fo:block>
                </fo:list-item-body>
              </fo:list-item>
            </fo:list-block>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="note">
          <xsl:call-template name="commonAttributes"/>

          <fo:block xsl:use-attribute-sets="note-head">
            <xsl:value-of select="$label" />
          </fo:block>

          <fo:block xsl:use-attribute-sets="note-body">
            <xsl:apply-templates/>
          </fo:block>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- text ================================================================ -->

  <xsl:attribute-set name="text">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/text ')]">
    <fo:inline xsl:use-attribute-sets="text">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- ph ================================================================ -->

  <xsl:attribute-set name="ph">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/ph ')]">
    <fo:inline xsl:use-attribute-sets="ph">
      <xsl:call-template name="commonAttributes"/>
      <!-- ph, cite, keyword, dt and term: the preprocessor may have converted 
           @keyref to @href. -->
      <xsl:call-template name="basicLink">
        <xsl:with-param name="href" select="string(@href)"/>
      </xsl:call-template>
    </fo:inline>
  </xsl:template>

  <!-- cite ============================================================== -->

  <xsl:attribute-set name="cite">
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/cite ')]">
    <fo:inline xsl:use-attribute-sets="cite">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="basicLink">
        <xsl:with-param name="href" select="string(@href)"/>
      </xsl:call-template>
    </fo:inline>
  </xsl:template>

  <!-- term ============================================================== -->

  <xsl:attribute-set name="term">
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/term ')]">
    <fo:inline xsl:use-attribute-sets="term">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="basicLink">
        <xsl:with-param name="href" select="string(@href)"/>
      </xsl:call-template>
    </fo:inline>
  </xsl:template>

  <!-- keyword =========================================================== -->

  <xsl:attribute-set name="keyword">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/keyword ')]">
    <fo:inline xsl:use-attribute-sets="keyword">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="basicLink">
        <xsl:with-param name="href" select="string(@href)"/>
      </xsl:call-template>
    </fo:inline>
  </xsl:template>

  <!-- xref ============================================================== -->

  <xsl:attribute-set name="xref" use-attribute-sets="link-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/xref ')]">
    <xsl:choose>
      <xsl:when test="@type eq 'fn'">
        <!-- Not an actual xref. An instance of a footnote. -->

        <!-- A .ditac file contains flattened, unique IDs. -->
        <xsl:variable name="id" select="substring-after(@href, '#')"/>

        <xsl:variable name="footnote"
          select="//*[contains(@class,' topic/fn ') and @id eq $id]"/>

        <xsl:choose>
          <xsl:when test="exists($footnote)">
            <xsl:choose>
              <xsl:when test="key('footnoteXref', $id)[1] is .">
                <!-- First reference to the footnote -->
                <fo:footnote>
                  <xsl:call-template name="footnoteCallout">
                    <xsl:with-param name="footnote" select="$footnote[1]"/>
                  </xsl:call-template>

                  <xsl:call-template name="footnoteBody">
                    <xsl:with-param name="footnote" select="$footnote[1]"/>
                  </xsl:call-template>
                </fo:footnote>
              </xsl:when>

              <xsl:otherwise>
                <!-- Other reference to the footnote.
                     Not necessarily on the same page, so use a link. -->
                <fo:basic-link internal-destination="{$id}">
                  <xsl:call-template name="footnoteCallout">
                    <xsl:with-param name="footnote" select="$footnote[1]"/>
                  </xsl:call-template>
                </fo:basic-link>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <xsl:otherwise>
            <fo:inline xsl:use-attribute-sets="fn-callout">???</fo:inline>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name="href">
          <xsl:call-template name="resolveExternalHref"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$href ne ''">
            <fo:basic-link xsl:use-attribute-sets="xref">
              <xsl:call-template name="linkDestination">
                <xsl:with-param name="href" select="$href"/>
              </xsl:call-template>
              <xsl:call-template name="commonAttributes"/>

              <xsl:call-template name="linkText">
                <xsl:with-param name="text">
                  <xsl:apply-templates/>
                </xsl:with-param>
                <xsl:with-param name="autoText" select="$xrefAutoText"/>
              </xsl:call-template>
            </fo:basic-link>
          </xsl:when>
          <xsl:otherwise>
            <fo:inline> <!-- No attribute-sets. -->
              <xsl:call-template name="commonAttributes"/>
              <xsl:apply-templates/>
            </fo:inline>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:attribute-set name="fn-callout">
    <xsl:attribute name="baseline-shift">super</xsl:attribute>
    <xsl:attribute name="font-size">smaller</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template name="footnoteCallout">
    <xsl:param name="footnote" select="''"/>

    <fo:inline xsl:use-attribute-sets="fn-callout">
      <xsl:choose>
        <xsl:when test="$footnote/@callout">
          <xsl:value-of select="$footnote/@callout"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number count="//*[contains(@class,' topic/fn ')]"
                      level="any" format="(1)" select="$footnote"/>
        </xsl:otherwise>
      </xsl:choose>
    </fo:inline>
  </xsl:template>

  <xsl:attribute-set name="fn-container"
                     use-attribute-sets="compact-block-style">
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="font-style">normal</xsl:attribute>
    <xsl:attribute
        name="provisional-distance-between-starts">2em</xsl:attribute>
    <xsl:attribute name="provisional-label-separation">0.1em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="fn-body">
    <xsl:attribute name="font-size">smaller</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template name="footnoteBody">
    <xsl:param name="footnote" select="''"/>

    <fo:footnote-body start-indent="0">
      <fo:list-block xsl:use-attribute-sets="fn-container">
        <fo:list-item relative-align="baseline">
          <fo:list-item-label end-indent="label-end()">
            <fo:block text-align="end">
              <xsl:text>&#xA0;</xsl:text>
              <xsl:call-template name="footnoteCallout">
                <xsl:with-param name="footnote" select="$footnote"/>
              </xsl:call-template>
            </fo:block>
          </fo:list-item-label>

          <fo:list-item-body start-indent="body-start()">
            <fo:block xsl:use-attribute-sets="fn-body">
              <xsl:for-each select="$footnote">
                <xsl:call-template name="commonAttributes2"/>
              </xsl:for-each>

              <xsl:apply-templates select="$footnote/node()"/>
            </fo:block>
          </fo:list-item-body>
        </fo:list-item>
      </fo:list-block>
    </fo:footnote-body>
  </xsl:template>

  <!-- ol ================================================================ -->

  <xsl:attribute-set name="ol" use-attribute-sets="block-style">
    <xsl:attribute
        name="provisional-distance-between-starts">2em</xsl:attribute>
    <xsl:attribute name="provisional-label-separation">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/ol ')]">
    <fo:list-block xsl:use-attribute-sets="ol">
      <xsl:call-template name="xfcOLLabelFormat"/>

      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:list-block>
  </xsl:template>

  <xsl:template name="xfcOLLabelFormat">
    <xsl:param name="format" select="'1.'"/>

    <xsl:if test="$foProcessor eq 'XFC'">
      <xsl:variable name="olType">
        <xsl:choose>
          <xsl:when test="starts-with($format, 'a')">lower-alpha</xsl:when>
          <xsl:when test="starts-with($format, 'A')">upper-alpha</xsl:when>
          <xsl:when test="starts-with($format, 'i')">lower-roman</xsl:when>
          <xsl:when test="starts-with($format, 'I')">upper-roman</xsl:when>
          <xsl:otherwise>decimal</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:attribute name="xfc:label-format" 
                     select="concat('%{', $olType, '}.')"/>
    </xsl:if>
  </xsl:template>

  <!-- ul ================================================================ -->

  <xsl:attribute-set name="ul" use-attribute-sets="block-style">
    <xsl:attribute
        name="provisional-distance-between-starts">2em</xsl:attribute>
    <xsl:attribute name="provisional-label-separation">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/ul ')]">
    <fo:list-block xsl:use-attribute-sets="ul">
      <xsl:call-template name="xfcULLabelFormat"/>

      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:list-block>
  </xsl:template>

  <xsl:template name="xfcULLabelFormat">
    <xsl:param name="class" select="' topic/ul '"/>
    <xsl:param name="bullets" select="$ulLiBullets"/>

    <xsl:if test="$foProcessor eq 'XFC'">
      <xsl:variable name="nesting"
        select="count(ancestor::*[contains(@class,$class)])"/>
      <xsl:variable name="bullet" 
        select="$bullets[1 + ($nesting mod count($bullets))]"/>

      <xsl:attribute name="xfc:label-format" select="$bullet"/>
    </xsl:if>
  </xsl:template>

  <!-- li ================================================================ -->

  <xsl:attribute-set name="li" use-attribute-sets="block-style">
    <xsl:attribute name="relative-align">baseline</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="ol-li" use-attribute-sets="li">
  </xsl:attribute-set>

  <xsl:attribute-set name="compact-ol-li"
                     use-attribute-sets="ol-li compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="ol-li-label">
    <xsl:attribute name="text-align">end</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="ul-li" use-attribute-sets="li">
  </xsl:attribute-set>

  <xsl:attribute-set name="compact-ul-li"
                     use-attribute-sets="ul-li compact-block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="ul-li-label">
    <xsl:attribute name="text-align">end</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/ol ')]/*[contains(@class,' topic/li ')]">
    <xsl:choose>
      <xsl:when test="parent::*/@compact eq 'yes'">
        <fo:list-item xsl:use-attribute-sets="compact-ol-li">
          <xsl:call-template name="orderedListItem"/>
        </fo:list-item>
      </xsl:when>
      <xsl:otherwise>
        <fo:list-item xsl:use-attribute-sets="ol-li">
          <xsl:call-template name="orderedListItem"/>
        </fo:list-item>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="orderedListItem">
    <xsl:param name="format" select="'1.'"/>

    <xsl:call-template name="commonAttributes"/>

    <fo:list-item-label end-indent="label-end()">
      <xsl:choose>
        <xsl:when test="self::*[contains(@class,' task/step ')]">
          <fo:block xsl:use-attribute-sets="step-label">
            <xsl:number format="{$format}"/>
          </fo:block>
        </xsl:when>
        <xsl:when test="self::*[contains(@class,' task/substep ')]">
          <fo:block xsl:use-attribute-sets="substep-label">
            <xsl:number format="{$format}"/>
          </fo:block>
        </xsl:when>
        <xsl:otherwise>
          <fo:block xsl:use-attribute-sets="ol-li-label">
            <xsl:number format="{$format}"/>
          </fo:block>
        </xsl:otherwise>
      </xsl:choose>
    </fo:list-item-label>

    <fo:list-item-body start-indent="body-start()">
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:list-item-body>
  </xsl:template>

  <xsl:template match="*[contains(@class,' topic/ul ')]/*[contains(@class,' topic/li ')]">
    <xsl:choose>
      <xsl:when test="parent::*/@compact eq 'yes'">
        <fo:list-item xsl:use-attribute-sets="compact-ul-li">
          <xsl:call-template name="listItem"/>
        </fo:list-item>
      </xsl:when>
      <xsl:otherwise>
        <fo:list-item xsl:use-attribute-sets="ul-li">
          <xsl:call-template name="listItem"/>
        </fo:list-item>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="listItem">
    <xsl:param name="class" select="' topic/ul '"/>
    <xsl:param name="bullets" select="$ulLiBullets"/>

    <xsl:call-template name="commonAttributes"/>

    <xsl:variable name="nesting"
      select="count(ancestor::*[contains(@class,$class)]) - 1"/>
    <xsl:variable name="bullet" 
      select="$bullets[1 + ($nesting mod count($bullets))]"/>

    <fo:list-item-label end-indent="label-end()">
      <xsl:choose>
        <xsl:when test="self::*[contains(@class,' task/step ')]">
          <fo:block xsl:use-attribute-sets="unordered-step-label">
            <xsl:value-of select="$bullet"/>
          </fo:block>
        </xsl:when>
        <xsl:when test="self::*[contains(@class,' task/choice ')]">
          <fo:block xsl:use-attribute-sets="choice-label">
            <xsl:value-of select="$bullet"/>
          </fo:block>
        </xsl:when>
        <xsl:otherwise>
          <fo:block xsl:use-attribute-sets="ul-li-label">
            <xsl:value-of select="$bullet"/>
          </fo:block>
        </xsl:otherwise>
      </xsl:choose>
    </fo:list-item-label>

    <fo:list-item-body start-indent="body-start()">
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:list-item-body>
  </xsl:template>

  <!-- sl ================================================================ -->

  <xsl:attribute-set name="sl" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/sl ')]">
    <fo:block xsl:use-attribute-sets="sl">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- sli =============================================================== -->

  <xsl:attribute-set name="sli" use-attribute-sets="block-style">
    <xsl:attribute name="margin-left">2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="compact-sli"
                     use-attribute-sets="sli compact-block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/sli ')]">
    <xsl:choose>
      <xsl:when test="parent::*/@compact eq 'yes'">
        <fo:block xsl:use-attribute-sets="compact-sli">
          <xsl:call-template name="commonAttributes"/>
          <xsl:apply-templates/>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="sli">
          <xsl:call-template name="commonAttributes"/>
          <xsl:apply-templates/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- dl ================================================================ -->

  <xsl:attribute-set name="tabular-dl" use-attribute-sets="block-style">
    <xsl:attribute name="border-top">0.5pt solid #C0C0C0</xsl:attribute>
    <xsl:attribute name="border-bottom">0.5pt solid #C0C0C0</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="tabular-dl-head-row">
    <xsl:attribute name="font-family">sans-serif</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="background-color">#E0E0E0</xsl:attribute>
    <xsl:attribute name="border-bottom">0.5pt solid #C0C0C0</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="tabular-dl-head-cell">
    <xsl:attribute name="padding">0.2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="tabular-dl-row">
  </xsl:attribute-set>

  <xsl:attribute-set name="tabular-dl-cell">
    <xsl:attribute name="padding">0.2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="dl" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/dl ')]">
    <xsl:choose>
      <xsl:when test="./*[contains(@class,' topic/dlhead ')]">
        <fo:table xsl:use-attribute-sets="tabular-dl">
          <xsl:call-template name="twoColumns"/>

          <xsl:call-template name="commonAttributes"/>

          <fo:table-header>
            <xsl:for-each select="./*[contains(@class,' topic/dlhead ')]">
              <fo:table-row xsl:use-attribute-sets="tabular-dl-head-row">
                <xsl:call-template name="commonAttributes"/>

                <xsl:for-each select="./*">
                  <fo:table-cell start-indent="0"
                      xsl:use-attribute-sets="tabular-dl-head-cell">
                    <xsl:call-template name="commonAttributes"/>
                    <fo:block>
                      <xsl:apply-templates/>
                    </fo:block>
                  </fo:table-cell>
                </xsl:for-each>
              </fo:table-row>
            </xsl:for-each>
          </fo:table-header>

          <fo:table-body>
            <xsl:for-each select="./*[contains(@class,' topic/dlentry ')]">
              <fo:table-row xsl:use-attribute-sets="tabular-dl-row">
                <xsl:call-template name="commonAttributes"/>

                <xsl:for-each select="./*">
                  <fo:table-cell start-indent="0"
                                 xsl:use-attribute-sets="tabular-dl-cell">
                    <xsl:call-template name="commonAttributes"/>
                    <fo:block>
                      <xsl:apply-templates/>
                    </fo:block>
                  </fo:table-cell>
                </xsl:for-each>
              </fo:table-row>
            </xsl:for-each>
          </fo:table-body>
        </fo:table>
      </xsl:when>

      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="dl">
          <xsl:call-template name="commonAttributes"/>
          <xsl:apply-templates/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="twoColumns">
    <xsl:param name="width1">1</xsl:param>
    <xsl:param name="width2">1</xsl:param>

    <xsl:choose>
      <xsl:when test="$foProcessor eq 'FOP'">
        <!-- FOP does not support table-layout=auto. -->
        <xsl:attribute name="table-layout">fixed</xsl:attribute>
        <xsl:attribute name="width">100%</xsl:attribute>

        <fo:table-column column-number="1" 
                         column-width="proportional-column-width({$width1})"/>
        <fo:table-column column-number="2" 
                         column-width="proportional-column-width({$width2})"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:attribute name="table-layout">auto</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- dlentry =========================================================== -->

  <xsl:attribute-set name="dlentry" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="compact-dlentry"
                     use-attribute-sets="dlentry compact-block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/dlentry ')]">
    <xsl:choose>
      <xsl:when test="parent::*/@compact eq 'yes'">
        <fo:block xsl:use-attribute-sets="compact-dlentry">
          <xsl:call-template name="commonAttributes"/>
          <xsl:apply-templates/>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="dlentry">
          <xsl:call-template name="commonAttributes"/>
          <xsl:apply-templates/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- dt ================================================================ -->

  <xsl:attribute-set name="dt">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/dt ')]">
    <fo:block xsl:use-attribute-sets="dt">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="basicLink">
        <xsl:with-param name="href" select="string(@href)"/>
      </xsl:call-template>
    </fo:block>
  </xsl:template>

  <!-- dd ================================================================ -->

  <xsl:attribute-set name="dd">
    <xsl:attribute name="margin-left">4em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/dd ')]">
    <fo:block xsl:use-attribute-sets="dd">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- fig =============================================================== -->

  <xsl:attribute-set name="fig" use-attribute-sets="display-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="fig-contents"
                     use-attribute-sets="split-border-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/fig ')]">
    <fo:block xsl:use-attribute-sets="fig">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="processFig"/>
    </fo:block>
  </xsl:template>

  <xsl:template name="processFig">
    <xsl:variable name="title" select="./*[contains(@class,' topic/title ')]"/>

    <xsl:choose>
      <xsl:when test="$title">
        <!-- Display attributes do not apply to the title. -->
        <xsl:choose>
          <xsl:when
            test="index-of($titleAfterList,u:classToElementName(@class)) ge 1">
            <fo:block xsl:use-attribute-sets="fig-contents">
              <xsl:call-template name="displayAttributes"/>
              <xsl:apply-templates select="./* except $title"/>
            </fo:block>
            <xsl:apply-templates select="$title"/>
          </xsl:when>

          <xsl:otherwise>
            <xsl:apply-templates select="$title"/>
            <fo:block xsl:use-attribute-sets="fig-contents">
              <xsl:call-template name="displayAttributes"/>
              <xsl:apply-templates select="./* except $title"/>
            </fo:block>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <xsl:call-template name="displayAttributes"/>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- figgroup ========================================================== -->

  <xsl:template match="*[contains(@class,' topic/figgroup ')]"/>

  <!-- image ============================================================= -->

  <xsl:attribute-set name="image-container">
  </xsl:attribute-set>

  <xsl:attribute-set name="image">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/image ')]">
    <xsl:choose>
      <xsl:when test="@placement eq 'break' or
                      parent::*[contains(@class,' topic/fig ')]">
        <fo:block xsl:use-attribute-sets="image-container">
          <xsl:if test="@align eq 'left' or
                        @align eq 'right' or
                        @align eq 'center'">
            <xsl:attribute name="text-align" select="string(@align)"/>
          </xsl:if>
          
          <xsl:call-template name="imageToExternalGraphic"/>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="imageToExternalGraphic"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="imageToExternalGraphic">
    <fo:external-graphic src="{concat('url(', string(@href), ')')}"
                         xsl:use-attribute-sets="image">
      <xsl:call-template name="imageSizeAttributes"/>
      <xsl:call-template name="idAttribute"/>
      <xsl:call-template name="roleAttribute"/>
    </fo:external-graphic>
  </xsl:template>

  <xsl:template name="imageSizeAttributes">
    <xsl:choose>
      <xsl:when test="@width or @height">
        <xsl:if test="@width">
          <xsl:attribute name="content-width"
                         select="u:checkLength(string(@width))"/>
        </xsl:if>
        <xsl:if test="@height">
          <xsl:attribute name="content-height"
                         select="u:checkLength(string(@height))"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="@scale">
        <xsl:attribute name="content-width"
                       select="concat(string(@scale), '%')"/>
      </xsl:when>
      <xsl:when test="@scalefit eq 'yes'">
        <xsl:attribute name="width">100%</xsl:attribute>
        <xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="roleAttribute">
    <xsl:variable name="alt" select="./*[contains(@class,' topic/alt ')]"/>

    <xsl:if test="exists($alt)">
      <xsl:attribute name="role" select="normalize-space(string($alt))"/>
    </xsl:if>
  </xsl:template>

  <!-- alt =============================================================== -->

  <xsl:template match="*[contains(@class,' topic/alt ')]"/>

  <!-- longdescref ======================================================= -->

  <xsl:template match="*[contains(@class,' topic/longdescref ')]"/>

  <!-- desc ============================================================== -->

  <xsl:template match="*[contains(@class,' topic/desc ')]"/>

  <!-- object ============================================================ -->
 
  <xsl:attribute-set name="object-fallback">
  </xsl:attribute-set>

  <xsl:attribute-set name="object-auto-fallback">
  </xsl:attribute-set>

  <xsl:attribute-set name="object-download-link" 
                     use-attribute-sets="monospace-style link-style">
    <xsl:attribute name="text-decoration">underline</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="object-no-download-link"
                     use-attribute-sets="monospace-style">
    <xsl:attribute name="text-decoration">underline</xsl:attribute>
    <xsl:attribute name="color">gray</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/object ')]">
    <!-- Use desc as a fallback. longdescref ignored. -->
    <xsl:call-template name="processObjectDesc">
      <xsl:with-param name="objectId" select="string(@id)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="processObjectDesc">
    <xsl:param name="objectId" select="''"/>

    <xsl:variable name="desc" select="./*[contains(@class,' topic/desc ')]"/>
    <xsl:choose>
      <xsl:when test="exists($desc)">
        <fo:block xsl:use-attribute-sets="object-fallback">
          <xsl:if test="$objectId ne ''">
            <xsl:attribute name="id" select="$objectId"/>
          </xsl:if>

          <xsl:apply-templates select="$desc/node()"/>
        </fo:block>
      </xsl:when>

      <xsl:otherwise>
        <xsl:call-template name="generateObjectFallback">
          <xsl:with-param name="objectId" select="$objectId"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:param name="downloadObjectAsFallback" select="true()"/>

  <xsl:template name="generateObjectFallback">
    <xsl:param name="objectId" select="''"/>

    <xsl:variable name="download" select="normalize-space(@data)"/>
    <xsl:variable name="downloadType" select="normalize-space(@type)"/>

    <xsl:if test="$download ne ''">
      <fo:block xsl:use-attribute-sets="object-auto-fallback">
        <xsl:if test="$objectId ne ''">
          <xsl:attribute name="id" select="$objectId"/>
        </xsl:if>

        <xsl:choose>
          <xsl:when test="$downloadObjectAsFallback">
            <fo:basic-link
              external-destination="{concat('url(', $download, ')')}" 
              xsl:use-attribute-sets="object-download-link">
              <xsl:call-template name="generateObjectFallbackContent">
                <xsl:with-param name="download" select="$download"/>
                <xsl:with-param name="downloadType" select="$downloadType"/>
              </xsl:call-template>
            </fo:basic-link>
          </xsl:when>
          <xsl:otherwise>
            <fo:inline xsl:use-attribute-sets="object-no-download-link">
              <xsl:call-template name="generateObjectFallbackContent">
                <xsl:with-param name="download" select="$download"/>
                <xsl:with-param name="downloadType" select="$downloadType"/>
              </xsl:call-template>
            </fo:inline>
          </xsl:otherwise>
        </xsl:choose>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <xsl:template name="generateObjectFallbackContent">
    <xsl:param name="download" select="''"/>
    <xsl:param name="downloadType" select="''"/>

    <xsl:variable name="label" select="u:basename($download)"/>

    <xsl:variable name="posterParam" 
                  select="./*[contains(@class,' topic/param ') and 
                              @name eq 'poster' and
                              string-length(@value) gt 0]"/>

    <xsl:variable name="posterPath" 
                  select="if (exists($posterParam)) 
                          then normalize-space($posterParam[1]/@value)
                          else ''"/>

    <xsl:choose>
      <xsl:when test="$posterPath ne ''">
        <xsl:variable name="posterHeight">
          <xsl:call-template name="imageHeight">
            <xsl:with-param name="path" select="$posterPath"/>
          </xsl:call-template>
        </xsl:variable>
        <!-- Possibly NaN -->
        <xsl:variable name="posterHeight2" select="number($posterHeight)"
                      as="xs:double"/>

        <xsl:variable name="height" 
                      select="if ($posterHeight2 gt 0 and $posterHeight2 le 64) 
                              then xs:integer($posterHeight2)
                              else 64"
                      as="xs:integer"/>

        <!-- Without text-altitude, you'll have to click the bottom (font
             height) of the poster in order to follow the link. -->
        <xsl:attribute name="text-altitude"
                       select="concat($height, 'px')"/>

        <fo:external-graphic src="{concat('url(', $posterPath, ')')}" 
                             role="{$label}"
                             content-height="{concat($height, 'px')}"/>
      </xsl:when>

      <xsl:otherwise>
        <fo:external-graphic
          src="{concat('url(', $xslResourcesDir, 'play.png', ')')}" 
          role="{$label}" />
      </xsl:otherwise>
    </xsl:choose>

    <xsl:text> </xsl:text>
    <xsl:value-of select="$label"/>

    <xsl:if test="$downloadType ne ''">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="$downloadType"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- OMITTED: param -->

  <!-- pre =============================================================== -->

  <xsl:attribute-set name="pre"
    use-attribute-sets="monospace-block-style split-border-style">
    <xsl:attribute name="background-color">#F0F0F0</xsl:attribute>
    <xsl:attribute name="padding">0.25em</xsl:attribute>
    <xsl:attribute name="margin-left">1pt</xsl:attribute>
    <xsl:attribute name="margin-right">1pt</xsl:attribute>
    <!-- Add actual border using the frame attribute. -->
    <xsl:attribute name="border-color">#C0C0C0</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/pre ')]">
    <fo:block xsl:use-attribute-sets="pre">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="displayAttributes"/>

      <xsl:choose>
        <xsl:when test="$highlight-source eq 'yes' and 
                        starts-with(@outputclass, 'language-')">
          <xsl:variable name="source">
            <xsl:copy>
              <xsl:for-each select="./node()">
                <xsl:choose>
                  <xsl:when test="self::*[contains(@class,' pr-d/coderef ')]">
                    <xsl:apply-templates select="." />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:sequence select="." />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:copy>
          </xsl:variable>
          
          <xsl:call-template name="syntaxHighlight">
            <xsl:with-param name="language" 
              select="lower-case(substring-after(@outputclass, '-'))" />
            <xsl:with-param name="source" select="$source/*" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </fo:block>
  </xsl:template>

  <!-- lines ============================================================= -->

  <xsl:attribute-set name="lines"
                     use-attribute-sets="block-style split-border-style">
    <xsl:attribute name="white-space">pre</xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="font-size">90%</xsl:attribute>
    <xsl:attribute name="padding">0.25em</xsl:attribute>
    <xsl:attribute name="margin-left">1pt</xsl:attribute>
    <xsl:attribute name="margin-right">1pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/lines ')]">
    <fo:block xsl:use-attribute-sets="lines">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="displayAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- lq ================================================================ -->

  <xsl:attribute-set name="lq" use-attribute-sets="display-style">
    <xsl:attribute name="margin-left">4em</xsl:attribute>
    <xsl:attribute name="margin-right">4em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="lq-reftitle" use-attribute-sets="caption-style">
    <xsl:attribute name="text-align">right</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/lq ')]">
    <fo:block xsl:use-attribute-sets="lq">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>

      <xsl:variable name="longquoteref" 
        select="(./*[contains(@class,' topic/longquoteref ')])[1]"/>

      <xsl:variable name="href">
        <xsl:choose>
          <xsl:when test="@href">
            <xsl:value-of select="string(@href)"/>
          </xsl:when>
          <xsl:when test="$longquoteref/@href">
            <xsl:value-of select="string($longquoteref/@href)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="@reftitle">
        <fo:block xsl:use-attribute-sets="lq-reftitle">
          <xsl:choose>
            <xsl:when test="$href ne ''">
              <xsl:call-template name="basicLink">
                <xsl:with-param name="href" select="$href"/>
                <xsl:with-param name="text" select="string(@reftitle)"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@reftitle"/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <!-- longquoteref ======================================================= -->

  <xsl:template match="*[contains(@class,' topic/longquoteref ')]"/>

  <!-- q ================================================================= -->

  <xsl:attribute-set name="q">
  </xsl:attribute-set>

  <xsl:attribute-set name="q-quote">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/q ')]">
    <fo:inline xsl:use-attribute-sets="q">
      <xsl:call-template name="commonAttributes"/>
      
      <fo:inline xsl:use-attribute-sets="q-quote">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'openQuote'"/>
        </xsl:call-template>
      </fo:inline>

      <xsl:apply-templates/>

      <fo:inline xsl:use-attribute-sets="q-quote">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'closeQuote'"/>
        </xsl:call-template>
      </fo:inline>
    </fo:inline>
  </xsl:template>

</xsl:stylesheet>
