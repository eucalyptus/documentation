<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:saxon="http://icl.com/saxon"    
    exclude-result-prefixes="xhtml saxon"
    version="1.0">
    
    <xsl:import href="../../dita/mobile/common.xsl"/>
    <xsl:output indent="yes"/>

    <!--
        Composes the header.
        Inhibits the title in the content, as it moves to the header. 
    -->
    <xsl:template match="xhtml:div[@class = 'titlepage']" mode="fixup_mobile"/>    
    <xsl:template match="xhtml:div[@class = 'navheader']" mode="fixup_mobile">
        <div data-role="header">
            <h1>
                <xsl:attribute name="class">pageHeader</xsl:attribute>
                <xsl:apply-templates select="/xhtml:html/xhtml:head/xhtml:title/node()" mode="fixup_mobile"/>
            </h1>
            <xsl:call-template name="generateNavigationLinks"/>
        </div>        
    </xsl:template>    
    <xsl:template name="generateNavigationLinks">
        <xsl:variable name="prev" select="(//xhtml:link[@rel='prev']/@href)[1]"/>
        <xsl:variable name="next" select="(//xhtml:link[@rel='next']/@href)[1]"/>
        <div class="ui-btn-left">
            <a href="{$PATH2PROJ}index.html" data-role="button" data-icon="home" rel="external"
                data-iconpos="notext">&#160;</a>
        </div>
        <div class="ui-btn-right" data-role="controlgroup" data-iconpos="notext"
            data-type="horizontal">
            <xsl:if test="$prev">
                <a href="{$prev}" data-icon="arrow-l" data-role="button" data-iconpos="notext"
                    class="prevPage">&#160;</a>
            </xsl:if>
            <xsl:if test="$next">
                <a href="{$next}" data-icon="arrow-r" data-role="button" data-iconpos="notext"
                    class="nextPage">&#160;</a>
            </xsl:if>
        </div>
    </xsl:template>


    <!-- 
        Cleans-up the footer. The oXygen logo is converted to text.        
    -->
    <xsl:template match="xhtml:div[@class='footer']/hr" mode="fixup_mobile"/>            
    <xsl:template match="xhtml:div[@class='footer']/xhtml:a/xhtml:span[@class='oXygenLogo']" mode="fixup_mobile"> oXygen </xsl:template>
    <xsl:template match="xhtml:div[@class='footer']" mode="fixup_mobile">
      	<xsl:variable name="content">
                <xsl:apply-templates select="//xhtml:div[@class='footer']/node()" mode="fixup_mobile"/>
        </xsl:variable>
        <xsl:if test="count(saxon:node-set($content)/node()) > 0">
        	<div data-role="footer" data-theme="c">
            	<div class="footer">
                	<xsl:copy-of select="$content"/>
	            </div>
    	    </div>            
        </xsl:if>
    </xsl:template>
    <xsl:template match="xhtml:div[@class='navfooter']" mode="fixup_mobile"/>

    <!--
        Rewrites the head section.
     -->
    <xsl:template match="xhtml:head" mode="fixup_mobile">
        <head>
            <!-- All default metas.-->
            <xsl:apply-templates mode="fixup_mobile"/>
            <xsl:call-template name="jsAndCSS"/>
        </head>
    </xsl:template>

    <!-- Adds page attributes on the body. Imposes a theme and a page structure. -->
    <xsl:template match="xhtml:body" mode="fixup_mobile">
        <body data-content-theme="c" data-role="page">
            <xsl:for-each select="ancestor-or-self::*/@*">
                <xsl:if test="local-name(.) != 'id'">
                    <xsl:attribute name="{local-name(.)}">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:for-each>
            <xsl:variable name="content">
                <xsl:apply-templates mode="fixup_mobile"/>
            </xsl:variable>
            <xsl:variable name="contentClassAttribute">
                <xsl:if test="($draft.mode = 'yes' or
                              ($draft.mode = 'maybe' and
                                ancestor-or-self::*[@status][1]/@status = 'draft'))
                              and $draft.watermark.image != ''">
                    draftmode
                </xsl:if>
                content
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="saxon:node-set($content)/*[@data-role='header'] and saxon:node-set($content)/*[@data-role='footer']">
                    <!-- Now re-creates the sections JQuery mobile needs. Header, Content, Footer -->
                    <xsl:copy-of select="saxon:node-set($content)/*[@data-role='header']"/>
                    <div data-role="content" 
                         class="{normalize-space($contentClassAttribute)}">
                        <xsl:copy-of select="saxon:node-set($content)/node()[preceding-sibling::*[@data-role='header'] and following-sibling::*[@data-role='footer']]"/>
                    </div>
                    <xsl:copy-of select="saxon:node-set($content)/*[@data-role='footer']"/>
                </xsl:when>
                <xsl:when test="saxon:node-set($content)/*[@data-role='header']">
                    <!-- Now re-creates the sections JQuery mobile needs. Header, Content, Footer -->
                    <xsl:copy-of select="saxon:node-set($content)/*[@data-role='header']"/>            
                    <div data-role="content" 
                         class="{normalize-space($contentClassAttribute)}">
                        <xsl:copy-of select="saxon:node-set($content)/node()[preceding-sibling::*[@data-role='header']]"/>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <!-- No header or no footer. Dump all. -->
                    <div data-role="content" 
                         class="{normalize-space($contentClassAttribute)}">
                        <xsl:copy-of select="$content"/>
                    </div>
                </xsl:otherwise>                
            </xsl:choose>
        </body>
    </xsl:template>

    <!-- 
        Remove only the css and scripts from the oXygen webhelp system. Other scripts are left in place. 
    -->
    <xsl:template match="xhtml:script[contains(@src, 'oxygen-webhelp/resources/')]" mode="fixup_mobile"/>
    <xsl:template match="xhtml:link[contains(@href, 'oxygen-webhelp/resources/')]" mode="fixup_mobile"/>
    
    <!-- 
        Navigating from TOC to a page and hitting Home on that page lead to the 
        impossibility to change the tab to "Search" or "Index", from "Content".
        
        This looks like it fixes the problem.
    -->
    <xsl:template match="xhtml:a[not(@onclick)]" mode="fixup_mobile">
        <xsl:copy>
          <xsl:choose>
            <xsl:when test="contains(@href, '#')">
              <!-- The href contains a fragment. Because we have to keep it,
              put ajax="false" on the link, in order to preserve its functionality and 
              not break jQuery mobile.
              -->
              <xsl:copy-of select="@href"/>
              <xsl:attribute name="data-ajax">false</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="@href"/>
            </xsl:otherwise>
          </xsl:choose>
          
          <!-- Copy all other attributes. -->
          <xsl:copy-of select="@*[name() != 'href']"/>
          <xsl:attribute name="onclick">return true;</xsl:attribute>
          <xsl:apply-templates mode="fixup_mobile"/>
        </xsl:copy>
    </xsl:template>

    <!-- Embedded TOC -->
    <xsl:template match="xhtml:div[@class='toc']/xhtml:p" mode="fixup_mobile"/>
    <xsl:template match="xhtml:div[@class='toc']/xhtml:dl" mode="fixup_mobile">
        <!-- If there is no element before the listview, the swiping is not enabled (jQuery Mobile bug.) -->
        <div class="tocSeparatorBefore">&#160;</div>
        <ul data-role="listview">
            <xsl:for-each select="xhtml:dt">
                <li>
                    <xsl:apply-templates select="xhtml:span/*" mode="fixup_mobile"/>
                </li>
            </xsl:for-each>
        </ul>    
        <div class="tocSeparatorAfter">&#160;</div>
    </xsl:template>

    <!-- 
        Generic copy. 
    -->
    <xsl:template match="node() | @*" mode="fixup_mobile">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="fixup_mobile"/>
        </xsl:copy>
    </xsl:template>
    <!--
    <xsl:template match="/">
        <xsl:apply-templates mode="fixup_mobile"/>
    </xsl:template>-->
</xsl:stylesheet>
