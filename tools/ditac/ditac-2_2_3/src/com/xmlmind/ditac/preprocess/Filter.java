/*
 * Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.io.IOException;
import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import org.w3c.dom.Node;
import org.w3c.dom.Attr;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.ThrowableUtil;
import com.xmlmind.util.ArrayUtil;
import com.xmlmind.util.StringUtil;
import com.xmlmind.util.StringList;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.FileUtil;
import com.xmlmind.util.XMLText;
import com.xmlmind.util.Console;
import com.xmlmind.ditac.util.NodeLocation;
import com.xmlmind.ditac.util.LoadDocument;
import com.xmlmind.ditac.util.SaveDocument;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;
import com.xmlmind.ditac.util.Resolve;
import com.xmlmind.ditac.util.SimpleConsole;
import com.xmlmind.ditac.util.ConsoleHelper;

/**
 * Representation of a conditional processing profile (contents of a
 * <tt>.ditaval</tt> file).
 */
public final class Filter implements Constants {
    public static final class Prop implements Comparable<Prop> {
        /**
         * May be null: means any.
         * If not null, uses Clark's notation. 
         * Example: {http://www.w3.org/XML/1998/namespace}lang.
         */
        public final String attribute;
        private PropValue[] values;

        public Prop(String attribute, PropValue value) {
            this.attribute = attribute;
            values = new PropValue[] { value };
        }

        public void addValue(PropValue value) {
            int index = -1;
            String v = value.value;

            for (int i = 0; i < values.length; ++i) {
                String v2 = values[i].value;

                if ((v2 == null && v == null) ||
                    (v2 != null && v2.equals(v))) {
                    index = i;
                    break;
                }
            }

            if (index < 0) {
                values = ArrayUtil.append(values, value);
            } else {
                values[index] = value;
            }
        }

        public int getValueCount() {
            return values.length;
        }

        public PropValue[] getValues() {
            return values;
        }

        public PropValue findValue(String value) {
            int valueCount = values.length;
            for (int i = 0; i < valueCount; ++i) {
                String propValue = values[i].value;

                if (propValue == null || // Wildcard.
                    propValue.equals(value)) {
                    return values[i];
                }
            }

            return null;
        }

        public int compareTo(Prop other) {
            if (attribute == null) {
                if (other.attribute == null) {
                    return 0;
                } else {
                    return 1;
                }
            } else {
                if (other.attribute == null) {
                    return -1;
                } else {
                    return attribute.compareTo(other.attribute);
                }
            }
        }

        public String toString() {
            StringBuilder buffer = new StringBuilder();
            toString(buffer);
            return buffer.toString();
        }

        public void toString(StringBuilder buffer) {
            buffer.append("attribute=");
            if (attribute != null) {
                buffer.append(attribute);
            }
            buffer.append('\n');

            for (int i = 0; i < values.length; ++i) {
                buffer.append("  ");
                values[i].toString(buffer);
                buffer.append('\n');
            }
        }
    }

    // -----------------------------------------------------------------------

    public static enum Action {
        EXCLUDE,
        FLAG,
        INCLUDE,
        PASSTHROUGH;

        public String toString() {
            switch (this) {
            case EXCLUDE:
                return "exclude";
            case FLAG:
                return "flag";
            case INCLUDE:
                return "include";
            case PASSTHROUGH:
                return "passthrough";
            default:
                return "???";
            }
        }
    }

    public static final class PropValue implements Comparable<PropValue> {
        public final String value;
        public final Action action;
        public final Flags flags;

        public PropValue(String value, Action action, Flags flags) {
            this.value = value;
            this.action = action;
            this.flags = flags;
        }

        public int compareTo(PropValue other) {
            if (value == null) {
                if (other.value == null) {
                    return 0;
                } else {
                    return 1;
                }
            } else {
                if (other.value == null) {
                    return -1;
                } else {
                    return value.compareTo(other.value);
                }
            }
        }

        public String toString() {
            StringBuilder buffer = new StringBuilder();
            toString(buffer);
            return buffer.toString();
        }

