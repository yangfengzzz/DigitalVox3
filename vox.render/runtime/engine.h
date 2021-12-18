//
//  engine.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef engine_hpp
#define engine_hpp

#include <memory>
#include "physics/physics_manager.h"
#include "components_manager.h"
#include "scene_manager.h"
#include "rhi-metal/metal_renderer.h"
#include "canvas.h"
#include "timer.h"
#include "render_pipeline/render_context.h"
#include "shader/shader_macro_collection.h"

namespace vox {
class Engine {
public:
    physics::PhysicsManager _physicsManager;
    ComponentsManager _componentsManager;
    MetalRenderer _hardwareRenderer;
    RenderContext _renderContext = RenderContext();
    
    /**
     * Create engine.
     * @param canvas - The canvas to use for rendering
     */
    Engine(Canvas* canvas);
    
    ~Engine();
    
    /**
     * The canvas to use for rendering.
     */
    Canvas* canvas();
    
    /**
     * Get the resource manager.
     */
    MetalLoaderPtr resourceLoader();
    
    /**
     * Get the scene manager.
     */
    SceneManager sceneManager();
    
    /**
     * Get the Time class.
     */
    Timer timer();
    
    /**
     * Whether the engine is paused.
     */
    bool isPaused();
    
    /**
     * The number of vertical synchronization means the number of vertical blanking for one frame.
     * @remarks 0 means that the vertical synchronization is turned off.
     */
    int vSyncCount();
    void setVSyncCount(int newValue);
    
    /**
     * Set the target frame rate you want to achieve.
     * @remarks
     * It only takes effect when vSyncCount = 0 (ie, vertical synchronization is turned off).
     * The larger the value, the higher the target frame rate, Number.POSITIVE_INFINITY represents the infinite target frame rate.
     */
    float targetFrameRate();
    void setTargetFrameRate(float newValue);
    
public:
    /**
     * Execution engine loop.
     */
    void run();
    
    /**
     * Pause the engine.
     */
    void pause();
    
    /**
     * Resume the engine.
     */
    void resume();
    
    /**
     * Update the engine loop manually. If you call engine.run(), you generally don't need to call this function.
     */
    void update();
    
protected:
    void _render(ScenePtr scene, float deltaTime);
    
    Canvas* _canvas;
    
private:
    friend class Scene;
    
    ShaderMacroCollection _macroCollection = ShaderMacroCollection();
    
    SceneManager _sceneManager = SceneManager(this);
    int _vSyncCount = 1;
    float _targetFrameRate = 60;
    Timer _timer = Timer();
    bool _isPaused = true;
    int _requestId = 0;
    int _timeoutId = 0;
    int _vSyncCounter = 1;
    float _targetFrameInterval = 1000 / 60;
};

}

#endif /* engine_hpp */
