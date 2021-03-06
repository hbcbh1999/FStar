module EtM.CoreCrypto
open Platform.Bytes
include CoreCrypto

assume 
val block_encrypt_spec:
    block_cipher
  -> bytes 
  -> bytes
  -> bytes
  -> GTot bytes
       
assume 
val block_decrypt_spec: 
    block_cipher 
  -> bytes 
  -> bytes 
  -> bytes 
  -> GTot bytes

assume
val enc_dec_inverses (b:block_cipher) (raw_key:bytes) (iv:bytes) (plain:bytes)
    : Lemma (block_decrypt_spec b raw_key iv 
                                (block_encrypt_spec b raw_key iv plain)
             == plain)
             
let block_enc (b:block_cipher) (raw_key:bytes) (iv:bytes) (plain:bytes) :
    EXT (c:bytes{c == block_encrypt_spec b raw_key iv plain}) = 
    admit();
    block_encrypt b raw_key iv plain

let block_dec (b:block_cipher) (raw_key:bytes) (iv:bytes) (cipher:bytes) :
    EXT (p:bytes{p == block_decrypt_spec b raw_key iv cipher}) = 
    admit();
    block_decrypt b raw_key iv cipher
