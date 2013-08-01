<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:dita="***Function Processing***" xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/">
<xsl:param name="input"/>
<xsl:param name="fileroot"/>
<xsl:param name="OUTPUTDIR" />
<xsl:param name="FILTERFILE" />
<xsl:param name="BASEDIR" />
<xsl:include href="qachecks/_att_values.xsl"/>
<!-- the following file is an example of how to include company-specific terminology checks
<xsl:include href="qachecks/_citrix_terms.xsl"/>
-->
<xsl:include href="qachecks/_general_terms.xsl"/>
<xsl:include href="qachecks/_language_standards.xsl"/>
<xsl:include href="qachecks/_markup_checks.xsl"/>
<xsl:include href="qachecks/_nesting_elements.xsl"/>
<xsl:include href="qachecks/_output_standards.xsl"/>
<xsl:output method="html"/>
	
	<xsl:key name="tagErrors" match="li" use="@class" />
	
	<!--Use something like this for more advanced counting sequences...we don't have a need for this yet, but if we ever needed to create sub-classes, we might.  Either way, it's a nice blending of user-defined functions and keys.

	<xsl:function name="dita:errors" as="element(ul)">
		<xsl:param name="errorType" as="xs:string" />
		<xsl:param name="number" as="xs:string" />
		<xsl:variable name="identifier" select="concat($errorType, ':', $number)" />
		<xsl:sequence select="key('courses', $identifier, $hitCount)" />
	</xsl:function>-->


	<xsl:template match="/">
	
		<xsl:variable name="hitCount">
	       <xsl:for-each select="//*[contains(@class,'topic/body ')]">
					   <xsl:call-template name="att_values"/>
