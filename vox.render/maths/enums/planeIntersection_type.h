//
//  planeIntersection_type.h
//  DigitalVox3
//
//  Created by 杨丰 on 2021/11/25.
//

#ifndef planeIntersection_type_h
#define planeIntersection_type_h

/**
 * Defines the intersection between a plane and a bounding volume.
 */
enum PlaneIntersectionType {
    /** There is no intersection, the bounding volume is in the back of the plane. */
    Back,
    /** There is no intersection, the bounding volume is in the front of the plane. */
    Front,
    /** The plane is intersected. */
    Intersecting
};

#endif /* planeIntersection_type_h */
