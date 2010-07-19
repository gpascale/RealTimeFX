#ifdef GL_ES
// define default precision for float, vec, mat.
precision mediump float;
#endif

uniform sampler2D u_sampler0;

varying vec2 v_texCoords;

float getGray(in vec4 color)
{
    return dot(vec3(.3, .59, .11), color.xyz);
}

/*
const mat3 xMatrix = mat3(1.0, 0.0, -1.0,
                          2.0, 0.0, -2.0,
                          1.0, 0.0, -1.0);
                          */
const mat3 xMatrix = mat3(-1.0, -1.0, -1.0,
                          -1.0, 8.0, -1.0,
                          -1.0, -1.0, -1.0);
                              
const mat3 yMatrix = mat3(1.0, 2.0, 1.0,
                          0.0, 0.0, 0.0,
                          -1.0, -2.0, -1.0);

void main()
{
    const float xOffset = 4.0 / 480.0;
    const float yOffset = 4.0 / 320.0;

    mat3 colorMat;
    colorMat[0][0] = getGray(texture2D(u_sampler0, v_texCoords + vec2(-xOffset, -yOffset)));
    colorMat[0][1] = getGray(texture2D(u_sampler0, v_texCoords + vec2(0.0, -yOffset)));
    colorMat[0][2] = getGray(texture2D(u_sampler0, v_texCoords + vec2(xOffset, -yOffset)));
    colorMat[1][0] = getGray(texture2D(u_sampler0, v_texCoords + vec2(-xOffset, 0.0)));
    colorMat[1][1] = getGray(texture2D(u_sampler0, v_texCoords + vec2(0.0, 0.0)));
    colorMat[1][2] = getGray(texture2D(u_sampler0, v_texCoords + vec2(xOffset, 0.0)));
    colorMat[2][0] = getGray(texture2D(u_sampler0, v_texCoords + vec2(-xOffset, yOffset)));
    colorMat[2][1] = getGray(texture2D(u_sampler0, v_texCoords + vec2(0.0, yOffset)));
    colorMat[2][2] = getGray(texture2D(u_sampler0, v_texCoords + vec2(xOffset, yOffset)));

                      // x
    float combColor = dot(xMatrix[0], colorMat[0]) + 
                      dot(xMatrix[1], colorMat[1]) + 
                      dot(xMatrix[2], colorMat[2]);//
                      /*// y                      
                      dot(yMatrix[0], colorMat[0]) + 
                      dot(yMatrix[1], colorMat[1]) + 
                      dot(yMatrix[2], colorMat[2]);    */
	
    gl_FragColor = vec4(combColor, combColor, combColor, 1.0);
}