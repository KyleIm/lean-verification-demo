#!/usr/bin/env python3
"""Provisional reconstruction using only the revised trusted geometry caption.

The authorized user-supplied image is not currently accessible. This drawing
therefore makes no visual-fidelity claim. Projection and label positions are
illustrative choices; no independent reference image, solution or proof is read.
"""
from pathlib import Path
from math import sin, cos, radians
from html import escape
import json

ROOT = Path(__file__).resolve().parent


def main():
    source = json.loads((ROOT / 'source.jsonl').read_text())
    caption = source['diagram_caption']
    assert source['diagram_geometry'] == {
        'shape': 'short annular cylinder', 'inner_radius': 'a',
        'outer_radius': 'b', 'axial_height': 'h', 'axis': 'vertical',
        'section': 'vertical rectangular radial section',
        'radial_cut': {'side': 'right', 'radial_span': ['a', 'b'],
                       'full_axial_height': 'h'}}
    cx, top, height = 300, 150, 95
    inner, outer, flatten = 110, 220, .34
    bottom = top + height

    def line(a, b, css='edge', extra=''):
        return (f'<line x1="{a[0]:.3f}" y1="{a[1]:.3f}" '
                f'x2="{b[0]:.3f}" y2="{b[1]:.3f}" class="{css}" {extra}/>')

    def arc(radius, y, start, stop, css='edge'):
        points = []
        for i in range(121):
            angle = radians(start + (stop-start)*i/120)
            points.append((cx+radius*cos(angle), y+radius*flatten*sin(angle)))
        coordinates = ' '.join(f'{x:.3f},{y:.3f}' for x, y in points)
        return f'<polyline points="{coordinates}" class="{css}"/>'

    def label(x, y, value):
        return f'<text class="label" x="{x}" y="{y}">{value}</text>'

    def dimension(a, b):
        return line(a, b, 'dimension',
                    'marker-start="url(#arrow)" marker-end="url(#arrow)"')

    svg = [
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 680 390" width="680" height="390" role="img" aria-labelledby="title desc">',
        '<title id="title">Provisional caption-based Fig. 203: annular cylinder with right radial section</title>',
        f'<desc id="desc">{escape(caption)}</desc>',
        '<defs>',
        '<pattern id="section-hatch" width="12" height="12" patternUnits="userSpaceOnUse" patternTransform="rotate(42)"><line x1="0" y1="0" x2="0" y2="12" stroke="#222" stroke-width="1.2"/></pattern>',
        '<marker id="arrow" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M 10 0 L 0 5 L 10 10" fill="none" stroke="#111" stroke-width="1.4"/></marker>',
        '</defs>',
        '<style>.edge,.hidden,.axis,.dimension{fill:none;stroke:#111;stroke-linecap:round;stroke-linejoin:round}.edge{stroke-width:2}.hidden{stroke-width:1.5;stroke-dasharray:7 5}.axis{stroke-width:1.3}.dimension{stroke-width:1.2}.section{stroke:#111;stroke-width:2;fill:url(#section-hatch)}.label{font-family:serif;font-size:29px;font-style:italic;text-anchor:middle;fill:#111;paint-order:stroke;stroke:white;stroke-width:5px}.caption{font-family:serif;font-size:20px;fill:#111}</style>',
        '<rect width="680" height="410" fill="white"/>',
        # Dashed lines are illustrative hidden cylindrical boundaries.
        arc(outer, bottom, 180, 360, 'hidden'),
        arc(inner, bottom, 0, 360, 'hidden'),
        line((cx-inner, top), (cx-inner, bottom), 'hidden'),
        line((cx+inner, top), (cx+inner, bottom), 'hidden'),
        # The caption specifies one full-height right radial rectangular section.
        # No extra wedge angle, detached section or arbitrary notch is introduced.
        f'<rect id="right-radial-section" class="section" x="{cx+inner}" y="{top}" width="{outer-inner}" height="{height}"/>',
        arc(outer, top, 0, 360),
        arc(inner, top, 0, 360),
        line((cx-outer, top), (cx-outer, bottom)),
        line((cx+outer, top), (cx+outer, bottom)),
        arc(outer, bottom, 0, 180),
        line((cx, top-65), (cx, bottom+65), 'axis'),
        # Radius dimensions lie on the top plane, not at an image-derived position.
        dimension((cx, top), (cx-inner, top)),
        label(cx-inner/2, top-13, 'a'),
        dimension((cx, top), (cx-outer*.6, top-outer*.8*flatten)),
        label(cx-outer*.3-13, top-outer*.4*flatten-12, 'b'),
        line((cx+outer+7, top), (cx+outer+61, top), 'dimension'),
        line((cx+outer+7, bottom), (cx+outer+61, bottom), 'dimension'),
        dimension((cx+outer+47, top+4), (cx+outer+47, bottom-4)),
        label(cx+outer+76, top+height/2+9, 'h'),
        '<text class="caption" x="70" y="365">Fig. 203 — provisional caption-based reconstruction</text>',
        '</svg>']
    (ROOT / 'problem_diagram.svg').write_text('\n'.join(svg) + '\n')


if __name__ == '__main__':
    main()
