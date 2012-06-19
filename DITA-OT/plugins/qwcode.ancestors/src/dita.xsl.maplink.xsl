<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- PARAMETER DEFAULTS -->
<xsl:param name="doAncestors" select="'yes'"/>
<xsl:param name="includeLinkToIndexAsRootAncestor" select="'yes'"/>
<xsl:param name="indexLink" select="'index'"/>
<xsl:param name="indexLinkText" select="'Index'"/>
<xsl:param name="OUTEXT" select="'.html'"/>


<xsl:template match="*" mode="link-to-other">
	<xsl:param name="pathBackToMapDirectory"/>
	<xsl:if test="$doAncestors='yes'">	   
    	<xsl:if test="$includeLinkToIndexAsRootAncestor='yes' and count(ancestor::*[contains(@class, ' map/reltable ')])=0">	          
			<link 
				class="- topic/link " 
				format="html" 
				role="ancestor">
				<xsl:attribute name="href">					
	              <xsl:call-template name="simplifyLink">
	                <xsl:with-param name="originalLink">
	                	<xsl:value-of select="$pathBackToMapDirectory"/>
		                    <xsl:value-of select="$indexLink"/>
		                    <xsl:value-of select="$OUTEXT"/> 		                    		                    
 	                   </xsl:with-param>
	              </xsl:call-template>
				</xsl:attribute>										
				<linktext class="- topic/linktext "><xsl:value-of select="$indexLinkText"/></linktext>
				<desc class="- topic/desc "><xsl:value-of select="$indexLinkText"/></desc>
			</link>			
		</xsl:if>	
		<xsl:apply-templates mode="link" select="ancestor::*[contains(@class, ' map/topicref ')][@href][not(@href='')][not(@linking='none')][not(@linking='sourceonly')]">
       		<xsl:with-param name="role">ancestor</xsl:with-param>
       		<xsl:with-param name="pathBackToMapDirectory" 
         		select="$pathBackToMapDirectory"/>
		</xsl:apply-templates>
	</xsl:if>	
	<xsl:next-match>
		<xsl:fallback>
			<xsl:message>Passing: XSLT 1.0 doesn't support next-match</xsl:message>
		</xsl:fallback>
  	</xsl:next-match>  
	

</xsl:template>


	            

</xsl:stylesheet>
