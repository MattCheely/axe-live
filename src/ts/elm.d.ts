declare module "*.elm" {
  export interface Flags {
    initialize: boolean;
    state: any;
  }

  export interface App {
    ports: any;
  }

  export interface Main {
    init: ({ node: HTMLElement }) => App;
  }

  const Elm: {
    Main: Main;
  };

  export default Elm;
}
