﻿#light "off"
module FStar.Tests.Pars
open FSharp.Compatibility.OCaml
open FStar
open FStar.Range
open FStar.Parser
open FStar.Util
open FStar.Syntax
open FStar.Syntax.Syntax
open FStar.Errors
module DsEnv = FStar.ToSyntax.Env
module TcEnv = FStar.TypeChecker.Env
module SMT = FStar.SMTEncoding.Solver
module Tc = FStar.TypeChecker.Tc
module TcTerm = FStar.TypeChecker.TcTerm
module ToSyntax = FStar.ToSyntax.ToSyntax

let test_lid = Ident.lid_of_path ["Test"] Range.dummyRange
let tcenv_ref = ref None
let test_mod_ref = ref (Some ({name=test_lid;
                                declarations=[];
                                exports=[];
                                is_interface=false}))

let parse_mod mod_name dsenv =
    match ParseIt.parse (Inl mod_name) with
    | Inl (Inl m, _) ->
        let m, env'= ToSyntax.ast_modul_to_modul m dsenv in
        let env' , _ = DsEnv.prepare_module_or_interface false false env' (FStar.Ident.lid_of_path ["Test"] (FStar.Range.dummyRange)) DsEnv.default_mii in
        env', m
    | _ -> failwith "Unexpected "

let add_mods mod_names dsenv env =
  List.fold_left (fun (dsenv,env) mod_name ->
      let dsenv, string_mod = parse_mod mod_name dsenv in
      let _mod, env = Tc.check_module env string_mod in
      (dsenv, env)
  ) (dsenv,env) mod_names

let init_once () : unit =
  let solver = SMT.dummy in
  let env = TcEnv.initial_env
                FStar.Parser.Dep.empty_deps
                TcTerm.tc_term
                TcTerm.type_of_tot_term
                TcTerm.universe_of
                solver
                Const.prims_lid in
  env.solver.init env;
  let dsenv, prims_mod = parse_mod (Options.prims()) (DsEnv.empty_env()) in
  let env = {env with dsenv=dsenv} in
  let _prims_mod, env = Tc.check_module env prims_mod in
// only needed by normalization test #24, probably quite expensive otherwise
//  let dsenv, env = add_mods ["FStar.PropositionalExtensionality.fst"; "FStar.FunctionalExtensionality.fst"; "FStar.PredicateExtensionality.fst";
//                             "FStar.TSet.fst"; "FStar.Heap.fst"; "FStar.ST.fst"; "FStar.All.fst"; "FStar.Char.fsti"; "FStar.String.fsti"] dsenv env in
  let env = TcEnv.set_current_module env test_lid in
  tcenv_ref := Some env

let rec init () =
    match !tcenv_ref with
        | Some f -> f
        | _ -> init_once(); init()

open FStar.Parser.ParseIt
let frag_of_text s = {frag_text=s; frag_line=1; frag_col=0}

let failed_to_parse s e =
    match e with
        | Err msg ->
            printfn "Failed to parse %s\n%s\n" s msg;
            exit -1
        | Error(msg, r) ->
            printfn "Failed to parse %s\n%s: %s\n" s (Range.string_of_range r) msg;
            exit -1
        | _ -> raise e

let pars s =
    try
          let tcenv = init() in
          let resetLexbufPos filename (lexbuf: Microsoft.FSharp.Text.Lexing.LexBuffer<char>) =
            lexbuf.EndPos <- {lexbuf.EndPos with
            pos_fname= filename;
            pos_cnum=0;
            pos_lnum=1 } in
          let filename,sr,fs = "<input>", new System.IO.StringReader(s) :> System.IO.TextReader, s  in
          let lexbuf = Microsoft.FSharp.Text.Lexing.LexBuffer<char>.FromTextReader(sr) in
          resetLexbufPos filename lexbuf;
          let lexargs = Lexhelp.mkLexargs ((fun () -> "."), filename,fs) in
          let lexer = LexFStar.token lexargs in
          let t = Parser.Parse.term lexer lexbuf in
          ToSyntax.desugar_term tcenv.dsenv t
     with
        | e when not ((Options.trace_error())) -> failed_to_parse s e

let tc s =
    let tm = pars s in
    let tcenv = init() in
    let tcenv = {tcenv with top_level=false} in
    let tm, _, _ = TcTerm.tc_tot_or_gtot_term tcenv tm in
    tm

let pars_and_tc_fragment (s:string) =
    Options.set_option "trace_error" (Options.Bool true);
    let report () = FStar.Errors.report_all () |> ignore in
    try
        let tcenv = init() in
        let frag = frag_of_text s in
        try
          let test_mod', tcenv' = FStar.Universal.tc_one_fragment !test_mod_ref tcenv frag in
          test_mod_ref := test_mod';
          tcenv_ref := Some tcenv';
          let n = get_err_count () in
          if n <> 0
          then (report ();
                raise (Err (Util.format1 "%s errors were reported" (string_of_int n))))
        with e -> report(); raise (Err ("tc_one_fragment failed: " ^s))
    with
        | e when not ((Options.trace_error())) -> failed_to_parse s e
