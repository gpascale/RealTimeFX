#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

uniform sampler2D u_sampler0;

varying vec2 v_texCoords;

void main()
{
    float grayValue = dot(texture2D(u_sampler0, v_texCoords), vec4(0.2, 0.69, 0.11, 0.0));
	gl_FragColor = vec4(grayValue, grayValue, grayValue, 1.0);
}