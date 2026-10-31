# Echo Canyon Co-op
Live: https://itesydht.github.io/echo-canyon/  (GitHub Pages, repo itesydht/itesydht.github.io, folder echo-canyon/)
Files: index.html, photos.json, photos/<id>.txt (JPEG data URI), flyer.png (make_flyer.py)

## Add a party photo
1. ./add_photo.sh /path/to/img.jpg "funny caption"   (HEIC ok; resizes to 1600px max, strips EXIF/GPS)
2. Push: CallDynamicTool user-GitHub-xai push_files with the owner/repo/branch/files from .deploy/push.json
   (contents use "$file:/abs/path" so nothing goes inline). Live in ~10-60 s.
## Remove: ./add_photo.sh --remove <id>, push photos.json, then user-GitHub-xai delete_file echo-canyon/photos/<id>.txt

## Add a MISSING poster (posters.json, posters/, 1400px max, q88)
1. ./add_photo.sh --poster /path/to/poster.jpg "Guest Name" --title "Co-op Title" --duty "One-line job duty" --turnaround "Last seen: <poster claim>. Now found: <co-op redemption>."
   (title/duty optional; page shows "Title pending review by Guru Eddy". Edit later: ./add_photo.sh --poster --set <id> [--title ...] [--duty ...] [--turnaround ...], then push posters.json)
2. push_files (user-GitHub-xai) with files from .deploy/push.json. Live in ~15 s.
Remove: ./add_photo.sh --poster --remove <id>, push posters.json, delete_file echo-canyon/posters/<id>.txt

## Found Members page features
- Roll Call: sticky, horizontally scrollable pill strip auto-built from posters.json, sorted by last name (Jr/Sr/II/III ignored); tapping a pill smooth-scrolls to and flashes that card. Cards have ids found-<id>, so links like #found-<id> deep-link.
- Card fields: caption (name), title (fallback "Title pending review by Guru Eddy"), duty, turnaround (shown in a dashed "The Turnaround" box). All optional except the image.
- Leader name is Guru Eddy (renamed from Brother Eddy 2026-10-30). flyer.png regenerated; QR still https://itesydht.github.io/echo-canyon/
- Mobile layout (2026-10-30): sticky top nav (Found / Tiers / FAQ / Join), Found Members sits right under the hero with a "Find yourself" hero button, single-column posters under 560px, body text >= 16px, tap targets >= 44px. Roll Call sticks just under the top nav.

## v2 redesign (2026-10-30, 8 PM ET): DEFINITELY NOT A CULT
- Dark Trivia-Murder-Party game-show theme (Creepster/Bungee headings, Atkinson Hyperlegible body 20px), big tap targets (>=48px), single column on phones.
- Found Members search: sticky "Type your name to find yourself" combobox built from posters.json. Matches first/last names, case-insensitive, full-name prefix > word prefix > substring, up to 8 results; arrows/Enter/Escape; selecting scrolls to and flashes the card. No match: "Not found yet. The co-op is still looking for you."
- Roll call pills replaced by a collapsible "Show the whole roll call" grid.
- posters.json "special": guru (FOUNDER stamp, gold), hero (HERO stamp), wanted (CAUGHT stamp). Default stamp FOUND.
- Guest book form POSTs to https://formsubmit.co/150993492d857dc0c3e15f2655032f48 (FormSubmit alias for eddy@mail.grokbot.com; activated 2026-10-30) (fields name, found_member, message; _template=table, _captcha=false, _honey honeypot, _next=...?joined=1#join shows the thank-you panel).
- Batch tooling: batch/entries.py + batch/crop.py. Bernie and Kathryn poster images have the bottom caption line redacted (F*** Cancer / no "naked").

## Testimonies from the Found (wall right after the hero)
- Page fetches testimonies.json?v=<now> (no-store), shows newest first (by time), 12 at a time with a "Show more" button. Empty state: "No testimonies yet. Be the first to confess."
- Entry format: {"id","name","member","message","time"}; everything is rendered with textContent (no HTML), times shown in ET.
- Add one (after reading the FormSubmit email in eddy@mail.grokbot.com and deciding it should go up):
    ./add_testimony.sh "Name" "Found Member or empty" "Message" "2026-10-30T21:15:00-04:00"
  ISO time optional (defaults to now). Name/member capped at 60 chars, message at 400 (adds "..."), control chars stripped, em/en dashes replaced. JSON-escaped by Python.
- Then ONE push: CallDynamicTool user-GitHub-xai push_files with the owner/repo/branch/message/files from .deploy/push.json:
    {"owner":"itesydht","repo":"itesydht.github.io","branch":"main","message":"Echo Canyon: testimony from <Name>",
     "files":[{"path":"echo-canyon/testimonies.json","content":"$file:/workspace/echo-canyon/testimonies.json"}]}
- Remove/edit: edit testimonies.json by hand (keep valid JSON), push the same spec. Do not post test entries (e.g. "Bob test").
