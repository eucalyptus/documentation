<?xml version='1.0'?>

<!-- JJV modifications for FOP -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:exsl="http://exslt.org/common"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:exslf="http://exslt.org/functions"
    xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
    xmlns:comparer="com.idiominc.ws.opentopic.xsl.extension.CompareStrings"
    extension-element-prefixes="exsl"
    version='1.1'>

    <!--xsl:include href="../../../cfg/fo/attrs/toc-attr.xsl"/-->
    
    <xsl:variable name="map" select="//opentopic:map"/>

    <xsl:template name="createTocHeader">
        <fo:block xsl:use-attribute-sets="__toc__header">
            <xsl:attribute name="id">ID_TOC_00-0F-EA-40-0D-4D</xsl:attribute>
            <xsl:call-template name="insertVariable">
                <xsl:with-param name="theVariableID" select="'Table of Contents'"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>

    <xsl:template name="createToc">

        <xsl:variable name="toc">
            <xsl:apply-templates select="/" mode="toc"/>
        </xsl:variable>

        <xsl:if test="count(exsl:node-set($toc)/*) > 0">
            <fo:page-sequence master-reference="toc-sequence" format="i" xsl:use-attribute-sets="__force__page__count">

                <xsl:call-template name="insertTocStaticContents"/>

                <fo:flow flow-name="xsl-region-body">
                    <xsl:call-template name="createTocHeader"/>
                    <fo:block>
                        <xsl:copy-of select="exsl:node-set($toc)"/>
                    </fo:block>
                </fo:flow>

            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

    <xsl:template match="/" mode="toc">
        <xsl:apply-templates mode="toc">
            <xsl:with-param name="include" select="'true'"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ') and not(contains(@class, ' bkinfo/bkinfo '))]" mode="toc">
        <xsl:param name="include"/>
        <xsl:variable name="topicLevel" select="count(ancestor-or-self::*[contains(@class, ' topic/topic ')])"/>
        <xsl:if test="$topicLevel &lt; $tocMaximumLevel">
            <xsl:variable name="topicTitle">
                <xsl:call-template name="getNavTitle" />
            </xsl:variable>
            <xsl:variable name="id" select="@id"/>
            <xsl:variable name="gid" select="generate-id()"/>
            <xsl:variable name="topicNumber" select="count(exsl:node-set($topicNumbers)/topic[@id = $id][following-sibling::topic[@guid = $gid]]) + 1"/>
            <xsl:variable name="mapTopic">
                <xsl:copy-of select="$map//*[@id = $id]"/>
            </xsl:variable>
            <xsl:variable name="topicType">
                <xsl:call-template name="determineTopicType"/>
            </xsl:variable>

            <xsl:variable name="parentTopicHead">
                <xsl:copy-of select="$map//*[@id = $id]/parent::*[contains(@class, ' mapgroup/topichead ')]"/>
            </xsl:variable>

            <!--        <xsl:if test="(($mapTopic/*[position() = $topicNumber][@toc = 'yes' or not(@toc)]) or (not($mapTopic/*) and $include = 'true')) and not($parentTopicHead/*[position() = $topicNumber]/@toc = 'no')">-->
            <xsl:if test="($mapTopic/*[position() = $topicNumber][@toc = 'yes' or not(@toc)]) or (not($mapTopic/*) and $include = 'true')">
                <fo:basic-link internal-destination="{concat('_OPENTOPIC_TOC_PROCESSING_', generate-id())}" xsl:use-attribute-sets="__toc__link">
                    <fo:block xsl:use-attribute-sets="__toc__indent">
                        <xsl:variable name="tocItemContent">
                            <xsl:choose>
                                <xsl:when test="$topicType = 'topicChapter'">
                                    <xsl:variable name="topicChapters">
                                        <xsl:copy-of select="$map//*[contains(@class, ' bookmap/chapter ')]"/>
                                    </xsl:variable>
                                    <xsl:variable name="chapterNumber">
                                        <xsl:number format="1" value="count($topicChapters/*[@id = $id]/preceding-sibling::*) + 1"/>
                                    </xsl:variable>
                                    <xsl:call-template name="insertVariable">
                                        <xsl:with-param name="theVariableID" select="'Table of Contents Chapter'"/>
                                        <xsl:with-param name="theParameters">
                                            <number>
                                                <xsl:value-of select="$chapterNumber"/>
                                            </number>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="$topicType = 'topicAppendix'">
                                    <xsl:variable name="topicAppendixes">
                                        <xsl:copy-of select="$map//*[contains(@class, ' bookmap/appendix ')]"/>
                                    </xsl:variable>
                                    <xsl:variable name="appendixNumber">
                                        <xsl:number format="A" value="count($topicAppendixes/*[@id = $id]/preceding-sibling::*) + 1"/>
                                    </xsl:variable>
                                    <xsl:call-template name="insertVariable">
                                        <xsl:with-param name="theVariableID" select="'Table of Contents Appendix'"/>
                                        <xsl:with-param name="theParameters">
                                            <number>
                                                <xsl:value-of select="$appendixNumber"/>
                                            </number>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="$topicType = 'topicPart'">
                                    <xsl:variable name="topicParts">
                                        <xsl:copy-of select="$map//*[contains(@class, ' bookmap/part ')]"/>
                                    </xsl:variable>
                                    <xsl:variable name="partNumber">
                                        <xsl:number format="I" value="count($topicParts/*[@id = $id]/preceding-sibling::*) + 1"/>
                                    </xsl:variable>
                                    <xsl:call-template name="insertVariable">
                                        <xsl:with-param name="theVariableID" select="'Table of Contents Part'"/>
                                        <xsl:with-param name="theParameters">
                                            <number>
                                                <xsl:value-of select="$partNumber"/>
                                            </number>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="$topicType = 'topicPreface'">
                                    <xsl:call-template name="insertVariable">
                                        <xsl:with-param name="theVariableID" select="'Table of Contents Preface'"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="$topicType = 'topicNotices'">
                                    <xsl:call-template name="insertVariable">
                                        <xsl:with-param name="theVariableID" select="'Table of Contents Notices'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            <fo:inline xsl:use-attribute-sets="__toc__title" margin-right=".2in">
                                <xsl:value-of select="$topicTitle"/>
                            </fo:inline>
                            <fo:inline margin-left="-.2in" keep-together.within-line="always">
                                <fo:leader xsl:use-attribute-sets="__toc__leader"/>
                                <fo:page-number-citation
                                        ref-id="{concat('_OPENTOPIC_TOC_PROCESSING_', generate-id())}"/>
                            </fo:inline>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$topicType = 'topicChapter'">
                                <fo:block xsl:use-attribute-sets="__toc__chapter__content">
                                    <xsl:copy-of select="$tocItemContent"/>
                                </fo:block>
                            </xsl:when>
                            <xsl:when test="$topicType = 'topicAppendix'">
                                <fo:block xsl:use-attribute-sets="__toc__appendix__content">
                                    <xsl:copy-of select="$tocItemContent"/>
                                </fo:block>
                            </xsl:when>
                            <xsl:when test="$topicType = 'topicPart'">
                                <fo:block xsl:use-attribute-sets="__toc__part__content">
                                    <xsl:copy-of select="$tocItemContent"/>
                                </fo:block>
                            </xsl:when>
                            <xsl:when test="$topicType = 'topicPreface'">
                                <fo:block xsl:use-attribute-sets="__toc__preface__content">
                                    <xsl:copy-of select="$tocItemContent"/>
                                </fo:block>
                            </xsl:when>
                            <xsl:when test="$topicType = 'topicNotices'">
                                <fo:block xsl:use-attribute-sets="__toc__notices__content">
                                    <xsl:copy-of select="$tocItemContent"/>
                                </fo:block>
                            </xsl:when>
                            <xsl:otherwise>
                                <fo:block xsl:use-attribute-sets="__toc__topic__content">
                                    <xsl:copy-of select="$tocItemContent"/>
                                </fo:block>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                </fo:basic-link>
                <xsl:apply-templates mode="toc">
                    <xsl:with-param name="include" select="'true'"/>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="node()" mode="toc">
        <xsl:param name="include"/>
        <xsl:apply-templates mode="toc">
            <xsl:with-param name="include" select="$include"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/note ')]">
        <xsl:variable name="noteType">
            <xsl:choose>
                <xsl:when test="@type">
                    <xsl:value-of select="@type"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'note'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
	  <!-- xsl:variable name="noteImagePath">
            <xsl:call-template name="insertVariable">
                <xsl:with-param name="theVariableID" select="concat($noteType, ' Note Image Path')"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not($noteImagePath = '')">
				<fo:external-graphic src="url({concat($artworkPrefix, '/', $noteImagePath)})" xsl:use-attribute-sets="image"/>                
                        <fo:inline xsl:use-attribute-sets="note">
					<xsl:call-template name="placeNoteContent"/>
                  	</fo:inline>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="placeNoteContent"/>
            </xsl:otherwise>
        </xsl:choose -->

	<fo:block xsl:use-attribute-sets="note">
        <xsl:call-template name="placeNoteContent"/>
	</fo:block>

    </xsl:template>

    <!--Definition list-->
    <xsl:template match="*[contains(@class, ' topic/dl ')]">
        <fo:table xsl:use-attribute-sets="dl" id="{@id}">
            <xsl:apply-templates select="*[contains(@class, ' topic/dlhead ')]"/>
            <fo:table-body xsl:use-attribute-sets="dl__body">
			<fo:table-row xsl:use-attribute-sets="dlentry" id="{@id}">
		    <!-- xsl:choose>
                    <xsl:when test="contains(@otherprops,'sortable')">
                        <xsl:apply-templates select="*[contains(@class, ' topic/dlentry ')]">
                            <xsl:sort select="opentopic-func:getSortString(normalize-space( opentopic-func:fetchValueableText(*[contains(@class, ' topic/dt ')]) ))" lang="{$locale}"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="*[contains(@class, ' topic/dlentry ')]"/>
                    </xsl:otherwise>

                </xsl:choose -->

            		<fo:table-cell xsl:use-attribute-sets="dlentry.dt" id="{@id}">
                			<fo:block>
					<xsl:text> </xsl:text>
					</fo:block>
            		</fo:table-cell>
            		<fo:table-cell xsl:use-attribute-sets="dlentry.dd" id="{@id}">
                			<fo:block>
					<xsl:text> </xsl:text>
					</fo:block>
            		</fo:table-cell>

       	 </fo:table-row>

            </fo:table-body>
        </fo:table>

		<xsl:apply-templates select="*[contains(@class, ' topic/dlentry ')]"/>

    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dl ')]/*[contains(@class, ' topic/dlhead ')]">
        <fo:table-header xsl:use-attribute-sets="dl.dlhead" id="{@id}">
            <fo:table-row xsl:use-attribute-sets="dl.dlhead__row">
                <xsl:apply-templates/>
            </fo:table-row>
        </fo:table-header>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dlhead ')]/*[contains(@class, ' topic/dthd ')]">
        <fo:table-cell xsl:use-attribute-sets="dlhead.dthd__cell" id="{@id}">
            <fo:block xsl:use-attribute-sets="dlhead.dthd__content">
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dlhead ')]/*[contains(@class, ' topic/ddhd ')]">
        <fo:table-cell xsl:use-attribute-sets="dlhead.ddhd__cell" id="{@id}">
            <fo:block xsl:use-attribute-sets="dlhead.ddhd__content">
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>

    <!-- xsl:template match="*[contains(@class, ' topic/dlentry ')]">
        <fo:table-row xsl:use-attribute-sets="dlentry" id="{@id}">
            <fo:table-cell xsl:use-attribute-sets="dlentry.dt" id="{@id}">
                <xsl:apply-templates select="*[contains(@class, ' topic/dt ')]"/>
            </fo:table-cell>
            <fo:table-cell xsl:use-attribute-sets="dlentry.dd" id="{@id}">
                <xsl:apply-templates select="*[contains(@class, ' topic/dd ')]"/>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template -->


	<xsl:template match="*[contains(@class, ' topic/dlentry ')]">
		<fo:block>
                <xsl:apply-templates select="*[contains(@class, ' topic/dt ')]"/>
                <xsl:apply-templates select="*[contains(@class, ' topic/dd ')]"/>
		</fo:block>
	</xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dt ')]">
        <fo:block xsl:use-attribute-sets="dlentry.dt__content">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dd ')]">
        <fo:block xsl:use-attribute-sets="dlentry.dd__content">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

