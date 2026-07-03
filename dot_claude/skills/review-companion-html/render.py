#!/usr/bin/env python3
"""Assemble a review-companion page: inline the behavior engine and resolve
content includes into the page YOU authored. Stdlib only — no deps.

    python3 render.py page.html -o out.html [--base DIR]

You write the whole page (structure, CSS, look) and drop in two kinds of marker;
this step expands them so the result is one self-contained .html:

  <!--rc:engine-->                  -> <script> … engine.js … </script>
  <!--rc:include FILE [lang]-->     -> <pre data-rc-fence data-lang=LANG><code …>escaped</code></pre>
  <!--rc:include FILE:A-B [lang]-->    (A-B = 1-based inclusive line range)
  <!--rc:include FILE md-->         -> <div data-rc-markdown hidden>escaped</div>
                                       (rendered client-side by marked.js if loaded)

Includes embed big verbatim sources (a diff, a file, a doc) BY REFERENCE, so
their bytes never pass through the authoring session's context — you point at
them instead of pasting them. The engine marker keeps the behavior JS
off-context the same way.
"""
import argparse, html, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
INCLUDE_RE = re.compile(r"<!--\s*rc:include\s+(\S+?)(?::(\d+)-(\d+))?(?:\s+([\w+.#-]+))?\s*-->")
ENGINE_MARKER = "<!--rc:engine-->"


def resolve_includes(page, base):
    def repl(m):
        path, a, b, lang = m.groups()
        fp = path if os.path.isabs(path) else os.path.join(base, path)
        with open(fp, encoding="utf-8") as f:
            text = f.read()
        if a and b:
            text = "\n".join(text.splitlines()[int(a) - 1:int(b)])
        esc = html.escape(text, quote=False)
        if lang in ("md", "markdown"):
            return f'<div data-rc-markdown hidden>{esc}</div>'
        cls = f' class="language-{lang}"' if lang else ""
        lang_attr = f' data-lang="{lang}"' if lang else ""
        return f'<pre data-rc-fence{lang_attr}><code{cls}>{esc}</code></pre>'
    return INCLUDE_RE.sub(repl, page)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("page", help="the HTML page you authored (with rc: markers)")
    ap.add_argument("-o", "--out", required=True)
    ap.add_argument("--engine", default=os.path.join(HERE, "engine.js"))
    ap.add_argument("--base", help="base dir for include paths (default: the page's dir)")
    args = ap.parse_args()

    with open(args.page, encoding="utf-8") as f:
        page = f.read()
    base = args.base or os.path.dirname(os.path.abspath(args.page)) or "."

    n_inc = len(INCLUDE_RE.findall(page))
    page = resolve_includes(page, base)
    n_units = len(re.findall(r"data-rc-unit=", page))

    if ENGINE_MARKER not in page:
        sys.exit(f"render.py: page has no {ENGINE_MARKER} marker — engine would not be inlined")
    with open(args.engine, encoding="utf-8") as f:
        engine = f.read()
    page = page.replace(ENGINE_MARKER, "<script>\n" + engine + "\n</script>")

    os.makedirs(os.path.dirname(os.path.abspath(args.out)) or ".", exist_ok=True)
    with open(args.out, "w", encoding="utf-8") as f:
        f.write(page)

    print(f"✓ {args.out}")
    print(f"  units:    {n_units}")
    print(f"  includes: {n_inc} resolved")
    print(f"  size:     {os.path.getsize(args.out) / 1024:.1f} KB")
    print(f"  regen:    python3 {os.path.relpath(__file__)} {args.page} -o {args.out}")


if __name__ == "__main__":
    try:
        main()
    except OSError as e:
        sys.exit(f"render.py: {e}")
