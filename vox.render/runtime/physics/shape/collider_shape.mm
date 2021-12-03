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
const float ColliderShape::halfSqrt = 0.70710678118655;
ColliderShape::ColliderShape():
_nativeMaterial(PhysicsManager::_nativePhysics()->createMaterial(0, 0, 0)) {
    _pose.rotation = math::Quaternion(0, 0, halfSqrt, halfSqrt);
    _pose.scale = math::Float3(1, 1, 1);
}

Collider* ColliderShape::collider() {
    return _collider;
}

void ColliderShape::setLocalPose(const math::Transform &pose) {
    _pose = pose;
    
    const auto& p = pose.translation;
    const auto& q = pose.rotation;
    _nativeShape->setLocalPose(PxTransform(PxVec3(p.x, p.y, p.z), PxQuat(q.x, q.y, q.z, q.w)));
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
    _nativeMaterial = material;
    
    std::vector<PxMaterial *> materials = {material};
    _nativeShape->setMaterials(materials.data(), 1);
}

PxMaterial* ColliderShape::material() {
    return _nativeMaterial;
}

PxFilterData ColliderShape::queryFilterData() {
    return _nativeShape->getQueryFilterData();
}

void ColliderShape::setQueryFilterData(const PxFilterData &data) {
    _nativeShape->setQueryFilterData(data);
}

uint32_t ColliderShape::uniqueID() {
    return _nativeShape->getQueryFilterData().word0;
}

bool ColliderShape::trigger() {
    return _nativeShape->getFlags().isSet(PxShapeFlag::Enum::eTRIGGER_SHAPE);
}

void ColliderShape::setTrigger(bool isTrigger) {
    _nativeShape->setFlag(PxShapeFlag::Enum::eSIMULATION_SHAPE, !isTrigger);
    _nativeShape->setFlag(PxShapeFlag::Enum::eTRIGGER_SHAPE, isTrigger);
}

bool ColliderShape::sceneQuery() {
    return _nativeShape->getFlags().isSet(PxShapeFlag::Enum::eSCENE_QUERY_SHAPE);
}

void ColliderShape::setSceneQuery(bool isQuery) {
    _nativeShape->setFlag(PxShapeFlag::Enum::eSCENE_QUERY_SHAPE, isQuery);
}

}
}
