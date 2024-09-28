open Webapi

type simpleAmount = Composition.simpleAmount

type amountGetter = {
  amount: float,
  getter: string
}

let ag = (a: float, g: string): amountGetter => {
  {
    amount: a,
    getter: g
  }
}

let calculate = (inputFields: array<simpleAmount>) => {
  // All in (g) or kJ

  // ------------------------------------------------------------------------------
  // Essentials
  // ------------------------------------------------------------------------------
  let dict = Dict.fromArray([
    ("Protein", ag(0.0, "Protein; protcnt")),
    ("Fat",     ag(0.0, "Total Fat; fatce")),
    ("Fibre",   ag(0.0, "Dietary Fiber; fibtg")),
    ("Carbohydrates", ag(0.0, "Carbohydrate; choavldf")),
    ("Energy",  ag(0.0, "Energy; enerc")),
    ("Starch",  ag(0.0, "Starch; starch")),

    ("Vitamin A", ag(0.0, "Vitamin A; vita")),
    ("Vitamin B", ag(0.0, "Vitamin B; vitb")),
    ("Vitamin C", ag(0.0, "Ascorbic acids (C); vitc")),
    ("Vitamin D", ag(0.0, "Vitamin D; vitd")),
    ("Vitamin E", ag(0.0, "α-Tocopherol equivalent (E); vite")),
    ("Vitamin K", ag(0.0, "Vitamin K; vitk")),

    ("Calcium",     ag(0.0, "Calcium (Ca); ca")),
    ("Copper",      ag(0.0, "Copper (Cu); cu")),
    ("Iron",        ag(0.0, "Iron (Fe); fe")),
    ("Magnesium",   ag(0.0, "Magnesium (Mg); mg")),
    ("Phosphorous", ag(0.0, "Phosphorus (P); p")),
    ("Zinc",        ag(0.0, "Zinc (Zn); zn"))
    
  ])

  Belt.Array.forEach(inputFields, inputField => {
    let foodItem: 'a = Js.Dict.unsafeGet(Composition.compositions, inputField.code)
    let amountIn100Grams = inputField.amount *. 10.0

    Dict.forEachWithKey(dict, (value, key) => {
      Dict.set(dict, key, ag(
        value.amount +.
          (amountIn100Grams *. (Js.Dict.unsafeGet(foodItem, value.getter) :> float)),
        value.getter
      ))
    })
  })

  dict
}

module Result = {
  @react.component
  let make = (~active, ~setActive, ~inputFields) => {
    <div className={"modal " ++ (active ? "is-active" : "")}>
      <div className="modal-background" />
      <div className="modal-card">
        <header className="modal-card-head">
          <p className="modal-card-title"> {React.string("Result")} </p>

        </header>
        <section className="modal-card-body">
          {
            React.array({
              Dict.toArray(calculate(inputFields))
              -> Belt.Array.map(keyAmountGetter => {
                let (key, amountGetter) = keyAmountGetter
                <p>
                  {React.string(
                    `${key}: ${Float.parseFloat(Float.toPrecision(amountGetter.amount, ~digits=9)) -> Float.toString(~radix=10)}${key == "Energy" ? "kJ" : "g"}`
                  )}
                </p>
              })
            })
          }
        </section>
        <footer className="modal-card-foot">
        <div className="buttons">
          <button className="button is-danger has-text-white" ariaLabel="close" onClick= {
            _ => setActive(_ => false)
          }>
            {React.string("x")}
          </button>
          </div>
        </footer>
      </div>
    </div>
  }
}
