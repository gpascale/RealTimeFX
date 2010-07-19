#ifdef GL_ES
// define default precision for float, vec, mat.
precision mediump float;
#endif

uniform sampler2D u_sampler0;

uniform float u_multiplier;

varying vec2 v_texCoords;

void main()
{
    vec2 newTexCoords = vec2(mod(2.0 * v_texCoords.s, 1.0), mod(2.0 * v_texCoords.t, 1.0));
    vec4 color = texture2D(u_sampler0, newTexCoords);
    float grayVal = dot(color, vec4(0.2, 0.69, 0.11, 0.0));
    
    if(v_texCoords.s < 0.5)
    {
        if(v_texCoords.t < 0.5)
        {
            gl_FragColor = vec4(color.g, u_multiplier * color.r, color.b, 1.0);                        
        }
        else
        {
            gl_FragColor = vec4(color.g, color.g, color.g, 1.0);
        }
    }
    else
    {
        if(v_texCoords.t < 0.5)
        {
            gl_FragColor = vec4(color.g, color.b, u_multiplier * color.r, 1.0);
        }
        else
        {
            gl_FragColor = vec4(u_multiplier * color.r, color.b, color.g, 1.0);
        }
    }
}