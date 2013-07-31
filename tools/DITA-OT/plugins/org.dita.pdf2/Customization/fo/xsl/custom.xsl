<?xml version='1.0'?>

<!-- 
Copyright © 2004-2006 by Idiom Technologies, Inc. All rights reserved. 
IDIOM is a registered trademark of Idiom Technologies, Inc. and WORLDSERVER
and WORLDSTART are trademarks of Idiom Technologies, Inc. All other 
trademarks are the property of their respective owners. 

IDIOM TECHNOLOGIES, INC. IS DELIVERING THE SOFTWARE "AS IS," WITH 
ABSOLUTELY NO WARRANTIES WHATSOEVER, WHETHER EXPRESS OR IMPLIED,  AND IDIOM
TECHNOLOGIES, INC. DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
PURPOSE AND WARRANTY OF NON-INFRINGEMENT. IDIOM TECHNOLOGIES, INC. SHALL NOT
BE LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, COVER, PUNITIVE, EXEMPLARY,
RELIANCE, OR CONSEQUENTIAL DAMAGES (INCLUDING BUT NOT LIMITED TO LOSS OF 
ANTICIPATED PROFIT), ARISING FROM ANY CAUSE UNDER OR RELATED TO  OR ARISING 
OUT OF THE USE OF OR INABILITY TO USE THE SOFTWARE, EVEN IF IDIOM
TECHNOLOGIES, INC. HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. 

Idiom Technologies, Inc. and its licensors shall not be liable for any
damages suffered by any person as a result of using and/or modifying the
Software or its derivatives. In no event shall Idiom Technologies, Inc.'s
liability for any damages hereunder exceed the amounts received by Idiom
Technologies, Inc. as a result of this transaction.

These terms and conditions supersede the terms and conditions in any
licensing agreement to the extent that such terms and conditions conflict
with those set forth herein.

