#version 330

// Input and output topologies
layout(triangles) in;
layout(triangle_strip, max_vertices = 170) out;

// Input
in vec2 g_texture_coord[];

// Uniform properties
uniform mat4 View;
uniform mat4 Projection;
uniform int instances;
// TODO(student): Declare other uniforms here
uniform float shrink;
const float SPACING = 1.25;

// Output
out vec2 f_texture_coord;


void EmitPoint(vec3 pos, vec3 offset)
{
    gl_Position = Projection * View * vec4(pos + offset, 1.0);
    EmitVertex();
}


void main()
{
    vec3 p1 = gl_in[0].gl_Position.xyz;
    vec3 p2 = gl_in[1].gl_Position.xyz;
    vec3 p3 = gl_in[2].gl_Position.xyz;

    const vec3 INSTANCE_OFFSET = vec3(1.25, 0, 1.25);
    const int NR_COLS = 6;

    // TODO(student): Second, modify the points so that the
    // triangle shrinks relative to its center
    vec3 c   = (p1 + p2 + p3) / 3.0;
    float s  = clamp(1.0 - shrink, 0.05, 1.0);
    vec3 sp1 = c + (p1 - c) * s;
    vec3 sp2 = c + (p2 - c) * s;
    vec3 sp3 = c + (p3 - c) * s;

    vec3 n = cross(p2 - p1, p3 - p1);
    float nlen = length(n);
    n = (nlen > 1e-5) ? (n / nlen) : vec3(0.0, 1.0, 0.0);

    float explode = shrink * 0.6;
    vec3 eoffset = n * explode;

    for (int i = 0; i < instances; ++i) {
        int col = i % NR_COLS, row = i / NR_COLS;
        vec3 offset = vec3((float(col) - float(NR_COLS - 1) * 0.5) * SPACING,
                           0.0,
                           float(row) * SPACING);

        f_texture_coord = g_texture_coord[0];
        EmitPoint(sp1 + eoffset, offset);                  

        f_texture_coord = g_texture_coord[1];
        EmitPoint(sp2 + eoffset, offset);                  

        f_texture_coord = g_texture_coord[2];
        EmitPoint(sp3 + eoffset, offset);                  

        EndPrimitive();
    }
}
