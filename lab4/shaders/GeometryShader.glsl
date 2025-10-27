#version 330

layout(lines) in;
layout(triangle_strip, max_vertices = 146) out;

// Uniforms
uniform mat4 View;
uniform mat4 Projection;
uniform vec3 control_p0, control_p1, control_p2, control_p3;
uniform int  no_of_instances;              // number of bands
uniform int  no_of_generated_points;       // samples along the curve
uniform float max_translate;               // total translation along +X
uniform float max_rotate;                  // total rotation angle (radians)

// Per-vertex input carrying instance index
in int instance[2];

out vec3 gColor;

// Helpers
vec3 rotateY(vec3 point, float u)
{
    float c = cos(u), s = sin(u);
    float x = point.x * c - point.z * s;
    float z = point.x * s + point.z * c;
    return vec3(x, point.y, z);
}

vec3 translateX(vec3 point, float t)
{
    return vec3(point.x + t, point.y, point.z);
}

vec3 angleToRGB(float ang)
{
    const float TWO_PI = 6.283185307179586;
    float u = fract(ang / TWO_PI);

    const vec3 A = vec3(0.5, 0.5, 0.5);
    const vec3 B = vec3(0.5, 0.5, 0.5);
    const vec3 C = vec3(1.0, 1.0, 1.0);
    const vec3 D = vec3(0.00, 0.33, 0.67);
    return clamp(A + B * cos(TWO_PI * (C * u + D)), 0.0, 1.0);
}

vec3 bezier(float t)
{
    float it  = 1.0 - t;
    float it2 = it * it;
    float t2  = t * t;
    return  control_p0 * (it2 * it) +
            control_p1 * (3.0 * t * it2) +
            control_p2 * (3.0 * t2 * it) +
            control_p3 * (t2 * t);
}

vec3 hermite(float t)
{
    float t2 = t * t;
    float t3 = t2 * t;

    float h00 =  2.0 * t3 - 3.0 * t2 + 1.0;
    float h10 =        t3 - 2.0 * t2 + t;
    float h01 = -2.0 * t3 + 3.0 * t2;
    float h11 =        t3 -       t2;

    return h00 * control_p0 +
           h10 * control_p1 +
           h01 * control_p2 +
           h11 * control_p3;
}

void main()
{
    // Each GS invocation draws ONE band between instance k and k+1
    int k = instance[0];

    // Skip if this would be the last band
    if (no_of_instances < 2 || k >= no_of_instances - 1)
        return;

    const int MAX_V = 256;
    int N = no_of_generated_points;
    N = min(N, (MAX_V / 2) - 1);
    N = max(N, 2);

    float dt = 1.0 / float(N);

    float denom = float(max(no_of_instances - 1, 1));
    float s0 = float(k)     / denom;
    float s1 = float(k + 1) / denom;

    float tx0 = s0 * max_translate;
    float tx1 = s1 * max_translate;

    float ang0 = s0 * max_rotate;
    float ang1 = s1 * max_rotate;

    bool doRotation    = (max_rotate    > 1e-5);
    bool doTranslation = (max_translate > 1e-5) && !doRotation;

    vec3 col0_base = angleToRGB(ang0);
    vec3 col1_base = angleToRGB(ang1);

    for (int i = 0; i <= N; ++i)
    {
        float t = float(i) * dt;
        vec3 p = bezier(t);
        // vec3 p = hermite(t);

        vec3 p0 = p;
        vec3 p1 = p;

        if (doRotation)
        {
            p0 = rotateY(p, ang0);
            p1 = rotateY(p, ang1);
        }
        else if (doTranslation)
        {
            p0 = translateX(p, tx0);
            p1 = translateX(p, tx1);
        }

        float vMod = mix(0.9, 1.0, t);

        gColor = col0_base * vMod;
        gl_Position = Projection * View * vec4(p0, 1.0); EmitVertex();

        gColor = col1_base * vMod;
        gl_Position = Projection * View * vec4(p1, 1.0); EmitVertex();

    }
    EndPrimitive();
}
