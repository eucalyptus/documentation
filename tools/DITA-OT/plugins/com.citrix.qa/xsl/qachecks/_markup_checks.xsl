<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" >
<!-- Use this function to handle the following checks...shows error in xmlspy, but 2.0 should be able to handle xsl:function-->

<xsl:template name="markup_checks">


<!-- Valid markup that we don't want to use -->
<xsl:if test=".//b"><li class="tagwarning">Do not use typographic markup b</li></xsl:if>
<xsl:if test=".//i"><li class="tagwarning">Do not use typographic markup i</li></xsl:if>
<xsl:if test=".//u"><li class="tagwarning">Do not use typographic markup u</li></xsl:if>
<xsl:if test=".//dl/dlentry[not(dd)]"><li class="tagwarning">DLEntry is missing DD</li></xsl:if>
<xsl:if test=".//p[(not(text()) and not(node()))]"><li class="tagwarning">P element is empty</li></xsl:if>
<xsl:if test=".//fig[not(title)]"><li class="tagerror">Figure does not have a title</li></xsl:if>
<xsl:if test=".//image[not(alt) and not(@alt)]"><li class="tagwarning">IMAGE does not have alternate text</li></xsl:if>
<xsl:if test=".//image[@width]"><li class="tagwarning">IMAGE has WIDTH set</li></xsl:if>
<xsl:if test=".//uicontrol[contains(text(), '>')]"><li class="tagwarning">Use MenuCascade element for series of UIControl items</li></xsl:if>
<!-- the next two may be wrong since we changed the context node -->
<xsl:if test="./conbody//*[not(@conref) and processing-instruction('xm-replace_text')]"><li class="tagwarning">Body contains xm-replace_text</li></xsl:if>
<xsl:if test="./taskbody//*[not(@conref) and processing-instruction('xm-replace_text')]"><li class="tagwarning">Body contains xm-replace_text</li></xsl:if>
<xsl:if test=".//indexterm"><li class="tagwarning">Remove indexterm elements</li></xsl:if>
<xsl:if test=".//xref[not(starts-with(@href, 'http'))]"><li class="tagwarning">Begin web links with "http://". Does not apply to course resources or mailto links.</li></xsl:if>
<xsl:if test=".//@href[contains(., ' ')]"><li class="syntaxerror">HREF target contains a space</li></xsl:if>
<!--<xsl:if test=".//xref[not(@href)]"><li class="tagerror">Add @href to XREF</li></xsl:if>-->
<xsl:if test=".//xref[not(@scope='external') and contains(@href, 'http://')]"><li class="tagerror">XREF does not have attribute scope as external</li></xsl:if>
<!--<xsl:if test=".//xref[not(@scope='external')]"><li class="tagerror">XREF does not have attribute scope as external</li></xsl:if>-->

<!-- sample checks you may want to use
<xsl:if test=".//draft-comment[not(@otherprops='DraftStatusOn')]"><li class="tagerror">Draft-Comment does not have DraftStatusOn</li></xsl:if>
<xsl:if test=".//bookmap[not(@linking='none')]"><li class="tagerror">BOOKMAP does not have attribute linking as none</li></xsl:if>
<xsl:if test=".//dlentry/dd[position()>1]"><li class="tagerror">DLEntry has more than one definition (DD)</li></xsl:if>
<xsl:if test=".//indexterm"><li class="tagwarning">Remove indexterm elements</li></xsl:if>
<xsl:if test=".//xref[not(@scope='external')]"><li class="tagerror">XREF does not have attribute scope as external</li></xsl:if>
-->

</xsl:template>
</xsl:stylesheet>