clone this repository; it _might_ take time because it includes the entire WASI (WebAssembly System Interface) SDK component for portability

get a simple HTTP server, for example, miniserve from https://github.com/svenstaro/miniserve.git

in the Command Prompt, run: `miniserve <disk>:\path\to\root\of\this\repo -p 8000 --index index.html`

then, in the Command Prompt at `<disk>:\path\to\root\of\this\repo`, run `build.bat` and navigate to `localhost:8000` in your web browser of choice

