#!/usr/bin/env bash
# Usage: ./add_testimony.sh "Name" "Member-or-empty" "Message" ["ISO time"]
# Appends a testimony to testimonies.json (newest shown first on the site) and
# writes .deploy/push.json for testimonies.json only. Then run ONE push_files call
# with the owner/repo/branch/message/files from .deploy/push.json.
set -euo pipefail
cd "$(dirname "$0")"
if [ $# -lt 3 ]; then echo 'Usage: ./add_testimony.sh "Name" "Member-or-empty" "Message" ["ISO time"]' >&2; exit 1; fi
NAME="$1" MEMBER="$2" MSG="$3" WHEN="${4:-}" python3 - <<'PY'
import json, os, re, unicodedata, datetime
def clean(s, cap):
    s = unicodedata.normalize('NFC', s or '')
    s = re.sub(r'[\x00-\x08\x0b-\x1f\x7f]', '', s)          # strip control chars (keep \n, \t)
    s = s.replace('\u2014', ', ').replace('\u2013', '-')    # house style: no em/en dashes
    s = re.sub(r'[ \t]+', ' ', s); s = re.sub(r'\n{3,}', '\n\n', s).strip()
    if len(s) > cap: s = s[:cap].rstrip() + '...'
    return s
name = clean(os.environ['NAME'], 60) or 'Anonymous Contestant'
member = clean(os.environ['MEMBER'], 60)
msg = clean(os.environ['MSG'], 400)
if not msg: raise SystemExit('Message is empty; nothing added.')
when = os.environ.get('WHEN') or datetime.datetime.now().astimezone().isoformat(timespec='seconds')
try:
    t = datetime.datetime.fromisoformat(when.replace('Z', '+00:00'))
    if t.tzinfo is None: t = t.astimezone()
    when = t.isoformat(timespec='seconds')
except ValueError:
    raise SystemExit('Bad ISO time: ' + when)
p = 'testimonies.json'
data = json.load(open(p)) if os.path.exists(p) and open(p).read().strip() else []
tid = t.strftime('%Y%m%d-%H%M%S')
if any(x.get('id') == tid for x in data): tid += '-' + str(len(data))
data.append({'id': tid, 'name': name, 'member': member, 'message': msg, 'time': when})
data.sort(key=lambda x: datetime.datetime.fromisoformat(x['time'].replace('Z','+00:00')).timestamp())
tmp = p + '.tmp'; json.dump(data, open(tmp, 'w'), indent=1, ensure_ascii=False); os.replace(tmp, p)
here = os.path.abspath('.')
os.makedirs('.deploy', exist_ok=True)
json.dump({'owner': 'itesydht', 'repo': 'itesydht.github.io', 'branch': 'main',
           'message': 'Echo Canyon: testimony from ' + name,
           'files': [{'path': 'echo-canyon/testimonies.json', 'content': '$file:' + here + '/testimonies.json'}]},
          open('.deploy/push.json', 'w'), indent=1)
print(f'Added {tid} ({name}). {len(data)} testimonies. Push spec: .deploy/push.json')
PY
