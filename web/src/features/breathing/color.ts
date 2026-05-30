// Lavender-constrained palette for phase color transitions.
// Constrains the original index.html's random RGB pool to on-brand hues.

export interface RGB { r: number; g: number; b: number }

export function rgb(r: number, g: number, b: number): RGB {
  return { r, g, b };
}

export function toCss(c: RGB, alpha = 1): string {
  return alpha === 1
    ? `rgb(${c.r},${c.g},${c.b})`
    : `rgba(${c.r},${c.g},${c.b},${alpha})`;
}

export function lerp(a: number, b: number, t: number): number {
  return a + (b - a) * t;
}

export function lerpColor(a: RGB, b: RGB, t: number): RGB {
  return {
    r: Math.round(lerp(a.r, b.r, t)),
    g: Math.round(lerp(a.g, b.g, t)),
    b: Math.round(lerp(a.b, b.b, t)),
  };
}

export function lighten(c: RGB, t: number): string {
  const clamp = (v: number) => Math.max(0, Math.min(255, Math.floor(v * t)));
  return `rgb(${clamp(c.r)},${clamp(c.g)},${clamp(c.b)})`;
}

// HSL → RGB, used to keep phase end-colors within the lavender band.
function hslToRgb(h: number, s: number, l: number): RGB {
  h /= 360; s /= 100; l /= 100;
  const a = s * Math.min(l, 1 - l);
  const f = (n: number) => {
    const k = (n + h * 12) % 12;
    return Math.round(255 * (l - a * Math.max(-1, Math.min(k - 3, 9 - k, 1))));
  };
  return { r: f(0), g: f(8), b: f(4) };
}

const rand = (min: number, max: number) => Math.random() * (max - min) + min;

/**
 * Returns an on-brand "next phase" color in the lavender range.
 * H 250–280, S 30–55, L 55–75 keeps the orb tonal and calm.
 */
export function nextLavenderColor(): RGB {
  return hslToRgb(rand(250, 280), rand(30, 55), rand(55, 75));
}

export const DEFAULT_ORB_COLOR: RGB = hslToRgb(262, 45, 65); // ~#A78BFA-ish
