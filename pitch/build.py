# Builds pitch/index.html: embeds public/index.html (the live app) and the Ploopy PNGs into one file.
# Run from the repo root: python3 pitch/build.py
import base64, json, pathlib
root = pathlib.Path(__file__).resolve().parent.parent
src = (root / 'pitch/src.html').read_text()
app = base64.b64encode((root / 'public/index.html').read_bytes()).decode()
ploopy = {}
for c in ['caramel', 'sage', 'blueberry', 'honey', 'terracotta', 'oat']:
    p = {}
    for m in ['hello', 'cheer']:
        f = root / f'pitch/ploopy/{c}-{m}.png'
        if f.exists():
            p[m] = 'data:image/png;base64,' + base64.b64encode(f.read_bytes()).decode()
    if len(p) == 2:
        ploopy[c] = p
out = src.replace('__APP_B64__', app).replace('__PLOOPY__', json.dumps(ploopy))
(root / 'pitch/index.html').write_text(out)
print('wrote pitch/index.html', len(out) // 1024, 'KB,', len(ploopy), 'colourways')