        public void toString(StringBuilder buffer) {
            buffer.append("value=");
            if (value != null) {
                buffer.append(value);
            }

            buffer.append(" action=");
            buffer.append(action);
            if (flags != null) {
                flags.toString(buffer);
            }
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Representation of the styles used to flag an element.
     */
    public final class Flags {
        public String color;
        public String backgroundColor;
        public String fontWeight;
        public String fontStyle;
        public String textDecoration;
        public boolean changebar;
        public URL startImage;
        public boolean isAbsoluteStartImageURL;
        public String startText;
        public URL endImage;
        public boolean isAbsoluteEndImageURL;
        public String endText;

        public void set(Flags other) {
            if (other.color != null) {
                if (color != null && 
                    !color.equals(other.color) &&
                    conflictColor != null) {
                    color = conflictColor;
                } else {
                    color = other.color;
                }
            }

            if (other.backgroundColor != null) {
                if (backgroundColor != null && 
                    !backgroundColor.equals(other.backgroundColor) &&
                    conflictBackgroundColor != null) {
                    backgroundColor = conflictBackgroundColor;
                } else {
                    backgroundColor = other.backgroundColor;
                }
            }

            if (other.fontWeight != null) {
                fontWeight = other.fontWeight;
            }

            if (other.fontStyle != null) {
                fontStyle = other.fontStyle;
            }

            if (other.textDecoration != null) {
                textDecoration = other.textDecoration;
            }

            if (other.changebar) {
                changebar = true;
            }

            if (other.startImage != null) {
                startImage = other.startImage;
                isAbsoluteStartImageURL = other.isAbsoluteStartImageURL;
            }

            if (other.startText != null) {
                startText = other.startText;
            }

            if (other.endImage != null) {
                endImage = other.endImage;
                isAbsoluteEndImageURL = other.isAbsoluteEndImageURL;
            }

            if (other.endText != null) {
                endText = other.endText;
            }
        }

        public void clear() {
            color = null;
            backgroundColor = null;
            fontWeight = null;
            fontStyle = null;
            textDecoration = null;
            changebar = false;
            startImage = null;
            isAbsoluteStartImageURL = false;
            startText = null;
            endImage = null;
            isAbsoluteEndImageURL = false;
            endText = null;
        }

        public boolean isEmpty() {
            return (color == null &&
                    backgroundColor == null &&
                    fontWeight == null &&
                    fontStyle == null &&
                    textDecoration == null &&
                    !changebar &&
                    startImage == null &&
                    startText == null &&
                    endImage == null &&
                    endText == null);
        }

        public Flags copy() {
            Flags copy = new Flags();

            copy.color = color;
            copy.backgroundColor = backgroundColor;
            copy.fontWeight = fontWeight;
            copy.fontStyle = fontStyle;
            copy.textDecoration = textDecoration;
            copy.changebar = changebar;
            copy.startImage = startImage;
            copy.isAbsoluteStartImageURL = isAbsoluteStartImageURL;
            copy.startText = startText;
            copy.endImage = endImage;
            copy.isAbsoluteEndImageURL = isAbsoluteEndImageURL;
            copy.endText = endText;

            return copy;
        }

        public Element toElement(Document doc) {
            Element flags = doc.createElementNS(DITAC_NS_URI, "ditac:flags");

            if (color != null) {
                flags.setAttributeNS(null, "color", color);
            }

            if (backgroundColor != null) {
                flags.setAttributeNS(null, "background-color", 
                                     backgroundColor);
            }

            if (fontWeight != null) {
                flags.setAttributeNS(null, "font-weight", fontWeight);
            }

            if (fontStyle != null) {
                flags.setAttributeNS(null, "font-style", fontStyle);
            }

            if (textDecoration != null) {
                flags.setAttributeNS(null, "text-decoration", textDecoration);
            }

            if (changebar) {
                flags.setAttributeNS(null, "changebar", "true");
            }

            if (startImage != null) {
                flags.setAttributeNS(null, "startImage", 
                                     imagePath(startImage,
                                               isAbsoluteStartImageURL));
            }

            if (startText != null) {
                flags.setAttributeNS(null, "startText", startText);
            }

            if (endImage != null) {
                flags.setAttributeNS(null, "endImage", 
                                     imagePath(endImage,
                                               isAbsoluteEndImageURL));
            }

            if (endText != null) {
                flags.setAttributeNS(null, "endText", endText);
            }

            return flags;
        }

        private String imagePath(URL url, boolean isAbsolute) {
            String path =  null;

            if (!isAbsolute && imageHandler != null && outDir != null) {
                try {
                    path = imageHandler.handleImage(url, outDir, console);
                } catch (Throwable t) {
                    console.error(Msg.msg("cannotProcessImage",
                                          url, ThrowableUtil.reason(t)));
                }
            }

            if (path == null) {
                path = url.toExternalForm();
            }

            return path;
        }

        public String toString() {
            StringBuilder buffer = new StringBuilder();
            toString(buffer);
            return buffer.toString();
        }

        public void toString(StringBuilder buffer) {
            if (color != null) {
                buffer.append(" color=");
                buffer.append(color);
            }

            if (backgroundColor != null) {
                buffer.append(" backgroundColor=");
                buffer.append(backgroundColor);
            }

            if (fontWeight != null) {
                buffer.append(" fontWeight=");
                buffer.append(fontWeight);
            }

            if (fontStyle != null) {
                buffer.append(" fontStyle=");
                buffer.append(fontStyle);
            }

            if (textDecoration != null) {
                buffer.append(" textDecoration=");
                buffer.append(textDecoration);
            }

            if (changebar) {
                buffer.append(" changebar");
            }

            if (startImage != null) {
                buffer.append(" startImage=");
                buffer.append(startImage.toExternalForm());
                if (isAbsoluteStartImageURL) {
                    buffer.append(" (ABSOLUTE URL)");
                }
            }

            if (startText != null) {
                buffer.append(" startText=\"");
                buffer.append(startText);
                buffer.append('"');
            }

            if (endImage != null) {
                buffer.append(" endImage=");
                buffer.append(endImage.toExternalForm());
                if (isAbsoluteEndImageURL) {
                    buffer.append(" (ABSOLUTE URL)");
                }
            }

            if (endText != null) {
                buffer.append(" endText=\"");
                buffer.append(endText);
                buffer.append('"');
            }
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Name of the application-level attribute added to flagged elements.
     * 
     * @see #filterTopic
     */
    public static final String FLAGS_KEY = "DITAC_FLAGS";

    private URL url;
    private Prop[] props;
    private String conflictColor;
    private String conflictBackgroundColor;

    private ConsoleHelper console;
    private ImageHandler imageHandler;
    private File outDir;
    
    // Used when applying this filter ---
    private String[] filterAttributes;
    private boolean[] hasFlags = new boolean[1];
    private Flags flags = new Flags();

    private static final String EXCLUDE = "EXCLUDE";

    private static final String[] NAMED_COLORS = {
        "aqua", "black", "blue", "fuchsia", "gray", "green", "lime", 
        "maroon", "navy", "olive", "purple", "red", "silver", "teal", 
        "white", "yellow", "orange"
    };

    // -----------------------------------------------------------------------

    /**
     * Constructs a Filter initialized using the contents of specified DITAVAL
     * file.
     */
    public Filter(File file) 
        throws IOException {
        this(FileUtil.fileToURL(file));
    }

    /**
     * Constructs a Filter initialized using the contents of the DITAVAL file
     * having specified URL.
     */
    public Filter(URL url) 
        throws IOException {
        this(LoadDocument.load(url));
        setURL(url);
    }

    /**
     * Constructs a Filter initialized using the contents of specified DITAVAL
     * document.
     */
    public Filter(Document doc) 
        throws IOException {
        props = new Prop[0];

        Element val = doc.getDocumentElement();
        if (val.getNamespaceURI() != null || 
            !"val".equals(val.getLocalName())) {
            reportError(val, Msg.msg("notADitaval", DOMUtil.formatName(val)));
            /*NOTREACHED*/
        }

        Node child = val.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                String childName = childElement.getLocalName();
                if ("prop".equals(childName)) {
                    parseProp(childElement);
                } else if ("revprop".equals(childName)) {
                    parseRevprop(childElement);
                } else if ("style-conflict".equals(childName)) {
                    parseStyleConflict(childElement);
                } else {
                    reportError(childElement, 
                                Msg.msg("unknownElement", 
                                        DOMUtil.formatName(childElement)));
                    /*NOTREACHED*/
                }
            }

            child = child.getNextSibling();
        }

        sortProps();
    }

    public Filter(Filter other) {
        url = other.url;
        props = other.props;
        conflictColor = other.conflictColor;
        conflictBackgroundColor = other.conflictBackgroundColor;

        console = other.console;
        imageHandler = other.imageHandler;
        outDir = other.outDir;
    }

    public Filter() {
        setProps(null);
    }

    public void setProps(Prop[] props) {
        if (props == null) {
            props = new Prop[0];
        }
        this.props = props;

        sortProps();
    }

    public void addExcludeProps(String... pairs) {
        Prop[] props = getProps();

        for (int i = 0; i < pairs.length; i += 2) {
            props = ArrayUtil.append(props,
                                     newExcludeProp(pairs[i], pairs[i+1]));
        }

        setProps(props);
    }

    public static Prop newExcludeProp(String attrName, String attrValue) {
        return new Prop(attrName, 
                        new PropValue(attrValue, Action.EXCLUDE,
                                      /*flags*/ null));
    }

    private void sortProps() {
        // Sort entries: actual name or value first, then null wildcards ---

        int propCount = props.length;
        if (propCount > 1) {
            Arrays.sort(props);
        }

        for (int i = 0; i < propCount; ++i) {
            Prop prop = props[i];

            if (prop.getValueCount() > 1) {
                Arrays.sort(prop.getValues());
            }
        }
    }

    public Prop[] getProps() {
        return props;
    }

    public void setConflictColor(String conflictColor) {
        this.conflictColor = conflictColor;
    }

    public String getConflictColor() {
        return conflictColor;
    }

    public void setConflictBackgroundColor(String conflictBackgroundColor) {
        this.conflictBackgroundColor = conflictBackgroundColor;
    }

    public String getConflictBackgroundColor() {
        return conflictBackgroundColor;
    }

    public void setURL(URL url) {
        this.url = url;
    }

    /**
     * Returns the URL of the DITAVAL file used to initialize this Filter.
     * Returns <code>null</code> if unknown.
     */
    public URL getURL() {
        return url;
    }

    /**
     * Specifies the console on which messages issued during filtering are to
     * be displayed. Invoked by the {@link PreProcessor}.
     * 
     * @param c the console; may be <code>null</code>, in which case messages
     * are displayed on <code>System.err</code> and <code>System.out</code>
     */
    public void setConsole(Console c) {
        if (c == null) {
            c = new SimpleConsole();
        }
        this.console = ((c instanceof ConsoleHelper)? 
                        (ConsoleHelper) c : new ConsoleHelper(c));
    }

    /**
     * Returns the console on which messages issued during filtering are to be
     * displayed.
     * 
     * @see #setConsole
     */
    public ConsoleHelper getConsole() {
        return console;
    }

    /**
     * Specifies the ImageHandler used by the PreProcessor. Invoked by the
     * {@link PreProcessor}.
     *
     * @see #getImageHandler
     */
    public void setImageHandler(ImageHandler handler) {
        imageHandler = handler;
    }

    /**
     * Returns the ImageHandler used by the PreProcessor.
     * 
     * @see #setImageHandler
     */
    public ImageHandler getImageHandler() {
        return imageHandler;
    }

    /**
     * Specifies the output directory used by the PreProcessor. Invoked by the
     * {@link PreProcessor}.
     * 
     * @see #getOutputDirectory
     */
    public void setOutputDirectory(File dir) {
        outDir = dir;
    }

    /**
     * Returns the output directory used by the PreProcessor.
     * 
     * @see #setOutputDirectory
     */
    public File getOutputDirectory() {
        return outDir;
    }

    public String toString() {
        StringBuilder buffer = new StringBuilder();
        toString(buffer);
        return buffer.toString();
    }

    public void toString(StringBuilder buffer) {
        if (conflictColor != null) {
            buffer.append("conflictColor=");
            buffer.append(conflictColor);
            buffer.append('\n');
        }

        if (conflictBackgroundColor != null) {
            buffer.append("conflictBackgroundColor=");
            buffer.append(conflictBackgroundColor);
            buffer.append('\n');
        }

        for (int i = 0; i < props.length; ++i) {
            props[i].toString(buffer);
        }
    }

    // -----------------------------------------------------------------------
    // Parse .ditaval files
    // -----------------------------------------------------------------------

    private void parseProp(Element element) 
        throws IOException {
        // EXTENSION: Any attribute may be use to filter or flag elements.

        String attrName = element.getAttributeNS(null, "att");
        if (attrName == null || (attrName = attrName.trim()).length() == 0) {
            // Wildcard.
            attrName = null;
        } else {
            // attrName uses Clark's notation.
            attrName = expandQName(attrName, element);
        }

        doParseProp(element, attrName);
    }

    private static final String expandQName(String qName, Node context) {
        if (qName == null) {
            return null;
        }

        int pos = qName.indexOf(':');
        if (pos <= 0 || pos == qName.length()-1) {
            return qName;
        }

        String prefix = qName.substring(0, pos);
        String localPart = qName.substring(pos+1);

        String ns = null;
        if ("xml".equals(prefix)) {
            ns = "http://www.w3.org/XML/1998/namespace";
        } else {
            ns = context.lookupNamespaceURI(prefix);
        }
        if (ns == null) {
            // Unknown prefix. An XML 1.0 name?
            return qName;
        }
        
        StringBuilder buffer = new StringBuilder();
        buffer.append('{');
        buffer.append(ns);
        buffer.append('}');
        buffer.append(localPart);
        return buffer.toString();
    }

    private void parseRevprop(Element element) 
        throws IOException {
        doParseProp(element, "rev");
    }

    private void doParseProp(Element element, String attrName) 
        throws IOException {
        String attrValue = element.getAttributeNS(null, "val");
        if (attrValue == null || (attrValue=attrValue.trim()).length() == 0) {
            // Wildcard.
            attrValue = null;
        }

        String action = element.getAttributeNS(null, "action");
        if (action == null || (action = action.trim()).length() == 0) {
            reportError(element, Msg.msg("missingAttribute", "action"));
            /*NOTREACHED*/
            return;
        }

        Action propAction = null;
        Flags flags = null;

        if ("exclude".equals(action)) {
            propAction = Action.EXCLUDE;
        } else if ("include".equals(action)) {
            propAction = Action.INCLUDE;
        } else if ("passthrough".equals(action)) {
            propAction = Action.PASSTHROUGH;
        } else if ("flag".equals(action)) {
            flags = new Flags();

            flags.color = parseColor(element, "color");
            flags.backgroundColor = parseColor(element, "backcolor");

            String value = element.getAttributeNS(null, "style");
            if (value != null && (value = value.trim()).length() > 0) {
                if ("underline".equals(value) ||
                    "double-underline".equals(value)) {
                    // LIMITATION: "double-underline" treated like "underline".
                    flags.textDecoration = "underline";
                } else if ("overline".equals(value)) {
                    flags.textDecoration = "overline";
                } else if ("line-through".equals(value)) {
                    // EXTENSION: "line-through".
                    flags.textDecoration = "line-through";
                } else if ("italics".equals(value)) {
                    flags.fontStyle = "italic";
                } else if ("bold".equals(value)) {
                    flags.fontWeight = "bold";
                } else {
                    reportError(element, Msg.msg("invalidStyle", value));
                    /*NOTREACHED*/
                }
            }

            value = element.getAttributeNS(null, "changebar");
            if (value != null && (value = value.trim()).length() > 0) {
                // LIMITATION: changebar cannot be styled. 
                flags.changebar = true;
            }

            Element startflag =
                DOMUtil.getChildElementByName(element, null, "startflag");
            if (startflag != null) {
                parseStartEndFlag(startflag, /*start*/ true, flags);
            }

            Element endflag =
                DOMUtil.getChildElementByName(element, null, "endflag");
            if (endflag != null) {
                parseStartEndFlag(endflag, /*start*/ false, flags);
            }
 
            if (flags.isEmpty()) {
                flags = null;
            }

            if (flags != null) {
                propAction = Action.FLAG;
            }
        } else {
            reportError(element, Msg.msg("invalidAttribute", action, "action"));
            /*NOTREACHED*/
            return;
        }
        
        // Add to the list ---

        if (propAction == null) {
            // Nothing to do.
            return;
        }

        Prop prop = null;

        for (int i = 0; i < props.length; ++i) {
            String propAttribute = props[i].attribute;
            if ((propAttribute == null && attrName == null) ||
                (propAttribute != null && propAttribute.equals(attrName))) {
                prop = props[i];
                break;
            }
        }

        PropValue propValue = new PropValue(attrValue, propAction, flags);
        if (prop == null) {
            prop = new Prop(attrName, propValue);
            props = ArrayUtil.append(props, prop);
        } else {
            prop.addValue(propValue);
        }
    }

    private static void parseStartEndFlag(Element element, boolean isStartflag,
                                          Flags flags) 
        throws IOException {
        URL url = null;
        boolean isAbsoluteURL = false;

        String imageref = element.getAttributeNS(null, "imageref");
        if (imageref != null && (imageref = imageref.trim()).length() > 0) {
            try {
                url = Resolve.resolveURI(imageref, null);
                isAbsoluteURL = true;
            } catch (MalformedURLException ignored) {}

            if (url == null) {
                URL baseURL = null;

                String baseLocation = element.getBaseURI();
                if (baseLocation != null) {
                    try {
                        baseURL = URLUtil.createURL(baseLocation);
                    } catch (MalformedURLException ignored) {}
                }

                try {
                    url = URLUtil.createURL(baseURL, imageref);
                } catch (MalformedURLException ignored) {
                    reportError(element, Msg.msg("invalidAttribute", imageref,
                                                 "imageref"));
                    /*NOTREACHED*/
                    return;
                }
            }
        }

        // alt-text child ---

        String text = null;

        Element altText =
            DOMUtil.getChildElementByName(element, null, "alt-text");
        if (altText != null) {
            text = altText.getTextContent();
            if (text != null) {
                text = XMLText.collapseWhiteSpace(text);
                if (text.length() == 0) {
                    text = null;
                }
            }
        }

        // Update flags ---

        if (url != null || text != null) {
            if (isStartflag) {
                flags.startImage = url;
                flags.isAbsoluteStartImageURL = isAbsoluteURL;
                flags.startText = text;
            } else {
                flags.endImage = url;
                flags.isAbsoluteEndImageURL = isAbsoluteURL;
                flags.endText = text;
            }
        }
    }

    private void parseStyleConflict(Element element) 
        throws IOException {
        conflictColor = parseColor(element, "foreground-conflict-color");

        conflictBackgroundColor = 
            parseColor(element, "background-conflict-color");
    }

    private String parseColor(Element element, String attrName) 
        throws IOException {
        String value = element.getAttributeNS(null, attrName);
        if (value != null && (value = value.trim()).length() > 0) {
            if (StringList.contains(NAMED_COLORS, value) ||
                value.matches("#[0-9A-Fa-f]{6}")) {
                return value;
            }

            reportError(element, Msg.msg("invalidColor", value));
            /*NOTREACHED*/
        }

        // Not specified.
        return null;
    }

    private static void reportError(Element element, String message) 
        throws IOException {
        if (element != null) {
            NodeLocation location = 
                (NodeLocation) element.getUserData(NodeLocation.USER_DATA_KEY);
            if (location == null) {
                location = NodeLocation.UNKNOWN_LOCATION;
            }

            StringBuilder buffer = new StringBuilder();
            location.toString(buffer);
            buffer.append(": ");
            buffer.append(message);

            message = buffer.toString();
        }
        throw new IOException(message);
    }

    // -----------------------------------------------------------------------
    // Apply filter
    // -----------------------------------------------------------------------

    public void filterMap(Element map) {
        filterAttributes = DITAUtil.getFilterAttributes(map);

        filterMap1(map);
        filterMap2(map);
    }

    private void filterMap1(Element element) {
        Node child = element.getFirstChild();
        while (child != null) {
            Node next = child.getNextSibling();

            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;
                boolean filterContent = false;
                boolean removeHref = false;
                
                if (DITAUtil.hasClass(childElement, "map/topicmeta") ||
                    DITAUtil.hasClass(childElement, "topic/title")) {
                    filterContent = true;
                } else if (DITAUtil.hasClass(childElement, "map/topicref")) {
                    String href = childElement.getAttributeNS(null, "href");
                    if (href != null && href.length() > 0) {
                        removeHref = (computeAction(childElement) == EXCLUDE);
                    }
                }

                if (filterContent) {
                    doFilterTopic(childElement, /*allowFlagging*/  false);
                } else {
                    if (removeHref) {
                        childElement.removeAttributeNS(null, "href");
                    }

                    filterMap1(childElement);
                }
            }

            child = next;
        }
    }

