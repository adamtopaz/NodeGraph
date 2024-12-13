import Lean

open Lean

namespace NodeGraph

structure Graph (α : Type) [Hashable α] [BEq α] where
  nodes : Std.HashSet α
  edges : Std.HashSet (α × α)

namespace Graph

variable {α : Type} [Hashable α] [BEq α] (G : Graph α)

inductive Data (α : Type) where
  | node (val : α)
  | edge (src tgt : α)
deriving Inhabited

def serialize : Array (Data α) := Id.run do
  let mut out := #[]
  for a in G.nodes do
    out := out.push <| .node a
  for (a,b) in G.edges do
    out := out.push <| .edge a b
  return out

def deserialize (data : Array (Data α)) : Graph α := Id.run do
  let mut nodes := {}
  let mut edges := {}
  for item in data do
    match item with
    | .node a => nodes := nodes.insert a
    | .edge a b => edges := edges.insert (a,b)
  return .mk nodes edges

def addNode (a : α) : Graph α where
  nodes := G.nodes.insert a
  edges := G.edges

def addEdge (src tgt : α) : Graph α where
  nodes := G.nodes.insertMany [src,tgt]
  edges := G.edges.insert (src,tgt)

def addData (data : Data α) : Graph α :=
  match data with
  | .node a => G.addNode a
  | .edge a b => G.addEdge a b

def removeEdge (src tgt : α) : Graph α where
  nodes := G.nodes.insertMany [src,tgt]
  edges := G.edges.erase (src,tgt)

def empty : Graph α where
  nodes := {}
  edges := {}

instance : EmptyCollection (Graph α) where
  emptyCollection := .empty

instance : Singleton α (Graph α) where
  singleton a := .empty |>.addNode a

instance : Insert α (Graph α) where
  insert a G := G.addNode a

instance : Inhabited (Graph α) where default := {}

def union (H : Graph α) : Graph α where
  nodes := G.nodes.union H.nodes
  edges := G.edges.union H.edges

instance : Union (Graph α) where
  union A B := A.union B

def tclosure : Graph α := Id.run do
  let mut out := G
  for i in G.nodes do
    out := out.addEdge i i
  for k in G.nodes do for i in G.nodes do for j in G.nodes do
    if out.edges.contains (i,j) then continue
    if out.edges.contains (i,k) && out.edges.contains (k,j) then
      out := out.addEdge i j
  return out

def tred : Graph α := Id.run do
  let closure := G.tclosure
  let mut out := G
  for (src,tgt) in G.edges do
    for k in G.nodes do
      if src != k then
      if tgt != k then
      if closure.edges.contains (src,k) then
      if closure.edges.contains (k,tgt) then
        out := out.removeEdge src tgt
        break
  for node in out.nodes do
    out := out.removeEdge node node
  return out

def componentTo (a : α) [ToString α] : Except String (Graph α) := do
  unless G.nodes.contains a do throw s!"The graph does not contain {a}"
  let mut out : Graph α := {a}
  let mut queue : Array α := #[a]
  let mut edgesToVisit := G.edges
  while h : queue.size > 0 do
    let current := queue[queue.size - 1]
    queue := queue.pop
    let mut edgesToRemove : Std.HashSet (α × α) := {}
    for (src,tgt) in edgesToVisit do
      unless tgt == current do continue
      out := out.addEdge src tgt
      queue := queue.push src
      edgesToRemove := edgesToRemove.insert (src,tgt)
    for edge in edgesToRemove do
      edgesToVisit := edgesToVisit.erase edge
  return out

def componentFrom (a : α) [ToString α] : Except String (Graph α) := do
  unless G.nodes.contains a do throw s!"The graph does not contain {a}"
  let mut out : Graph α := {a}
  let mut queue : Array α := #[a]
  let mut edgesToVisit := G.edges
  while h : queue.size > 0 do
    let current := queue[queue.size - 1]
    queue := queue.pop
    let mut edgesToRemove : Std.HashSet (α × α) := {}
    for (src,tgt) in edgesToVisit do
      unless src == current do continue
      out := out.addEdge src tgt
      queue := queue.push tgt
      edgesToRemove := edgesToRemove.insert (src,tgt)
    for edge in edgesToRemove do
      edgesToVisit := edgesToVisit.erase edge
  return out

end Graph
