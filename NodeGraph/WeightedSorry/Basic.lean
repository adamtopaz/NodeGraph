import Lean

open Lean

namespace NodeGraph

structure Weight where
  val : Nat
deriving ToExpr

instance Weight.instOfNat (n : Nat) : OfNat Weight n where ofNat := .mk n

macro:max "wsorry" t:term:max : term => 
  `((sorry : Weight → _) $t) 

unsafe
def getWeightComponent (e : Expr) : MetaM Nat := do
  let (nm, args) := e.getAppFnArgs
  unless nm == ``sorryAx do return 0
  if h : args.size = 4 then 
    let shouldBeName := args[2]
    let shouldBeWeight := args[3]
    unless (← Meta.inferType shouldBeName) == .const `Lean.Name [] do return 0
    unless (← Meta.inferType shouldBeWeight) == .const `NodeGraph.Weight [] do return 0
    let weight := Expr.app (.const `NodeGraph.Weight.val []) args[3]
    let weight ← Meta.evalExpr Nat (.const `Nat []) weight
    return weight
  else 
    return 0

unsafe
def collectWeight (e : Expr) : MetaM Nat := Prod.snd <$> go.run 0
where go : StateT Nat MetaM Unit := Meta.forEachExpr e fun e => do
  let w ← getWeightComponent e
  modify (· + w)

def foo : Nat := 
  let a := wsorry 37 
  let b := wsorry 14 
  wsorry 213 + a + b

#eval show MetaM Unit from do
  let env ← getEnv
  let some c := env.find? `NodeGraph.foo | unreachable!
  let some val := c.value? | unreachable!
  let w ← collectWeight val
  println! w
