<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:fo="http://www.w3.org/1999/XSL/Format"
		xmlns:xslthl="http://xslthl.sf.net"
                exclude-result-prefixes="xslthl"
                version='1.0'>

<xsl:template match='xslthl:keyword' mode="xslthl">
  <fo:inline font-weight="bold" color="#7f0055"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:string' mode="xslthl">
  <fo:inline color="blue"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:value' mode="xslthl">
  <fo:inline color="blue"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:comment' mode="xslthl">
  <fo:inline color="#3f7f5f"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:multiline-comment' mode="xslthl">
  <fo:inline color="#3f7f5f"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:tag' mode="xslthl">
  <fo:inline color="teal"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:attribute' mode="xslthl">
  <fo:inline color="#7f0055"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:annotation' mode="xslthl">
  <fo:inline color="gray"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:directive' mode="xslthl">
  <xsl:apply-templates mode="xslthl"/>
</xsl:template>

<xsl:template match='xslthl:doccomment|xslthl:doctype' mode="xslthl">
  <fo:inline color="#3f5fbf"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>


</xsl:stylesheet>

