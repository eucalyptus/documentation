<?xml version="1.0" encoding="UTF-8" ?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:java="org.dita.dost.util.StringUtils"
    xmlns:oxygen="http://www.oxygenxml.com/functions"
    xmlns:File="java:java.io.File"
    exclude-result-prefixes="java oxygen File">

   <!-- The language used by the Webhelp indexer when it will parse the words from the HTML pages. -->
   <xsl:param name="INDEXER_LANGUAGE"/>

  <xsl:template name="generateMapTitleInBody">
      <!-- from map2htmltoc.xsl, added h1's -->
      <xsl:choose>
        <xsl:when test="/*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')]">
          <h1>
            <xsl:value-of select="normalize-space(/*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')])"/>
          </h1>          
        </xsl:when>
        <xsl:when test="/*[contains(@class,' map/map ')]/@title">
          <h1>
            <xsl:value-of select="/*[contains(@class,' map/map ')]/@title"/>
          </h1>
        </xsl:when>
      </xsl:choose>
      <xsl:value-of select="$newline"/>
      <!-- end -->
  </xsl:template>
    
  <xsl:template match="/*[contains(@class, ' map/map ')]">
    <xsl:param name="pathFromMaplist"/>
    <xsl:if test=".//*[contains(@class, ' map/topicref ')][not(@toc='no')][not(@processing-role='resource-only')]">
      <!-- OXYGEN PATCH START EXM-17248 -->
    <div id="tree">
      <ul><xsl:value-of select="$newline"/>
        <!-- OXYGEN PATCH END EXM-17248 -->
        
        <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
          <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
        </xsl:apply-templates>
      </ul>
    </div>
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>
  
    
  <xsl:template match="*[contains(@class, ' map/topicref ')][not(@toc='no')][not(@processing-role='resource-only')]">
    <xsl:param name="pathFromMaplist"/>
    <xsl:variable name="title">
      <xsl:call-template name="navtitle"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$title and $title!=''">
        <!-- OXYGEN PATCH START EXM-17960 -->
        <li id="{generate-id()}">
        <!-- OXYGEN PATCH END EXM-17960 -->
          <xsl:choose>
            <!-- If there is a reference to a DITA or HTML file, and it is not external: -->
            <xsl:when test="@href and not(@href='')">
              <xsl:element name="a">
                <xsl:attribute name="href">
                  <xsl:choose>        <!-- What if targeting a nested topic? Need to keep the ID? -->
                    <!-- edited by william on 2009-08-06 for bug:2832696 start -->
                    <xsl:when test="not(contains(@chunk, 'to-content')) and 
                      (not(@format) or @format = 'dita' or @format='ditamap' ) ">
                    <!-- edited by william on 2009-08-06 for bug:2832696 end -->
                      <xsl:if test="not(@scope='external')"><xsl:value-of select="$pathFromMaplist"/></xsl:if>
                      <xsl:call-template name="replace-extension">
                        <xsl:with-param name="filename" select="@copy-to"/>
                        <xsl:with-param name="extension" select="$OUTEXT"/>
                      </xsl:call-template>
                      <xsl:if test="not(contains(@copy-to, '#')) and contains(@href, '#')">
                        <xsl:value-of select="concat('#', substring-after(@href, '#'))"/>
                      </xsl:if>
                    </xsl:when>
                    <!-- edited by william on 2009-08-06 for bug:2832696 start -->
                    <xsl:when test="(not(@format) or @format = 'dita' or @format='ditamap')">
                    <!-- edited by william on 2009-08-06 for bug:2832696 end -->
                      <xsl:if test="not(@scope='external')"><xsl:value-of select="$pathFromMaplist"/></xsl:if>
                      <xsl:call-template name="replace-extension">
                        <xsl:with-param name="filename" select="@href"/>
                        <xsl:with-param name="extension" select="$OUTEXT"/>
                      </xsl:call-template>
                      <xsl:if test="contains(@href, '#')">
                        <xsl:value-of select="concat('#', substring-after(@href, '#'))"/>
                      </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>  <!-- If non-DITA, keep the href as-is -->
                      <xsl:if test="not(@scope='external')"><xsl:value-of select="$pathFromMaplist"/></xsl:if>
                      <xsl:value-of select="@href"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:if test="@scope='external' or @type='external' or ((@format='PDF' or @format='pdf') and not(@scope='local'))">
                  <xsl:attribute name="target">_blank</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$title"/>
              </xsl:element>
            </xsl:when>
            
            <xsl:otherwise>
              <xsl:value-of select="$title"/>
            </xsl:otherwise>
          </xsl:choose>
          
          <!-- If there are any children that should be in the TOC, process them -->
          <xsl:if test="descendant::*[contains(@class, ' map/topicref ')][not(contains(@toc,'no'))][not(@processing-role='resource-only')]">
            <xsl:value-of select="$newline"/><ul><xsl:value-of select="$newline"/>
              <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
                <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
              </xsl:apply-templates>
            </ul><xsl:value-of select="$newline"/>
          </xsl:if>
        </li><xsl:value-of select="$newline"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- if it is an empty topicref -->
        <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
          <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template name="generateCssLinks">        
    <xsl:variable name="urltest">
      <xsl:call-template name="url-string">
        <xsl:with-param name="urltext">
          <xsl:value-of select="concat($CSSPATH,$CSS)"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="string-length($CSS)>0">
      <xsl:choose>
        <xsl:when test="$urltest='url'">
          <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$CSS}">
              <xsl:comment/>
          </link>
        </xsl:when>
        <xsl:otherwise>
          <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$CSS}">
              <xsl:comment/>
          </link>
        </xsl:otherwise>
      </xsl:choose><xsl:value-of select="$newline"/>   
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>