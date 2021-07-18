declare module "*.elm" {
  export interface Flags {
    initialize: boolean;
    state: any;
  }

  export interface App {
    ports: any;
  }

  export interface ErrorPanel {
    init: ({ node: HTMLElement, flags: Flags }) => App;
  }

  const Elm: {
    ErrorPanel: ErrorPanel;
  };

  export default Elm;
}
