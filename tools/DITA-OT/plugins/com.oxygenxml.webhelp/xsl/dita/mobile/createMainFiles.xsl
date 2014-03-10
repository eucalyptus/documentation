<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
    xmlns:oxygen="http://www.oxygenxml.com/functions"
    xmlns:index="http://www.oxygenxml.com/ns/webhelp/index" version="2.0">
    
    <xsl:import href="../../createMainFiles.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <!-- Using the "mobile skin "-->
    <xsl:template name="get-skin-name">
        <xsl:param name="withFrames"/> mobile </xsl:template>


    <!-- Inhibit the creation of the TOC for the frames version. -->
    <xsl:template name="create-toc-frames-file">
        <xsl:param name="toc"/>
        <xsl:param name="title"/>
        <!-- Do nothing. -->
    </xsl:template>

    <xsl:template name="create-navigation">
        <xsl:param name="selected"/>
        <xsl:param name="title"/>

        <div data-role="header" data-position="fixed" data-theme="c">
            <h1>
                <xsl:copy-of select="$title"/>
            </h1>            
            <div data-role="navbar">
                <ul>
                    <li><a href="#tocPage" data-role="tab" data-icon="grid">
                        <xsl:if test="$selected = 'tocPage'">
                            <xsl:attribute name="class">ui-btn-active</xsl:attribute>
                        </xsl:if>
                        <xsl:call-template name="getWebhelpString">
                            <xsl:with-param name="stringName" select="'Content'"/>
                        </xsl:call-template>                  
                        </a></li>
                    <li><a href="#searchPage" data-role="tab" data-icon="search">
                        <xsl:if test="$selected = 'searchPage'">
                            <xsl:attribute name="class">ui-btn-active</xsl:attribute>
                        </xsl:if>
                        <xsl:call-template name="getWebhelpString">
                            <xsl:with-param name="stringName" select="'Search'"/>
                        </xsl:call-template>
                        </a></li>
                    <xsl:if test="count($index/*) > 0">
                        <li><a href="#indexPage" data-role="tab" data-icon="info">
                            <xsl:if test="$selected = 'indexPage'">
                                <xsl:attribute name="class">ui-btn-active</xsl:attribute>
                            </xsl:if>
                            <xsl:call-template name="getWebhelpString">
                                <xsl:with-param name="stringName" select="'Index'"/>
                            </xsl:call-template>
                            </a></li>
                    </xsl:if>
                </ul>                                 
            </div>
        </div>
    </xsl:template>

    <!-- 
    Common part for TOC creation.
  -->
    <xsl:template name="create-toc-common-file">
        <xsl:param name="toc"/>
        <xsl:param name="title" as="node()"/>
        <xsl:param name="fileName"/>
        <!-- toc.xml pt frame-uri, index.html pentru no frames.-->
        <xsl:param name="withFrames" as="xs:boolean"/>

        <xsl:result-document href="{$fileName}" method="xhtml" indent="yes" encoding="UTF-8"
            doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
            omit-xml-declaration="yes">
            <html>
                <head>
                    <title>
                        <xsl:copy-of select="$title"/>
                    </title>
                    <xsl:call-template name="jsAndCSS"/>                    
                </head>
                <body>
                    <xsl:if test="not($withFrames)">
                        <!-- Custom JavaScript code set by param webhelp.body.script -->
                        <xsl:call-template name="jsInBody"/>
                    </xsl:if>
                    <!-- toc -->
                    <div id="tocPage" data-role="page">
                        <xsl:call-template name="create-navigation">
                            <xsl:with-param name="selected" select="'tocPage'"/>
                            <xsl:with-param name="title" select="$title"/>
                        </xsl:call-template>
                        
                        <div data-role="content">
                            <ul data-role="listview" data-theme="c">
                                <xsl:apply-templates select="$toc/toc:topic" mode="create-toc"/>
                            </ul>
                        </div>
                        
                        <xsl:variable name="legalSection">
                            <xsl:call-template name="create-legal-section"/>
                        </xsl:variable>
                        <xsl:if test="count($legalSection/*) > 0">
                            <div data-role="footer">
                                <xsl:copy-of select="$legalSection"/>
                            </div>                                                    
                        </xsl:if>
                    </div>
                    
                    <!-- search -->
                    <div id="searchPage" data-role="page">
                        <xsl:call-template name="create-navigation">
                            <xsl:with-param name="selected" select="'searchPage'"/>
                            <xsl:with-param name="title" select="$title"/>
                        </xsl:call-template>
                        <div data-role="content">
                            <!-- The .blur function hides the virtual keyboard. -->
                            <form name="searchForm" id="searchForm" 
                                action="javascript:void(0)" 
                                onsubmit="SearchToc('searchForm');$('#textToSearch').blur();">
                                <xsl:call-template name="getWebhelpString">
                                    <xsl:with-param name="stringName" select="'Keywords'"/>
                                </xsl:call-template>
                                <xsl:text>: </xsl:text>
                                <xsl:comment/>
                                <input type="text" id="textToSearch" name="textToSearch" class="textToSearch" size="30"/>
                                <xsl:comment/>
                                <xsl:variable name="searchLabel">
                                    <xsl:call-template name="getWebhelpString">
                                        <xsl:with-param name="stringName" select="'Search'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <input type="submit" value="{$searchLabel}" name="Search"
                                    class="searchButton"/>
                            </form>
                            <div id="searchResults">
                                <xsl:comment/>
                            </div>
                        </div>
                    </div>
                    
                    <!-- index -->
                    <xsl:if test="count($index/*) > 0">
                        <div id="indexPage"  data-role="page">
                            <xsl:call-template name="create-navigation">
                                <xsl:with-param name="selected" select="'indexPage'"/>
                                <xsl:with-param name="title" select="$title"/>
                            </xsl:call-template>

                            <div data-role="content">
                                <xsl:apply-templates select="$index" mode="create-index"/>
                            </div>
                        </div>
                    </xsl:if>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <!-- 
        Recursive generation of the TOC. Only top level links are displayed - level 1 chapters, 
        with one exception: topic groups. 
    -->
    <xsl:template match="toc:topic" mode="create-toc">
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="@title">
                    <xsl:value-of select="@title"/>
                </xsl:when>
                <xsl:when test="@navtitle">
                    <xsl:value-of select="@navtitle"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <li>
            <xsl:choose>
                <xsl:when test="@href">
                    <a href="{if (contains(@href, '#')) then substring-before(@href, '#') else @href}" 
                            onclick="return true;">
                        <xsl:value-of select="$title"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$title"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="toc:topic and @href='javascript:void(0)'">
                <!-- Descend into the the child topics only if the parent does not have a norma HREF (is a topic group) -->
                <ul>
                    <xsl:apply-templates select="toc:topic" mode="create-toc"/>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>

    <!-- Change from a hierarchy to a flat list.-->
    <xsl:template match="index:index" mode="create-index">
        <ul id="indexList" data-role="listview" data-filter="true">
            <xsl:for-each select="//index:target">
                <li>
                <a href="{.}">
                    <xsl:for-each select="ancestor-or-self::index:term">
                        <xsl:value-of select="@name" />
                        <xsl:if test="position() != last()">, </xsl:if>
                    </xsl:for-each> 
                </a>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    

</xsl:stylesheet>
