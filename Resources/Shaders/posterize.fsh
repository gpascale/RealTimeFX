#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

uniform sampler2D u_sampler0;
uniform int u_numBuckets;

varying vec2 v_texCoords;

void main()
{
    float numBucketsFloat = float(u_numBuckets);
    vec3 color = texture2D(u_sampler0, v_texCoords).xyz;    
    color = color * numBucketsFloat;
    color = floor(color);
    color = color * (1.0 / (numBucketsFloat - 1.0));
    
    gl_FragColor = vec4(color.x, color.y, color.z, 1.0);
}