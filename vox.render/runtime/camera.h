//
//  camera.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/26.
//

#ifndef camera_hpp
#define camera_hpp

#include "component.h"
#include "enums/camera_clear_flags.h"
#include "enums/textureCube_face.h"
#include "layer.h"
#include "maths/bounding_frustum.h"
#include "maths/ray.h"
#include <optional>
#include "transform.h"
#include "updateFlag.h"
#include "shader/shader.h"
#include "shader/shader_data.h"
#include "render_pipeline/basic_render_pipeline.h"
#include "render_pipeline/render_context.h"

namespace vox {
using namespace math;

/**
 * Camera component, as the entrance to the three-dimensional world.
 */
class Camera : public Component {
public:
    /// Shader data.
    ShaderData shaderData = ShaderData(ShaderDataGroup::Camera);
    
    /** Rendering priority - A Camera with higher priority will be rendered on top of a camera with lower priority. */
    int priority = 0;
    
    /** Whether to enable frustum culling, it is enabled by default. */
    bool enableFrustumCulling = true;
    
    /**
     * Determining what to clear when rendering by a Camera.
     * @defaultValue `CameraClearFlags.DepthColor`
     */
    CameraClearFlags clearFlags = CameraClearFlags::DepthColor;
    
    /**
     * Culling mask - which layers the camera renders.
     * @remarks Support bit manipulation, corresponding to Entity's layer.
     */
    Layer cullingMask = Layer::Everything;
    
    /**
     * Create the Camera component.
     * @param entity - Entity
     */
    Camera(Entity* entity);
    
    /**
     * Near clip plane - the closest point to the camera when rendering occurs.
     */
    float nearClipPlane();
    
    void setNearClipPlane(float value);
    
    /**
     * Far clip plane - the furthest point to the camera when rendering occurs.
     */
    float farClipPlane();
    
    void setFarClipPlane(float value);
    
    /**
     * The camera's view angle. activating when camera use perspective projection.
     */
    float fieldOfView();
    
    void setFieldOfView(float value);
    
    /**
     * Aspect ratio. The default is automatically calculated by the viewport's aspect ratio. If it is manually set,
     * the manual value will be kept. Call resetAspectRatio() to restore it.
     */
    float aspectRatio();
    
    void setAspectRatio(float value);
    
    /**
     * Viewport, normalized expression, the upper left corner is (0, 0), and the lower right corner is (1, 1).
     * @remarks Re-assignment is required after modification to ensure that the modification takes effect.
     */
    Float4 viewport() const;
    
    void setViewport(const Float4& value);
    
    /**
     * Whether it is orthogonal, the default is false. True will use orthographic projection, false will use perspective projection.
     */
    bool isOrthographic();
    
    void setIsOrthographic(bool value);
    
    /**
     * Half the size of the camera in orthographic mode.
     */
    float orthographicSize();
    
    void setOrthographicSize(float value);
    
    /**
     * View matrix.
     */
    Matrix viewMatrix();
    
    /**
     * The projection matrix is ​​calculated by the relevant parameters of the camera by default.
     * If it is manually set, the manual value will be maintained. Call resetProjectionMatrix() to restore it.
     */
    void setProjectionMatrix(const Matrix& value);
    
    Matrix projectionMatrix();
    
    /**
     * Whether to enable HDR.
     * @todo When render pipeline modification
     */
    bool enableHDR();
    
    void setEnableHDR(bool value);
    
    /**
     * RenderTarget. After setting, it will be rendered to the renderTarget. If it is empty, it will be rendered to the main canvas.
     */
    MTLRenderPassDescriptor* renderTarget();
    
    void setRenderTarget(MTLRenderPassDescriptor* value);
    
public:
    /**
     * Restore the automatic calculation of projection matrix through fieldOfView, nearClipPlane and farClipPlane.
     */
    void resetProjectionMatrix();
    
    /**
     * Restore the automatic calculation of the aspect ratio through the viewport aspect ratio.
     */
    void resetAspectRatio();
    
    /**
     * Transform a point from world space to viewport space.
     * @param point - Point in world space
     * @return out - A point in the viewport space, X and Y are the viewport space coordinates, Z is the viewport depth, the near clipping plane is 0, the far clipping plane is 1, and W is the world unit distance from the camera
     */
    Float4 worldToViewportPoint(const Float3& point);
    