This file is part of the DITA Open Toolkit project hosted on Sourceforge.net. 
See the accompanying license.txt file for applicable licenses.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    exclude-result-prefixes="opentopic"
    version="1.1">

  <xsl:template name="insertPageNumberCitation">
		<xsl:param name="isTitleEmpty"/>
		<xsl:param name="destination"/>
		<xsl:param name="element"/>
		
		<xsl:choose>
			<xsl:when test="not($element) or ($destination = '')"/>
			<xsl:when test="$isTitleEmpty">
				<fo:inline>
					<xsl:call-template name="insertVariable">
						<xsl:with-param name="theVariableID" select="'Page'"/>
						<xsl:with-param name="theParameters">
							<pagenum>
								<fo:inline>
									<fo:page-number-citation ref-id="{$destination}"/>
								</fo:inline>
							</pagenum>
						</xsl:with-param>
					</xsl:call-template>
				</fo:inline>
			</xsl:when>
			<!--<xsl:otherwise>
				<fo:inline>
					<xsl:call-template name="insertVariable">
						<xsl:with-param name="theVariableID" select="'On the page'"/>
						<xsl:with-param name="theParameters">
							<pagenum>
								<fo:inline>
									<fo:page-number-citation ref-id="{$destination}"/>
								</fo:inline>
							</pagenum>
						</xsl:with-param>
					</xsl:call-template>
				</fo:inline>
			</xsl:otherwise>-->
		</xsl:choose>
  </xsl:template> 
	
	<xsl:template name="createFrontMatter">
		<xsl:value-of select="$map/*[contains(@class,' map/topicmeta ')]/*[contains(@class,'
			topic/publisher ')]"/>
        <fo:page-sequence master-reference="front-matter" format="i" xsl:use-attribute-sets="__force__page__count">
            <xsl:call-template name="insertFrontMatterStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <fo:block xsl:use-attribute-sets="__frontmatter">
                    <!-- set the title -->
                    <fo:block xsl:use-attribute-sets="__frontmatter__title">
                    	<fo:block text-align="center">
                    		<fo:external-graphic src="url({concat($artworkPrefix,
                    			'/Customization/OpenTopic/common/artwork/logo.png')})"/>
                    	</fo:block>
                        <xsl:choose>
                            <xsl:when test="//*[contains(@class,' bkinfo/bkinfo ')][1]">
                                <xsl:apply-templates select="//*[contains(@class,' bkinfo/bkinfo ')][1]/*[contains(@class,' topic/title ')]/node()"/>
                            </xsl:when>
                            <xsl:when test="//*[contains(@class, ' map/map ')]/@title">
                                <xsl:value-of select="//*[contains(@class, ' map/map ')]/@title"/>
                            </xsl:when>
                            <!--<xsl:otherwise>
                                <xsl:value-of select="/descendant::*[contains(@class, ' topic/topic ')][1]/*[contains(@class, ' topic/title ')]"/>
                                </xsl:otherwise>-->
                        	<xsl:otherwise>
                        		<xsl:value-of select="/descendant::title"/>
                        	</xsl:otherwise>
                        </xsl:choose>
                    </fo:block>

                    <!-- set the subtitle -->
                    <xsl:apply-templates select="//*[contains(@class,' bkinfo/bkinfo ')][1]/*[contains(@class,' bkinfo/bktitlealts ')]/*[contains(@class,' bkinfo/bksubtitle ')]"/>

                	<!--<fo:block text-align="center" width="100%">
                		<fo:external-graphic src="url({concat($artworkPrefix,
                			'/Customization/OpenTopic/common/artwork/logo.png')})"/>
                		</fo:block>-->
                	
                	<fo:block xsl:use-attribute-sets="__frontmatter__owner">
                        <xsl:choose>
                            <xsl:when test="//*[contains(@class,' bkinfo/bkowner ')]">
                                <xsl:apply-templates select="//*[contains(@class,' bkinfo/bkowner ')]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$map/*[contains(@class, ' map/topicmeta ')]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>

                </fo:block>

                <xsl:call-template name="processCopyrigth"/>

            </fo:flow>
        </fo:page-sequence>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bkinfo/bkowner ')]">
        <fo:block-container xsl:use-attribute-sets="__frontmatter__owner__container">
            <fo:block >
                <fo:inline>
                    <xsl:apply-templates select="*[contains(@class, ' bkinfo/organization ')]/*[contains(@class, ' bkinfo/orgname ')]"/>
                </fo:inline>
                    &#xA0;
                <fo:inline>
                    <xsl:apply-templates select="*[contains(@class, ' bkinfo/organization ')]/*[contains(@class, ' bkinfo/address ')]"/>
                </fo:inline>
            </fo:block>
        </fo:block-container>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicmeta ')]">
        <fo:block-container xsl:use-attribute-sets="__frontmatter__owner__container">
            <xsl:apply-templates/>
        </fo:block-container>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/author ')]">
        <fo:block xsl:use-attribute-sets="author" >
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/publisher ')]">
        <fo:block xsl:use-attribute-sets="publisher" >
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/copyright ')]">
        <fo:block xsl:use-attribute-sets="copyright" >
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/copyryear ')]">
        
        <fo:inline xsl:use-attribute-sets="copyryear" >
            <xsl:value-of select="format-date(current-date(),'[Y0001]-[M01]-[D01]')" /><xsl:text> </xsl:text>
        </fo:inline>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/copyrholder ')]">
        <fo:inline xsl:use-attribute-sets="copyrholder" >
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bkinfo/bksubtitle ')]" priority="+2">
        <fo:block xsl:use-attribute-sets="__frontmatter__subtitle">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template name="processCopyrigth">
        <xsl:apply-templates select="/bookmap/*[contains(@class,' topic/topic ')]" mode="process-preface"/>
    </xsl:template>

    <xsl:template name="processTopicAbstract">
        <fo:block xsl:use-attribute-sets="topic" page-break-before="always">
            <xsl:if test="not(ancestor::*[contains(@class, ' topic/topic ')])">
                <fo:marker marker-class-name="current-topic-number">
                    <xsl:number format="1"/>
                </fo:marker>
            	<fo:marker marker-class-name="current-header">
            		<xsl:for-each select="child::*[contains(@class,' topic/title ')]">
            			<xsl:apply-templates select="." mode="getTitle"/>
            		</xsl:for-each>
            	</fo:marker>
            </xsl:if>
            <fo:inline>
                <xsl:call-template name="commonattributes"/>
            </fo:inline>
            <fo:inline id="{concat('_OPENTOPIC_TOC_PROCESSING_', generate-id())}"/>
            <fo:block>
                <xsl:attribute name="border-bottom">3pt solid black</xsl:attribute>
                <xsl:attribute name="margin-bottom">1.4pc</xsl:attribute>
            </fo:block>
            <fo:block xsl:use-attribute-sets="body__toplevel">
                <xsl:apply-templates select="*[not(contains(@class, ' topic/title '))]"/>
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="process-preface">
        <xsl:param name="include" select="'true'"/>
        <xsl:variable name="topicType">
            <xsl:call-template name="determineTopicType"/>
        </xsl:variable>

        <xsl:if test="$topicType = 'topicAbstract'">
            <xsl:call-template name="processTopicAbstract"/>
        </xsl:if>
    </xsl:template>	
	
	<xsl:template name="generateTableEntryBorder">
		<xsl:variable name="colsep">1</xsl:variable>
		<xsl:variable name="rowsep">1</xsl:variable>
		<xsl:variable name="frame" select="ancestor::*[contains(@class, ' topic/table ')][1]/@frame"/>
		<xsl:variable name="needTopBorderOnBreak">
			<xsl:choose>
				<xsl:when test="$frame = 'all' or $frame = 'topbot' or $frame = 'top' or not($frame)">
					<xsl:choose>
						<xsl:when test="../parent::node()[contains(@class, ' topic/thead ')]">
							<xsl:value-of select="'true'"/>
						</xsl:when>
						<xsl:when test="(../parent::node()[contains(@class, ' topic/tbody ')]) and not(../preceding-sibling::*[contains(@class, ' topic/row ')])">
							<xsl:value-of select="'true'"/>
						</xsl:when>
						<xsl:when test="../parent::node()[contains(@class, ' topic/tbody ')]">
							<xsl:variable name="entryNum" select="count(preceding-sibling::*[contains(@class, ' topic/entry ')]) + 1"/>
							<xsl:variable name="prevEntryRowsep">
								<xsl:for-each select="../preceding-sibling::*[contains(@class, ' topic/row ')]/*[contains(@class, ' topic/entry ')][$entryNum]">
									<xsl:call-template name="getTableRowsep"/>
								</xsl:for-each>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="number($prevEntryRowsep)">
									<xsl:value-of select="'true'"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'false'"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'false'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'false'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="number($rowsep) and (../parent::node()[contains(@class, ' topic/thead ')])">
			<xsl:call-template name="processAttrSetReflection">
				<xsl:with-param name="attrSet" select="'thead__tableframe__bottom'"/>
				<xsl:with-param name="path" select="$tableAttrs"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="number($rowsep) and ((../following-sibling::*[contains(@class, ' topic/row ')]) or (../parent::node()[contains(@class, ' topic/tbody ')] and ancestor::*[contains(@class, ' topic/tgroup ')][1]/*[contains(@class, ' topic/tfoot ')]))">
			<xsl:call-template name="processAttrSetReflection">
				<xsl:with-param name="attrSet" select="'__tableframe__bottom'"/>
				<xsl:with-param name="path" select="$tableAttrs"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$needTopBorderOnBreak = 'true'">
			<xsl:call-template name="processAttrSetReflection">
				<xsl:with-param name="attrSet" select="'__tableframe__top'"/>
				<xsl:with-param name="path" select="$tableAttrs"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="number($colsep) and following-sibling::*[contains(@class, ' topic/entry ')]">
			<xsl:call-template name="processAttrSetReflection">
				<xsl:with-param name="attrSet" select="'__tableframe__right'"/>
				<xsl:with-param name="path" select="$tableAttrs"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="number($colsep) and not(following-sibling::*[contains(@class, ' topic/entry ')]) and ((count(preceding-sibling::*)+1) &lt; ancestor::*[contains(@class, ' topic/tgroup ')][1]/@cols)">
			<xsl:call-template name="processAttrSetReflection">
				<xsl:with-param name="attrSet" select="'__tableframe__right'"/>
				<xsl:with-param name="path" select="$tableAttrs"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
