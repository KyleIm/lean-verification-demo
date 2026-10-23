#!/usr/bin/env python3
"""Deterministic caption-only geometry: intact annulus and radial-section view.

The second view exposes the caption's rectangular section without inventing a
cut or notch in the ring. No physical solution or Lean proof data is read.
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
        'shape': 'annular cylinder', 'inner_radius': 'a', 'outer_radius': 'b',
        'axial_height': 'h', 'axis': 'vertical',
        'section': 'rectangular radial section'}
    cx, cy, depth = 285, 180, 80
    inner, outer, flatten = 120, 220, .48

    def point(r, angle, down=0):
        q = radians(angle)
        return cx + r*cos(q), cy + flatten*r*sin(q)+down

    def arc(r, start, stop, down=0):
        return [point(r, start+(stop-start)*i/120, down) for i in range(121)]

    def polygon(points, css, extra=''):
        coordinates = ' '.join(f'{x:.3f},{y:.3f}' for x,y in points)
        return f'<polygon points="{coordinates}" class="{css}" {extra}/>'

    def line(a, b, css='dimension', extra=''):
        return (f'<line x1="{a[0]:.3f}" y1="{a[1]:.3f}" '
                f'x2="{b[0]:.3f}" y2="{b[1]:.3f}" class="{css}" {extra}/>')

    def text(x, y, label, css='label'):
        return f'<text class="{css}" x="{x}" y="{y}">{label}</text>'

    def dimension(a, b):
        return line(a, b, extra='marker-start="url(#arrow)" marker-end="url(#arrow)"')

    svg = [
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 470" role="img" aria-labelledby="title desc">',
        '<title id="title">Figure 203: ring and rectangular radial section, reconstructed from caption geometry</title>',
        f'<desc id="desc">{escape(caption)} The intact body and its radial section are shown as separate views.</desc>',
        '<defs>',
        '<marker id="arrow" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="5" markerHeight="5" orient="auto-start-reverse"><path d="M 10 0 L 0 5 L 10 10" fill="none" stroke="#263745" stroke-width="1.5"/></marker>',
        '<pattern id="hatch" width="8" height="8" patternUnits="userSpaceOnUse" patternTransform="rotate(35)"><line x1="0" y1="0" x2="0" y2="8" stroke="#74848d" stroke-width="1.5"/></pattern>',
        f'<clipPath id="opening"><ellipse cx="{cx}" cy="{cy}" rx="{inner}" ry="{inner*flatten}"/></clipPath>',
        '</defs>',
        '<style>polygon,.outline{stroke:#263745;stroke-width:2;stroke-linejoin:round}.outer{fill:#bccbd3}.inner{fill:#d2dde3}.axis{stroke:#647280;stroke-width:1.4;stroke-dasharray:8 5}.dimension{stroke:#263745;stroke-width:1.2}text{font-family:DejaVu Sans,Arial,sans-serif;fill:#263745;text-anchor:middle}.label{font-size:23px;font-style:italic;paint-order:stroke;stroke:white;stroke-width:3px}.heading{font-size:18px}.note{font-size:14px}</style>',
        '<rect width="960" height="470" fill="white"/>',
        text(cx, 36, 'Ring — perspective view', 'heading'),
        text(755, 105, 'Rectangular radial section', 'heading'),
        # Front external wall, then the hole and its visible rear internal wall.
        polygon(arc(outer,0,180)+arc(outer,180,0,depth), 'outer'),
        f'<ellipse cx="{cx}" cy="{cy}" rx="{inner}" ry="{inner*flatten}" fill="white"/>',
        polygon(arc(inner,180,360)+arc(inner,360,180,depth), 'inner',
                'clip-path="url(#opening)"'),
        # Even-odd fill keeps the top face an actual annulus with no seam/notch.
        f'<path class="outline" fill="#edf2f5" fill-rule="evenodd" d="M {cx-outer} {cy} a {outer} {outer*flatten} 0 1 0 {2*outer} 0 a {outer} {outer*flatten} 0 1 0 {-2*outer} 0 Z M {cx-inner} {cy} a {inner} {inner*flatten} 0 1 0 {2*inner} 0 a {inner} {inner*flatten} 0 1 0 {-2*inner} 0 Z"/>',
        line((cx,52),(cx,400),'axis'),
    ]
    # Radii are measured from the common axis on the top plane.
    for r, angle, label in [(inner,190,'a'),(outer,225,'b')]:
        end = point(r,angle)
        svg += [dimension((cx,cy),end),
                text((cx+end[0])/2-5,(cy+end[1])/2-10,label)]
    svg += [line((505,180),(548,180)),line((505,260),(548,260)),
            dimension((536,180),(536,260)),text(556,228,'h')]
    # A separate meridional section on one side of the same vertical axis.
    # This is a second view, not a removed wedge or additional piece of material.
    axis, left, right, top, bottom = 635, 705, 855, 170, 250
    svg += [line((axis,130),(axis,365),'axis'),
            '<rect x="705" y="170" width="150" height="80" fill="#edf2f5"/>',
            '<rect class="outline" x="705" y="170" width="150" height="80" fill="url(#hatch)"/>',
            line((left,bottom),(left,306)),line((right,bottom),(right,344)),
            dimension((axis,292),(left,292)),text((axis+left)/2,282,'a'),
            dimension((axis,332),(right,332)),text((axis+right)/2,322,'b'),
            line((right,top),(900,top)),line((right,bottom),(900,bottom)),
            dimension((889,top),(889,bottom)),text(910,218,'h'),
            text(755,390,'Section lies between radii a and b.', 'note'),
            text(480,437,'Caption-only reconstruction of Fig. 203. Dimensions and projection are illustrative.', 'note'),
            '</svg>']
    (ROOT/'problem_diagram.svg').write_text('\n'.join(svg)+'\n')


if __name__ == '__main__':
    main()
