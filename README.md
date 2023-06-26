# Discord Lite

### An ultra-lightweight native Discord client for vintage and modern Mac OS

![screenshot1](https://raw.githubusercontent.com/dosdude1/discord-lite/master/res/screenshot1.png)

### Minimum System Requirements

- Mac OS X version 10.4 (Tiger)
- PowerPC G3 CPU
- 256MB of system memory


### Current Functional State

#### What Works

- Viewing and interaction in both servers and direct messages
- Sending images and attachments
- Viewing and downloading images and attachments
- Mention/ping notifications
- Pinging users
- Typing indication
- Viewing and sending replies
- URL hotlinks
- Two-factor authentication
- Captchas (in Mac OS X 10.5 or later only)
- Editing messages


#### What does not work

(I plan to implement all the following unless noted otherwise)

- Message web embeds
- Voice and video chat
- Friend requests (will not be implemented due to Discord TOS concerns)


### Important Notes

- As of version 0.3-alpha, a new Curl and OpenSSL-based backend for both the WebSocket and HTTP requests has been implemented. As such, the application now has full TLS v1.3 support, and once again works without the need of going through a proxy running on a newer machine.


### Releases

Prebuilt Universal "Tri-FAT" binaries can be found in the [Releases](https://github.com/dosdude1/discord-lite/releases) section. You can download and run on PowerPC, 32-bit Intel, or 64-bit Intel. It will also run on ARM-based Macs under Rosetta, but native ARM support will be added soon.

Alternatively, you can download the latest release off [my website](http://dosdude1.com/apps/Discord%20Lite.dmg), which is loadable on the older machines.


### Building

You can use a modern Xcode version to build this application, but installing legacy SDKs and compilers is necessary using [Xcode Legacy](https://github.com/devernay/xcodelegacy) to compile for older architectures.

The following components of Xcode Legacy need to be installed:

- Compilers
- Mac OS X 10.5 SDK
- Mac OS X 10.7 SDK

Once Xcode Legacy components have been installed, the application can simply be built and run in Xcode.
