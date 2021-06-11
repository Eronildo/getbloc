import * as changeCase from "change-case";

export function getPageTemplate(pageName: string) {
  const pascalCasePageName = changeCase.pascalCase(pageName.toLowerCase());
  const snakeCasePageName = changeCase.snakeCase(pageName.toLowerCase());
  return `import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state/${snakeCasePageName}_controller.dart';

class ${pascalCasePageName}Page extends StatelessWidget {
  final controller = Get.put(${pascalCasePageName}Controller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(
        () {
          final state = controller.state;
          if (state is ${pascalCasePageName}Initial) {
            return Text('${pascalCasePageName} Initial State');
          }
          return Container();
        },
      ),
    );
  }
}
`;
}

export function getGetViewTemplate(pageName: string) {
  const pascalCasePageName = changeCase.pascalCase(pageName.toLowerCase());
  const snakeCasePageName = changeCase.snakeCase(pageName.toLowerCase());
  const controllerName = `${pascalCasePageName}Controller`;
  return `import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state/${snakeCasePageName}_controller.dart';

class ${pascalCasePageName}Page extends GetView<${controllerName}> {
  static const String routeName = '/${snakeCasePageName}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(
        () {
          final state = controller.state;
          if (state is ${pascalCasePageName}Initial) {
            return Text('${pascalCasePageName} Initial State');
          }
          return Container();
        },
      ),
    );
  }
}
`;
}
