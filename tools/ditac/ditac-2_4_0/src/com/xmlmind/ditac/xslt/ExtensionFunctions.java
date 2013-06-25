/*
 * Copyright (c) 2009-2013 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.xslt;

import java.lang.reflect.Method;
import javax.xml.transform.TransformerFactory;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.DoubleValue;
import net.sf.saxon.value.StringValue;
import net.sf.saxon.om.StructuredQName; 
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.Configuration;
import net.sf.saxon.TransformerFactoryImpl;

/**
 * This class allows to register with Saxon 9.2+ all the extension functions 
 * needed to run the XSL stylesheets found in
 * <tt><i>ditac_install_dir</i>/xsl/</tt>.
 */
public final class ExtensionFunctions {
    /**
     * Registers with Saxon 9.2+ all the extension functions 
     * needed to run the XSL stylesheets found in 
     * <tt><i>ditac_install_dir</i>/xsl/</tt>.
     * <p>This method must be invoked once per TransformerFactory.
     *
     * @param factory the TransformerFactory pointing to
     * Saxon 9.2+ extension function registry 
     * (that is, a <tt>net.sf.saxon.Configuration</tt>). 
     * This object must be an instance of 
     * <tt>net.sf.saxon.TransformerFactoryImpl</tt>.
     */
    public static void registerAll(TransformerFactory factory) 
        throws Exception {
        Configuration config = Configuration.newConfiguration();

        config.registerExtensionFunction(new DecodeURIDefinition());
        config.registerExtensionFunction(new UserDirectoryDefinition());
        config.registerExtensionFunction(new UuidUriDefinition());
        config.registerExtensionFunction(new CopyFileDefinition());
        config.registerExtensionFunction(new GetImageWidthDefinition());
        config.registerExtensionFunction(new GetImageHeightDefinition());
        config.registerExtensionFunction(new FormatDateDefinition());

        Method highlightMethod = null;
        try {
            Class<?> xslthlClass = 
                Class.forName("net.sf.xslthl.ConnectorSaxonHE");
            highlightMethod = xslthlClass.getMethod("highlight", 
                                                    XPathContext.class,
                                                    String.class,
                                                    SequenceIterator.class,
                                                    String.class);
        } catch (Exception ignored) {}
        if (highlightMethod != null) {
            config.registerExtensionFunction(
                new HighlightDefinition(highlightMethod));
        }

        ((TransformerFactoryImpl) factory).setConfiguration(config);
    }

    // -----------------------------------------------------------------------
    // URI:decodeURI
    // -----------------------------------------------------------------------

    public static final class DecodeURIDefinition 
                        extends ExtensionFunctionDefinition {
        public StructuredQName getFunctionQName() {
            return new StructuredQName("URI", 
                                       "java:com.xmlmind.ditac.xslt.URI", 
                                       "decodeURI");
        }

        public int getMinimumNumberOfArguments() {
            return 1;
        }

        public SequenceType[] getArgumentTypes() {
            return new SequenceType[] { SequenceType.SINGLE_STRING };
        }

        public SequenceType getResultType(SequenceType[] suppliedArgTypes) {
            return SequenceType.SINGLE_STRING;
        }

        public ExtensionFunctionCall makeCallExpression() {
            return new DecodeURICall();
        }
    }

    public static final class DecodeURICall extends ExtensionFunctionCall {
        public SequenceIterator call(SequenceIterator[] arguments,
                                     XPathContext context)
            throws XPathException {
            StringValue arg = (StringValue) arguments[0].next();

            String result = URI.decodeURI(arg.getStringValue());

            return (new StringValue(result)).iterate();
        }
    }

    // -----------------------------------------------------------------------
    // URI:userDirectory
    // -----------------------------------------------------------------------

    public static final class UserDirectoryDefinition 
                        extends ExtensionFunctionDefinition {
        public StructuredQName getFunctionQName() {
            return new StructuredQName("URI", 
                                       "java:com.xmlmind.ditac.xslt.URI", 
                                       "userDirectory");
        }

        public int getMinimumNumberOfArguments() {
            return 0;
        }

        @Override
        public int getMaximumNumberOfArguments() {
            return 0;
        }

        public SequenceType[] getArgumentTypes() {
            // Does not work with an empty array.
            return new SequenceType[] { SequenceType.OPTIONAL_STRING };
        }

        public SequenceType getResultType(SequenceType[] suppliedArgTypes) {
            return SequenceType.SINGLE_STRING;
        }

        public ExtensionFunctionCall makeCallExpression() {
            return new UserDirectoryCall();
        }
    }

