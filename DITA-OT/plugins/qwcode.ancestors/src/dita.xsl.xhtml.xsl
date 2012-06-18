<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- PARAMETER DEFAULTS -->
<xsl:param name="doAncestors" select="'yes'"/>
<xsl:param name="ancestorSeperator" select="' &gt; '"/>
<xsl:param name="includePrevNextLinks" select="'no'"/>
<xsl:param name="includeTitleInTrail" select="'no'"/>


<xsl:template name="generateBreadcrumbs">
   <xsl:if test="$doAncestors='yes'">	
     <xsl:value-of select="$newline"/><div class="breadcrumb">
     <xsl:apply-templates select="*[contains(@class,' topic/related-links ')]" mode="breadcrumb_prevnext"/>
     <xsl:apply-templates select="*[contains(@class,' topic/related-links ')]" mode="breadcrumb_ancestors"/>
     <xsl:if test="$includeTitleInTrail='yes'">	
		 <xsl:value-of select="/descendant::title[position()=1]"/>
	 </xsl:if>      
     </div><xsl:value-of select="$newline"/>     
   </xsl:if>  
</xsl:template>

<xsl:template match="*[contains(@class,' topic/related-links ')]" mode="breadcrumb_prevnext">  
  <xsl:for-each select="descendant-or-self::*[contains(@class,' topic/related-links ') or contains(@class,' topic/linkpool ')]">    
     <xsl:if test="$includePrevNextLinks='yes'">     	
	     <xsl:choose>
	          <!--output previous link first, if it exists-->
	          <xsl:when test="*[@href][@role='previous']">
	               <xsl:apply-templates select="*[@href][@role='previous'][1]" mode="breadcrumb"/>
	          </xsl:when>
	          <xsl:otherwise/>
	     </xsl:choose>
	     <!--if both previous and next links exist, output a separator bar-->
	     <xsl:if test="*[@href][@role='next'] and *[@href][@role='previous']">
	       <xsl:text> | </xsl:text>
	     </xsl:if>
	     <xsl:choose>
	          <!--output next link, if it exists-->
	          <xsl:when test="*[@href][@role='next']">	          			
	               <xsl:apply-templates select="*[@href][@role='next'][1]" mode="breadcrumb"/>
	          </xsl:when>
	          <xsl:otherwise/>
	     </xsl:choose>
	     <!--if we have either next or previous, plus ancestors, separate the next/prev from the ancestors with a vertical bar-->
	     <xsl:if test="(*[@href][@role='next'] or *[@href][@role='previous']) and $doAncestors='yes'">
	       <xsl:text> | </xsl:text>
	     </xsl:if>
	</xsl:if>          
  </xsl:for-each>
  
</xsl:template>

<xsl:template match="*[contains(@class,' topic/related-links ')]" mode="breadcrumb_ancestors">
  <xsl:for-each select="descendant-or-self::*[contains(@class,' topic/related-links ') or contains(@class,' topic/linkpool ')][child::*[@role='ancestor']]">    
     <!--if ancestors exist, output them, and include a greater-than symbol after each one, including a trailing one-->
     <xsl:choose>
          <xsl:when test="*[@href][@role='ancestor']"> 			 
			 <xsl:for-each select="*[@href][@role='ancestor']">
			           <xsl:apply-templates select="." /><xsl:value-of select="$ancestorSeperator"/>
			 </xsl:for-each>                  
          </xsl:when>
          <xsl:otherwise>
		  </xsl:otherwise>
     </xsl:choose>
  </xsl:for-each>  
</xsl:template>



</xsl:stylesheet>
