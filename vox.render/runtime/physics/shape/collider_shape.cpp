//
//  collider_shape.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/2.
//

#include "collider_shape.h"
#include "../physics_manager.h"

namespace vox {
namespace physics {
ColliderShape::ColliderShape():
_material(PhysicsManager::_nativePhysics()->createMaterial(0, 0, 0)) {
    _id = PhysicsManager::_idGenerator++;
}

Collider* ColliderShape::collider() {
    return _collider;
}

void ColliderShape::setLocalPose(const math::Transform &pose) {
    _pose = pose;
    
    const auto& p = pose.translation;
    const auto& q = pose.rotation;
    _pxShape->setLocalPose(PxTransform(PxVec3(p.x, p.y, p.z), PxQuat(q.x, q.y, q.z, q.w)));
}

math::Transform ColliderShape::localPose() const {
    return _pose;
}

void ColliderShape::setPosition(const math::Float3& pos) {
    _pose.translation = pos;
    setLocalPose(_pose);
}

math::Float3 ColliderShape::position() const {
    return _pose.translation;
}

void ColliderShape::setMaterial(PxMaterial* material) {
    _material = material;
    
    std::vector<PxMaterial *> materials = {material};
    _pxShape->setMaterials(materials.data(), 1);
}

PxMaterial* ColliderShape::material() {
    return _material;
}

PxFilterData ColliderShape::queryFilterData() {
    return _pxShape->getQueryFilterData();
}

void ColliderShape::setQueryFilterData(const PxFilterData &data) {
    _pxShape->setQueryFilterData(data);
}

int ColliderShape::uniqueID() {
    return _pxShape->getQueryFilterData().word0;
}

bool ColliderShape::trigger() {
    return _pxShape->getFlags().isSet(PxShapeFlag::Enum::eTRIGGER_SHAPE);
}

void ColliderShape::setTrigger(bool isTrigger) {
    _pxShape->setFlag(PxShapeFlag::Enum::eSIMULATION_SHAPE, !isTrigger);
    _pxShape->setFlag(PxShapeFlag::Enum::eTRIGGER_SHAPE, isTrigger);
}

bool ColliderShape::sceneQuery() {
    return _pxShape->getFlags().isSet(PxShapeFlag::Enum::eSCENE_QUERY_SHAPE);
}

void ColliderShape::setSceneQuery(bool isQuery) {
    _pxShape->setFlag(PxShapeFlag::Enum::eSCENE_QUERY_SHAPE, isQuery);
}

}
}
