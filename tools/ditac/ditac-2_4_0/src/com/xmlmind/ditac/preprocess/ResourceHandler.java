/*
 * Copyright (c) 2009-2013 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.io.File;
import java.net.URL;
import com.xmlmind.util.Console;

/**
 * A {@link PreProcessor} invokes the same ResourceHandler to process all the
 * resources (that is, image, audio, video) contained in all the documents 
 * being preprocessed. However, a ResourceHandler is invoked only 
 * for resources having an URL which is relative to the document 
 * being preprocessed, not for resource having an absolute URL.
 * <p>A basic ResourceHandler copies its resource argument to a directory 
 * which is part of the deliverable. A more sophisticated ResourceHandler 
 * may convert its resource argument to a different format (example: convert 
 * a <tt>.svg</tt> image to <tt>.png</tt>).
 */
public interface ResourceHandler {
    /**
     * Specifies the media, print or screen, associated to the output format.
     *
     * @see #getMedia
     */
    void setMedia(Media media);

    /**
     * Returns the media, print or screen, associated to the output format.
     * Initial value: {@link Media#SCREEN}.
     *
     * @see #setMedia
     */
    Media getMedia();

    /**
     * Parses specified parameter string.
     * 
     * @param parameters parameter string having a syntax which is specific to
     * this ResourceHandler
     * @exception Exception If for any reason this operation fails
     */
    void parseParameters(String parameters)
        throws Exception;

    /**
     * Reset the internal state of this ResourceHandler. Invoked by the
     * PreProcessor before a run. Allows the PreProcessor to reuse the same
     * ResourceHandler to process several documents.
     */
    void reset()
        throws Exception;

    /**
     * Process specified resource.
     * 
     * @param resourceURL The URL of the resource to be processed
     * @param resourceType The MIME type of the resource; 
     * <code>null</code> if unknown
     * @param isImage <code>true</code> if the resource is for sure 
     * an image file
     * @param outDir The directory where the input resource, as is or modified,
     * is to be copied
     * @param console Console on which progress, trace, debug, etc, message
     * can be displayed. May be <code>null</code>.
     * @return The properly escaped, relative to <tt>outDir</tt>, URL of the
     * processed resource.
     * <p>Return <code>null</code> if default processing is to take place. The
     * default processing does nothing at all and returns
     * <code>resourceURL.toExternalForm()</code>. 
     * This means that the deliverable will point to the resources referenced 
     * in the source document.
     * @exception Exception if, for any reason, this operation fails
     */
    String handleResource(URL resourceURL, String resourceType, boolean isImage,
                          File outDir, Console console)
        throws Exception;
}
