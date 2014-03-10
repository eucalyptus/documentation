<?xml version='1.0'?>
<!--
    
Oxygen Codeblock Highlights plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file README.txt 
available in the base directory of this plugin.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xslthl="http://xslthl.sf.net"
    exclude-result-prefixes="xslthl"
    version="2.0">
  
  <xsl:include href="common.xsl"/>
  
  <!-- Pre -->
  <xsl:template match="*[contains(@class,' topic/pre ')]">
        <xsl:call-template name="setSpecTitle"/>
        <xsl:variable name="attrSets">
            <xsl:call-template name="setFrame"/>
        </xsl:variable>
        <fo:block xsl:use-attribute-sets="pre">
            <xsl:call-template name="commonattributes"/>
            <!--TODO: $attrSets contains space-separated names!! Check if this actually works. -->
            <xsl:call-template name="processAttrSetReflection">
                <xsl:with-param name="attrSet" select="$attrSets"/>
                <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
            </xsl:call-template>
            <xsl:call-template name="setScale"/>
            <xsl:call-template name="outputStyling"/>
        </fo:block>
    </xsl:template>

  <xsl:template match='xslthl:keyword' mode="xslthl">
    <fo:inline font-weight="bold"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:string' mode="xslthl">
    <fo:inline font-weight="bold" font-style="italic"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:comment' mode="xslthl">
    <fo:inline font-style="italic"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:tag' mode="xslthl">
    <fo:inline font-weight="bold"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:attribute' mode="xslthl">
    <fo:inline font-weight="bold"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:value' mode="xslthl">
    <fo:inline font-weight="bold"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:number' mode="xslthl">
    <xsl:apply-templates mode="xslthl"/>
  </xsl:template>
  
  <xsl:template match='xslthl:annotation' mode="xslthl">
    <fo:inline color="gray"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:directive' mode="xslthl">
    <xsl:apply-templates mode="xslthl"/>
  </xsl:template>
  
  <!-- Not sure which element will be in final XSLTHL 2.0 -->
  <xsl:template match='xslthl:doccomment|xslthl:doctype' mode="xslthl">
    <fo:inline font-weight="bold"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <!-- Color syntax highlight-->  
  <!--<xsl:template match='xslthl:keyword' mode="xslthl">
    <fo:inline font-weight="bold" color="#7f0055"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:string' mode="xslthl">
    <fo:inline font-weight="bold" font-style="italic" color="2a00ff"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:comment' mode="xslthl">
    <fo:inline font-style="italic" color="#006400"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:tag' mode="xslthl">
    <fo:inline font-weight="bold" color="#000096"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:attribute' mode="xslthl">
    <fo:inline font-weight="bold" color="#ff7935"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:value' mode="xslthl">
    <fo:inline font-weight="bold" color="#993300" ><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:number' mode="xslthl">
    <xsl:apply-templates mode="xslthl"/>
  </xsl:template>
  
  <xsl:template match='xslthl:annotation' mode="xslthl">
    <fo:inline color="gray"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:directive' mode="xslthl">
    <fo:inline color="#8b26c9"><xsl:apply-templates mode="xslthl"/></fo:inline>
    <xsl:apply-templates mode="xslthl"/>
  </xsl:template>
  
  <!-\- Not sure which element will be in final XSLTHL 2.0 -\->
  <xsl:template match='xslthl:doccomment' mode="xslthl">
    <fo:inline font-weight="bold" color="#3f5fbf"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:doctype' mode="xslthl">
    <fo:inline font-weight="bold" color="#0000ff"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>-->
</xsl:stylesheet>