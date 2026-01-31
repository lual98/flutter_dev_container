## Standalone dev container for developing
FROM --platform=linux/amd64 ubuntu:24.04
# Workaround from https://askubuntu.com/a/1515958
RUN userdel -r ubuntu

# Prerequisites
RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk wget socat lcov libsqlite3-dev fish zsh

# Follow instructions of https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#_creating-a-nonroot-user

# Set up new user
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME
WORKDIR /home/$USERNAME

# Prepare Android directories and system variables
RUN mkdir -p /home/$USERNAME/Android/sdk/cmdline-tools
ENV ANDROID_SDK_ROOT=/home/$USERNAME/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg

# Set up Android SDK
ENV CMDLINE_TOOLS_VERSION=6858069
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv cmdline-tools /home/$USERNAME/Android/sdk/cmdline-tools/latest
ENV PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin"
ENV PATH="$PATH:/home/$USERNAME/Android/sdk/platform-tools"
RUN yes | sdkmanager --licenses
RUN sdkmanager "build-tools;35.0.1" "platform-tools" "platforms;android-35" "sources;android-35"

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
RUN cd flutter
ENV PATH="$PATH:/home/$USERNAME/flutter/bin"

# This is part of a workaround mentioned in https://github.com/flutter/flutter/issues/61604#issuecomment-739885494
ENV ADB_SERVER_SOCKET=tcp:host.docker.internal:5037

# Run basic check to download Dart SDK and set stable channel
RUN flutter channel stable
RUN flutter doctor

WORKDIR /home/$USERNAME/

# Setup flutterfire cli
RUN dart pub global activate flutterfire_cli
RUN mkdir -p /home/$USERNAME/bin
RUN cd /home/$USERNAME/bin && wget -O firebase https://firebase.tools/bin/linux/latest && chmod +x firebase
ENV PATH="$PATH:/home/$USERNAME/.pub-cache/bin"
ENV PATH="$PATH:/home/$USERNAME/bin"

# Setup FVM
RUN dart pub global activate fvm

COPY --chown=$USERNAME:$USERNAME pubspec.* ./
# This is part of a workaround mentioned in https://github.com/flutter/flutter/issues/61604#issuecomment-739885494
# The dart VM service has problems connecting to the real device by default so we need to use socat to forward the connection.
CMD ["socat", "tcp-listen:10388,bind=127.0.0.1,fork", "tcp:host.docker.internal:10388"]