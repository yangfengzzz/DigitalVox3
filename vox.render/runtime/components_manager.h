//
//  components_manager.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef components_manager_hpp
#define components_manager_hpp

#include <vector>
#include "component.h"
#include "render_pipeline/render_context.h"
#include "maths/bounding_frustum.h"

namespace vox {
/**
 * The manager of the components.
 */
class ComponentsManager {
public:
    void addOnStartScript(Script* script);
    
    void removeOnStartScript(Script* script);
    
    void addOnUpdateScript(Script* script);
    
    void removeOnUpdateScript(Script* script);
    
    void addOnLateUpdateScript(Script* script);
    
    void removeOnLateUpdateScript(Script* script);
    
    void addOnEndFrameScript(Script* script);
    
    void removeOnEndFrameScript(Script* script);
    
    void addDestroyComponent(Script* component);
    
public:
    void addRenderer(Renderer* renderer);
    
    void removeRenderer(Renderer* renderer);
    
    void addOnUpdateRenderers(Renderer* renderer);
    
    void removeOnUpdateRenderers(Renderer* renderer);
    
public:
    void addOnUpdateAnimators(Animator* animator);
    
    void removeOnUpdateAnimators(Animator* animator);
    
    void addOnUpdateSceneAnimators(SceneAnimator* animator);
    
    void removeOnUpdateSceneAnimators(SceneAnimator* animator);
    
public:
    void callScriptOnStart();
    
    void callScriptOnUpdate(float deltaTime);
    
    void callScriptOnLateUpdate(float deltaTime);
    
    void callScriptOnEndFrame();
    
    void callRendererOnUpdate(float deltaTime);
    
    void callAnimatorUpdate(float deltaTime);
    
    void callSceneAnimatorUpdate(float deltaTime);
    
    void callComponentDestroy();
    
    void callCameraOnBeginRender(Camera* camera);
    
    void callCameraOnEndRender(Camera* camera);
    
public:
    void callRender(RenderContext& context,
                    std::vector<RenderElement>& opaqueQueue,
                    std::vector<RenderElement>& alphaTestQueue,
                    std::vector<RenderElement>& transparentQueue);
    
    void callRender(const BoundingFrustum& frustrum,
                    std::vector<RenderElement>& opaqueQueue,
                    std::vector<RenderElement>& alphaTestQueue,
                    std::vector<RenderElement>& transparentQueue);
    
public:
    std::vector<Component *> getActiveChangedTempList();
    
    void putActiveChangedTempList(std::vector<Component *> &componentContainer);
    
private:
    // Script
    std::vector<Script *> _onStartScripts;
    std::vector<Script *> _onUpdateScripts;
    std::vector<Script *> _onLateUpdateScripts;
    std::vector<Script *> _onEndFrameScripts;
    std::vector<Script *> _destroyComponents;
    
    // Animatior
    std::vector<Animator*> _onUpdateAnimators;
    std::vector<SceneAnimator*> _onUpdateSceneAnimators;
    
    // Render
    std::vector<Renderer*> _renderers;
    std::vector<Renderer*> _onUpdateRenderers;
    
    // Delay dispose active/inActive Pool
    std::vector<std::vector<Component *>> _componentsContainerPool;
};

}

#endif /* components_manager_hpp */
