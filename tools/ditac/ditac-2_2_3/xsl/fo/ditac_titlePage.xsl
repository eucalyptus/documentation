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
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                xmlns:URI="java:com.xmlmind.ditac.xslt.URI"
                xmlns:Date="java:com.xmlmind.ditac.xslt.Date"
                exclude-result-prefixes="xs ditac URI Date"
                version="2.0">

  <xsl:preserve-space elements="addressdetails"/>

  <xsl:attribute-set name="title-page">
    <xsl:attribute name="margin">1em</xsl:attribute>
    <xsl:attribute name="text-align">center</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="ditac:titlePage">
    <xsl:choose>
      <xsl:when test="$title-page = 'none'">
        <!-- Nothing to do. -->
      </xsl:when>

      <xsl:when test="$title-page = 'auto'">
        <xsl:call-template name="autoTitlePage"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:call-template name="customTitlePage"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="autoTitlePage">
    <fo:block xsl:use-attribute-sets="title-page" id="__TP">
      <xsl:for-each select="$ditacLists/ditac:titlePage">
        <!-- Compose your title-page by invoking one or more titlePage_XXX
             (with the right options for some of these templates). -->

        <xsl:call-template name="titlePage_library"/>
        <xsl:call-template name="titlePage_title"/>
        <xsl:call-template name="titlePage_titlealt"/>

        <xsl:call-template name="titlePage_author">
          <xsl:with-param name="authorOptions" select="'all'" tunnel="yes"/>
        </xsl:call-template>

        <xsl:call-template name="titlePage_lastCritdate"/>

        <xsl:call-template name="titlePage_publisher">
          <xsl:with-param name="publisherOptions" select="'all'" 
                          tunnel="yes"/>
        </xsl:call-template>

      </xsl:for-each>
    </fo:block>
  </xsl:template>

  <xsl:template name="customTitlePage">
    <xsl:variable name="titlePageURI" 
                  select="resolve-uri($title-page, URI:userDirectory())"/>
    <xsl:choose>
      <xsl:when test="doc-available($titlePageURI)">
        <xsl:variable name="titlePage" select="doc($titlePageURI)"/>
        <xsl:variable name="titlePageContents"
          select="$titlePage//fo:flow[@flow-name='xsl-region-body']/node()"/>
        <xsl:choose>
          <xsl:when test="exists($titlePageContents)">
            <fo:block id="__TP">
              <xsl:copy-of select="$titlePageContents"/>
            </fo:block>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes" 
                         select="concat('&quot;', $titlePageURI, 
                                        '&quot; is not an XSL-FO document.')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes" 
                     select="concat('cannot access &quot;', 
                                    $titlePageURI, '&quot;.')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- titlePage_title =================================================== -->

  <xsl:template name="titlePage_title">
    <xsl:variable name="bookTitle"
                  select="*[contains(@class,' bookmap/booktitle ')]"/>
    <xsl:choose>
      <xsl:when test="exists($bookTitle)">
        <xsl:apply-templates
          select="$bookTitle/*[contains(@class,' bookmap/mainbooktitle ')]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[contains(@class,' topic/title ')]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- mainbooktitle, titlePage/title ========== -->

  <xsl:attribute-set name="title-page-block-style">
    <xsl:attribute name="space-before.optimum">1.5em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">1em</xsl:attribute>
    <xsl:attribute name="space-before">2em</xsl:attribute>
    <xsl:attribute name="space-after.optimum">1.5em</xsl:attribute>
    <xsl:attribute name="space-after.minimum">1em</xsl:attribute>
    <xsl:attribute name="space-after.maximum">2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="document-title"
                     use-attribute-sets="title-page-block-style">
    <xsl:attribute name="font-family">sans-serif</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">200%</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' bookmap/mainbooktitle ')] |
                       ditac:titlePage/*[contains(@class,' topic/title ')]">
    <fo:block xsl:use-attribute-sets="document-title">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- titlePage_titlealt ================================================ -->

  <xsl:template name="titlePage_titlealt">
    <xsl:apply-templates
      select="*[contains(@class,' bookmap/booktitle ')]/*[contains(@class,' bookmap/booktitlealt ')]"/>
  </xsl:template>

  <!-- booktitlealt ========== -->

  <xsl:attribute-set name="booktitlealt"
                     use-attribute-sets="title-page-block-style">
    <xsl:attribute name="font-family">sans-serif</xsl:attribute>
    <xsl:attribute name="font-style">italic</xsl:attribute>
    <xsl:attribute name="font-size">120%</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' bookmap/booktitlealt ')]">
    <fo:block xsl:use-attribute-sets="booktitlealt">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- titlePage_library ================================================= -->

  <xsl:template name="titlePage_library">
    <xsl:apply-templates
      select="*[contains(@class,' bookmap/booktitle ')]/*[contains(@class,' bookmap/booklibrary ')]"/>
  </xsl:template>

  <!-- booklibrary ========== -->

  <xsl:attribute-set name="booklibrary"
                     use-attribute-sets="title-page-block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' bookmap/booklibrary ')]">
    <fo:block xsl:use-attribute-sets="booklibrary">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- titlePage_author ================================================== -->

  <xsl:template name="titlePage_author">
    <xsl:param name="authorOptions" select="'all'" tunnel="yes"/>

    <xsl:apply-templates
      select="*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/author ')]"/>
  </xsl:template>

  <!-- author, authorinformation ========== -->

  <xsl:attribute-set name="document-author"
                     use-attribute-sets="title-page-block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/author ')]">
    <fo:block xsl:use-attribute-sets="document-author">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- personinfo ========== -->

  <xsl:attribute-set name="personinfo">
    <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">0.4em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">0.6em</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0.5em</xsl:attribute>
    <xsl:attribute name="space-after.minimum">0.4em</xsl:attribute>
    <xsl:attribute name="space-after.maximum">0.6em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' xnal-d/personinfo ')]">
    <fo:block xsl:use-attribute-sets="personinfo">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- organizationinfo ========== -->

  <xsl:attribute-set name="organizationinfo" use-attribute-sets="personinfo">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' xnal-d/organizationinfo ')]">
    <fo:block xsl:use-attribute-sets="organizationinfo">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- namedetails ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/namedetails ')]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- personname ========== -->

  <xsl:attribute-set name="personname">
  </xsl:attribute-set>

  <xsl:attribute-set name="full-name">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' xnal-d/personname ')]">
    <fo:block xsl:use-attribute-sets="personname">
      <xsl:call-template name="commonAttributes"/>

      <fo:block xsl:use-attribute-sets="full-name">
        <xsl:apply-templates 
          select="* except *[contains(@class,' xnal-d/otherinfo ')]"/>
      </fo:block>

      <xsl:apply-templates select="*[contains(@class,' xnal-d/otherinfo ')]"/>
    </fo:block>
  </xsl:template>

  <!-- honorific, firstname, middlename, lastname,
       generationidentifier ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/honorific ')] |
                       *[contains(@class,' xnal-d/firstname ')] |
                       *[contains(@class,' xnal-d/middlename ')] |
                       *[contains(@class,' xnal-d/lastname ')] |
                       *[contains(@class,' xnal-d/generationidentifier ')]">
    <xsl:if test="position() gt 1">
      <xsl:text> </xsl:text>
    </xsl:if>

    <xsl:apply-templates/>
  </xsl:template>

  <!-- organizationnamedetails ========== -->

  <xsl:attribute-set name="organizationnamedetails">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' xnal-d/organizationnamedetails ')]">
    <fo:block xsl:use-attribute-sets="organizationnamedetails">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- organizationname ========== -->

  <xsl:attribute-set name="organizationname">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' xnal-d/organizationname ')]">
    <fo:block xsl:use-attribute-sets="organizationname">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- otherinfo ========== -->

  <xsl:attribute-set name="otherinfo">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' xnal-d/otherinfo ')]">
    <xsl:param name="authorOptions" select="'all'" tunnel="yes"/>

    <xsl:if test="$authorOptions = 'all' or 
                  index-of($authorOptions, 'otherinfo') ge 1">
      <fo:block xsl:use-attribute-sets="otherinfo">
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <!-- addressdetails ========== -->

  <xsl:attribute-set name="addressdetails">
    <xsl:attribute name="white-space">pre</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' xnal-d/addressdetails ')]">
    <xsl:param name="authorOptions" select="'all'" tunnel="yes"/>

    <xsl:if test="$authorOptions = 'all' or 
                  index-of($authorOptions, 'addressdetails') ge 1">
      <fo:block xsl:use-attribute-sets="addressdetails">
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <!-- thoroughfare, locality, administrativearea, country,
       localityname, postalcode ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/thoroughfare ')] |
                       *[contains(@class,' xnal-d/locality ')] |
                       *[contains(@class,' xnal-d/administrativearea ')] |
                       *[contains(@class,' xnal-d/country ')] |
                       *[contains(@class,' xnal-d/localityname ')] |
                       *[contains(@class,' xnal-d/postalcode ')]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- contactnumbers ========== -->

  <xsl:attribute-set name="contactnumbers">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' xnal-d/contactnumbers ')]">
    <xsl:param name="authorOptions" select="'all'" tunnel="yes"/>

    <xsl:if test="$authorOptions = 'all' or 
                  index-of($authorOptions, 'contactnumbers') ge 1">
      <fo:block xsl:use-attribute-sets="contactnumbers">
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <!-- contactnumber ========== -->

  <xsl:attribute-set name="contactnumber">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' xnal-d/contactnumber ')]">
    <fo:block xsl:use-attribute-sets="contactnumber">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- emailaddresses ========== -->

  <xsl:attribute-set name="emailaddresses">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' xnal-d/emailaddresses ')]">
    <xsl:param name="authorOptions" select="'all'" tunnel="yes"/>

    <xsl:if test="$authorOptions = 'all' or 
                  index-of($authorOptions, 'emailaddresses') ge 1">
      <fo:block xsl:use-attribute-sets="emailaddresses">
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <!-- emailaddress ========== -->

  <xsl:attribute-set name="emailaddress" use-attribute-sets="link-style">
    <xsl:attribute name="font-family">monospace</xsl:attribute>
    <xsl:attribute name="font-size">90%</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' xnal-d/emailaddress ')]">
    <fo:block xsl:use-attribute-sets="emailaddress">
      <xsl:call-template name="commonAttributes"/>

      <xsl:variable name="href" select="string(.)"/>
      <xsl:variable name="href2"
                    select="if (starts-with($href, 'mailto:')) then
                                $href
                            else
                                concat('mailto:', $href)"/>

      <fo:basic-link external-destination="{concat('url(', $href2, ')')}">
        <xsl:apply-templates/>
      </fo:basic-link>
    </fo:block>
  </xsl:template>

  <!-- urls ========== -->

  <xsl:attribute-set name="urls">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' xnal-d/urls ')]">
    <xsl:param name="authorOptions" select="'all'" tunnel="yes"/>

    <xsl:if test="$authorOptions = 'all' or 
                  index-of($authorOptions, 'urls') ge 1">
      <fo:block xsl:use-attribute-sets="urls">
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <!-- url ========== -->

  <xsl:attribute-set name="url" use-attribute-sets="emailaddress">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' xnal-d/url ')]">
    <fo:block xsl:use-attribute-sets="url">
      <xsl:call-template name="commonAttributes"/>

      <xsl:variable name="href" select="string(.)"/>
      <xsl:variable name="href2"
                    select="if (contains($href, '://')) then
                                $href
                            else
                                concat('http://', $href)"/>

      <fo:basic-link external-destination="{concat('url(', $href2, ')')}">
        <xsl:apply-templates/>
      </fo:basic-link>
    </fo:block>
  </xsl:template>

  <!-- titlePage_publisher =============================================== -->

  <xsl:template name="titlePage_publisher">
    <xsl:param name="publisherOptions" select="'all'" tunnel="yes"/>

    <xsl:apply-templates
      select="*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/publisher ')]"/>
  </xsl:template>

  <!-- publisher, publisherinformation ========== -->

  <xsl:attribute-set name="document-publisher"
                     use-attribute-sets="title-page-block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' topic/publisher ')]">
    <fo:block xsl:use-attribute-sets="document-publisher">
      <xsl:call-template name="commonAttributes"/>

      <xsl:choose>
        <xsl:when test="contains(@class,' bookmap/publisherinformation ')">
          <xsl:apply-templates
            select="*[contains(@class,' bookmap/person ')] |
                    *[contains(@class,' bookmap/organization ')] |
                    *[contains(@class,' bookmap/printlocation ')]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </fo:block>
  </xsl:template>

  <!-- person ========== -->

  <xsl:attribute-set name="person">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' bookmap/person ')]">
    <fo:block xsl:use-attribute-sets="person">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- organization ========== -->

  <xsl:attribute-set name="organization">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' bookmap/organization ')]">
    <fo:block xsl:use-attribute-sets="organization">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- printlocation ========== -->

  <xsl:attribute-set name="printlocation">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' bookmap/printlocation ')]">
    <xsl:param name="publisherOptions" select="'all'" tunnel="yes"/>

    <xsl:if test="$publisherOptions = 'all' or 
                  index-of($publisherOptions, 'printlocation') ge 1">
      <fo:block xsl:use-attribute-sets="printlocation">
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <!-- titlePage_lastCritdate ============================================ -->

  <xsl:attribute-set name="last-critdate"
                     use-attribute-sets="title-page-block-style">
  </xsl:attribute-set>

  <xsl:template name="titlePage_lastCritdate">
    <xsl:variable name="date">
      <xsl:call-template name="lastCritdate"/>
    </xsl:variable>
    <xsl:if test="$date != ''">
      <fo:block xsl:use-attribute-sets="last-critdate">
        <xsl:value-of select="$date"/>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <xsl:template name="lastCritdate">
    <xsl:variable name="date" 
      select="*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/critdates ')]/*[last()]"/>
    <xsl:if test="exists($date)">
      <xsl:variable name="lang">
        <xsl:call-template name="lang"/>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="exists($date/@golive)">
          <xsl:value-of select="Date:format(string($date/@golive), $lang)"/>
        </xsl:when>
        <xsl:when test="exists($date/@modified)">
          <xsl:value-of select="Date:format(string($date/@modified), $lang)"/>
        </xsl:when>
        <xsl:when test="exists($date/@date)">
          <xsl:value-of select="Date:format(string($date/@date), $lang)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
