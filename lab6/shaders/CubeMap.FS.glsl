#version 330

in vec3 world_position;
in vec3 world_normal;

uniform samplerCube texture_cubemap;
uniform vec3 camera_position;
uniform int type;

layout(location = 0) out vec4 out_color;

void main()
{
    vec3 N = normalize(world_normal);
    vec3 I = normalize(world_position - camera_position);
    vec3 color;

    if (type == 0) {
        vec3 R = reflect(I, N);
        color = texture(texture_cubemap, R).rgb;
    } else {
        float eta = 1.0 / 1.33;
        vec3 T = refract(I, N, eta);
        color = texture(texture_cubemap, T).rgb;
    }

    out_color = vec4(color, 1.0);
}
