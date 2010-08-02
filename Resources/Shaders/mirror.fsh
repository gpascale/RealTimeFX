#ifdef GL_ES
// define default precision for float, vec, mat.
precision mediump float;
#endif

uniform sampler2D u_sampler0;

varying vec2 v_texCoords;

void main()
{
    vec2 newTexCoords = v_texCoords;

    if(v_texCoords.t < 0.5)
    {
        newTexCoords.t = v_texCoords.t;
    }
    else
    {
        newTexCoords.t = 1.0 - v_texCoords.t;
    }
    
    if(v_texCoords.s < 0.5)
    {
        newTexCoords.s = v_texCoords.s;
    }
    else
    {
        newTexCoords.s = 1.0 - v_texCoords.s;
    }
    
    gl_FragColor = texture2D(u_sampler0, newTexCoords);
}