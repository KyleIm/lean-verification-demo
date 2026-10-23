#!/usr/bin/env python3
"""Deterministic Fig. 203 reconstruction from caption geometry only.

No solution, field, material or Lean proof data is read. A cutaway is a drawing
convention to expose the caption's rectangular radial section.
"""
from pathlib import Path
from math import sin, cos, radians
from html import escape
import json

ROOT = Path(__file__).resolve().parent

def main():
    source = json.loads((ROOT / 'source.jsonl').read_text())
    caption = source['diagram_caption']
    geometry = source['diagram_geometry']
    assert geometry == {'shape':'annular cylinder','inner_radius':'a',
        'outer_radius':'b','axial_height':'h','axis':'vertical',
        'section':'rectangular radial section'}
    cx, cy, depth = 320, 180, 135
    inner, outer, flatten = 105, 225, .40
    def pt(r, angle, down=0):
        q = radians(angle)
        return (cx + r*cos(q), cy + flatten*r*sin(q)+down)
    def pts(seq):
        return ' '.join(f'{x:.3f},{y:.3f}' for x,y in seq)
    def arc(r, start, stop, down=0):
        return [pt(r, start+(stop-start)*i/120, down) for i in range(121)]
    def polygon(seq, css):
        return f'<polygon points="{pts(seq)}" class="{css}"/>'
    def line(a,b,css='dimension'):
        return f'<line x1="{a[0]:.3f}" y1="{a[1]:.3f}" x2="{b[0]:.3f}" y2="{b[1]:.3f}" class="{css}"/>'
    svg=['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 690 500" role="img" aria-labelledby="title desc">',
      '<title id="title">Figure 203: caption-only reconstruction of a ring with rectangular cross section</title>',
      f'<desc id="desc">{escape(caption)} A chosen perspective cutaway exposes the radial section.</desc>',
      '<defs><pattern id="hatch" width="7" height="7" patternUnits="userSpaceOnUse" patternTransform="rotate(35)"><line x1="0" y1="0" x2="0" y2="7" stroke="#6b596e" stroke-width="2"/></pattern></defs>',
      '<style>polygon{stroke:#263745;stroke-width:2;stroke-linejoin:round}.outer{fill:#acbec9}.inner{fill:#ccd8df}.top{fill:#e4ecf1}.cut{fill:#e3d9e6}.section{fill:url(#hatch)}.axis{stroke:#647280;stroke-width:1.5;stroke-dasharray:7 5}.dimension{stroke:#263745;stroke-width:1.4}text{font-family:DejaVu Sans,Arial,sans-serif;fill:#263745;text-anchor:middle}.label{font-size:23px;font-style:italic}.note{font-size:14px}</style>',
      '<rect width="690" height="500" fill="white"/>']
    # Geometry alone: annular prism with a 0–45 degree illustrative cutaway.
    svg += [polygon(arc(outer,45,180)+arc(outer,180,45,depth),'outer'),
            polygon(arc(inner,180,360)+arc(inner,360,180,depth),'inner'),
            polygon([pt(inner,45),pt(outer,45),pt(outer,45,depth),pt(inner,45,depth)],'cut'),
            polygon(arc(outer,45,360)+arc(inner,360,45),'top')]
    cut=[pt(inner,0),pt(outer,0),pt(outer,0,depth),pt(inner,0,depth)]
    svg += [polygon(cut,'cut'), polygon(cut,'section'),
            line((cx,60),(cx,405),'axis')]
    # Radius labels use distinct directions, with only a,b,h as physical labels.
    for radius, angle, label, offset in [(inner,180,'a',(-6,-12)),(outer,235,'b',(-13,-6))]:
        end=pt(radius,angle)
        svg.append(line((cx,cy),end))
        mx,my=(cx+end[0])/2+offset[0],(cy+end[1])/2+offset[1]
        svg.append(f'<text class="label" x="{mx:.3f}" y="{my:.3f}">{label}</text>')
    x=590
    svg += [line(pt(outer,0),(x+8,cy)),line(pt(outer,0,depth),(x+8,cy+depth)),
            line((x,cy),(x,cy+depth)),line((x-5,cy),(x+5,cy)),line((x-5,cy+depth),(x+5,cy+depth)),
            f'<text class="label" x="{x+20}" y="{cy+depth/2+7}">h</text>',
            '<text class="note" x="345" y="443">Caption-only reconstruction of Fig. 203; dimensions are symbolic.</text>',
            '<text class="note" x="345" y="467">Illustrative cutaway exposes the shaded rectangular radial section.</text>',
            '</svg>']
    (ROOT/'problem_diagram.svg').write_text('\n'.join(svg)+'\n')

if __name__ == '__main__':
    main()
