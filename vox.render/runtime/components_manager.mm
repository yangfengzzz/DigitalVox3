//
//  components_manager.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#include "components_manager.h"
#include "script.h"
#include "renderer.h"
#include "entity.h"
#include "camera.h"

namespace vox {
void ComponentsManager::addOnStartScript(Script* script) {
    script->_onStartIndex = _onStartScripts.size();
    _onStartScripts.push_back(script);
}

void ComponentsManager::removeOnStartScript(Script* script) {
    _onStartScripts.erase(_onStartScripts.begin() + script->_onStartIndex);
    script->_onStartIndex = -1;
}

void ComponentsManager::addOnUpdateScript(Script* script) {
    script->_onUpdateIndex = _onUpdateScripts.size();
    _onUpdateScripts.push_back(script);
}

void ComponentsManager::removeOnUpdateScript(Script* script) {
    _onUpdateScripts.erase(_onUpdateScripts.begin() + script->_onUpdateIndex);
    script->_onUpdateIndex = -1;
}

void ComponentsManager::addOnLateUpdateScript(Script* script) {
    script->_onLateUpdateIndex = _onLateUpdateScripts.size();
    _onLateUpdateScripts.push_back(script);
}

void ComponentsManager::removeOnLateUpdateScript(Script* script) {
    _onLateUpdateScripts.erase(_onLateUpdateScripts.begin() + script->_onLateUpdateIndex);
    script->_onLateUpdateIndex = -1;
}

void ComponentsManager::addDestroyComponent(Script* component) {
    _destroyComponents.push_back(component);
}

void ComponentsManager::addRenderer(Renderer* renderer) {
    renderer->_rendererIndex = _renderers.size();
    _renderers.push_back(renderer);
}

void ComponentsManager::removeRenderer(Renderer* renderer) {
    _renderers.erase(_renderers.begin() + renderer->_rendererIndex);
    renderer->_rendererIndex = -1;
}

void ComponentsManager::addOnUpdateRenderers(Renderer* renderer) {
    renderer->_onUpdateIndex = _onUpdateRenderers.size();
    _onUpdateRenderers.push_back(renderer);
}

void ComponentsManager::removeOnUpdateRenderers(Renderer* renderer) {
    _onUpdateRenderers.erase(_onUpdateRenderers.begin() + renderer->_onUpdateIndex);
    renderer->_onUpdateIndex = -1;
}

void ComponentsManager::callScriptOnStart() {
    auto& onStartScripts = _onStartScripts;
    if (onStartScripts.size() > 0) {
        // The 'onStartScripts.length' maybe add if you add some Script with addComponent() in some Script's onStart()
        for (size_t i = 0; i < onStartScripts.size(); i++) {
            const auto& script = onStartScripts[i];
            script->_started = true;
            script->_onStartIndex = -1;
            script->onStart();
        }
        onStartScripts.clear();
    }
}

void ComponentsManager::callScriptOnUpdate(float deltaTime) {
    const auto& onUpdateScripts = _onUpdateScripts;
    for (size_t i = 0; i < _onUpdateScripts.size(); i++) {
        const auto& element = onUpdateScripts[i];
        if (element->_started) {
            element->onUpdate(deltaTime);
        }
    }
}

void ComponentsManager::callScriptOnLateUpdate(float deltaTime) {
    const auto& onLateUpdateScripts = _onLateUpdateScripts;
    for (size_t i = 0; i < _onLateUpdateScripts.size(); i++) {
        const auto& element = onLateUpdateScripts[i];
        if (element->_started) {
            element->onLateUpdate(deltaTime);
        }
    }
}

void ComponentsManager::callRendererOnUpdate(float deltaTime) {
    const auto& elements = _onUpdateRenderers;
    for (size_t i = 0; i < _onUpdateRenderers.size(); i++) {
        elements[i]->update(deltaTime);
    }
}

void ComponentsManager::callRender(const RenderContext& context) {
    const auto& camera = context._camera;
    const auto& elements = _renderers;
    for (size_t i = 0; i < _renderers.size(); i++) {
        const auto& element = elements[i];
        
        // filter by camera culling mask.
        if (!(camera->cullingMask & element->_entity->layer)) {
            continue;
        }
        
        // filter by camera frustum.
        if (camera->enableFrustumCulling) {
            element->isCulled = !camera->_frustum.intersectsBox(element->bounds());
            if (element->isCulled) {
                continue;
            }
        }
        
        const auto& transform = camera->entity()->transform;
        const auto position = transform->worldPosition();
        auto center = element->bounds().getCenter();
        if (camera->isOrthographic()) {
            const auto forward = transform->worldForward();
            center = center - position;
            element->_distanceForSort = Dot(center, forward);
        } else {
            element->_distanceForSort = LengthSqr(center - position);
        }
        
        element->_updateShaderData(context);
        
        element->_render(camera);
        
        // union camera global macro and renderer macro.
        ShaderMacroCollection::unionCollection(camera->_globalShaderMacro,
                                               element->shaderData._macroCollection,
                                               element->_globalShaderMacro);
    }
}

void ComponentsManager::callComponentDestroy() {
    if (_destroyComponents.size() > 0) {
        for (size_t i = 0; i < _destroyComponents.size(); i++) {
            _destroyComponents[i]->onDestroy();
        }
        _destroyComponents.clear();
    }
}

void ComponentsManager::callCameraOnBeginRender(Camera* camera) {
    const auto& camComps = camera->entity()->_components;
    for (size_t i = 0; i < camComps.size(); i++) {
        const auto& camComp = camComps[i].get();
        auto pointer = dynamic_cast<Script*>(camComp);
        if (pointer != nullptr) {
            pointer->onBeginRender(camera);
        }
    }
}

void ComponentsManager::callCameraOnEndRender(Camera* camera) {
    const auto& camComps = camera->entity()->_components;
    for (size_t i = 0; i < camComps.size(); i++) {
        const auto& camComp = camComps[i].get();
        auto pointer = dynamic_cast<Script*>(camComp);
        if (pointer != nullptr) {
            pointer->onEndRender(camera);
        }
    }
}

std::vector<Component *> ComponentsManager::getActiveChangedTempList() {
    return _componentsContainerPool.size() ? *(_componentsContainerPool.end() - 1) : std::vector<Component *>{};
}

void ComponentsManager::putActiveChangedTempList(std::vector<Component *> &componentContainer) {
    componentContainer.clear();
    _componentsContainerPool.push_back(componentContainer);
}

}
