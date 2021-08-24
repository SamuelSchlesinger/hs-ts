export interface IExampleRequest {
  someField: string;
}

export interface IExampleResponse {
  anotherField: string;
}

export type ExampleRequest = IExampleRequest;

export type ExampleResponse = IExampleResponse;
