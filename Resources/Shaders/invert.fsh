#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

uniform sampler2D u_sampler0;

varying vec2 v_texCoords;

void main()
{
	gl_FragColor = vec4(vec3(1.0, 1.0, 1.0) - texture2D(u_sampler0, v_texCoords).xyz, 1.0);
    /*gl_FragColor = texture2D(u_sampler0, v_texCoords).zyxw;*/
}
