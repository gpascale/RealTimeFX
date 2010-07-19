#ifdef GL_ES
// define default precision for float, vec, mat.
precision mediump float;
#endif

uniform sampler2D u_sampler0;
uniform sampler2D u_sampler1;

varying vec2 v_texCoords;

/*
void main()
{
    float dx = 2.0 * (v_texCoords.x - 0.5);
    float dy = 2.0 * (v_texCoords.y - 0.5);
    float dxAmt = pow(abs(dx), 0.5);
    float dyAmt = pow(abs(dy), 0.5);

    vec4 color = texture2D(u_sampler, vec2(0.5 + (0.5 * dx * dxAmt),
                                           0.5 + (0.5 * dy * dyAmt)));

    gl_FragColor = color;
}
*/

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
    float mul = texture2D(u_sampler1, vec2(color.r, 0.5)).r; // r is aribtrary - texture is a single float value
	
    gl_FragColor = sum*sum*mul + color;
}