#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

uniform sampler2D u_sampler0;
uniform sampler2D u_sampler1;

varying vec2 v_texCoords;

void main()
{
    vec4 dispColor = texture2D(u_sampler1, v_texCoords);
	vec2 dispTexCoords = vec2(dispColor.x, dispColor.y);
	gl_FragColor = texture2D(u_sampler0, dispTexCoords);
	
	/*
	Uncomment this to visualize the displacement texture
	gl_FragColor = texture2D(u_sampler2, v_texCoords);
	*/
}