open Webapi.Dom

type simpleAmount = Composition.simpleAmount

module ThemeButton = {
  @react.component
  let make = (~className) => {
    let (theme, setTheme) = React.useState(_ => "")
    let html = document -> Document.documentElement
    let setAttribute = (e, a) => {
      Element.setAttribute(e, "data-theme", a)
      setTheme(_ => a)
    }
    

    <button onClick={
      _ => switch (Element.getAttribute(html, "data-theme")) {
        | Some("dark") => setAttribute(html, "light")
        | _ => setAttribute(html, "dark")
      }} className={className ++ " " ++ (theme == "dark" ? "is-link" : "is-warning")}
    >
      <img src={
        theme == "dark"
          ? "resources/cloud-moon-fill.svg"
          : "resources/brightness-alt-low-fill.svg"
        } width="30" height="30"
      />
    </button>
  }
}

module Navbar = {
  @react.component
  let make = () => {
    <nav className="navbar has-shadow" role="navigation" ariaLabel="Navigation">
      <div className="navbar-brand" style={ReactDOM.Style.make(~width="100%", ())}>
        <a className="navbar-item" href="/">
	  <object data="icon.svg" width="50" height="50" className="m-0"/>
        </a>
        <ThemeButton className="button m-2 ml-auto p-1" />
      </div>
    </nav>
  }
}

type inputType =
  | Select
  | Number

module Input = {
  @react.component
  let make = (~inputFields, ~setInputFields, ~index) => {
    let handleOnChange = (event, inputType: inputType) => {
      setInputFields(_ =>
        Belt.Array.mapWithIndex(inputFields, (i, ca: simpleAmount) => {
          if i == index {
            switch inputType {
              | Select => { ...ca, code: (JsxEvent.Form.target(event)["value"]) }
              | Number => { ...ca, amount: (
                (JsxEvent.Form.target(event)["value"] :> string)
                  -> Belt.Float.fromString
                  -> Belt.Option.getWithDefault(0.0)
              )}
            }
          } else { ca }
        })
      )
    }
    
    <div className="field">
      <label className="label"> {React.string("Select Food Item")} </label>
      <div className="control">
        <div className="select is-rounded" onChange={
          event => event -> handleOnChange(Select)
        }>
          <select required={true}>
          {
            React.array(
              Belt.Array.map(
                Composition.simpleFoodArray, f =>
                { <option key={f.code} id={f.code} value={f.code}> {React.string(f.name)} </option> }
              )
            )
          }
          </select>
        </div>
      </div>
      <label className="label mt-2"> {React.string("Amount (kg)")} </label>
      <div className="control">
        <input type_="number" required={true} className="input" onChange={
          event => event -> handleOnChange(Number)
        }/>
      </div>
      <button className="button is-danger mt-4 has-text-white" onClick={
        _ => setInputFields(_ => Belt.Array.keepWithIndex(inputFields, (_, i) => i != index))
      }>
        {React.string("x")}
      </button>
      <hr />
    </div>
  }
}



module Diet = {
  @react.component
  let make = (~setActive, ~inputFields, ~setInputFields) => {
    
    <div className="section">
      <div className="card">
        <header className="card-header">
          <p className="card-header-title"> {React.string("Nutrition Calculator")} </p>
        </header>
        <div className="card-content">
          {React.array(
            Belt.Array.mapWithIndex(inputFields, (index, _) => {
              <Input key={Belt.Int.toString(index)} inputFields setInputFields index/>
            })
          )}
        </div>
        <footer className="card-footer">
          <button className="card-footer-item has-text-success" onClick={
            _ => setInputFields(_ => Belt.Array.concat(inputFields, [{code: "A001", amount: 0.0}]))
          }>
            {React.string("Add Food Item")}
          </button>
          <button className="card-footer-item has-text-success" onClick={
            _ => setActive(_ => true)
          }>
            {React.string("Calculate")}
          </button>
        </footer>
      </div>
    </div>
  }
}

module Footer = {
  @react.component
  let make = () => {
    <footer className="footer">
      <div className="content has-text-centered">
        <p>
          <strong> {React.string("Nutritiona")} </strong>
          {React.string(" created by ")}
          <a href="www.github.com/jrrom"> {React.string("jrrom")} </a>
          {React.string(" for VSO MAHE Global Goals Week")}
        </p>
      </div>
    </footer>
  }
}
module MainPage = {
  @react.component
  let make = () => {
    let (active, setActive) = React.useState(_ => false)
    let (inputFields, setInputFields) = React.useState(_ => [{
      code: "A001",
      amount: 0.0
    }: simpleAmount])
    
    <>
      <Navbar />
      <Diet setActive inputFields setInputFields/>
      <Compute.Result active setActive inputFields/>
      <Footer />
    </>
  }
}

switch ReactDOM.querySelector("#root") {
| Some(rootElement) => {
    let root = ReactDOM.Client.createRoot(rootElement)
    ReactDOM.Client.Root.render(root, <MainPage />)
  }
| None => {
    Console.log("Root not found.")
  }
}
