//
//  Fragment.metal
//  SurfaceManipulation
//
//  Created by Matthew Dillard on 7/7/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

fragment half4 passThroughFragment(VertexInOut inFrag [[stage_in]])
{
	return half4(inFrag.color);
};
