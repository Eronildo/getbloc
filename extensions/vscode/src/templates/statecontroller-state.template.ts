import * as changeCase from "change-case";
import { ControllerType } from "../utils";

export function getStateControllerStateTemplate(
  controllerName: string,
  type: ControllerType
): string {
  switch (type) {
    case ControllerType.Equatable:
      return getEquatableStateControllerStateTemplate(controllerName);
    default:
      return getDefaultStateControllerStateTemplate(controllerName);
  }
}

function getEquatableStateControllerStateTemplate(controllerName: string): string {
  const pascalCaseStateControllerName = changeCase.pascalCase(controllerName.toLowerCase());
  const snakeCaseStateControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  return `part of '${snakeCaseStateControllerName}_controller.dart';

abstract class ${pascalCaseStateControllerName}State extends Equatable {
  const ${pascalCaseStateControllerName}State();

  @override
  List<Object> get props => [];
}

class ${pascalCaseStateControllerName}Initial extends ${pascalCaseStateControllerName}State {}
`;
}

function getDefaultStateControllerStateTemplate(controllerName: string): string {
  const pascalCaseStateControllerName = changeCase.pascalCase(controllerName.toLowerCase());
  const snakeCaseStateControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  return `part of '${snakeCaseStateControllerName}_controller.dart';

@immutable
abstract class ${pascalCaseStateControllerName}State {}

class ${pascalCaseStateControllerName}Initial extends ${pascalCaseStateControllerName}State {}
`;
}
