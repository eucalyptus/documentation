<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<!-- Use this function to handle the following checks...shows error in xmlspy, but 2.0 should be able to handle xsl:function-->


<xsl:template name="citrix_terms">

<xsl:variable name="excludes" select="not (codeblock or draft-comment or filepath or shortdesc or uicontrol or varname)"/>

<!-- Product specific terminology -->
<xsl:if test=".//*[$excludes]/text()[contains(.,'access management console')]"><li class="prodterm">access management console should be "AppCenter"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'best practice')]"><li class="prodterm">best
	practice should be "Eucalyptus recommends"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'dazzle')]"><li class="prodterm">dazzle should be "Receiver"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'delivery services console')]"><li class="prodterm">delivery services console should be "AppCenter"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'easycall')]"><li class="prodterm">EasyCall is EOL; remove all references</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'http://www.eucalyptus.com/documentation')]"><li
	class="prodterm">http://www.eucalyptus.com/documentation should be "http://www.eucalyptus.com/docs"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'presentation server')]"><li class="prodterm">presentation server should be "XenApp"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'secure gateway')]"><li class="prodterm">secure gateway should be "Focus on Access Gateway"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'xenapp advanced console')]"><li class="prodterm">xenapp advanced console should be "AppCenter"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'xenapp policy')]"><li class="prodterm">xenapp policy should be "Citrix policy"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'xenapp plugin')]"><li class="prodterm">xenapp plugin should be "XenApp online plug-in"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'xenapp plug-in')]"><li class="prodterm">xenapp plug-in should be "XenApp online plug-in"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'web interface console')]"><li class="prodterm">web interface console should be "Web Interface management console"</li></xsl:if>

<!-- General phrasing/terminology -->
<xsl:if test=".//*[$excludes]/text()[contains(.,'data center')]"><li class="genterm">data center - Use "datacenter"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'datastore')]"><li class="genterm">datastore - Use "data store"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(., 'user') and not(contains(., 'end user')) and not(contains(., 'user interface'))]"><li class="genterm">Do not use "user." Use "end user."</li></xsl:if>



</xsl:template>
</xsl:stylesheet>