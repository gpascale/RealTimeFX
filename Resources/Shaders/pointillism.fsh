#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

uniform sampler2D u_sampler0;
uniform sampler2D u_sampler1;

varying vec2 v_texCoords;

void main()
{
    //gl_FragColor = texture2D(u_sampler1, v_texCoords);
    
    vec4 lookupOffset = texture2D(u_sampler1, v_texCoords.xy);
    vec4 finalColor = vec4(0.0, 0.0, 0.0, 0.0);
    
    if(lookupOffset.x < 0.99)
    {
        vec2 offset = (lookupOffset.xy * 255.0) - vec2(128.0, 128.0);
        offset = offset * vec2(1.0 / 480.0, 1.0 / 320.0);
        vec2 coords = vec2(v_texCoords.x + offset.x, v_texCoords.y + offset.y);
        finalColor = texture2D(u_sampler0, coords);
        finalColor.a = lookupOffset.b;
        /*finalColor = finalColor * (lookupOffset.b) +
                     vec4(1.0, 1.0, 1.0, 1.0) * (1.0 - lookupOffset.b);*/
    }
    
	gl_FragColor = vec4(finalColor.xyz, lookupOffset.b);
}