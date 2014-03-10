<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:saxon="http://icl.com/saxon"    
    exclude-result-prefixes="xhtml saxon"
    version="1.0">

  <xsl:import href="../../dita/desktop/common.xsl"/>
  
  <!-- 
    Flag indicating the output is feedback enabled. 
  -->
  <xsl:variable name="IS_FEEDBACK_ENABLED" select="string-length($WEBHELP_PRODUCT_ID) > 0"/>
  
  <!-- 
    Instead of overriding docbook header.navigation template, we add the permalink 
    and navigation directly. 
  -->
  
  <!-- 
    Adds the permalink and the print link in each page.
  -->
  <xsl:template match="xhtml:table[@class='docbookNav']/xhtml:tr/xhtml:th[@colspan='3']" mode="fixup_desktop">
    <xsl:copy>
      <xsl:apply-templates mode="fixup_desktop"/>
      <div id="permalink"><a href="#">
        <xsl:call-template name="getWebhelpString">
          <xsl:with-param name="stringName" select="'linkToThis'"/>
        </xsl:call-template>
      </a></div>
      <div id="printlink">
        <a href="javascript:window.print();">
          <xsl:call-template name="getWebhelpString">
            <xsl:with-param name="stringName" select="'printThisPage'"/>
          </xsl:call-template>  
        </a>
      </div>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="xhtml:td/xhtml:a[@accesskey='p']" mode="fixup_desktop">
    <span class="navprev">
      <xsl:copy>
        <xsl:apply-templates select="node() | @*" mode="fixup_desktop"/>
      </xsl:copy>
    </span>
  </xsl:template>  
  
  
  <xsl:template match="xhtml:td/xhtml:a[@accesskey='n']" mode="fixup_desktop">
    <span class="navnext">
      <xsl:copy>
        <xsl:apply-templates select="node() | @*" mode="fixup_desktop"/>
      </xsl:copy>
    </span>
  </xsl:template>
  
  
  <!-- 
    Adds body attributes. 
  -->
    <xsl:template match="xhtml:body" mode="fixup_desktop">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$IS_FEEDBACK_ENABLED">
          <xsl:attribute name="onload">init('<xsl:value-of select="$PATH2PROJ"/>')</xsl:attribute>          
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="onload">highlightSearchTerm()</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="node() | @*" mode="fixup_desktop"/>
      
      <!-- Injects the feedback div. -->
      <xsl:call-template name="generateFeedbackDiv"/>      
    </xsl:copy>
  </xsl:template>
  
  
  <!--
    Rewrites the head section.
   -->
  <xsl:template match="xhtml:head" mode="fixup_desktop">
    <head>
      <!-- All default metas.-->
      <xsl:apply-templates select="node() | @*" mode="fixup_desktop"/>
      <xsl:text xml:space="preserve">        
      </xsl:text>
      <xsl:call-template name="jsAndCSS"/>
    </head>
  </xsl:template>
  
   
  
  <!-- 
    Generic copy. 
  -->
  <xsl:template match="node() | @*" mode="fixup_desktop">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="fixup_desktop"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!--
    <xsl:template match="/">
        <xsl:apply-templates mode="fixup_desktop"/>
    </xsl:template>
  -->
  
</xsl:stylesheet>