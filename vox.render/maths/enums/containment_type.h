//
//  containment_type.h
//  DigitalVox3
//
//  Created by 杨丰 on 2021/11/25.
//

#ifndef containment_type_h
#define containment_type_h

/**
 * Defines how the bounding volumes intersects or contain one another.
 */
enum ContainmentType {
    /** Indicates that there is no overlap between two bounding volumes. */
    Disjoint,
    /** Indicates that one bounding volume completely contains another volume. */
    Contains,
    /** Indicates that bounding volumes partially overlap one another. */
    Intersects
};

#endif /* containment_type_h */
