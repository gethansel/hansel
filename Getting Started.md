# Getting Started

## Flutter

### Installing Flutter 

1. Download the [Flutter SDK](https://storage.googleapis.com/flutter_infra/releases/stable/macos/flutter_macos_v1.12.13+hotfix.9-stable.zip)
2. Extract the file to the desired location
```sh
$ cd ~/development
$ unzip ~/Downloads/flutter_macos_v1.12.13+hotfix.9-stable.zip
```
You can also clone the source code from the [Flutter repo](https://github.com/flutter/flutter) on Github
```sh
$ git clone https://github.com/flutter/flutter.git -b stable
```
3. Add the flutter tool to your path:
```sh
$ export PATH="$PATH:`pwd`/flutter/bin"
```
This only sets your **PATH** variable for the current terminal window only. To permanently add Flutter to your path, follow [these instructions](https://flutter.dev/docs/get-started/install/macos#update-your-path)

4. Run the flutter doctor command to see if there are any dependencies you need to install
```sh
$ flutter doctor
```

## iOS setup

### Install Xcode

To develop for iOS, you will need to have Xcode installed. 
1. Install the latest version of Xcode from the [web](https://developer.apple.com/xcode/) or from the [App Store](https://itunes.apple.com/us/app/xcode/id497799835)
2. Configure the command line tools for Xcode by running the following commands
```sh
$ sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
$ sudo xcodebuild -runFirstLaunch
```

### Set up the iOS simulator

To test the app, you will need to run it on the iOS simulator
1. Find the Simulator using Spotlight Search or using the command line
```sh
$ open -a Simulator
```
2. Make sure your simulator is using a 64-bit device (iPhone 5s or later) by checking the settings in the simulator’s Hardware > Device menu.
3. Depending on your development machine’s screen size, simulated high-screen-density iOS devices might overflow your screen. Set the device scale under the Window > Scale menu in the simulator.

## Android setup

### Install Android Studio

To develop for Android, you will need to have Android Studio Installed
1. Download and install [Android Studio](https://developer.android.com/studio).
2. Start Android Studio and complete the **Android Studio Setup Wizard** 

### Set up the Android emulator

1. Enable [VM acceleration](https://developer.android.com/studio/run/emulator-acceleration).
2. Launch **Android Studio > Tools > Android > AVD Manager** and select **Create Virtual Device**.
3. Choose a device definition and select **Next**.
4. Select one or more system images for the Android versions you want to emulate, and select **Next**
5. Under **Emulated Performance**, select **Hardware - GLES 2.0** This will enable [hardware acceleration](https://developer.android.com/studio/run/emulator-acceleration)
6. Verify the [AVD configuration](https://developer.android.com/studio/run/managing-avds) is correct, and select **Finish**.
7. In the **Android Virtual Device Manager**, click **Run** in the toolbar. The emulator will start up and display the default canvas for your selected OS version and device.

## Set up an Editor

### Android Studio

1. Start Android Studio
2. Open plugin preferences (**Preferences > Plugins** on macOS, **File > Settings > Plugins** on Windows & Linux).
3. Select **Marketplace**, select the Flutter plugin and click Install.
4. Click **Restart** when prompted.

### Visual Studio Code

1. Start VS Code.
2. Navigate to the **View** menu and select **Command Palette**.
3. Type ```> Extensions: Install Extensions``` and select **Extensions: Install Extensions** from the dropdown menu.
4. Type “flutter” in the extensions search field, select **Flutter** from the list, and click **Install**. This also installs the required Dart plugin.
5. To validate the setup, Navigate to the **View** menu and select **Command Palette**.
6. Type ```> Flutter: Run Flutter Doctor``` and select **Flutter: Run Flutter Doctor** from the dropdown menu.
7. Check the **OUTPUT** pane to see if there are any dependencies you need to install

## Cloning the repo

### Using HTTPS
1. Open terminal
2. Change the current working directory to the location where you want the cloned directory to be made.
```sh
$ cd YOURDIRECTORY
```
3. Use git clone to clone the repository 
```sh
$ git clone https://github.com/aaronlinsky/covid_tracer.git
```
4. Click enter and the local clone will be created

### Using SSH
1. Open terminal
2. Change the current working directory to the location where you want the cloned directory to be made.
```sh
$ cd ~/development
```
3. Use git clone to clone the repository 
```sh
$ git clone git@github.com:aaronlinsky/covid_tracer.git
```
4. Click enter and the local clone will be created

## Testing the code

To test the code and your local changes, follow these steps

### iOS

1. Navigate to the directory where the repo was cloned and find the mobileApp directory
```sh
$ cd ~/development/covid_tracer/mobileApp
```
2. Install all of the neccesary packages by running:
```sh
$ flutter pub get
```
3. To launch the app in the Simulator, ensure that the Simulator is running and enter:
```sh
$ flutter run
```

### Android
1. Navigate to the directory where the repo was cloned and find the mobileApp directory
```sh
$ cd ~/development/covid_tracer/mobileApp
```
2. Install all of the neccesary packages by running:
```sh
$ flutter pub get
```
3. In the **Android Virtual Device Manager**, click **Run** in the toolbar. The emulator will start up and display the default canvas for your selected OS version and device.
4. Launch the app by running:
```sh
$ flutter run
```
