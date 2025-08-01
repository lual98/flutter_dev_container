## Standalone dev container for developing
FROM ubuntu:24.04

# Prerequisites
RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk wget socat lcov

# Set up new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Prepare Android directories and system variables
RUN mkdir -p /home/developer/Android/sdk/cmdline-tools
ENV ANDROID_SDK_ROOT /home/developer/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg

# Set up Android SDK
ENV CMDLINE_TOOLS_VERSION=6858069
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv cmdline-tools /home/developer/Android/sdk/cmdline-tools/latest
ENV PATH "$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin"
ENV PATH "$PATH:/home/developer/Android/sdk/platform-tools"
RUN yes | sdkmanager --licenses
RUN sdkmanager "build-tools;35.0.1" "platform-tools" "platforms;android-35" "sources;android-35"

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
RUN cd flutter
ENV PATH "$PATH:/home/developer/flutter/bin"

# This is part of a workaround mentioned in https://github.com/flutter/flutter/issues/61604#issuecomment-739885494
ENV ADB_SERVER_SOCKET=tcp:host.docker.internal:5037

# Run basic check to download Dart SDK
RUN flutter doctor

WORKDIR /home/developer/

# Setup flutterfire cli
RUN dart pub global activate flutterfire_cli
RUN mkdir -p /home/developer/bin
RUN cd /home/developer/bin && wget -O firebase https://firebase.tools/bin/linux/latest && chmod +x firebase
ENV PATH "$PATH:/home/developer/.pub-cache/bin"
ENV PATH "$PATH:/home/developer/bin"

COPY --chown=developer:developer pubspec.* ./
# This is part of a workaround mentioned in https://github.com/flutter/flutter/issues/61604#issuecomment-739885494
# The dart VM service has problems connecting to the real device by default so we need to use socat to forward the connection.
CMD ["socat", "tcp-listen:10388,bind=127.0.0.1,fork", "tcp:host.docker.internal:10388"]