<!-- Added changed frontmatter processing -->

    <xsl:template name="createFrontMatter">
        <xsl:choose>
            <xsl:when test="$ditaVersion &gt; '1.0'">
                <xsl:call-template name="createFrontMatter_1.0"/>
            </xsl:when>
            <xsl:otherwise>
                <fo:page-sequence master-reference="front-matter" xsl:use-attribute-sets="__force__page__count">
                    <xsl:call-template name="insertFrontMatterStaticContents"/>
                    <fo:flow flow-name="xsl-region-body">
                        <fo:block xsl:use-attribute-sets="__frontmatter">
                            <!-- set the title -->
                            <fo:block xsl:use-attribute-sets="__frontmatter__title">
                                <xsl:choose>
                                    <xsl:when test="//*[contains(@class,' bkinfo/bkinfo ')][1]">
                                        <xsl:apply-templates select="//*[contains(@class,' bkinfo/bkinfo ')][1]/*[contains(@class,' topic/title ')]/node()"/>
                                    </xsl:when>
                                    <xsl:when test="//*[contains(@class, ' map/map ')]/@title">
                                        <xsl:value-of select="//*[contains(@class, ' map/map ')]/@title"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="/descendant::*[contains(@class, ' topic/topic ')][1]/*[contains(@class, ' topic/title ')]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </fo:block>

                            <!-- set the subtitle -->
                            <xsl:apply-templates select="//*[contains(@class,' bkinfo/bkinfo ')][1]/*[contains(@class,' bkinfo/bktitlealts ')]/*[contains(@class,' bkinfo/bksubtitle ')]"/>

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

                        <!--<xsl:call-template name="createPreface"/>-->

                    </fo:flow>
                </fo:page-sequence>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="createFrontMatter_1.0">
        <fo:page-sequence master-reference="front-matter" xsl:use-attribute-sets="__force__page__count">
            <xsl:call-template name="insertFrontMatterStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <fo:block xsl:use-attribute-sets="__frontmatter">
                    <!-- set the title -->
                    <fo:block xsl:use-attribute-sets="__frontmatter__title">
                        <xsl:choose>
                            <xsl:when test="$map/*[contains(@class,' topic/title ')][1]">
                                <xsl:apply-templates select="$map/*[contains(@class,' topic/title ')][1]"/>
                            </xsl:when>
                            <xsl:when test="$map//*[contains(@class,' bookmap/mainbooktitle ')][1]">
                                <xsl:apply-templates select="$map//*[contains(@class,' bookmap/mainbooktitle ')][1]"/>
                            </xsl:when>
                            <xsl:when test="//*[contains(@class, ' map/map ')]/@title">
                                <xsl:value-of select="//*[contains(@class, ' map/map ')]/@title"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="/descendant::*[contains(@class, ' topic/topic ')][1]/*[contains(@class, ' topic/title ')]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>

                    <!-- set the subtitle -->
                    <xsl:apply-templates select="$map//*[contains(@class,' bookmap/booktitlealt ')]"/>

                    <fo:block xsl:use-attribute-sets="__frontmatter__owner">
                        <xsl:apply-templates select="$map//*[contains(@class,' bookmap/bookmeta ')]"/>
                    </fo:block>

