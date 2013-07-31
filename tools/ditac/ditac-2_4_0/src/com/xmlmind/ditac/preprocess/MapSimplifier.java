/*
 * Copyright (c) 2010-2011 Pixware SARL. All rights reserved.
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
import java.util.Iterator;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.ThrowableUtil;
import com.xmlmind.util.ArrayUtil;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.Console;
import com.xmlmind.ditac.util.SimpleConsole;
import com.xmlmind.ditac.util.ConsoleHelper;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;

/*package*/ final class MapSimplifier {
    private Keys keys;
    private ConsoleHelper console;

    // -----------------------------------------------------------------------

    public MapSimplifier(Keys keys, Console console) {
        setKeys(keys);
        setConsole(console);
    }

    public void setKeys(Keys keys) {
        this.keys = keys;
    }

    public Keys getKeys() {
        return keys;
    }

    public void setConsole(Console c) {
        if (c == null) {
            c = new SimpleConsole();
        }
        this.console = ((c instanceof ConsoleHelper)? 
                        (ConsoleHelper) c : new ConsoleHelper(c));
    }

    public ConsoleHelper getConsole() {
        return console;
    }

    public boolean simplify(Document mapDoc, URL mapURL) 
        throws IOException {
        console.info(Msg.msg("simplifyingMap", URLUtil.toLabel(mapURL)));

        Element map = mapDoc.getDocumentElement();
        assert(DITAUtil.hasClass(map, "map/map"));

        // Load all maps ---

        // Note that mapDoc has already been loaded and *processed* by another
        // instance of LoadedDocuments.

        LoadedDocuments loadedDocs = new LoadedDocuments(keys, console);
        loadedDocs.put(mapURL, mapDoc, /*process*/ false);

        if (!loadAllMaps(map, loadedDocs)) {
            return false;
        }

        LoadedDocument[] loadedMaps = new LoadedDocument[loadedDocs.size()];
        int j = 0;

        Iterator<LoadedDocument> iter = loadedDocs.iterator();
        while (iter.hasNext()) {
            LoadedDocument loadedDoc = iter.next();

            switch (loadedDoc.type) {
            case MAP:
            case BOOKMAP:
                loadedMaps[j++] = loadedDoc;
                break;
            }
        }

        if (j != loadedMaps.length) {
            loadedMaps = ArrayUtil.trimToSize(loadedMaps, j);
        }

        // Conref-push all maps ---

        console.verbose(Msg.msg("pushingMapContent"));

        (new ConrefPusher(console)).process(loadedMaps);

        // Conref-transclude all maps ---

        console.verbose(Msg.msg("pullingMapContent"));

        if (!(new ConrefIncluder(keys, console)).process(loadedMaps)) {
            return false;
        }

        // Cascade attributes and metadata in all maps ---

        console.verbose(Msg.msg("cascadingMapMeta"));

        for (LoadedDocument loadedMap : loadedMaps) {
            CascadeMeta.processMap(loadedMap.document.getDocumentElement());
        }

        // Mapref-tranclude all maps ---

        console.verbose(Msg.msg("includingSubmaps"));

        if (!(new MaprefIncluder(keys, console)).process(loadedMaps)) {
            return false;
        }

        return true;
    }

    private boolean loadAllMaps(Element element, LoadedDocuments loadedDocs) {
        Node child = element.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, "map/topicref")) {
                    URL url = getLocalMapURL(childElement);
                    if (url != null) {
                        if (url.getRef() != null) {
                            url = URLUtil.setFragment(url, null);
                        }

                        LoadedDocument loadedDoc = loadedDocs.get(url);
                        if (loadedDoc == null) {
                            try {
                                loadedDoc = loadedDocs.load(url);
                            } catch (Exception e) {
                                console.error(childElement, 
                                              Msg.msg("cannotLoad", url, 
                                                      ThrowableUtil.reason(e)));
                                return false;
                            }

                            switch (loadedDoc.type) {
                            case MAP:
                            case BOOKMAP:
                                loadAllMaps(
                                    loadedDoc.document.getDocumentElement(),
                                    loadedDocs);
                                break;
                            }
                        }
                    }
                }

                if (!loadAllMaps(childElement, loadedDocs)) {
                    return false;
                }
            }

            child = child.getNextSibling();
        }

        return true;
    }

    private URL getLocalMapURL(Element topicref) {
        String href = DITAUtil.getNonEmptyAttribute(topicref, null, "href");
        if (href == null) {
            return null;
        }

        String scope = DITAUtil.inheritAttribute(topicref, null, "scope");
        if (scope != null && !"local".equals(scope)) {
            return null;
        }

        String format = DITAUtil.inheritFormat(topicref, href);
        if (format == null) {
            console.warning(topicref, 
                            Msg.msg("missingAttribute", "format"));
            return null;
        }
        if (!"ditamap".equals(format)) {
            return null;
        }

        // Remember that LoadedDocuments automatically resolves relative URLs.
        URL url = null;
        try {
            url = URLUtil.createURL(href);
        } catch (MalformedURLException ignored) {
            console.warning(topicref, 
                            Msg.msg("invalidAttribute", href, "href"));
            return null;
        }

        return url;
    }
}
