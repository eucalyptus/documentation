<!-- 
All of this code was taken from: http://xslthl.wiki.sourceforge.net/Usage
 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:s6hl="http://net.sf.xslthl/ConnectorSaxon6"
    xmlns:sbhl="http://net.sf.xslthl/ConnectorSaxonB"
    xmlns:xhl="http://net.sf.xslthl/ConnectorXalan"
 
    xmlns:saxon6="http://icl.com/saxon"
    xmlns:saxonb="http://saxon.sf.net/"
    xmlns:xalan="http://xml.apache.org/xalan"
 
    xmlns:xslthl="http://xslthl.sf.net"
 
    extension-element-prefixes="s6hl sbhl xhl xslthl"
>
 
    <!-- for Xalan 2.7 -->
    <xalan:component prefix="xhl" functions="highlight">
        <xalan:script lang="javaclass" src="xalan://net.sf.xslthl.ConnectorXalan" />
    </xalan:component>
 
    <!-- for saxon 6 -->
    <saxon6:script implements-prefix="s6hl" language="java"
        src="java:net.sf.xslthl.ConnectorSaxon6" />
 
    <!-- for saxon 8.5 and later -->
    <saxonb:script implements-prefix="sbhl" language="java"
        src="java:net.sf.xslthl.ConnectorSaxonB" />
 
     <xsl:template name="syntax-highlight">
        <xsl:param name="language" />
        <xsl:param name="source" />
        <xsl:param name="config"></xsl:param>
        <xsl:choose>
            <xsl:when test="function-available('s6hl:highlight')">            	
                <xsl:variable name="highlighted" select="s6hl:highlight($language, $source, $config)" />
                <xsl:apply-templates select="$highlighted" mode="xslthl"/>
            </xsl:when>
            <xsl:when test="function-available('sbhl:highlight')">
                <xsl:variable name="highlighted" select="sbhl:highlight($language, $source, $config)" />
                <xsl:apply-templates select="$highlighted" mode="xslthl"/>
            </xsl:when>
            <xsl:when test="function-available('xhl:highlight')">            	
                <xsl:variable name="highlighted" select="xhl:highlight($language, $source, $config)" />
                <xsl:apply-templates select="$highlighted" mode="xslthl"/> 
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$source/*|$source/text()" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 
 </xsl:stylesheet>
