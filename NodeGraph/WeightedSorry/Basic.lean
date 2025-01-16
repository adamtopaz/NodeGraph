import Lean

open Lean

namespace NodeGraph

structure Weight where
  val : Nat
deriving ToExpr, BEq, Hashable

structure WSorry where
  weight : Weight
  type : Expr
  name : Name
deriving BEq, Hashable

instance Weight.instOfNat (n : Nat) : OfNat Weight n where ofNat := .mk n

macro:max "wsorry" t:term:max : term => 
  `((sorry : Weight → _) $t) 

unsafe
def getWSorry (e : Expr) : MetaM (Option WSorry) := do
  let (nm, args) := e.getAppFnArgs
  unless nm == ``sorryAx do return none
  if h : args.size = 4 then 
    let shouldBeName := args[2]
    let shouldBeWeight := args[3]
    unless (← Meta.inferType shouldBeName) == .const `Lean.Name [] do return none
    unless (← Meta.inferType shouldBeWeight) == .const `NodeGraph.Weight [] do return none
    let name ← Meta.evalExpr Name (.const `Lean.Name []) args[2]
    let weight := Expr.app (.const `NodeGraph.Weight.val []) args[3]
    let weight ← Meta.evalExpr Nat (.const `Nat []) weight
    return some ⟨⟨weight⟩, args[0], name⟩
  else 
    return none

unsafe
def collectWSorriesInExpr (e : Expr) : MetaM (Std.HashSet WSorry) := Prod.snd <$> go.run {}
where go : StateT (Std.HashSet WSorry) MetaM Unit := Meta.forEachExpr e fun e => do
  if let some val ← getWSorry e then modify fun S => S.insert val

unsafe
def collectWSorriesInConst (e : ConstantInfo) : MetaM (Std.HashSet WSorry) := do
  let tpWeight ← collectWSorriesInExpr e.type
  let valWeight : Std.HashSet (Expr × Nat) ← match e.value? with
  | some val => collectWSorriesInExpr val
  | none => pure .empty
  return tpWeight.union valWeight

unsafe
def collectConstWeight (e : ConstantInfo) : MetaM Nat := do
  let wsorries ← collectWSorriesInConst e
  let mut out := 0
  for ⟨⟨a⟩, _, _⟩ in wsorries do
    out := out + a
  return out
