<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:oxygen="http://www.oxygenxml.com/functions"
    exclude-result-prefixes="oxygen"
    version="2.0">
    
    <xsl:function name="oxygen:makeURL" as="item()">
        <xsl:param name="filepath"/>
        <xsl:variable name="correctedPath" select="replace($filepath, '\\', '/')"/>
        <xsl:variable name="url">
            <xsl:choose>
                <!-- Mac / Linux paths start with / -->
                <xsl:when test="starts-with($correctedPath, '/')">
                    <xsl:value-of select="concat('file://', $correctedPath)"/>
                </xsl:when>
                <!-- Windows paths not start with / -->
                <xsl:otherwise>
                    <xsl:value-of select="concat('file:///', $correctedPath)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$url"/>
    </xsl:function>
</xsl:stylesheet>