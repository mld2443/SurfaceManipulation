//
//  Fragment.metal
//  SurfaceManipulation
//
//  Created by Matthew Dillard on 7/7/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexInOut
{
	float4  position [[position]];
	float4  color;
};

fragment half4 fragmentShader(VertexInOut inFrag [[stage_in]])
{
	return half4(inFrag.color);
};
