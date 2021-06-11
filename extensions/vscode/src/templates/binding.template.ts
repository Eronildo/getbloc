import * as changeCase from "change-case";

export function getBindingTemplate(bindingName: string) {
  const pascalCaseBindingName = changeCase.pascalCase(bindingName.toLowerCase());
  const snakeCaseBindingName = changeCase.snakeCase(bindingName.toLowerCase());
  return `import 'package:get/get.dart';

import 'state/${snakeCaseBindingName}_controller.dart';

class ${pascalCaseBindingName}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() {
      return ${pascalCaseBindingName}Controller();
    });
  }
}
`;
}
