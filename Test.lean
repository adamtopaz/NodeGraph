import NodeGraph

def doc : String :=
  s!"Some additional text {"test"}" ++ " something"

/-- This is an element of $\mathbb{N}$. -/
@[node doc in defs]
def a : Nat :=
  subnode "Just zero!" in 0 +
  subnode "Just one!" in 1

@[node in defs]
axiom f : Nat

@[node in defs]
noncomputable def b : Nat × wsorry 5 := (a + wsorry 10 + f, wsorry 20)

@[node in lemmas]
theorem foo : b = (0, wsorry 73) := sorry

#decl_graph
#decl_graph from b
#decl_graph in defs to b
#group_graph
