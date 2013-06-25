<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">

  
<xsl:template name="output_standards">

<!-- Stuff to make the output work -->
<xsl:if test="//concept[not(prolog)]|//task[not(prolog)]"><li class="ditaerror">Topic does not include a prolog</li></xsl:if>
<xsl:if test="//topic[not(@id)]"><li class="tagerror">topic element is missing ID</li></xsl:if>
<xsl:if test="//concept[not(@id)]"><li class="tagerror">concept element is missing ID</li></xsl:if>
<xsl:if test="//task[not(@id)]"><li class="tagerror">task element is missing ID</li></xsl:if>
<xsl:if test="//reference[not(@id)]"><li class="tagerror">reference element is missing ID</li></xsl:if>
<xsl:if test=".//shortdesc[not(@otherprops='DraftStatusOn')]"><li class="tagerror">ShortDesc does not have DraftStatusOn</li></xsl:if>
<xsl:if test=".//draft-comment[not(@otherprops='DraftStatusOn')]"><li class="tagerror">Draft-Comment does not have DraftStatusOn</li></xsl:if>
<xsl:if test=".//bookmap[not(@linking='none')]"><li class="tagerror">BOOKMAP does not have attribute linking as none</li></xsl:if>
<xsl:if test="ancestor::*[1][not(@xml:lang)]"><li class="tagerror">Topic does not have xml:lang attribute set on element: <xsl:value-of select="./@xtrc"/></li></xsl:if>
<xsl:if test=".//dlentry/dd[position()>1]"><li class="tagerror">DLEntry has more than one definition (DD)</li></xsl:if>
<xsl:if test=".//strow[not(node())]"><li class="syntaxerror">Delete empty simple table rows</li></xsl:if>
<xsl:if test=".//row[not(node())]"><li class="syntaxerror">Delete empty table rows</li></xsl:if>

<!--<xsl:if test=".[not(@xml:lang)]|//task[not(@xml:lang)]|//reference[not(@xml:lang)]"><li class="tagerror">Topic does not have xml:lang attribute set on element: <xsl:value-of select="./@xtrc"/></li></xsl:if>
-->

</xsl:template>
</xsl:stylesheet>