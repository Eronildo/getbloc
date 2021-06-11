import * as changeCase from "change-case";
import { ControllerType } from "../utils";

export function getControllerStateTemplate(controllerName: string, type: ControllerType): string {
  switch (type) {
    case ControllerType.Equatable:
      return getEquatableControllerStateTemplate(controllerName);
    default:
      return getDefaultControllerStateTemplate(controllerName);
  }
}

function getEquatableControllerStateTemplate(controllerName: string): string {
  const pascalCaseControllerName = changeCase.pascalCase(controllerName.toLowerCase());
  const snakeCaseControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  return `part of '${snakeCaseControllerName}_controller.dart';

abstract class ${pascalCaseControllerName}State extends Equatable {
  const ${pascalCaseControllerName}State();
  
  @override
  List<Object> get props => [];
}

class ${pascalCaseControllerName}Initial extends ${pascalCaseControllerName}State {}
`;
}

function getDefaultControllerStateTemplate(controllerName: string): string {
  const pascalCaseControllerName = changeCase.pascalCase(controllerName.toLowerCase());
  const snakeCaseControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  return `part of '${snakeCaseControllerName}_controller.dart';

@immutable
abstract class ${pascalCaseControllerName}State {}

class ${pascalCaseControllerName}Initial extends ${pascalCaseControllerName}State {}
`;
}
