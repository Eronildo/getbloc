import * as changeCase from "change-case";
import { ControllerType } from "../utils";

export function getControllerTemplate(controllerName: string, type: ControllerType): string {
  switch (type) {
    case ControllerType.Equatable:
      return getEquatableControllerTemplate(controllerName);
    default:
      return getDefaultControllerTemplate(controllerName);
  }
}

function getEquatableControllerTemplate(controllerName: string) {
  const pascalCaseControllerName = changeCase.pascalCase(controllerName.toLowerCase());
  const snakeCaseControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  const controllerState = `${pascalCaseControllerName}State`;
  const controllerEvent = `${pascalCaseControllerName}Event`;
  return `import 'dart:async';

import 'package:getbloc/getbloc.dart';
import 'package:equatable/equatable.dart';

part '${snakeCaseControllerName}_event.dart';
part '${snakeCaseControllerName}_state.dart';

class ${pascalCaseControllerName}Controller extends Controller<${controllerEvent}, ${controllerState}> {
  ${pascalCaseControllerName}Controller() : super(${pascalCaseControllerName}Initial());

  @override
  Stream<${controllerState}> mapEventToState(${controllerEvent} event) async* {
    // TODO: implement mapEventToState
  }
}
`;
}

function getDefaultControllerTemplate(controllerName: string) {
  const pascalCaseControllerName = changeCase.pascalCase(controllerName.toLowerCase());
  const snakeCaseControllerName = changeCase.snakeCase(controllerName.toLowerCase());
  const controllerState = `${pascalCaseControllerName}State`;
  const controllerEvent = `${pascalCaseControllerName}Event`;
  return `import 'dart:async';

import 'package:getbloc/getbloc.dart';
import 'package:meta/meta.dart';

part '${snakeCaseControllerName}_event.dart';
part '${snakeCaseControllerName}_state.dart';

class ${pascalCaseControllerName}Controller extends Controller<${controllerEvent}, ${controllerState}> {
  ${pascalCaseControllerName}Controller() : super(${pascalCaseControllerName}Initial());

  @override
  Stream<${controllerState}> mapEventToState(${controllerEvent} event) async* {
    // TODO: implement mapEventToState
  }
}
`;
}
