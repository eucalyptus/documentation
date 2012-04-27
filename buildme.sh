#!/bin/sh
#simple build script
export DITA_HOME="`pwd`/DITA-OT"
export DOC_HOME=`pwd`
export ANT_HOME="/usr/bin/ant"

cd "$DITA_HOME"

# Get the absolute path of DITAOT's home directory
DITA_DIR="`pwd`"

if [ -f "$DITA_DIR"/tools/ant/bin/ant ] && [ ! -x "$DITA_DIR"/tools/ant/bin/ant ]; then
chmod +x "$DITA_DIR"/tools/ant/bin/ant
fi

export ANT_OPTS="-Xmx512m $ANT_OPTS"
export ANT_OPTS="$ANT_OPTS -Djavax.xml.transform.TransformerFactory=net.sf.saxon.TransformerFactoryImpl"
export ANT_HOME="$DITA_DIR"/tools/ant
export PATH="$DITA_DIR"/tools/ant/bin:"$PATH"

NEW_CLASSPATH="$DITA_DIR/lib:$DITA_DIR/lib/dost.jar:$DITA_DIR/lib/commons-codec-1.4.jar:$DITA_DIR/lib/resolver.jar:$DITA_DIR/lib/icu4j.jar"
NEW_CLASSPATH="$DITA_DIR/lib/saxon/saxon9.jar:$DITA_DIR/lib/saxon/saxon9-dom.jar:$NEW_CLASSPATH"
if test -n "$CLASSPATH"
then
export CLASSPATH="$NEW_CLASSPATH":"$CLASSPATH"
else
export CLASSPATH="$NEW_CLASSPATH"
fi

cd $DOC_HOME/install_guide ; cp build.properties.buildy build.properties

ant pdf
