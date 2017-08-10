module PureParser

open KeyValue

open FStar.Seq
module U8 = FStar.UInt8
module U16 = FStar.UInt16
module U32 = FStar.UInt32
module Cast = FStar.Int.Cast

(*** Spec-level pure parsing to values *)

// parse a value of type t
// - the parser can fail (currently reporting an uninformative [None])
// - it returns the parsed value as well as the number of bytes read
//   (this is intended to be the number of bytes to advance the input pointer)
let parser (t:Type) = b:bytes{length b < pow2 32} -> Tot (option (t * n:nat{n <= length b}))

// parsers form a monad; this is bind for the parser monad
val and_then : #t:Type -> #t':Type ->
                p:parser t ->
                p': (t -> parser t') ->
                parser t'
let and_then #t #t' p p' b =
  match p b with
  | Some (v, l) ->
    begin
      match p' v (slice b l (length b)) with
      | Some (v', l') -> Some (v', l + l')
      | None -> None
    end
  | None -> None

// the monadic return for parsers
unfold let parse_ret (#t:Type) (v:t) : parser t =
  fun _ -> Some (v, 0)

let fail_parser #t : parser t = fun b -> None

let parse_result (#t:Type) (#b:bytes)
  (r: option (t * n:nat{n <= length b}){Some? r}) : t =
  fst (Some?.v r)

let parse_u8: parser U8.t =
  fun b -> if length b < 1 then None
        else Some (index b 0, 1)

inline_for_extraction unfold
val u16_from_bytes: hi:byte -> lo:byte -> U16.t
let u16_from_bytes hi lo =
  U16.add (U16.shift_left (Cast.uint8_to_uint16 hi) 8ul) (Cast.uint8_to_uint16 lo)

val u16_from_be: b:bytes{length b == 2} -> U16.t
let u16_from_be b = u16_from_bytes (index b 0) (index b 1)

let parse_u16: parser U16.t =
  fun b -> if length b < 2 then None
        else Some (u16_from_be (slice b 0 2), 2)

assume val u32_from_be: b:bytes{length b == 4} -> U32.t

let parse_u32: parser U32.t =
  fun b -> if length b < 4 then None
        else Some (u32_from_be (slice b 0 4), 4)

val parse_u16_array: parser u16_array
let parse_u16_array =
  parse_u16 `and_then`
  (fun array_len b' ->
    if length b' < U16.v array_len then None
    else let data = slice b' 0 (U16.v array_len) in
    Some (U16Array array_len data, U16.v array_len))

val parse_u32_array: parser u32_array
let parse_u32_array =
  parse_u32 `and_then`
  (fun array_len b' ->
    if length b' < U32.v array_len then None
    else let data = slice b' 0 (U32.v array_len) in
    Some (U32Array array_len data, U32.v array_len))

val parse_entry : parser encoded_entry
let parse_entry =
  parse_u16_array `and_then`
  (fun key -> parse_u32_array `and_then`
  (fun value ->
  parse_ret (EncodedEntry key.len16 key.a16 value.len32 value.a32)))

let parsing_done : parser unit =
  fun b -> if length b = 0 then Some ((), 0) else None

val parse_many : #t:Type -> p:parser t -> n:nat -> parser (l:list t{List.length l == n})
let rec parse_many #t p n =
  match n with
  | 0 -> parse_ret []
  | _ -> let n':nat = n-1 in
      p `and_then`
      (fun v -> parse_many #t p n' `and_then`
      (fun l -> parse_ret #(l:list t{List.length l == n}) (v::l)))

let parse_abstract_store : parser store =
  parse_u32 `and_then`
  (fun num_entries -> parse_many parse_entry (U32.v num_entries) `and_then`
  (fun entries -> parsing_done `and_then`
  (fun _ -> parse_ret (Store num_entries entries))))

let parse_entries (num_entries:U32.t) : parser store =
  parse_many parse_entry (U32.v num_entries) `and_then`
  (fun entries -> parsing_done `and_then`
  (fun _ -> parse_ret (Store num_entries entries)))