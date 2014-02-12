<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">

<xsl:template name="nesting_elements">

<!-- Nesting problems -->
<xsl:if test=".//p//ol/li"><li class="tagerror">OL embedded in P element</li></xsl:if>
<xsl:if test=".//p//ul/li"><li class="tagerror">UL embedded in P element</li></xsl:if>
<xsl:if test=".//p//note"><li class="tagerror">NOTE embedded in P element</li></xsl:if>
<xsl:if test=".//p//dl/dlentry"><li class="tagerror">DL embedded in P element</li></xsl:if>
<xsl:if test=".//p//simpletable"><li class="tagerror">SimpleTable embedded in P element</li></xsl:if>
<xsl:if test=".//dl//simpletable"><li class="tagerror">SimpleTable embedded in DL element</li></xsl:if>
<xsl:if test=".//p//table"><li class="tagerror">TABLE embedded in P element</li></xsl:if>
<xsl:if test=".//dl//table"><li class="tagerror">TABLE embedded in DL element</li></xsl:if>
<xsl:if test=".//dl//dd[p]"><li class="tagerror">P embedded inside a DD</li></xsl:if>
<xsl:if test=".//dl//dt[p]"><li class="tagerror">P embedded inside a DD</li></xsl:if>
<xsl:if test=".//dl//dl"><li class="tagerror">DL embedded inside a DL</li></xsl:if>
<xsl:if test=".//simpletable//stentry[p]"><li class="tagerror">P embedded inside a simpletable</li></xsl:if>
<xsl:if test=".//table//entry[p]"><li class="tagerror">P embedded inside a table entry</li></xsl:if>


</xsl:template>
</xsl:stylesheet>