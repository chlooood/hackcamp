# Builds pitch/index.html: embeds public/index.html (the live app) and every Ploopy PNG in pitch/ploopy/ into one file.
# Run from the repo root: python3 pitch/build.py
import base64, json, pathlib
root = pathlib.Path(__file__).resolve().parent.parent
src = (root / 'pitch/src.html').read_text()
app = base64.b64encode((root / 'public/index.html').read_bytes()).decode()
ploopy = {}
for f in sorted((root / 'pitch/ploopy').glob('*-*.png')):
    colour, mood = f.stem.split('-', 1)
    ploopy.setdefault(colour, {})[mood] = 'data:image/png;base64,' + base64.b64encode(f.read_bytes()).decode()
out = src.replace('__APP_B64__', app).replace('__PLOOPY__', json.dumps(ploopy))
(root / 'pitch/index.html').write_text(out)
print('wrote pitch/index.html', len(out) // 1024, 'KB,', sum(len(v) for v in ploopy.values()), 'Ploopy images')
