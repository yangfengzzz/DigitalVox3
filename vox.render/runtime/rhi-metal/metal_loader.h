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
    
    id<MTLTexture> loadTexture(const std::string& path, const std::string& imageName, bool isTopLeft = true);
    
    id<MTLTexture> loadTexture(MDLTexture* texture);
    
    id<MTLTexture> loadCubeTexture(const std::string& path, const std::string& imageName, bool isTopLeft);
    
    id<MTLTexture> loadTextureArray(const std::string& path, const std::vector<std::string>& textureNames);
    
    id<MTLTexture> createIrradianceTexture(const std::string& path,
                                           const std::array<std::string, 6>& imageName, bool isTopLeft = true);
    
public:
    id<MTLBuffer> buildBuffer(const void * pointer, size_t length, MTLResourceOptions options);

    id<MTLBuffer> buildBuffer(size_t length, MTLResourceOptions options);
    
private:
    id <MTLDevice> device;
    id <MTLCommandQueue> commandQueue;
    MTKTextureLoader* textureLoader;
};

}

#endif /* metal_loader_hpp */
