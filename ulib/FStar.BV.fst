module FStar.BV

module U = FStar.UInt
module B = FStar.BitVector

let bv_t (n : nat) = B.bv_t n

let bvand = B.logand_vec
let bvxor = B.logxor_vec
let bvor = B.logor_vec
let bvnot = B.lognot_vec

(*TODO: specify index functions? *)
let bvshl = B.shift_left_vec
let bvshr = B.shift_right_vec

let int2bv = U.to_vec
let bv2int = U.from_vec

let int2bv_lemma_1 = U.to_vec_lemma_1
let int2bv_lemma_2 = U.to_vec_lemma_2

let bvdiv #n a b = 
    int2bv #n (U.udiv #n (bv2int #n a) b)    
let bvmod #n a b = 
    int2bv #n (U.mod #n (bv2int #n a) b)

let inverse_vec_lemma = U.inverse_vec_lemma
let inverse_num_lemma = U.inverse_num_lemma

let int2bv_logand #n #x #y #z pf =
  inverse_vec_lemma #n (bvand #n (int2bv #n x) (int2bv #n y));
  ()
  
let int2bv_logxor #n #x #y #z pf =
  inverse_vec_lemma #n (bvxor #n (int2bv x) (int2bv y));
  ()

let int2bv_logor #n #x #y #z pf =
  inverse_vec_lemma #n (bvor #n (int2bv x) (int2bv y));
  ()

let int2bv_shl #n #x #y #z pf =
  inverse_vec_lemma #n (bvshl #n (int2bv #n x) y);			    
  ()
  
let int2bv_shr #n #x #y #z pf =
  inverse_vec_lemma #n (bvshr #n (int2bv #n x) y);
  ()

let int2bv_div #n #x #y #z pf =
  inverse_vec_lemma #n (bvdiv #n (int2bv #n x) y);
  ()