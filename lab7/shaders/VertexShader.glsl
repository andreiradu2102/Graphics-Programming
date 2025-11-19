#version 330 core

// Input
layout(location = 0) in vec3 v_position;
layout(location = 1) in vec3 v_normal;
layout(location = 2) in vec2 v_texture_coord;
layout(location = 3) in ivec4 BoneIDs;
layout(location = 4) in vec4 Weights;

const int MAX_BONES = 200;

// Uniform properties
uniform mat4 Model;
uniform mat4 View;
uniform mat4 Projection;
uniform mat4 Bones[MAX_BONES];

// Output to fragment shader
out vec2 texture_coord;
out vec3 normal;

void main()
{
    // Linear blend skinning: combine up to 4 bone transforms with their weights
    mat4 BoneTransform = Bones[BoneIDs[0]] * Weights[0];
    BoneTransform += Bones[BoneIDs[1]] * Weights[1];
    BoneTransform += Bones[BoneIDs[2]] * Weights[2];
    BoneTransform += Bones[BoneIDs[3]] * Weights[3];

    // Pass-through texture coordinates
    texture_coord = v_texture_coord;

    // Transform normal into "bone space"
    normal = mat3(BoneTransform) * v_normal;

    // Final position: apply bone, then standard MVP
    gl_Position = Projection * View * Model * BoneTransform * vec4(v_position, 1.0);
}
