# Warden Example

This directory demonstrates how to configure and run [Warden](https://pub.dev/packages/warden) — a static builder CLI for Dart-based frontend builds.

## 🗂️ Structure
```
examples/
├── bin/
│   └── main.dart                 # Main Dart source file (compiled to JS)
├── lib/
│   └── examples.dart             # Optional shared logic
├── sass/
│   └── index.scss                # Sass file to compile into CSS
├── static/                       # Output directory for compiled assets
├── node_modules/                # Your frontend dependencies (Bootstrap, Popper.js, etc.)
├── warden.yaml                  # Warden config file
```
## ⚙️ warden.yaml

This file controls how Warden behaves. Here's an example:

```yaml
source_dir: examples

destination: static/

dependencies:
  source: examples/node_modules
  bundle: true
  main: static/main.js
  files:
    - 'bootstrap/dist/js/bootstrap.min.js'
    - 'popper.js/dist/umd/popper.min.js'

tasks:
  frontend:
    executable: dart
    args: ["compile", "js", "bin/main.dart", "-o", "../static/main.js"]
    src: examples

  styles:
    executable: dart
    args: ["run", "sass", "sass/index.scss:../static/index.css"]
    src: examples
```

###▶️ Running the Example

From the root of this directory, run:
```bash
dart run warden --file=warden.yaml
```
This will:
	•	Compile bin/main.dart to JS
	•	Compile sass/index.scss to CSS
	•	Copy and optionally bundle third-party JS files
	•	Watch files and recompile automatically


### 📝 Notes
	•	You must have dependencies like bootstrap and popper.js already installed in examples/node_modules.
	•	You can use any frontend packages compatible with Dart or just pure JS/CSS assets.