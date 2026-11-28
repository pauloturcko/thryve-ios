# Visual language of major AI assistants for voice capture / listening (state as of late Nov 2026)

Scope note: research run on 2026-11-28. "Confirmed" means an official source or a hands-on review of shipped software. "Teardown" means APK/beta strings or screenshots of unreleased builds. "Rumor" means pre-release reporting (mostly Bloomberg/Gurman). Many visual specifics (exact hex values, timing curves) are not published by any vendor; where they are missing, that is recorded under Gaps rather than guessed.

---

## 1. What does each visual look like (shape, color, material)? Monochrome or colored?

### Takeaway
Late 2025 to 2026 brought a clear move away from full-screen ambient effects (Siri's rainbow edge glow, ChatGPT's full-screen blue orb) toward compact, in-context indicators. Siri in iOS 27 is a small dark Liquid Glass orb that drops out of the Dynamic Island, ChatGPT voice now runs inside the chat, and Gemini replaces the text field with a waveform. Color has become more restrained: Apple's iOS 27 palette is dark and desaturated, with the multicolor waveform as the only color accent. Blue/cyan is still the default "AI listening" hue for Google, OpenAI, Amazon and xAI.

### Cited Findings

**Apple Siri (iOS 18 / iOS 26 edge glow, older, 2024–2025)**
- Apple described the iOS 18 Siri look as "a brand-new design with an elegant glowing light that wraps around the edge of the screen when active on iPhone." — [Apple Newsroom, Sept 2024](https://www.apple.com/newsroom/2024/09/ios-18-is-available-today-making-iphone-more-personal-and-capable-than-ever/)
- Apple's feature guide: "The new edge light responsively animates with the sound of your voice and makes it possible to keep scrolling, typing, or otherwise navigating your device while you talk to Siri." — [iOS 18 All New Features PDF](https://apple.com/ios/ios-18/pdf/iOS_18_All_New_Features_Sept_2024.pdf)
- MacRumors calls the iOS 27 shades "softer and less saturated than the current Siri glow around the display", which implies the iOS 18–26 glow was saturated and multicolored. — [MacRumors, May 26 2026](https://www.macrumors.com/2026/05/26/ios-27-siri-dark-colors/)

**Apple Siri (iOS 27, announced WWDC June 8 2026, shipped Sept 2026)**
- Pre-WWDC rumor (Gurman): the Siri interface Apple was testing uses only dark colors, with no light mode "for now". Accent colors were said to match the WWDC26 site art: a white Swift bird on black with subtle pink, dark blue, purple and orange highlights. Several elements reportedly had a dark background and a blinking cursor in those colors. — [MacRumors, May 26 2026](https://www.macrumors.com/2026/05/26/ios-27-siri-dark-colors/)
- Rumor: a pill-shaped animation in the Dynamic Island on activation, a glowing "searching" label while answering, and results in a translucent panel. — [MacRumors, May 26 2026](https://www.macrumors.com/2026/05/26/ios-27-siri-dark-colors/); [MacRumors, June 2 2026](https://www.macrumors.com/2026/06/02/ios-27-siri-features/)
- Gurman pre-launch: a "thin glow" around the edges of the Dynamic Island when Siri is invoked. Launch coverage describes Siri appearing from within the Dynamic Island "in a wave-like animation". — [Digital Trends](https://www.digitaltrends.com/computing/apple-announces-ios-27-with-speedy-app-launches-siri-ai-and-liquid-glass-refinements-for-your-iphone/) (via search summary; descriptions vary across outlets between "wave-like", "expanding bubble" and "glowing pill")
- **Confirmed (hands-on review):** "The old glowing animation around the bezels is gone." It is replaced by "a floating dark orb made out of Liquid Glass" that refracts what is beneath it. "Siri's multicolor waveform is the only part that keeps the old colors." — [MacStories iOS 27 review, p.5](https://www.macstories.net/stories/ios-and-ipados-27-review/5/)
- The standalone Siri app icon was redesigned in iOS 27 beta 5 with a glass look "inspired by the dynamic Siri glow" seen when Siri is invoked. — [Republic World, Aug 12 2026](http://www.republicworld.com/tech/apple-redesigns-siri-icon-in-ios-27-beta-5-with-dynamic-liquid-glass-design-2026-08-12-134587)
- Siri AI ships with a dedicated app that stores conversation history and syncs through iCloud. Pre-release reports expected a Messages-style chatbot look. — [Digital Trends](https://www.digitaltrends.com/computing/apple-announces-ios-27-with-speedy-app-launches-siri-ai-and-liquid-glass-refinements-for-your-iphone/); [MacRumors, May 26 2026](https://www.macrumors.com/2026/05/26/ios-27-siri-dark-colors/)
- System context: iOS 27 adds a Settings slider that sets Liquid Glass anywhere from "ultraclear" to "fully tinted". — [Apple Newsroom, Sept 2026](https://apple.com/newsroom/2026/09/major-updates-for-apples-software-platforms-are-now-available)

**Apple dictation**
- iOS 27 introduces a new systemwide dictation "built into the keyboard". It runs on a new Apple Intelligence model "created based on Google's Gemini" and corrects spelling, punctuation and capitalization across apps. TechCrunch does not describe its visual UI. — [TechCrunch, June 8 2026](https://techcrunch.com/2026/06/08/apple-introduces-systemwide-dictation)
- Apple's accessibility page describes a cursor popover for stopping Dictation (version not stated). — [Apple Accessibility](https://apple.com/am/accessibility/cognitive/) (via search summary)
- iOS 27 lets users hide the Messages audio/dictation button "everyone hits by mistake." — [MacRumors how-to](https://macrumors.com/how-to/ios-hide-dictation-messages-button) (headline)

**OpenAI ChatGPT Voice**
- May 2024 GPT-4o demo: animated black dots. At the Sept 24 2024 Advanced Voice Mode rollout it was replaced by "a blue animated sphere". — [TechCrunch, Sept 24 2024](https://techcrunch.com/2024/09/24/openai-rolls-out-advanced-voice-mode-with-more-voices-and-a-new-look)
- Web (Nov 2024): starting a voice chat opened a screen with a blue orb in the center. — [TechCrunch, Nov 19 2024](https://techcrunch.com/2024/11/19/openai-brings-chatgpts-advanced-voice-mode-to-the-web)
- Nov 25 2025: voice moved into the regular chat window as the default. Responses appear as text while you talk, and images and maps appear in real time. The old separate screen had the "animated blue circle", a mute button, a live-video option and an X button. Users can still turn on "Separate mode" under Settings → Voice Mode. You "still need to tap 'end'" to return to text. — [TechCrunch, Nov 25 2025](https://techcrunch.com/2025/11/25/chatgpts-voice-mode-is-no-longer-a-separate-interface/); [Yahoo Tech](https://tech.yahoo.com/ai/chatgpt/articles/chatgpt-moves-voice-mode-chat-192635811.html)
- July 8 2026: GPT-Live-1 / GPT-Live-1 mini (full-duplex, listens and talks at the same time) power ChatGPT Voice. "While you're talking, ChatGPT can now show rich visual cards for topics like weather, stocks, sports" (screenshots show a weather forecast, football fixtures and a map). OpenAI's page does not describe the orb or any state visuals. — [OpenAI, "Introducing GPT-Live"](https://openai.com/index/introducing-gpt-live)
- OpenAI community threads ask for "Voice mode visual improvements" and an "Optional Animated Avatar for ChatGPT Voice Mode", which suggests some users want more expressive visuals. — [OpenAI Community](https://community.openai.com/t/voice-mode-visual-improvements/1386614); [OpenAI Community](https://community.openai.com/t/feature-request-optional-animated-avatar-for-chatgpt-voice-mode/1391160) (titles only)

**Google Gemini Live / Gemini voice**
- Current Gemini Live audio visualizer: a pill-shaped element. — [Android Authority, Oct 27 2026](https://www.androidauthority.com/gemini-live-neural-expressive-audio-visualizer-redesign-3728666/)
- Mar 2026 (rolled out on Android): Gemini's voice input redesign "replaces the text field with a waveform". The old design's "blue pulsating circle" remains in the Gemini overlay. The Send control is a circle that "slightly pulsates". — [9to5Google, Mar 19 2026](https://9to5google.com/2026/03/19/gemini-voice-input-redesign/)
- "Neural Expressive" design language (introduced around May 2026): "glowing gradients, animated elements, and an overall cleaner layout." — [Android Authority, Oct 27 2026](https://www.androidauthority.com/gemini-live-neural-expressive-audio-visualizer-redesign-3728666/); [Sammy Fans, May 14 2026](https://www.sammyfans.com/2026/05/14/google-quietly-refreshing-gemini-live-with-new-interactive-ui/)
- Teardown, July 2026 (Google app 17.43.11): the overlay looks "more gauzy, ethereal almost, with edges that blur slightly when you're communicating with Gemini". It has colored floating dots along its edges and highlights on the outer edge of the output window, and is "not truly transparent" but gives "the impression of a glowing element". The Gemini Live center button gets an "airy glow with a misty, ever-changing shape". — [Android Authority, July 24 2026](https://www.androidauthority.com/gemini-overlay-live-neural-design-apk-teardown-3690991/)
- Teardown, Oct 2026 (Google app 17.70.10): "a circular button surrounded by animated dots and a glowing blue background". The dots "almost appear to warp the space around them, much like a black hole". An earlier October test used a waveform animation plus a dedicated mute button. — [Android Authority, Oct 27 2026](https://www.androidauthority.com/gemini-live-neural-expressive-audio-visualizer-redesign-3728666/); [Android Headlines, Oct 2026](https://www.androidheadlines.com/2026/10/google-gemini-live-redesign-leak.html)
- A Notebookcheck headline says Gemini's latest beta "takes animation design cues from Apple's new Siri." — [Notebookcheck](https://www.notebookcheck.net/Gemini-AI-assistant-takes-animation-design-cues-from-Apple-s-new-Siri-in-the-latest-Google-app-beta-APK-teardown.872459.0.html) (headline only, not read)

**Anthropic Claude voice mode**
- Beta launched May 27 2025 on mobile. It "displays key points on-screen as Claude speaks." — [TechCrunch, May 27 2025](https://techcrunch.com/2025/05/27/anthropic-launches-a-voice-mode-for-claude)
- July 2026 update, reported from user observations with no Anthropic announcement: "the central orb now pulses with a visual glow to signal that the model is speaking or listening". The update also added a hold-to-talk button, an in-session model selector and about 18 more languages. — [Crypto Briefing, July 6 2026](https://cryptobriefing.com/anthropic-claude-voice-mode-ui-update/)
- 60fps.design lists a "Claude Voice Selection Border Pulse Interaction" and describes the app as having "swiping audio-reactive gradient borders" (which recording that refers to is unclear). — [60fps.design, Claude](https://60fps.design/apps/claude)

**Microsoft Copilot Voice (Mico)**
- Oct 23 2025: Mico is an optional animated avatar, "an abstract blob that floats around the screen and can change shape, emote, and react to conversations." Microsoft says it "listens, reacts, and even changes colors to reflect your interactions." It is on by default in voice mode and can be turned off. — [TechCrunch, Oct 23 2025](https://techcrunch.com/2025/10/23/microsofts-mico-is-a-clippy-for-the-ai-era); search summary of [Tom's Guide](https://www.tomsguide.com/au/ai/copilot/forget-clippy-meet-mico-microsofts-friendlier-face-for-copilots-fall-release)
- One reviewer called it "almost like a mood ring for your computer". Tom's Guide says Microsoft claims it can "quickly change facial expressions, tones and colors to match the mood." — search summary of Mico coverage ([Tom's Guide](https://www.tomsguide.com/au/ai/copilot/forget-clippy-meet-mico-microsofts-friendlier-face-for-copilots-fall-release))

**Amazon Alexa+**
- "Alexicons": "expressive animations on the blue light bar while you chat" on the new Echo Show devices. — [About Amazon](https://www.aboutamazon.com/news/devices/new-alexa-plus-amazon-devices)
- PCWorld preview: a new expressive blue animation replaces the classic blue line and "changes shape as you talk". — [PCWorld](https://www.pcworld.com/article/2617852/a-new-alexa-ai-is-coming-what-it-will-cost-and-when-you-can-try-it.html) (via search summary)
- Amazon help: on Echo Show, a cyan spotlight on a blue bar means Alexa is listening. — [Amazon Customer Service](https://www.amazon.com/gp/help/customer/display.html?nodeId=TaI3C5lPJp9GBipa94) (via search summary)

**Perplexity**
- Feb 2025 iOS redesign: the mic/push-to-talk button was replaced by "a dot-filled sphere that reacts to both voice and touch." — [TechRadar](https://www.techradar.com/computing/artificial-intelligence/perplexitys-voice-mode-gets-a-futuristic-makeover-on-your-iphone); [AiNews](https://ainews.com/p/perplexity-ai-s-voice-mode-gets-a-major-upgrade-on-ios)

**xAI Grok**
- iOS listening state: "a vibrant teal-to-blue gradient" that "flows and pulses horizontally" across the bottom input bar, "contained within the pill-shaped container". It suggests sound without drawing waveform lines. — [60fps.design, Grok Voice Gradient Animation](https://60fps.design/shots/grok-voice-gradient-animation). Date is uncertain: the page shows today's date as its publish date, while a search index described it as ~632 days old (around early 2025).

**Meta AI**
- Meta Connect 2026 announced a "great voice mode" for its agent Muse, with voices designed by description, but nothing on visuals. — [Meta Connect 2026 blog](https://www.meta.com/blog/meta-connect-2026-everything-we-announced/)
- On glasses, Meta AI responds "via visuals on the lenses (for Meta Ray-Ban Display) or audio in open-ear speakers (for all models)". — [Meta, AI glasses voice assistant](https://www.meta.com/ca/ai-glasses/ai-glasses-voice-assistant/)

### Inferences
- Color families: Apple goes dark, desaturated and glass-based, keeping color only in the waveform. Google, OpenAI, Amazon and xAI stick with blue/cyan. Microsoft uses changing color as personality. Perplexity uses monochrome dot particles. No major assistant uses a pure monochrome glowing orb as its headline visual. The monochrome or near-monochrome options are Apple's dark glass orb and Perplexity's dot sphere.
- Apple's "Siri glow" brand color (warm pink, orange, purple, blue) now lives in the waveform and the app icon, not in a full-screen effect. The color became a signature accent instead of an environment.
- My recollection of the iOS 18 edge glow is roughly orange, pink, purple and blue/cyan, and that it shipped with Apple Intelligence in iOS 18.1 (Oct 2024). I did not verify this from a primary source this session.

### Gaps
- No official hex values or gradient stops for any assistant (Siri, ChatGPT orb, Gemini glow, Grok gradient).
- I found no reliable description of the shipped Siri app's internal UI, or of what iOS 27 systemwide dictation looks like (cursor indicator, waveform, glow).
- I found no reliable text description of the original 2024–2025 Gemini Live full-screen look. Articles show screenshots without describing them.
- What the current ChatGPT in-chat voice indicator looks like inside the composer is not described in any source I found.
- Claude's voice orb color, shape and size are not documented officially. The only source is a secondary article citing user reports.
- The Meta AI app voice mode visuals and Copilot's non-Mico voice UI have no reliable descriptions.

---

## 2. How does each react to the user's voice (volume, pitch, rhythm), and does it differ while the AI speaks?

### Takeaway
Where it is documented, reactivity is almost always amplitude-driven (loudness → size, pulse or glow intensity), not pitch-driven. Apple is the one vendor that clearly splits the roles: in iOS 27 the orb "pulses slightly" while a separate multicolor waveform carries real-time speech reactivity. Most products don't publicly separate "user speaking" from "AI speaking" visuals. Claude's orb reportedly uses the same glow pulse for both.

### Cited Findings
- iOS 18 edge light "responsively animates with the sound of your voice." — [Apple iOS 18 features PDF](https://apple.com/ios/ios-18/pdf/iOS_18_All_New_Features_Sept_2024.pdf)
- iOS 27: the orb "pulses slightly to show it's listening" and "the waveform reacts in real time to the user's speech." — [MacStories iOS 27 review](https://www.macstories.net/stories/ios-and-ipados-27-review/5/)
- Gemini: an earlier test showed a blue pill-shaped waveform that reacts in real time when users speak. In the July 2026 teardown, overlay edges "blur slightly when you're communicating with Gemini." — search summary of [Android Headlines](https://www.androidheadlines.com/2026/10/google-gemini-live-redesign-leak.html)/[Trend Hunter](https://www.trendhunter.com/trends/ai-voice-interfaces); [Android Authority, July 2026](https://www.androidauthority.com/gemini-overlay-live-neural-design-apk-teardown-3690991/)
- Gemini voice input (Mar 2026): voice input "stays active for a while" if you do nothing, and Gemini "won't cut you off" when you "pause, take a breath, or ramble". Transcript text is not shown live and appears only after tapping Stop. — [9to5Google](https://9to5google.com/2026/03/19/gemini-voice-input-redesign/)
- Claude: the orb glow pulses "to signal that the model is speaking or listening". No distinct per-state styling is described. — [Crypto Briefing](https://cryptobriefing.com/anthropic-claude-voice-mode-ui-update/)
- Perplexity: the sphere reacts as you speak, which signals that it is listening. Swiping scatters the dots, which then return. — [First AI Movers](https://www.firstaimovers.com/p/perplexity-voice-mode); [TestingCatalog](https://www.testingcatalog.com/new-perplexity-ios-update-brings-redesigned-voice-mode-and-claude-sonnet-3-7.md)
- Alexa+: the blue animation "changes shape as you talk". — [PCWorld](https://www.pcworld.com/article/2617852/a-new-alexa-ai-is-coming-what-it-will-cost-and-when-you-can-try-it.html) (via search summary)
- Copilot Mico "listens, reacts" and changes colors/expressions to the conversation's mood. This is semantic or emotional reactivity, not just loudness. — [TechCrunch](https://techcrunch.com/2025/10/23/microsofts-mico-is-a-clippy-for-the-ai-era)
- ChatGPT GPT-Live is full-duplex ("listen and talk at the same time"), so in principle user and AI audio can overlap. The UI treatment of that is not described. — [OpenAI](https://openai.com/index/introducing-gpt-live)
- Recreation technique: one ChatGPT-style orb uses "normalized RMS amplitude calculation to drive the fluid orb". It "pulses with real-time audio harmonics whenever you speak or listen" and visualizes "speech cadence" during TTS. — [GitHub heyogeshcode/voice-orb](https://github.com/heyogeshcode/voice-orb)
- A developer's Gemini Live "Orb" component (not Google's) maps volume to CSS `transform: scale()` and `opacity`. — [Medium, Felipe Lujan](https://felipelujan.medium.com/gemini-live-api-proactive-in-next-js-and-react-native-expo-26d070dafff9?postPublishedType=initial) (via search summary)

### Inferences
- The industry default, and the cheapest robust signal, is RMS loudness → scale, brightness or glow radius, smoothed. Pitch reactivity isn't documented anywhere. Rhythm comes through only indirectly, via amplitude envelopes.
- Apple's split (a calm container that "breathes" plus a separate reactive waveform) looks like a deliberate restraint pattern: the main object stays stable and premium, and the fast, noisy signal goes into a thin secondary element.
- Full-duplex models (GPT-Live) reduce the need for a strong "your turn / my turn" visual, which may explain why OpenAI is downplaying the orb in favor of in-chat text and cards.

### Gaps
- No vendor publishes its audio-to-visual mapping (smoothing windows, attack/release, frequency bands).
- I found no description of how ChatGPT's orb (separate mode) differs between user speech and AI speech, or how Siri iOS 27 looks while Siri speaks the answer aloud.

---

## 3. What states exist (idle, listening, thinking, speaking, interrupted, error), and how do they look and transition?

### Takeaway
Siri in iOS 27 is the best documented: spatial transitions from the Dynamic Island, where each state is a physical change in the same glass object (descend → pulse → shrink to a spinner → expand into an overlay). Alexa has a long-standing documented light grammar (listening, processing, responding). Most others document only "listening" and "speaking". Interrupted and error states are not described for any assistant in what I found.

### Cited Findings
**Siri iOS 27 (shipped):**
- Invoke: on iPhone the orb "smoothly descends from the Dynamic Island". On iPad it "emerges from the bezel like a drop of liquid and lands at the top of the screen", triggerable from anywhere in the status bar. — [MacStories](https://www.macstories.net/stories/ios-and-ipados-27-review/5/)
- Listening: the orb pulses slightly and the waveform reacts in real time. — [MacStories](https://www.macstories.net/stories/ios-and-ipados-27-review/5/)
- Thinking: the orb "shrinks into a 'thinking' indicator with a loading spinner". — [MacStories](https://www.macstories.net/stories/ios-and-ipados-27-review/5/)
- Answer: the orb "expands into a dark, translucent overlay" with text, images and App Intents snippets (a Reminders snippet, a photo grid, an inline Notes card). Swiping down on a response lets you type. — [MacStories](https://www.macstories.net/stories/ios-and-ipados-27-review/5/)
- Typed entry: swiping down on the Dynamic Island opens a shared Siri/Spotlight field ("Search or Ask"). When a question is detected, an "Ask Siri" option appears. — [MacStories](https://www.macstories.net/stories/ios-and-ipados-27-review/5/)
- Pre-release reporting described the processing state as "a glowing, pill-shaped animation in the Dynamic Island" and the answer as the Island expanding into a transparent card. Swiping the card opens an iMessage-like conversation. — [MacRumors, June 2 2026](https://www.macrumors.com/2026/06/02/ios-27-siri-features/)

**ChatGPT:**
- Separate mode: a full-screen animated blue circle with mute, live video and X (end). In-chat mode (default since Nov 2025): live transcript and visuals in the thread, and "end" returns to text. — [TechCrunch, Nov 25 2025](https://techcrunch.com/2025/11/25/chatgpts-voice-mode-is-no-longer-a-separate-interface/)

**Gemini:**
- Voice input states: listening (waveform in place of the text field) → Stop (prompt box returns with the transcript) or Send (submits immediately). The Send button pulsates slightly. — [9to5Google](https://9to5google.com/2026/03/19/gemini-voice-input-redesign/)
- Overlay launch animation is slowed down for a "hypnagogic appearance". — [Android Authority, July 2026](https://www.androidauthority.com/gemini-overlay-live-neural-design-apk-teardown-3690991/)
- Wear OS: Gemini may get glow animations to show when it is listening, processing or responding. — [Trusted Reviews](https://www.trustedreviews.com/news/gemini-for-wear-os-could-get-a-major-upgrade-soon) (via search summary; teardown/rumor)

**Alexa / Echo (long-standing light grammar, extended for Alexa+):**
- Echo Show: a cyan spotlight on a blue bar means listening, and a teal bar means Alexa is ready for you to speak. — [Amazon Customer Service](https://www.amazon.com/gp/help/customer/display.html?nodeId=TaI3C5lPJp9GBipa94) (via search summary)
- Secondary guide: a blue pulse when a command is heard, a blue light traveling around the ring while processing, and a blue pulse at the bottom while responding. — [Smart Home Perfected](https://www.smarthomeperfected.com/alexa-blue-ring/) (via search summary; secondary)
- Echo Studio's upgraded light ring is meant to show "what Alexa is doing or processing." — [TechCrunch, Sept 30 2025](https://techcrunch.com/2025/09/30/amazon-unveils-new-echo-devices-powered-by-its-al-alexa)

**Claude:**
- A hold-to-talk button (push-to-talk) was added in addition to the open-mic flow. The orb glow marks the speaking and listening states. — [Crypto Briefing](https://cryptobriefing.com/anthropic-claude-voice-mode-ui-update/)

**Grok:** a listening state is documented (horizontal flowing gradient in the input pill). — [60fps.design](https://60fps.design/shots/grok-voice-gradient-animation)

**Common community state model:** open-source orb libraries standardize on idle → listening → thinking → speaking. One gallery uses a "7-state contract" across 15+ audio-reactive React orbs. — [GitHub deqodegroup/voiceorbs](https://github.com/deqodegroup/voiceorbs) (title/snippet); [Webdevpuneet Voice Assistant Orb](https://webdevpuneet.com/ui-snippets/voice-assistant-orb/) (via search summary)

### Inferences
- The sophisticated pattern (Apple) is one persistent object that changes size and position between states (morphing), instead of swapping animations. Thinking becomes a smaller, quieter shape and answering becomes a container. This matches Liquid Glass "morph" behavior.
- Alexa's older grammar (listening = spotlight toward the speaker, processing = rotation/travel, responding = pulse) is still the clearest mental model for state legibility. Rotation or sweeping motion for "processing" is a cross-vendor convention (Alexa ring, Siri spinner).
- Explicit stop/send buttons (Gemini) and hold-to-talk (Claude) show vendors adding manual control back alongside auto end-of-turn detection. A voice-capture app benefits from a visible "stop/commit" affordance.

### Gaps
- No assistant documents interrupted (barge-in) or error/no-network visuals publicly.
- Transition timings (ms) and easing curves are unpublished for all vendors.

---

## 4. What technique is known or likely (shaders, Lottie, Rive, video loops, mesh gradients, particles)?

### Takeaway
No major vendor has published how its voice visual is built. Community recreations point to GPU shaders: Metal fragment shaders, or angular gradients plus layered blurs, for Apple's glow, and GLSL noise/fresnel shaders for the ChatGPT-style orb. Cheap but convincing CSS/SwiftUI versions use two counter-rotating blurred conic gradients. iOS 27's orb is built from Liquid Glass, which suggests Apple's system glass material rather than a bespoke particle effect.

### Cited Findings
- Apple Intelligence glow recreations in SwiftUI:
  - "Aurora": an Apple-Intelligence-style glow for SwiftUI "backed by Metal shaders", using a single fragment shader with several palettes including an Apple Intelligence one. — [Aurora landing](https://tornikegomareli.github.io/aurora-landing/)
  - "IntelligenceGlow": an overlay for any `InsettableShape` built from "animated angular gradients, layered blurs, and smooth transitions." — [Livsy90/IntelligenceGlow](https://uithub.com/Livsy90/IntelligenceGlow)
  - A minimal Metal approach: SwiftUI `colorEffect` with a `[[ stitchable ]]` function taking origin, size and a progress value. — [Gist, uvolchyk](https://gist.github.com/uvolchyk/d7c29dc3eb47f5e109ccb6cf102a7421)
  - macOS recreation with Core Animation: four stacked `CAShapeLayer`s at different blur levels for a neon halo. — [DEV Community](https://dev.to/vector4wang/i-recreated-iphones-apple-intelligence-edge-glow-effect-on-mac-57f5)
  - Apple's official shader pipeline: SwiftUI runs fragment shaders per pixel (WWDC24 "Create custom visual effects with SwiftUI"). WWDC26 session 322 covers `layerEffect` for sampling and warping the underlying view. — [WWDC24 10151](https://developer.apple.com/videos/play/wwdc2024/10151/); [WWDC26 322](https://developer.apple.com/videos/play/wwdc2026/322)
  - Shader library for SwiftUI (glows, noise, transitions): [twostraws/Inferno](https://github.com/twostraws/Inferno)
- ChatGPT-orb recreations (OpenAI has not published its implementation):
  - A GLSL fragment shader with "an opaline white core, electric cyan luminescence, azure harmonics, and midnight indigo boundaries", at 60 FPS, driven by normalized RMS amplitude. — [heyogeshcode/voice-orb](https://github.com/heyogeshcode/voice-orb)
  - Another common approach: a vertex shader doing simplex-noise displacement from audio levels plus a fragment shader for color and fresnel edge glow (Three.js/WebGL). — search summary of orb recreations (e.g. [aguscruiz/voiceorb](https://github.com/aguscruiz/voiceorb), [ui.wensity ChatGPT Orb](https://ui.wensity.com/components/chatgpt-orb)); exact repo attribution unverified
  - Fractal noise drifting inside a circular mask, "blooming from white into the accent color". — search summary (e.g. [beUI Voice Orb](https://beui.dev/components/agents/voice-orb), [21st.dev Voice Orb](https://21st.dev/@starc007/components/voice-orb)); exact repo attribution unverified
- Pure-CSS iridescent orb (generic, not tied to a vendor): two pseudo-elements, each a conic gradient with `filter: blur(12px)`. The top layer spins clockwise over 9 s. The second spins in reverse over 5.8 s at 0.6 opacity with `mix-blend-mode: screen`. `inset: -25%` keeps the blur edge outside the clip, with `overflow:hidden` and `border-radius:50%`. Palettes: `#22d3ee`, `#4d9dff`, `#a855f7` and `#6366f1`, `#06b6d4`, `#c084fc`. Listening shortens the spin to 3 s and sharpens the blur to 8 px. State is set through CSS custom properties, not separate keyframes. — [Adrián Álvarez, "The AI voice orb"](https://www.adrian-alvarez.com/en/snippets/ai-voice-orb/)
- Siri iOS 27 orb is "made out of Liquid Glass" and refracts content beneath it. — [MacStories](https://www.macstories.net/stories/ios-and-ipados-27-review/5/)
- Perplexity's visual is a particle-style dot sphere whose dots scatter on swipe and re-form. — [TestingCatalog](https://www.testingcatalog.com/new-perplexity-ios-update-brings-redesigned-voice-mode-and-claude-sonnet-3-7.md)
- Gemini's Oct 2026 test: dots that warp the space around them ("black hole"). The July 2026 overlay is "not truly transparent" but fakes a glow. — [Android Authority Oct 2026](https://www.androidauthority.com/gemini-live-neural-expressive-audio-visualizer-redesign-3728666/); [Android Authority July 2026](https://www.androidauthority.com/gemini-overlay-live-neural-design-apk-teardown-3690991/)

### Inferences
- The "black hole" dot warp in Gemini and the refracting Liquid Glass orb in Siri both imply real-time distortion shaders (sampling and displacing the background), not Lottie or video loops. For SwiftUI that maps to `layerEffect` / `distortionEffect` (WWDC26 322). On iOS 26+ the native `glassEffect` material can supply the glass container.
- Lottie/Rive suits character-style avatars like Copilot's Mico, which has discrete expressions. Microsoft hasn't confirmed the technique, so this is a guess.
- A cost-efficient iOS path that matches the look: a SwiftUI `Canvas`/`TimelineView` or a Metal fragment shader for the orb body (noise + soft radial falloff), driven by smoothed RMS from `AVAudioEngine`, plus a thin separate waveform or ring for fast reactivity.

### Gaps
- No engineering blog, WWDC session or teardown documents how Apple actually builds the Siri glow, waveform or orb, or how OpenAI builds its orb. Everything above is a recreation.
- No information on whether any vendor uses Rive, Lottie or video loops for voice states.

---

## 5. What makes these feel modern/premium versus generic? Design commentary and criticism

### Takeaway
In 2026 the "premium" signals are restraint and physical continuity: dark, low-saturation, glass materials, one object that morphs between states, and motion that is fluid and interruptible (Apple iOS 27, which reviewers praised). "Generic" signals are the saturated blue/purple gradient blob, full-screen ambient glows that cover content, and visuals that feel unfinished or keep changing (Gemini's repeated redesigns, criticized as glitchy). Character avatars (Mico) are polarizing and get framed as "Clippy."

### Cited Findings
- MacStories on iOS 27 Siri: "The fluidity and responsiveness of the animations are top notch." On the iPad drop-of-liquid transition: "I can't stop staring at this." — [MacStories](https://www.macstories.net/stories/ios-and-ipados-27-review/5/)
- iOS 27 shades are "softer and less saturated than the current Siri glow." — [MacRumors](https://www.macrumors.com/2026/05/26/ios-27-siri-dark-colors/)
- Gemini Live's Neural Expressive test: "The new UI is a work in progress, and its animations aren't all that perfect just yet," with visible glitches. — [Android Authority](https://www.androidauthority.com/gemini-live-neural-expressive-audio-visualizer-redesign-3728666/)
- Headline critique: "Google Still Can't Decide How Gemini Live Should Actually Look, Now Testing Glowing Circle." — [Android Headlines, Oct 2026](https://www.androidheadlines.com/2026/10/google-gemini-live-redesign-leak.html)
- Perplexity's dot-sphere redesign was called a "well-designed, futuristic voice UI" and a "futuristic makeover". — [TestingCatalog](https://www.testingcatalog.com/new-perplexity-ios-update-brings-redesigned-voice-mode-and-claude-sonnet-3-7.md); [TechRadar](https://www.techradar.com/computing/artificial-intelligence/perplexitys-voice-mode-gets-a-futuristic-makeover-on-your-iphone)
- Mico framed as "Microsoft's Clippy for the AI age" (Engadget) and "a Clippy for the AI era" (TechCrunch). Tapping it repeatedly turns it into Clippy. Suleyman: "we're not chasing engagement or optimizing for screen time." — [Engadget](https://www.engadget.com/ai/mico-is-microsofts-clippy-for-the-ai-age-174524597.html); [TechCrunch](https://techcrunch.com/2025/10/23/microsofts-mico-is-a-clippy-for-the-ai-era)
- The ChatGPT move into chat was framed as fixing a "major problem": users previously had to leave voice mode to read a reply. — [PhoneArena](https://www.phonearena.com/news/chatgpt-voice-mode-is-accessible-in-chat_id176082); [TechCrunch](https://techcrunch.com/2025/11/25/chatgpts-voice-mode-is-no-longer-a-separate-interface/)
- Craft guidance from the CSS orb write-up: two layers at speeds "that never resync" read as liquid rather than a "colour wheel". Reduced motion should stop the spin. The orb "is also decoration" (`aria-hidden`, real state in text). Keep it small, because "a 40rem hero version of the same code will make a laptop fan spin." — [Adrián Álvarez](https://www.adrian-alvarez.com/en/snippets/ai-voice-orb/)
- Grok's gradient is noted for signaling sound "without drawing waveform lines", kept "contained within the pill-shaped container." — [60fps.design](https://60fps.design/shots/grok-voice-gradient-animation)
- Low-reliability critique of Claude: the mic and waveform icons are confusingly similar. — [Sumiksha Services](https://sumikshaservices.com/2026/08/09/how-to-use-claude-s-voice-mode-anthropic-s-chatbot-can-be-very-vocal-if-you-want/) (opinion piece; treat with caution). A 2026 review scored Claude voice naturalness/turn-taking 3.4/5. — [Kompozy](https://kompozy.io/reviews/claude-voice-mode)

### Inferences
- Premium (as of late 2026): (1) a single object with continuous morphing between states, (2) dark or neutral base with one restrained accent, (3) real material (glass, refraction, depth) instead of flat gradients, (4) motion anchored to hardware or layout (it comes from the Dynamic Island or the input field), (5) calm container plus separate fine-grained reactivity, (6) content-first: the visual gets out of the way once there is text or a result.
- Generic: a saturated blue-purple-cyan blob in the middle of a blank screen (the 2024 ChatGPT/assistant-orb template copied by hundreds of open-source components), always-on rainbow gradients, and fast pulsing that reads as anxious.
- For a minimalist iOS voice-capture app (no assistant persona, just capture), the closest references are Apple iOS 27 (glass orb + thin waveform + morph to a spinner), Gemini's March 2026 move (waveform replaces the text field, explicit Stop/Send) and Grok's contained gradient in the input pill. All three keep the visual inside the existing input surface instead of taking over the screen.
- A monochrome or near-monochrome treatment (white/graphite glass with a single accent tied to brand) would stand apart from the blue/cyan default most assistants share.

### Gaps
- I found no long-form design-press critique (e.g., Fast Company design, The Verge) specifically comparing assistant listening visuals in 2026. The Fast Company Mico article returned HTTP 403.
- No designer interviews from Apple, OpenAI or Google explaining the rationale for their 2026 voice visuals were found.
