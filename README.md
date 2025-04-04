# Warden
**Static Builder CLI**
# Warden
**Static Builder CLI**

[![pub package](https://img.shields.io/pub/v/warden.svg)](https://pub.dev/packages/warden)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![build](https://img.shields.io/github/actions/workflow/status/joegasewicz/warden/dart.yml?branch=main)](https://github.com/joegasewicz/warden/actions)
[![Dart](https://img.shields.io/badge/Dart-3.7%2B-blue)](https://dart.dev)

Warden is a lightweight CLI tool to watch and compile Dart and Sass files for frontend projects. It's designed for projects that use server-side rendered HTML but still want custom JS/CSS assets compiled automatically.

Docs are [here](https://pub.dev/packages/warden)

### Features
- 🪄 Watches your Dart and Sass files and recompiles on change  
- 🧱 Moves specified dependencies (e.g. node_module installed files) into your build output  
- 📁 Fully configurable via a `warden.yaml` file  
- 🧵 Supports multiple tasks like compiling Dart code to JS & compiling sass to css.

### Setup
Create a `warden.yaml` in your project root with the following structure:

```yaml
source_dir: examples

destination: static/

dependencies:
  source: examples/node_modules
  files:
    - 'bootstrap/dist/js/bootstrap.min.js'
    - 'bootstrap/dist/css/bootstrap.min.css'
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

### ▶️ Running
Run Warden from your terminal in watch mode:
```
dart run warden --file=warden.yaml
```
This will:
	•	Copy specified dependency files into the build static/ directory
	•	Compile Dart to JavaScript
	•	Compile Sass to CSS
	•	Watch all source files and recompile on change


### 📦 Installation (coming soon)

```bash
dart pub global activate warden
```
Then run from any Dart project:
```bash
warden --file=warden.yaml
```

### 🧪 Example Project Structure
```
examples/
├── bin/
│   └── main.dart
├── lib/
│   └── examples.dart
├── sass/
│   └── index.scss
├── node_modules/
├── warden.yaml
```

License

MIT © 2025 joegasewicz