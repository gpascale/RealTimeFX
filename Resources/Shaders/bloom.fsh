#ifdef GL_ES
// define default precision for float, vec, mat.
precision mediump float;
#endif

uniform sampler2D u_sampler0;
uniform sampler2D u_sampler1;
uniform float u_multiplier;

varying vec2 v_texCoords;


void main()
{
	vec4 sum = vec4(0, 0, 0, 0);

    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(-.006, -.008));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(-.003, -.008));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.000, -.008));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.003, -.008));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.006, -.008));
    
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(-.006, -.004));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(-.003, -.004));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.000, -.004));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.003, -.004));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.006, -.004));
    
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(-.006, .000));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(-.003, .000));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.000, .000));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.003, .000));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.006, .000));
    
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(-.006, .004));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(-.003, .004));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.000, .004));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.003, .004));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.006, .004));
    
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(-.006, .008));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(-.003, .008));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.000, .008));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.003, .008));
    sum += 0.5 * texture2D(u_sampler0, v_texCoords + vec2(0.006, .008));

    vec4 color = texture2D(u_sampler0, v_texCoords);
    float mul = u_multiplier * texture2D(u_sampler1, vec2(color.r, 0.5)).r; // r is aribtrary - texture is a single float value
	
    gl_FragColor = sum*sum*mul + color;
}