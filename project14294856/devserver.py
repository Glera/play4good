from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import os

BASE_DIR = Path(__file__).resolve().parent

class NoCacheHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(BASE_DIR), **kwargs)

    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

if __name__ == '__main__':
    base_port = int(os.environ.get('PORT', '8080'))
    for port in (base_port, base_port + 1, base_port + 2):
        try:
            server = ThreadingHTTPServer(('0.0.0.0', port), NoCacheHandler)
            print(f'Serving {BASE_DIR} on http://localhost:{port}')
            server.serve_forever()
        except OSError:
            continue
    raise SystemExit('No свободного порта рядом с 8080. Укажите PORT=XXXX')
