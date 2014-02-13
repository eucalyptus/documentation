<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<!-- 
  Infrastructure for the feedback/comments. 
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="generateFeedbackDiv">
    
    <xsl:if test="string-length($WEBHELP_PRODUCT_ID) > 0">
      <div id="productInfo" style="display:none;">
        <span id="oxy_productID"><xsl:value-of select="$WEBHELP_PRODUCT_ID"/></span>
        <span id="oxy_productVersion"><xsl:value-of select="$WEBHELP_PRODUCT_VERSION"/></span>
      </div>
      <div id="loginData" style="display: none">
        <span class="bt_close" title="Close"><xsl:comment/></span>
      <form action="" target="passwordIframe" method="POST" name="form_login"
        onsubmit="return loggInUser();" id="loginFormData" autocomplete="on">
        <input type="hidden" id="reloadComments" value="yes" ><xsl:comment/></input>
        <table class="login">
          <thead>
            <tr>
              <td colspan="2">
                <span id="l_login2">
                  <script type="text/javascript">$('#l_login2').html(getLocalization('label.login'));</script>
                </span>
              </td>
            </tr>
            <tr>
              <td colspan="2">
                <div id="loginResponse"><xsl:comment/></div>
              </td>
            </tr>
          </thead>
          <tr>
            <td>
              <span id="l_userName">
                <script type="text/javascript">$('#l_userName').html(getLocalization('label.userName'));</script>
              </span>
            </td>
            <td>
              <input name="usernameW" type="text" id="myUserName" autocomplete="on"
                required="required" autofocus="autofocus" ><xsl:comment/></input>
            </td>
          </tr>
          <tr>
            <td>
              <span id="l_pswd">
                <script type="text/javascript">$('#l_pswd').html(getLocalization('label.pswd'));</script>
              </span>
            </td>
            <td>
              <input name="passwordW" type="password" id="myPassword" autocomplete="on"
                required="required" ><xsl:comment/></input>
            </td>
          </tr>
          <tr>
            <td colspan="2" align="left">
              <span id="ll_remember">
                <script type="text/javascript" xml:space="preserve">
								$('#ll_remember').html(getLocalization('label.rememberme'));
							</script>
              </span> &#160;&#160;&#160; <input name="myLoginRemember" type="checkbox" class="ck"
                id="myRemember" value="no" ><xsl:comment/></input>
            </td>
          </tr>
          <tr>
            <td colspan="2" align="center">
              <input id="l_bt_submit_log" type="submit" value="Submit" name="loginFormButton"><xsl:comment/></input>
              <script type="text/javascript">$('#l_bt_submit_log').attr('value',getLocalization('label.login'));</script>
              <span class="btnHGlue"><xsl:comment/></span>
              <input class="bt_cancel" id="l_cancelLog" type="button" value="Cancel"
                name="loginFormButton"><xsl:comment/></input>
              <script type="text/javascript">$('#l_cancelLog').attr('value',getLocalization('label.cancel'));</script>
            </td>
          </tr>
        </table>
        <div class="loginAlternative">
          <span id="link_lostPwd" onclick="showLostPwd()">
            <script type="text/javascript">$('#link_lostPwd').html(getLocalization('label.lostPswd'));</script>
          </span>
          <span id="link_signUp" onclick="showSignUp()">
            <script type="text/javascript">$('#link_signUp').html(getLocalization('label.signUp'));</script>
          </span>
        </div>
      </form>
        <iframe id="passwordIframe" name="passwordIframe" style="display:none"><xsl:comment/></iframe>
    </div>
    <div id="cmts"><xsl:comment/></div>
      
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>    
