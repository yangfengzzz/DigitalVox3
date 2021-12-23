//
//  model_mesh.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "model_mesh.h"
#include "../engine.h"
#include "../shaderlib/shader_common.h"
#include "../rhi-metal/metal_loader.h"

namespace vox {
bool ModelMesh::accessible() {
    return _accessible;
}

size_t ModelMesh::vertexCount() {
    return _vertexCount;
}

ModelMesh::ModelMesh(Engine* engine, const std::string& name):
Mesh(engine, name),
resourceLoader(engine->resourceLoader()){
}

void ModelMesh::setPositions(const std::vector<Float3>& positions) {
    if (!_accessible) {
        assert(false && "Not allowed to access data while accessible is false.");
    }
    
    auto count = positions.size();
    _positions = positions;
    _vertexChangeFlag |= ValueChanged::Position;
    
    if (_vertexCount != count) {
        _vertexCount = count;
    }
}

const std::vector<Float3>& ModelMesh::positions() {
    if (!_accessible) {
        assert(false && "Not allowed to access data while accessible is false.");
    }
    
    return _positions;
}

void ModelMesh::setNormals(const std::vector<Float3>& normals) {
    if (!_accessible) {
        assert(false && "Not allowed to access data while accessible is false.");
    }
    
    if (normals.size() != _vertexCount) {
        assert(false && "The array provided needs to be the same size as vertex count.");
    }
    
    _vertexChangeFlag |= ValueChanged::Normal;
    _normals = normals;
}

const std::vector<Float3>& ModelMesh::normals() {
    if (!_accessible) {
        assert(false && "Not allowed to access data while accessible is false.");
    }
    return _normals;
}

void ModelMesh::setColors(const std::vector<math::Color>& colors) {
    if (!_accessible) {
        assert(false && "Not allowed to access data while accessible is false.");
    }
    
    if (colors.size() != _vertexCount) {
        assert(false && "The array provided needs to be the same size as vertex count.");
    }
    
    _vertexChangeFlag |= ValueChanged::Color;
    _colors = colors;
}

const std::vector<math::Color>& ModelMesh::colors() {
    if (!_accessible) {
        assert(false && "Not allowed to access data while accessible is false.");
    }
    return _colors;
}

void ModelMesh::setTangents(const std::vector<Float4>& tangents) {
    if (!_accessible) {
        assert(false && "Not allowed to access data while accessible is false.");
    }
    
    if (tangents.size() != _vertexCount) {
        assert(false && "The array provided needs to be the same size as vertex count.");
    }
    
    _vertexChangeFlag |= ValueChanged::Tangent;
    _tangents = tangents;
}

const std::vector<Float4>& ModelMesh::tangents() {
    if (!_accessible) {
        assert(false && "Not allowed to access data while accessible is false.");
    }
    return _tangents;
}

void ModelMesh::setUVs(const std::vector<Float2>& uv, int channelIndex) {
    if (!_accessible) {
        assert(false && "Not allowed to access data while accessible is false.");
    }
    
    if (uv.size() != _vertexCount) {
        assert(false && "The array provided needs to be the same size as vertex count.");
    }
    
    switch (channelIndex) {
        case 0:
            _vertexChangeFlag |= ValueChanged::UV;
            _uv = uv;
            break;
        case 1:
            _vertexChangeFlag |= ValueChanged::UV1;
            _uv1 = uv;
            break;
        case 2:
            _vertexChangeFlag |= ValueChanged::UV2;
            _uv2 = uv;
            break;
        case 3:
            _vertexChangeFlag |= ValueChanged::UV3;
            _uv3 = uv;
            break;
        case 4:
            _vertexChangeFlag |= ValueChanged::UV4;
            _uv4 = uv;
            break;
        case 5:
            _vertexChangeFlag |= ValueChanged::UV5;
            _uv5 = uv;
            break;
        case 6:
            _vertexChangeFlag |= ValueChanged::UV6;
            _uv6 = uv;
            break;
        case 7:
            _vertexChangeFlag |= ValueChanged::UV7;
            _uv7 = uv;
            break;
        default:
            assert(false && "The index of channel needs to be in range [0 - 7].");
    }
}


const std::vector<Float2>& ModelMesh::uvs(int channelIndex) {
    if (!_accessible) {
        assert(false && "Not allowed to access data while accessible is false.");
    }
    switch (channelIndex) {
        case 0:
            return _uv;
        case 1:
            return _uv1;
        case 2:
            return _uv2;
        case 3:
            return _uv3;
        case 4:
            return _uv4;
        case 5:
            return _uv5;
        case 6:
            return _uv6;
        case 7:
            return _uv7;
        default:
            assert(false && "The index of channel needs to be in range [0 - 7].");
    }
}

void ModelMesh::setIndices(const std::vector<uint32_t>& indices) {
    if (!_accessible) {
        assert(false && "Not allowed to access data while accessible is false.");
    }
    _indices = indices;
}

const std::vector<uint32_t> ModelMesh::indices() {
    return _indices;
}

void ModelMesh::uploadData(bool noLongerAccessible) {
    if (!_accessible) {
        assert(false && "Not allowed to access data while accessible is false.");
    }
    
    _vertexDescriptor = _updateVertexDescriptor();
    _vertexChangeFlag = ValueChanged::All;
    
    auto vertexFloatCount = _elementCount * _vertexCount;
    auto vertices = std::vector<float>(vertexFloatCount);
    _updateVertices(vertices);
    
    auto newVertexBuffer = resourceLoader->buildBuffer(vertices.data(), vertexFloatCount * sizeof(float), NULL);
    _setVertexBuffer(0, MeshBuffer(newVertexBuffer, vertexFloatCount * sizeof(float), MDLMeshBufferTypeVertex));
    
    const auto indexBuffer = resourceLoader->buildBuffer(_indices.data(), _indices.size() * sizeof(uint32_t), MTLResourceStorageModeShared);
    addSubMesh(MeshBuffer(indexBuffer, _indices.size() * sizeof(uint32_t), MDLMeshBufferTypeIndex),
               MTLIndexTypeUInt32, _indices.size(), MTLPrimitiveTypeTriangle);
    
    if (noLongerAccessible) {
        _accessible = false;
        _releaseCache();
    }
}

MDLVertexDescriptor* ModelMesh::_updateVertexDescriptor() {
    auto descriptor = [[MDLVertexDescriptor alloc]init];
    descriptor.attributes[Attributes::Position] =
    [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributePosition
                                     format:MDLVertexFormatFloat3
                                     offset:0 bufferIndex:0];
    
    size_t offset = 12;
    size_t elementCount = 3;
    if (!_normals.empty()) {
        descriptor.attributes[Attributes::Normal] =
        [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeNormal
                                         format:MDLVertexFormatFloat3
                                         offset:offset bufferIndex:0];
        offset += sizeof(float) * 3;
        elementCount += 3;
    }
    if (!_colors.empty()) {
        descriptor.attributes[Attributes::Color_0] =
        [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeColor
                                         format:MDLVertexFormatFloat4
                                         offset:offset bufferIndex:0];
        offset += sizeof(float) * 4;
        elementCount += 4;
    }
    if (!_boneWeights.empty()) {
        descriptor.attributes[Attributes::Weights_0] =
        [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeJointWeights
                                         format:MDLVertexFormatFloat4
                                         offset:offset bufferIndex:0];
        offset += sizeof(float) * 4;
        elementCount += 4;
    }
    if (!_boneIndices.empty()) {
        descriptor.attributes[Attributes::Joints_0] =
        [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeJointIndices
                                         format:MDLVertexFormatShort4
                                         offset:offset bufferIndex:0];
        offset += sizeof(short) * 4;
        elementCount += 1;
    }
    if (!_tangents.empty()) {
        descriptor.attributes[Attributes::Tangent] =
        [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeTangent
                                         format:MDLVertexFormatFloat4
                                         offset:offset bufferIndex:0];
        offset += sizeof(float) * 4;
        elementCount += 4;
    }
    if (!_uv.empty()) {
        descriptor.attributes[Attributes::UV_0] =
        [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeTextureCoordinate
                                         format:MDLVertexFormatFloat2
                                         offset:offset bufferIndex:0];
        offset += sizeof(float) * 2;
        elementCount += 2;
    }
    if (!_uv1.empty()) {
        descriptor.attributes[Attributes::UV_1] =
        [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeTextureCoordinate
                                         format:MDLVertexFormatFloat2
                                         offset:offset bufferIndex:0];
        offset += sizeof(float) * 2;
        elementCount += 2;
    }
    if (!_uv2.empty()) {
        descriptor.attributes[Attributes::UV_2] =
        [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeTextureCoordinate
                                         format:MDLVertexFormatFloat2
                                         offset:offset bufferIndex:0];
        offset += sizeof(float) * 2;
        elementCount += 2;
    }
    if (!_uv3.empty()) {
        descriptor.attributes[Attributes::UV_3] =
        [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeTextureCoordinate
                                         format:MDLVertexFormatFloat2
                                         offset:offset bufferIndex:0];
        offset += sizeof(float) * 2;
        elementCount += 2;
    }
    if (!_uv4.empty()) {
        descriptor.attributes[Attributes::UV_4] =
        [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeTextureCoordinate
                                         format:MDLVertexFormatFloat2
                                         offset:offset bufferIndex:0];
        offset += sizeof(float) * 2;
        elementCount += 2;
    }
    if (!_uv5.empty()) {
        descriptor.attributes[Attributes::UV_5] =
        [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeTextureCoordinate
                                         format:MDLVertexFormatFloat2
                                         offset:offset bufferIndex:0];
        offset += sizeof(float) * 2;
        elementCount += 2;
    }
    if (!_uv6.empty()) {
        descriptor.attributes[Attributes::UV_6] =
        [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeTextureCoordinate
                                         format:MDLVertexFormatFloat2
                                         offset:offset bufferIndex:0];
        offset += sizeof(float) * 2;
        elementCount += 2;
    }
    if (!_uv7.empty()) {
        descriptor.attributes[Attributes::UV_7] =
        [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeTextureCoordinate
                                         format:MDLVertexFormatFloat2
                                         offset:offset bufferIndex:0];
        offset += sizeof(float) * 2;
        elementCount += 2;
    }
    descriptor.layouts[0] = [[MDLVertexBufferLayout alloc]initWithStride:offset];
    
    _elementCount = elementCount;
    return descriptor;
}

void ModelMesh::_updateVertices(std::vector<float>& vertices) {
    if ((_vertexChangeFlag & ValueChanged::Position) != 0) {
        for (size_t i = 0; i < _vertexCount; i++) {
            auto start = _elementCount * i;
            const auto& position = _positions[i];
            vertices[start] = position.x;
            vertices[start + 1] = position.y;
            vertices[start + 2] = position.z;
        }
    }
    
    size_t offset = 3;
    
    if (!_normals.empty()) {
        if ((_vertexChangeFlag & ValueChanged::Normal) != 0) {
            for (size_t i = 0; i < _vertexCount; i++) {
                auto start = _elementCount * i + offset;
                const auto& normal = _normals[i];
                vertices[start] = normal.x;
                vertices[start + 1] = normal.y;
                vertices[start + 2] = normal.z;
            }
        }
        offset += 3;
    }
    
    if (!_colors.empty()) {
        if ((_vertexChangeFlag & ValueChanged::Color) != 0) {
            for (size_t i = 0; i < _vertexCount; i++) {
                auto start = _elementCount * i + offset;
                const auto& color = _colors[i];
                vertices[start] = color.r;
                vertices[start + 1] = color.g;
                vertices[start + 2] = color.b;
                vertices[start + 3] = color.a;
            }
        }
        offset += 4;
    }
    
    if (!_tangents.empty()) {
        if ((_vertexChangeFlag & ValueChanged::Tangent) != 0) {
            for (size_t i = 0; i < _vertexCount; i++) {
                auto start = _elementCount * i + offset;
                const auto& tangent = _tangents[i];
                vertices[start] = tangent.x;
                vertices[start + 1] = tangent.y;
                vertices[start + 2] = tangent.z;
            }
        }
        offset += 4;
    }
    if (!_uv.empty()) {
        if ((_vertexChangeFlag & ValueChanged::UV) != 0) {
            for (size_t i = 0; i < _vertexCount; i++) {
                auto start = _elementCount * i + offset;
                const auto& uv = _uv[i];
                vertices[start] = uv.x;
                vertices[start + 1] = uv.y;
            }
        }
        offset += 2;
    }
    if (!_uv1.empty()) {
        if ((_vertexChangeFlag & ValueChanged::UV1) != 0) {
            for (size_t i = 0; i < _vertexCount; i++) {
                auto start = _elementCount * i + offset;
                const auto& uv = _uv1[i];
                vertices[start] = uv.x;
                vertices[start + 1] = uv.y;
            }
        }
        offset += 2;
    }
    if (!_uv2.empty()) {
        if ((_vertexChangeFlag & ValueChanged::UV2) != 0) {
            for (size_t i = 0; i < _vertexCount; i++) {
                auto start = _elementCount * i + offset;
                const auto& uv = _uv2[i];
                vertices[start] = uv.x;
                vertices[start + 1] = uv.y;
                
            }
        }
        offset += 2;
    }
    if (!_uv3.empty()) {
        if ((_vertexChangeFlag & ValueChanged::UV3) != 0) {
            for (size_t i = 0; i < _vertexCount; i++) {
                auto start = _elementCount * i + offset;
                const auto& uv = _uv3[i];
                vertices[start] = uv.x;
                vertices[start + 1] = uv.y;
            }
        }
        offset += 2;
    }
    if (!_uv4.empty()) {
        if ((_vertexChangeFlag & ValueChanged::UV4) != 0) {
            for (size_t i = 0; i < _vertexCount; i++) {
                auto start = _elementCount * i + offset;
                const auto& uv = _uv4[i];
                vertices[start] = uv.x;
                vertices[start + 1] = uv.y;
            }
        }
        offset += 2;
    }
    if (!_uv5 .empty()) {
        if ((_vertexChangeFlag & ValueChanged::UV5) != 0) {
            for (size_t i = 0; i < _vertexCount; i++) {
                auto start = _elementCount * i + offset;
                const auto& uv = _uv5[i];
                vertices[start] = uv.x;
                vertices[start + 1] = uv.y;
            }
        }
        offset += 2;
    }
    if (!_uv6.empty()) {
        if ((_vertexChangeFlag & ValueChanged::UV6) != 0) {
            for (size_t i = 0; i < _vertexCount; i++) {
                auto start = _elementCount * i + offset;
                const auto& uv = _uv6[i];
                vertices[start] = uv.x;
                vertices[start + 1] = uv.y;
            }
        }
        offset += 2;
    }
    if (!_uv7.empty()) {
        if ((_vertexChangeFlag & ValueChanged::UV7) != 0) {
            for (size_t i = 0; i < _vertexCount; i++) {
                auto start = _elementCount * i + offset;
                const auto& uv = _uv7[i];
                vertices[start] = uv.x;
                vertices[start + 1] = uv.y;
            }
        }
        offset += 2;
    }
    
    _vertexChangeFlag = 0;
}

void ModelMesh::_releaseCache() {
    _vertices.clear();
    _positions.clear();
    _tangents.clear();
    _normals.clear();
    _colors.clear();
    _uv.clear();
    _uv1.clear();
    _uv2.clear();
    _uv3.clear();
    _uv4.clear();
    _uv5.clear();
    _uv6.clear();
    _uv7.clear();
}

}
