#ifdef GL_ES
// define default precision for float, vec, mat.
precision mediump float;
#endif

uniform sampler2D u_sampler0;
varying vec2 v_texCoords;

uniform int u_mirrorType;

void main()
{
    vec2 newTexCoords = v_texCoords;

    if(u_mirrorType == 1 || u_mirrorType == 2)
    {
        if(v_texCoords.t < 0.5)
        {
            newTexCoords.t = v_texCoords.t;
        }
        else
        {
            newTexCoords.t = 1.0 - v_texCoords.t;
        }
    }
    
    if(u_mirrorType == 0 || u_mirrorType == 1)
    {
        if(v_texCoords.s < 0.5)
        {
            newTexCoords.s = v_texCoords.s;
        }
        else
        {
            newTexCoords.s = 1.0 - v_texCoords.s;
        }
    }
    
    gl_FragColor = texture2D(u_sampler0, newTexCoords);
}