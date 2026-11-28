# Voice orbs and audio-reactive listening indicators beyond the big assistants (2024 to late 2026)

Scope note: research done 2026-11-28. Target context is a minimalist iOS app with one central element, white on black (dark) and black on white (light). Each family's monochrome suitability is covered in the monochrome section below and touched on throughout. Several primary pages (ElevenLabs UI orb docs, ui.elevenlabs.io) returned HTTP 429 and could not be read directly. Facts about them come from secondary mirrors and are flagged as such.

---

## What distinct visual families exist (shape, material, motion, color)?

### Takeaway
The field has settled into roughly ten recognizable families. Four are "soft/volumetric": the shader gradient orb or aura, the cheap CSS blurred gradient orb, the deforming/displaced sphere (including metaball and ferrofluid looks), and the particle/dotted sphere. Four are "graphic/discrete": discrete bars or the pill, the dot-matrix grid, radial bars or rings, and line waveforms (Siri-wave). The last two are the screen-edge glow and the character/face. The voice-AI platforms (ElevenLabs, LiveKit, Pipecat, assistant-ui, orb-ui) all ship one shader "aura/orb" option next to several graphic options. Dictation and meeting apps (Wispr Flow, Granola, Superwhisper) almost all use small discrete bars or waveforms, not orbs.

### Cited Findings

