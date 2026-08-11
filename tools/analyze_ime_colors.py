#!/usr/bin/env python3
"""Locate the IME window from dumpsys/uiautomator and report ROI colors."""
import argparse
import json
import re
from pathlib import Path

import cv2
import numpy as np


def rects_from_text(text):
    return [tuple(map(int, m)) for m in re.findall(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", text)]


def ime_rect(window_text, image_shape):
    # The InputMethod window is the authoritative IME boundary; do not use a fixed y.
    m = re.search(r"package=[^\n]*?\n?", window_text)
    block = re.search(r"WindowStateAnimator\{[^\n]* InputMethod\}:.*?(?=\n  Window #|\Z)", window_text, re.S)
    if block:
        b = re.search(r"mFrame=Rect\((\d+), (\d+) - (\d+), (\d+)\)", block.group())
        if b:
            return tuple(map(int, b.groups()))
    # Insets dump is present on Android 16 even when mFrame formatting changes.
    b = re.search(r"type=ime frame=\[(\d+),(\d+)\]\[(\d+),(\d+)\]", window_text)
    if b:
        return tuple(map(int, b.groups()))
    h, w = image_shape[:2]
    raise RuntimeError("Could not locate InputMethod bounds in dumpsys window")


def nav_top(window_text, height):
    vals = [int(y1) for _, y1, _, _ in re.findall(r"type=navigationBars frame=\[(\d+),(\d+)\]\[(\d+),(\d+)\]", window_text)]
    return min(vals) if vals else height


def stats(image, rect):
    x1, y1, x2, y2 = rect
    a = image[y1:y2, x1:x2, ::-1].reshape(-1, 3)
    med = np.median(a, axis=0)
    q = (a // 8) * 8
    colors, counts = np.unique(q, axis=0, return_counts=True)
    dom = colors[counts.argmax()]
    return {"rect": [x1, y1, x2, y2], "median_rgb": med.round(1).tolist(),
            "dominant_rgb_quantized": dom.tolist(), "dominant_share": round(float(counts.max()/len(q)), 4)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("screenshot", type=Path)
    ap.add_argument("--window", required=True, type=Path)
    ap.add_argument("--uiautomator", type=Path)
    ap.add_argument("--annotated", type=Path)
    args = ap.parse_args()
    image = cv2.imread(str(args.screenshot), cv2.IMREAD_COLOR)
    if image is None:
        raise SystemExit("cannot read screenshot")
    wt = args.window.read_text(errors="replace")
    x1, top, x2, bottom = ime_rect(wt, image.shape)
    bottom = min(bottom, nav_top(wt, image.shape[0]))
    if x2 <= x1 or bottom <= top:
        raise SystemExit("IME window is not visible; focus an editable field before capturing")
    # Scan horizontal bands near the bottom. A toolbar is a uniform band followed by
    # a distinct lower area; selecting the last such transition avoids fixed coords.
    ys = range(top, max(top, bottom - 20), 4)
    rows = []
    for y in ys:
        a = image[y:min(y+4, bottom), x1+max(8,(x2-x1)//20):x2-max(8,(x2-x1)//20), ::-1].reshape(-1,3)
        rows.append((y, np.median(a, axis=0)))
    diffs = [(rows[i][0], float(np.linalg.norm(rows[i][1]-rows[i-1][1]))) for i in range(1,len(rows))]
    cuts = [y for y,d in diffs if d > 12]
    toolbar_end = cuts[-1] if cuts else bottom
    toolbar_start = max(top, toolbar_end - 100)
    toolbar = stats(image, (x1, toolbar_start, x2, toolbar_end))
    lower = stats(image, (x1, toolbar_end, x2, bottom)) if bottom-toolbar_end >= 20 else None
    result = {"ime_rect": [x1, top, x2, bottom], "toolbar": toolbar, "lower_ime": lower}
    print(json.dumps(result, ensure_ascii=True, indent=2))
    if args.annotated:
        out = image.copy()
        cv2.rectangle(out, (x1, toolbar_start), (x2, toolbar_end), (0, 0, 255), 5)
        cv2.rectangle(out, (x1, toolbar_end), (x2, bottom), (255, 0, 0), 5)
        cv2.imwrite(str(args.annotated), out)


if __name__ == "__main__":
    main()
