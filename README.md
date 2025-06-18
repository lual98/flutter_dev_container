# Flutter Dev Container

A ready-to-use development container for Flutter projects, including Android SDK, Flutter SDK, and FlutterFire CLI.

## Features

- Preinstalled Flutter SDK and Android SDK
- FlutterFire CLI included for Firebase integration
- VS Code extensions for Flutter and Dart
- Runs as a non-root `developer` user

## Usage

1. Open this repository in VS Code and reopen in the dev container.
2. Your Flutter projects should be placed inside the `workspace` directory.

## Debugging Android Devices

> **Warning:**  
> To debug Android emulators or real devices via ADB inside the container, you must have ADB running on your host machine. If ADB is not running on the host, the Dart analysis server will be terminated inside the container.

## Debugging Flutter Apps from the Container

A sample `launch.json` is provided at the root of this repository. Use the **"Run (from container)"** configuration to launch and debug your Flutter app from within the container. This configuration includes the required arguments:

```
--host-vmservice-port=10388 --dds-port=43123
```

These arguments are necessary for the debugger to work properly with the ADB workaround. Make sure to select this configuration when starting a debug session in VS Code.

## Limitations

> **Limitation:**
> Only one instance of this container can run at a time on the same host. This is due to the fixed ports used for ADB and the Dart debugger. Running multiple containers simultaneously will cause port conflicts.

## Notes

- The container is set up for both development and testing of Flutter apps.
- FlutterFire CLI is already installed for easy Firebase setup.

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](LICENSE)
