import * as _ from "lodash";
import * as changeCase from "change-case";
import * as mkdirp from "mkdirp";

import { InputBoxOptions, OpenDialogOptions, Uri, window } from "vscode";
import { existsSync, lstatSync, writeFile } from "fs";
import {
  getControllerEventTemplate,
  getControllerStateTemplate,
  getControllerTemplate,
} from "../templates";
import { getControllerType, ControllerType, TemplateType } from "../utils";

export const newController = async (uri: Uri) => {
  const controllerName = await promptForControllerName();
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

  const controllerType = await getControllerType(TemplateType.Controller);
  const pascalCaseControllerName = changeCase.pascalCase(controllerName.toLowerCase());
  try {
    await generateControllerCode(controllerName, targetDirectory, controllerType);
    window.showInformationMessage(
      `Successfully Generated ${pascalCaseControllerName} Controller`
    );
  } catch (error) {
    window.showErrorMessage(
      `Error:
        ${error instanceof Error ? error.message : JSON.stringify(error)}`
    );
  }
};

function promptForControllerName(): Thenable<string | undefined> {
  const controllerNamePromptOptions: InputBoxOptions = {
    prompt: "Controller Name",
    placeHolder: "counter",
  };
  return window.showInputBox(controllerNamePromptOptions);
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

async function generateControllerCode(
  controllerName: string,
  targetDirectory: string,
  type: ControllerType
) {
  const controllerDirectoryPath = `${targetDirectory}/state`;
  if (!existsSync(controllerDirectoryPath)) {
    await createDirectory(controllerDirectoryPath);
  }

  await Promise.all([
    createControllerEventTemplate(controllerName, targetDirectory, type),
    createControllerStateTemplate(controllerName, targetDirectory, type),
    createControllerTemplate(controllerName, targetDirectory, type),
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

function createControllerEventTemplate(
  controllerName: string,
  targetDirectory: string,
  type: ControllerType
) {
  const snakeCaseControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  const targetPath = `${targetDirectory}/state/${snakeCaseControllerName}_event.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCaseControllerName}_event.dart already exists`);
  }
  return new Promise(async (resolve, reject) => {
    writeFile(
      targetPath,
      getControllerEventTemplate(controllerName, type),
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

function createControllerStateTemplate(
  controllerName: string,
  targetDirectory: string,
  type: ControllerType
) {
  const snakeCaseControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  const targetPath = `${targetDirectory}/state/${snakeCaseControllerName}_state.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCaseControllerName}_state.dart already exists`);
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

function createControllerTemplate(
  controllerName: string,
  targetDirectory: string,
  type: ControllerType
) {
  const snakeCaseControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  const targetPath = `${targetDirectory}/state/${snakeCaseControllerName}_controller.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCaseControllerName}_controller.dart already exists`);
  }
  return new Promise(async (resolve, reject) => {
    writeFile(targetPath, getControllerTemplate(controllerName, type), "utf8", (error) => {
      if (error) {
        reject(error);
        return;
      }
      resolve();
    });
  });
}
