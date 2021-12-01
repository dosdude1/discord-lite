# Discord Lite

### An ultra-lightweight native Discord client for vintage and modern Mac OS

![screenshot1](https://raw.githubusercontent.com/dosdude1/discord-lite/master/res/screenshot1.png)

### Minimum System Requirements

- Mac OS X version 10.4 (Tiger)
- PowerPC G3 CPU
- 256MB of system memory


### Current Functional State

#### What Works

- Vieweing and interaction in both servers and direct messages
- Sending images and attachments
- Viewing and downloading images and attachments
- Mention/ping notifications
- Pinging users
- Typing indication

#### What does not work

(I plan to implement all the following unless noted otherwise)

- Message hotlinks
- Message web embeds
- Voice and video chat
- Friend requests (will not be implemented due to Discord TOS concerns)
- Two-factor authentication



### Building

You can use a modern Xcode version to build this application, but installing legacy SDKs and compilers is necessary using [Xcode Legacy](https://github.com/devernay/xcodelegacy) to compile for older architectures.

The following components of Xcode Legacy need to be installed:

- Compilers
- Mac OS X 10.5 SDK
- Mac OS X 10.7 SDK

Once Xcode Legacy components have been installed, the application can simply be built and run in Xcode.
