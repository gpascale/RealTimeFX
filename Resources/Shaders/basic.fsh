#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

uniform sampler2D u_sampler0; /* Input texture */

varying vec2 v_texCoords;

void main()
{
    gl_FragColor = texture2D(u_sampler0, v_texCoords);
}
