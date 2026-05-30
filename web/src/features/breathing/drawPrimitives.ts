// Canvas drawing primitives ported from /index.html (lines 96-146) with TS types
// and cleaner composition. The donut (`drawPulse2`) and pie sweep (`drawPie`) are
// the visual core of the breathing animation.

export interface StrokeOpts {
  strokeStyle?: string;
  lineWidth?: number;
  lineJoin?: CanvasLineJoin;
}
export interface FillOpts {
  fillStyle?: string;
}
export type DrawOpts = StrokeOpts & FillOpts;

function applyFill(ctx: CanvasRenderingContext2D, o: DrawOpts) {
  if (!o.fillStyle) return;
  ctx.fillStyle = o.fillStyle;
  ctx.fill();
}

function applyStroke(ctx: CanvasRenderingContext2D, o: DrawOpts) {
  if (!o.lineWidth) return;
  if (o.strokeStyle) ctx.strokeStyle = o.strokeStyle;
  ctx.lineWidth = o.lineWidth;
  if (o.lineJoin) ctx.lineJoin = o.lineJoin;
  ctx.stroke();
}

export function drawCircle(
  ctx: CanvasRenderingContext2D,
  x: number, y: number, r: number,
  o: DrawOpts,
) {
  ctx.beginPath();
  ctx.arc(x, y, r, 0, 2 * Math.PI);
  applyFill(ctx, o);
  applyStroke(ctx, o);
}

/** Draws a donut: outer filled circle minus inner circle via destination-out. */
export function drawDonut(
  ctx: CanvasRenderingContext2D,
  x: number, y: number, outerR: number, innerR: number,
  o: DrawOpts,
) {
  drawCircle(ctx, x, y, outerR, o);
  if (innerR > 0) {
    ctx.globalCompositeOperation = 'destination-out';
    drawCircle(ctx, x, y, innerR, { fillStyle: '#000' });
    ctx.globalCompositeOperation = 'source-over';
  }
}

const D2R = (d: number) => (d * Math.PI) / 180;

/** Pie wedge from `startDeg` for `arcDeg` degrees. */
export function drawPie(
  ctx: CanvasRenderingContext2D,
  x: number, y: number,
  outerR: number, innerR: number,
  startDeg: number, arcDeg: number,
  o: DrawOpts,
) {
  const start = D2R(startDeg);
  const end = start + D2R(arcDeg);
  ctx.beginPath();
  ctx.arc(x, y, outerR, start, end, false);
  ctx.arc(x, y, innerR, end,   start, true);
  ctx.closePath();
  applyFill(ctx, o);
  applyStroke(ctx, o);
}