<!--					   <xsl:call-template name="citrix_terms"/>
-->					   <xsl:call-template name="general_terms"/>
					   <xsl:call-template name="language_standards"/>
					   <xsl:call-template name="markup_checks"/>
					   <xsl:call-template name="nesting_elements"/>
					   <xsl:call-template name="output_standards"/>
			</xsl:for-each> 
	    </xsl:variable>
	    <xsl:variable name="totalErrors">
	    <xsl:value-of select="count(key('tagErrors', 'tagerror', $hitCount)) + count(key('tagErrors', 'standard', $hitCount)) + count(key('tagErrors', 'syntaxerror', $hitCount))"/>
	    </xsl:variable>
	    <xsl:variable name="totalWarnings">
	    <xsl:value-of select="count(key('tagErrors', 'tagwarning', $hitCount)) + count(key('tagErrors', 'prodterm', $hitCount)) + count(key('tagErrors', 'genterm', $hitCount))"/>
	    </xsl:variable>
	    <xsl:variable name="OTDIR">
			<xsl:value-of select="replace($BASEDIR, '\\', '/')" />
	    </xsl:variable>
	    <xsl:variable name="inputMap">
			<xsl:value-of select="concat('file:///' , $OTDIR, '/' , $input)"/>
	    </xsl:variable>
	    
		<html>
			<head>
				<title>DITA QA Error Log</title>
				<!-- Pie Chart CSS Files -->
				<link type="text/css" href="css/base.css" rel="stylesheet" />
				<link type="text/css" href="css/PieChart.css" rel="stylesheet" />
				
				<!--[if IE]><script language="javascript" type="text/javascript" src="../../Extras/excanvas.js"></script><![endif]-->
				
				<!-- JIT Library File -->
				<script language="javascript" type="text/javascript" src="jit-yc.js"></script>
				
				<!-- Pie Chart  File -->
				<xsl:element name="script">
					<xsl:attribute name="language">javascript</xsl:attribute>
					<xsl:attribute name="type">text/javascript</xsl:attribute>
					<xsl:attribute name="src"><xsl:value-of select="$fileroot"/>.js</xsl:attribute>
				</xsl:element>
				
				<style type="text/css"><![CDATA[
				body {font-family:sans-serif;}
				p {color:#25383C}
				ul {list-style: square}
				.tagerror {color: #B80000  }
				.tagwarning {color: #FFC125  }
				.standard {color: #385E0F  }
				.syntaxerror {color: #B80000  }
				.prodterm {color: #330099  }
				.genterm {color: #330099  }
				#main {
					margin-left:10.2em;
					margin-right:10.2em;
					padding-left:1em;
					padding-right:1em;
					}
				ul.twocolumn {
					width: 400px;
						}
				ul.twocolumn li {
					width: 190px;
					float: left;
						} 
			]]></style>
			</head>
			<body  onload="init();">
				<!-- trying to get the bookmap title, but the document function works relative to this xsl file, not to build.xml, so the input variable doesn't point to an actual document -->
				<h1>QA Error Log</h1> <!--: <xsl:value-of select="document($inputMap)//mainbooktitle"/>-->
				<font face="sans-serif">
					<table border="1" cellpadding="2" cellspacing="2">
						<tbody>
							<tr>
								<td rowspan="9">
								<xsl:choose>
									<xsl:when test="($totalErrors + $totalWarnings) &gt; 30">
										<p align="center"><font size="20">FAIL</font></p>
										<img alt="FAIL" src="img/fail.png"></img>
									</xsl:when>
									<xsl:when test="($totalErrors + $totalWarnings) &lt; 30">
									<p align="center"><font size="20">PASS</font></p>
									<img alt="FAIL" src="img/pass.png"></img>
									</xsl:when>
								</xsl:choose>
								
								<!-- use an if statement to select a pass or fail image -->
								<p align="center">Total violation count: <xsl:value-of select="$totalErrors + $totalWarnings"/></p>
								</td>
							</tr>
							<tr>
								<td><b>Pass/Fail</b></td>
								<td><b>Check Type</b></td>
								<td><b>Violations</b></td>
							</tr>
							<tr>	
								<td>
								<xsl:choose>
								<xsl:when test="count(key('tagErrors', 'tagerror', $hitCount)) &gt; 10">
								<img alt="FAIL" src="img/failsm.png"></img>
								</xsl:when>
								<xsl:when test="count(key('tagErrors', 'tagerror', $hitCount)) &lt; 10">
								<img alt="FAIL" src="img/passsm.png"></img>
								</xsl:when>
								</xsl:choose>
								</td>
								<td><font class="tagerror">Tagging errors</font></td>
								<td><xsl:value-of select="count(key('tagErrors', 'tagerror', $hitCount))" /></td>
							</tr>
							<tr>
								<td>
								<xsl:choose>
								<xsl:when test="count(key('tagErrors', 'tagwarning', $hitCount)) &gt; 10">
								<img alt="FAIL" src="img/failsm.png"></img>
								</xsl:when>
								<xsl:when test="count(key('tagErrors', 'tagwarning', $hitCount)) &lt; 10">
								<img alt="FAIL" src="img/passsm.png"></img>
								</xsl:when>
								</xsl:choose></td>
								<td><font class="tagwarning">Tagging warnings</font></td>
								<td><xsl:value-of select="count(key('tagErrors', 'tagwarning', $hitCount))"/></td>
							</tr>
							<tr>
								<td>
								<xsl:choose>
								<xsl:when test="count(key('tagErrors', 'standard', $hitCount)) &gt; 10">
								<img alt="FAIL" src="img/failsm.png"></img>
								</xsl:when>
								<xsl:when test="count(key('tagErrors', 'standard', $hitCount)) &lt; 10">
								<img alt="FAIL" src="img/passsm.png"></img>
								</xsl:when>
								</xsl:choose>
								</td>
								<td><font class="standard">Standards violations</font></td>
								<td><xsl:value-of select="count(key('tagErrors', 'standard', $hitCount))"/></td>
							</tr>
							<tr>
								<td>
								<xsl:choose>
								<xsl:when test="count(key('tagErrors', 'syntaxerror', $hitCount)) &gt; 0">
								<img alt="FAIL" src="img/failsm.png"></img>
								</xsl:when>
								<xsl:when test="count(key('tagErrors', 'syntaxerror', $hitCount)) = 0">
								<img alt="FAIL" src="img/passsm.png"></img>
								</xsl:when>
								</xsl:choose>
								</td>
								<td><font class="syntaxerror">Syntax errors</font></td>
								<td><xsl:value-of select="count(key('tagErrors', 'syntaxerror', $hitCount))"/></td>
							</tr>
							<tr>
								<td>
								<xsl:choose>
								<xsl:when test="count(key('tagErrors', 'prodterm', $hitCount)) &gt; 10">
								<img alt="FAIL" src="img/failsm.png"></img>
								</xsl:when>
								<xsl:when test="count(key('tagErrors', 'prodterm', $hitCount)) &lt; 10">
								<img alt="FAIL" src="img/passsm.png"></img>
								</xsl:when>
								</xsl:choose>
								</td>
								<td><font class="prodterm">Product terminology warnings</font></td>
								<td><xsl:value-of select="count(key('tagErrors', 'prodterm', $hitCount))"/></td>
							</tr>
							<tr>
								<td>
								<xsl:choose>
								<xsl:when test="count(key('tagErrors', 'genterm', $hitCount)) &gt; 10">
								<img alt="FAIL" src="img/failsm.png"></img>
								</xsl:when>
								<xsl:when test="count(key('tagErrors', 'genterm', $hitCount)) &lt; 10">
								<img alt="FAIL" src="img/passsm.png"></img>
								</xsl:when>
								</xsl:choose>
								</td>
								<td><font class="genterm">General terminology warnings</font></td>
								<td><xsl:value-of select="count(key('tagErrors', 'genterm', $hitCount))"/></td>
							</tr>
						</tbody>
					</table>
					<br/>
					<hr/>
					<h2>Summary of Content Processed</h2>
					<div id="infovis" style="float:right;"></div>
					<table border="1" cellpadding="2" cellspacing="2">
						<tbody>
							<tr>
								<td>Report run on</td>
								<td><xsl:value-of select="current-date()"/></td>
							</tr>
							<tr>
								<td>Document info</td>
								<td>
								<ul>
									<li>map processed: <xsl:value-of select="$inputMap"/></li>
									<li>language values set: <xsl:value-of select="distinct-values(//*/@xml:lang)" separator=", " /></li>
<!--	lists each unique domain value, but it is a long list	<li>domains used: <xsl:value-of select="distinct-values(//*/@domains)" separator=", " /></li> -->	
									<li>DITA versions used: <xsl:value-of select="distinct-values(//*/@ditaarch:DITAArchVersion)" separator=", " /></li>
									<li>DITA Open Toolkit build log: <a href="qalog.xml" target="_blank">open in new window</a></li>
								</ul>
								</td>
							</tr>
							<tr>
								<td>Topic info</td>
								<td>
								<ul>
									<li>total topics: <xsl:value-of select="count(//*[contains(@class,' topic/topic ')])"/></li>
									<li>concept: <xsl:value-of select="count(//*[contains(@class,' topic/topic concept/concept')])"/></li>
									<li>task: <xsl:value-of select="count(//*[contains(@class,' topic/topic task/task')])"/></li>
									<li>reference: <xsl:value-of select="count(//*[contains(@class,' topic/topic reference/reference')])"/></li>
									<li>total images: <xsl:value-of select="count(//image)"/></li>
								</ul></td>
							</tr>
							<tr>
								<td>Conditions found</td>
								<td>
										<ul>
										<li>filter file: <xsl:value-of select="$FILTERFILE"/></li> <!-- set up a choose , when filterfile is set, spit out the name, when it is not, say filter not applied -->
										<li>audience: <xsl:value-of select="distinct-values(//*/@audience)" separator=", " /></li>
										<li>platform:<xsl:value-of select="distinct-values(//*/@platform)" separator=", " /></li>
										<li>product: <xsl:value-of select="distinct-values(//*/@product)" separator=", " /></li>
										<li>otherprops: <xsl:value-of select="distinct-values(//*/@otherprops)" separator=", "/></li>
										</ul>
								</td>
							</tr>
							<tr>
							<td>Element Counts</td>
							<td>
								<p>Course contains <xsl:value-of select="count(distinct-values(descendant::*))" /> distinct tag values in <xsl:value-of select="count(descendant::*)" /> tags.</p>	<p>Total words: <xsl:value-of select="count(tokenize(lower-case(.),'(\s|[,.?!:;])+')[string(.)])"/></p>
								<!-- use this code in new stylesheet
							<ul class="twocolumn">
							<xsl:for-each-group select="//descendant::*" group-by="name()">
												<xsl:sort select="count(current-group())" order="descending"/> 
												<li><xsl:value-of select="concat(name(),': ',string(count(current-group())),'&#10;')"/></li>												
							   </xsl:for-each-group>
							<xsl:for-each select="//*">
									<xsl:sort select="count(descendant::*)" data-type="number"/>
												</xsl:for-each> </ul>		
									-->
							</td>
							</tr>
						</tbody>
					</table>
					<br/>
					<hr/>
					<h2>QA Violations</h2>
					<xsl:apply-templates select="//*[contains(@class,' topic/body ')]"/>
				</font>
			</body>
		</html>
		
		
		
	</xsl:template>
	<xsl:template match="*[contains(@class,' topic/body ')]">
		
		<xsl:for-each select="self::conbody | self::taskbody | self::refbody | self::body">

				<p><b>Topic title: <xsl:value-of select="preceding-sibling::title[contains(@class, ' topic/title ')]"/></b><br></br>
					File path: <xsl:element name="a">
										<xsl:attribute name="href">file:///<xsl:value-of select="@xtrf"/></xsl:attribute>
										<xsl:attribute name="target">_blank</xsl:attribute>
										<xsl:value-of select="@xtrf"/>
										</xsl:element><br></br>
					Revision: <xsl:choose>
										<xsl:when test="exists(../@rev)">
											<xsl:value-of select="../@rev"/>						
									</xsl:when>
									<xsl:otherwise>
										@rev not set on topic root element.
									</xsl:otherwise>
									</xsl:choose>
					<br></br>
					Status: <xsl:choose>
										<xsl:when test="exists(../@status)">
											<xsl:value-of select="../@status"/>						
									</xsl:when>
									<xsl:otherwise>
										@status not set on topic root element.
									</xsl:otherwise>
									</xsl:choose>
				</p>
				<p>Word count: <xsl:value-of select="count(tokenize(lower-case(.),'(\s|[,.?!:;])+')[string(.)])"/></p> <!-- does not count contents of topic titles-->
				<!-- for each error type, create a collapsible div that indicates which template the error came from-->
					   <xsl:call-template name="att_values"/>
<!--					   <xsl:call-template name="citrix_terms"/>
-->					   <xsl:call-template name="general_terms"/>
					   <xsl:call-template name="language_standards"/>
					   <xsl:call-template name="markup_checks"/>
					   <xsl:call-template name="nesting_elements"/>
					   <xsl:call-template name="output_standards"/>
				<hr/>
		
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