    public static final class UserDirectoryCall extends ExtensionFunctionCall {
        public SequenceIterator call(SequenceIterator[] arguments,
                                     XPathContext context)
            throws XPathException {
            String result = URI.userDirectory();

            return (new StringValue(result)).iterate();
        }
    }

    // -----------------------------------------------------------------------
    // URI:uuidURI
    // -----------------------------------------------------------------------

    public static final class UuidUriDefinition 
                        extends ExtensionFunctionDefinition {
        public StructuredQName getFunctionQName() {
            return new StructuredQName("URI", 
                                       "java:com.xmlmind.ditac.xslt.URI", 
                                       "uuidURI");
        }

        public int getMinimumNumberOfArguments() {
            return 0;
        }

        @Override
        public int getMaximumNumberOfArguments() {
            return 0;
        }

        public SequenceType[] getArgumentTypes() {
            // Does not work with an empty array.
            return new SequenceType[] { SequenceType.OPTIONAL_STRING };
        }

        public SequenceType getResultType(SequenceType[] suppliedArgTypes) {
            return SequenceType.SINGLE_STRING;
        }

        public ExtensionFunctionCall makeCallExpression() {
            return new UuidUriCall();
        }
    }

    public static final class UuidUriCall extends ExtensionFunctionCall {
        public SequenceIterator call(SequenceIterator[] arguments,
                                     XPathContext context)
            throws XPathException {
            String result = URI.uuidURI();

            return (new StringValue(result)).iterate();
        }
    }

    // -----------------------------------------------------------------------
    // URI:copyFile
    // -----------------------------------------------------------------------

    public static final class CopyFileDefinition 
                        extends ExtensionFunctionDefinition {
        public StructuredQName getFunctionQName() {
            return new StructuredQName("URI", 
                                       "java:com.xmlmind.ditac.xslt.URI", 
                                       "copyFile");
        }

        public int getMinimumNumberOfArguments() {
            return 2;
        }

        public SequenceType[] getArgumentTypes() {
            return new SequenceType[] { SequenceType.SINGLE_STRING,
                                        SequenceType.SINGLE_STRING };
        }

        public SequenceType getResultType(SequenceType[] suppliedArgTypes) {
            return SequenceType.SINGLE_DOUBLE;
        }

        public ExtensionFunctionCall makeCallExpression() {
            return new CopyFileCall();
        }
    }

    public static final class CopyFileCall extends ExtensionFunctionCall {
        public SequenceIterator call(SequenceIterator[] arguments,
                                     XPathContext context)
            throws XPathException {
            StringValue src = (StringValue) arguments[0].next();
            StringValue dst = (StringValue) arguments[1].next();

            int copied = URI.copyFile(src.getStringValue(), 
                                      dst.getStringValue());

            return (new DoubleValue(copied)).iterate();
        }
    }

    // -----------------------------------------------------------------------
    // Image:getWidth
    // -----------------------------------------------------------------------

    public static final class GetImageWidthDefinition 
                        extends ExtensionFunctionDefinition {
        public StructuredQName getFunctionQName() {
            return new StructuredQName("Image", 
                                       "java:com.xmlmind.ditac.xslt.Image", 
                                       "getWidth");
        }

        public int getMinimumNumberOfArguments() {
            return 1;
        }

        public SequenceType[] getArgumentTypes() {
            return new SequenceType[] { SequenceType.SINGLE_STRING };
        }

        public SequenceType getResultType(SequenceType[] suppliedArgTypes) {
            return SequenceType.SINGLE_DOUBLE;
        }

        public ExtensionFunctionCall makeCallExpression() {
            return new GetImageWidthCall();
        }
    }

    public static final class GetImageWidthCall extends ExtensionFunctionCall {
        public SequenceIterator call(SequenceIterator[] arguments,
                                     XPathContext context)
            throws XPathException {
            StringValue arg = (StringValue) arguments[0].next();

            int result = Image.getWidth(arg.getStringValue());

            return (new DoubleValue(result)).iterate();
        }
    }

    // -----------------------------------------------------------------------
    // Image:getHeight
    // -----------------------------------------------------------------------

