#!/usr/bin/env python3
"""Deterministic SVG from figure_caption.json only.

No source image was available. The generator/design uses only the user-supplied
caption geometry, not solution values, Lean code or an external source book.
"""
from html import escape
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def render(caption):
    points = caption['vertices']
    assert len(points) >= 2
    assert all(x1 < x2 for (x1, _), (x2, _) in zip(points, points[1:]))
    assert min(y for _, y in points) >= 0
    max_time = max(t for t, _ in points)
    max_velocity = max(v for _, v in points)
    width, height = 800, 420
    left, baseline, sx, sy = 76, 324, 62, 62

    def x(t):
        return left + sx * t

    def y(v):
        return baseline - sy * v

    lines = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" role="img" aria-labelledby="title description">',
        '<title id="title">Fig. 6 — caption-reconstructed velocity–time graph</title>',
        '<desc id="description">A straight-segment polyline through the caption vertices; time in seconds and velocity in centimetres per second. No solution areas or averages are displayed.</desc>',
        '<rect width="800" height="420" fill="white"/>',
        '<defs><marker id="arrow" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0 0 L8 4 L0 8" fill="#222"/></marker></defs>',
        '<g font-family="sans-serif" font-size="15" fill="#222">',
    ]
    for tick in range(int(max_time) + 1):
        lines.append(f'<line x1="{x(tick)}" y1="{y(0)}" x2="{x(tick)}" y2="{y(max_velocity)}" stroke="#e4e4e4"/>')
        lines.append(f'<line x1="{x(tick)}" y1="{baseline}" x2="{x(tick)}" y2="{baseline+5}" stroke="#222"/>')
        lines.append(f'<text x="{x(tick)}" y="{baseline+23}" text-anchor="middle">{tick}</text>')
    for tick in range(1, int(max_velocity) + 1):
        lines.append(f'<line x1="{left}" y1="{y(tick)}" x2="{x(max_time)}" y2="{y(tick)}" stroke="#e4e4e4"/>')
        lines.append(f'<text x="{left-14}" y="{y(tick)+5}" text-anchor="end">{tick}</text>')
    lines.append(f'<line x1="{left}" y1="{baseline}" x2="{x(max_time)+42}" y2="{baseline}" stroke="#222" stroke-width="1.6" marker-end="url(#arrow)"/>')
    lines.append(f'<line x1="{left}" y1="{baseline}" x2="{left}" y2="{y(max_velocity)-35}" stroke="#222" stroke-width="1.6" marker-end="url(#arrow)"/>')
    for mark in caption['marked_times']:
        t = mark['value']
        lines.append(f'<text x="{x(t)}" y="{baseline+49}" text-anchor="middle">{escape(mark["label"])} = {t} s</text>')
    coords = ' '.join(f'{x(t)},{y(v)}' for t, v in points)
    lines.append(f'<polyline points="{coords}" fill="none" stroke="#125a83" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/>')
    for t, v in points:
        lines.append(f'<circle cx="{x(t)}" cy="{y(v)}" r="3.3" fill="#125a83"/>')
    haxis, vaxis = caption['horizontal_axis'], caption['vertical_axis']
    lines.append(f'<text x="{x(max_time)+48}" y="{baseline+5}">{escape(haxis["symbol"])} ({escape(haxis["unit"])})</text>')
    lines.append(f'<text x="{left-35}" y="{y(max_velocity)-48}">{escape(vaxis["symbol"])} ({escape(vaxis["unit"])})</text>')
    lines.append('<text x="400" y="404" text-anchor="middle" font-size="12" fill="#555">Caption-only reconstruction of Fig. 6</text>')
    lines.append('</g></svg>')
    return '\n'.join(lines) + '\n'


if __name__ == '__main__':
    data = json.loads((ROOT / 'figure_caption.json').read_text())
    (ROOT / 'problem_diagram.svg').write_text(render(data))
