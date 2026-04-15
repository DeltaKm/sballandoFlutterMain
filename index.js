 // Mobile-specific parallax coordinates with 12 phases
  let scale = 1,
  translateY = 0,
  translateX = 0,
  rotation = 0;

if (scrollProgress <= 0.0556) {
  // Phase 1: ...
  const phase1Progress    = scrollProgress / 0.0833;
  const easedProgress     = phase1Progress * phase1Progress * (3 - 2 * phase1Progress);
  scale                   = 0.8 + easedProgress * 1.2;
  translateY              = easedProgress * -20;
  translateX              = 0;
  rotation                = 0;

} else if (scrollProgress <= 0.1111) {
  // Phase 2: ...
  scale = 2.0;
  translateY = -20;
  translateX = 0;
  rotation = 0;

} else if (scrollProgress <= 0.1667) {
  // Phase 3: ...
  const phase3Progress      = (scrollProgress - 0.1667) / 0.0833;
  const easedPhase3         = phase3Progress * phase3Progress * (3 - 2 * phase3Progress);
  scale                     = 2.0 + easedPhase3 * 0.15;
  translateY                = -20 + easedPhase3 * 1.5;
  translateX                = 0;
  rotation                  = 0;

} else if (scrollProgress <= 0.2222) {
  // Phase 4: ...
  const phase4Progress = (scrollProgress - 0.2222) / 0.0833;

  if (phase4Progress <= 0.5) {
    // Sub-phase 4a: Return back (zoom out) with easing
    const returnProgress    = phase4Progress / 0.5;
    const easedReturn       =  returnProgress * returnProgress * (3 - 2 * returnProgress);
    scale                   = 2.15 - easedReturn * 0.65;
    translateY              = -18.5 + easedReturn * 8.5;
    translateX              = 0;
    rotation                = 0;

  } else {
    // Sub-phase 4b: Zoom on left vertical wave with rotation and easing
    const zoomProgress      = (phase4Progress - 0.5) / 0.5;
    const easedZoom         = zoomProgress * zoomProgress * (3 - 2 * zoomProgress);
    scale                   = 1.5 + easedZoom * 1.0;
    translateY              = -10 + easedZoom * 15;
    translateX              = 0;
    rotation                = easedZoom * 90;

  }
} else if (scrollProgress <= 0.2778) {
  // Phase 5: ...
  scale                     = 2.5;
  translateY                = 5;
  translateX                = 0;
  rotation                  = 90;

} else if (scrollProgress <= 0.3333) {
  // Phase 6: ...
  const phase6Progress      = (scrollProgress - 0.4167) / 0.0833;
  const easedPhase6         = phase6Progress * phase6Progress * (3 - 2 * phase6Progress);
  scale                     = 2.5 + easedPhase6 * 0.08;
  translateY                = 5 + easedPhase6 * -1.5;
  translateX                = 0;
  rotation                  = 90 + easedPhase6 * 4;

} else if (scrollProgress <= 0.3889) {
  // Phase 7: ...
  const phase7Progress = (scrollProgress - 0.5) / 0.0833;

  if (phase7Progress <= 0.4) {
    // Sub-phase 7a: Zoom back from vertical wave with easing
    const zoomBackProgress = phase7Progress / 0.4;
    const easedZoomBack =  zoomBackProgress * zoomBackProgress * (3 - 2 * zoomBackProgress);
    scale = 2.58 - easedZoomBack * 1.08;
    translateY = 3.5 - easedZoomBack * 3.5;
    translateX = 0;
    rotation = 94 - easedZoomBack * 94;
  } else {
    // Sub-phase 7b: Approach phase 8 final position with easing
    const approachProgress = (phase7Progress - 0.4) / 0.6;
    const easedApproach =  approachProgress * approachProgress * (3 - 2 * approachProgress);
    scale = 1.5 + easedApproach * 1.5;
    translateY = 0 + easedApproach * -8;
    translateX = 0;
    rotation = 0;
  }
} else if (scrollProgress <= 0.4444) {
  // Phase 8: ...
  scale = 3.0;
  translateY = -8;
  translateX = 0;
  rotation = 0;
} else if (scrollProgress <= 0.5) {
  // Phase 9: ...
  const phase9Progress = (scrollProgress - 0.6667) / 0.0833;
  const easedPhase9 = phase9Progress * phase9Progress * (3 - 2 * phase9Progress);
  scale = 3.0 + easedPhase9 * 1.5;
  translateY = -8 + easedPhase9 * (-40);
  translateX = 0;
  rotation = 0;
} else if (scrollProgress <= 0.5556) {
  // Phase 10: ...
  scale = 4.5;
  translateY = -48;
  translateX = 0;
  rotation = 0;
} else if (scrollProgress <= 0.6111) {
  // Phase 11: ...
  const phase11Progress = (scrollProgress - 0.8333) / 0.0833;
  const easedPhase11 =  phase11Progress * phase11Progress * (3 - 2 * phase11Progress);
  scale = 4.5 + easedPhase11 * 0.3;
  translateY = -48 + easedPhase11 * (-8);
  translateX = 0;
  rotation = 0;
} else if (scrollProgress <= 0.6667) {
  // Phase 12: ...
  scale = 4.8;
  translateY = -56;
  translateX = 0;
  rotation = 0;
} else if (scrollProgress <= 0.7222) {
  // Phase 13: ...
} else if (scrollProgress <= 0.7778) {
  // Phase 14: ...
} else if (scrollProgress <= 0.8333) {
  // Phase 15: ...
} else if (scrollProgress <= 0.8889) {
  // Phase 16: ...
} else if (scrollProgress <= 0.9444) {
  // Phase 17: ...
} else {
  // Phase 18: ...
}