    private void filterMap2(Element element) {
        Node child = element.getFirstChild();
        while (child != null) {
            Node next = child.getNextSibling();

            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                filterMap2(childElement);

                if (DITAUtil.hasClass(childElement, "map/topicref") &&
                    computeAction(childElement) == EXCLUDE &&
                    DITAUtil.findChildByClass(childElement, 
                                              "map/topicref") == null) {
                    assert(DITAUtil.getNonEmptyAttribute(childElement, 
                                                        null, "href") == null);
                    childElement.getParentNode().removeChild(childElement);
                }
            }

            child = next;
        }
    }

    /**
     * Apply this filter to specified topic. 
     *
     * <p>Depending on the contents of specified topic, this may cause 
     * one of the following side-effects on the topic and/or 
     * its descendant elements:
     * <ul>
     * <li>Mark the topic as excluded using 
     * <code>LoadedTopic.setExcluded(true)</code>.
     * <li>Flag the topic element by specifying a {@link Flags} object 
     * as the value  of the {@link #FLAGS_KEY} application-level attribute 
     * (W3C DOM method <code>Node.setUserData()</code> is used to add 
     * this application-level attribute to the <tt>topic</tt> element).
     * <li>Delete the descendant element.
     * <li>Wrap the descendant element into a <tt>ditac:flags</tt> 
     * element having the proper style attributes.
     * </ul>
     *
     * <p>Notes:
     * <ul>
     * <li>Assumes that all filter attributes have been properly cascaded.
     * <li> Filtering and flagging is performed using only the following 
     * attributes: <tt>@audience</tt>, <tt>@platform</tt>, <tt>@product</tt>, 
     * <tt>@otherprops</tt>, <tt>@props</tt>, specializations of <tt>@props 
     * and <tt>@rev</tt>.
     * <li><tt>@otherprops</tt> is assumed to contain simple, non-structured, 
     * strings. (This is not required by the DITA 1.2 spec.)
     * <li>Nested topics are not processed.
     * </ul>
     */
    public void filterTopic(LoadedTopic loadedTopic) {
        filterAttributes = DITAUtil.getFilterAttributes(loadedTopic.element);

        Object action = computeAction(loadedTopic.element);
        if (action == EXCLUDE) {
            loadedTopic.setExcluded(true);
        } else if (action != null) {
            Flags flags2 = ((Flags) action).copy();
            loadedTopic.element.setUserData(FLAGS_KEY, flags2, null);
        }

        // Do not assume that we will be able to actually exclude all topics
        // marked as excluded, so filter out and flag the contents of the
        // topic.
        doFilterTopic(loadedTopic.element, /*allowFlagging*/ true);
    }

