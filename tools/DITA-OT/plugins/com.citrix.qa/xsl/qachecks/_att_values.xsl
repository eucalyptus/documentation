<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" >

<xsl:template name="att_values">

<!-- List variables found in the topic -->
<xsl:if test=".//*[exists(@otherprops)]"><li>@otherprops values: <xsl:value-of select="distinct-values(.//*/@otherprops)" separator=", "/></li></xsl:if>
<xsl:if test=".//*[exists(@audience)]"><li>@audience values: <xsl:value-of select="distinct-values(.//*/@audience)" separator=", "/></li></xsl:if>
<xsl:if test=".//*[exists(@platform)]"><li>@platform values: <xsl:value-of select="distinct-values(.//*/@platform)" separator=", "/></li></xsl:if>
<xsl:if test=".//*[exists(@product)]"><li>@product values: <xsl:value-of select="distinct-values(.//*/@product)" separator=", "/></li></xsl:if>


</xsl:template>
</xsl:stylesheet>