<p align="center">
<img src="https://raw.githubusercontent.com/Eronildo/getbloc/main/docs/assets/getbloc_logo.png" height="100" alt="GetBloc" />
</p>

---

## Overview

[VSCode](https://code.visualstudio.com/) support for the [GetBloc](https://pub.dev/packages/getbloc) and provides tools for effectively creating [GetX Controllers](https://pub.dev/packages/get#state-management) for [Flutter](https://flutter.dev/) apps.

## Installation

GetBloc can be installed from the [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=EronildoCavalcanti.getbloc) or by [searching within VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Commands

| Command                         | Description                                   |
| ------------------------------- | --------------------------------------------- |
| `GetBloc: New Binding Module`   | Generate a new GetX Binding Module Structure  |
| `GetBloc: New Module`           | Generate a new Module Structure               |
| `GetBloc: New Controller`       | Generate a new Controller                     |
| `GetBloc: New State Controller` | Generate a new StateController                |

You can activate the commands by launching the command palette (View -> Command Palette) and running entering the command name or you can right click on the directory in which you'd like to create the Controller/StateController and select the command from the context menu.

## Code Actions

| Action                           | Description                                      |
| -------------------------------- | ------------------------------------------------ |
| `Wrap with Obx`                  | Wraps current widget in a `Obx`                  |
| `Wrap with ListenerWidget`       | Wraps current widget in a `ListenerWidget`       |

### Snippets

| Shortcut                      | Description                                          |
| ----------------------------- | ---------------------------------------------------- |
| `importgetbloc`               | Imports `package:getbloc`                            |
| `importgetbloctest`           | Imports `package:getbloc_test`                       |
| `controller`                  | Creates a `Controller` class                         |
| `statecontroller`             | Creates a `StateController` class                    |
| `observercontroller`          | Creates a `ObserverController` class                 |
| `listenerwidget`              | Creates a `Listener` Widget                          |
| `controllerstate`             | Creates a state class                                |
| `controllerevent`             | Creates an event class                               |
| `testcontroller`              | Creates a `testController`                           |
| `page`                        | Creates a page extending `StatelessWidget`           |
| `pagegetview`                 | Creates a page extending `GetView`                   |
| `widget`                      | Creates a widget extending `StatelessWidget`         |
| `material` or `importM`       | Imports a `package:flutter/material.dart`            |