    public static final class GetImageHeightDefinition 
                        extends ExtensionFunctionDefinition {
        public StructuredQName getFunctionQName() {
            return new StructuredQName("Image", 
                                       "java:com.xmlmind.ditac.xslt.Image", 
                                       "getHeight");
        }

        public int getMinimumNumberOfArguments() {
            return 1;
        }

        public SequenceType[] getArgumentTypes() {
            return new SequenceType[] { SequenceType.SINGLE_STRING };
        }

        public SequenceType getResultType(SequenceType[] suppliedArgTypes) {
            return SequenceType.SINGLE_DOUBLE;
        }

        public ExtensionFunctionCall makeCallExpression() {
            return new GetImageHeightCall();
        }
    }

    public static final class GetImageHeightCall extends ExtensionFunctionCall {
        public SequenceIterator call(SequenceIterator[] arguments,
                                     XPathContext context)
            throws XPathException {
            StringValue arg = (StringValue) arguments[0].next();

            int result = Image.getHeight(arg.getStringValue());

            return (new DoubleValue(result)).iterate();
        }
    }

    // -----------------------------------------------------------------------
    // Date:format
    // -----------------------------------------------------------------------

    public static final class FormatDateDefinition 
                        extends ExtensionFunctionDefinition {
        public StructuredQName getFunctionQName() {
            return new StructuredQName("Date", 
                                       "java:com.xmlmind.ditac.xslt.Date", 
                                       "format");
        }

        public int getMinimumNumberOfArguments() {
            return 2;
        }

        public SequenceType[] getArgumentTypes() {
            return new SequenceType[] { SequenceType.SINGLE_STRING, 
                                        SequenceType.SINGLE_STRING };
        }

        public SequenceType getResultType(SequenceType[] suppliedArgTypes) {
            return SequenceType.SINGLE_STRING;
        }

        public ExtensionFunctionCall makeCallExpression() {
            return new FormatDateCall();
        }
    }

    public static final class FormatDateCall extends ExtensionFunctionCall {
        public SequenceIterator call(SequenceIterator[] arguments,
                                     XPathContext context)
            throws XPathException {
            StringValue arg0 = (StringValue) arguments[0].next();
            StringValue arg1 = (StringValue) arguments[1].next();

            String result = Date.format(arg0.getStringValue(),
                                        arg1.getStringValue());

            return (new StringValue(result)).iterate();
        }
    }

    // -----------------------------------------------------------------------
    // ConnectorSaxonHE:highlight
    // -----------------------------------------------------------------------

    public static final class HighlightDefinition 
                        extends ExtensionFunctionDefinition {
        private final Method highlightMethod;

        public HighlightDefinition(Method highlightMethod) {
            this.highlightMethod = highlightMethod;
        }

        public StructuredQName getFunctionQName() {
            return new StructuredQName("Highlight", 
                                       "java:com.xmlmind.ditac.xslt.Highlight", 
                                       "highlight");
        }

        public int getMinimumNumberOfArguments() {
            return 2;
        }

        @Override
        public int getMaximumNumberOfArguments() {
            return 3;
        }

        public SequenceType[] getArgumentTypes() {
            return new SequenceType[] { SequenceType.SINGLE_STRING,
                                        SequenceType.NODE_SEQUENCE,
                                        SequenceType.SINGLE_STRING };
        }

        public SequenceType getResultType(SequenceType[] suppliedArgTypes) {
            return SequenceType.NODE_SEQUENCE;
        }

        public ExtensionFunctionCall makeCallExpression() {
            return new HighlightCall(highlightMethod);
        }
    }

    public static final class HighlightCall extends ExtensionFunctionCall {
        private final Method highlightMethod;

        public HighlightCall(Method highlightMethod) {
            this.highlightMethod = highlightMethod;
        }

        public SequenceIterator call(SequenceIterator[] arguments,
                                     XPathContext context)
            throws XPathException {
            StringValue arg0 = (StringValue) arguments[0].next();
            String hlCode = arg0.getStringValue();

            SequenceIterator nodes = arguments[1];

            String configFilename = null;
            if (arguments.length > 2) {
                StringValue arg2 = (StringValue) arguments[2].next();
                configFilename = arg2.getStringValue();
            }

            try {
                return (SequenceIterator) 
                    highlightMethod.invoke(null, context,
                                           hlCode, nodes, configFilename);
            } catch (Exception shouldNotHappen) {
                shouldNotHappen.printStackTrace();
                return null;
            }
        }
    }
}
