#!/usr/bin/env python3
"""Redraw the directly inspected Fig. 228 as a new vector schematic.

The authoring reference is the user-provided screenshot identified in source.jsonl.
There is no trusted-caption intermediary. Coordinates below are drawing choices
made after visual inspection, not measurements inferred from source pixels.
This generator consumes no caption, solution text/proof, or Fig. 479.
"""
import argparse
import math
from pathlib import Path


def schematic() -> str:
    # A common support with two distinct pivots, equal vertical strings and bobs.
    hatches = "\n".join(
        f'<path d="M {x} 45 l 18 -18"/>' for x in range(90, 533, 18)
    )
    points = [(184, 300), (201, 300)]
    for i in range(241):
        x = 201 + (438 - 201) * i / 240
        points.append((x, 300 + 8 * math.sin(2 * math.pi * 12 * i / 240)))
    points += [(438, 300), (456, 300)]
    spring = " ".join(f'{x:.3f},{y:.3f}' for x, y in points)
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="640" height="380" viewBox="0 0 640 380">
<title>Two equal pendulums connected by a spring in vertical equilibrium</title>
<desc>New schematic based on direct inspection of the user-provided Fig. 228.</desc>
<rect width="640" height="380" fill="white"/>
<g fill="none" stroke="#202020" stroke-width="2" stroke-linecap="round">
{hatches}
<path d="M 90 45 H 550" stroke-width="4"/>
<path d="M 160 45 V 276 M 480 45 V 276"/>
<polyline points="{spring}"/>
</g>
<g fill="#202020"><circle cx="160" cy="45" r="4"/><circle cx="480" cy="45" r="4"/></g>
<g fill="#f1f1f1" stroke="#202020" stroke-width="2">
<circle cx="160" cy="300" r="24"/><circle cx="480" cy="300" r="24"/>
</g>
<g fill="#202020" font-family="serif" font-size="27" font-style="italic">
<text x="178" y="171">l</text><text x="498" y="171">l</text>
<text x="96" y="308">m</text><text x="515" y="308">m</text>
</g>
</svg>
'''


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='check deterministic regeneration')
    args = parser.parse_args()
    path = Path(__file__).with_name('problem_diagram.svg')
    content = schematic()
    if args.check:
        if not path.exists() or path.read_text() != content:
            raise SystemExit('problem_diagram.svg differs from deterministic output')
        print('PASS: Fig. 228 schematic regeneration')
    else:
        path.write_text(content)


if __name__ == '__main__':
    main()
