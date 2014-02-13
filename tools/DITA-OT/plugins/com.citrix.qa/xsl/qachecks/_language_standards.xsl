<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:qa="****Function Processing****">
<!-- Use this function to handle the following checks...shows error in xmlspy, but 2.0 should be able to handle xsl:function-->

<xsl:function name="qa:checkCase">
    <xsl:param name="string"/>
		<xsl:variable name="lowString" select="lower-case($string)"/>
		<xsl:variable name="regString" select="$string"/>
		<xsl:choose>
			<xsl:when test="$lowString = $regString">
					<!--<xsl:value-of select="string('PASS')"/>-->
			</xsl:when>
			<xsl:when test="not($lowString = $regString)">
					<xsl:value-of select="string( '- FAILED Interaction filename test - Change XML filename to lowercase')"/>
			</xsl:when>
		</xsl:choose>
  </xsl:function>
  
<xsl:template name="language_standards">

<!-- Language standards to enforce -->
<xsl:if test="ancestor::concept/title[starts-with(normalize-space(.), 'To')]"><li class="standard">Title does not match standard for topic type</li></xsl:if>
<xsl:if test="ancestor::task/title[(not(starts-with(normalize-space(.), 'To'))) and (not(contains(., 'ing')))]"><li class="standard">Title does not match standard for topic type</li></xsl:if>
<xsl:if test=".//*/text()[contains(., 'dialog')][not(contains(., 'dialog box'))]"><li>Do not use "dialog." Use "dialog box."</li></xsl:if>

<!-- using ancestor:: will cause false positives on topics nested beneath a topic causing a valid error -->
<xsl:if test="ancestor::concept/title[contains(., 'Review')]"><li class="standard">Replace "Review" with "Test Your Knowledge"</li></xsl:if>
<xsl:if test="ancestor::concept/title[contains(., 'Practice')]"><li class="standard">Replace "Practice" with "Test Your Knowledge"</li></xsl:if>

<!-- Check for capital letters and spaces in links -->
<xsl:if test=".//keyword[4][not(processing-instruction('xm-replace_text'))][contains(., ' ')]"><li class="syntaxerror">Interaction filename contains a space</li></xsl:if>
<xsl:if test=".//keyword[4][//keyword[2][text() = 'flashON']]/text()"><li class="tagerror">Interaction FlashON  <xsl:for-each select=".//keyword[4][//keyword[2][text() = 'flashON']]/text()"><xsl:value-of select="qa:checkCase(.)"/></xsl:for-each></li></xsl:if>						

<!-- Check for file names undesireable characters --> <!-- not sure if this works -->
<xsl:if test="./@xtrf[matches(., ' !-~ ' )]"><li class="syntaxerror">DITA file contains a space or undesireable character. Please rename the file, and only include lower case letters and underscores.</li></xsl:if>



</xsl:template>
</xsl:stylesheet>