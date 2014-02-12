<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<!-- Use this function to handle the following checks...shows error in xmlspy, but 2.0 should be able to handle xsl:function-->
  
<xsl:template name="general_terms">

<xsl:variable name="excludes" select="not (codeblock or draft-comment or filepath or shortdesc or uicontrol or varname)"/>

<!-- Product specific terminology -->
<xsl:if test=".//*[$excludes]/text()[contains(.,'client device')]"><li class="prodterm">client device should be "user device"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'endpoint device')]"><li class="prodterm">endpoint device should be "user device"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'knowledge base')]"><li class="prodterm">knowledge
	base should be "Engage"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'print driver')]"><li class="prodterm">print driver should be "printer driver"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'server farm')]"><li class="prodterm">server farm should be "farm"</li></xsl:if>
	
<xsl:if test=".//*[$excludes]/text()[contains(.,'above')]"><li class="genterm">Use only for physical space or screen descriptions, e.g., "the outlet above the floor," or "the foo button above the bar pane." For orientation within a document use previous, preceding, or earlier.</li></xsl:if>

	<xsl:if test=".//*[$excludes]/text()[contains(.,'affect')]"><li class="genterm">affect vs. effect -
		An affect is an influence; an effect is a result. If you affect the outcome, you modify it. If you effect the outcome, you cause it.</li></xsl:if>
	
	<xsl:if test=".//*[$excludes]/text()[contains(.,'effect')]"><li class="genterm">affect vs. effect -
		An affect is an influence; an effect is a result. If you affect the outcome, you modify it. If you effect the outcome, you cause it.</li></xsl:if>

<!-- General phrasing/terminology based on Microsoft Manual of Style for Technical Publications -->
<xsl:if test=".//*[$excludes]/text()[contains(.,'and/or')]"><li class="genterm">and/or - Although popular, the phrase is ambiguous and unnecessary in technical writing. Use either "both...and" or "either...or," as the situation requires.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'anti-virus')]"><li class="genterm">anti-virus - Do not hyphenate</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'boot')]"><li class="genterm">boot - Use "turn on" (for physical machines) or "start" (for virtual machines)</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'click on')]"><li class="genterm">click on - Use "click"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'context menu')]"><li class="genterm">context menu - Use "shortcut menu"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'crash')][not(contains(., 'crash dump'))]"><li class="genterm">crash - Use "fail", "stop responding", or another appropriate term</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'datastore')]"><li class="genterm">datastore - Use "data store"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'demilitarized zone')]"><li class="genterm">demilitarized zone - Use "perimeter network"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(., 'dialog')][not(contains(., 'dialog box'))]"><li>Do not use "dialog." Use "dialog box."</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'dmz')]"><li class="genterm">dmz - Use "perimeter network"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'drag and drop')]"><li class="genterm">drag and drop - Use "drag (to)"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'either/or')]"><li class="genterm">either/or - Expand sentence to be more specific</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'email')]"><li class="genterm">email - Use "e-mail"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'engineer') and not(contains(., 'engineered')) and not(contains(., 'engineering'))]"><li class="genterm">engineer - Check for need to rephrase as second person</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'engineers')]"><li class="genterm">engineers - Check for need to rephrase as second person</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,' foo ')]"><li class="genterm"> foo  - Choose another placeholder</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,' foobar')]"><li class="genterm"> foobar - Choose another placeholder</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'for more information on')]"><li class="genterm">for more information on - Use "for more information about"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'gig ')]"><li class="genterm">gig - Use the standard abbreviation for the unit (e.g., "GB")</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'gigs')]"><li class="genterm">gigs - Use the standard abbreviation for the unit (e.g., "GB")</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,' hang')]"><li class="genterm">hang - Use "fail" or "stop responding"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,' hit ')]"><li class="genterm">hit - Use "press"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'hkey_local_machine')]"><li class="genterm">hkey_local_machine - Use "HKLM"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'hkey_current_user')]"><li class="genterm">hkey_current_user - Use "HKCU"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'insecure')]"><li class="genterm">insecure - Use "not secure"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'instantiate')]"><li class="genterm">instantiate - Use "create an instance of"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'kbps')]"><li class="genterm">kbps - Use "KB per second" (for bytes) or "Kb per second" (for bits).</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'leverage')]"><li class="genterm">leverage - Use "use", "take advantage of", "capitalize on", or another more appropriate word or phrase</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'login')]"><li class="genterm">login - Use "log on" (verb) or "logon" (noun or adjective)</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'log in')]"><li class="genterm">log in - Use "log on" (verb) or "logon" (noun or adjective)</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'logged in')]"><li class="genterm">logged in - Use "logged on" (verb)</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'logoff of')]"><li class="genterm">logoff of - Use "log off from" (verb)</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'log off of')]"><li class="genterm">log off of - Use "log off from" (verb)</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'log onto')]"><li class="genterm">log onto - Use "log on to" (verb)</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'log out')]"><li class="genterm">log out - Use "log off" (verb) or "logoff" (noun or adjective)</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'logout')]"><li class="genterm">logout - Use "log off" (verb) or "logoff" (noun or adjective)</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'mouse over')]"><li class="genterm">mouse over - Use a phrase such as "move the pointer over the button" or "hover"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'multi-')]"><li class="genterm">multi- - Remove hyphen</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'navigate to')]"><li class="genterm">navigate to - Use "browse to" or "go to"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'obfuscate')]"><li class="genterm">obfuscate - Use "conceal", "obscure", or some other less clumsy word</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'patch')]"><li class="genterm">patch - Use "update"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'pop-up')]"><li class="genterm">pop-up - Use "dialog box"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'power on')]"><li class="genterm">power on - Use "turn on" (for physical machines) or "start" (for virtual machines)</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'power up')]"><li class="genterm">power up - Use "turn on" (for physical machines) or "start" (for virtual machines)</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'power off')]"><li class="genterm">power off - Use "turn off" (for physical machines) or "shut down" (for virtual machines)</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'power down')]"><li class="genterm">power down - Use "turn off" (for physical machines) or "shut down" (for virtual machines)</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'purge')]"><li class="genterm">purge - Use "delete", "clear", or "remove"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'radio button')]"><li class="genterm">radio button - Use "option" or the label name in the interface</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'reboot')]"><li class="genterm">reboot - Use "restart"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'(s)')]"><li class="genterm">(s) - Use the plural or "one or more"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'slave')]"><li class="genterm">slave - Use "subordinate", "client", "worker", or another appropriate term</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'system prompt')]"><li class="genterm">system prompt - Use "command prompt"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'toggle')]"><li class="genterm">toggle - Use "switch", "click", or "turn on and turn off"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'understand')]"><li class="genterm">understand - Rephrase with an observable action</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'utilize')]"><li class="genterm">utilize - Use "use"</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'Windows start button')]"><li class="genterm">Windows start button - Use "Start button"</li></xsl:if>

