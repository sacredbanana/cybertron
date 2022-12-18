void main() {
    vec2 uv = v_tex_coord;
    uv -= .5;
    uv.x /= v2Resolution.y / v2Resolution.x;
    
    float distortionSpeed = u_time * .1;
    float distortionFrequency = 5.;
    float distortionStrength = 1.;
    
    uv.x += sin((uv.x + distortionSpeed) * distortionFrequency) * distortionStrength;
    uv.y += cos((uv.y + distortionSpeed) * distortionFrequency) * distortionStrength;
    
    vec3 color = vec3(0.);
    color.b = .5 + .5 * sin(5. * (length(uv) * 5. - 2. * u_time));

    gl_FragColor = vec4(color, 1.);
}
