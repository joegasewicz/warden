## 0.1.0

- Initial version.

## 0.2.0
- Bundle JS assets #5 by @joegasewicz in https://github.com/joegasewicz/warden/pull/9

## 0.2.1
- Check that only js files get bundled #10 by @joegasewicz in https://github.com/joegasewicz/warden/pull/11

## 0.3.0
- Adds `warnings` flag to yaml.
- Fixes version flag.

## 0.3.1
- Fixes errors get swallowed up if warnings token is in stderr. #21 by @joegasewicz in https://github.com/joegasewicz/warden/pull/22

## 0.3.2
- Fixes move all none bundled files #23 by @joegasewicz in https://github.com/joegasewicz/warden/pull/24

## 0.4.0
- Added move assets #25 by @joegasewicz in https://github.com/joegasewicz/warden/pull/26

## 0.4.1
- Version fix

## 0.5.0
- Multiple dependencies #29 by @joegasewicz in https://github.com/joegasewicz/warden/pull/30

## 0.5.1
- Version fix

## 0.5.2
- 🪲Bug fix for dart watch not waiting for tasks to complete before re-bundling.

## 0.6.0
- Added `mode` setting for 🧪 development and 🚀 production builds.
- Added support for injecting environment variables into frontend Dart builds via `environment` config.
- Updated README with examples for mode and environment variable usage.

## 0.6.1
- Version fix

## 0.7.0
* Watch & build modes
* debug & logging

## 0.8.0
* Improves CLI visuals.
* Adds time taken for tasks & bundle times.

## 0.8.1
* Dart compile errors are now displayed in the terminal & the bundling is restricted until the errors are fixed by the end user.

## 0.8.2
* Removed false positive task output.
* Added better error logging to generate non compile tasks.

## 0.8.3
* Fixes bug not displaying dart compile success message and time

## 0.9.0
* Adds file compression