    /**
     * Transform a point from viewport space to world space.
     * @param point - Point in viewport space, X and Y are the viewport space coordinates, Z is the viewport depth. The near clipping plane is 0, and the far clipping plane is 1
     * @returns Point in world space
     */
    Float3 viewportToWorldPoint(const Float3& point);
    
    /**
     * Generate a ray by a point in viewport.
     * @param point - Point in viewport space, which is represented by normalization
     * @returns Ray
     */
    Ray viewportPointToRay(const Float2& point);
    
    /**
     * Transform the X and Y coordinates of a point from screen space to viewport space
     * @param point - Point in screen space
     * @returns Point in viewport space
     */
    Float2 screenToViewportPoint(const Float2& point);
    
    Float3 screenToViewportPoint(const Float3& point);
    
    /**
     * Transform the X and Y coordinates of a point from viewport space to screen space.
     * @param point - Point in viewport space
     * @returns Point in screen space
     */
    Float2 viewportToScreenPoint(const Float2& point);
    
    Float3 viewportToScreenPoint(const Float3& point);
    
    Float4 viewportToScreenPoint(const Float4& point);
    
    /**
     * Transform a point from world space to screen space.
     * @param point - Point in world space
     * @returns Point of screen space
     */
    Float4 worldToScreenPoint(const Float3& point);
    
    /**
     * Transform a point from screen space to world space.
     * @param point - Screen space point
     * @returns Point in world space
     */
    Float3 screenToWorldPoint(const Float3&  point);
    
    /**
     * Generate a ray by a point in screen.
     * @param point - Point in screen space, the unit is pixel
     * @returns Ray
     */
    Ray screenPointToRay(const Float2& point);
    
    /**
     * Manually call the rendering of the camera.
     * @param cubeFace - Cube rendering surface collection
     * @param mipLevel - Set mip level the data want to write, only take effect in webgl2.0
     */
    void render(std::optional<TextureCubeFace> cubeFace = std::nullopt, int mipLevel = 0);
    
public:
    void _onActive() override;
    
    void _onInActive() override;
    
    void _onDestroy() override;
    
private:
    friend class ComponentsManager;
    friend class MeshRenderer;
    
    void _projMatChange();
    
    Float3 _innerViewportToWorldPoint(const Float3& point, const Matrix& invViewProjMat);
    
    void _updateShaderData(const RenderContext& context);
    
    /**
     * The inverse matrix of view projection matrix.
     */
    Matrix invViewProjMat();
    
    /**
     * The inverse of the projection matrix.
     */
    Matrix inverseProjectionMatrix();
    
    static ShaderProperty _viewMatrixProperty;
    static ShaderProperty _projectionMatrixProperty;
    static ShaderProperty _vpMatrixProperty;
    static ShaderProperty _inverseViewMatrixProperty;
    static ShaderProperty _inverseProjectionMatrixProperty;
    static ShaderProperty _cameraPositionProperty;
    
    ShaderMacroCollection _globalShaderMacro = ShaderMacroCollection();
    BoundingFrustum _frustum = BoundingFrustum();
    BasicRenderPipeline _renderPipeline;
    
    bool _isOrthographic = false;
    bool _isProjMatSetting = false;
    float _nearClipPlane = 0.1;
    float _farClipPlane = 100;
    float _fieldOfView = 45;
    float _orthographicSize = 10;
    bool _isProjectionDirty = true;
    bool _isInvProjMatDirty = true;
    bool _isFrustumProjectDirty = true;
    std::optional<float> _customAspectRatio = std::nullopt;
    MTLRenderPassDescriptor* _renderTarget = nullptr;
    
    std::unique_ptr<UpdateFlag> _frustumViewChangeFlag;
    Transform* _transform;
    std::unique_ptr<UpdateFlag> _isViewMatrixDirty;
    std::unique_ptr<UpdateFlag> _isInvViewProjDirty;
    Matrix _projectionMatrix = Matrix();
    Matrix _viewMatrix = Matrix();
    Float4 _viewport = Float4(0, 0, 1, 1);
    Matrix _inverseProjectionMatrix = Matrix();
    Float2 _lastAspectSize = Float2();
    Matrix _invViewProjMat = Matrix();
};

}

#endif /* camera_hpp */
