# Flutter Dev Container

A ready-to-use development container for Flutter projects, including Android SDK, Flutter SDK, and FlutterFire CLI.

## Features

- Preinstalled Flutter SDK and Android SDK
- FlutterFire CLI included for Firebase integration
- FVM (Flutter Version Management) for managing Flutter versions included
- VS Code extensions for Flutter and Dart
- Runs as a non-root `developer` user

## Requirements
- ADB should be installed on your host machine and in your PATH.

## Usage

1. Open this repository in VS Code and reopen in the dev container.
2. Your Flutter projects should be placed inside the `workspace` directory.

## Debugging Android Devices

> **Warning:**  
> To debug Android emulators or real devices via ADB inside the container, you must have ADB running on your host machine. The container will automatically start the ADB server in the host machine. If ADB is not running on the host, the Dart analysis server will be terminated inside the container.
> If you don't need to debug Android devices, remove the initializeCommand from the `.devcontainer/devcontainer.json` file and the following line from Dockerfile:
```diff
- ENV ADB_SERVER_SOCKET=tcp:host.docker.internal:5037
```


## Debugging Flutter Apps from the Container

A sample `launch.json` is provided at the root of this repository. Use the **"Run (from container)"** configuration to launch and debug your Flutter app from within the container. This configuration includes the required arguments:

```
--host-vmservice-port=10388 --dds-port=43123
```

These arguments are necessary for the debugger to work properly with the ADB workaround. Make sure to select this configuration when starting a debug session in VS Code.

## Limitations

> **Limitation:**
> Only one instance of this container can run at a time on the same host. This is due to the fixed ports used for ADB and the Dart debugger. Running multiple containers simultaneously will cause port conflicts.

## Issues
- You may encounter the following error during Android builds:
```
Gradle build daemon disappeared unexpectedly (it may have been killed or may have crashed)
```
To fix this, lower the `org.gradle.jvmargs` value in your gradle
.properties file. For example:
```
org.gradle.jvmargs=-Xmx1024M
```
## Notes

- The container is set up for both development and testing of Flutter apps.
- FlutterFire CLI is already installed for easy Firebase setup.

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](LICENSE)
