#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

uniform sampler2D u_sampler0;
uniform sampler2D u_sampler1;

varying vec2 v_texCoords;

void main()
{
	float gray = dot((texture2D(u_sampler0, v_texCoords)), vec4(0.3, 0.6, 0.1, 0.0));
	vec2 dispTexCoords = vec2(gray, 0.5);
	gl_FragColor = texture2D(u_sampler1, dispTexCoords);

	// Uncomment this to visualize the displacement texture
	// gl_FragColor = texture2D(u_sampler1, v_texCoords);
    
}