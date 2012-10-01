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
      <xsl:if test="$use-note-icon = 'yes' and
                    index-of($noteIconList, $type) ge 1">
        <img>
          <xsl:attribute name="src"
                         select="concat($xslResourcesDir,
                                        $type, $note-icon-suffix)"/>
          <xsl:attribute name="alt" select="$label"/>
          <xsl:if test="$note-icon-width != ''">
            <xsl:attribute name="width" select="$note-icon-width"/>
          </xsl:if>
          <xsl:if test="$note-icon-height != ''">
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
          <table border="0" cellspacing="0" class="note-layout">
            <tr>
              <td class="note-icon">
                <xsl:if test="$xhtmlVersion = '-3.2'">
                  <xsl:attribute name="valign">top</xsl:attribute>
                </xsl:if>

                <xsl:copy-of select="$icon"/>
              </td>
              <td class="note-text">
                <xsl:if test="$xhtmlVersion = '-3.2'">
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
    <i>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="basicLink"/>
    </i>
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
    <i>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="basicLink"/>
    </i>
  </xsl:template>

  <!-- xref ============================================================== -->

  <xsl:template match="*[contains(@class,' topic/xref ')]">
    <xsl:choose>
      <xsl:when test="@type = 'fn'">
        <!-- Not an actual xref. An instance of a footnote. -->

        <!-- A .ditac file contains flattened, unique IDs. -->
        <xsl:variable name="id" select="substring-after(@href, '#')"/>

        <xsl:variable name="footnote"
          select="//*[contains(@class,' topic/fn ') and @id = $id]"/>

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
        <!-- An actual xref though in some cases the preprocessor may have
             removed the href. -->

        <xsl:choose>
          <xsl:when test="@href">
            <a>
              <xsl:copy-of select="@href"/>
              <xsl:call-template name="commonAttributes"/>
              <xsl:call-template name="scopeAttribute"/>
              <xsl:call-template name="descToTitleAttribute"/>
              <xsl:if test="exists(@id) and $xhtmlVersion != '1.1'">
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
          <xsl:when test="@compact = 'yes'">
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
    <ul style="list-style-type: none;">
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
        <table cellspacing="0">
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
                  <xsl:if test="$xhtmlVersion = '-3.2'">
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
                  <xsl:if test="$xhtmlVersion = '-3.2'">
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
    <xsl:if test="$xhtmlVersion = '-3.2' and (../*[1] is .) and parent::*/@id">
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
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="descToTitleAttribute"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="processFig"/>
    </div>
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
      <xsl:when test="@placement = 'break' or
                      parent::*[contains(@class,' topic/fig ')]">
        <div class="image-container">
          <xsl:if test="@align = 'left' or
                        @align = 'right' or
                        @align = 'center'">
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

      <xsl:when test="@scalefit = 'yes'">
        <xsl:attribute name="width">100%</xsl:attribute>
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
                          ($unit = 'pc' or $unit = 'pt' or $unit = 'px' or 
                           $unit = 'in' or $unit = 'cm' or $unit = 'mm' or 
                           $unit = 'em'))">
          <xsl:message terminate="yes" 
             select="concat('&quot;', $length, '&quot;, invalid length')" />
        </xsl:if>

        <xsl:variable name="value2" select="number($value)" />

        <xsl:variable name="value3">
          <xsl:choose>
            <xsl:when test="$unit = 'pc'">
              <!-- 1pc = 12pt ==> 1in = 6pc. -->
              <xsl:sequence select="($value2 div 6) * $screen-resolution"/>
            </xsl:when>

            <xsl:when test="$unit = 'pt'">
              <!-- 1in = 72pt. -->
              <xsl:sequence select="($value2 div 72.0) * $screen-resolution"/>
            </xsl:when>

            <xsl:when test="$unit = 'px'">
              <xsl:sequence select="$value2"/>
            </xsl:when>

            <xsl:when test="$unit = 'in'">
              <xsl:sequence select="$value2 * $screen-resolution"/>
            </xsl:when>

            <xsl:when test="$unit = 'cm'">
              <xsl:sequence select="($value2 div 2.54) * $screen-resolution"/>
            </xsl:when>

            <xsl:when test="$unit = 'mm'">
              <xsl:sequence select="($value2 div 25.4) * $screen-resolution"/>
            </xsl:when>

            <xsl:when test="$unit = 'em'">
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
    <xsl:variable name="href" 
                  select="./*[contains(@class,' topic/longdescref ')]/@href"/>

    <xsl:if test="$href">
      <xsl:attribute name="longdesc" select="string($href)"/>
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
    <xsl:call-template name="namedAnchor"/>
    <object>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="descToTitleAttribute"/>
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
      <!-- What to do with the possible longdescref child? -->
      <xsl:apply-templates/>
    </object>
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
      <xsl:apply-templates/>
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

      <xsl:if test="$href != '' and not(@reftitle)">
        <xsl:attribute name="cite" select="$href"/>
      </xsl:if>

      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>

      <div>
        <xsl:apply-templates/>

        <xsl:if test="@reftitle">
          <p class="lq-reftitle">
            <xsl:choose>
              <xsl:when test="$href != ''">
                <a href="{$href}">
                  <xsl:if test="$scope = 'external' and $xhtmlVersion != '1.1'">
                    <xsl:attribute name="target">_blank</xsl:attribute>
                  </xsl:if>

                  <xsl:value-of select="@reftitle"/>

                  <xsl:if test="$scope = 'external' and $xhtmlVersion != '1.1'">
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
