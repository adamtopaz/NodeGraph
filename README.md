# AutoBlueprint

A toolset for viewing and automatically creating dependency graphs 
within the Lean4 infoview. 

## Basic usage

First, add this repository as a dependency in your lakefile, as usual.
Then make a file in the project with the following code, 
and click around the various places where it says `node` or `subnode`.
Then put your cursor on one of the various commands at the bottom to see 
the automatically generated graphs.

```lean
import AutoBlueprint
import Mathlib.Data.Real.Basic

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
noncomputable def b : Nat := a + a + sorry + f

@[node in lemmas]
lemma foo : b = 0 := sorry

#decl_graph
#decl_graph from b
#decl_graph in defs to b
#group_graph
```

## Usage

Nodes should be tagged with the `@[node]` attribute.
To provide an additional markdown explanation for a node, you can do one of the following:

```lean
@[node "This is foo"]
def foo : Nat := 0
```
```lean
def a : String := "foo"
def fooDoc := s!"This is {a}"

@[node fooDoc]
def foo : Nat := 0
```

To place a node into a certain group, use the `in group1 group2 ...` syntax as follows:
```lean
@[node "This is foo" in defs zeros]
def foo : Nat := 0
```
The above will include the node into the groups `defs` and `zeros`.

Subnodes correspond to terms or tactics that can be tagged as such with the `subnode string in term` or `subnode string in tactic` syntax (the string is optional in both cases): 
```lean
@[node "This is foo" in defs ones]
def foo : Nat := subnode in 0 + subnode "one" in 1 

@[node "This is bar"]
def bar : True := by
  subnode "Should be easy?"
  subnode "Okay, it was easy" in trivial
```

The `#decl_graph` command will show the full declaration graph which includes *all* declarations tagged with `node`.
To see the component of the graph terminating in `foo`, use `#decl_graph to foo`.
To see the component of the graph originating from `foo`, use `#decl_graph from foo`.
To see just the graph involving nodes in a certain group, use `#decl_graph in group`. 
To restrict the graph associated to a group further, it's possible to also write `#decl_graph in group from foo` and `#decl_graph in group from foo`.

The `#group_graph` command will display the graph of the various groups and the dependencies between them.
Clicking on a node in the group graph will show the graph associated to that group.