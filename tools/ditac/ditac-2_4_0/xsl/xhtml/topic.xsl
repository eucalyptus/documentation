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
  
  <!-- topic ============================================================= -->

  <xsl:template match="*[contains(@class,' topic/topic ')]">
    <xsl:element name="{$sectionQName}">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- title ============================================================= -->

  <xsl:template priority="10"
    match="*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]">
    <h2>
      <xsl:call-template name="commonAttributes">
        <xsl:with-param name="class">
          <xsl:call-template name="topicTitleClass"/>
        </xsl:with-param>
      </xsl:call-template>

      <xsl:call-template name="titlePrefix"/>

      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="titleContents"/>

      <xsl:if test="$chain-topics eq 'yes'">
        <xsl:text> </xsl:text>
        <xsl:call-template name="chainTopics" />
      </xsl:if>
    </h2>
  </xsl:template>

  <xsl:template name="chainTopics">
    <xsl:variable name="topicId" select="../@id"/>
    <xsl:variable name="tocEntry" select="u:tocEntry($topicId)"/>

    <xsl:if test="exists($tocEntry)">
      <xsl:variable name="previousTOCEntry" 
                    select="$tocEntry/preceding-sibling::ditac:tocEntry[1]"/>
      <xsl:variable name="parentTOCEntry"
                    select="$tocEntry/parent::ditac:tocEntry"/>
      <xsl:variable name="childTOCEntry"
                    select="$tocEntry/child::ditac:tocEntry[1]"/>
      <xsl:variable name="nextTOCEntry"
                    select="$tocEntry/following-sibling::ditac:tocEntry[1]"/>

      <span class="topic-navigation-bar">
        <xsl:choose>
          <xsl:when test="exists($previousTOCEntry)">
            <xsl:call-template name="navigationIcon">
              <xsl:with-param name="name" select="'previous'"/>
              <xsl:with-param name="type" select="'previousTopic'"/>
              <xsl:with-param name="href" 
                select="u:joinLinkTarget($previousTOCEntry/@file,
                                         $previousTOCEntry/@id)"/>
              <xsl:with-param name="target" 
                             select="u:shortTOCEntryTitle($previousTOCEntry)"/>
              <!-- L like Left -->
              <xsl:with-param name="accessKey" select="'L'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="navigationIcon">
              <xsl:with-param name="name" select="'previous'"/>
              <xsl:with-param name="type" select="'previousTopic'"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:text>&#xA0;</xsl:text>

        <xsl:choose>
          <xsl:when test="exists($parentTOCEntry)">
            <xsl:call-template name="navigationIcon">
              <xsl:with-param name="name" select="'parent'"/>
              <xsl:with-param name="type" select="'parentTopic'"/>
              <xsl:with-param name="href" 
                select="u:joinLinkTarget($parentTOCEntry/@file,
                                         $parentTOCEntry/@id)"/>
              <xsl:with-param name="target" 
                              select="u:shortTOCEntryTitle($parentTOCEntry)"/>
              <!-- U like Up -->
              <xsl:with-param name="accessKey" select="'U'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="navigationIcon">
              <xsl:with-param name="name" select="'parent'"/>
              <xsl:with-param name="type" select="'parentTopic'"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:text>&#xA0;</xsl:text>

        <xsl:choose>
          <xsl:when test="exists($childTOCEntry)">
            <xsl:call-template name="navigationIcon">
              <xsl:with-param name="name" select="'child'"/>
              <xsl:with-param name="type" select="'childTopic'"/>
              <xsl:with-param name="href" 
                select="u:joinLinkTarget($childTOCEntry/@file,
                                         $childTOCEntry/@id)"/>
              <xsl:with-param name="target" 
                              select="u:shortTOCEntryTitle($childTOCEntry)"/>
              <!-- D like Down -->
              <xsl:with-param name="accessKey" select="'D'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="navigationIcon">
              <xsl:with-param name="name" select="'child'"/>
              <xsl:with-param name="type" select="'childTopic'"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:text>&#xA0;</xsl:text>

        <xsl:choose>
          <xsl:when test="exists($nextTOCEntry)">
            <xsl:call-template name="navigationIcon">
              <xsl:with-param name="name" select="'next'"/>
              <xsl:with-param name="type" select="'nextTopic'"/>
              <xsl:with-param name="href" 
                select="u:joinLinkTarget($nextTOCEntry/@file,
                                         $nextTOCEntry/@id)"/>
              <xsl:with-param name="target" 
                              select="u:shortTOCEntryTitle($nextTOCEntry)"/>
              <!-- R like Right -->
              <xsl:with-param name="accessKey" select="'R'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="navigationIcon">
              <xsl:with-param name="name" select="'next'"/>
              <xsl:with-param name="type" select="'nextTopic'"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template priority="10"
    match="*[contains(@class,' topic/example ')]/*[contains(@class,' topic/title ')]">
    <h3>
      <xsl:call-template name="commonAttributes">
        <xsl:with-param name="class">example-title</xsl:with-param>
      </xsl:call-template>

      <xsl:call-template name="titlePrefix"/>

      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="titleContents"/>
    </h3>
  </xsl:template>

  <xsl:template priority="10"
    match="*[contains(@class,' topic/section ')]/*[contains(@class,' topic/title ')]">
    <h3>
      <xsl:call-template name="commonAttributes">
        <xsl:with-param name="class">section-title</xsl:with-param>
      </xsl:call-template>

      <!-- Sections are not numbered. -->

      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="titleContents"/>
    </h3>
  </xsl:template>

  <xsl:template priority="100"
    match="*[contains(@class,' reference/refsyn ')]/*[contains(@class,' topic/title ')]">
    <h3>
      <xsl:call-template name="commonAttributes">
        <xsl:with-param name="class">refsyn-title</xsl:with-param>
      </xsl:call-template>

      <!-- Refsyns are not numbered. -->

      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="titleContents"/>
    </h3>
  </xsl:template>

  <xsl:template match="*[contains(@class,' topic/title ')]">
    <xsl:variable name="class">
      <xsl:call-template name="titleClass"/>
    </xsl:variable>

    <xsl:variable name="titleQName">
      <xsl:choose>
        <xsl:when test="$xhtmlVersion eq '5.0' and 
                        parent::*[contains(@class,' topic/fig ')]">
          <xsl:sequence select="'figcaption'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'h4'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:element name="{$titleQName}">
      <xsl:if 
        test="index-of($centerList, u:classToElementName(../@class)) ge 1">
        <xsl:attribute name="style">text-align: center;</xsl:attribute>
      </xsl:if>

      <xsl:call-template name="commonAttributes">
        <xsl:with-param name="class" select="$class"/>
      </xsl:call-template>

      <xsl:call-template name="titlePrefix"/>

      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="titleContents"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="titleClass">
    <xsl:choose>
      <xsl:when test="parent::*/@class">
        <xsl:value-of
          select="concat(tokenize(normalize-space(parent::*/@class), '/|\s+')[last()], '-title')"/>
      </xsl:when>
      <xsl:otherwise>title</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- titlealts ========================================================= -->

  <xsl:template match="*[contains(@class,' topic/titlealts ')]"/>

  <!-- OMITTED: navtitle, searchtitle -->

  <!-- abstract ========================================================== -->

  <xsl:template match="*[contains(@class,' topic/abstract ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- shortdesc ========================================================= -->

  <xsl:template match="*[contains(@class,' topic/shortdesc ')]">
    <p>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <!-- body ============================================================== -->

  <xsl:template match="*[contains(@class,' topic/body ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- bodydiv =========================================================== -->

  <xsl:template match="*[contains(@class,' topic/bodydiv ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- section =========================================================== -->

  <xsl:template match="*[contains(@class,' topic/section ')]">
    <xsl:element name="{$sectionQName}">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- sectiondiv ======================================================== -->

  <xsl:template match="*[contains(@class,' topic/sectiondiv ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- example =========================================================== -->

  <xsl:template match="*[contains(@class,' topic/example ')]">
    <xsl:element name="{$sectionQName}">
      <xsl:call-template name="commonAttributes"/>

      <xsl:if test="not(./*[contains(@class,' topic/title ')])">
        <h3 class="example-title">
          <xsl:call-template name="localize">
            <xsl:with-param name="message" select="'example'"/>
          </xsl:call-template>
        </h3>
      </xsl:if>

      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- related-links ===================================================== -->

  <xsl:template match="*[contains(@class,' topic/related-links ')]">
    <xsl:variable name="navigationChildren" 
      select="for $c in ./*
              return
                  if ($c[contains(@class,' topic/linkpool ') and
                         (ends-with(@mapkeyref, 'type=sequence-parent') or 
                          ends-with(@mapkeyref, 'type=sequence-members') or 
                          ends-with(@mapkeyref, 'type=family-parent') or 
                          ends-with(@mapkeyref, 'type=family-members') or 
                          ends-with(@mapkeyref, 'type=unordered-parent') or 
                          ends-with(@mapkeyref, 'type=unordered-members') or 
                          ends-with(@mapkeyref, 'type=choice-parent') or 
                          ends-with(@mapkeyref, 'type=choice-members'))])
                  then $c
                  else ()" />

    <xsl:variable name="otherChildren" 
                  select="./* except $navigationChildren" />

    <xsl:if test="count($otherChildren) gt 0">
      <xsl:element name="{$navQName}">
        <xsl:call-template name="commonAttributes"/>

        <h3 class="related-links-title">
          <xsl:variable name="key">
            <xsl:choose>
              <xsl:when test="@type eq 'concept'">relatedConcepts</xsl:when>
              <xsl:when test="@type eq 'task'">relatedTasks</xsl:when>
              <xsl:when test="@type eq 'reference'">relatedReference</xsl:when>
              <xsl:otherwise>relatedLinks</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:call-template name="localize">
            <xsl:with-param name="message" select="$key"/>
          </xsl:call-template>
        </h3>

        <xsl:call-template name="namedAnchor"/>
        <xsl:apply-templates select="$otherChildren"/>
      </xsl:element>
    </xsl:if>

    <xsl:if
      test="($ignore-navigation-links eq 'no' or 
             ($ignore-navigation-links eq 'auto' and $chain-topics eq 'no'))
            and not(parent::*[contains(@class,' glossentry/glossentry ')])">
      <xsl:for-each select="$navigationChildren">
        <xsl:if test="ends-with(@mapkeyref, '-members')">
          <xsl:apply-templates select="."/>
        </xsl:if>
      </xsl:for-each>

      <xsl:for-each select="$navigationChildren">
        <xsl:if test="ends-with(@mapkeyref, '-parent')">
          <xsl:apply-templates select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
