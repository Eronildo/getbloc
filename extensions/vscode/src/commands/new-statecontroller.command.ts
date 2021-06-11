import * as _ from "lodash";
import * as changeCase from "change-case";
import * as mkdirp from "mkdirp";

import { InputBoxOptions, OpenDialogOptions, Uri, window } from "vscode";
import { existsSync, lstatSync, writeFile } from "fs";
import { getControllerStateTemplate, getStateControllerTemplate } from "../templates";
import { getControllerType, ControllerType, TemplateType } from "../utils";

export const newStateController = async (uri: Uri) => {
  const controllerName = await promptForStateControllerName();
  if (_.isNil(controllerName) || controllerName.trim() === "") {
    window.showErrorMessage("The controller name must not be empty");
    return;
  }

  let targetDirectory;
  if (_.isNil(_.get(uri, "fsPath")) || !lstatSync(uri.fsPath).isDirectory()) {
    targetDirectory = await promptForTargetDirectory();
    if (_.isNil(targetDirectory)) {
      window.showErrorMessage("Please select a valid directory");
      return;
    }
  } else {
    targetDirectory = uri.fsPath;
  }

  const controllerType = await getControllerType(TemplateType.StateController);
  const pascalCaseStateControllerName = changeCase.pascalCase(controllerName.toLowerCase());
  try {
    await generateStateControllerCode(controllerName, targetDirectory, controllerType);
    window.showInformationMessage(
      `Successfully Generated ${pascalCaseStateControllerName} Controller`
    );
  } catch (error) {
    window.showErrorMessage(
      `Error:
        ${error instanceof Error ? error.message : JSON.stringify(error)}`
    );
  }
};

function promptForStateControllerName(): Thenable<string | undefined> {
  const stateControllerNamePromptOptions: InputBoxOptions = {
    prompt: "StateController Name",
    placeHolder: "counter",
  };
  return window.showInputBox(stateControllerNamePromptOptions);
}

async function promptForTargetDirectory(): Promise<string | undefined> {
  const options: OpenDialogOptions = {
    canSelectMany: false,
    openLabel: "Select a folder to create the controller in",
    canSelectFolders: true,
  };

  return window.showOpenDialog(options).then((uri) => {
    if (_.isNil(uri) || _.isEmpty(uri)) {
      return undefined;
    }
    return uri[0].fsPath;
  });
}

async function generateStateControllerCode(
  controllerName: string,
  targetDirectory: string,
  type: ControllerType
) {
  const stateControllerDirectoryPath = `${targetDirectory}/state`;
  if (!existsSync(stateControllerDirectoryPath)) {
    await createDirectory(stateControllerDirectoryPath);
  }

  await Promise.all([
    createStateControllerStateTemplate(controllerName, targetDirectory, type),
    createStateControllerTemplate(controllerName, targetDirectory, type),
  ]);
}

function createDirectory(targetDirectory: string): Promise<void> {
  return new Promise((resolve, reject) => {
    mkdirp(targetDirectory, (error) => {
      if (error) {
        return reject(error);
      }
      resolve();
    });
  });
}

function createStateControllerStateTemplate(
  controllerName: string,
  targetDirectory: string,
  type: ControllerType
) {
  const snakeCaseStateControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  const targetPath = `${targetDirectory}/state/${snakeCaseStateControllerName}_state.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCaseStateControllerName}_state.dart already exists`);
  }
  return new Promise(async (resolve, reject) => {
    writeFile(
      targetPath,
      getControllerStateTemplate(controllerName, type),
      "utf8",
      (error) => {
        if (error) {
          reject(error);
          return;
        }
        resolve();
      }
    );
  });
}

function createStateControllerTemplate(
  controllerName: string,
  targetDirectory: string,
  type: ControllerType
) {
  const snakeCaseStateControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  const targetPath = `${targetDirectory}/state/${snakeCaseStateControllerName}_controller.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCaseStateControllerName}_controller.dart already exists`);
  }
  return new Promise(async (resolve, reject) => {
    writeFile(
      targetPath,
      getStateControllerTemplate(controllerName, type),
      "utf8",
      (error) => {
        if (error) {
          reject(error);
          return;
        }
        resolve();
      }
    );
  });
}
