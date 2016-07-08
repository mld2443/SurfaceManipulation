//
//  Vertex.metal
//  SurfaceManipulation
//
//  Created by Matthew Dillard on 6/30/16.
//  Copyright (c) 2016 Matthew Dillard. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct VertexInOut
{
    float4  position [[position]];
    float4  color;
};

vertex VertexInOut vertexShader(uint vid [[ vertex_id ]],
								constant packed_float4* position  [[ buffer(0) ]],
								constant packed_float4* color    [[ buffer(1) ]])
{
    VertexInOut outVertex;
    
    outVertex.position = position[vid];
    outVertex.color    = color[vid];
    
    return outVertex;
};