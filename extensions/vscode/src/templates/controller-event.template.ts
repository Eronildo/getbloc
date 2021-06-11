import * as changeCase from "change-case";
import { ControllerType } from "../utils";

export function getControllerEventTemplate(controllerName: string, type: ControllerType): string {
  switch (type) {
    case ControllerType.Equatable:
      return getEquatableControllerEventTemplate(controllerName);
    default:
      return getDefaultControllerEventTemplate(controllerName);
  }
}

function getEquatableControllerEventTemplate(controllerName: string): string {
  const pascalCaseControllerName = changeCase.pascalCase(controllerName.toLowerCase());
  const snakeCaseControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  return `part of '${snakeCaseControllerName}_controller.dart';

abstract class ${pascalCaseControllerName}Event extends Equatable {
  const ${pascalCaseControllerName}Event();

  @override
  List<Object> get props => [];
}
`;
}

function getDefaultControllerEventTemplate(controllerName: string): string {
  const pascalCaseControllerName = changeCase.pascalCase(controllerName.toLowerCase());
  const snakeCaseControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  return `part of '${snakeCaseControllerName}_controller.dart';

@immutable
abstract class ${pascalCaseControllerName}Event {}
`;
}
