#!/usr/bin/env python3
"""Reconstruct Fig. 237 from figure_caption.json geometry alone.

Only the approved qualitative caption is input. Pixel positions, object width,
ray count and visual inclinations below are arbitrary rendering choices, not
source measurements or Lean parameters. No solution, Candidate, Fig. 494, source
scan or computed shadow/boundary information is read. --check compares the
deterministic result with the committed SVG.
"""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def render(caption):
    geometry = caption['geometry']
    assert geometry['view'] == 'two-dimensional vertical cross-section'
    assert geometry['mirror'] == {'orientation': 'horizontal', 'placement': 'bottom'}
    assert geometry['screen'] == {'orientation': 'vertical', 'side': 'right', 'base': 'on mirror'}
    assert geometry['object'] == {
        'shape': 'upright oblong', 'cross_section': 'vertical segment',
        'base': 'on mirror', 'placement': 'between incoming rays and screen',
    }
    assert geometry['rays'] == {
        'incident': 'mutually parallel straight rays obliquely downward toward mirror',
        'reflected': 'from mirror toward screen',
    }
    assert geometry['relative_placement'] == (
        'object horizontally between at least some incident/reflected ray paths and screen')

    # Schematic layout only: no source dimensions, angles or boundary-ray solve.
    width, height = 900, 440
    floor, screen = 350, 810
    object_x, object_top = 530, 265
    reflection_points = (210, 270, 330)
    visual_rise = 0.5
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" role="img" aria-labelledby="title description">',
        '<title id="title">Fig. 237 — caption-derived problem reconstruction</title>',
        '<desc id="description">Horizontal mirror, vertical screen on the right, upright object and parallel oblique incident rays reflected toward the screen. Positions and ray count are schematic rendering choices.</desc>',
        '<rect width="900" height="440" fill="white"/>',
        '<defs><marker id="ray-arrow" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0 0 L8 4 L0 8" fill="#394c5a"/></marker></defs>',
        '<g fill="none" stroke="#222" stroke-width="2">',
        f'<line x1="65" y1="{floor}" x2="{screen}" y2="{floor}"/>',
        f'<line x1="{screen}" y1="40" x2="{screen}" y2="{floor}"/>',
    ]
    # Hatch the mirror backing, never a shadow or screen illumination interval.
    for x in range(75, screen, 18):
        parts.append(f'<line x1="{x}" y1="{floor+2}" x2="{x-9}" y2="{floor+11}" stroke-width="1"/>')
    parts.append('</g>')
    parts.append('<g fill="none" stroke="#394c5a" stroke-width="1.8">')
    for r in reflection_points:
        start_x = r - 180
        start_y = floor - 180 * visual_rise
        end_y = floor - (screen-r) * visual_rise
        parts.append(f'<path d="M {start_x} {start_y:g} L {r} {floor} L {screen} {end_y:g}"/>')
        # Mid-segment arrows indicate travel direction, not limiting constructions.
        parts.append(f'<path d="M {r-130} {floor-130*visual_rise:g} L {r-90} {floor-90*visual_rise:g}" marker-end="url(#ray-arrow)"/>')
        parts.append(f'<path d="M {r+160} {floor-160*visual_rise:g} L {r+200} {floor-200*visual_rise:g}" marker-end="url(#ray-arrow)"/>')
    parts.append('</g>')
    parts.append(f'<rect x="{object_x-5}" y="{object_top}" width="10" height="{floor-object_top}" fill="#333"/>')
    parts.extend([
        '<g font-family="sans-serif" font-size="16" fill="#222">',
        '<text x="86" y="231">Incident sunrays</text>',
        '<text x="541" y="155">Reflected rays</text>',
        f'<text x="{object_x+17}" y="{object_top+35}">Object</text>',
        f'<text x="{screen+16}" y="218">Screen</text>',
        '<text x="647" y="388">Horizontal mirror</text>',
        '<text x="450" y="423" text-anchor="middle" font-size="12" fill="#555">Fig. 237 — caption-derived schematic, not a source scan</text>',
        '</g></svg>',
    ])
    return '\n'.join(parts) + '\n'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    data = json.loads((ROOT / 'figure_caption.json').read_text())
    svg = render(data)
    target = ROOT / 'problem_diagram.svg'
    if args.check:
        if target.read_text() != svg:
            raise SystemExit('SVG differs from deterministic caption reconstruction')
        print('Caption-derived SVG: up to date')
    else:
        target.write_text(svg)
