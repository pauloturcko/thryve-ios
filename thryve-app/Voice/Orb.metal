#include <metal_stdlib>
using namespace metal;

// A bolinha da tela de gravação: a orb elétrica, refeita a partir da prévia escolhida.
// Borda de fios contínuos (sem sorteio por quadro, que fazia a orb tremer) com halo
// (orbElectricFragment) e poeira cósmica por dentro (orbDustVertex), que o OrbRenderer
// move a cada quadro. A voz agita os fios e acende o brilho; cada sílaba dá um tranco na
// borda e sopra a poeira. Entendendo: um arco percorre a borda. Salvo: um ✓ acende por dentro.
// Branca no tema escuro, preta no claro.

/// Espelho do `OrbUniforms` do Swift: só floats, para o layout bater dos dois lados.
struct OrbUniforms {
    float width;      // drawable, em pixels
    float height;
    float scale;      // pixels por ponto
    float time;
    float phase;      // avança mais rápido com a voz
    float energy;     // volume suavizado, 0...1
    float low;        // faixas da voz, 0...1
    float mid;
    float high;
    float pulseAge;   // segundos desde a última sílaba
    float pulseAmp;   // força da última sílaba, 0...1
    float listen;     // pesos dos estados, 0...1, suavizados no Swift
    float process;
    float saved;
    float light;      // 1 no tema claro
};

static float orbHash(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

static float orbNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(orbHash(i), orbHash(i + float2(1, 0)), u.x),
               mix(orbHash(i + float2(0, 1)), orbHash(i + float2(1, 1)), u.x), u.y);
}

static float orbFbm(float2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    const float2x2 turn = float2x2(1.6, 1.2, -1.2, 1.6);
    for (int octave = 0; octave < 5; octave++) {
        value += amplitude * orbNoise(p);
        p = turn * p;
        amplitude *= 0.5;
    }
    return value;
}

static float segmentDistance(float2 p, float2 a, float2 b) {
    float2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

static float checkDistance(float2 p) {
    return min(segmentDistance(p, float2(-0.30, 0.02), float2(-0.08, -0.20)),
               segmentDistance(p, float2(-0.08, -0.20), float2(0.32, 0.24)));
}

struct QuadOut {
    float4 position [[position]];
};

vertex QuadOut orbQuadVertex(uint vertexID [[vertex_id]]) {
    const float2 corners[3] = { float2(-1, -1), float2(3, -1), float2(-1, 3) };
    QuadOut out;
    out.position = float4(corners[vertexID], 0.0, 1.0);
    return out;
}

fragment half4 orbElectricFragment(QuadOut in [[stage_in]], constant OrbUniforms &u [[buffer(0)]]) {
    float2 size = float2(u.width, u.height);
    float unit = 0.5 * min(size.x, size.y);
    // Coordenadas com o centro em 0 e a borda da view em 1, y para cima.
    float2 p = (in.position.xy - 0.5 * size) / unit;
    p.y = -p.y;
    // Meio ponto da tela nessas coordenadas: deixa as linhas com a mesma espessura em qualquer aparelho.
    float halfPoint = 0.5 * u.scale / unit;

    float r = length(p);
    float angle = atan2(p.y, p.x);
    float2 circle = float2(cos(angle), sin(angle));
    float R = 0.6 * (1.0 + 0.03 * u.low * u.listen - 0.1 * u.process);
    float active = u.energy * u.listen;
    float2 q = p / R;
    float light = 0.0;

    // Névoa leve por dentro.
    if (r < R) {
        light += 0.04 + 0.08 * orbFbm(q * 2.0 + u.phase * 0.2) * (1.0 + active);
    }

    // Fios da borda: ruído contínuo em volta do círculo. A voz abre a ondulação,
    // o agudo agita mais e cada sílaba dá um tranco.
    float kick = u.pulseAmp * exp(-u.pulseAge * 3.5) * u.listen;
    for (int strand = 0; strand < 4; strand++) {
        float index = float(strand);
        float wave = (orbFbm(circle * 1.6 + float2(index * 7.0, u.time * 0.3 + index)) - 0.5)
            * (0.035 + 0.07 * active + 0.03 * u.high * u.listen + 0.04 * kick);
        wave += 0.012 * sin(angle * (9.0 + index * 4.0) + u.phase * (1.5 + index * 0.4)) * (0.5 + active);
        float gap = abs(r - R * (1.0 + wave));
        float width = halfPoint * (1.2 + 0.4 * index);
        light += exp(-gap * gap / (width * width)) * 0.55 + exp(-gap / 0.035) * 0.07 * (1.0 + 1.5 * active + kick);
    }

    // Entendendo: um arco claro corre pela borda. Salvo: um ✓ acende por dentro.
    float arc = pow(0.5 + 0.5 * cos(angle - u.time * 4.0), 24.0) * u.process * exp(-abs(r - R) * 40.0) * 1.5;
    float halo = exp(-max(r - R, 0.0) * 9.0) * (0.08 + 0.3 * active) * step(R, r);
    float check = (1.0 - smoothstep(0.035, 0.055, checkDistance(q))) * u.saved * step(r, R);
    light += arc + halo + check * 1.4;

    // Some antes da borda da view, senão aparece um quadrado em volta.
    light *= 1.0 - smoothstep(0.9, 1.0, r);
    // Compressão suave em vez de cortar no 1: os fios somados não viram uma faixa chapada.
    light = 1.0 - exp(-1.3 * max(light, 0.0));
    float3 ink = u.light > 0.5 ? float3(0.04, 0.04, 0.05) : float3(1.0);
    return half4(half3(ink * light), half(light));
}

struct DustOut {
    float4 position [[position]];
    float pointSize [[point_size]];
    float brightness;
};

/// Cada grão chega do OrbRenderer como xy (dentro da esfera de raio 1), z (diâmetro em pontos)
/// e w (brilho, já com profundidade e cintilação).
vertex DustOut orbDustVertex(uint vertexID [[vertex_id]],
                             const device float4 *grains [[buffer(0)]],
                             constant OrbUniforms &u [[buffer(1)]]) {
    float4 grain = grains[vertexID];
    float2 size = float2(u.width, u.height);
    float R = 0.6 * (1.0 + 0.03 * u.low * u.listen - 0.1 * u.process);
    // Cada sílaba sopra a poeira para fora por um instante.
    float puff = 1.0 + 0.06 * u.pulseAmp * exp(-u.pulseAge * 3.5) * u.listen;

    DustOut out;
    out.position = float4(grain.xy * puff * R * min(size.x, size.y) / size, 0.0, 1.0);
    // O sprite é 3x o grão, para caber o brilho em volta dos maiores.
    out.pointSize = grain.z * u.scale * 3.0;
    out.brightness = grain.w;
    return out;
}

fragment half4 orbDustFragment(DustOut in [[stage_in]],
                               float2 pointCoord [[point_coord]],
                               constant OrbUniforms &u [[buffer(0)]]) {
    // 0 no centro do sprite, 1 na borda; o grão em si ocupa o terço do meio.
    float distance = length(pointCoord - 0.5) * 2.0;
    float core = 1.0 - smoothstep(0.2, 0.34, distance);
    float glow = exp(-distance * distance * 7.0) * 0.3;
    float alpha = clamp((core + glow) * in.brightness, 0.0, 1.0) * (1.0 - smoothstep(0.85, 1.0, distance));
    float3 ink = u.light > 0.5 ? float3(0.04, 0.04, 0.05) : float3(1.0);
    return half4(half3(ink * alpha), half(alpha));
}
