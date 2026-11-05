#!/usr/bin/env python3
"""New schematics authored after direct inspection of the two source images.

15-43-07.png was identified visually as Fig. 253; 15-43-52.png as Fig. 255.
There is no caption input. Layout coordinates and the unlabeled screen-hit height
in the Lloyd picture are rendering choices, not numerical source evidence.
No supplied solution, proof file, scan pixels or final formula is consumed.
"""
import argparse
from pathlib import Path


def frame(title, body):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="860" height="400" viewBox="0 0 860 400">
<title>{title}</title>
<rect width="860" height="400" fill="white"/>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M 0 0 L 10 5 L 0 10" fill="none" stroke="#222" stroke-width="1.5"/></marker></defs>
<g fill="none" stroke="#222" stroke-width="2">{body}</g>
</svg>
'''


def text(x, y, label):
    return f'<text x="{x}" y="{y}" fill="#222" stroke="none" font-family="sans-serif" font-size="24">{label}</text>'


def problem764():
    # The original Fig. 253 has dimension lines, not solution fringe rays.
    body = '<path d="M 740 35 V 365" stroke-width="4"/>'
    body += '<path d="M 125 200 H 740" marker-start="url(#arrow)" marker-end="url(#arrow)"/>'
    body += '<path d="M 80 125 V 275" marker-start="url(#arrow)" marker-end="url(#arrow)"/>'
    body += '<rect x="400" y="183" width="48" height="32" fill="white" stroke="none"/>'
    body += '<rect x="66" y="181" width="28" height="36" fill="white" stroke="none"/>'
    body += '<g fill="#222"><circle cx="125" cy="125" r="4"/><circle cx="125" cy="275" r="4"/><circle cx="740" cy="200" r="4"/></g>'
    body += text(143, 130, 'S₁') + text(143, 282, 'S₂')
    body += text(72, 207, 'l') + text(412, 207, 'D') + text(756, 208, 'A')
    return frame('Two coherent sources and a distant screen', body)


def problem766():
    sx, sy, mirror_y, screen_x, hit_y = 150, 170, 230, 780, 70
    virtual_y = 2 * mirror_y - sy
    # The already source-visible reflected ray and virtual backward extension
    # share a straight line. Choose a new drawing height, then intersect it.
    bounce_x = sx + (screen_x - sx) * (mirror_y - sy) / (virtual_y - hit_y)
    body = '<path d="M 780 25 V 370" stroke-width="4"/>'
    body += '<path d="M 70 230 H 780" stroke-width="3"/>'
    body += ''.join(f'<path d="M {x} 232 l -12 15" stroke-width="1.5"/>' for x in range(85, 780, 16))
    body += f'<path d="M {sx} {sy} L {screen_x} {hit_y}"/>'
    body += f'<path d="M {sx} {sy} L {bounce_x:.3f} {mirror_y} L {screen_x} {hit_y}"/>'
    body += f'<path d="M {sx} {sy} V {virtual_y} L {bounce_x:.3f} {mirror_y}" stroke-dasharray="7 6"/>'
    body += f'<circle cx="{sx}" cy="{sy}" r="4" fill="#222"/><circle cx="{sx}" cy="{virtual_y}" r="4" fill="#222"/>'
    body += text(124, 160, 'S') + text(125, 320, 'S′') + text(52, 219, 'A') + text(750, 219, 'O')
    return frame('Lloyd mirror with a real source and its virtual image', body)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    directory = Path(__file__).parent
    for name, content in [('problem764_diagram.svg', problem764()), ('problem766_diagram.svg', problem766())]:
        path = directory / name
        if args.check:
            if not path.exists() or path.read_text() != content:
                raise SystemExit(f'{name} differs from deterministic regeneration')
            print(f'PASS: {name}')
        else:
            path.write_text(content)


if __name__ == '__main__':
    main()
