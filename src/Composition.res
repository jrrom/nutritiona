@module external compositions: 'a = "../../../composition.json"

type simpleComposition = {
  code: string,
  name: string
}

type simpleAmount = {
  code: string,
  amount: float
}

let getFoods = (compositions: 'a): array<simpleComposition> => {
  let temp: array<simpleComposition> = []
  compositions
    -> Js.Dict.keys
    -> Belt.Array.forEach(
      k => Belt.Array.push(temp, {
        code: k,
        name: Js.Dict.unsafeGet(compositions, k)["Food Name; name"]
      })
    )

  temp
}

let simpleFoodArray = getFoods(compositions)
