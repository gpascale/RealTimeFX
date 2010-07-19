#ifdef GL_ES
// define default precision for float, vec, mat.
precision mediump float;
#endif

uniform sampler2D u_sampler0;
uniform sampler2D u_sampler1;

varying vec2 v_texCoords;

float getGray(in vec4 color)
{
    return dot(vec3(.2, .69, .11), color.xyz);
}

const mat3 edgeFilter = mat3(-1.0, -1.0, -1.0,
                             -1.0, 8.0, -1.0,
                             -1.0, -1.0, -1.0);                              

void main()
{
    const float xOffset = 3.0 / 480.0;
    const float yOffset = 3.0 / 320.0;

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

    float edgeContribution = dot(edgeFilter[0], colorMat[0]) + 
                             dot(edgeFilter[1], colorMat[1]) + 
                             dot(edgeFilter[2], colorMat[2]);

    vec4 paperColor = vec4(texture2D(u_sampler1, v_texCoords).xyz, 1.0);

    float edgeMult = max(0.0, min(1.0, ceil(edgeContribution - 0.3)));
    
    float edgeColor = max(0.3, 1.0 - (2.0 * edgeContribution * edgeContribution));
    
    gl_FragColor = (edgeMult * vec4(edgeColor, edgeColor, edgeColor, 1.0))
                    + ((1.0 - edgeMult) * paperColor);    
}