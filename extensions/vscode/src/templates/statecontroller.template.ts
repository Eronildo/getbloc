import * as changeCase from "change-case";
import { ControllerType } from "../utils";

export function getStateControllerTemplate(controllerName: string, type: ControllerType): string {
  switch (type) {
    case ControllerType.Equatable:
      return getEquatableStateControllerTemplate(controllerName);
    default:
      return getDefaultStateControllerTemplate(controllerName);
  }
}

function getEquatableStateControllerTemplate(controllerName: string) {
  const pascalCaseStateControllerName = changeCase.pascalCase(controllerName.toLowerCase());
  const snakeCaseStateControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  const controllerState = `${pascalCaseStateControllerName}State`;
  return `import 'package:getbloc/getbloc.dart';
import 'package:equatable/equatable.dart';

part '${snakeCaseStateControllerName}_state.dart';

class ${pascalCaseStateControllerName}Controller extends StateController<${controllerState}> {
  ${pascalCaseStateControllerName}Controller() : super(${pascalCaseStateControllerName}Initial());
}
`;
}

function getDefaultStateControllerTemplate(controllerName: string) {
  const pascalCaseStateControllerName = changeCase.pascalCase(controllerName.toLowerCase());
  const snakeCaseStateControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  const controllerState = `${pascalCaseStateControllerName}State`;
  return `import 'package:getbloc/getbloc.dart';
import 'package:meta/meta.dart';

part '${snakeCaseStateControllerName}_state.dart';

class ${pascalCaseStateControllerName}Controller extends StateController<${controllerState}> {
  ${pascalCaseStateControllerName}Controller() : super(${pascalCaseStateControllerName}Initial());
}
`;
}
