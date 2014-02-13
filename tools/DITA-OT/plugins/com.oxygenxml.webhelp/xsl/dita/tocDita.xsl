<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:relpath="http://dita2indesign/functions/relpath"
    exclude-result-prefixes="relpath"
    version="2.0">
    
    <xsl:import href="dita-utilities.xsl"/>
    
    <!-- Extension of output files for example .html -->
    <xsl:param name="OUT_EXT" select="'.html'"/>

    <xsl:template match="/">
        <xsl:result-document href="toc.xml" method="xml">
            <toc xmlns="http://www.oxygenxml.com/ns/webhelp/toc">
                <title>
                    <xsl:choose>
                        <xsl:when test="/*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')]">
                            <xsl:copy-of select="/*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')]"/>
                        </xsl:when>
                        <xsl:when test="/*[contains(@class,' map/map ')]/@title">
                            <xsl:value-of select="/*[contains(@class,' map/map ')]/@title"/>
                        </xsl:when>
                    </xsl:choose>
                </title>
                <xsl:apply-templates mode="toc-webhelp"/>
            </toc>
        </xsl:result-document>
    </xsl:template>
    
    
    <xsl:template match="text()" mode="toc-webhelp"/>
    

    <xsl:template match="*[contains(@class, ' bookmap/booklists ')]" 
                         mode="toc-webhelp"/>
    
    <xsl:template match="*[contains(@class, ' bookmap/frontmatter ') 
                      or contains(@class, ' bookmap/backmatter ')
                      or contains(@class, ' mapgroup-d/topicgroup ')
                      or (contains(@class, ' bookmap/part ') 
                      and not(@href) and not(@navtitle))]"
                mode="toc-webhelp"
                priority="1">
        <xsl:apply-templates mode="toc-webhelp"/>
    </xsl:template>
    
  <xsl:template match="*[contains(@class, ' map/topicref ') 
                  and not(contains(@class, ' bookmap/booklists ')) 
                  and not(@processing-role='resource-only')
                  and not(@toc='no')
                  and not(ancestor::*[contains(@class, ' map/reltable ')])
                  or contains(@class, ' bookmap/part ')]" 
               mode="toc-webhelp">
        <topic xmlns="http://www.oxygenxml.com/ns/webhelp/toc">
            <xsl:choose>
                <xsl:when test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]">
                    <xsl:attribute name="title" select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"/>
                </xsl:when>
                <xsl:when test="@navtitle">
                    <xsl:attribute name="title" select="@navtitle"/>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="@copy-to">
                    <xsl:attribute name="href">
                        <xsl:call-template name="replace-extension">
                            <xsl:with-param name="filename" select="@copy-to"/>
                            <xsl:with-param name="extension" select="$OUT_EXT"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@href">
                    <xsl:attribute name="href">
                        <xsl:call-template name="replace-extension">
                            <xsl:with-param name="filename" select="@href"/>
                            <xsl:with-param name="extension" select="$OUT_EXT"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="href" select="'javascript:void(0)'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="@collection-type">
                <xsl:attribute name="collection-type" select="@collection-type"/>
            </xsl:if>
            <xsl:apply-templates mode="toc-webhelp"/>
        </topic>
    </xsl:template>
</xsl:stylesheet>