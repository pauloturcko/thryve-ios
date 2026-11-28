# Audio-Reactive Voice Visuals on iOS 26/27 with SwiftUI and Metal: Technical Guide

Scope: one central animated voice-capture element (orb, glow, fluid blob, particle field, dotted sphere) in a SwiftUI app on A18/A19-class iPhones, iOS 26–27, smooth at 60–120 fps and battery-friendly.

Labeling: anything not backed by a source fetched in this session is marked **[Unverified, general graphics/DSP knowledge]** and belongs to the Inferences sections. Treat those parts as engineering guidance to validate in Instruments, not documented fact.

---

## 1. SwiftUI rendering options: strengths, limits, and performance

### Takeaway
For one central element, the strongest default is a SwiftUI `[[stitchable]]` Metal shader (`colorEffect` for procedural generation, `layerEffect` only when you must sample neighbors), driven by `TimelineView(.animation)` with time and audio values passed in as uniforms. Use `MeshGradient` for cheap ambient color fields, Liquid Glass (`glassEffect`) only for chrome around the visual (not the visual itself), and drop to `MTKView` when you need persistent GPU state, such as compute-simulated particles, multi-pass bloom, or feedback buffers.

### Cited Findings
- **The three shader modifiers.** WWDC26 session 322 ("Compose advanced graphics effects with SwiftUI") calls `colorEffect` a per-pixel color transform that needs no neighboring pixels and `distortionEffect` a remap of the sample position. It calls `layerEffect` the most flexible, because it "provides the layer of the entire view, which allows you to sample adjacent pixels or the entire region." — [WWDC26 Session 322](https://developer.apple.com/videos/play/wwdc2026/322)
- **Shaders are stateless.** The same session says shaders "have no memory of the previous frame, the output relies only on the parameters," so "if I want animation, I need to pass in a value that changes over time." Its canonical pattern is `TimelineView(.animation)`, with elapsed time computed from a stored `startDate` and passed in as `.float(elapsed)`. — [WWDC26 Session 322](https://developer.apple.com/videos/play/wwdc2026/322)
- **Per-pixel parallelism.** "Each pixel executes independently, with no awareness of its neighbors." — [WWDC26 Session 322](https://developer.apple.com/videos/play/wwdc2026/322)
- **Shader signature, shown verbatim in the session:** `[[stitchable]] half4 backgroundWarp(float2 position, SwiftUI::Layer layer, float2 size, texture2d<half> noiseTex)`. Swift passes arguments as `ShaderLibrary.backgroundWarp(.float2(proxy.size), .image(Image("NoiseTexture")), .float(elapsed))`, applied with `.layerEffect(..., maxSampleOffset: .zero)`. — [WWDC26 Session 322](https://developer.apple.com/videos/play/wwdc2026/322)
- **`maxSampleOffset`.** If a layer shader samples positions other than the destination pixel, you must supply the maximum sampling distance on each axis. — [Apple docs: layerEffect(_:maxSampleOffset:isEnabled:)](https://developer.apple.com/documentation/swiftui/view/layereffect(_:maxsampleoffset:isenabled:).md)
- **Precompiling.** Precompiling a shader with `shader.compile(as:)` avoids a small hitch on first use, provided you compile well in advance with the same parameter types. — [Hacking with Swift (mirror)](https://chanhi2000.github.io/bookshelf/hackingwithswift.com/swiftui/how-to-add-metal-shaders-to-swiftui-views-using-layer-effects.html)
- **Inferno's performance claim and tips.** The README says "all the fragment shaders here run at 60fps on all phones that support iOS 17." It advises to "precompute values on the CPU and pass them directly into the shader" and to "prefer to use the `half` data types whenever the precision requirements allow it." It also warns that literal types matter, because an integer literal like `2` gets converted to float at runtime. — [twostraws/Inferno](https://github.com/twostraws/Inferno)
- **Reading the view size.** Inferno uses `visualEffect { content, proxy in }` to read the view size inside animated shaders, combined with `TimelineView(.animation)`. — [twostraws/Inferno](https://github.com/twostraws/Inferno)
- **MeshGradient.** `MeshGradient` is an iOS 18 SwiftUI view. The common animation pattern wraps it in `TimelineView(.animation)` and recomputes control-point positions from the timeline date, for example with `sin(t)`. — [Apple docs: MeshGradient](https://developer.apple.com/documentation/swiftui/meshgradient.md); [Create with Swift](https://www.createwithswift.com/creating-a-mesh-gradient-in-swiftui/); [Gist (Steppenbeck)](https://gist.github.com/davidsteppenbeck/e9f59cfd90df95d1f56b2987f87d78e6)
- **Throttling TimelineView.** `TimelineView(.animation(minimumInterval:))` and `.periodic` can lower the update rate. One gist uses a 0.75 s minimum interval. — [Gist (webserveis)](https://gist.github.com/webserveis/6950d70ff8a449b7a1b399b16959271d)
- **Reported MeshGradient and TimelineView issues.**
  - A forum post reports poor ScrollView performance and console warnings when `MeshGradient` is combined with `.ignoresSafeArea`. — [Apple Dev Forums 772331](https://www.developer.apple.com/forums/thread/772331)
  - Another reports that a background `TimelineView` made text animations twitch on device (iOS 17/18) but not in the simulator. — [Apple Dev Forums 766948](https://developer.apple.com/forums/thread/766948)
  - A thread asks about the compositing cost of a 12 fps `TimelineView` layer and whether siblings are re-evaluated. It had no answer. — [Apple Dev Forums 850664](https://developer.apple.com/forums/thread/850664)
- **No official benchmarks.** I found no Apple benchmarks or recommended frame rates for animating `MeshGradient`. — [search summary; see sources above]
- **Liquid Glass.**
  - `glassEffect(_:in:)` accepts `some Shape`, so custom shapes work. — [Apple docs: glassEffect(_:in:)](https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:).md)
  - `GlassEffectContainer` can morph individual glass shapes into one another. — [Apple docs: GlassEffectContainer](https://developer.apple.com/documentation/swiftui/glasseffectcontainer.md)
  - Community guidance credits the container with sharing a sampling region and rendering in a single pass. It recommends limiting the number of glass effects on screen and avoiding nesting. — [conorluddy/LiquidGlassReference](https://github.com/conorluddy/LiquidGlassReference); [DEV: GlassEffectContainer](https://dev.to/arshtechpro/understanding-glasseffectcontainer-in-ios-26-2n8p)
  - Known issue: `.clear.interactive()` on a concentric custom shape shows a highlighted capsule artifact. — [Apple Dev Forums 826485](https://developer.apple.com/forums/thread/826485)
- **MTKView frame rate.** MTKView's `preferredFramesPerSecond` defaults to 60. On iPhone, going above 60 Hz requires the Info.plist key `CADisableMinimumFrameDurationOnPhone = true`; frame-rate range hints above 60 Hz are otherwise ignored. iPad Pro doesn't need the key. — [Apple Dev Forums 690806](https://developer.apple.com/forums/thread/690806); [iMore on 120 Hz](https://www.imore.com/apple-clears-120hz-iphone-13-pro-confusion-developers); [Axiom display-performance guide](https://lobehub.com/skills/charleswiltgen-axiom-axiom-display-performance)
- **CAMetalDisplayLink.** `CAMetalDisplayLink.preferredFrameRateRange` is "a range of frequencies your app allows for frame updates," and it governs callback cadence. — [Apple docs: CAMetalDisplayLink.preferredFrameRateRange](https://developer.apple.com/documentation/quartzcore/cametaldisplaylink/preferredframeraterange.md)
- **RealityKit at 120 fps.** A forum thread asks how to get RealityView to 120 fps, which suggests it isn't trivial. — [Apple Dev Forums 762074](https://developer.apple.com/forums/thread/762074)
- **Earlier WWDC material.** WWDC24 has a related session on custom visual effects in SwiftUI with a Metal shaders segment. — [WWDC24 10151](https://developer.apple.com/videos/play/wwdc2024/10151/)

### Inferences
- **Choosing a path for each element type:**

  | Need | Best path | Why |
  |---|---|---|
  | Procedural orb, blob, or glow (no input pixels) | `Rectangle().colorEffect(ShaderLibrary.orb(...))` inside `TimelineView(.animation)` | Cheapest SwiftUI shader path: no layer sampling, so `maxSampleOffset` doesn't matter. |
  | Warping or refracting existing content (fake glass over a gradient or text) | `layerEffect` with the smallest `maxSampleOffset` you can manage | Sampling neighbors forces SwiftUI to render the input to an offscreen layer. |
  | Ambient color field behind the orb | `MeshGradient` (3×3 or 4×4) with audio-driven control points | Declarative and cheap at low point counts, but you can't get sharp highlights, rims, or particles from it. |
  | Thousands of particles or a dotted sphere with per-point physics | `MTKView` (UIViewRepresentable) with a compute kernel and point sprites | Needs persistent GPU buffers between frames, which SwiftUI shaders can't keep because they are stateless. |
  | Multi-pass bloom, feedback trails, temporal effects | `MTKView` / `CAMetalLayer` | Needs render-to-texture between passes. |
  | Glass "button" or controls around the visual | `glassEffect` / `GlassEffectContainer` | System material. Not programmable per pixel, so not suited as the audio-reactive element itself. |
  | 3D scenes | RealityKit / SceneKit | Heavy for one 2D-ish orb; frame-rate control is less direct. |

- **Frame rate.** A SwiftUI `TimelineView(.animation)` follows the display's refresh cadence, so on ProMotion iPhones it can run at up to 120 Hz. **[Unverified, general knowledge; the iOS 26/27 behavior was not confirmed in this session.]** For a voice orb, 60 Hz is often visually sufficient, and capping it saves battery. See section 5.
- **Hybrid approach.** Draw the orb with a `colorEffect` and put an `MeshGradient` or blurred, tinted copy behind it for ambient light. That gives a premium look without a custom Metal pipeline.
- **Noise textures.** Precompute noise into a small tileable texture and pass it with `.image(...)`, as WWDC26 does. Texture fetches are generally cheaper than computing multi-octave procedural noise per pixel at 120 Hz. **[Unverified on A18/A19; follows from the session's design choice.]**
- **Re-renders.** Isolate the `TimelineView` subtree so audio updates don't trigger re-evaluation of unrelated views. Pass audio values as plain `Float` uniforms read from an `@Observable` model inside the timeline closure.

### Gaps
- I found no official per-frame cost comparison of `colorEffect` vs `layerEffect` vs `MTKView`, and no measured numbers for full-screen shaders at 120 Hz on A18/A19.
- No iOS 27-specific new SwiftUI shader APIs were confirmed. The WWDC26 session page does not mention new modifiers, and I didn't verify whether iOS 27 adds features such as compute or multi-pass in SwiftUI.
- Whether `TimelineView(.animation)` honors `CADisableMinimumFrameDurationOnPhone` and runs at 120 Hz in SwiftUI on iOS 26/27 was not confirmed by a primary source.

---

## 2. Rendering techniques for premium looks (shader-level)

### Takeaway
Most premium voice visuals combine a few cheap building blocks in one fragment pass:
1. An analytic 2D or 3D signed distance field (SDF) with smooth-min blending for blobs and metaballs.
2. Domain-warped noise for organic motion.
3. Analytic glow from the SDF: an exponential or Gaussian falloff of distance, with no blur pass.
4. A fresnel or rim term with a cosine palette for iridescence.

Raymarching true 3D SDFs and compute-simulated particles are possible, but they cost far more and should be confined to the element's bounding box.

### Cited Findings
- **Domain warping, as presented at WWDC26.** Sample noise, then sample again at `uv + q`, where `q` is the first sample, and use the result as a displacement offset. Verbatim from session 322:
  ```metal
  half4 n = noiseTex.sample(s, uv);
  float2 q = float2(n.r, n.g);
  n = noiseTex.sample(s, uv + q);
  float2 offset = (float2(n.r, n.g) - 0.5) * 200.0;
  return layer.sample(position + offset);
  ```
  The noise texture is "a pre-computed image of smooth, random values," sampled with `constexpr sampler s(address::repeat, filter::linear)`. — [WWDC26 Session 322](https://developer.apple.com/videos/play/wwdc2026/322)
- **Smooth minimum for metaballs, from Inigo Quilez.**
  - Quadratic polynomial smin, the article's recommended default:
    ```glsl
    float smin(float a, float b, float k){ k *= 4.0; float h = max(k-abs(a-b),0.0)/k; return min(a,b) - h*h*k*(1.0/4.0); }
    ```
  - Exponential version, which is associative:
    ```glsl
    float smin(float a, float b, float k){ float r = exp2(-a/k) + exp2(-b/k); return -k*log2(r); }
    ```
  - `k` is the thickness of the blend region in distance units.
  - A variant also returns a blend factor for mixing materials or colors:
    ```glsl
    vec2 smin(float a,float b,float k){ float h = 1.0-min(abs(a-b)/(4.0*k),1.0); float w=h*h; float m=w*0.5; float s=w*k; return (a<b)? vec2(a-s,m) : vec2(b-s,1.0-m); }
    ```
  — [Inigo Quilez: smooth minimum](https://iquilezles.org/articles/smin/)
- **Apple Intelligence-style glow, approach A (pure SwiftUI layers).** uvolchyk's gist `glow` modifier on `Shape` stacks three layers: a thin stroke at half the line width, then two blurred copies of the full-width stroke, one at the full blur radius and one at half. Each is filled with an angular gradient (blue, purple, red, mint, indigo, pink, back to blue). — [Gist uvolchyk](https://gist.github.com/uvolchyk/d7c29dc3eb47f5e109ccb6cf102a7421)
- **Approach B (radial glow shader).** The same gist's Metal `glow` normalizes positions by view size and uses a Gaussian falloff `exp(-d²)`, scaled by amplitude and smoothsteps on progress. The color is the input color times that intensity. The gist also includes:
  - a `ripple` distortion: a radially displaced decaying sine wave, delayed by distance/speed, which also brightens or darkens the color;
  - a `ParticleCloud`: Metal kernels with a clear pass and a draw pass, where particles move toward a center and respawn at random positions;
  - progress driven by `KeyframeAnimator`.

  — [Gist uvolchyk](https://gist.github.com/uvolchyk/d7c29dc3eb47f5e109ccb6cf102a7421)
- **IntelligenceGlow** (Livsy90) adds an Apple Intelligence-style glowing stroke to any `InsettableShape`, using animated angular gradients and layered blurs. — [Livsy90/IntelligenceGlow](https://uithub.com/Livsy90/IntelligenceGlow)
- **Aurora** (tornikegomareli) renders an Apple Intelligence-style glow with one fragment shader inside a SwiftUI view, with no images or GIFs. It ships six palettes (including an Apple Intelligence preset), three intro styles, and four fill directions. — [Aurora landing](https://tornikegomareli.github.io/aurora-landing/)
- **Inferno shaders worth adapting.**
  - Generators (`colorEffect`): Animated Gradient Fill, Circle Wave, Light Grid, Sinebow, Rainbow Noise.
  - `layerEffect` shaders: Bubble, Warping Loupe, and Variable Blur (a two-pass Gaussian whose radius comes from a mask).

  — [twostraws/Inferno](https://github.com/twostraws/Inferno)

### Inferences
**[Unverified, general graphics knowledge. These are standard Shadertoy-style formulas, not fetched in this session.]**

- **Orb or blob as a 2D SDF in a `colorEffect`** (cheapest premium look):
  - Base shape: `d = length(p) - R`, with `R = R0 * (1 + 0.15*level)`.
  - Organic rim: perturb the radius with angle-dependent noise, `R(θ,t) = R0 + A * fbm(vec2(cos θ, sin θ)*f + t)`. Drive `A` by speech energy and `t` by slow time plus accumulated energy, so motion speeds up while speaking rather than jittering.
  - Metaballs: union 3–6 circles whose centers orbit slowly, using `smin` from above. Use the returned blend factor to mix colors at the seams.
  - Anti-aliased edge: `alpha = 1 - smoothstep(-fw, fw, d)`, where `fw` ≈ 1 px in uv units. Passing `1/size` from Swift is more reliable than relying on derivatives.
- **Glow or bloom in one pass.** Compute glow analytically from the same SDF instead of blurring:
  - `glow = exp(-max(d,0) * k)`, or a Lorentzian `1/(1 + (d/w)^2)`; or the Gaussian `exp(-d²)` used in the uvolchyk gist.
  - Final color: `col = core*fill + glowColor*glow*intensity`.
  - This removes the need for a multi-pass bloom, which SwiftUI shaders can't do because there is no render-to-texture.
- **Fresnel rim on a 2D orb.** Fake a sphere normal from the 2D position inside the disk: `n = vec3(p/R, sqrt(1 - dot(p/R,p/R)))`, `V = (0,0,1)`.
  - Fresnel: `F = pow(1 - saturate(dot(n,V)), P)` with `P` ≈ 2–5.
  - Schlick form: `F = F0 + (1-F0)*pow(1 - cosθ, 5)`.
  - Use `F` to brighten the rim and to feed the iridescence term.
- **Iridescence or thin film (cheap approximation).** Use Quilez's cosine palette `col(t) = a + b*cos(2π(c*t + d))`, with `t = F*thickness + time*0.05 + noise`. A physically based thin-film model (Belcour–Barla 2017) is overkill for a UI orb.
- **Fake refraction or glass:**
  - Over existing content: use a `layerEffect` with `layer.sample(position + n.xy * strength * (1-F))`.
  - Over procedural content: offset the uv you feed into your own color function. This stays in `colorEffect`, with no layer sampling.
  - Chromatic aberration: sample R, G and B with slightly different offsets.
  - Keep `maxSampleOffset` equal to the largest offset you actually use.
- **Raymarched 3D SDF blobs.**
  - Sphere-trace about 32–64 steps with `smin` of a few spheres, and a normal from the tetrahedral gradient (4 SDF evaluations).
  - Shade with fresnel, a fake environment from the cosine palette, and specular.
  - Cost scales with pixels × steps, so render it only in the orb's frame (for example 300×300 pt ≈ 900×900 px at 3×), not full screen.
  - Early exit when the ray misses the bounding sphere.
  - Consider rendering at reduced resolution, for example a smaller frame scaled up. That's cheap for a soft, blurry orb.
- **Dotted sphere (NCS-style point displacement):**
  - Points: generate N points on a Fibonacci lattice, `y_i = 1 - 2(i+0.5)/N`, `r_i = sqrt(1-y_i²)`, `φ_i = i·π(3-√5)`.
  - Displacement: move each point along its normal by `disp = A*noise3(p*f + t) + bandEnergy[k(i)]`, mapping latitude or index to FFT bands.
  - Draw: rotate, project, and draw as point sprites with size and brightness by depth. In `MTKView`, use a vertex shader over the point buffer with `[[point_size]]`. In SwiftUI, `Canvas` works for N ≲ 1–2k dots. A `colorEffect` that loops over dots per pixel is O(pixels × dots) and is not advised.
- **Particle fields.**
  - Below about 1–2k particles, `Canvas` with CPU updates (or SIMD + Accelerate) is fine.
  - For 10k–100k particles, use a compute kernel to update position and velocity buffers each frame, then draw point sprites with additive blending in an `MTKView`. The uvolchyk `ParticleCloud` follows this clear-then-draw kernel pattern.
  - Drive emission rate and outward velocity by onsets, and swirl strength by sustained energy.
- **Apple Intelligence screen-border glow:**
  - Rounded-rect SDF: `q = abs(p) - b + r; d = length(max(q,0)) + min(max(q.x,q.y),0) - r`.
  - Hue by angle: `h = atan2(p.y,p.x)/(2π) + t*speed` into a palette.
  - Inner glow: `exp(-abs(d)*k)`, masked to the inside.
  - Add a second blurred, wider band whose width is driven by audio level.
  - The cheap alternative is the SwiftUI-only version: `RoundedRectangle.stroke(AngularGradient)` stacked three times with increasing blur, as in the uvolchyk gist and IntelligenceGlow. Rotate the gradient's angle over time and scale blur and line width with level.
  - SwiftUI `.blur` on large layers isn't free, so fewer layers and smaller radii are cheaper.

### Gaps
- I found no measured cost of raymarched SDF orbs or compute particle systems on A18/A19 at 120 Hz.
- The internal implementation of Apple's own Siri, Apple Intelligence glow and Liquid Glass shaders is not public. No official Apple code was found.
- Thin-film, fresnel, Fibonacci-sphere and sdRoundBox formulas are from general knowledge. I didn't fetch primary sources this session, so look up Quilez's articles on palettes, warp and distfunctions2d to confirm the exact code.

---

## 3. Audio analysis for visuals (AVAudioEngine, Accelerate/vDSP)

### Takeaway
The iOS 27 `installAudioTap(onBus:bufferSize:format:tapProvider:)` gives Sendable, read-only buffers (`AVReadOnlyAudioPCMBuffer`) that are safe to process off the audio thread. The catch: its buffer size is limited to 100–400 ms, about 10 callbacks per second at best. That is too coarse to drive 60–120 fps motion directly.

Either split each buffer into short analysis hops (about 10–20 ms) and replay or interpolate them on the render clock, or use `AVAudioSinkNode` for real-time-context, low-latency blocks. Then compute RMS and band energies with vDSP, convert to dB, normalize, and smooth with asymmetric attack and release before mapping to visual parameters.

### Cited Findings
- **`installAudioTap` (iOS 27).** Signature: `func installAudioTap(onBus bus: AVAudioNodeBus, bufferSize: AVAudioFrameCount, format: AVAudioFormat?, tapProvider: @escaping @Sendable (AVReadOnlyAudioPCMBuffer, AVAudioTime) -> Void) throws`. It is available on iOS, iPadOS, macOS, tvOS, visionOS and watchOS 27.0 and later.
  - `bufferSize`: "The requested size of incoming buffers in sample frames. Supported range is [100, 400] ms."
  - Discussion: "installs a tap that receives read-only buffers safe for concurrent use. The tap block is sendable and can be safely called from any isolation domain. Only one tap may be installed on any bus. Taps may be safely installed and removed while the engine is running."

  — [Apple docs: installAudioTap](https://developer.apple.com/documentation/avfaudio/avaudionode/installaudiotap(onbus:buffersize:format:tapprovider:).md)
- **`AVReadOnlyAudioPCMBuffer` (iOS 27).** A "read-only, Sendable audio buffer for safe concurrent access."
  - Initializers: `init(copying:)`, `init(format:frameCapacity:initializingWith:)`, and `init(unsafeRetaining: sending AVAudioPCMBuffer)`, which retains without copying.
  - Properties: `format`, `frameCapacity`, `frameLength`, `stride`.
  - Access: `channelData(_:) -> ChannelData`, `withUnsafeAudioBufferList(_:)`.
  - Conforms to `Sendable`.

  — [Apple docs: AVReadOnlyAudioPCMBuffer](https://developer.apple.com/documentation/avfaudio/avreadonlyaudiopcmbuffer.md)
- **`AVAudioSinkNode` (WWDC19).** It is the counterpart to `AVAudioSourceNode` and is useful "when the input needs to be processed in real time, since a regular tap does not run in a real-time context." In real-time mode the block must not do "memory allocations, call to lib dispatch, or blocking on a mutex." — [WWDC19 Session 510](https://developer.apple.com/videos/play/wwdc2019/510); [Apple docs: AVAudioSinkNode](https://developer.apple.com/documentation/avfaudio/avaudiosinknode.md)
- **Lower latency than a tap.** A forum post says the block-based approach allows "shorter (lower latency) audio sample buffers from the microphone than using an installTap()." Audio Unit render callbacks can go down to a few milliseconds. — [Apple Dev Forums 22530](https://developer.apple.com/forums/thread/22530); [Stack Overflow archive](https://kaweah.freedombox.rocks/kiwix/stackoverflow.com_en_all_2023-11/questions/63343396/can-i-send-sound-buffers-received-using-avaudiosinknode-to-be-rendered-in-real)
- **Reported tap problems on iOS 18:**
  - On iPhone 16e (iOS 18.4.1–18.7.1), the `installTap` callback stops after a phone-call interruption. — [Apple Dev Forums 805735](https://developer.apple.com/forums/thread/805735)
  - Input taps sometimes deliver all-zero buffers with a valid format and no error. — [Apple Dev Forums 836713](https://developer.apple.com/forums/thread/836713); [771048](https://developer.apple.com/forums/thread/771048)
- **Apple's spectrogram sample.** "Visualizing sound as an audio spectrogram" (Accelerate) captures mic audio and uses vDSP and vImage. It applies a DCT to audio samples, converts Int16 to Float with `vDSP.convertElements(of:to:)`, and uses a Hann window. A companion sample, "Computing the Mel Spectrum Using Linear Algebra," builds a real-time mel spectrogram via matrix multiplication. — [Apple: Visualizing sound as an audio spectrogram](https://developer.apple.com/documentation/accelerate/visualizing-sound-as-an-audio-spectrogram.md); [Apple Accelerate sample code](https://developer.apple.com/accelerate/sample-code)
- **Open-source FFT pipelines:**
  - aure/FFT: real-time FFT of audio input with Swift and Metal, based on tempi-fft. — [aure/FFT](https://github.com/aure/FFT)
  - rtaudio: vDSP 1024-sample FFTs and Metal on macOS, avoiding SwiftUI in the render path to reduce overhead. — [rtaudio](https://gh.r-mj.com/ZephyrCodesStuff/rtaudio)

### Inferences
**[Unverified, standard DSP practice. API names are from general Accelerate knowledge.]**

**Capture architecture:**
- **Option A: iOS 27 tap.** Install `installAudioTap` with the minimum 100 ms buffer, which is 4800 frames at 48 kHz. Inside the Sendable closure, split the buffer into hops of 480–960 samples (10–20 ms) and compute features for each hop. Push timestamped features (from `AVAudioTime`) into a small lock-free ring or an actor.

  The render loop then plays them back with a constant delay of about one buffer plus a margin, so each displayed frame shows the feature for "now − latency." This gives smooth 100 Hz feature resolution at the cost of about 100–150 ms visual lag. That is usually acceptable for an orb, because humans tolerate audio-to-visual lag better than jitter, but it should be tested.

  Because the buffer is Sendable, analysis can run on a background task without copying.
- **Option B: `AVAudioSinkNode` on the input.** It gets IO-sized blocks (about 5–20 ms). Compute RMS in the real-time block with preallocated buffers and write the scalar into an atomic. This is the lowest latency; it allows no allocation or locks.
- **Option C: iOS 26 fallback.** Use the classic `installTap(onBus:bufferSize:format:block:)` with the same split-into-hops strategy, plus `#available(iOS 27, *)` for the new API.
- **Interruptions and silent buffers.** Handle `AVAudioSession` interruption and route-change notifications and restart the engine, given the reported iOS 18 tap stalls. Treat runs of all-zero buffers as "no signal": fade the visual to idle rather than freezing.

**Feature extraction per hop (vDSP):**
- **Level:** `rms = vDSP.rootMeanSquare(hop)`, and `peak = vDSP.maximumMagnitude(hop)`.
- **dB normalization:** `db = 20*log10(max(rms, 1e-7))`, then `level = clamp((db - floor) / (ceil - floor), 0, 1)`, with floor about −60 dBFS and ceil about −10 dBFS. Better, make the floor adaptive: track a slow noise-floor estimate (a minimum follower over about 2–3 s) and set `floor = noiseFloor + 6 dB`, so background noise doesn't animate the orb.
- **FFT:**
  - Use `vDSP.FFT` (or `vDSP.DiscreteFourierTransform`) of size 1024 at 48 kHz, which gives about 46.9 Hz bins over about 21 ms, with a Hann window and a hop of 512.
  - Magnitudes: `vDSP.squareMagnitudes` then `vDSP.convert(power:toDecibels:zeroReference:)`.
  - Aggregate bins into 4–8 log-spaced or mel bands. Apple's mel-spectrum sample shows a matrix-multiply filterbank, which is efficient with `vDSP_mmul` or BLAS.

**Bands for speech** (approximate, from speech-acoustics knowledge):

| Band | Range | What it captures |
|---|---|---|
| Low / fundamental | ~80–300 Hz | Voice pitch fundamental |
| Low-mid | ~300–1000 Hz | First formant, vowel body |
| Mid | ~1–3 kHz | Second formant, intelligibility |
| High / sibilance | ~3–8 kHz | Fricatives such as s, sh, f |

Mapping suggestion:
- low and low-mid energy → scale and "breathing" of the orb
- mid → rim turbulence and noise amplitude
- high → sparkle, particle emission, rim brightness

**Smoothing so motion feels organic** (one-pole envelope with separate attack and release):
```
coefA = exp(-dt / tauAttack)   // tauAttack ≈ 0.03–0.08 s
coefR = exp(-dt / tauRelease)  // tauRelease ≈ 0.25–0.6 s
env = x > env ? coefA*env + (1-coefA)*x : coefR*env + (1-coefR)*x
```
- Run this on the render clock using real `dt` (from `TimelineView` dates or display-link timestamps), so smoothing is frame-rate independent at 60 or 120 Hz.
- For shape parameters, add a critically damped spring (second order) on top. Springs give overshoot-free yet "alive" motion. SwiftUI's `Spring` type can compute this, or hand-roll `x'' = -ω²(x - target) - 2ωx'`.
- Apply a perceptual curve: `pow(level, 0.5–0.7)` makes quiet speech visible without loud speech saturating.

**Onset detection:**
- Compute spectral flux per hop: `flux = Σ max(0, |X_t[k]| - |X_{t-1}[k]|)` over 300 Hz–4 kHz.
- Use an adaptive threshold (median or mean of the last ~0.5 s × 1.3–1.5) and a refractory period of 80–120 ms.
- On an onset, fire a transient impulse (ripple, particle burst, brief glow pulse) that decays over about 150–300 ms. This makes syllables "pop" without making the steady state jittery.
- A simpler alternative is level-derivative onsets: `d(level)/dt` above a threshold.

**Mapping principles:**
- Keep idle motion always on: slow noise time plus breathing at about 0.2 Hz. Audio modulates it but never fully drives it, so silence doesn't look dead.
- Map audio to amplitude and speed of internal motion, not to raw positions.
- Accumulate a "phase" variable (`phase += dt * (baseSpeed + k*env)`) and feed the phase into noise, so louder speech flows faster without discontinuities.
- Clamp outputs and avoid per-frame random jumps.
- Use voice activity, for example from the Speech or SoundAnalysis frameworks, or simply `level > threshold` held for 150 ms, to switch between "listening" and "idle" palettes with a 300–500 ms crossfade.

**Passing values to the GPU:**
- In SwiftUI shaders, pass `level`, `bands` (up to about 8 floats via `.float(...)`, or a `.floatArray(...)` argument) and `phase` each frame.
- In `MTKView`, write a small uniforms struct per frame. Triple-buffer it to avoid CPU/GPU contention.

### Gaps
- The `ChannelData` enum layout of `AVReadOnlyAudioPCMBuffer` (float vs int, interleaved vs not) wasn't read in detail.
- Whether the legacy `installTap` has the same [100, 400] ms limit wasn't confirmed this session. It is widely reported that iOS ignores small tap buffer sizes, but that wasn't verified here.
- No primary source was fetched for recommended speech band edges. Values above are standard speech-acoustics ranges, not verified this session.
- No iOS 27-specific reports of how `installAudioTap` behaves on real devices were found.

---

## 4. Monochrome rendering (white-on-black and black-on-white)

### Takeaway
Monochrome looks rich when it builds a high-dynamic-range luminance field (core, rim, glow, grain) and tone-maps it, rather than clipping. On black, light should add (additive or `plusLighter`-style accumulation). On white, the same field should be inverted into ink: subtract or multiply darkness rather than "glowing" white on white. Correct alpha handling (premultiplied, alpha multiplied into color) avoids gray fringes at the edges.

### Cited Findings
- **Alpha in Inferno.** The README's only note on alpha is that final color values are "multiplied by the original color's alpha, just to make sure we get very smooth edges." In other words, it outputs premultiplied-style colors for clean edges. — [twostraws/Inferno](https://github.com/twostraws/Inferno)
- **Glow by multiplication.** The uvolchyk radial glow shader outputs the input color multiplied by a Gaussian intensity, a multiplicative glow that works with premultiplied color. — [Gist uvolchyk](https://gist.github.com/uvolchyk/d7c29dc3eb47f5e109ccb6cf102a7421)

### Inferences
**[Unverified, general graphics knowledge. SwiftUI's exact color-space and premultiplication contract for shader outputs was not read from Apple docs this session.]**

- **Premultiplied output.** Return `half4(rgb * a, a)` from SwiftUI shaders. Returning non-premultiplied color with fractional alpha produces bright or dark halos at anti-aliased edges and over glows.
- **White on black:**
  - Compute `L = core + rim*F + glow`, which may exceed 1.
  - Tone-map with `L' = 1 - exp(-L*exposure)` so overlaps saturate gracefully instead of hard clipping.
  - Add subtle inner detail (domain-warped noise at 3–8% contrast) and a faint grain.
  - Composite: output `half4(L', L', L', L')`, which is premultiplied white with alpha = luminance. With `.blendMode(.plusLighter)` or `.screen` over black, overlapping orbs and particles brighten naturally.
- **Black on white:**
  - Normal-blend black ink: output `half4(0,0,0, L')`, then compose normally or with `.blendMode(.multiply)`.
  - A soft "glow" becomes a soft shadow or halo of graphite. Use a wider, lower-opacity falloff than on black, because dark halos read heavier.
  - Optionally add a very light inner highlight (white rim at 10–20%) to keep volume.
  - Avoid additive blending on white: everything clips to white and disappears.
  - `.plusDarker` is the dark analog of `plusLighter` for overlapping dark particles.
- **Banding.** Smooth radial gradients in 8-bit sRGB band visibly, especially dark gray on black. Add ordered or blue-noise dithering of ±0.5/255 before output. With `MTKView`, consider a `.rgba16Float` drawable or an extended-range color space.
- **Contrast.** Keep the brightest core at about 95–100% and the background exactly 0 (or 100% on white). Get depth from soft falloff and from motion of the inner noise, not from color.
- **Light and dark mode.** One shader with a `mode` uniform (0 = light-on-dark, 1 = dark-on-light) can switch the composition: `out = mode==0 ? half4(L',L',L',L') : half4(0,0,0,L')`. Read `@Environment(\.colorScheme)` in SwiftUI.

### Gaps
- I didn't confirm from Apple docs whether SwiftUI `colorEffect` / `layerEffect` inputs and outputs are premultiplied, or in which color space (extended sRGB vs Display P3) they are evaluated.
- No public source was found on how Apple renders its monochrome Siri or Apple Intelligence states.

---

## 5. Accessibility, battery/thermal, and ProMotion

### Takeaway
Treat frame rate and shader complexity as adjustable:
- 120 Hz only while actively capturing voice, and only if it measurably improves the look;
- 30–60 Hz or static when idle;
- a static or slow-fade fallback under Reduce Motion, Low Power Mode, or elevated thermal state.

On iPhone, high refresh needs `CADisableMinimumFrameDurationOnPhone`. Other system settings can still cap you.

### Cited Findings
- **Unlocking 120 Hz.** On iPhone, `CADisableMinimumFrameDurationOnPhone = true` in Info.plist is needed for above-60 Hz rendering. Without it, frame-rate range hints above 60 Hz are ignored. — [Apple Dev Forums 690806](https://developer.apple.com/forums/thread/690806); [Axiom display-performance guide](https://lobehub.com/skills/charleswiltgen-axiom-axiom-display-performance)
- **The key isn't always enough.** One developer reported it had no effect: the Xcode GPU report stayed capped at 60 fps. Another found the key missing from the plist was the cause. — [Apple Dev Forums 801141](https://developer.apple.com/forums/thread/801141); [Apple Dev Forums 761616](https://developer.apple.com/forums/thread/761616)
- **Other settings cap the frame rate,** including the "Limit Frame Rate" accessibility setting, Low Power Mode, and Adaptive Power mode on newer iPhones. — [Axiom display-performance guide](https://lobehub.com/skills/charleswiltgen-axiom-axiom-display-performance)
- **`CAMetalDisplayLink.preferredFrameRateRange`** lets you declare the range of acceptable update frequencies. — [Apple docs](https://developer.apple.com/documentation/quartzcore/cametaldisplaylink/preferredframeraterange.md)
- **Throttling `TimelineView`.** `TimelineView(.animation(minimumInterval:))` / `.periodic` can throttle SwiftUI updates. — [Gist (webserveis)](https://gist.github.com/webserveis/6950d70ff8a449b7a1b399b16959271d)
- **Liquid Glass.** Guidance is to limit simultaneous glass effects and profile with Instruments. — [conorluddy/LiquidGlassReference](https://github.com/conorluddy/LiquidGlassReference)

### Inferences
**[Unverified, general iOS knowledge. These API names are standard, but I didn't re-read their docs this session.]**

- **Reduce Motion.** Read `@Environment(\.accessibilityReduceMotion)`. When it's on:
  - replace continuous noise motion and particles with a static orb whose brightness or opacity crossfades with voice level (opacity and brightness changes are generally acceptable under Reduce Motion; large scaling and swirling are not);
  - disable onset bursts and ripples;
  - lower the update rate.
- **Reduce Transparency.** Respect `@Environment(\.accessibilityReduceTransparency)` for glass and glow layers by using solid fills.
- **Power and thermal:**
  - Observe `ProcessInfo.processInfo.isLowPowerModeEnabled` (notification `NSProcessInfoPowerStateDidChange`) and `ProcessInfo.processInfo.thermalState` (`.nominal/.fair/.serious/.critical`).
  - Step down by tier: 120 → 60 → 30 Hz, fewer raymarch steps or octaves, fewer particles, smaller render size.
- **Pause when not visible.** Pause the `TimelineView` (use the `paused:` parameter of the `.animation` schedule) or stop the `MTKView` (`isPaused = true`) whenever the visual is offscreen, the app is backgrounded (`scenePhase`), or capture is idle.
- **Audio duty cycle.** Stop the `AVAudioEngine` when not capturing. The mic engine itself is a significant battery cost.
- **Per-frame budget at 120 Hz.** Frame time is 8.3 ms, shared with SwiftUI layout and the compositor. Practical rules:
  - keep the shader to one pass;
  - keep it to a bounded region (the orb's frame plus glow margin, not the whole screen, unless it is a border glow);
  - use `half` where possible;
  - avoid loops longer than about 32–64 iterations;
  - precompute noise into textures.
- **Profiling.** Measure with Instruments' "Animation Hitches" and "Metal System Trace", and the Xcode GPU frame report, on an actual A18 device, both cold and after 10 minutes of capture for thermals.
- **ProMotion and SwiftUI.** With `CADisableMinimumFrameDurationOnPhone` set, SwiftUI animations and `TimelineView(.animation)` can benefit from 120 Hz. You can't set a per-view preferred rate in pure SwiftUI the way you can with `CADisplayLink`/`MTKView`. For explicit control, host an `MTKView` or drive state from a `CADisplayLink` with `preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 60)`. **[Unverified: confirm whether iOS 26/27 SwiftUI added per-view frame-rate hints.]**

### Gaps
- No Apple primary doc fetched confirming the `CADisableMinimumFrameDurationOnPhone` semantics on iOS 26/27 (only forum and community sources).
- No measured battery or thermal numbers for continuous shader animation plus a live mic on A18/A19.
- No Apple HIG guidance specific to audio-reactive visuals under Reduce Motion was found this session.

---

## 6. Open-source references

### Takeaway
No single public repo combines everything (SwiftUI + Metal shader orb + vDSP FFT + mic). Build from these parts:
- Inferno: shader patterns and SwiftUI wiring;
- Aurora or IntelligenceGlow, or the uvolchyk gist: Apple Intelligence-style border and edge glow;
- metasidd/Orb: a pure-SwiftUI Siri-like orb to compare against;
- aure/FFT and Apple's spectrogram sample: the Accelerate and Metal audio pipeline;
- Quilez articles and Shadertoy: SDF and noise math to port.

### Cited Findings
**SwiftUI shader collections and glow effects:**
- **twostraws/Inferno.** MIT-licensed SwiftUI Metal shaders. It has generators, color effects, distortions (Wave, Water, Relative Wave), layer effects (Bubble, Loupe, Variable Blur, Emboss) and transitions. Install by copying `.metal` files. The sample needs iOS 17, and a macOS sandbox app is included. — [GitHub](https://github.com/twostraws/Inferno)
- **Aurora (tornikegomareli).** Apple Intelligence-style glow from a single fragment shader, with palettes and intro styles, distributed as a Swift package. — [Aurora landing](https://tornikegomareli.github.io/aurora-landing/)
- **IntelligenceGlow (Livsy90).** Apple Intelligence-style glowing stroke for any `InsettableShape`, built from angular gradients and layered blurs. — [uithub mirror](https://uithub.com/Livsy90/IntelligenceGlow)
- **GlowGetter (Feversun/Aeastr).** A `.glow(_:)` modifier rendered with Metal. Its README warns it may not be ideal for high-performance or production rendering. — [GitHub](https://github.com/Feversun/GlowGetter)
- **uvolchyk gist.** Includes:
  - a glow modifier (layered angular-gradient strokes plus blur);
  - a Gaussian radial glow shader and a ripple shader;
  - a particle-cloud Metal kernel;
  - a reactive control driven by `KeyframeAnimator` and `DragGesture`.

  — [Gist](https://gist.github.com/uvolchyk/d7c29dc3eb47f5e109ccb6cf102a7421)

**Orbs and Siri-style animations:**
- **metasidd/Orb.** MIT-licensed Swift package that renders a Siri-inspired orb in SwiftUI. No Metal code was evident; release 0.2 mentions FPS optimizations. — [Ecosyste.ms](https://awesome.ecosyste.ms/projects/github.com%2Fmetasidd%2FOrb); [Swift Package Registry](https://swiftpackageregistry.com/metasidd/Orb)
- **metasidd/Prototype-Siri-Screen-Animation.** About 370 stars. — [relatedrepos](https://relatedrepos.com/gh/metasidd/Prototype-Siri-Screen-Animation)

**Audio pipelines and visualizers:**
- **aure/FFT.** Real-time FFT of audio input in Swift and Metal (iPad), based on tempi-fft. — [GitHub](https://github.com/aure/FFT)
- **MuVis.** Open-source SwiftUI music visualizer using music files or the mic. — [GitHub](https://github.com/Keith-43/MuVis)
- **rtaudio.** macOS system-audio visualizer using vDSP 1024-point FFTs and Metal, without SwiftUI in the render path. — [mirror](https://gh.r-mj.com/ZephyrCodesStuff/rtaudio)
- **AudioKit + SwiftUI visualizer tutorial** (Matt54's project). — [AudioKit Pro tutorial](https://audiokitpro.com/audiovisualizertutorial/)
- **Create with Swift live waveform.** Built with AVFoundation, Accelerate and Swift Charts; not Metal. — [Create with Swift](https://www.createwithswift.com/creating-a-live-audio-waveform-in-swiftui/)
- **Apple's Accelerate samples:** "Visualizing sound as an audio spectrogram" and "Computing the Mel Spectrum Using Linear Algebra." — [Apple](https://developer.apple.com/documentation/accelerate/visualizing-sound-as-an-audio-spectrogram.md); [Apple Accelerate samples](https://developer.apple.com/accelerate/sample-code)

**Metal learning and alternatives:**
- **gnikoloff/apple-metal-sketch-dojo.** Metal rendering experiments. — [GitHub](https://github.com/gnikoloff/apple-metal-sketch-dojo)
- **DiffusionKit.** Claims to be a faster `MeshGradient` alternative on iOS 14+. The claims are unverified. — [GitHub](https://github.com/sunimp/DiffusionKit)
- **Liquid Glass reference.** Community reference for `glassEffect` and `GlassEffectContainer`. — [conorluddy/LiquidGlassReference](https://github.com/conorluddy/LiquidGlassReference)

**Math references:**
- **Inigo Quilez, smooth minimum.** smin variants for metaballs and material blending. — [iquilezles.org](https://iquilezles.org/articles/smin/)

**Apple sessions:**
- **WWDC26 322, "Compose advanced graphics effects with SwiftUI."** Covers layerEffect, noise-texture domain warping, and TimelineView-driven shaders. It also suggests gyroscope input "instead of audio" as an extension, which implies the sample pipeline is input-driven. — [WWDC26 322](https://developer.apple.com/videos/play/wwdc2026/322)
- **WWDC24 10151, custom visual effects in SwiftUI.** — [WWDC24 10151](https://developer.apple.com/videos/play/wwdc2024/10151/)
- **WWDC19 510.** Covers `AVAudioSinkNode` and `AVAudioSourceNode`. — [WWDC19 510](https://developer.apple.com/videos/play/wwdc2019/510)

### Inferences
- **Suggested starting stack for the Thryve voice screen:**
  1. A capture service using the iOS 27 `installAudioTap` with a `#available` fallback to `installTap`, producing hop-level RMS and 4–6 speech bands through vDSP.
  2. An `@Observable` "VoiceVisualState" holding level, bands, onset impulse and accumulated phase, smoothed on the render clock.
  3. A `TimelineView(.animation)` with a `Rectangle().colorEffect(ShaderLibrary.voiceOrb(...))` drawing an SDF orb with `smin` metaballs, analytic glow and a fresnel rim, in a monochrome mode.
  4. Optional Apple Intelligence-style border via the Aurora or IntelligenceGlow approach.
  5. Move to `MTKView` only if a compute-particle or dotted-sphere variant is chosen.
- **Shadertoy search terms worth porting** (searched by name, not verified this session): "metaballs 2D", "domain warping" (Quilez), "siri orb", "glowing orb", "fibonacci sphere", "audio reactive".
  - Port by translating GLSL `vec2/vec3/fract/mix/mod` to Metal `float2/float3/fract/mix/fmod` (note that `mod` semantics differ for negatives).
  - Replace `iResolution`/`iTime` with your uniforms, and the `fragCoord` origin with SwiftUI's top-left `position`.
  - Check each shader's license: Shadertoy defaults to CC BY-NC-SA 3.0 unless stated otherwise, which is incompatible with commercial use. **[Unverified this session; confirm per shader.]**

### Gaps
- I couldn't fetch full READMEs for Aurora, metasidd/Orb, IntelligenceGlow or MuVis, so licenses (except Inferno MIT and metasidd/Orb MIT) and exact implementation details are partly unconfirmed.
- I found no public repo that recreates the ChatGPT voice-mode orb in SwiftUI/Metal, and no Metal port of an NCS-style dotted sphere.
- The roughly 2,871-star "Metal shader collection for SwiftUI" mentioned in one search aggregate couldn't be identified by name.
