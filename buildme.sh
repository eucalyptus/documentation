# simple build script
# okay for real
# no, really really this time
# note that this will not work with the current build.properties
# unless you have xep installed and remove the hardcoded kindlegen references

#test to see if we're running under jenkins or not
echo "Testing for jenkins execution... "
if [ -n "$WORKSPACE" ]
then
echo "...running under jenkins; switching to $WORKSPACE and setting XEP_HOME"
cd "$WORKSPACE"
export XEP_HOME=/usr/local/RenderX/XEP
else
echo "...not running under jenkins"
fi

echo "----------------------------"
echo "Logged in as: " $USER
echo "----------------------------"


echo "Setting environment variables…"

export DITA_HOME="`pwd`/DITA-OT"
export DOC_HOME=`pwd`
export ANT_HOME="$DITA_HOME/tools/ant"
echo DITA_HOME IS $DITA_HOME
echo DOC_HOME is $DOC_HOME
echo ANT_HOME is $ANT_HOME

# Get the absolute path of DITAOT's home directory
cd "$DITA_HOME"
DITA_DIR="`pwd`"
echo DITA_DIR is $DITA_DIR
cd ..

# Make sure ant binary is executable
if [ -f "$DITA_DIR"/tools/ant/bin/ant ] && [ ! -x "$DITA_DIR"/tools/ant/bin/ant ]; then
echo "*** chmoding ant binary so it's executable ***"
chmod +x "$DITA_DIR"/tools/ant/bin/ant
fi

echo "*** Setting ant environment variables ***"
export ANT_OPTS="-Xmx512m $ANT_OPTS"
export ANT_OPTS="$ANT_OPTS -Djavax.xml.transform.TransformerFactory=net.sf.saxon.TransformerFactoryImpl"
#export ANT_HOME="$DITA_DIR"/tools/ant

echo "*** Adding project-specific version of ant to path ***"
export PATH="$DITA_DIR"/tools/ant/bin:"$PATH"

echo "*** Adding new CLASSPATH items ***"
NEW_CLASSPATH="$DITA_DIR/lib/saxon/saxon9.jar:$DITA_DIR/lib/saxon/saxon9-dom.jar:$DITA_DIR/lib:$DITA_DIR/lib/dost.jar:$DITA_DIR/lib/commons-codec-1.4.jar:$DITA_DIR/lib/resolver.jar:$DITA_DIR/lib/icu4j.jar"

#check to see if classpath already exists - if so, append our new values
if test -n "$CLASSPATH"
then
export CLASSPATH="$NEW_CLASSPATH":"$CLASSPATH"
else
export CLASSPATH="$NEW_CLASSPATH"
fi

# why do we wanna do this? nuking for now...
#echo "*** COPY THE BUILD PROPERTIES FILE OVER ***"
#cd $DOC_HOME/install_guide ; cp build.properties.buildy build.properties

#echo "*** Building admin guide ***"
#cd ag
#ant pdf
#cd ..
#echo "*** Building user guide ***"
#cd ug
#ant pdf
#cd ..
#echo "*** Building install guide ***"
#cd ig
#ant pdf
#cd ..
#echo "*** Building CLI reference ***"
#cd cli
#ant pdf
#cd ..
#echo "*** Building FastStart ***"
#cd fs
#ant pdf
#cd ..

#!/bin/bash
# use predefined variables to access passed arguments
#echo arguments to the shell
echo $1 $2 $3 ' -> echo $1 $2 $3'

# We can also store arguments from bash command line in special array
args=("$@")
#echo arguments to the shell
echo ${args[0]} ${args[1]} ${args[2]} ' -> args=("$@"); echo ${args[0]} ${args[1]} ${args[2]}'

#use $@ to print out all arguments at once
echo $@ ' -> echo $@'

# use $# variable to print out
# number of arguments passed to the bash script
echo Number of arguments passed: $# ' -> echo Number of arguments passed: $#' 

ant $@

echo "*** Builds done ***"
