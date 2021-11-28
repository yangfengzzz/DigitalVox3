//
//  primitive_mesh.cpp
//  vox.render
//
//  Created by 杨丰 on 2021/11/27.
//

#include "primitive_mesh.h"
#include "../engine.h"

namespace vox {
ModelMeshPtr PrimitiveMesh::createSphere(const EnginePtr &engine,
                                         float radius,
                                         size_t segments,
                                         bool noLongerAccessible) {
    auto mesh = std::make_shared<ModelMesh>(engine);
    segments = std::max(size_t(2), segments);
    
    const auto count = segments + 1;
    const auto vertexCount = count * count;
    const auto rectangleCount = segments * segments;
    auto indices = std::vector<uint32_t>(rectangleCount * 6);
    const auto thetaRange = M_PI;
    const auto alphaRange = thetaRange * 2;
    const auto countReciprocal = 1.0 / count;
    const auto segmentsReciprocal = 1.0 / segments;
    
    auto positions = std::vector<Float3>(vertexCount);
    auto normals = std::vector<Float3>(vertexCount);
    auto uvs = std::vector<Float2>(vertexCount);
    
    for (size_t i = 0; i < vertexCount; ++i) {
        const auto x = i % count;
        const auto y = size_t(float(i) * countReciprocal) | 0;
        const auto u = x * segmentsReciprocal;
        const auto v = y * segmentsReciprocal;
        const auto alphaDelta = u * alphaRange;
        const auto thetaDelta = v * thetaRange;
        const auto sinTheta = std::sin(thetaDelta);
        
        const auto posX = -radius * std::cos(alphaDelta) * sinTheta;
        const auto posY = radius * std::cos(thetaDelta);
        const auto posZ = radius * std::sin(alphaDelta) * sinTheta;
        
        // Position
        positions[i] = Float3(posX, posY, posZ);
        // Normal
        normals[i] = Float3(posX, posY, posZ);
        // Texcoord
        uvs[i] = Float2(u, v);
    }
    
    size_t offset = 0;
    for (size_t i = 0; i < rectangleCount; ++i) {
        const auto x = i % segments;
        const auto y = size_t(float(i) * segmentsReciprocal) | 0;
        
        const auto a = y * count + x;
        const auto b = a + 1;
        const auto c = a + count;
        const auto d = c + 1;
        
        indices[offset++] = static_cast<uint32_t>(b);
        indices[offset++] = static_cast<uint32_t>(a);
        indices[offset++] = static_cast<uint32_t>(d);
        indices[offset++] = static_cast<uint32_t>(a);
        indices[offset++] = static_cast<uint32_t>(c);
        indices[offset++] = static_cast<uint32_t>(d);
    }
    
    auto &bounds = mesh->bounds;
    bounds.min = Float3(-radius, -radius, -radius);
    bounds.max = Float3(radius, radius, radius);
    
    PrimitiveMesh::_initialize(engine, mesh, positions, normals, uvs, indices, noLongerAccessible);
    return mesh;
    
}

ModelMeshPtr PrimitiveMesh::createCuboid(const EnginePtr &engine,
                                         float width,
                                         float height,
                                         float depth,
                                         bool noLongerAccessible) {
    auto mesh = std::make_shared<ModelMesh>(engine);
    
    const auto halfWidth = width / 2;
    const auto halfHeight = height / 2;
    const auto halfDepth = depth / 2;
    
    auto positions = std::vector<Float3>(24);
    auto normals = std::vector<Float3>(24);
    auto uvs = std::vector<Float2>(24);
    
    // Up
    positions[0] = Float3(-halfWidth, halfHeight, -halfDepth);
    positions[1] = Float3(halfWidth, halfHeight, -halfDepth);
    positions[2] = Float3(halfWidth, halfHeight, halfDepth);
    positions[3] = Float3(-halfWidth, halfHeight, halfDepth);
    normals[0] = Float3(0, 1, 0);
    normals[1] = Float3(0, 1, 0);
    normals[2] = Float3(0, 1, 0);
    normals[3] = Float3(0, 1, 0);
    uvs[0] = Float2(0, 0);
    uvs[1] = Float2(1, 0);
    uvs[2] = Float2(1, 1);
    uvs[3] = Float2(0, 1);
    // Down
    positions[4] = Float3(-halfWidth, -halfHeight, -halfDepth);
    positions[5] = Float3(halfWidth, -halfHeight, -halfDepth);
    positions[6] = Float3(halfWidth, -halfHeight, halfDepth);
    positions[7] = Float3(-halfWidth, -halfHeight, halfDepth);
    normals[4] = Float3(0, -1, 0);
    normals[5] = Float3(0, -1, 0);
    normals[6] = Float3(0, -1, 0);
    normals[7] = Float3(0, -1, 0);
    uvs[4] = Float2(0, 1);
    uvs[5] = Float2(1, 1);
    uvs[6] = Float2(1, 0);
    uvs[7] = Float2(0, 0);
    // Left
    positions[8] = Float3(-halfWidth, halfHeight, -halfDepth);
    positions[9] = Float3(-halfWidth, halfHeight, halfDepth);
    positions[10] = Float3(-halfWidth, -halfHeight, halfDepth);
    positions[11] = Float3(-halfWidth, -halfHeight, -halfDepth);
    normals[8] = Float3(-1, 0, 0);
    normals[9] = Float3(-1, 0, 0);
    normals[10] = Float3(-1, 0, 0);
    normals[11] = Float3(-1, 0, 0);
    uvs[8] = Float2(0, 0);
    uvs[9] = Float2(1, 0);
    uvs[10] = Float2(1, 1);
    uvs[11] = Float2(0, 1);
    // Right
    positions[12] = Float3(halfWidth, halfHeight, -halfDepth);
    positions[13] = Float3(halfWidth, halfHeight, halfDepth);
    positions[14] = Float3(halfWidth, -halfHeight, halfDepth);
    positions[15] = Float3(halfWidth, -halfHeight, -halfDepth);
    normals[12] = Float3(1, 0, 0);
    normals[13] = Float3(1, 0, 0);
    normals[14] = Float3(1, 0, 0);
    normals[15] = Float3(1, 0, 0);
    uvs[12] = Float2(1, 0);
    uvs[13] = Float2(0, 0);
    uvs[14] = Float2(0, 1);
    uvs[15] = Float2(1, 1);
    // Front
    positions[16] = Float3(-halfWidth, halfHeight, halfDepth);
    positions[17] = Float3(halfWidth, halfHeight, halfDepth);
    positions[18] = Float3(halfWidth, -halfHeight, halfDepth);
    positions[19] = Float3(-halfWidth, -halfHeight, halfDepth);
    normals[16] = Float3(0, 0, 1);
    normals[17] = Float3(0, 0, 1);
    normals[18] = Float3(0, 0, 1);
    normals[19] = Float3(0, 0, 1);
    uvs[16] = Float2(0, 0);
    uvs[17] = Float2(1, 0);
    uvs[18] = Float2(1, 1);
    uvs[19] = Float2(0, 1);
    // Back
    positions[20] = Float3(-halfWidth, halfHeight, -halfDepth);
    positions[21] = Float3(halfWidth, halfHeight, -halfDepth);
    positions[22] = Float3(halfWidth, -halfHeight, -halfDepth);
    positions[23] = Float3(-halfWidth, -halfHeight, -halfDepth);
    normals[20] = Float3(0, 0, -1);
    normals[21] = Float3(0, 0, -1);
    normals[22] = Float3(0, 0, -1);
    normals[23] = Float3(0, 0, -1);
    uvs[20] = Float2(1, 0);
    uvs[21] = Float2(0, 0);
    uvs[22] = Float2(0, 1);
    uvs[23] = Float2(1, 1);
    
    auto indices = std::vector<uint32_t>(36);
    
    // prettier-ignore
    // Up
    indices[0] = 0;
    indices[1] = 2;
    indices[2] = 1;
    indices[3] = 2;
    indices[4] = 0;
    indices[5] = 3;
    // Down
    indices[6] = 4;
    indices[7] = 6;
    indices[8] = 7;
    indices[9] = 6;
    indices[10] = 4;
    indices[11] = 5;
    // Left
    indices[12] = 8;
    indices[13] = 10;
    indices[14] = 9;
    indices[15] = 10;
    indices[16] = 8;
    indices[17] = 11;
    // Right
    indices[18] = 12;
    indices[19] = 14;
    indices[20] = 15;
    indices[21] = 14;
    indices[22] = 12;
    indices[23] = 13;
    // Front
    indices[24] = 16;
    indices[25] = 18;
    indices[26] = 17;
    indices[27] = 18;
    indices[28] = 16;
    indices[29] = 19;
    // Back
    indices[30] = 20;
    indices[31] = 22;
    indices[32] = 23;
    indices[33] = 22;
    indices[34] = 20;
    indices[35] = 21;
    
    auto &bounds = mesh->bounds;
    bounds.min = Float3(-halfWidth, -halfHeight, -halfDepth);
    bounds.max = Float3(halfWidth, halfHeight, halfDepth);
    
    PrimitiveMesh::_initialize(engine, mesh, positions, normals, uvs, indices, noLongerAccessible);
    return mesh;
    
}


ModelMeshPtr PrimitiveMesh::createPlane(const EnginePtr &engine,
                                        float width,
                                        float height,
                                        size_t horizontalSegments,
                                        size_t verticalSegments,
                                        bool noLongerAccessible) {
    auto mesh = std::make_shared<ModelMesh>(engine);
    horizontalSegments = std::max(size_t(1), horizontalSegments);
    verticalSegments = std::max(size_t(1), verticalSegments);
    
    const auto horizontalCount = horizontalSegments + 1;
    const auto verticalCount = verticalSegments + 1;
    const auto halfWidth = width / 2;
    const auto halfHeight = height / 2;
    const auto gridWidth = width / horizontalSegments;
    const auto gridHeight = height / verticalSegments;
    const auto vertexCount = horizontalCount * verticalCount;
    const auto rectangleCount = verticalSegments * horizontalSegments;
    auto indices = std::vector<uint32_t>(rectangleCount * 6);
    const auto horizontalCountReciprocal = 1.0 / horizontalCount;
    const auto horizontalSegmentsReciprocal = 1.0 / horizontalSegments;
    const auto verticalSegmentsReciprocal = 1.0 / verticalSegments;
    
    auto positions = std::vector<Float3>(vertexCount);
    auto normals = std::vector<Float3>(vertexCount);
    auto uvs = std::vector<Float2>(vertexCount);
    
    for (size_t i = 0; i < vertexCount; ++i) {
        const auto x = i % horizontalCount;
        const auto z = size_t(float(i) * horizontalCountReciprocal) | 0;
        
        // Position
        positions[i] = Float3(x * gridWidth - halfWidth, 0, z * gridHeight - halfHeight);
        // Normal
        normals[i] = Float3(0, 1, 0);
        // Texcoord
        uvs[i] = Float2(x * horizontalSegmentsReciprocal, z * verticalSegmentsReciprocal);
    }
    
    size_t offset = 0;
    for (size_t i = 0; i < rectangleCount; ++i) {
        const auto x = i % horizontalSegments;
        const auto y = size_t(float(i) * horizontalSegmentsReciprocal) | 0;
        
        const auto a = y * horizontalCount + x;
        const auto b = a + 1;
        const auto c = a + horizontalCount;
        const auto d = c + 1;
        
        indices[offset++] = static_cast<uint32_t>(a);
        indices[offset++] = static_cast<uint32_t>(c);
        indices[offset++] = static_cast<uint32_t>(b);
        indices[offset++] = static_cast<uint32_t>(c);
        indices[offset++] = static_cast<uint32_t>(d);
        indices[offset++] = static_cast<uint32_t>(b);
    }
    
    auto &bounds = mesh->bounds;
    bounds.min = Float3(-halfWidth, 0, -halfHeight);
    bounds.max = Float3(halfWidth, 0, halfHeight);
    
    PrimitiveMesh::_initialize(engine, mesh, positions, normals, uvs, indices, noLongerAccessible);
    return mesh;
    
}

ModelMeshPtr PrimitiveMesh::createCylinder(const EnginePtr &engine,
                                           float radiusTop,
                                           float radiusBottom,
                                           float height,
                                           size_t radialSegments,
                                           size_t heightSegments,
                                           bool noLongerAccessible) {
    auto mesh = std::make_shared<ModelMesh>(engine);
    
    const auto radialCount = radialSegments + 1;
    const auto verticalCount = heightSegments + 1;
    const auto halfHeight = height * 0.5;
    const float unitHeight = height / heightSegments;
    const auto torsoVertexCount = radialCount * verticalCount;
    const auto torsoRectangleCount = radialSegments * heightSegments;
    const auto capTriangleCount = radialSegments * 2;
    const auto totalVertexCount = torsoVertexCount + 2 + capTriangleCount;
    auto indices = std::vector<uint32_t>(torsoRectangleCount * 6 + capTriangleCount * 3);
    const float radialCountReciprocal = 1.0 / radialCount;
    const float radialSegmentsReciprocal = 1.0 / radialSegments;
    const float heightSegmentsReciprocal = 1.0 / heightSegments;
    
    auto positions = std::vector<Float3>(totalVertexCount);
    auto normals = std::vector<Float3>(totalVertexCount);
    auto uvs = std::vector<Float2>(totalVertexCount);
    
    size_t indicesOffset = 0;
    
    // Create torso
    const auto thetaStart = M_PI;
    const auto thetaRange = M_PI * 2;
    const auto radiusDiff = radiusBottom - radiusTop;
    const auto slope = radiusDiff / height;
    const float radiusSlope = radiusDiff / heightSegments;
    
    for (size_t i = 0; i < torsoVertexCount; ++i) {
        const auto x = i % radialCount;
        const auto y = size_t(float(i) * radialCountReciprocal) | 0;
        const auto u = x * radialSegmentsReciprocal;
        const auto v = y * heightSegmentsReciprocal;
        const auto theta = thetaStart + u * thetaRange;
        const auto sinTheta = std::sin(theta);
        const auto cosTheta = std::cos(theta);
        const auto radius = radiusBottom - y * radiusSlope;
        
        const auto posX = radius * sinTheta;
        const auto posY = y * unitHeight - halfHeight;
        const auto posZ = radius * cosTheta;
        
        // Position
        positions[i] = Float3(posX, posY, posZ);
        // Normal
        normals[i] = Float3(sinTheta, slope, cosTheta);
        // Texcoord
        uvs[i] = Float2(u, 1 - v);
    }
    
    for (size_t i = 0; i < torsoRectangleCount; ++i) {
        const auto x = i % radialSegments;
        const auto y = size_t(float(i) * radialSegmentsReciprocal) | 0;
        
        const auto a = y * radialCount + x;
        const auto b = a + 1;
        const auto c = a + radialCount;
        const auto d = c + 1;
        
        indices[indicesOffset++] = static_cast<uint32_t>(b);
        indices[indicesOffset++] = static_cast<uint32_t>(c);
        indices[indicesOffset++] = static_cast<uint32_t>(a);
        indices[indicesOffset++] = static_cast<uint32_t>(b);
        indices[indicesOffset++] = static_cast<uint32_t>(d);
        indices[indicesOffset++] = static_cast<uint32_t>(c);
    }
    
    // Bottom position
    positions[torsoVertexCount] = Float3(0, -halfHeight, 0);
    // Bottom normal
    normals[torsoVertexCount] = Float3(0, -1, 0);
    // Bottom texcoord
    uvs[torsoVertexCount] = Float2(0.5, 0.5);
    
    // Top position
    positions[torsoVertexCount + 1] = Float3(0, halfHeight, 0);
    // Top normal
    normals[torsoVertexCount + 1] = Float3(0, 1, 0);
    // Top texcoord
    uvs[torsoVertexCount + 1] = Float2(0.5, 0.5);
    
    // Add cap vertices
    auto offset = torsoVertexCount + 2;
    
    const auto diameterTopReciprocal = 1.0 / (radiusTop * 2);
    const auto diameterBottomReciprocal = 1.0 / (radiusBottom * 2);
    const auto positionStride = radialCount * heightSegments;
    for (size_t i = 0; i < radialSegments; ++i) {
        const auto curPosBottom = positions[i];
        auto curPosX = curPosBottom.x;
        auto curPosZ = curPosBottom.z;
        
        // Bottom position
        positions[offset] = Float3(curPosX, -halfHeight, curPosZ);
        // Bottom normal
        normals[offset] = Float3(0, -1, 0);
        // Bottom texcoord
        uvs[offset++] = Float2(curPosX * diameterBottomReciprocal + 0.5, 0.5 - curPosZ * diameterBottomReciprocal);
        
        const auto &curPosTop = positions[i + positionStride];
        curPosX = curPosTop.x;
        curPosZ = curPosTop.z;
        
        // Top position
        positions[offset] = Float3(curPosX, halfHeight, curPosZ);
        // Top normal
        normals[offset] = Float3(0, 1, 0);
        // Top texcoord
        uvs[offset++] = Float2(curPosX * diameterTopReciprocal + 0.5, curPosZ * diameterTopReciprocal + 0.5);
    }
    
    // Add cap indices
    const auto topCapIndex = torsoVertexCount + 1;
    const auto bottomIndiceIndex = torsoVertexCount + 2;
    const auto topIndiceIndex = bottomIndiceIndex + 1;
    for (size_t i = 0; i < radialSegments; ++i) {
        const auto firstStride = i * 2;
        const auto secondStride = i == radialSegments - 1 ? 0 : firstStride + 2;
        
        // Bottom
        indices[indicesOffset++] = static_cast<uint32_t>(torsoVertexCount);
        indices[indicesOffset++] = static_cast<uint32_t>(bottomIndiceIndex + secondStride);
        indices[indicesOffset++] = static_cast<uint32_t>(bottomIndiceIndex + firstStride);
        
        // Top
        indices[indicesOffset++] = static_cast<uint32_t>(topCapIndex);
        indices[indicesOffset++] = static_cast<uint32_t>(topIndiceIndex + firstStride);
        indices[indicesOffset++] = static_cast<uint32_t>(topIndiceIndex + secondStride);
    }
    
    auto &bounds = mesh->bounds;
    const auto radiusMax = std::max(radiusTop, radiusBottom);
    bounds.min = Float3(-radiusMax, -halfHeight, -radiusMax);
    bounds.max = Float3(radiusMax, halfHeight, radiusMax);
    
    PrimitiveMesh::_initialize(engine, mesh, positions, normals, uvs, indices, noLongerAccessible);
    return mesh;
    
}

ModelMeshPtr PrimitiveMesh::createTorus(const EnginePtr &engine,
                                        float radius,
                                        float tubeRadius,
                                        size_t radialSegments,
                                        size_t tubularSegments,
                                        float arc,
                                        bool noLongerAccessible) {
    auto mesh = std::make_shared<ModelMesh>(engine);
    
    const auto vertexCount = (radialSegments + 1) * (tubularSegments + 1);
    const auto rectangleCount = radialSegments * tubularSegments;
    auto indices = std::vector<uint32_t>(rectangleCount * 6);
    
    auto positions = std::vector<Float3>(vertexCount);
    auto normals = std::vector<Float3>(vertexCount);
    auto uvs = std::vector<Float2>(vertexCount);
    
    arc = (arc / 180) * M_PI;
    
    size_t offset = 0;
    for (size_t i = 0; i <= radialSegments; i++) {
        for (size_t j = 0; j <= tubularSegments; j++) {
            const auto u = (j / tubularSegments) * arc;
            const auto v = (i / radialSegments) * M_PI * 2;
            const auto cosV = std::cos(v);
            const auto sinV = std::sin(v);
            const auto cosU = std::cos(u);
            const auto sinU = std::sin(u);
            
            const auto position = Float3(
                                         (radius + tubeRadius * cosV) * cosU,
                                         (radius + tubeRadius * cosV) * sinU,
                                         tubeRadius * sinV
                                         );
            positions[offset] = position;
            
            const auto centerX = radius * cosU;
            const auto centerY = radius * sinU;
            normals[offset] = Normalize(Float3(position.x - centerX, position.y - centerY, position.z));
            
            uvs[offset++] = Float2(j / tubularSegments, i / radialSegments);
        }
    }
    
    offset = 0;
    for (size_t i = 1; i <= radialSegments; i++) {
        for (size_t j = 1; j <= tubularSegments; j++) {
            const auto a = (tubularSegments + 1) * i + j - 1;
            const auto b = (tubularSegments + 1) * (i - 1) + j - 1;
            const auto c = (tubularSegments + 1) * (i - 1) + j;
            const auto d = (tubularSegments + 1) * i + j;
            
            indices[offset++] = static_cast<uint32_t>(a);
            indices[offset++] = static_cast<uint32_t>(b);
            indices[offset++] = static_cast<uint32_t>(d);
            
            indices[offset++] = static_cast<uint32_t>(b);
            indices[offset++] = static_cast<uint32_t>(c);
            indices[offset++] = static_cast<uint32_t>(d);
        }
    }
    
    auto &bounds = mesh->bounds;
    const auto outerRadius = radius + tubeRadius;
    bounds.min = Float3(-outerRadius, -outerRadius, -tubeRadius);
    bounds.max = Float3(outerRadius, outerRadius, tubeRadius);
    
    PrimitiveMesh::_initialize(engine, mesh, positions, normals, uvs, indices, noLongerAccessible);
    return mesh;
}

ModelMeshPtr PrimitiveMesh::createCone(const EnginePtr &engine,
                                       float radius,
                                       float height,
                                       size_t radialSegments,
                                       size_t heightSegments,
                                       bool noLongerAccessible) {
    auto mesh = std::make_shared<ModelMesh>(engine);
    
    const auto radialCount = radialSegments + 1;
    const auto verticalCount = heightSegments + 1;
    const auto halfHeight = height * 0.5;
    const auto unitHeight = height / heightSegments;
    const auto torsoVertexCount = radialCount * verticalCount;
    const auto torsoRectangleCount = radialSegments * heightSegments;
    const auto totalVertexCount = torsoVertexCount + 1 + radialSegments;
    auto indices = std::vector<uint32_t>(torsoRectangleCount * 6 + radialSegments * 3);
    const auto radialCountReciprocal = 1.0 / radialCount;
    const auto radialSegmentsReciprocal = 1.0 / radialSegments;
    const auto heightSegmentsReciprocal = 1.0 / heightSegments;
    
    auto positions = std::vector<Float3>(totalVertexCount);
    auto normals = std::vector<Float3>(totalVertexCount);
    auto uvs = std::vector<Float2>(totalVertexCount);
    
    size_t indicesOffset = 0;
    
    // Create torso
    const auto thetaStart = M_PI;
    const auto thetaRange = M_PI * 2;
    const auto slope = radius / height;
    
    for (size_t i = 0; i < torsoVertexCount; ++i) {
        const auto x = i % radialCount;
        const auto y = size_t(float(i) * radialCountReciprocal) | 0;
        const auto u = x * radialSegmentsReciprocal;
        const auto v = y * heightSegmentsReciprocal;
        const auto theta = thetaStart + u * thetaRange;
        const auto sinTheta = std::sin(theta);
        const auto cosTheta = std::cos(theta);
        const auto curRadius = radius - y * radius;
        
        const auto posX = curRadius * sinTheta;
        const auto posY = y * unitHeight - halfHeight;
        const auto posZ = curRadius * cosTheta;
        
        // Position
        positions[i] = Float3(posX, posY, posZ);
        // Normal
        normals[i] = Float3(sinTheta, slope, cosTheta);
        // Texcoord
        uvs[i] = Float2(u, 1 - v);
    }
    
    for (size_t i = 0; i < torsoRectangleCount; ++i) {
        const auto x = i % radialSegments;
        const auto y = size_t(float(i) * radialSegmentsReciprocal) | 0;
        
        const auto a = y * radialCount + x;
        const auto b = a + 1;
        const auto c = a + radialCount;
        const auto d = c + 1;
        
        indices[indicesOffset++] = static_cast<uint32_t>(b);
        indices[indicesOffset++] = static_cast<uint32_t>(c);
        indices[indicesOffset++] = static_cast<uint32_t>(a);
        indices[indicesOffset++] = static_cast<uint32_t>(b);
        indices[indicesOffset++] = static_cast<uint32_t>(d);
        indices[indicesOffset++] = static_cast<uint32_t>(c);
    }
    
    // Bottom position
    positions[torsoVertexCount] = Float3(0, -halfHeight, 0);
    // Bottom normal
    normals[torsoVertexCount] = Float3(0, -1, 0);
    // Bottom texcoord
    uvs[torsoVertexCount] = Float2(0.5, 0.5);
    
    // Add bottom cap vertices
    size_t offset = torsoVertexCount + 1;
    const auto diameterBottomReciprocal = 1.0 / (radius * 2);
    for (size_t i = 0; i < radialSegments; ++i) {
        const auto &curPos = positions[i];
        const auto curPosX = curPos.x;
        const auto curPosZ = curPos.z;
        
        // Bottom position
        positions[offset] = Float3(curPosX, -halfHeight, curPosZ);
        // Bottom normal
        normals[offset] = Float3(0, -1, 0);
        // Bottom texcoord
        uvs[offset++] = Float2(curPosX * diameterBottomReciprocal + 0.5, 0.5 - curPosZ * diameterBottomReciprocal);
    }
    
    const auto bottomIndiceIndex = torsoVertexCount + 1;
    for (size_t i = 0; i < radialSegments; ++i) {
        const auto firstStride = i;
        const auto secondStride = i == radialSegments - 1 ? 0 : firstStride + 1;
        
        // Bottom
        indices[indicesOffset++] = static_cast<uint32_t>(torsoVertexCount);
        indices[indicesOffset++] = static_cast<uint32_t>(bottomIndiceIndex + secondStride);
        indices[indicesOffset++] = static_cast<uint32_t>(bottomIndiceIndex + firstStride);
    }
    
    auto &bounds = mesh->bounds;
    bounds.min = Float3(-radius, -halfHeight, -radius);
    bounds.max = Float3(radius, halfHeight, radius);
    
    PrimitiveMesh::_initialize(engine, mesh, positions, normals, uvs, indices, noLongerAccessible);
    return mesh;
    
}

ModelMeshPtr PrimitiveMesh::createCapsule(const EnginePtr &engine,
                                          float radius,
                                          float height,
                                          size_t radialSegments,
                                          size_t heightSegments,
                                          bool noLongerAccessible) {
    auto mesh = std::make_shared<ModelMesh>(engine);
    
    radialSegments = std::max(size_t(2), radialSegments);
    
    const auto radialCount = radialSegments + 1;
    const auto verticalCount = heightSegments + 1;
    const auto halfHeight = height * 0.5;
    const auto unitHeight = height / heightSegments;
    const auto torsoVertexCount = radialCount * verticalCount;
    const auto torsoRectangleCount = radialSegments * heightSegments;
    
    const auto capVertexCount = radialCount * radialCount;
    const auto capRectangleCount = radialSegments * radialSegments;
    
    const auto totalVertexCount = torsoVertexCount + 2 * capVertexCount;
    auto indices = std::vector<uint32_t>((torsoRectangleCount + 2 * capRectangleCount) * 6);
    
    const auto radialCountReciprocal = 1.0 / radialCount;
    const auto radialSegmentsReciprocal = 1.0 / radialSegments;
    const auto heightSegmentsReciprocal = 1.0 / heightSegments;
    
    const auto halfPI = M_PI / 2;
    const auto doublePI = M_PI * 2;
    
    auto positions = std::vector<Float3>(totalVertexCount);
    auto normals = std::vector<Float3>(totalVertexCount);
    auto uvs = std::vector<Float2>(totalVertexCount);
    
    size_t indicesOffset = 0;
    
    // create torso
    for (size_t i = 0; i < torsoVertexCount; ++i) {
        const auto x = i % radialCount;
        const auto y = size_t(float(i) * radialCountReciprocal) | 0;
        const auto u = x * radialSegmentsReciprocal;
        const auto v = y * heightSegmentsReciprocal;
        const auto theta = -halfPI + u * doublePI;
        const auto sinTheta = std::sin(theta);
        const auto cosTheta = std::cos(theta);
        
        positions[i] = Float3(radius * sinTheta, y * unitHeight - halfHeight, radius * cosTheta);
        normals[i] = Float3(sinTheta, 0, cosTheta);
        uvs[i] = Float2(u, 1 - v);
    }
    
    for (size_t i = 0; i < torsoRectangleCount; ++i) {
        const auto x = i % radialSegments;
        const auto y = size_t(float(i) * radialSegmentsReciprocal) | 0;
        
        const auto a = y * radialCount + x;
        const auto b = a + 1;
        const auto c = a + radialCount;
        const auto d = c + 1;
        
        indices[indicesOffset++] = static_cast<uint32_t>(b);
        indices[indicesOffset++] = static_cast<uint32_t>(c);
        indices[indicesOffset++] = static_cast<uint32_t>(a);
        indices[indicesOffset++] = static_cast<uint32_t>(b);
        indices[indicesOffset++] = static_cast<uint32_t>(d);
        indices[indicesOffset++] = static_cast<uint32_t>(c);
    }
    
    PrimitiveMesh::_createCapsuleCap(
                                     radius,
                                     height,
                                     radialSegments,
                                     doublePI,
                                     torsoVertexCount,
                                     1,
                                     positions,
                                     normals,
                                     uvs,
                                     indices,
                                     indicesOffset
                                     );
    
    PrimitiveMesh::_createCapsuleCap(
                                     radius,
                                     height,
                                     radialSegments,
                                     -doublePI,
                                     torsoVertexCount + capVertexCount,
                                     -1,
                                     positions,
                                     normals,
                                     uvs,
                                     indices,
                                     indicesOffset + 6 * capRectangleCount
                                     );
    
    auto &bounds = mesh->bounds;
    bounds.min = Float3(-radius, -radius - halfHeight, -radius);
    bounds.max = Float3(radius, radius + halfHeight, radius);
    
    PrimitiveMesh::_initialize(engine, mesh, positions, normals, uvs, indices, noLongerAccessible);
    return mesh;
    
}

void PrimitiveMesh::_createCapsuleCap(float radius,
                                      float height,
                                      size_t radialSegments,
                                      float capAlphaRange,
                                      size_t offset,
                                      size_t posIndex,
                                      std::vector<Float3> &positions,
                                      std::vector<Float3> &normals,
                                      std::vector<Float2> &uvs,
                                      std::vector<uint32_t> &indices,
                                      size_t indicesOffset) {
    const auto radialCount = radialSegments + 1;
    const auto halfHeight = height * 0.5;
    const auto capVertexCount = radialCount * radialCount;
    const auto capRectangleCount = radialSegments * radialSegments;
    const auto radialCountReciprocal = 1.0 / radialCount;
    const auto radialSegmentsReciprocal = 1.0 / radialSegments;
    
    for (size_t i = 0; i < capVertexCount; ++i) {
        const auto x = i % radialCount;
        const auto y = size_t(float(i) * radialCountReciprocal) | 0;
        const auto u = x * radialSegmentsReciprocal;
        const auto v = y * radialSegmentsReciprocal;
        const auto alphaDelta = u * capAlphaRange;
        const auto thetaDelta = (v * M_PI) / 2;
        const auto sinTheta = std::sin(thetaDelta);
        
        const auto posX = -radius * std::cos(alphaDelta) * sinTheta;
        const auto posY = (radius * std::cos(thetaDelta) + halfHeight) * posIndex;
        const auto posZ = radius * std::sin(alphaDelta) * sinTheta;
        
        const auto index = i + offset;
        positions[index] = Float3(posX, posY, posZ);
        normals[index] = Float3(posX, posY, posZ);
        uvs[index] = Float2(u, v);
    }
    
    for (size_t i = 0; i < capRectangleCount; ++i) {
        const auto x = i % radialSegments;
        const auto y = size_t(float(i) * radialSegmentsReciprocal) | 0;
        
        const auto a = y * radialCount + x + offset;
        const auto b = a + 1;
        const auto c = a + radialCount;
        const auto d = c + 1;
        
        indices[indicesOffset++] = static_cast<uint32_t>(b);
        indices[indicesOffset++] = static_cast<uint32_t>(a);
        indices[indicesOffset++] = static_cast<uint32_t>(d);
        indices[indicesOffset++] = static_cast<uint32_t>(a);
        indices[indicesOffset++] = static_cast<uint32_t>(c);
        indices[indicesOffset++] = static_cast<uint32_t>(d);
    }
}

void PrimitiveMesh::_initialize(const EnginePtr &engine,
                                const ModelMeshPtr &mesh,
                                const std::vector<Float3> &positions,
                                const std::vector<Float3> &normals,
                                std::vector<Float2> &uvs,
                                const std::vector<uint32_t> &indices,
                                bool noLongerAccessible) {
    mesh->setPositions(positions);
    mesh->setNormals(normals);
    mesh->setUVs(uvs);
    
    mesh->uploadData(noLongerAccessible);
    const auto indexBuffer = [engine->_hardwareRenderer.device newBufferWithBytes:indices.data()
                                                                           length:indices.size() * sizeof(uint32_t)
                                                                          options:MTLResourceStorageModeShared];
    
    mesh->addSubMesh(MeshBuffer(indexBuffer, indices.size() * sizeof(uint32_t), MDLMeshBufferTypeIndex),
                     MTLIndexTypeUInt32, indices.size(), MTLPrimitiveTypeTriangle);
}

}
