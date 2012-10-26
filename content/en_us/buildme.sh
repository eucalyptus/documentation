# simple build script
# okay for real
# no, really really this time
# note that this will not work with the current build.properties
# unless you have xep installed and remove the hardcoded kindlegen references

# JSB 2012-10-23: Updated for new doc repo directory structure

#test to see if we're running under jenkins or not
echo "*** BUILDME v5.0 ***" 
echo "Testing for jenkins execution... "
if [ -n "$WORKSPACE" ]
then
echo "...running under jenkins; switching to $WORKSPACE and setting up environment"

cd "$WORKSPACE"
echo "Current PWD: "
pwd

export XEP_HOME=/usr/local/RenderX/XEP
export DITA_HOME="/srv/jenkins/workspace/product-docs/tools/DITA-OT"
export DOC_HOME="/srv/jenkins/workspace/product-docs"
export PATH=$PATH:/$ANT_HOME
else

echo "...not running under jenkins..."

# JSB 2012-10-21: this was hardcoded for testing and is left for future testing; 
# your actual XEP_HOME variable should be defined in your shell profile:
#export XEP_HOME="/Users/scottb/xep"

export DITA_HOME="`pwd`/../../tools/DITA-OT"
export DOC_HOME="`pwd`/.."
fi

echo "----------------------------"
echo "Logged in as: " $USER
echo "----------------------------"


# ugly parent directory hacks to avoid breaking other build stuff:

export ANT_HOME="$DITA_HOME/tools/ant"

echo DITA_HOME IS $DITA_HOME
echo DOC_HOME is $DOC_HOME
echo ANT_HOME is $ANT_HOME
echo PATH is $PATH

# Get the absolute path of DITAOT's home directory
#cd "$DITA_HOME"
#DITA_DIR="`pwd`"
#echo DITA_DIR is $DITA_DIR
#cd "$CUR_PWD"

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

echo "Path is " $PATH

echo "*** Adding new CLASSPATH items ***"
NEW_CLASSPATH="$DITA_DIR/lib/saxon/saxon9.jar:$DITA_DIR/lib/saxon/saxon9-dom.jar:$DITA_DIR/lib:$DITA_DIR/lib/dost.jar:$DITA_DIR/lib/commons-codec-1.4.jar:$DITA_DIR/lib/resolver.jar:$DITA_DIR/lib/icu4j.jar"

#check to see if classpath already exists - if so, append our new values
if test -n "$CLASSPATH"
then
export CLASSPATH="$NEW_CLASSPATH":"$CLASSPATH"
else
export CLASSPATH="$NEW_CLASSPATH"
fi

args=("$@")

echo $@ 

# use $# variable to print out
# number of arguments passed to the bash script
echo Number of arguments passed: $# 

ant $@

echo "*** Builds done ***"
