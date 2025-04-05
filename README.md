# Warden
**Static Builder CLI**

[![pub package](https://img.shields.io/pub/v/warden.svg)](https://pub.dev/packages/warden)
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
# The root directory of your source files
source_dir: examples

# Where to output built files (JavaScript, CSS, etc.)
destination: static/

# List of third-party files (JS/CSS) to copy from a source directory
dependencies:
  # Path to your local node_modules (or other directory holding third-party files)
  source: examples/node_modules
  files:
    # List of files to copy into the static/ destination
	# Note: We only need Bootstrap's JS files as the css file is bundled in with the built css file.  
    - 'bootstrap/dist/js/bootstrap.min.js'
    - 'popper.js/dist/umd/popper.min.js'

# List of build tasks to run (Dart compile, Sass compile, etc.)
tasks:
  # First task: compile Dart to JavaScript
  frontend:
    executable: dart                  # Command to run
    args: ["compile", "js", "bin/main.dart", "-o", "../static/main.js"]  # Arguments to compile Dart
    src: examples                     # Working directory for this task

  # Second task: compile Sass to CSS
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


### 📦 Installation

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