//
//  metal_loader.hpp
//  vox.render
//
//  Created by 杨丰 on 2021/12/18.
//

#ifndef metal_loader_hpp
#define metal_loader_hpp

#include <Metal/Metal.h>
#include <MetalKit/MetalKit.h>
#include <ModelIO/ModelIO.h>
#include <string>
#include <array>

namespace vox {
class MetalLoader {
public:
    MetalLoader(id <MTLDevice> device);
    
    id<MTLTexture> buildTexture(int width, int height, MTLPixelFormat pixelFormat,
                                MTLTextureUsage usage = MTLTextureUsageShaderRead|MTLTextureUsageRenderTarget,
                                MTLStorageMode storageMode = MTLStorageModePrivate);
    
    id<MTLTexture> buildCubeTexture(int size, MTLPixelFormat pixelFormat,
                                    MTLTextureUsage usage = MTLTextureUsageShaderRead|MTLTextureUsageRenderTarget,
                                    MTLStorageMode storageMode = MTLStorageModePrivate);
    
    id<MTLTexture> loadTexture(const std::string& path, const std::string& imageName, bool isTopLeft = true);
    
    id<MTLTexture> loadTexture(MDLTexture* texture);
    
    id<MTLTexture> loadCubeTexture(const std::string& path, const std::array<std::string, 6>& imageName, bool isTopLeft = true);
    
    id<MTLTexture> loadTextureArray(const std::string& path, const std::vector<std::string>& textureNames);
    
    id<MTLTexture> createTextureArray(const std::vector<id<MTLTexture>>& textures);
    
public:
    id<MTLTexture> createIrradianceTexture(const std::string& path,
                                           const std::array<std::string, 6>& imageName, float roughness = 0.6,
                                           bool isDebugger = false, bool isTopLeft = true);
    
    // red 9; green 9; blue 9;
    std::array<float, 27> createSphericalHarmonicsCoefficients(const std::string& path,
                                                               const std::array<std::string, 6>& imageName);
    
    id<MTLTexture> createSpecularTexture(const std::string& path,
                                         const std::array<std::string, 6>& imageName,
                                         bool isDebugger = false, bool isTopLeft = true);
    
    id<MTLTexture> createBRDFLookupTable();
    
    id<MTLTexture> createMetallicRoughnessTexture(const std::string& path, const std::string& metallic,
                                                  const std::string& roughness, bool isTopLeft = true);
    
public:
    id<MTLBuffer> buildBuffer(const void * pointer, size_t length, MTLResourceOptions options);
    
    id<MTLBuffer> buildBuffer(size_t length, MTLResourceOptions options);
    
private:
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;
    id <MTLLibrary> _library;
    MTKTextureLoader* _textureLoader;
};

}

#endif /* metal_loader_hpp */
