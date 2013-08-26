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
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                xmlns:URI="java:com.xmlmind.ditac.xslt.URI"
                xmlns:Date="java:com.xmlmind.ditac.xslt.Date"
                exclude-result-prefixes="xs ditac xhtml URI Date"
                version="2.0">

  <xsl:preserve-space elements="addressdetails"/>

  <xsl:template match="ditac:titlePage">
    <xsl:choose>
      <xsl:when test="$title-page eq 'none'">
        <!-- Nothing to do. -->
        <!-- The titlePage is always added to the first chunk: this cannot
             create an empty HTML page. -->
      </xsl:when>

      <xsl:when test="$title-page eq 'auto'">
        <xsl:call-template name="autoTitlePage"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:call-template name="customTitlePage"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="autoTitlePage">
    <div class="title-page" id="__TP">
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
    </div>
  </xsl:template>

  <xsl:template name="customTitlePage">
    <xsl:variable name="titlePageURI" 
                  select="resolve-uri($title-page, URI:userDirectory())"/>
    <xsl:choose>
      <xsl:when test="doc-available($titlePageURI)">
        <xsl:variable name="titlePage" select="doc($titlePageURI)"/>
        <xsl:variable name="titlePageContents"
                      select="$titlePage//xhtml:body/node()"/>
        <xsl:choose>
          <xsl:when test="exists($titlePageContents)">
            <div id="__TP">
              <xsl:copy-of select="$titlePageContents"/>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes" 
                         select="concat('&quot;', $titlePageURI, 
                                        '&quot; is not an XHTML document.')"/>
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

  <xsl:template match="*[contains(@class,' bookmap/mainbooktitle ')] |
                       ditac:titlePage/*[contains(@class,' topic/title ')]">
    <h1>
      <xsl:call-template name="commonAttributes">
        <xsl:with-param name="class">document-title</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </h1>
  </xsl:template>

  <!-- titlePage_titlealt ================================================ -->

  <xsl:template name="titlePage_titlealt">
    <xsl:apply-templates
      select="*[contains(@class,' bookmap/booktitle ')]/*[contains(@class,' bookmap/booktitlealt ')]"/>
  </xsl:template>

  <!-- booktitlealt ========== -->

  <xsl:template match="*[contains(@class,' bookmap/booktitlealt ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- titlePage_library ================================================= -->

  <xsl:template name="titlePage_library">
    <xsl:apply-templates
      select="*[contains(@class,' bookmap/booktitle ')]/*[contains(@class,' bookmap/booklibrary ')]"/>
  </xsl:template>

  <!-- booklibrary ========== -->

  <xsl:template match="*[contains(@class,' bookmap/booklibrary ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- titlePage_author ================================================== -->

  <xsl:template name="titlePage_author">
    <xsl:param name="authorOptions" select="'all'" tunnel="yes"/>

    <xsl:apply-templates
      select="*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/author ')]"/>
  </xsl:template>

  <!-- author, authorinformation ========== -->

  <xsl:template match="*[contains(@class,' topic/author ')]">
    <div>
      <xsl:call-template name="commonAttributes">
        <xsl:with-param name="class">document-author</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- personinfo ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/personinfo ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- organizationinfo ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/organizationinfo ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- namedetails ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/namedetails ')]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- personname ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/personname ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>

      <div class="full-name">
        <xsl:apply-templates 
          select="* except *[contains(@class,' xnal-d/otherinfo ')]"/>
      </div>

      <xsl:apply-templates select="*[contains(@class,' xnal-d/otherinfo ')]"/>
    </div>
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

  <xsl:template match="*[contains(@class,' xnal-d/organizationnamedetails ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- organizationname ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/organizationname ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- otherinfo ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/otherinfo ')]">
    <xsl:param name="authorOptions" select="'all'" tunnel="yes"/>

    <xsl:if test="$authorOptions eq 'all' or 
                  index-of($authorOptions, 'otherinfo') ge 1">
      <div>
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- addressdetails ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/addressdetails ')]">
    <xsl:param name="authorOptions" select="'all'" tunnel="yes"/>

    <xsl:if test="$authorOptions eq 'all' or 
                  index-of($authorOptions, 'addressdetails') ge 1">
      <pre>
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </pre>
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

  <xsl:template match="*[contains(@class,' xnal-d/contactnumbers ')]">
    <xsl:param name="authorOptions" select="'all'" tunnel="yes"/>

    <xsl:if test="$authorOptions eq 'all' or 
                  index-of($authorOptions, 'contactnumbers') ge 1">
      <div>
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- contactnumber ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/contactnumber ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- emailaddresses ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/emailaddresses ')]">
    <xsl:param name="authorOptions" select="'all'" tunnel="yes"/>

    <xsl:if test="$authorOptions eq 'all' or 
                  index-of($authorOptions, 'emailaddresses') ge 1">
      <div>
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- emailaddress ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/emailaddress ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>

      <xsl:variable name="href" select="string(.)"/>
      <a href="{if (starts-with($href, 'mailto:')) then
                    $href
                else
                    concat('mailto:', $href)}">
        <xsl:apply-templates/>
      </a>
    </div>
  </xsl:template>

  <!-- urls ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/urls ')]">
    <xsl:param name="authorOptions" select="'all'" tunnel="yes"/>

    <xsl:if test="$authorOptions eq 'all' or 
                  index-of($authorOptions, 'urls') ge 1">
      <div>
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- url ========== -->

  <xsl:template match="*[contains(@class,' xnal-d/url ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>

      <xsl:variable name="href" select="string(.)"/>
      <a href="{if (contains($href, '://')) then
                    $href
                else
                    concat('http://', $href)}">
        <xsl:apply-templates/>
      </a>
    </div>
  </xsl:template>

  <!-- titlePage_publisher =============================================== -->

  <xsl:template name="titlePage_publisher">
    <xsl:param name="publisherOptions" select="'all'" tunnel="yes"/>

    <xsl:apply-templates
      select="*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/publisher ')]"/>
  </xsl:template>

  <!-- publisher, publisherinformation ========== -->

  <xsl:template match="*[contains(@class,' topic/publisher ')]">
    <div>
      <xsl:call-template name="commonAttributes">
        <xsl:with-param name="class">document-publisher</xsl:with-param>
      </xsl:call-template>

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
    </div>
  </xsl:template>

  <!-- person ========== -->

  <xsl:template match="*[contains(@class,' bookmap/person ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- organization ========== -->

  <xsl:template match="*[contains(@class,' bookmap/organization ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- printlocation ========== -->

  <xsl:template match="*[contains(@class,' bookmap/printlocation ')]">
    <xsl:param name="publisherOptions" select="'all'" tunnel="yes"/>

    <xsl:if test="$publisherOptions eq 'all' or 
                  index-of($publisherOptions, 'printlocation') ge 1">
      <div>
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- titlePage_lastCritdate ============================================ -->

  <xsl:template name="titlePage_lastCritdate">
    <xsl:variable name="date" 
      select="*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/critdates ')]/*[last()]"/>
    <xsl:if test="exists($date)">
      <xsl:variable name="lang">
        <xsl:call-template name="lang"/>
      </xsl:variable>

      <div class="last-critdate">
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
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
