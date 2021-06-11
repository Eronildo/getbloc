import { workspace } from "vscode";

export const enum TemplateSetting {
  Auto,
  Equatable,
  Simple,
}

export const enum TemplateType {
  Controller,
  StateController,
  Module,
}

export function getTemplateSetting(type: TemplateType): TemplateSetting {
  let config: string | undefined;
  switch (type) {
    case TemplateType.Controller:
      config = workspace.getConfiguration("getbloc").get("newControllerTemplate");
      break;
    case TemplateType.StateController:
      config = workspace.getConfiguration("getbloc").get("newStateControllerTemplate");
      break;
      case TemplateType.Module:
        config = workspace.getConfiguration("getbloc").get("newModuleTemplate");
        break;
    default:
      return TemplateSetting.Auto;
  }

  switch (config) {
    case "equatable":
      return TemplateSetting.Equatable;
    case "simple":
      return TemplateSetting.Simple;
    case "auto":
    default:
      return TemplateSetting.Auto;
  }
}
