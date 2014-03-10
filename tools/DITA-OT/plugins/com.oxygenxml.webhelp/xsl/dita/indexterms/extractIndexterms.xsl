<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:relpath="http://dita2indesign/functions/relpath"
    exclude-result-prefixes="xs relpath"
    version="2.0">

  <xsl:import href="../original/relpath_util.xsl"/>
  <xsl:import href="../dita-utilities.xsl"/>
    
    <!-- The prefix of the input XML file path. -->
    <xsl:param name="TEMPFOLDER"/>
    
    <!-- Extension of output files for example .html -->
    <xsl:param name="OUT_EXT"/>
    
    <xsl:template match="/">
        <index xmlns="http://www.oxygenxml.com/ns/webhelp/index">
            <xsl:apply-templates/>
        </index>
    </xsl:template>

    <xsl:template match="text()|@*"/>
    
    <xsl:template match="*[contains(@class, ' topic/indexterm ')]">
      <term xmlns="http://www.oxygenxml.com/ns/webhelp/index" name="{normalize-space(string-join(text(), ' '))}">
            <xsl:choose>
                <xsl:when test="*[contains(@class, ' topic/indexterm ')]">
                    <xsl:apply-templates select="*[contains(@class, ' topic/indexterm ')]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="target">
                        <xsl:call-template name="replace-extension">
                            <xsl:with-param name="filename" select="substring-after(relpath:unencodeUri(document-uri(/)), concat(replace($TEMPFOLDER, '\\', '/'), '/'))"/>
                            <xsl:with-param name="extension" select="$OUT_EXT"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
      </term>
    </xsl:template>
</xsl:stylesheet>