**Family 1: Shader gradient orb / "aura" / energy field (WebGL).** A soft, glowing, volumetric sphere or field. Noise-driven color and luminance flow inside it, and it is usually colored.
- ElevenLabs UI describes its Orb as a "3D animated orb built with Three.js" that is audio-reactive and can visualize agent states with custom colors. It is installed via shadcn, and usage passes `agentState`, `colors` and `seed` props. (Secondary mirror; the primary docs page returned 429.) — [21st.dev ElevenLabs orb mirror / search summary](https://21st.dev/@ElevenLabs/components/orb)
- ElevenLabs UI (open-source audio and agent components on shadcn/ui) was announced on October 7, 2025, and the repo is MIT-licensed. — [ElevenLabs blog](https://elevenlabs.io/blog/elevenlabs-ui); [GitHub elevenlabs/ui](https://github.com/elevenlabs/ui)
- LiveKit Agents UI's `AgentAudioVisualizerAura` is described as "a glowing, organic aura" / "undulating energy field, designed in partnership with Unicorn Studio, powered with a custom WebGL shader." — [LiveKit Agents UI product page](https://livekit.com/products/agents-ui); [LiveKit prebuilt visualizers doc](https://docs.livekit.io/frontends/agents-ui/audio-visualizer/prebuilt.md)
- Aura props: `size` (icon/sm/md/lg/xl, default lg), `state` (default `connecting`), `color` (hex, default `#1FD5F9`), `colorShift` (default 0.05), `themeMode` (light/dark), `audioTrack`, `volume`. — [LiveKit Aura reference](https://docs.livekit.io/reference/components/agents-ui/component/agent-audio-visualizer-aura.md)
- Pipecat's `PlasmaVisualizer` is "a WebGL-powered plasma effect that responds to audio input in real time." It requires WebGL and Three.js. The lower-level `Plasma` component exposes `intensity` (0.5 to 3.0) and `radius` (0.5 to 3.0). — [Pipecat Voice UI Kit, Plasma](https://voiceuikit.pipecat.ai/visualizers/plasma-visualizer)
- assistant-ui's Orb element is a WebGL-animated `<canvas>`. The `variant` palette is `default` (grey), `blue`, `violet` or `emerald`, and "color is independent of state." — [assistant-ui Orb](https://www.assistant-ui.com/elements/orb)
- React Bits' Orb uses OGL (a light WebGL library) with a full-screen triangle and a fragment shader. The listed props are `hoverIntensity`, `rotateOnHover`, `hue` and `forceHoverState` (the listing is an unofficial mirror). — [21st.dev React Bits Orb mirror](https://21st.dev/@deleted_reactbits/components/orb); [shadcn.io Orb](https://www.shadcn.io/background/orb)
- orb-ui's "cloud" theme is "an atmospheric sphere that scales inversely to listening and moves faster while speaking." — [GitHub alexanderqchen/orb-ui](https://github.com/alexanderqchen/orb-ui)
- 21st.dev groups community orbs into microphone-reactive ([Voice Powered Orb](https://21st.dev/@isaiahbjork/components/voice-powered-orb), WebGL; [Siri Orb](https://21st.dev/@m.umairwaheedansari/components/siri-orb)), model-reactive / "ambient" ([Neon Orbs](https://21st.dev/@minhxthanh/components/neon-orbs)) and purely decorative "orbiting circles" rings. — [21st.dev, "Voice Orbs: What an AI Product Uses Instead of a Spinner"](https://21st.dev/blog/react-voice-orb-components)

**Family 2: Cheap CSS blurred gradient orb (conic or radial gradients plus blur).** The low-cost version of Family 1.
- Adrián Álvarez's orb is "Two conic gradients spinning inside a clipped circle, under a blur." The layers run 9s and 5.8s in opposite directions so they never resync, the second layer sits at opacity 0.6, and the palette runs cyan, blue, violet, indigo. He suggests `mix-blend-mode: screen` on dark backgrounds to make the orb look "lit rather than painted." — [Adrián Álvarez, The AI voice orb](https://www.adrian-alvarez.com/en/snippets/ai-voice-orb/)
- 21st.dev classes this as "CSS/SVG: gradient, blur, and scale animation. 'Effectively free.'" — [21st.dev blog](https://21st.dev/blog/react-voice-orb-components)

**Family 3: Discrete bars / "pill" (few vertical bars, often center-weighted, inside a capsule).** This is the default for dictation and meeting apps.
- Wispr Flow's "Flow Bar" is "a small floating bubble" showing resting, recording or processing states. It can be docked to a screen edge. — [Wispr Flow docs](https://docs.wisprflow.ai/articles/1790396454-move-and-dock-the-flow-bar-on-desktop)
- A rebuild of the Wispr-style pill (Freestyle) uses 14 bars drawn as plain SVG lines in a 260 × 90 px frameless transparent window. — [Freestyle, How we built Wispr Flow's floating pill](https://freestylevoice.com/blog/floating-pill)
- A third-party Wispr-style PR describes "an icon-less black capsule with ten centre-weighted white bars that grow with input level and sit as dots during silence." It is an imitation, not Wispr's spec. — [GitHub softmaxe/whisper PR #73](https://github.com/softmaxe/whisper/pull/73)
- Granola shows "three vertical green dancing bars at the bottom of your screen when transcription is active." On iOS the "dancing bars respond to mic input" and a duration timer runs. Clicking the bars opens the live transcript, and a floating indicator appears on the right when another app has focus. — [Granola help: transcription](https://help.granola.ai/article/transcription); [Granola docs iOS transcription](https://docs.granola.ai/help-center/ios/transcription)
- Superwhisper's mini recording window shows a live microphone waveform while recording, with a stop button on hover. — [Superwhisper docs, Recording window](https://superwhisper.com/docs/get-started/interface-rec-window)
- LiveKit `AgentAudioVisualizerBar` draws vertical bars with a `barCount` prop (example: 5). The Swift equivalent is `AgentBarAudioVisualizer(audioTrack, agentState, barColor, barCount)`. — [LiveKit prebuilt visualizers](https://docs.livekit.io/frontends/agents-ui/audio-visualizer/prebuilt.md)
- orb-ui ships a "bars" theme (five bars that animate with voice) and a "circle" theme (a pulsing circle that responds to volume). — [orb-ui](https://github.com/alexanderqchen/orb-ui)
- Pipecat's `VoiceVisualizer` "displays frequency data as animated bars." — [Pipecat Voice UI Kit](https://voiceuikit.pipecat.ai/visualizers/basic-visualizer)

**Family 4: Dot-matrix / grid.**
- LiveKit `AgentAudioVisualizerGrid` is "a grid of cells that pulse with audio." The product page calls it a "retro, lo-fi vibe dot-matrix grid visualizer." — [LiveKit prebuilt](https://docs.livekit.io/frontends/agents-ui/audio-visualizer/prebuilt.md); [LiveKit Agents UI](https://livekit.com/products/agents-ui)

**Family 5: Radial bars / ring.**
- LiveKit `AgentAudioVisualizerRadial` is "a circular visualization that expands outward" (circular bars) and is suited to "centered, prominent agent displays." — [LiveKit prebuilt](https://docs.livekit.io/frontends/agents-ui/audio-visualizer/prebuilt.md)
- Pipecat UI also ships an `audio-visualizer-radial`. — [Pipecat UI radial](https://ui.pipecat.ai/docs/visualizers/audio-visualizer-radial)
- orb-ui's "radial" theme is "a four-lobe radial field with a rim that reacts to input and twisting that reacts to output." — [orb-ui](https://github.com/alexanderqchen/orb-ui)

**Family 6: Line waveforms / Siri-wave.**
- LiveKit `AgentAudioVisualizerWave` is "a flowing waveform line." Pipecat UI has `audio-visualizer-wave`. — [LiveKit prebuilt](https://docs.livekit.io/frontends/agents-ui/audio-visualizer/prebuilt.md); [Pipecat UI wave](https://ui.pipecat.ai/docs/visualizers/audio-visualizer-wave)
- SiriWave (kopiro, MIT, ~1.6k stars) offers a "classic" pre-iOS9 sine style and an "iOS9" fluorescent multi-curve style. In the iOS9 style, frequency and color are not configurable. — [GitHub kopiro/siriwave](https://github.com/kopiro/siriwave); [Ecosyste.ms listing](https://awesome.ecosyste.ms/projects/github.com%2Fkopiro%2Fsiriwave); [freeCodeCamp write-up](https://www.freecodecamp.org/news/how-i-built-siriwavejs-library-maths-and-code-behind-6971497ae5c1/)

**Family 7: Particle / dotted sphere ("NCS-style").** A sphere made of points, displaced or scattered by audio.
- The three.js forum has an "NCS like sphere reacting to music you upload" thread, showing the "NCS sphere" is a recognized reference look. — [three.js discourse](https://discourse.threejs.org/t/ncs-like-sphere-reacting-to-music-you-upload/50501)
- Codrops tutorial: audio-reactive particles synced to frequencies and tempo, using curl noise in the vertex shader and an FBO particle approach. — [Codrops, Dec 2023](https://tympanus.net/codrops/2023/12/19/creating-audio-reactive-visuals-with-dynamic-particles-in-three-js/)
- A GPU-noise particle sphere gist is noted as mobile-friendly. — [Gist ZainabNadeem](https://gist.github.com/ZainabNadeem/41c07a54b70aa4e7c216c9226cb007f4)
- In a small community poll a particle orb beat a deformation orb 86% to 14%, but only 6 people voted, so this is anecdotal. — [Contra community post (via search)](https://contra.com/community/CkVfR8YZ-explore-interactive-ai-voice-orb-with)

**Family 8: Deforming / displaced sphere (blob, metaball, ferrofluid look).**
- AudioSphere (Three.js, GPL-3.0) deforms a sphere based on audio frequencies. — [Ecosyste.ms AudioSphere](https://awesome.ecosyste.ms/projects/github.com%2Fjonaskroedel%2Faudiosphere)
- Another project lets the audio spectrum drive the amplitude of fractal Brownian motion (fBm) displacement on spheres. — [Wayne Wu music viz](https://wayne-wu.github.io/work/musicviz/)
- 21st.dev: WebGL "shader with noise and displacement" is "the expensive one, and the only one that looks genuinely liquid." — [21st.dev blog](https://21st.dev/blog/react-voice-orb-components)

**Family 9: Screen-edge glow (Apple Intelligence Siri style).**
- The glowing, color-shifting edge light shown when Siri activates is system UI. There is no public API to invoke or restyle it, so apps must build their own. The usual SwiftUI approach is an inset rounded rectangle stroked with a rotating `AngularGradient`, blurred and layered for bloom. A Metal `colorEffect` shader (iOS 17+) adds per-pixel rippling color. (This comes from a vendor blog that promotes templates; treat specifics as unverified.) — [vp0, Apple Intelligence glow border](https://vp0.com/blogs/apple-intelligence-glow-border-effect-code-ios-free-ios-template-vibe-coding-gui); [vp0 Siri overlay clone](https://vp0.com/blogs/apple-intelligence-siri-overlay-clone-swiftui)
- Paul Hudson's Inferno is an open-source collection of SwiftUI Metal shaders (iOS 17+). — [GitHub twostraws/Inferno](https://github.com/twostraws/Inferno)

**Family 10: Character / face / mascot.**
- Arc Search "Call Arc" (May 23, 2024): you raise the phone to your ear and an animated smiley face appears whose mouth moves as it speaks the answer. The UI mimics a phone call (end-call and speaker buttons, brief hold music). — [TechCrunch](https://techcrunch.com/2024/05/23/arc-searchs-new-call-arc-feature-lets-you-ask-questions-by-making-a-phone-call); [Yanko Design](https://www.yankodesign.com/2024/05/24/arc-searchs-call-arc-feature-for-iphone-is-a-fun-take-on-phone-a-friend/); [9to5Mac](https://9to5mac.com/2024/05/23/arc-goes-conversational-with-call-arc/)
- Rabbit R1: reviewers credit Teenage Engineering for its personality, from "witty feature names to the retro aesthetic to the onscreen animation." It has a 2.88-inch screen. — [TechCrunch R1 review](https://techcrunch.com/2024/04/24/rabbits-r1-is-a-little-ai-gadget-that-grows-on-you/); [Engadget hands-on](https://www.engadget.com/rabbit-r1-hands-on-already-more-fun-and-accessible-than-the-humane-ai-pin-163622560.html)
- Humane Ai Pin had no screen and projected answers onto the palm with a laser. It was discontinued after HP bought Humane in February 2025. (Both facts came from a search-summary synthesis of these pages; I did not open each page to confirm.) — [Trusted Reviews](https://www.trustedreviews.com/versus/rabbit-r1-vs-humane-ai-pin-4410517); [Legend Memory comparison](https://legendmemory.ai/blogs/the-archive/rabbit-r1-vs-humane-ai-pin); [Wikipedia, Rabbit r1](https://en.wikipedia.org/wiki/Rabbit_r1)
- Rive tutorials describe AI-assistant mascots and orbs built as state machines (see the state-distinction section below). — [dev.to uianimation, Rive smart orb](https://dev.to/uianimation/building-a-smart-orb-animation-for-ai-assistants-in-rive-3off)

### Inferences
- The platforms converge on one taxonomy: LiveKit ships exactly Bar / Grid / Radial / Wave / Aura, Pipecat ships bars / wave / radial / plasma, and orb-ui ships radial / cloud / circle / bars. Taken together, this suggests the "official" vocabulary for voice-agent visuals as of late 2026 is one volumetric shader option plus three or four graphic options.
- Productivity tools (Wispr Flow, Granola, Superwhisper) avoid the orb. They use small, peripheral, discrete-bar indicators, which suggests "orb as hero" is an agent/conversation idiom while "bars as status" is a dictation idiom. A dictation-first app with one central element sits between the two.
- The character/face family (Call Arc, R1) is the most playful and least "premium-tech" in tone. It is also inherently monochrome-friendly.

### Gaps
- Vapi, Retell, Hume EVI and Vercel AI SDK voice demos: no first-party visual component spec was found. orb-ui provides adapters for Vapi, Retell, ElevenLabs, LiveKit, Pipecat, OpenAI Realtime and Gemini Live, so these platforms appear to leave visuals to third parties. orb-ui also claims Hume's hosted EVI API "is retired (November 13, 2026)". This was not independently verified. — [orb-ui](https://github.com/alexanderqchen/orb-ui)
- Otter, Apple Voice Memos and MacWhisper recording UIs: no sourced design descriptions found.
- Friend and Limitless pendants: no sources found on their companion-app voice visuals.
- Mobbin, Dribbble and Behance "AI voice orb" collections, Magic UI / Aceternity orb components, Lottie voice orbs, ferrofluid-specific references and iridescent/holographic orb commentary: not reached within the tool budget. These look names, though, map onto Families 1, 7 and 8.
- Liquid Glass (iOS 26) as a material for voice orbs: no designer commentary was gathered. A WWDC26 session on shader effects surfaced (developer.apple.com/videos/play/wwdc2026/322) but was not read.

---

## How does each family map audio to motion (volume, FFT bands, onset, pitch)? What feels responsive vs laggy?

### Takeaway
Almost everything is driven by a smoothed volume envelope (RMS or analyser level normalized to 0 to 1). Only bar, grid and radial families typically use FFT bands, and pitch and onset detection are essentially absent from shipped components. Responsiveness comes from three things: asymmetric smoothing (fast attack, slow release), keeping input and output volumes as separate signals, and rendering outside the UI framework's re-render loop. Unsmoothed jitter is the main cause of "looks broken."

### Cited Findings
- ElevenLabs' SDK exposes input and output volume on a 0 to 1 scale where "0 is -100 dB and 1 is -30 dB," which is the signal its orb consumes. — [ElevenLabs JS SDK docs](https://elevenlabs.io/docs/agents-platform/libraries/javascript)
- A Deepgram registry copy of an orb shows the API shape `Orb inputVolume={0.5} outputVolume={0.3} state="talking"`, with idle/listening/talking states. — [Deepgram orb registry](https://cdn.deepgram.com/ui/r/orb.json) (via search summary)
- assistant-ui: `volume` (0 to 1) "adds to the state's speed, distortion, and glow, so the orb keeps reacting during an utterance." With a runtime it reads live level through `useVoiceVolume()`. — [assistant-ui Orb](https://www.assistant-ui.com/elements/orb)
- orb-ui normalizes every provider into one `OrbSignal` (state plus separate input and output volume). Vapi uses the mic track for listening motion and assistant audio events for speaking motion, with separate calibration for each. LiveKit "meters both sides with speech-oriented analyser and smoothing defaults." Pipecat reads RTVI events and falls back to media tracks. — [orb-ui](https://github.com/alexanderqchen/orb-ui)
- Input and output drive different motion parameters in orb-ui's radial theme (rim reacts to input, twist reacts to output). The cloud theme scales *inversely* while listening and moves faster while speaking. — [orb-ui](https://github.com/alexanderqchen/orb-ui)
- LiveKit visualizers are "driven by two inputs: the audio track's volume levels and the agent's current state." — [LiveKit prebuilt](https://docs.livekit.io/frontends/agents-ui/audio-visualizer/prebuilt.md)
- FFT band mapping (Wispr-style pill rebuild): `analyser.fftSize = 256`. "Each frame, we take that frequency snapshot, slice it into 14 buckets, one per bar." Each bar averages its bins and is normalized by 255. — [Freestyle](https://freestylevoice.com/blog/floating-pill)
- Asymmetric smoothing: RISE = 0.55 when the target is above the current height, FALL = 0.22 when below. Each frame moves a fraction of the gap, which "gives it the smooth, voice-y feel that settles with a decay." — [Freestyle](https://freestylevoice.com/blog/floating-pill)
- Raw signal: the mic is captured with `echoCancellation`, `noiseSuppression` and `autoGainControl` all false so the analyser sees the true signal. — [Freestyle](https://freestylevoice.com/blog/floating-pill)
- Rendering path: plain SVG lines in a `requestAnimationFrame` loop, because React re-rendering "would drop frames." — [Freestyle](https://freestylevoice.com/blog/floating-pill)
- "Smooth the value over several frames, because raw amplitude jitters". An orb that twitches "reads as broken rather than responsive." The pipeline is an `AnalyserNode` on the mic, giving an amplitude that feeds a shader or transform. — [21st.dev blog](https://21st.dev/blog/react-voice-orb-components)
- Particle family: Codrops syncs particles to both frequencies and tempo, with curl noise for swirl. — [Codrops](https://tympanus.net/codrops/2023/12/19/creating-audio-reactive-visuals-with-dynamic-particles-in-three-js/)
- Deforming family: the spectrum drives fBm displacement amplitude. — [Wayne Wu](https://wayne-wu.github.io/work/musicviz/)
- Rive pattern: a numeric `audioLevel` (or `talkAmount` 0 to 1) input driven by amplitude, plus a separate lip-sync state machine with a numeric `viseme` input fed by TTS timing. — [dev.to Rive smart orb](https://dev.to/uianimation/building-a-smart-orb-animation-for-ai-assistants-in-rive-3off); [dev.to Rive state machine for AI voice avatars](https://dev.to/uianimation/rive-state-machine-for-ai-voice-avatars-complete-developer-guide-49g2)
- Character family: Call Arc's smiley mouth moves with the spoken audio. — [TechCrunch](https://techcrunch.com/2024/05/23/arc-searchs-new-call-arc-feature-lets-you-ask-questions-by-making-a-phone-call)

### Inferences
- Responsive vs laggy rule of thumb from the sources: a fast attack (about 0.5 per frame at 60 fps) makes onsets feel immediate. A slower release (about 0.2) keeps decay from flickering. Symmetric heavy smoothing feels laggy and no smoothing feels twitchy.
- For volumetric families (orb, aura, blob), the common pattern is to map volume to *several* parameters at once (scale, displacement or distortion, noise speed, glow) rather than to scale alone. Scale-only pulsing is the most "generic" mapping.
- Separate input and output channels let one element show both "I hear you" and "I'm talking" with different motion signatures (for example, rim vs twist, or contract vs expand). For a dictation app with no TTS output, the second channel can be repurposed for a "processing/transcribing" signal.
- On iOS, the Freestyle lesson (render outside the declarative re-render loop) maps to driving a Metal shader or `TimelineView`/`Canvas` from a smoothed value, rather than publishing per-frame SwiftUI state. This is an inference; no iOS-specific source was found.

### Gaps
- No shipped component found that uses pitch tracking or onset/transient detection explicitly. No designer commentary measures perceived latency thresholds (for example, ms from voice to motion).
- The ElevenLabs Orb's internal mapping (which uniforms the volumes drive) was not readable (429 on the docs page).

---

## How do they distinguish states (idle, listening, thinking, speaking)?

### Takeaway
States are almost always a small enum (idle/connecting/listening/thinking/speaking, sometimes muted or error). In the best implementations each state changes *motion parameters* (speed, sharpness, blur, amplitude source) rather than swapping to a different graphic. "Faster and sharper reads as attention", while "thinking" is typically an autonomous pulse or sweep not tied to audio. Several kits drop "thinking" entirely. Accessibility guidance says to pair the visual with a text or live-region label.

### Cited Findings
- State enums by library:
  - orb-ui: `idle`, `connecting`, `listening`, `thinking`, `speaking`, `error`. — [orb-ui](https://github.com/alexanderqchen/orb-ui)
  - assistant-ui: `idle`, `connecting`, `listening`, `speaking`, `muted`, with no thinking state. A status dot is grey when idle, pulsing amber when connecting, green when listening or speaking, and red when muted. Muted overrides speaking. — [assistant-ui Orb](https://www.assistant-ui.com/elements/orb)
  - LiveKit Aura defaults to `state="connecting"` and the Swift bar visualizer defaults to `.initializing`. The docs say visualizers respond "to agent state with unique animations" (listening, thinking, speaking) without detailing each. — [LiveKit Aura](https://docs.livekit.io/reference/components/agents-ui/component/agent-audio-visualizer-aura.md); [LiveKit prebuilt](https://docs.livekit.io/frontends/agents-ui/audio-visualizer/prebuilt.md)
  - ElevenLabs Orb takes an `agentState` prop (exact values unverified because of the 429). A Deepgram copy uses idle/listening/talking. — [21st.dev mirror](https://21st.dev/@ElevenLabs/components/orb); [Deepgram registry](https://cdn.deepgram.com/ui/r/orb.json)
  - Wispr Flow bar: resting, recording, processing. — [Wispr Flow docs](https://docs.wisprflow.ai/articles/1790396454-move-and-dock-the-flow-bar-on-desktop). The Freestyle rebuild uses a state machine of idle → initializing → recording → transcribing → idle, triggered by `hotkey:down` and `hotkey:up`. — [Freestyle](https://freestylevoice.com/blog/floating-pill)
  - Rive tutorial: a state machine `Orb_SM` with Idle, Listening, Thinking and Speaking, boolean inputs per state plus a numeric `audioLevel`, transitioning Idle → Listening → Thinking → Speaking → Idle. — [dev.to Rive smart orb](https://dev.to/uianimation/building-a-smart-orb-animation-for-ai-assistants-in-rive-3off)
- Parameter-shift approach: one attribute `data-state='listening'` shortens the spin from 9s to 3s and reduces the blur, with a transition on `filter`. "Faster and sharper reads as attention." — [Adrián Álvarez](https://www.adrian-alvarez.com/en/snippets/ai-voice-orb/)
- Thinking: the orb "pulses while a response generates and settles when it arrives". The orb "can express three states (idle, working, speaking) with no text and no layout change." Use a live region announcing "Listening" / "Thinking" / "Speaking". — [21st.dev blog](https://21st.dev/blog/react-voice-orb-components)
- Silence within listening: a Wispr-style bar implementation has bars "sit as dots during silence". The resting form is a row of dots, not flat lines or nothing. — [softmaxe/whisper PR #73](https://github.com/softmaxe/whisper/pull/73)
- Active-capture affordance: Granola's dancing bars double as the button to open the live transcript, and a floating indicator persists when the app is backgrounded. — [Granola help](https://help.granola.ai/article/transcription)
- Critique: an orb alone may not tell the user whether the assistant is "suggesting, waiting, acting, or asking for permission" (UX designer Val Pavliuchenko, as reported). — [C114Pro, The Future of Voice AI Depends on Visible Control](https://www.c114pro.com/ai/164802.html)
- An orb "cannot express progress, so anything with a countable unit still wants a number." — [21st.dev blog](https://21st.dev/blog/react-voice-orb-components)

### Inferences
- A robust monochrome state grammar visible in these sources:
  - Idle: slow, low-amplitude "breathing", or a dot/ring at rest.
  - Listening: audio-driven, sharper, faster.
  - Thinking/processing: autonomous rhythmic motion decoupled from audio (pulse, rotation, sweep).
  - Speaking/result: driven by the output signal, with a different motion signature from listening.
  Color is not needed for any of these, because speed, sharpness, amplitude source and form changes carry them.
- For a dictation app, "thinking" equals "transcribing/processing". The Wispr pattern (resting → recording → processing) is the closest analogue and is a three-state enum, not five.

### Gaps
- Exact per-state animations of LiveKit's Bar/Grid/Radial/Wave/Aura and ElevenLabs' Orb are not documented on the pages fetched. The source code (livekit/components-js packages/shadcn, elevenlabs/ui) would have them.

---

## How do they work in monochrome (white on black, black on white)? Which families survive without color?

### Takeaway
The graphic and discrete families (bars or pill, dots at rest, dot-matrix grid, radial bars, particle/dotted sphere, character face) are native to monochrome. Wispr's look is literally black capsule and white bars. Volumetric families survive only if they carry information in luminance and form (a lit, shaded displaced sphere; a luminance-only glow), not in hue. Hue-rotation orbs (conic gradients, Siri-wave iOS9, edge glow) largely collapse into grey fog. Glow-based shaders also need explicit rework for light backgrounds, because additive "light" on white has nowhere to go.

### Cited Findings
- The Wispr-style indicator is a black capsule with white bars that turn into dots in silence, which is a fully monochrome design. — [softmaxe/whisper PR #73](https://github.com/softmaxe/whisper/pull/73)
- LiveKit Aura has an explicit `themeMode` prop (light/dark). The example passes the resolved theme from next-themes, so the shader is tuned separately per theme. — [LiveKit Aura reference](https://docs.livekit.io/reference/components/agents-ui/component/agent-audio-visualizer-aura.md)
- React Bits added a `backgroundColor` prop to Orb across all variants "with shader luminance adjustments", which shows a glow shader built for dark backgrounds needs luminance changes to work on other backgrounds. — [GitHub react-bits PR #790](https://github.com/DavidHDev/react-bits/pull/790)
- assistant-ui ships a grey `default` variant and keeps color "independent of state", so state is not encoded in hue. — [assistant-ui Orb](https://www.assistant-ui.com/elements/orb)
- Adrián Álvarez's CSS orb relies on `mix-blend-mode: screen` "on dark backgrounds" to look lit, and its identity is a cyan-violet palette. — [Adrián Álvarez](https://www.adrian-alvarez.com/en/snippets/ai-voice-orb/)
- SiriWave's iOS9 style does not allow configuring color. Its look depends on the fixed fluorescent multi-color curves. — [kopiro/siriwave](https://github.com/kopiro/siriwave)
- The Apple Intelligence edge glow is defined by a "color-shifting" rotating angular gradient. — [vp0](https://vp0.com/blogs/apple-intelligence-glow-border-effect-code-ios-free-ios-template-vibe-coding-gui)
- LiveKit's Swift bar visualizer exposes a single `barColor`, so it is monochrome by construction. — [LiveKit prebuilt](https://docs.livekit.io/frontends/agents-ui/audio-visualizer/prebuilt.md)

### Inferences
Monochrome suitability per family (inference, synthesized from the sources above):

| Family | White on black | Black on white | Notes |
|---|---|---|---|
| 1. Shader gradient orb / aura | Good if luminance-only (white core, falloff to black) | Weak to medium; glow inverts to a soft grey smudge or "shadow" and needs a separate tuning (cf. `themeMode`, luminance adjustments) | Without hue, depth must come from noise contrast and core brightness |
| 2. CSS conic-gradient blur orb | Weak; hue rotation is the whole effect, so grayscale looks like a spinning fuzzy disc | Weak | `screen` blend on dark → `multiply` on light (inference) |
| 3. Discrete bars / pill / dots-at-rest | Excellent | Excellent | Proven by Wispr-style designs |
| 4. Dot-matrix grid | Excellent | Excellent | Can read "retro/lo-fi" (LiveKit's own framing) |
| 5. Radial bars / ring | Excellent | Excellent | Good fit for one centered element |
| 6a. Classic sine / single line wave | Works technically | Works | But reads as dated (see next section) |
| 6b. Siri-wave iOS9 | Poor; color is fixed and the defining trait | Poor | |
| 7. Particle / dotted sphere | Excellent; points are binary marks, depth via size and density | Excellent; black dots on white looks like stipple or print | Strong candidate for "premium + monochrome" |
| 8. Deforming sphere / metaball / ferrofluid | Good with lighting (specular, Fresnel rim) | Good; black ferrofluid on white is a natural fit | Needs shading or matcap, not flat fill |
| 9. Screen-edge glow | Weak; it is a color effect and peripheral, not a central element | Weak | Conflicts with the "one central element" brief |
| 10. Character / face | Excellent (Call Arc smiley is a simple glyph) | Excellent | Tone is playful, not "premium tech" |

- For a white-on-black / black-on-white app, the families that keep sophistication without color are 7 (particle/dotted sphere), 8 (lit displaced sphere / ferrofluid), 5 (radial ring) and 3 (center-weighted bars or dots with asymmetric smoothing). Family 1 can work in dark mode as a luminance glow but needs a deliberately different light-mode rendering.

### Gaps
- No designer commentary specifically on monochrome voice orbs was found. The table above is synthesized from the component evidence, not quoted.

---

## What makes a visual feel modern/premium in 2025 to 2026 versus dated or generic?

### Takeaway
Across the sources, "premium" comes from four things: organic, non-repeating motion (layered noise, desynchronized periods); perceived materiality (liquid, lit, volumetric, not "painted"); restrained, well-smoothed audio response; and state changes expressed through motion character rather than new graphics. "Generic" is explicitly named as plain volume bars and single rotating gradients. Productivity apps add a counter-trend: Granola deliberately avoids looking like a recorder. Hard evidence of broad designer consensus is thin. Most commentary comes from individual builders and the platform vendors themselves.

### Cited Findings
- LiveKit positions its shader Aura as "more expressive than generic volume bars", which treats bars as the baseline to beat. — [LiveKit blog, Design voice AI interfaces with Agents UI](https://livekit.com/blog/design-voice-ai-interfaces-with-agents-ui)
- WebGL noise and displacement is "the only one that looks genuinely liquid". "Quality varies by author, so preview before you take it." — [21st.dev blog](https://21st.dev/blog/react-voice-orb-components)
- "The orb is what an AI product uses instead of a spinner." — [21st.dev blog](https://21st.dev/blog/react-voice-orb-components)
- A single rotating gradient reads as a "colour wheel", while two offset, desynchronized layers read as "liquid". A non-matching last gradient stop leaves "a hard seam". The orb should look "lit rather than painted". — [Adrián Álvarez](https://www.adrian-alvarez.com/en/snippets/ai-voice-orb/)
- Restraint and accessibility are part of the craft: reduced motion should stop the spin, the orb should be `aria-hidden` with state given in text, and a large hero version can "make a laptop fan spin." — [Adrián Álvarez](https://www.adrian-alvarez.com/en/snippets/ai-voice-orb/)
- Twitchy, unsmoothed response "reads as broken rather than responsive". A bare circle "is not an obvious button." — [21st.dev blog](https://21st.dev/blog/react-voice-orb-components)
- Asymmetric attack and release is what makes bars feel "smooth, voice-y" and "settle with a decay". — [Freestyle](https://freestylevoice.com/blog/floating-pill)
- Granola: "we wanted Granola to feel like a notepad, not a recorder". Its CEO contrasts it with capture-centric tools ("a lot of the other tools—Otter is like 9 years old at this point—are really about meeting capture, meeting recording"). Its indicator is a tiny three-bar glyph, not a hero visual. (The quotes came from search snippets. Their most likely source pages are listed here, but I did not open those pages to confirm the exact URL for each quote.) — [Granola blog, Why Granola doesn't use a bot](https://www.granola.ai/blog/why-granola-doesnt-use-a-bot); [Platformer interview](https://platformer.news/granola-chris-pedregal-interview); [Fast Company interview](https://www.fastcompany.com/91497900/granola-chris-pedregal-interview)
- Vendors treat customization and branding as part of premium: "Every component can be themed, so it's easy to express your brand's unique style." — [LiveKit blog](https://livekit.com/blog/design-voice-ai-interfaces-with-agents-ui)
- Personality through animation is credited as what made the Rabbit R1 likeable despite functional weaknesses. — [TechCrunch R1 review](https://techcrunch.com/2024/04/24/rabbits-r1-is-a-little-ai-gadget-that-grows-on-you/)
- Google tested a circular audio visualizer with animated dots for Gemini Live, which signals that a dots-in-a-circle form is on big-platform radar. — [Trend Hunter](https://www.trendhunter.com/trends/ai-voice-interfaces) (aggregator, low weight)
- Counterpoint: an orb is not enough by itself, and visible control and explicit state matter more than a pleasant visual (Val Pavliuchenko, as reported). — [C114Pro](https://www.c114pro.com/ai/164802.html)

### Inferences
- Dated or generic markers (synthesized):
  - Many equal-width bars, symmetric and full-spectrum (a "Winamp EQ" look).
  - A single plain sine line.
  - A single hue-rotating gradient disc.
  - Scale-only pulsing.
  - Unsmoothed jitter.
  - Stock neon cyan-violet palettes (already the default in many free components, e.g., LiveKit `#1FD5F9`, Adrián's cyan-to-indigo).
- Premium markers (synthesized):
  - Few elements or many tiny ones (3 to 5 bars, or hundreds of dots), not a medium count.
  - Center-weighting and dots-at-rest.
  - Desynchronized layered noise.
  - Volumetric lighting or material cues.
  - Motion-only state grammar.
  - A deliberate light-mode treatment.
  - Respect for reduced motion.
- For a monochrome brand, removing color moves the premium signal entirely onto motion quality and form. Smoothing curves, noise layering and light-mode rendering then carry more weight than palette.

### Gaps
- No Awwwards, Mobbin, Dribbble or Behance trend data was gathered. No high-profile designer essays specifically ranking voice-orb styles were found, and the commentary base is mostly individual builders and vendor marketing.
- No commentary was found on how Apple's Liquid Glass (iOS 26) has changed expectations for refraction or glass orbs.

---

## Which have open-source implementations, and what technique do they use?

### Takeaway
The open-source ecosystem is web-first (React + shadcn registries) and dominated by WebGL shaders (Three.js / React Three Fiber, OGL, custom WebGL) for volumetric looks and SVG/Canvas for bars and waves. Rive state machines are the main cross-platform authoring route that includes native iOS. Native iOS options are thinner: LiveKit's Swift bar visualizer, SwiftUI Metal shader collections (Inferno) and hand-rolled `AngularGradient`/blur glows.

### Cited Findings
| Implementation | Family | Technique | License / link |
|---|---|---|---|
| ElevenLabs UI `Orb` (plus waveforms etc.) | 1 | Three.js (per mirror), React, shadcn | MIT — [elevenlabs/ui](https://github.com/elevenlabs/ui) |
| LiveKit Agents UI: Bar, Grid, Radial, Wave, Aura | 3, 4, 5, 6, 1 | React/shadcn; Aura is a custom WebGL shader designed with Unicorn Studio | [livekit/components-js packages/shadcn](https://github.com/livekit/components-js/tree/main/packages/shadcn); Swift `AgentBarAudioVisualizer`, Flutter `SoundWaveformWidget`, Android `VoiceAssistantBarVisualizer` per [LiveKit prebuilt](https://docs.livekit.io/frontends/agents-ui/audio-visualizer/prebuilt.md) |
| LiveKit custom shader visualizer guide | 1 | Aura is "a good starting point for custom shaders" | [LiveKit custom visualizers](https://docs.livekit.io/frontends/agents-ui/audio-visualizer/custom.md) |
| Pipecat `PlasmaVisualizer` / `Plasma`, `VoiceVisualizer` | 1, 3 | WebGL + Three.js; bars from spectrum | [Pipecat Voice UI Kit](https://voiceuikit.pipecat.ai/visualizers/plasma-visualizer). Note: "Pipecat UI replaces Voice UI Kit" (shadcn registry with wave and radial visualizers) — [Pipecat UI docs](https://docs.pipecat.ai/client/pipecat-ui) |
| orb-ui (radial, cloud, circle, bars, debug) | 5, 1, 3 | React; custom `renderTheme` can be DOM, SVG, canvas or WebGL; presets `calm` / `expressive` | MIT — [alexanderqchen/orb-ui](https://github.com/alexanderqchen/orb-ui) |
| assistant-ui `Orb` / `VoiceOrb` | 1 | WebGL canvas | License not stated on page — [assistant-ui](https://www.assistant-ui.com/elements/orb) |
| React Bits `Orb` | 1 | OGL fragment shader | [react-bits repo PR #790](https://github.com/DavidHDev/react-bits/pull/790) (license not verified) |
| Adrián Álvarez CSS orb | 2 | Two conic gradients + blur + clip | [Snippet](https://www.adrian-alvarez.com/en/snippets/ai-voice-orb/) |
| Freestyle Wispr-style pill | 3 | Web Audio AnalyserNode (fftSize 256, 14 buckets) + SVG lines + rAF | [Write-up](https://freestylevoice.com/blog/floating-pill) |
| softmaxe/whisper Wispr-style bar | 3 | 10 center-weighted bars, dots at silence | [PR #73](https://github.com/softmaxe/whisper/pull/73) |
| SiriWave (classic + iOS9) | 6 | Canvas 2D | MIT — [kopiro/siriwave](https://github.com/kopiro/siriwave) |
| AudioSphere | 8 | Three.js sphere deformation from Web Audio frequencies | GPL-3.0 — [Ecosyste.ms](https://awesome.ecosyste.ms/projects/github.com%2Fjonaskroedel%2Faudiosphere) |
| Codrops audio-reactive particles | 7 | Three.js, curl noise in vertex shader, FBO particles | [Codrops tutorial](https://tympanus.net/codrops/2023/12/19/creating-audio-reactive-visuals-with-dynamic-particles-in-three-js/) |
| GPU noise particle sphere | 7 | Three.js GPU noise (mobile-friendly) | [Gist](https://gist.github.com/ZainabNadeem/41c07a54b70aa4e7c216c9226cb007f4) |
| Rive AI orb / avatar state machines | 1, 10 | Rive state machine: Idle/Listening/Thinking/Speaking, numeric `audioLevel` / `talkAmount`, `viseme` | Tutorials only; no official community .riv found — [dev.to](https://dev.to/uianimation/building-a-smart-orb-animation-for-ai-assistants-in-rive-3off) |
| Inferno (SwiftUI Metal shaders) | 1, 9 (building blocks) | SwiftUI `colorEffect` / `layerEffect` Metal shaders, iOS 17+ | [twostraws/Inferno](https://github.com/twostraws/Inferno) |
| 21st.dev community orbs (Voice Powered Orb, Siri Orb, Neon Orbs) | 1 | WebGL (Voice Powered Orb); others unspecified | [21st.dev blog index](https://21st.dev/blog/react-voice-orb-components) |

- The SwiftUI shader APIs (iOS 17+) let views sample position and time per pixel, and iOS 18 adds `compile()` to precompile a shader for the device. (Secondary source.) — [vp0](https://vp0.com/blogs/apple-intelligence-siri-overlay-clone-swiftui)

### Inferences
- For a native iOS target, the most direct paths are:
  - Port a WebGL/GLSL orb or particle shader to Metal (SwiftUI `.colorEffect`/`.layerEffect` or an `MTKView`), driven by a smoothed mic level from `AVAudioEngine`.
  - Author in Rive with a numeric audio input and use the Rive iOS runtime.
  - Draw bars, dots or rings in SwiftUI `Canvas` with asymmetric smoothing.
  The web components are best used as visual and parameter references, not dependencies.
- LiveKit's Swift `AgentBarAudioVisualizer` is the only first-party native-iOS visualizer found among the platforms.

### Gaps
- Magic UI and Aceternity orb-style components, Lottie voice orbs, and the specific "Crystalized Ball" component named in the brief were not located within the tool budget.
- License terms for React Bits and assistant-ui components were not verified.
- No open-source native SwiftUI/Metal voice orb (as opposed to generic shader collections) was found in this pass.