<!-- JJV create back of title page -->

		<fo:block xsl:use-attribute-sets="printed_layout">
				<fo:block-container position="absolute" top="80mm">
				<fo:block>
				<xsl:value-of select="$map//*[contains(@class,' bookmap/mainbooktitle ')][1]"/>
				</fo:block>
				<fo:block>
				<xsl:value-of select="//author"/>
				</fo:block>
				<fo:block space-before.optimum="10mm">
				<xsl:text>Published by: </xsl:text>
				</fo:block>
				<fo:block>
				<xsl:value-of select="//bookrights/bookowner/organization [1]"/>
				</fo:block>
				<fo:block>
				<xsl:value-of select="//bookrights/bookowner/organization [2]"/>
				</fo:block>
				<fo:block>
				<xsl:value-of select="//authorinformation/organizationinfo/addressdetails/thoroughfare"/>
				</fo:block>
				<fo:block>
				<xsl:value-of select="//authorinformation/organizationinfo/addressdetails/locality/localityname"/>
				<fo:inline>	
					<xsl:value-of select="//authorinformation/organizationinfo/locality/postalcode"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="//authorinformation/organizationinfo/country"/>
				</fo:inline>
				</fo:block>
				<fo:block>
				<xsl:value-of select="//authorinformation/organizationinfo/urls/url"/>
				</fo:block>
				<fo:block space-before.optimum="10mm">
					<xsl:text>ISBN: </xsl:text>
					<xsl:value-of select="//bookid/isbn"/>
				</fo:block>
				</fo:block-container>

			<fo:block-container xsl:use-attribute-sets="copyright_layout">			
			<fo:block> <!-- xsl:use-attribute-sets="copyright_layout" -->
			
				<fo:block>
				<xsl:value-of select="//bookid/edition"/>
				</fo:block>
				<fo:block>
				<xsl:text> </xsl:text>
				</fo:block>
			<fo:block xsl:use-attribute-sets="restriction">
			<xsl:text>Copyright &#169; </xsl:text>
			<xsl:value-of select="//bookrights/copyrfirst/year"/>
			<xsl:text>, </xsl:text>
			<xsl:value-of select="//bookrights/copyrlast/year"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="//bookrights/bookowner/organization [1]"/>
			<!--xsl:text> and </xsl:text>
			<xsl:value-of select="//bookrights/bookowner/organization [2]"/-->
			<xsl:text>. No part of this document can be reproduced in any manner, either electronic or
				manually without the express written consent of the publisher.</xsl:text>
			</fo:block>	

			</fo:block>
			</fo:block-container>
			
	</fo:block>

     </fo:block>

                <!--<xsl:call-template name="createPreface"/>-->

		</fo:flow>
		
        </fo:page-sequence>

    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/bookmeta ')]">
        <fo:block-container xsl:use-attribute-sets="__frontmatter__owner__container">
            <fo:block>
			<xsl:value-of select="./author"/>
            </fo:block>
        </fo:block-container>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/booktitlealt ')]" priority="+2">
        <fo:block xsl:use-attribute-sets="__frontmatter__subtitle">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/booktitle ')]" priority="+2">
        <fo:block xsl:use-attribute-sets="__frontmatter__booklibrary">
            <xsl:apply-templates select="*[contains(@class, ' bookmap/booklibrary ')]"/>
        </fo:block>
        <fo:block xsl:use-attribute-sets="__frontmatter__mainbooktitle">
            <xsl:apply-templates select="*[contains(@class,' bookmap/mainbooktitle ')]"/>
        </fo:block>
    </xsl:template>

	<xsl:template match="*[contains(@class, ' xnal-d/namedetails ')]">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' xnal-d/addressdetails ')]">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' xnal-d/contactnumbers ')]">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' bookmap/bookowner ')]">
		<fo:block xsl:use-attribute-sets="author">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' bookmap/summary ')]">
		<fo:block xsl:use-attribute-sets="bookmap.summary">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

