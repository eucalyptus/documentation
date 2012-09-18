/*
 * Copyright (c) 2009-2010 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.URIComponent;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.Console;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;

/*package*/ final class MaprefIncluder extends Includer {
    private static final class MaprefIncl extends Incl {
        public final URL targetURL;
        public final String targetId;

        public MaprefIncl(Element directiveElement, URL url) {
            super(directiveElement);
            
            targetId = URLUtil.getFragment(url);
            if (targetId != null) {
                targetURL = URLUtil.setFragment(url, null);
            } else {
                targetURL = url;
            }
        }

        public String getMaprefHref() {
            if (targetId != null) {
                StringBuilder buffer =
                    new StringBuilder(targetURL.toExternalForm());
                buffer.append('#');
                buffer.append(URIComponent.quoteFragment(targetId));
                return buffer.toString();
            } else {
                return targetURL.toExternalForm();
            }
        }
    }

    // -----------------------------------------------------------------------

    public MaprefIncluder() {
        this(null, null);
    }

    public MaprefIncluder(Keys keys, Console c) {
        super(keys, c);
    }

    protected Incl detectInclusion(Element element) {
        // The map containing the referencing topicref is assumed to have been
        // processed using CascadeMeta.processMap. No need to lookup
        // attributes.

        if (!DITAUtil.hasClass(element, "map/topicref")) {
            return null;
        }

        String href =  DITAUtil.getNonEmptyAttribute(element, null, "href");
        if (href == null) {
            return null;
        }

        String scope = DITAUtil.getNonEmptyAttribute(element, null, "scope");
        if (scope != null && !"local".equals(scope)) {
            return null;
        }

        String format = DITAUtil.getFormat(element, href);
        if (format == null) {
            console.warning(element,
                            Msg.msg(Msg.msg("missingAttribute", "format")));
        }
        if (format == null || !"ditamap".equals(format)) {
            return null;
        }

        // Note that maprefs having processing-role="resource-only" are
        // included too.

        URL url = null;
        try {
            url = URLUtil.createURL(href);
        } catch (MalformedURLException ignored) {
            console.warning(element,
                            Msg.msg("invalidAttribute", href, "href"));
        }

        if (url != null) {
            return new MaprefIncl(element, url);
        }

        return null;
    }

    protected void fetchIncluded(Incl incl)
        throws IOException, InclusionException {
        MaprefIncl maprefIncl = (MaprefIncl) incl;

        Doc targetDoc = fetchDoc(maprefIncl.targetURL);

        Element rootElement = targetDoc.document.getDocumentElement();
        if (!DITAUtil.hasClass(rootElement, "map/map")) {
            throw new InclusionException(Msg.msg("notAMap", 
                                                 maprefIncl.targetURL));
        }

        Element target = null;
        if (maprefIncl.targetId != null) {
            // Branch or the whole map (e.g. href="foo.ditamap#foo").
            target = DITAUtil.findElementById(targetDoc.document, 
                                              maprefIncl.targetId);
        } else {
            // Whole map.
            target = rootElement;
        }

        if (target == null) {
            throw new InclusionException(
              Msg.msg("targetNotFound", maprefIncl.getMaprefHref(), "href"));
        }

        copyTarget(target, maprefIncl);
    }

    private static void copyTarget(Element mapOrTopicref, MaprefIncl incl) {
        // The referenced map or branch is assumed to have been processed
        // using CascadeMeta.processMap. Therefore the referenced topicrefs
        // have their proper, local, xml:lang, dir, etc.

        Element directiveElement = incl.directiveElement;
        Document doc = directiveElement.getOwnerDocument();

        if (DITAUtil.hasClass(mapOrTopicref, "map/map")) {
            // Copy map contents ---

            ArrayList<Node> replacement = new ArrayList<Node>();
            ArrayList<Node> appended = new ArrayList<Node>();

            Node child = mapOrTopicref.getFirstChild();
            while (child != null) {
                if (child.getNodeType() == Node.ELEMENT_NODE) {
                    Element childElement = (Element) child;

                    if (DITAUtil.hasClass(childElement, "map/topicref")) {
                        replacement.add(copyTopicrefAs(childElement,
                                                       directiveElement, doc));
                    } else if (DITAUtil.hasClass(childElement, 
                                                 "map/reltable")) {
                        appended.add((Element) doc.importNode(childElement, 
                                                              /*deep*/ true));
                    }
                }

                child = child.getNextSibling();
            }

            int count = replacement.size();
            if (count > 0) {
                incl.replacementNodes = new Node[count];
                replacement.toArray(incl.replacementNodes);
            }

            count = appended.size();
            if (count > 0) {
                incl.appendedNodes = new Node[count];
                appended.toArray(incl.appendedNodes);
            }
        } else {
            // Copy branch ---

            incl.replacementNodes = new Node[] {
                copyTopicrefAs(mapOrTopicref, directiveElement, doc)
            };
        }

        if (incl.replacementNodes != null) {
            CascadeMeta.processMapref(directiveElement, incl.replacementNodes);
        }

        if (incl.appendedNodes != null) {
            CascadeMeta.processMapref(directiveElement, incl.appendedNodes);
        }
    }

    private static Element copyTopicrefAs(Element source, Element template, 
                                          Document doc) {
        String cls = template.getAttributeNS(null, "class");
        if (cls != null && cls.length() > 0 && 
            cls.indexOf("mapgroup-d/") < 0) {
            // Example:
            // <chapter href="foo.ditamap#bar"/>
            // where:
            // <topicref id="bar" href="bar.dita"/>
            // is copied as a chapter and not as a topicref.

            Element copy = doc.createElementNS(template.getNamespaceURI(), 
                                               template.getLocalName());

            copyUserData(source, copy);

            DOMUtil.copyAllAttributes(source, copy);
            copy.setAttributeNS(null, "class", cls);

            DOMUtil.copyChildren(source, copy, doc);

            return copy;
        } else {
            // Example:
            // <mapref href="foo.ditamap"/>
            // (The class of a mapref is "+ map/topicref mapgroup-d/mapref ".)

            return (Element) doc.importNode(source, /*deep*/ true);
        }
    }

    // -----------------------------------------------------------------------

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println(
                "usage: java com.xmlmind.ditac.preprocess.MaprefIncluder" +
                " in_ditamap_file out_flat_ditamap_file");
            System.exit(1);
        }
        java.io.File inFile = new java.io.File(args[0]);
        java.io.File outFile = new java.io.File(args[1]);

        LoadedDocument loadedDoc = 
            (new LoadedDocuments()).load(inFile.toURI().toURL());

        com.xmlmind.ditac.util.SimpleConsole console = 
            new com.xmlmind.ditac.util.SimpleConsole(null, false, 
                                                    Console.MessageType.ERROR);
        MaprefIncluder includer = new MaprefIncluder(null, console);
        boolean done = includer.process(loadedDoc);

        com.xmlmind.ditac.util.SaveDocument.save(loadedDoc.document, outFile);
        System.exit(done? 0 : 2);
    }
}

