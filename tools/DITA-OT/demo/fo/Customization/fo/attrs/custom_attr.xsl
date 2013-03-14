<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">


	<xsl:attribute-set name="__frontmatter__title">
		<xsl:attribute name="margin-top">10mm</xsl:attribute>
		<xsl:attribute name="font-family">Helvetica</xsl:attribute>
		<!--<xsl:attribute name="border-bottom">1pt solid #8CC63E</xsl:attribute>-->
		<xsl:attribute name="font-size">20pt</xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<!--<xsl:attribute name="font-style">italic</xsl:attribute>-->
		<xsl:attribute name="line-height">160%</xsl:attribute>
		<xsl:attribute name="margin-bottom">1.4pc</xsl:attribute>
		<xsl:attribute name="color">#8CC63E</xsl:attribute>
		<xsl:attribute name="padding-right">1.4pc</xsl:attribute>
		<xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
	</xsl:attribute-set>

	<!-- Codeblocks -->
	
	<xsl:attribute-set name="li.filename__label">
		<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
		<xsl:attribute name="keep-with-next.within-line">always</xsl:attribute>
		<xsl:attribute name="end-indent">label-end()</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="pre" use-attribute-sets="base-font common.block">
		<xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
		<xsl:attribute name="white-space-collapse">false</xsl:attribute>
		<xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
		<xsl:attribute name="wrap-option">wrap</xsl:attribute>
		<xsl:attribute name="background-color">#f0f0f0</xsl:attribute>
		<xsl:attribute name="font-family">Monospaced</xsl:attribute>
		<xsl:attribute name="line-height">106%</xsl:attribute>
		<xsl:attribute name="space-before">0.6em</xsl:attribute>
		<xsl:attribute name="space-after">0.6em</xsl:attribute>
		<xsl:attribute name="border-top-style">dashed</xsl:attribute>
		<xsl:attribute name="border-top-width">1pt</xsl:attribute>
		<xsl:attribute name="border-top-color">#6A737B</xsl:attribute>
		<xsl:attribute name="border-bottom-style">dashed</xsl:attribute>
		<xsl:attribute name="border-bottom-width">1pt</xsl:attribute>
		<xsl:attribute name="border-bottom-color">#6A737B</xsl:attribute>
		<xsl:attribute name="border-left-style">dashed</xsl:attribute>
		<xsl:attribute name="border-left-width">1pt</xsl:attribute>
		<xsl:attribute name="border-left-color">#6A737B</xsl:attribute>
		<xsl:attribute name="border-right-style">dashed</xsl:attribute>
		<xsl:attribute name="border-right-width">1pt</xsl:attribute>
		<xsl:attribute name="border-right-color">#6A737B</xsl:attribute>
	</xsl:attribute-set>

	<!-- Tables	-->
	<xsl:attribute-set name="table__tableframe__all">
		<xsl:attribute name="border-before-style">solid</xsl:attribute>
		<xsl:attribute name="border-before-width">1pt</xsl:attribute>
		<xsl:attribute name="border-before-width.conditionality">retain</xsl:attribute>
		<xsl:attribute name="border-before-color">#03405F</xsl:attribute>
		<xsl:attribute name="border-after-style">solid</xsl:attribute>
		<xsl:attribute name="border-after-width">1pt</xsl:attribute>
		<xsl:attribute name="border-after-width.conditionality">retain</xsl:attribute>
		<xsl:attribute name="border-after-color">#03405F</xsl:attribute>
		<xsl:attribute name="border-left-style">solid</xsl:attribute>
		<xsl:attribute name="border-left-width">1pt</xsl:attribute>
		<xsl:attribute name="border-left-color">#03405F</xsl:attribute>
		<xsl:attribute name="border-right-style">solid</xsl:attribute>
		<xsl:attribute name="border-right-width">1pt</xsl:attribute>
		<xsl:attribute name="border-right-color">#03405F</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="thead.row.entry">
		<!--head cell-->
		<xsl:attribute name="background-color">#03405F</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:attribute-set name="thead.row.entry__content">
		<!--head cell contents-->
		<xsl:attribute name="margin">3pt 3pt 3pt 3pt</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="color">white</xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="font-family">Helvetica</xsl:attribute>
	</xsl:attribute-set>
	
	<!-- Headings -->
	
	<xsl:attribute-set name="common.title">
		<xsl:attribute name="font-family">Helvetica</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:attribute-set name="topic.title" use-attribute-sets="common.title">
		<xsl:attribute name="border-bottom">3pt solid #03405F</xsl:attribute>
		<xsl:attribute name="space-before">0pt</xsl:attribute>
		<xsl:attribute name="space-after">16.8pt</xsl:attribute>
		<xsl:attribute name="font-size">18pt</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="padding-top">16.8pt</xsl:attribute>
		<xsl:attribute name="color">#03405F</xsl:attribute>
		<xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:attribute-set name="topic.topic.title" use-attribute-sets="common.title common.border__bottom">
		<xsl:attribute name="space-before">15pt</xsl:attribute>
		<xsl:attribute name="space-before">12pt</xsl:attribute>
		<xsl:attribute name="space-after">5pt</xsl:attribute>
		<xsl:attribute name="font-size">14pt</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="padding-top">12pt</xsl:attribute>
		<xsl:attribute name="color">#8CC63E</xsl:attribute>
		<xsl:attribute name="border-bottom-style">solid</xsl:attribute>
		<xsl:attribute name="border-bottom-width">1pt</xsl:attribute>
		<xsl:attribute name="border-bottom-color">#8CC63E</xsl:attribute>
		<xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
	</xsl:attribute-set>
	
<!--	The following attr set is supposed to elegantly break content. I don't think it works, so I'm
		using "&#8203;" in the parameter/filter names instead. -->

		<xsl:attribute-set name="tbody.row">
			<!--Table body row-->
			<xsl:attribute name="keep-together.within-column">always</xsl:attribute>
		</xsl:attribute-set>

</xsl:stylesheet>
