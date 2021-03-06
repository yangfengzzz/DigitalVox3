//
//  scene.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "scene.h"
#include "engine.h"
#include "camera.h"
#include "log.h"

namespace vox {
ShaderProperty Scene::_frameBufferSizeProperty = Shader::createProperty("u_framebuffer_size", ShaderDataGroup::Scene);

Scene::Scene(Engine *engine, std::string name) :
EngineObject(engine),
name(name),
_ambientLight(this),
light_manager(this) {
    auto createFrameBuffer = [&](GLFWwindow *window, int width, int height) {
        int buffer_width, buffer_height;
        glfwGetFramebufferSize(window, &buffer_width, &buffer_height);
        shaderData.setData(Scene::_frameBufferSizeProperty, Float2(buffer_width, buffer_height));
    };
    createFrameBuffer(engine->canvas()->handle(), 0, 0);
    Canvas::resize_callbacks.push_back(createFrameBuffer);
}

AmbientLight &Scene::ambientLight() {
    return _ambientLight;
}

size_t Scene::rootEntitiesCount() {
    return _rootEntities.size();
}

const std::vector<EntityPtr> &Scene::rootEntities() {
    return _rootEntities;
}

bool Scene::destroyed() {
    return _destroyed;
}

EntityPtr Scene::createRootEntity(std::string name) {
    const auto entity = std::make_shared<Entity>(_engine, name);
    addRootEntity(entity);
    return entity;
}

void Scene::addRootEntity(EntityPtr entity) {
    const auto isRoot = entity->_isRoot;
    
    // let entity become root
    if (!isRoot) {
        entity->_isRoot = true;
        entity->_removeFromParent();
    }
    
    // add or remove from scene's rootEntities
    const auto oldScene = entity->_scene;
    if (oldScene != this) {
        if (oldScene && isRoot) {
            oldScene->_removeEntity(entity);
        }
        _rootEntities.push_back(entity);
        Entity::_traverseSetOwnerScene(entity.get(), this);
    } else if (!isRoot) {
        _rootEntities.push_back(entity);
    }
    
    // process entity active/inActive
    if (_isActiveInEngine) {
        if (!entity->_isActiveInHierarchy && entity->_isActive) {
            entity->_processActive();
        }
    } else {
        if (entity->_isActiveInHierarchy) {
            entity->_processInActive();
        }
    }
}

void Scene::removeRootEntity(EntityPtr entity) {
    if (entity->_isRoot && entity->_scene == this) {
        _removeEntity(entity);
        if (_isActiveInEngine) {
            entity->_processInActive();
        }
        Entity::_traverseSetOwnerScene(entity.get(), nullptr);
    }
}

EntityPtr Scene::getRootEntity(size_t index) {
    return _rootEntities[index];
}

EntityPtr Scene::findEntityByName(const std::string &name) {
    const auto &children = _rootEntities;
    for (size_t i = 0; i < children.size(); i++) {
        const auto &child = children[i];
        if (child->name == name) {
            return child;
        }
    }
    
    for (size_t i = 0; i < children.size(); i++) {
        const auto &child = children[i];
        const auto entity = child->findByName(name);
        if (entity) {
            return entity;
        }
    }
    return nullptr;
}

void Scene::destroy() {
    if (_destroyed) {
        return;
    }
    if (_isActiveInEngine) {
        _engine->sceneManager().setActiveScene(nullptr);
    }
    for (size_t i = 0, n = rootEntitiesCount(); i < n; i++) {
        _rootEntities[i]->destroy();
    }
    _rootEntities.clear();
    _destroyed = true;
}

void Scene::_attachRenderCamera(Camera *camera) {
    auto iter = std::find(_activeCameras.begin(), _activeCameras.end(), camera);
    if (iter == _activeCameras.end()) {
        _activeCameras.push_back(camera);
    } else {
        log::Log() << "Camera already attached." << std::endl;
    }
}

void Scene::_detachRenderCamera(Camera *camera) {
    auto iter = std::find(_activeCameras.begin(), _activeCameras.end(), camera);
    if (iter != _activeCameras.end()) {
        _activeCameras.erase(iter);
    }
}

void Scene::_processActive(bool active) {
    _isActiveInEngine = active;
    const auto &rootEntities = _rootEntities;
    for (size_t i = 0; i < rootEntities.size(); i++) {
        const auto &entity = rootEntities[i];
        if (entity->_isActive) {
            active ? entity->_processActive() : entity->_processInActive();
        }
    }
}

void Scene::_updateShaderData() {
    // union scene and camera macro.
    shaderData.mergeMacro(engine()->_macroCollection, _globalShaderMacro);
    light_manager._updateShaderData(shaderData);
}

void Scene::_removeEntity(EntityPtr entity) {
    auto &oldRootEntities = _rootEntities;
    oldRootEntities.erase(std::remove(oldRootEntities.begin(),
                                      oldRootEntities.end(), entity), oldRootEntities.end());
}

}
