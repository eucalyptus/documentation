<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    version="1.1">

<xsl:import href="xslthl.xsl"/>
<xsl:import href="highlight_fo.xsl"/>
<xsl:import href="../xslthl-config.xsl"/>

<xsl:template match="*[contains(@class,' pr-d/codeblock ')]">

        <xsl:call-template name="generateAttrLabel"/>
        <fo:block xsl:use-attribute-sets="codeblock" id="{@id}">
            <xsl:call-template name="setScale"/>
            <!-- rules have to be applied within the scope of the PRE box; else they start from page margin! -->
            <xsl:if test="contains(@frame,'top')">
                <fo:block>
                    <fo:leader xsl:use-attribute-sets="codeblock__top"/>
                </fo:block>
            </xsl:if>
            
            <xsl:call-template name="syntax-highlight">
                <xsl:with-param name="language" select="@outputclass" />
                <xsl:with-param name="source" select="." />
                <xsl:with-param name="config" select="$xslthl.config" />
            </xsl:call-template>

            <xsl:if test="contains(@frame,'bot')">
                <fo:block>
                    <fo:leader xsl:use-attribute-sets="codeblock__bottom"/>
                </fo:block>
            </xsl:if>
        </fo:block>

</xsl:template>




</xsl:stylesheet>