    private void doFilterTopic(Element element, boolean allowFlagging) {
        Node child = element.getFirstChild();
        while (child != null) {
            Node next = child.getNextSibling();

            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, "topic/topic")) {
                    // Do not process nested topics.
                    return;
                }

                Object action = computeAction(childElement);
                if (action == null) {
                    doFilterTopic(childElement, allowFlagging);
                } else {
                    Node parent = childElement.getParentNode();
                    assert(parent != null);

                    if (action == EXCLUDE) {
                        if (DITAUtil.hasClass(childElement, "map/relcell", 
                                             "topic/entry", "topic/stentry")) {
                            // Do not remove a cell, just make it empty.
                            DOMUtil.removeChildren(childElement);
                        } else {
                            parent.removeChild(childElement);
                        }
                    } else {
                        if (allowFlagging) {
                            parent.removeChild(childElement);

                            Flags flags = (Flags) action;

                            Document doc = parent.getOwnerDocument();
                            assert(doc != null);

                            Element wrapper = flags.toElement(doc);
                            wrapper.appendChild(childElement);

                            parent.insertBefore(wrapper, next);
                        }

                        doFilterTopic(childElement, allowFlagging);
                    }
                }
            }
            
            child = next;
        }
    }

    private Object computeAction(Element element) {
        Object action = null;

        hasFlags[0] = false;
        flags.clear();

        NamedNodeMap attrs = element.getAttributes();
        int attrCount = attrs.getLength();
        
        for (int i = 0; i < attrCount; ++i) {
            Attr attr = (Attr) attrs.item(i);

            if (computeAction(DOMUtil.formatName(attr), attr.getValue(), 
                              flags, hasFlags) == EXCLUDE) {
                action = EXCLUDE;
                break;
            }
        }

        if (action == null && hasFlags[0]) {
            action = flags;
        }
        return action;
    }

    private Object computeAction(String attrName, String attrValue, 
                                 Flags flags, boolean[] hasFlags) {
        Prop prop = findProp(attrName);
        if (prop == null) {
            return null;
        }

        int excludeCount = 0;

        String[] values = XMLText.splitList(attrValue);
        int valueCount = values.length;

        for (int j = 0; j < valueCount; ++j) {
            PropValue propValue = prop.findValue(values[j]);
            if (propValue != null) {
                switch (propValue.action) {
                case EXCLUDE:
                    ++excludeCount;
                    break;
                case FLAG:
                    flags.set(propValue.flags);
                    hasFlags[0] = true;
                    break;
                }
            }
        }

        if (excludeCount == valueCount) {
            return EXCLUDE;
        }

        return null;
    }

    private Prop findProp(String attribute) {
        int propCount = props.length;
        for (int i = 0; i < propCount; ++i) {
            String propAttribute = props[i].attribute;
            if ((propAttribute == null && // Wildcard.
                 StringList.contains(filterAttributes, attribute)) || 
                propAttribute.equals(attribute)) {
                return props[i];
            }
        }

        return null;
    }

    // -----------------------------------------------------------------------

    /**
     * Simple test driver.
     */
    public static void main(String[] args) {
        File filterFile = null;
        String filterOptions = null;
        File inFile = null;
        File outFile = null;
        boolean usage = false;

        switch (args.length) {
        case 2:
            filterFile = new File(args[0]);
            outFile = new File(args[1]);
            break;
        case 4:
            filterFile = new File(args[0]);
            filterOptions = args[1];
            inFile = new File(args[2]);
            outFile = new File(args[3]);
            break;
        default:
            usage = true;
            break;
        }

        if (usage) {
            System.err.println(
                "usage: java com.xmlmind.ditac.preprocess.Filter" +
                " in_ditaval_file out_text_file" +
                " |\n    in_ditaval_file in_topic_or_map_file out_xml_file");
            System.exit(1);
        }

        try {
            Filter filter = new Filter(filterFile);

            if (inFile != null) {
                LoadedDocument loadedDoc = 
                    (new LoadedDocuments()).load(inFile);

                if (filterOptions.indexOf("new") >= 0) {
                    filter = new Filter();
                }
                if (filterOptions.indexOf("prune") >= 0) {
                    filter.addExcludeProps("processing-role", "resource-only");
                }
                if (filterOptions.indexOf("screen") >= 0) {
                    filter.addExcludeProps("print", "printonly");
                }
                if (filterOptions.indexOf("print") >= 0) {
                    filter.addExcludeProps("print", "no");
                }

                switch (loadedDoc.type) {
                case MAP:
                case BOOKMAP:
                    filter.filterMap(loadedDoc.document.getDocumentElement());
                    break;
                default:
                    filter.filterTopic(loadedDoc.getFirstTopic());
                    break;
                }

                SaveDocument.save(loadedDoc.document, outFile);
            } else {
                FileUtil.saveString(filter.toString(), outFile);
            }
        } catch (Exception e) {
            System.out.println(ThrowableUtil.reason(e));
            System.exit(2);
        }
    }
}
