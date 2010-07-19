#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

uniform sampler2D u_sampler0; /* Input texture */

varying vec2 v_texCoords;

void main()
{
    vec4 originalColor = texture2D(u_sampler0, v_texCoords); 
    gl_FragColor = vec4(dot(originalColor, vec4(0.393, 0.769, 0.189, 0.0)),
                        dot(originalColor, vec4(0.349, 0.686, 0.168, 0.0)),
                        dot(originalColor, vec4(0.272, 0.534, 0.131, 0.0)),
                        1.0);
}