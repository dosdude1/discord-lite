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

- Somewhat recently, Discord has killed support for TLS1.1 and older SSL protocols when connecting to their servers. As such, this application will no longer work on legacy Mac OS X versions without using a proxy. As of release 0.1.6-alpha, there is now a setting in the Preferences menu allowing you to set a SOCKS proxy configuration for the WebSocket. A custom proxy implementation for the HTTPS side of things is in the works, but at this time, that setting will have to be made in the Network pane of System Preferences on your machine.


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
