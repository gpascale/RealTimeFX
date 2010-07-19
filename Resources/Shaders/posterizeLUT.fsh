#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

uniform sampler2D u_sampler0;
uniform sampler2D u_sampler1;

varying vec2 v_texCoords;

float getGray(in vec4 color)
{
	return dot(color, vec4(0.3, 0.6, 0.1, 0.0));
}

void main()
{
    vec4 originalColor = texture2D(u_sampler0, v_texCoords);
    vec4 clampedColor = vec4(0.0, 0.0, 0.0, 1.0);
    clampedColor.r = texture2D(u_sampler1, vec2(originalColor.r, 0.5)).r;
    clampedColor.g = texture2D(u_sampler1, vec2(originalColor.g, 0.5)).r;
    clampedColor.b = texture2D(u_sampler1, vec2(originalColor.b, 0.5)).r;

    gl_FragColor = clampedColor;

	/* Uncomment this to visualize the displacement texture
	gl_FragColor = texture2D(u_sampler1, v_texCoords);
    */
}