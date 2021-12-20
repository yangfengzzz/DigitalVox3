//
//  render_pipeline_state.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#ifndef render_pipeline_state_hpp
#define render_pipeline_state_hpp

#import <Metal/Metal.h>
#include "../vox_type.h"
#include "../shader/shader_uniform.h"
#include "../shader/shader_data.h"
#include <iomanip>
#include <type_traits>
#include <typeindex>
#include <typeinfo>
#include <unordered_map>
#include <iostream>

namespace vox {
/**
 * Shader program, corresponding to the GPU shader program.
 */
class RenderPipelineState {
public:
    std::vector<ShaderUniform> sceneUniformBlock{};
    std::vector<ShaderUniform> cameraUniformBlock{};
    std::vector<ShaderUniform> rendererUniformBlock{};
    std::vector<ShaderUniform> materialUniformBlock{};
    std::vector<ShaderUniform> otherUniformBlock{};
    
    RenderPipelineState(MetalRenderer* _render, MTLRenderPipelineDescriptor* descriptor);
    
    id <MTLRenderPipelineState> handle() {
        return _handle;
    }
    
public:
    /**
     * Grouping other data.
     */
    void groupingOtherUniformBlock();
    
    /**
     * Upload all shader data in shader uniform block.
     * @param uniformBlock - shader Uniform block
     * @param shaderData - shader data
     */
    void uploadAll(const std::vector<ShaderUniform>& uniformBlock, const ShaderData& shaderData);
    
    /**
     * Upload constant shader data in shader uniform block.
     * @param uniformBlock - shader Uniform block
     * @param shaderData - shader data
     */
    void uploadUniforms(const std::vector<ShaderUniform>& uniformBlock, const ShaderData& shaderData);
    
    template<class T, class F>
    static inline void register_vertex_uploader(F const& f) {
        std::cout << "Register uploader for type "
        << std::quoted(typeid(T).name()) << '\n';
        vertex_any_uploader.insert(to_any_uploader<T>(f));
    }
    
    template<class T, class F>
    static inline void register_fragment_uploader(F const& f) {
        std::cout << "Register uploader for type "
        << std::quoted(typeid(T).name()) << '\n';
        fragment_any_uploader.insert(to_any_uploader<T>(f));
    }
    
private:
    template<class T, class F>
    static inline std::pair<const std::type_index, std::function<void(std::any const&, size_t, id <MTLRenderCommandEncoder>)>>
    to_any_uploader(F const &f) {
        return {
            std::type_index(typeid(T)),
            [g = f](std::any const &a, size_t location, id <MTLRenderCommandEncoder> encoder)
            {
                if constexpr (std::is_void_v<T>)
                    g();
                else
                    g(std::any_cast<T const&>(a), location, encoder);
            }
        };
    }
    
    static std::unordered_map<
    std::type_index, std::function<void(std::any const&, size_t, id <MTLRenderCommandEncoder>)>>
    vertex_any_uploader;
    
    static std::unordered_map<
    std::type_index, std::function<void(std::any const&, size_t, id <MTLRenderCommandEncoder>)>>
    fragment_any_uploader;
    
    void process(const ShaderUniform& uniform, const std::any& a, id <MTLRenderCommandEncoder> encoder);
    
private:
    /**
     * record the location of uniform/attribute.
     */
    void _recordVertexLocation(MTLRenderPipelineReflection* reflection);
    
    void _groupingUniform(const ShaderUniform& uniform,
                          const std::optional<ShaderDataGroup::Enum>& group);
    
    void _groupingSubOtherUniforms(std::vector<ShaderUniform>& uniforms);
    
    MetalRenderer *_render;
    id <MTLRenderPipelineState> _handle;
};

}

#endif /* render_pipeline_state_hpp */
