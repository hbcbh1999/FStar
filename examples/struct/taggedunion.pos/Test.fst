module Test

module TU = FStar.TaggedUnion
module HS = FStar.HyperStack
module HST = FStar.HyperStack.ST
module P = FStar.Pointer
module DM = FStar.DependentMap

#set-options "--initial_fuel 4"

(** Either *)

let either_l (a b : P.typ) : P.union_typ =
  [("left", a); ("right", b)]

let either_typ (a b : P.typ) : P.typ =
  TU.typ (either_l a b)

let either_tags (a b : P.typ) : TU.tags (either_l a b) =
  [0ul; 1ul]

let either (a b : P.typ) : Type0 =
  TU.t (either_l a b) (either_tags a b)


(** Option *)

let option_l (a : P.typ) : P.union_typ =
  [("none", P.(TBase TUnit)); ("some", a)]

let option_typ (a : P.typ) : P.typ =
  TU.typ (option_l a)

let option_tags (a : P.typ) : TU.tags (option_l a) =
  [0ul; 1ul]

let option (a : P.typ) : Type0 =
  TU.t (option_l a) (option_tags a)

(*******************)

let s_l : P.struct_typ = [("x", P.(TBase TUInt8)); ("y", P.(TBase TUInt8))]
// FIXME?
let s_x : P.struct_field s_l = "x"
let s_y : P.struct_field s_l = "y"

let s_typ : P.typ = P.TStruct s_l

let s_ty : P.struct_field s_l -> Type0 = function "x" -> UInt8.t | "y" -> UInt8.t
//let s_ty = P.type_of_struct_field' s_l P.type_of_typ
let s = DM.t (P.struct_field s_l) s_ty
let mk_s (x y: UInt8.t) : s =
  DM.create #(P.struct_field s_l) #s_ty (function "x" -> x | "y" -> y)

let st_typ = either_typ s_typ P.(TBase TUInt16)
let st_tags = either_tags s_typ P.(TBase TUInt16)

let includes_readable
  (#a #b: P.typ)
  (h: HS.mem)
  (p: P.pointer a)
  (p': P.pointer b)
: Lemma (requires (P.includes p p' /\ P.readable h p))
        (ensures (P.readable h p'))
  [SMTPat (P.readable h p'); SMTPat (P.includes p p')]
= admit ()

let step (p: P.pointer st_typ) :
  HST.Stack unit
  (requires (fun h -> TU.valid h st_tags p /\ P.readable h p))
  (ensures (fun h0 _ h1 ->
    TU.valid h0 st_tags p /\ P.readable h0 p /\
    TU.valid h1 st_tags p /\ P.readable h1 p /\
    TU.gread_tag h1 st_tags p == 0ul /\
    P.modifies_1 p h0 h1
  ))
=
  let t = TU.read_tag st_tags p in
  if t = 0ul then (
    let s_ptr = TU.field st_tags p "left" in
    let x_ptr = P.field s_ptr s_x in
    let x : UInt8.t = P.read x_ptr in
    let y : UInt8.t = P.read (P.field s_ptr s_y) in
    let h0 = HST.get () in
    P.write x_ptr (UInt8.logxor x y);
    let h1 = HST.get () in
    TU.modifies_1_valid st_tags p "left" h0 h1 x_ptr; // TODO: add a SMTPat
    TU.readable_intro st_tags p "left" h1; // TODO: SMTPat
    TU.modifies_1_tag st_tags p "left" 0ul h0 h1 // TODO: SMTPat
  ) else (
    assert (t == 1ul);
    let z : UInt16.t = P.read (TU.field st_tags p "right") in
    let x : UInt8.t = FStar.Int.Cast.uint16_to_uint8 z in
    let v : s = mk_s x 0uy in
    assert_norm (P.typ_of_struct_field (either_l s_typ P.(TBase TUInt16)) "left" == s_typ);
    assume (P.type_of_typ (P.typ_of_struct_field (either_l s_typ P.(TBase TUInt16)) "left") == s); // Cheating
    TU.write st_tags p "left" v
  )
