declare module "*.elm" {
  export interface Flags {
    checkOnChange: boolean;
  }

  export interface App {
    ports: any;
  }

  export interface Main {
    init: ({ node: HTMLElement, flags: Flags }) => App;
  }

  const Elm: {
    Main: Main;
  };

  export default Elm;
}
