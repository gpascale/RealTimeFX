#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

uniform float u_power;
uniform sampler2D u_sampler0;

varying vec2 v_texCoords;

void main()
{
    vec2 d = vec2(2.0, 3.0) * (v_texCoords - vec2(0.5, 0.5));
    float mag = sqrt(d.x * d.x + d.y * d.y);
    float magAdjust = pow(mag, u_power);
    vec2 adjustedD = 0.5 * magAdjust * (vec2(1.0, 0.66) * d);
    gl_FragColor = texture2D(u_sampler0, vec2(0.5, 0.5) + adjustedD);
}