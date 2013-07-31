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
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs u ditac"
                version="2.0">
  
  <!-- p ================================================================= -->

  <xsl:template match="*[contains(@class,' topic/p ')]">
    <!-- a p can contain elements such as ul! -->
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- note ============================================================== -->

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
        <img>
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
      </xsl:if>
    </xsl:variable>

    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>

      <xsl:choose>
        <xsl:when test="exists($icon/*)">
          <table class="note-layout">
            <tr>
              <td class="note-icon">
                <xsl:if test="$xhtmlVersion eq '-3.2'">
                  <xsl:attribute name="valign">top</xsl:attribute>
                </xsl:if>

                <xsl:copy-of select="$icon"/>
              </td>
              <td class="note-text">
                <xsl:if test="$xhtmlVersion eq '-3.2'">
                  <xsl:attribute name="valign">top</xsl:attribute>
                </xsl:if>

                <h5 class="note-head">
                  <xsl:value-of select="$label"/>
                </h5>

                <div class="note-body">
                  <xsl:apply-templates/>
                </div>
              </td>
            </tr>
          </table>
        </xsl:when>

        <xsl:otherwise>
          <h5 class="note-head">
            <xsl:value-of select="$label"/>
          </h5>

          <div class="note-body">
            <xsl:apply-templates/>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <!-- text ============================================================== -->

  <xsl:template match="*[contains(@class,' topic/text ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- ph ================================================================ -->

  <xsl:template match="*[contains(@class,' topic/ph ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <!-- ph, cite, keyword, dt and term: the preprocessor may have converted
           @keyref to @href, @scope, @format. -->
      <xsl:call-template name="basicLink"/>
    </span>
  </xsl:template>

  <xsl:template name="basicLink">
    <xsl:choose>
      <xsl:when test="@href">
        <a>
          <xsl:copy-of select="@href"/>
          <xsl:call-template name="commonAttributes"/>
          <xsl:call-template name="scopeAttribute"/>

          <xsl:choose>
            <xsl:when test="exists(./node())">
              <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@href"/>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:call-template name="externalLinkIcon"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- term ============================================================== -->

  <xsl:template match="*[contains(@class,' topic/term ')]">
    <dfn>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="basicLink"/>
    </dfn>
  </xsl:template>

  <!-- keyword =========================================================== -->

  <xsl:template match="*[contains(@class,' topic/keyword ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="basicLink"/>
    </span>
  </xsl:template>

  <!-- cite ============================================================== -->

  <xsl:template match="*[contains(@class,' topic/cite ')]">
    <cite>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="basicLink"/>
    </cite>
  </xsl:template>

  <!-- xref ============================================================== -->

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
            <xsl:call-template name="footnoteLink">
              <xsl:with-param name="footnote" select="$footnote[1]"/>
            </xsl:call-template>
          </xsl:when>

          <xsl:otherwise>
            <sup class="fn-callout">???</sup>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name="href">
          <xsl:call-template name="resolveExternalHref"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$href ne ''">
            <a>
              <xsl:attribute name="href" select="$href"/>
              <xsl:call-template name="commonAttributes"/>
              <xsl:call-template name="scopeAttribute"/>
              <xsl:call-template name="descToTitleAttribute"/>
              <xsl:if test="exists(@id) and 
                            $xhtmlVersion ne '1.1' and $xhtmlVersion ne '5.0'">
                <xsl:attribute name="name" select="string(@id)"/>
              </xsl:if>

              <xsl:call-template name="linkText">
                <xsl:with-param name="text">
                  <xsl:apply-templates/>
                </xsl:with-param>
                <xsl:with-param name="autoText" select="$xrefAutoText"/>
              </xsl:call-template>

              <xsl:call-template name="externalLinkIcon"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <span>
              <xsl:call-template name="commonAttributes"/>
              <xsl:call-template name="namedAnchor"/>
              <!-- In this case, the desc child is ignored. -->
              <xsl:apply-templates/>
            </span>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="footnoteLink">
    <xsl:param name="footnote" select="''"/>

    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="$footnote/@id">
          <xsl:value-of select="$footnote/@id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('I_', generate-id($footnote), '_')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <a href="#{$id}" class="fn-link">
      <xsl:call-template name="footnoteCallout">
        <xsl:with-param name="footnote" select="$footnote"/>
      </xsl:call-template>
    </a>
  </xsl:template>

  <xsl:template name="footnoteCallout">
    <xsl:param name="footnote" select="''"/>

    <sup class="fn-callout">
      <xsl:choose>
        <xsl:when test="$footnote/@callout">
          <xsl:value-of select="$footnote/@callout"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number count="//*[contains(@class,' topic/fn ')]"
                      level="any" format="(1)" select="$footnote"/>
        </xsl:otherwise>
      </xsl:choose>
    </sup>
  </xsl:template>

  <!-- ol ================================================================ -->

  <xsl:template match="*[contains(@class,' topic/ol ')]">
    <xsl:call-template name="namedAnchor"/>
    <ol>
      <xsl:call-template name="listCommonAttributes">
        <xsl:with-param name="class" select="'ol'"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </ol>
  </xsl:template>

  <xsl:template name="listCommonAttributes">
    <xsl:param name="class" select="''"/>

    <xsl:call-template name="commonAttributes">
      <xsl:with-param name="class">
        <xsl:choose>
          <xsl:when test="@compact eq 'yes'">
            <xsl:value-of select="concat('compact-', $class)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$class"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- ul ================================================================ -->

  <xsl:template match="*[contains(@class,' topic/ul ')]">
    <xsl:call-template name="namedAnchor"/>
    <ul>
      <xsl:call-template name="listCommonAttributes">
        <xsl:with-param name="class" select="'ul'"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <!-- li ================================================================ -->

  <xsl:template match="*[contains(@class,' topic/li ')]">
    <li>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <!-- sl ================================================================ -->

  <xsl:template match="*[contains(@class,' topic/sl ')]">
    <xsl:call-template name="namedAnchor"/>
    <ul>
      <xsl:call-template name="listCommonAttributes">
        <xsl:with-param name="class" select="'sl'"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <!-- sli ================================================================ -->

  <xsl:template match="*[contains(@class,' topic/sli ')]">
    <li>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <!-- dl ================================================================ -->

  <xsl:template match="*[contains(@class,' topic/dl ')]">
    <xsl:choose>
      <xsl:when test="./*[contains(@class,' topic/dlhead ')]">
        <xsl:call-template name="namedAnchor"/>
        <table>
          <xsl:call-template name="commonAttributes">
            <xsl:with-param name="class" select="'tabular-dl'"/>
          </xsl:call-template>

          <xsl:for-each select="./*[contains(@class,' topic/dlhead ')]">
            <tr class="tabular-dl-head-row">
              <xsl:call-template name="idAttribute"/>

              <xsl:for-each select="./*">
                <th>
                  <xsl:call-template name="commonAttributes">
                    <xsl:with-param name="classPrefix" select="'tabular-'"/>
                  </xsl:call-template>
                  <xsl:if test="$xhtmlVersion eq '-3.2'">
                    <xsl:attribute name="valign">top</xsl:attribute>
                  </xsl:if>

                  <xsl:call-template name="namedAnchor"/>
                  <xsl:apply-templates/>
                </th>
              </xsl:for-each>
            </tr>
          </xsl:for-each>

          <xsl:for-each select="./*[contains(@class,' topic/dlentry ')]">
            <tr class="tabular-dl-row">
              <xsl:call-template name="idAttribute"/>

              <xsl:for-each select="./*">
                <td>
                  <xsl:call-template name="commonAttributes">
                    <xsl:with-param name="classPrefix" select="'tabular-'"/>
                  </xsl:call-template>
                  <xsl:if test="$xhtmlVersion eq '-3.2'">
                    <xsl:attribute name="valign">top</xsl:attribute>
                  </xsl:if>

                  <xsl:call-template name="namedAnchor"/>
                  <xsl:apply-templates/>
                </td>
              </xsl:for-each>
            </tr>
          </xsl:for-each>
        </table>
      </xsl:when>

      <xsl:otherwise>
        <xsl:call-template name="namedAnchor"/>
        <dl>
          <xsl:call-template name="listCommonAttributes">
            <xsl:with-param name="class" select="'dl'"/>
          </xsl:call-template>
          <xsl:apply-templates/>
        </dl>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- dlentry =========================================================== -->

  <xsl:template match="*[contains(@class,' topic/dlentry ')]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- dt ================================================================ -->

  <xsl:template match="*[contains(@class,' topic/dt ')]">
    <dt>
      <xsl:call-template name="copyEntryId"/>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="copyEntryId2"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="basicLink"/>
    </dt>
  </xsl:template>

  <xsl:template name="copyEntryId">
    <!-- An ID attribute is likely to be specified on a dlentry rather than on
         a dt or dd. -->
    <xsl:if test="not(@id) and (../*[1] is .) and parent::*/@id">
      <xsl:copy-of select="parent::*/@id"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="copyEntryId2">
    <xsl:if test="$xhtmlVersion eq '-3.2' and (../*[1] is .) and parent::*/@id">
      <a name="{string(parent::*/@id)}"/>
    </xsl:if>
  </xsl:template>

  <!-- dd ================================================================ -->

  <xsl:template match="*[contains(@class,' topic/dd ')]">
    <dd>
      <xsl:call-template name="copyEntryId"/>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="copyEntryId2"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </dd>
  </xsl:template>

  <!-- fig =============================================================== -->

  <xsl:template match="*[contains(@class,' topic/fig ')]">
    <xsl:element name="{if ($xhtmlVersion eq '5.0') then 'figure' else 'div'}">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="descToTitleAttribute"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="processFig"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="processFig">
    <xsl:variable name="title" select="./*[contains(@class,' topic/title ')]"/>

    <xsl:choose>
      <xsl:when test="$title">
        <!-- Display attributes do not apply to the title. -->
        <xsl:choose>
          <xsl:when
            test="index-of($titleAfterList,u:classToElementName(@class)) ge 1">
            <div class="fig-contents">
              <xsl:call-template name="displayAttributes"/>
              <xsl:apply-templates select="./* except $title"/>
            </div>
            <xsl:apply-templates select="$title"/>
          </xsl:when>

          <xsl:otherwise>
            <xsl:apply-templates select="$title"/>
            <div class="fig-contents">
              <xsl:call-template name="displayAttributes"/>
              <xsl:apply-templates select="./* except $title"/>
            </div>
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

  <xsl:template match="*[contains(@class,' topic/image ')]">
    <xsl:choose>
      <xsl:when test="@placement eq 'break' or
                      parent::*[contains(@class,' topic/fig ')]">
        <div class="image-container">
          <xsl:if test="@align eq 'left' or
                        @align eq 'right' or
                        @align eq 'center'">
            <xsl:attribute name="style"
              select="concat('text-align: ', string(@align), ';')"/>
          </xsl:if>
          
          <xsl:call-template name="namedAnchor"/>
          <xsl:call-template name="imageToImg"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="namedAnchor"/>
        <xsl:call-template name="imageToImg"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="imageToImg">
    <xsl:variable name="alt" select="./*[contains(@class,' topic/alt ')]"/>

    <img src="{@href}">
      <xsl:call-template name="imageSizeAttributes"/>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="longdescrefToLongdescAttribute"/>
      <!-- Attribute alt is required. -->
      <xsl:attribute name="alt">
        <xsl:choose>
          <xsl:when test="exists($alt)">
            <xsl:value-of select="normalize-space(string($alt))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="tokenize(string(@href), '/')[last()]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </img>
  </xsl:template>

  <xsl:template name="imageSizeAttributes">
    <xsl:choose>
      <xsl:when test="@width or @height">
        <xsl:if test="@width">
          <xsl:attribute name="width" select="u:toPixels(string(@width))"/>
        </xsl:if>
        <xsl:if test="@height">
          <xsl:attribute name="height" select="u:toPixels(string(@height))"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="@scale">
        <xsl:variable name="width" as="xs:double">
          <xsl:call-template name="imageWidth">
            <xsl:with-param name="path" select="@href"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:if test="$width gt 0">
          <xsl:attribute name="width"
            select="(xs:integer($width)*xs:integer(@scale)) idiv 100"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="@scalefit eq 'yes'">
        <!-- XHTML5 only supports a width in pixels. -->
        <xsl:attribute name="style" select="'width: 100%;'"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="u:toPixels" as="xs:string">
    <xsl:param name="length" as="xs:string"/>

    <!-- Real number optionally followed by a unit of measure from the set of
         pc, pt, px, in, cm, mm, em (picas, points, pixels, inches,
         centimeters, millimeters, and ems respectively). 
         The default unit is px (pixels). -->

    <xsl:choose>
      <xsl:when test="number($length) gt 0">
        <xsl:sequence select="string(round(number($length)))"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name="value"
          select="substring($length, 1, string-length($length)-2)"/>

        <xsl:variable name="unit"
          select="substring($length, string-length($length)-1)"/>
        
        <xsl:if test="not((number($value) gt 0) and 
                          ($unit eq 'pc' or $unit eq 'pt' or $unit eq 'px' or 
                           $unit eq 'in' or $unit eq 'cm' or $unit eq 'mm' or 
                           $unit eq 'em'))">
          <xsl:message terminate="yes" 
             select="concat('&quot;', $length, '&quot;, invalid length')" />
        </xsl:if>

        <xsl:variable name="value2" select="number($value)" />

        <xsl:variable name="value3">
          <xsl:choose>
            <xsl:when test="$unit eq 'pc'">
              <!-- 1pc=12pt ==> 1in=6pc. -->
              <xsl:sequence select="($value2 div 6) * $screen-resolution"/>
            </xsl:when>

            <xsl:when test="$unit eq 'pt'">
              <!-- 1in=72pt. -->
              <xsl:sequence select="($value2 div 72.0) * $screen-resolution"/>
            </xsl:when>

            <xsl:when test="$unit eq 'px'">
              <xsl:sequence select="$value2"/>
            </xsl:when>

            <xsl:when test="$unit eq 'in'">
              <xsl:sequence select="$value2 * $screen-resolution"/>
            </xsl:when>

            <xsl:when test="$unit eq 'cm'">
              <xsl:sequence select="($value2 div 2.54) * $screen-resolution"/>
            </xsl:when>

            <xsl:when test="$unit eq 'mm'">
              <xsl:sequence select="($value2 div 25.4) * $screen-resolution"/>
            </xsl:when>

            <xsl:when test="$unit eq 'em'">
              <xsl:sequence
                select="(($value2 * $em-size) div 72.0) * $screen-resolution"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="string(round(number($value3)))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- alt =============================================================== -->

  <xsl:template match="*[contains(@class,' topic/alt ')]"/>

  <!-- longdescref ======================================================= -->

  <xsl:template match="*[contains(@class,' topic/longdescref ')]"/>

  <xsl:template name="longdescrefToLongdescAttribute">
    <xsl:if test="$xhtmlVersion ne '-3.2' and $xhtmlVersion ne '5.0'">
      <xsl:variable name="href" 
                    select="./*[contains(@class,' topic/longdescref ')]/@href"/>

      <xsl:if test="$href">
        <xsl:attribute name="longdesc" select="string($href)"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- desc ============================================================== -->

  <xsl:template match="*[contains(@class,' topic/desc ')]"/>

  <xsl:template name="descToTitleAttribute">
    <xsl:variable name="desc" select="./*[contains(@class,' topic/desc ')]"/>

    <xsl:if test="$desc">
      <xsl:attribute name="title" select="normalize-space(string($desc))"/>
    </xsl:if>
  </xsl:template>

  <!-- object ============================================================ -->
 
  <xsl:template match="*[contains(@class,' topic/object ')]">
    <xsl:call-template name="processObject"/>
  </xsl:template>

  <xsl:template name="processObject">
    <xsl:call-template name="namedAnchor"/>

    <xsl:choose>
      <xsl:when test="u:objectIsAudioVideo(.)">
        <xsl:choose>
          <xsl:when test="$xhtmlVersion eq '5.0'">
            <xsl:call-template name="processAudioVideo"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- An audio/video object is not meant to be used as is, so
                 just use the fallback. -->
            <xsl:call-template name="processObjectDesc">
              <xsl:with-param name="objectId" select="string(@id)"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <object>
          <xsl:call-template name="commonAttributes"/>
          <xsl:copy-of select="@declare"/>
          <xsl:copy-of select="@classid"/>
          <xsl:copy-of select="@codebase"/>
          <xsl:copy-of select="@data"/>
          <xsl:copy-of select="@type"/>
          <xsl:copy-of select="@codetype"/>
          <xsl:copy-of select="@archive"/>
          <xsl:copy-of select="@standby"/>
          <xsl:copy-of select="@height"/>
          <xsl:copy-of select="@width"/>
          <xsl:copy-of select="@usemap"/>
          <xsl:copy-of select="@name"/>
          <xsl:copy-of select="@tabindex"/>
          <xsl:apply-templates select="./*[contains(@class,' topic/param ')]"/>

          <!-- Use desc as a fallback. longdescref ignored. -->
          <xsl:call-template name="processObjectDesc"/>
        </object>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="processAudioVideo">
    <xsl:choose>
      <xsl:when test="starts-with(@type, 'audio/')">
        <audio>
          <xsl:call-template name="commonAttributes"/>

          <xsl:call-template name="processAudioVideoParams">
            <xsl:with-param name="isAudio" select="true()"/>
          </xsl:call-template>

          <xsl:call-template name="processObjectDesc"/>
        </audio>
      </xsl:when>

      <xsl:otherwise>
        <video>
          <xsl:call-template name="commonAttributes"/>

          <xsl:call-template name="processAudioVideoParams">
            <xsl:with-param name="isAudio" select="false()"/>
          </xsl:call-template>

          <xsl:call-template name="processObjectDesc"/>
        </video>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="processAudioVideoParams">
    <xsl:param name="isAudio" select="false()"/>

    <xsl:if test="not($isAudio)">
      <xsl:if test="exists(@width)">
        <xsl:copy-of select="@width"/>
      </xsl:if>
      <xsl:if test="exists(@height)">
        <xsl:copy-of select="@height"/>
      </xsl:if>
    </xsl:if>

    <xsl:variable name="params" select="./*[contains(@class,' topic/param ')]"/>
    <xsl:for-each select="$params">
      <xsl:variable name="paramName" select="string(@name)"/>
      <xsl:variable name="paramValue" select="string(@value)"/>

      <xsl:if test="$paramName ne '' and 
                    $paramName ne 'source.src' and $paramName ne 'source.type'">
        <xsl:choose>
          <xsl:when test="$paramName eq 'autoplay' or
                          $paramName eq 'loop' or
                          $paramName eq 'muted' or
                          $paramName eq 'controls'">
            <!-- Boolean attributes: do not care about the value. -->
            <xsl:attribute name="{$paramName}" select="''"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="$paramValue ne ''">
              <xsl:attribute name="{$paramName}" select="$paramValue"/>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>

    <source src="{string(@data)}" type="{string(@type)}"/>

    <!-- Alternate sources -->

    <xsl:for-each-group select="$params" 
                        group-starting-with="*[@name eq 'source.src']">
      <xsl:variable name="typeParam" 
                    select="current-group()[@name eq 'source.type']"/>
      <xsl:if test="exists($typeParam)">
        <xsl:variable name="src" select="string(current-group()[1]/@value)"/>
        <xsl:variable name="type" select="string($typeParam[1]/@value)"/>

        <xsl:if test="string-length($src) gt 0 and string-length($type) gt 0">
          <source src="{$src}" type="{$type}"/>
        </xsl:if>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template name="processObjectDesc">
    <xsl:param name="objectId" select="''"/>

    <xsl:variable name="desc" select="./*[contains(@class,' topic/desc ')]"/>
    <xsl:choose>
      <xsl:when test="exists($desc)">
        <div class="object-fallback">
          <xsl:if test="$objectId ne ''">
            <xsl:attribute name="id" select="$objectId"/>
          </xsl:if>

          <xsl:apply-templates select="$desc/node()"/>
        </div>
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
      <div class="object-auto-fallback">
        <xsl:if test="$objectId ne ''">
          <xsl:attribute name="id" select="$objectId"/>
        </xsl:if>

        <xsl:choose>
          <xsl:when test="$downloadObjectAsFallback">
            <a href="{$download}" target="_blank" class="object-download-link">
              <xsl:call-template name="generateObjectFallbackContent">
                <xsl:with-param name="download" select="$download"/>
                <xsl:with-param name="downloadType" select="$downloadType"/>
              </xsl:call-template>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <span class="object-no-download-link">
              <xsl:call-template name="generateObjectFallbackContent">
                <xsl:with-param name="download" select="$download"/>
                <xsl:with-param name="downloadType" select="$downloadType"/>
              </xsl:call-template>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </div>
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
        <xsl:variable name="posterWidth">
          <xsl:call-template name="imageWidth">
            <xsl:with-param name="path" select="$posterPath"/>
          </xsl:call-template>
        </xsl:variable>
        <!-- Possibly NaN -->
        <xsl:variable name="posterWidth2" select="number($posterWidth)"
                      as="xs:double"/>

        <xsl:variable name="width" 
                      select="if ($posterWidth2 gt 0 and $posterWidth2 le 128) 
                              then xs:integer($posterWidth2)
                              else 128"
                      as="xs:integer"/>

        <img src="{$posterPath}" alt="{$label}" width="{$width}">
          <xsl:call-template name="noImageBorder"/>
        </img>
      </xsl:when>

      <xsl:otherwise>
        <img src="{concat($xslResourcesDir, 'play.png')}" alt="{$label}">
          <xsl:call-template name="noImageBorder"/>
        </img>
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

  <!-- param ============================================================= -->

  <xsl:template match="*[contains(@class,' topic/param ')]">
    <param>
      <xsl:call-template name="idAttribute"/>
      <xsl:copy-of select="@name"/>
      <xsl:copy-of select="@value"/>
      <xsl:copy-of select="@valuetype"/>
      <xsl:copy-of select="@type"/>
    </param>
  </xsl:template>

  <!-- pre =============================================================== -->

  <xsl:template match="*[contains(@class,' topic/pre ')]">
    <pre>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="displayAttributes"/>
      <xsl:call-template name="namedAnchor"/>

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
    </pre>
  </xsl:template>

  <!-- lines ============================================================= -->

  <xsl:template match="*[contains(@class,' topic/lines ')]">
    <pre>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="displayAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </pre>
  </xsl:template>

  <!-- lq ================================================================ -->

  <xsl:template match="*[contains(@class,' topic/lq ')]">
    <blockquote>
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

      <xsl:variable name="scope">
        <xsl:choose>
          <xsl:when test="@scope">
            <xsl:value-of select="string(@scope)"/>
          </xsl:when>
          <xsl:when test="$longquoteref/@scope">
            <xsl:value-of select="string($longquoteref/@scope)"/>
          </xsl:when>
          <xsl:when test="@type">
            <!-- Normally @type is deprecated -->
            <xsl:value-of select="string(@type)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="$href ne '' and not(@reftitle)">
        <xsl:attribute name="cite" select="$href"/>
      </xsl:if>

      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>

      <div>
        <xsl:apply-templates/>

        <xsl:if test="@reftitle">
          <p class="lq-reftitle">
            <xsl:choose>
              <xsl:when test="$href ne ''">
                <a href="{$href}">
                  <xsl:if test="$scope eq 'external' and 
                                $xhtmlVersion ne '1.1'">
                    <xsl:attribute name="target">_blank</xsl:attribute>
                  </xsl:if>

                  <xsl:value-of select="@reftitle"/>

                  <xsl:if test="$scope eq 'external' and 
                                $xhtmlVersion ne '1.1'">
                    <xsl:call-template name="addExternalLinkIcon"/>
                  </xsl:if>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@reftitle"/>
              </xsl:otherwise>
            </xsl:choose>
          </p>
        </xsl:if>
      </div>
    </blockquote>
  </xsl:template>

  <!-- longquoteref ======================================================= -->

  <xsl:template match="*[contains(@class,' topic/longquoteref ')]"/>

  <!-- q ================================================================= -->

  <xsl:template match="*[contains(@class,' topic/q ')]">
    <q>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </q>
  </xsl:template>

</xsl:stylesheet>
