<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">

<xsl:template match="/">
<xsl:variable name="apos" select='"&apos;"'/>
<xsl:variable name="comma" select='"&#44;"'/>

<xsl:text disable-output-escaping="yes">
<![CDATA[
var labelType, useGradients, nativeTextSupport, animate;

(function() {
  var ua = navigator.userAgent,
      iStuff = ua.match(/iPhone/i) || ua.match(/iPad/i),
      typeOfCanvas = typeof HTMLCanvasElement,
      nativeCanvasSupport = (typeOfCanvas == 'object' || typeOfCanvas == 'function'),
      textSupport = nativeCanvasSupport 
        && (typeof document.createElement('canvas').getContext('2d').fillText == 'function');
  //I'm setting this based on the fact that ExCanvas provides text support for IE
  //and that as of today iPhone/iPad current text support is lame
  labelType = (!nativeCanvasSupport || (textSupport && !iStuff))? 'Native' : 'HTML';
  nativeTextSupport = labelType == 'Native';
  useGradients = nativeCanvasSupport;
  animate = !(iStuff || !nativeCanvasSupport);
})();

var Log = {
  elem: false,
  write: function(text){
    if (!this.elem) 
      this.elem = document.getElementById('log');
    this.elem.innerHTML = text;
    this.elem.style.left = (500 - this.elem.offsetWidth / 2) + 'px';
  }
};


function init(){
    //init data
    var json = {
		 'label': ['count'],
        'values': [
 ]]></xsl:text>
<xsl:for-each-group select="//descendant::*" group-by="name()">

		<xsl:sort select="count(current-group())" order="descending"/>
		<xsl:value-of select="concat('{' , $apos , 'label' , $apos , ':' , $apos , name(), $apos , $comma , $apos , 'values' , $apos , ': &#91;' , string(count(current-group())) , '&#93;}' , $comma)" />
		<!-- kind of a hack, but putting in a zero value pie slice so that the .js file syntax is correct -->
</xsl:for-each-group>
		<xsl:text disable-output-escaping="yes">
<![CDATA[
		{ 'label': ' ','values': [0]}]};
		//init PieChart
    var pieChart = new $jit.PieChart({
      //id of the visualization container
      injectInto: 'infovis',
      //whether to add animations
      animate: false,
      //offsets
      offset: 30,
      sliceOffset: 0,
      labelOffset: 35,
      //slice style
      type: useGradients? 'stacked:gradient' : 'stacked',
      //whether to show the labels for the slices
      showLabels:true,
      //resize labels according to
      //pie slices values set 12px as
      //min label size
      resizeLabels: 12,
      //label styling
      Label: {
        type: labelType, //Native or HTML
        size: 30,
        family: 'Arial',
        color: 'black'
      },
      //enable tips
      Tips: {
        enable: true,
        onShow: function(tip, elem) {
           tip.innerHTML = "<b>" + elem.name + "</b>: " + elem.value;
        }
      }
    });
    //load JSON data.
    pieChart.loadJSON(json);
    //end
    var list = $jit.id('id-list'),
        button = $jit.id('update');
    //update json on click
    $jit.util.addEvent(button, 'click', function() {
      var util = $jit.util;
      if(util.hasClass(button, 'gray')) return;
      util.removeClass(button, 'white');
      util.addClass(button, 'gray');
      pieChart.updateJSON(json2);
    });
    //dynamically add legend to list
    var legend = pieChart.getLegend(),
        listItems = [];
    for(var name in legend) {
      listItems.push('<div class=\'query-color\' style=\'background-color:'
          + legend[name] +'\'>&nbsp;</div>' + name);
    }
    list.innerHTML = '<li>' + listItems.join('</li><li>') + '</li>';
}]]>
		</xsl:text>
</xsl:template>

</xsl:stylesheet>
