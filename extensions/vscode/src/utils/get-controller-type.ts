import { hasDependency } from "./has-dependency";
import {
  TemplateType,
  getTemplateSetting,
  TemplateSetting,
} from "./get-template-setting";

const equatable = "equatable";

export const enum ControllerType {
  Simple,
  Equatable,
}

export async function getControllerType(type: TemplateType): Promise<ControllerType> {
  const setting = getTemplateSetting(type);
  switch (setting) {
    case TemplateSetting.Equatable:
      return ControllerType.Equatable;
    case TemplateSetting.Simple:
      return ControllerType.Simple;
    case TemplateSetting.Auto:
    default:
      return getDefaultDependency();
  }
}

async function getDefaultDependency(): Promise<ControllerType> {
  if (await hasDependency(equatable)) {
    return ControllerType.Equatable;
  } else {
    return ControllerType.Simple;
  }
}
