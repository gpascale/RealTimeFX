#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

uniform sampler2D u_sampler0;
uniform sampler2D u_sampler1;
uniform float u_intensity;
uniform float u_rotationAmt;

varying vec2 v_texCoords;

void main()
{
    vec4 originalColor = texture2D(u_sampler0, v_texCoords); 
    vec4 imageColor = vec4(dot(originalColor, vec4(0.393, 0.769, 0.189, 0.0)),
                           dot(originalColor, vec4(0.349, 0.686, 0.168, 0.0)),
                           dot(originalColor, vec4(0.272, 0.534, 0.131, 0.0)),
                           1.0);
                           
    mat2 rotMat = mat2(cos(u_rotationAmt), -sin(u_rotationAmt),
                       sin(u_rotationAmt), cos(u_rotationAmt));
    vec2 texCoordsNew = (rotMat * (v_texCoords - vec2(0.5, 0.5))) + vec2(0.5, 0.5);
                                                   
    vec4 filmColor = texture2D(u_sampler1, texCoordsNew);
    gl_FragColor = ((1.0 - u_intensity) * imageColor) + (u_intensity * filmColor);

	/* Uncomment this to visualize the displacement texture
	gl_FragColor = texture2D(u_sampler1, v_texCoords);
    */
}