//
//  physics_material.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/2.
//

#include "physics_material.h"

namespace vox {
namespace physics {
PhysicsMaterial::PhysicsMaterial(PxMaterial* material):
material(material) {
}

void PhysicsMaterial::setDynamicFriction(float coef) {
    material->setDynamicFriction(coef);
}

float PhysicsMaterial::dynamicFriction() const {
    return material->getDynamicFriction();
}

void PhysicsMaterial::setStaticFriction(float coef) {
    material->setStaticFriction(coef);
}

float PhysicsMaterial::staticFriction() const {
    return material->getStaticFriction();
}

void PhysicsMaterial::setRestitution(float rest) {
    material->setRestitution(rest);
}

float PhysicsMaterial::restitution() const {
    return material->getRestitution();
}

void PhysicsMaterial::setFlag(PxMaterialFlag::Enum flag, bool b) {
    material->setFlag(flag, b);
}

void PhysicsMaterial::setFlags(PxMaterialFlags flags) {
    material->setFlags(flags);
}

PxMaterialFlags PhysicsMaterial::flags() const {
    return material->getFlags();
}

void PhysicsMaterial::setFrictionCombineMode(PxCombineMode::Enum combMode) {
    material->setFrictionCombineMode(combMode);
}

PxCombineMode::Enum PhysicsMaterial::frictionCombineMode() const {
    return material->getFrictionCombineMode();
}

void PhysicsMaterial::setRestitutionCombineMode(PxCombineMode::Enum combMode) {
    material->setRestitutionCombineMode(combMode);
}

PxCombineMode::Enum PhysicsMaterial::restitutionCombineMode() const {
    return material->getRestitutionCombineMode();
}

}
}