<!-- task overrides: JJV -->

    <xsl:template match="*[contains(@class, ' task/steps ')]" priority="10">
	<!-- modified to add heading to task -->
	<fo:block xsl:use-attribute-sets="section.title">
		<xsl:text>Procedure:</xsl:text>
	</fo:block>
        <fo:list-block xsl:use-attribute-sets="steps" id="{@id}">
            <xsl:apply-templates/>
        </fo:list-block>
    </xsl:template>

<xsl:template match="*[contains(@class, ' task/steps-unordered ')]" priority="10">
	<!-- modified to add heading to task -->
	<fo:block xsl:use-attribute-sets="task_section_headings">
		<xsl:text>Procedure:</xsl:text>
	</fo:block>
        <fo:list-block xsl:use-attribute-sets="steps" id="{@id}">
            <xsl:apply-templates/>
        </fo:list-block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/prereq ')]" priority="10">
        <fo:block xsl:use-attribute-sets="task_section_headings">
		<xsl:text>Before starting this task:</xsl:text>
        </fo:block>
	<fo:block xsl:use-attribute-sets="prereq" id="{@id}">
            <xsl:apply-templates/>
	</fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/context ')]" priority="10">
        <fo:block xsl:use-attribute-sets="task_section_headings">
		<xsl:text>About this task:</xsl:text>
        </fo:block>
	  <fo:block xsl:use-attribute-sets="context" id="{@id}">
            <xsl:apply-templates/>
	  </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/result ')]" priority="10">
        <fo:block xsl:use-attribute-sets="task_section_headings">
		<xsl:text>How to tell you're done:</xsl:text>
        </fo:block>
	  <fo:block xsl:use-attribute-sets="result" id="{@id}">
            <xsl:apply-templates/>
	  </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/postreq ')]" priority="10">
        <fo:block xsl:use-attribute-sets="task_section_headings">
			<xsl:text>What you should do next:</xsl:text>
        </fo:block>
	  <fo:block xsl:use-attribute-sets="postreq" id="{@id}">
            <xsl:apply-templates/>
	  </fo:block>
    </xsl:template>

</xsl:stylesheet>
