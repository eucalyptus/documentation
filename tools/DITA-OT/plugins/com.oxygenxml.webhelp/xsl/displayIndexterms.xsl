<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:index="http://www.oxygenxml.com/ns/webhelp/index"
    version="1.0">
    
    <xsl:output omit-xml-declaration="yes"/>
    
    <xsl:template match="index:index">
        <xsl:if test="index:term">
            <ul>
                <xsl:apply-templates select="index:term"/>
            </ul>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="index:term">
        <li>
            <xsl:value-of select="@name"/>
            <xsl:for-each select="index:target">
                <xsl:text>  </xsl:text>
                <a href="{.}" target="contentwin">[<xsl:value-of select="position()"/>]</a>
                <xsl:text>  </xsl:text>
            </xsl:for-each>
            <xsl:if test="index:term">
                <ul>
                    <xsl:apply-templates select="index:term"/>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>
</xsl:stylesheet>