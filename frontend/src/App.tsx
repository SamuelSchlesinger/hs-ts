import React from 'react';
import './App.css';
import { ExampleRequest, ExampleResponse } from './Api.js';
import styled from 'styled-components';

function exampleEndpoint(exampleRequest: ExampleRequest): Promise<ExampleResponse> {
  return fetch('http://localhost:3001/example',
    { method: 'POST'
    , mode: 'cors'
    , cache: 'no-cache'
    , credentials: 'omit'
    , headers: {
      'Content-Type': 'application/json'
    }
    , redirect: 'follow'
    , referrerPolicy: 'no-referrer'
    , body: JSON.stringify(exampleRequest)
    }
  ).then((r) => r.json())
}

const AppContainer = styled.div`
  text-align: center;
`

function ifThenElse<X>(b:boolean, x:X, y:X): X {
  if (b) {
    return x;
  } else {
    return y;
  }}

function ExampleForm(props: { input: string, output: string | null, onInputChange: (e:React.ChangeEvent<HTMLInputElement>) => void }) {
  return (
    <form >
      <input type="string" onChange={props.onInputChange} value={props.input}/>
      <p> Amazing output: { props.output } </p>
    </form>
      )
}

function App() {
  const [input, setInput] = React.useState("");
  const [output, setOutput] = React.useState<string>("")
  React.useEffect(() =>
    { const setEm = async () =>
      { const x = await exampleEndpoint({someField: input});
        setOutput((_o) => x.anotherField);
      }
      setEm();
    }
  , [input]);
  const onInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setInput((_i) => e.target.value);
  };
  return (
    <AppContainer className="App">
      <h1> Haskell + TypeScript Example </h1>
      <ExampleForm input={input} output={output} onInputChange={onInputChange}/>
    </AppContainer>
  );
}

export default App;
