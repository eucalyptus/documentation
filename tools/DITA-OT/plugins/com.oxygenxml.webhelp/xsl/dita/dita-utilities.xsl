<?xml version="1.0" encoding="utf-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  exclude-result-prefixes="relpath">

  
  <xsl:import href="original/dita-utilities.xsl"/>
  <xsl:include href="original/output-message.xsl"/>

  <xsl:variable name="msgprefix">DOTX</xsl:variable>
  
  <!-- Uses the DITA localization architecture, but our strings. -->
  <xsl:template name="getWebhelpString">
    <xsl:param name="stringName" />
    <xsl:param name="stringFileList" select="document('../../oxygen-webhelp/resources/localization/allstrings.xml')/allstrings/stringfile"/>
    <xsl:call-template name="getString">
      <xsl:with-param name="stringName" select="$stringName"/>
      <xsl:with-param name="stringFileList" select="$stringFileList"/>
    </xsl:call-template>
  </xsl:template>
  

  <!-- Replace file extension in a URI -->
  <xsl:template name="replace-extension">
    <xsl:param name="filename"/>
    <xsl:param name="extension"/>
    <xsl:param name="ignore-fragment" select="false()"/>
    <xsl:variable name="file-path">
        <xsl:choose>
            <xsl:when test="contains($filename, '#')">
                <xsl:value-of select="substring-before($filename, '#')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$filename"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="f">
        <xsl:call-template name="substring-before-last">
            <xsl:with-param name="text" select="$file-path"/>
            <xsl:with-param name="delim" select="'.'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="original-extension">
        <xsl:call-template name="substring-after-last">
            <xsl:with-param name="text" select="$file-path"/>
            <xsl:with-param name="delim" select="'.'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:if test="string($f)">
        <xsl:choose>
            <xsl:when test="$original-extension = 'xml' or $original-extension = 'dita'">
                <xsl:value-of select="concat($f, $extension)"/>  
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($f, '.', $original-extension)"/>  
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
    <xsl:if test="not($ignore-fragment) and contains($filename, '#')">
        <xsl:value-of select="concat('#', substring-after($filename, '#'))"/>
    </xsl:if>
  </xsl:template>
    

  <xsl:template name="substring-after-last">
    <xsl:param name="text"/>
    <xsl:param name="delim"/>
    
    <xsl:if test="string($text) and string($delim)">
        <xsl:variable name="tail" select="substring-after($text, $delim)" />
        <xsl:choose>
            <xsl:when test="string-length($tail) > 0">
                <xsl:call-template name="substring-after-last">
                    <xsl:with-param name="text" select="$tail" />
                    <xsl:with-param name="delim" select="$delim" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
  </xsl:template>
    
</xsl:stylesheet>
