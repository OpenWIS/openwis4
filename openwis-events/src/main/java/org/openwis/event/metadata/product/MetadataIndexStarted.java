/**
 *
 */
package org.openwis.event.metadata.product;

import java.util.Vector;

import org.fao.geonet.domain.Metadata;
import org.fao.geonet.events.md.MetadataEvent;
import org.jdom.Element;

/**
 * Event launched when the indexation of a metadata record is previous to start, allowing to update the fields for indexing.
 *
 * @author Jose García
 */
public class MetadataIndexStarted extends MetadataEvent {

    private static final long serialVersionUID = 5119421930299384126L;

    private  Vector<Element> indexFields;


    /**
     * @param metadata
     */
    public MetadataIndexStarted(Metadata metadata, Vector<Element> indexFields) {
        super(metadata);
        this.indexFields = indexFields;
    }


    public Vector<Element> getIndexFields() {
        return indexFields;
    }
}