<!-- General terminology based on Citrix UI Writing Style Guide -->
<xsl:if test=".//*[$excludes]/text()[contains(.,'abort')]"><li class="genterm">Instead of "abort" use "cancel" or "stop."</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'as long as')]"><li class="genterm">Instead of "as long as" use "provided that" or "if."</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'domestic')]"><li class="genterm">Avoid using "domestic" to refer to the United States. Use a more specific reference, like "in the US."</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'e.g.')]"><li class="genterm">Instead of "e.g." use "for example."</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'etc.')]"><li class="genterm">Instead of "etc." use "and so on" or "and so forth."</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'execute')]"><li class="genterm">Avoid "execute" when referring to commands. Use "start" or "run" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'fatal error')]"><li class="genterm">Avoid "fatal error." Use "unrecoverable error" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'terminal error')]"><li class="genterm">Avoid "terminal error." Use "unrecoverable error" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'foreign')]"><li class="genterm">Avoid "foreign" when referring to a location outside the United States. Use a more specific reference, like "outside the US."</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'gray')]"><li class="genterm">Avoid "gray" when referring to unavailable menu items. Use "not available" or "unavailable" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'grayed out')]"><li class="genterm">Avoid "grayed out" when referring to unavailable menu items. Use "not available" or "unavailable" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'hang')]"><li class="genterm">Avoid "hang" when referring to programs that have stopped responding. Use "stop" or "stopped" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'hung')]"><li class="genterm">Avoid "hung" when referring to programs that have stopped responding. Use "stop" or "stopped" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'i.e.')]"><li class="genterm">Avoid "i.e." Use "that is" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'in spite of')]"><li class="genterm">Avoid "in spite of." Use "regardless" or "despite" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'kill')]"><li class="genterm">Avoid "kill." Use "end" or "stop" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'may')]"><li class="genterm">Avoid "may." Use "might" or "can" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'not many')]"><li class="genterm">Avoid using "not many." Use "few" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'on the other hand')]"><li class="genterm">Avoid "on the other hand" Use "however" or "alternatively" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'punch')]"><li class="genterm">Avoid punch." Use "enter," "press," or "type" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'(s)')]"><li class="genterm">Avoid using "(s)" to indicate plural. Use the plural form of the word instead, such as "devices."</li></xsl:if>
	<xsl:if test=".//*[$excludes]/text()[contains(.,'system')]"><li class="genterm">Avoid using
		"system" to indicate cloud or network or group of machines. Use the specific term like "cloud" or
		network instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'via')]"><li class="genterm">Avoid "via." Use "across," "along," "by," "from," "on," "through," or "using" instead.</li></xsl:if>
<xsl:if test=".//*[$excludes]/text()[contains(.,'wish')]"><li class="genterm">Avoid "wish." Use "want" instead.</li></xsl:if>


</xsl:template>
</xsl:stylesheet>