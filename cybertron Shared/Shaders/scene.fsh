void main() {
//    float speed = u_time * u_speed * .05;
//    float strength = u_strength / 100.;
    vec2 uv = v_tex_coord;
    uv = ceil(uv*200.)/200.;
//    uv -= .5;
//    uv.x /= v2Resolution.y / v2Resolution.x;

//    vec2 coord = v_tex_coord;
//
//    coord.x += sin((coord.x + speed) * u_frequency) * strength;
//    coord.y += cos((coord.y + speed) * u_frequency) * strength;

    gl_FragColor = texture2D(u_texture, uv) * v_color_mix.a;
}
