import * as _ from "lodash";

import { commands, ExtensionContext, languages } from "vscode";
import {
  newController,
  newStateController,
  wrapWithObx,
  wrapWithListenerWidget,
  newModule,
  newBinding,
} from "./commands";
import { ControllerCodeActionProvider } from "./code-actions";

const DART_MODE = { language: "dart", scheme: "file" };

export function activate(_context: ExtensionContext) {
  _context.subscriptions.push(
    commands.registerCommand("extension.new-controller", newController),
    commands.registerCommand("extension.new-statecontroller", newStateController),
    commands.registerCommand("extension.new-module", newModule),
    commands.registerCommand("extension.new-binding", newBinding),
    commands.registerCommand("extension.wrap-obx", wrapWithObx),
    commands.registerCommand(
      "extension.wrap-listenerwidget",
      wrapWithListenerWidget
    ),
    languages.registerCodeActionsProvider(
      DART_MODE,
      new ControllerCodeActionProvider()
    )
  );
}
