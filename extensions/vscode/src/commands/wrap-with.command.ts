import { wrapWith } from "../utils";

const obxSnippet = (widget: string) => {
  return `Obx(() {
    final state = controller.state;
    return ${widget};
  },
)`;
};

const listenerWidgetSnippet = (widget: string) => {
  return `ListenerWidget(
  controller,
  (state) {
    \${3:// TODO: implement listener}
  },
  child: ${widget},
)`;
};

const observerWidgetSnippet = (widget: string) => {
  return `ObserverWidget(
  controller,
  (state) {
    \${3:// TODO: return widget here based on Controller's state}
    return ${widget};
  },
)`;
};

export const wrapWithObx = async () => wrapWith(obxSnippet);
export const wrapWithListenerWidget = async () => wrapWith(listenerWidgetSnippet);
export const wrapWithObserverWidget = async () => wrapWith(observerWidgetSnippet);
