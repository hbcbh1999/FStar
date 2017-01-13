
open Prims

let trans_aqual : FStar_Parser_AST.arg_qualifier Prims.option  ->  FStar_Syntax_Syntax.arg_qualifier Prims.option = (fun _67_1 -> (match (_67_1) with
| Some (FStar_Parser_AST.Implicit) -> begin
Some (FStar_Syntax_Syntax.imp_tag)
end
| Some (FStar_Parser_AST.Equality) -> begin
Some (FStar_Syntax_Syntax.Equality)
end
| _67_33 -> begin
None
end))


let trans_qual : FStar_Range.range  ->  FStar_Ident.lident Prims.option  ->  FStar_Parser_AST.qualifier  ->  FStar_Syntax_Syntax.qualifier = (fun r maybe_effect_id _67_2 -> (match (_67_2) with
| FStar_Parser_AST.Private -> begin
FStar_Syntax_Syntax.Private
end
| FStar_Parser_AST.Assumption -> begin
FStar_Syntax_Syntax.Assumption
end
| FStar_Parser_AST.Unfold_for_unification_and_vcgen -> begin
FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen
end
| FStar_Parser_AST.Inline_for_extraction -> begin
FStar_Syntax_Syntax.Inline_for_extraction
end
| FStar_Parser_AST.NoExtract -> begin
FStar_Syntax_Syntax.NoExtract
end
| FStar_Parser_AST.Irreducible -> begin
FStar_Syntax_Syntax.Irreducible
end
| FStar_Parser_AST.Logic -> begin
FStar_Syntax_Syntax.Logic
end
| FStar_Parser_AST.TotalEffect -> begin
FStar_Syntax_Syntax.TotalEffect
end
| FStar_Parser_AST.Effect -> begin
FStar_Syntax_Syntax.Effect
end
| FStar_Parser_AST.New -> begin
FStar_Syntax_Syntax.New
end
| FStar_Parser_AST.Abstract -> begin
FStar_Syntax_Syntax.Abstract
end
| FStar_Parser_AST.Opaque -> begin
(

let _67_49 = (FStar_TypeChecker_Errors.warn r "The \'opaque\' qualifier is deprecated since its use was strangely schizophrenic. There were two overloaded uses: (1) Given \'opaque val f : t\', the behavior was to exclude the definition of \'f\' to the SMT solver. This corresponds roughly to the new \'irreducible\' qualifier. (2) Given \'opaque type t = t\'\', the behavior was to provide the definition of \'t\' to the SMT solver, but not to inline it, unless absolutely required for unification. This corresponds roughly to the behavior of \'unfoldable\' (which is currently the default).")
in FStar_Syntax_Syntax.Visible_default)
end
| FStar_Parser_AST.Reflectable -> begin
(match (maybe_effect_id) with
| None -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Qualifier reflect only supported on effects"), (r)))))
end
| Some (effect_id) -> begin
FStar_Syntax_Syntax.Reflectable (effect_id)
end)
end
| FStar_Parser_AST.Reifiable -> begin
FStar_Syntax_Syntax.Reifiable
end
| FStar_Parser_AST.Noeq -> begin
FStar_Syntax_Syntax.Noeq
end
| FStar_Parser_AST.Unopteq -> begin
FStar_Syntax_Syntax.Unopteq
end
| FStar_Parser_AST.DefaultEffect -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("The \'default\' qualifier on effects is no longer supported"), (r)))))
end
| (FStar_Parser_AST.Inline) | (FStar_Parser_AST.Visible) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Unsupported qualifier"), (r)))))
end))


let trans_pragma : FStar_Parser_AST.pragma  ->  FStar_Syntax_Syntax.pragma = (fun _67_3 -> (match (_67_3) with
| FStar_Parser_AST.SetOptions (s) -> begin
FStar_Syntax_Syntax.SetOptions (s)
end
| FStar_Parser_AST.ResetOptions (sopt) -> begin
FStar_Syntax_Syntax.ResetOptions (sopt)
end))


let as_imp : FStar_Parser_AST.imp  ->  FStar_Syntax_Syntax.arg_qualifier Prims.option = (fun _67_4 -> (match (_67_4) with
| FStar_Parser_AST.Hash -> begin
Some (FStar_Syntax_Syntax.imp_tag)
end
| _67_69 -> begin
None
end))


let arg_withimp_e = (fun imp t -> ((t), ((as_imp imp))))


let arg_withimp_t = (fun imp t -> (match (imp) with
| FStar_Parser_AST.Hash -> begin
((t), (Some (FStar_Syntax_Syntax.imp_tag)))
end
| _67_76 -> begin
((t), (None))
end))


let contains_binder : FStar_Parser_AST.binder Prims.list  ->  Prims.bool = (fun binders -> (FStar_All.pipe_right binders (FStar_Util.for_some (fun b -> (match (b.FStar_Parser_AST.b) with
| FStar_Parser_AST.Annotated (_67_80) -> begin
true
end
| _67_83 -> begin
false
end)))))


let rec unparen : FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun t -> (match (t.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Paren (t) -> begin
(unparen t)
end
| _67_88 -> begin
t
end))


let tm_type_z : FStar_Range.range  ->  FStar_Parser_AST.term = (fun r -> (let _166_25 = (let _166_24 = (FStar_Ident.lid_of_path (("Type0")::[]) r)
in FStar_Parser_AST.Name (_166_24))
in (FStar_Parser_AST.mk_term _166_25 r FStar_Parser_AST.Kind)))


let tm_type : FStar_Range.range  ->  FStar_Parser_AST.term = (fun r -> (let _166_29 = (let _166_28 = (FStar_Ident.lid_of_path (("Type")::[]) r)
in FStar_Parser_AST.Name (_166_28))
in (FStar_Parser_AST.mk_term _166_29 r FStar_Parser_AST.Kind)))


let rec is_comp_type : FStar_Parser_Env.env  ->  FStar_Parser_AST.term  ->  Prims.bool = (fun env t -> (match (t.FStar_Parser_AST.tm) with
| (FStar_Parser_AST.Name (l)) | (FStar_Parser_AST.Construct (l, _)) -> begin
(let _166_34 = (FStar_Parser_Env.try_lookup_effect_name env l)
in (FStar_All.pipe_right _166_34 FStar_Option.isSome))
end
| FStar_Parser_AST.App (head, _67_101, _67_103) -> begin
(is_comp_type env head)
end
| (FStar_Parser_AST.Paren (t)) | (FStar_Parser_AST.Ascribed (t, _)) | (FStar_Parser_AST.LetOpen (_, t)) -> begin
(is_comp_type env t)
end
| _67_117 -> begin
false
end))


let unit_ty : FStar_Parser_AST.term = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.unit_lid)) FStar_Range.dummyRange FStar_Parser_AST.Type)


let compile_op_lid : Prims.int  ->  Prims.string  ->  FStar_Range.range  ->  FStar_Ident.lident = (fun n s r -> (let _166_44 = (let _166_43 = (let _166_42 = (let _166_41 = (FStar_Parser_AST.compile_op n s)
in ((_166_41), (r)))
in (FStar_Ident.mk_ident _166_42))
in (_166_43)::[])
in (FStar_All.pipe_right _166_44 FStar_Ident.lid_of_ids)))


let op_as_term : FStar_Parser_Env.env  ->  Prims.int  ->  FStar_Range.range  ->  Prims.string  ->  FStar_Syntax_Syntax.term Prims.option = (fun env arity rng s -> (

let r = (fun l dd -> (let _166_58 = (let _166_57 = (FStar_Syntax_Syntax.lid_as_fv (FStar_Ident.set_lid_range l rng) dd None)
in (FStar_All.pipe_right _166_57 FStar_Syntax_Syntax.fv_to_tm))
in Some (_166_58)))
in (

let fallback = (fun _67_129 -> (match (()) with
| () -> begin
(match (s) with
| "=" -> begin
(r FStar_Syntax_Const.op_Eq FStar_Syntax_Syntax.Delta_equational)
end
| ":=" -> begin
(r FStar_Syntax_Const.write_lid FStar_Syntax_Syntax.Delta_equational)
end
| "<" -> begin
(r FStar_Syntax_Const.op_LT FStar_Syntax_Syntax.Delta_equational)
end
| "<=" -> begin
(r FStar_Syntax_Const.op_LTE FStar_Syntax_Syntax.Delta_equational)
end
| ">" -> begin
(r FStar_Syntax_Const.op_GT FStar_Syntax_Syntax.Delta_equational)
end
| ">=" -> begin
(r FStar_Syntax_Const.op_GTE FStar_Syntax_Syntax.Delta_equational)
end
| "&&" -> begin
(r FStar_Syntax_Const.op_And FStar_Syntax_Syntax.Delta_equational)
end
| "||" -> begin
(r FStar_Syntax_Const.op_Or FStar_Syntax_Syntax.Delta_equational)
end
| "+" -> begin
(r FStar_Syntax_Const.op_Addition FStar_Syntax_Syntax.Delta_equational)
end
| "-" when (arity = (Prims.parse_int "1")) -> begin
(r FStar_Syntax_Const.op_Minus FStar_Syntax_Syntax.Delta_equational)
end
| "-" -> begin
(r FStar_Syntax_Const.op_Subtraction FStar_Syntax_Syntax.Delta_equational)
end
| "/" -> begin
(r FStar_Syntax_Const.op_Division FStar_Syntax_Syntax.Delta_equational)
end
| "%" -> begin
(r FStar_Syntax_Const.op_Modulus FStar_Syntax_Syntax.Delta_equational)
end
| "!" -> begin
(r FStar_Syntax_Const.read_lid FStar_Syntax_Syntax.Delta_equational)
end
| "@" -> begin
(r FStar_Syntax_Const.list_append_lid FStar_Syntax_Syntax.Delta_equational)
end
| "^" -> begin
(r FStar_Syntax_Const.strcat_lid FStar_Syntax_Syntax.Delta_equational)
end
| "|>" -> begin
(r FStar_Syntax_Const.pipe_right_lid FStar_Syntax_Syntax.Delta_equational)
end
| "<|" -> begin
(r FStar_Syntax_Const.pipe_left_lid FStar_Syntax_Syntax.Delta_equational)
end
| "<>" -> begin
(r FStar_Syntax_Const.op_notEq FStar_Syntax_Syntax.Delta_equational)
end
| "~" -> begin
(r FStar_Syntax_Const.not_lid (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "2"))))
end
| "==" -> begin
(r FStar_Syntax_Const.eq2_lid FStar_Syntax_Syntax.Delta_constant)
end
| "<<" -> begin
(r FStar_Syntax_Const.precedes_lid FStar_Syntax_Syntax.Delta_constant)
end
| "/\\" -> begin
(r FStar_Syntax_Const.and_lid (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "1"))))
end
| "\\/" -> begin
(r FStar_Syntax_Const.or_lid (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "1"))))
end
| "==>" -> begin
(r FStar_Syntax_Const.imp_lid (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "1"))))
end
| "<==>" -> begin
(r FStar_Syntax_Const.iff_lid (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "2"))))
end
| _67_157 -> begin
None
end)
end))
in (match ((let _166_61 = (compile_op_lid arity s rng)
in (FStar_Parser_Env.try_lookup_lid env _166_61))) with
| Some (t) -> begin
Some ((Prims.fst t))
end
| _67_161 -> begin
(fallback ())
end))))


let sort_ftv : FStar_Ident.ident Prims.list  ->  FStar_Ident.ident Prims.list = (fun ftv -> (let _166_68 = (FStar_Util.remove_dups (fun x y -> (x.FStar_Ident.idText = y.FStar_Ident.idText)) ftv)
in (FStar_All.pipe_left (FStar_Util.sort_with (fun x y -> (FStar_String.compare x.FStar_Ident.idText y.FStar_Ident.idText))) _166_68)))


let rec free_type_vars_b : FStar_Parser_Env.env  ->  FStar_Parser_AST.binder  ->  (FStar_Parser_Env.env * FStar_Ident.ident Prims.list) = (fun env binder -> (match (binder.FStar_Parser_AST.b) with
| FStar_Parser_AST.Variable (_67_170) -> begin
((env), ([]))
end
| FStar_Parser_AST.TVariable (x) -> begin
(

let _67_177 = (FStar_Parser_Env.push_bv env x)
in (match (_67_177) with
| (env, _67_176) -> begin
((env), ((x)::[]))
end))
end
| FStar_Parser_AST.Annotated (_67_179, term) -> begin
(let _166_75 = (free_type_vars env term)
in ((env), (_166_75)))
end
| FStar_Parser_AST.TAnnotated (id, _67_185) -> begin
(

let _67_191 = (FStar_Parser_Env.push_bv env id)
in (match (_67_191) with
| (env, _67_190) -> begin
((env), ([]))
end))
end
| FStar_Parser_AST.NoName (t) -> begin
(let _166_76 = (free_type_vars env t)
in ((env), (_166_76)))
end))
and free_type_vars : FStar_Parser_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Ident.ident Prims.list = (fun env t -> (match ((let _166_79 = (unparen t)
in _166_79.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Labeled (_67_197) -> begin
(failwith "Impossible --- labeled source term")
end
| FStar_Parser_AST.Tvar (a) -> begin
(match ((FStar_Parser_Env.try_lookup_id env a)) with
| None -> begin
(a)::[]
end
| _67_203 -> begin
[]
end)
end
| (FStar_Parser_AST.Wild) | (FStar_Parser_AST.Const (_)) | (FStar_Parser_AST.Uvar (_)) | (FStar_Parser_AST.Var (_)) | (FStar_Parser_AST.Projector (_)) | (FStar_Parser_AST.Discrim (_)) | (FStar_Parser_AST.Name (_)) -> begin
[]
end
| (FStar_Parser_AST.Assign (_, t)) | (FStar_Parser_AST.Requires (t, _)) | (FStar_Parser_AST.Ensures (t, _)) | (FStar_Parser_AST.NamedTyp (_, t)) | (FStar_Parser_AST.Paren (t)) | (FStar_Parser_AST.Ascribed (t, _)) -> begin
(free_type_vars env t)
end
| FStar_Parser_AST.Construct (_67_246, ts) -> begin
(FStar_List.collect (fun _67_253 -> (match (_67_253) with
| (t, _67_252) -> begin
(free_type_vars env t)
end)) ts)
end
| FStar_Parser_AST.Op (_67_255, ts) -> begin
(FStar_List.collect (free_type_vars env) ts)
end
| FStar_Parser_AST.App (t1, t2, _67_262) -> begin
(let _166_82 = (free_type_vars env t1)
in (let _166_81 = (free_type_vars env t2)
in (FStar_List.append _166_82 _166_81)))
end
| FStar_Parser_AST.Refine (b, t) -> begin
(

let _67_271 = (free_type_vars_b env b)
in (match (_67_271) with
| (env, f) -> begin
(let _166_83 = (free_type_vars env t)
in (FStar_List.append f _166_83))
end))
end
| (FStar_Parser_AST.Product (binders, body)) | (FStar_Parser_AST.Sum (binders, body)) -> begin
(

let _67_287 = (FStar_List.fold_left (fun _67_280 binder -> (match (_67_280) with
| (env, free) -> begin
(

let _67_284 = (free_type_vars_b env binder)
in (match (_67_284) with
| (env, f) -> begin
((env), ((FStar_List.append f free)))
end))
end)) ((env), ([])) binders)
in (match (_67_287) with
| (env, free) -> begin
(let _166_86 = (free_type_vars env body)
in (FStar_List.append free _166_86))
end))
end
| FStar_Parser_AST.Project (t, _67_290) -> begin
(free_type_vars env t)
end
| FStar_Parser_AST.Attributes (cattributes) -> begin
(FStar_List.collect (free_type_vars env) cattributes)
end
| (FStar_Parser_AST.Abs (_)) | (FStar_Parser_AST.Let (_)) | (FStar_Parser_AST.LetOpen (_)) | (FStar_Parser_AST.If (_)) | (FStar_Parser_AST.QForall (_)) | (FStar_Parser_AST.QExists (_)) | (FStar_Parser_AST.Record (_)) | (FStar_Parser_AST.Match (_)) | (FStar_Parser_AST.TryWith (_)) | (FStar_Parser_AST.Seq (_)) -> begin
[]
end))


let head_and_args : FStar_Parser_AST.term  ->  (FStar_Parser_AST.term * (FStar_Parser_AST.term * FStar_Parser_AST.imp) Prims.list) = (fun t -> (

let rec aux = (fun args t -> (match ((let _166_93 = (unparen t)
in _166_93.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.App (t, arg, imp) -> begin
(aux ((((arg), (imp)))::args) t)
end
| FStar_Parser_AST.Construct (l, args') -> begin
(({FStar_Parser_AST.tm = FStar_Parser_AST.Name (l); FStar_Parser_AST.range = t.FStar_Parser_AST.range; FStar_Parser_AST.level = t.FStar_Parser_AST.level}), ((FStar_List.append args' args)))
end
| _67_339 -> begin
((t), (args))
end))
in (aux [] t)))


let close : FStar_Parser_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun env t -> (

let ftv = (let _166_98 = (free_type_vars env t)
in (FStar_All.pipe_left sort_ftv _166_98))
in if ((FStar_List.length ftv) = (Prims.parse_int "0")) then begin
t
end else begin
(

let binders = (FStar_All.pipe_right ftv (FStar_List.map (fun x -> (let _166_102 = (let _166_101 = (let _166_100 = (tm_type x.FStar_Ident.idRange)
in ((x), (_166_100)))
in FStar_Parser_AST.TAnnotated (_166_101))
in (FStar_Parser_AST.mk_binder _166_102 x.FStar_Ident.idRange FStar_Parser_AST.Type (Some (FStar_Parser_AST.Implicit)))))))
in (

let result = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (((binders), (t)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
in result))
end))


let close_fun : FStar_Parser_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun env t -> (

let ftv = (let _166_107 = (free_type_vars env t)
in (FStar_All.pipe_left sort_ftv _166_107))
in if ((FStar_List.length ftv) = (Prims.parse_int "0")) then begin
t
end else begin
(

let binders = (FStar_All.pipe_right ftv (FStar_List.map (fun x -> (let _166_111 = (let _166_110 = (let _166_109 = (tm_type x.FStar_Ident.idRange)
in ((x), (_166_109)))
in FStar_Parser_AST.TAnnotated (_166_110))
in (FStar_Parser_AST.mk_binder _166_111 x.FStar_Ident.idRange FStar_Parser_AST.Type (Some (FStar_Parser_AST.Implicit)))))))
in (

let t = (match ((let _166_112 = (unparen t)
in _166_112.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Product (_67_352) -> begin
t
end
| _67_355 -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.App ((((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.effect_Tot_lid)) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)), (t), (FStar_Parser_AST.Nothing)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
end)
in (

let result = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (((binders), (t)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
in result)))
end))


let rec uncurry : FStar_Parser_AST.binder Prims.list  ->  FStar_Parser_AST.term  ->  (FStar_Parser_AST.binder Prims.list * FStar_Parser_AST.term) = (fun bs t -> (match (t.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Product (binders, t) -> begin
(uncurry (FStar_List.append bs binders) t)
end
| _67_365 -> begin
((bs), (t))
end))


let rec is_var_pattern : FStar_Parser_AST.pattern  ->  Prims.bool = (fun p -> (match (p.FStar_Parser_AST.pat) with
| (FStar_Parser_AST.PatWild) | (FStar_Parser_AST.PatTvar (_, _)) | (FStar_Parser_AST.PatVar (_, _)) -> begin
true
end
| FStar_Parser_AST.PatAscribed (p, _67_382) -> begin
(is_var_pattern p)
end
| _67_386 -> begin
false
end))


let rec is_app_pattern : FStar_Parser_AST.pattern  ->  Prims.bool = (fun p -> (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed (p, _67_390) -> begin
(is_app_pattern p)
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (_67_396); FStar_Parser_AST.prange = _67_394}, _67_400) -> begin
true
end
| _67_404 -> begin
false
end))


let replace_unit_pattern : FStar_Parser_AST.pattern  ->  FStar_Parser_AST.pattern = (fun p -> (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatConst (FStar_Const.Const_unit) -> begin
(FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatAscribed ((((FStar_Parser_AST.mk_pattern FStar_Parser_AST.PatWild p.FStar_Parser_AST.prange)), (unit_ty)))) p.FStar_Parser_AST.prange)
end
| _67_409 -> begin
p
end))


let rec destruct_app_pattern : FStar_Parser_Env.env  ->  Prims.bool  ->  FStar_Parser_AST.pattern  ->  ((FStar_Ident.ident, FStar_Ident.lident) FStar_Util.either * FStar_Parser_AST.pattern Prims.list * FStar_Parser_AST.term Prims.option) = (fun env is_top_level p -> (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed (p, t) -> begin
(

let _67_421 = (destruct_app_pattern env is_top_level p)
in (match (_67_421) with
| (name, args, _67_420) -> begin
((name), (args), (Some (t)))
end))
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id, _67_426); FStar_Parser_AST.prange = _67_423}, args) when is_top_level -> begin
(let _166_130 = (let _166_129 = (FStar_Parser_Env.qualify env id)
in FStar_Util.Inr (_166_129))
in ((_166_130), (args), (None)))
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id, _67_437); FStar_Parser_AST.prange = _67_434}, args) -> begin
((FStar_Util.Inl (id)), (args), (None))
end
| _67_445 -> begin
(failwith "Not an app pattern")
end))


type bnd =
| LocalBinder of (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual)
| LetBinder of (FStar_Ident.lident * FStar_Syntax_Syntax.term)


let is_LocalBinder = (fun _discr_ -> (match (_discr_) with
| LocalBinder (_) -> begin
true
end
| _ -> begin
false
end))


let is_LetBinder = (fun _discr_ -> (match (_discr_) with
| LetBinder (_) -> begin
true
end
| _ -> begin
false
end))


let ___LocalBinder____0 = (fun projectee -> (match (projectee) with
| LocalBinder (_67_448) -> begin
_67_448
end))


let ___LetBinder____0 = (fun projectee -> (match (projectee) with
| LetBinder (_67_451) -> begin
_67_451
end))


let binder_of_bnd : bnd  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual) = (fun _67_5 -> (match (_67_5) with
| LocalBinder (a, aq) -> begin
((a), (aq))
end
| _67_458 -> begin
(failwith "Impossible")
end))


let as_binder : FStar_Parser_Env.env  ->  FStar_Parser_AST.arg_qualifier Prims.option  ->  (FStar_Ident.ident Prims.option * FStar_Syntax_Syntax.term)  ->  (FStar_Syntax_Syntax.binder * FStar_Parser_Env.env) = (fun env imp _67_6 -> (match (_67_6) with
| (None, k) -> begin
(let _166_167 = (FStar_Syntax_Syntax.null_binder k)
in ((_166_167), (env)))
end
| (Some (a), k) -> begin
(

let _67_471 = (FStar_Parser_Env.push_bv env a)
in (match (_67_471) with
| (env, a) -> begin
(((((

let _67_472 = a
in {FStar_Syntax_Syntax.ppname = _67_472.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = _67_472.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = k})), ((trans_aqual imp)))), (env))
end))
end))


type env_t =
FStar_Parser_Env.env


type lenv_t =
FStar_Syntax_Syntax.bv Prims.list


let mk_lb : (FStar_Syntax_Syntax.lbname * FStar_Syntax_Syntax.typ * FStar_Syntax_Syntax.term)  ->  FStar_Syntax_Syntax.letbinding = (fun _67_477 -> (match (_67_477) with
| (n, t, e) -> begin
{FStar_Syntax_Syntax.lbname = n; FStar_Syntax_Syntax.lbunivs = []; FStar_Syntax_Syntax.lbtyp = t; FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_ALL_lid; FStar_Syntax_Syntax.lbdef = e}
end))


let no_annot_abs : (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list  ->  FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term = (fun bs t -> (FStar_Syntax_Util.abs bs t None))


let mk_ref_read = (fun tm -> (

let tm' = (let _166_180 = (let _166_179 = (let _166_175 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.sread_lid FStar_Syntax_Syntax.Delta_constant None)
in (FStar_Syntax_Syntax.fv_to_tm _166_175))
in (let _166_178 = (let _166_177 = (let _166_176 = (FStar_Syntax_Syntax.as_implicit false)
in ((tm), (_166_176)))
in (_166_177)::[])
in ((_166_179), (_166_178))))
in FStar_Syntax_Syntax.Tm_app (_166_180))
in (FStar_Syntax_Syntax.mk tm' None tm.FStar_Syntax_Syntax.pos)))


let mk_ref_alloc = (fun tm -> (

let tm' = (let _166_187 = (let _166_186 = (let _166_182 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.salloc_lid FStar_Syntax_Syntax.Delta_constant None)
in (FStar_Syntax_Syntax.fv_to_tm _166_182))
in (let _166_185 = (let _166_184 = (let _166_183 = (FStar_Syntax_Syntax.as_implicit false)
in ((tm), (_166_183)))
in (_166_184)::[])
in ((_166_186), (_166_185))))
in FStar_Syntax_Syntax.Tm_app (_166_187))
in (FStar_Syntax_Syntax.mk tm' None tm.FStar_Syntax_Syntax.pos)))


let mk_ref_assign = (fun t1 t2 pos -> (

let tm = (let _166_199 = (let _166_198 = (let _166_191 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.swrite_lid FStar_Syntax_Syntax.Delta_constant None)
in (FStar_Syntax_Syntax.fv_to_tm _166_191))
in (let _166_197 = (let _166_196 = (let _166_192 = (FStar_Syntax_Syntax.as_implicit false)
in ((t1), (_166_192)))
in (let _166_195 = (let _166_194 = (let _166_193 = (FStar_Syntax_Syntax.as_implicit false)
in ((t2), (_166_193)))
in (_166_194)::[])
in (_166_196)::_166_195))
in ((_166_198), (_166_197))))
in FStar_Syntax_Syntax.Tm_app (_166_199))
in (FStar_Syntax_Syntax.mk tm None pos)))


let is_special_effect_combinator : Prims.string  ->  Prims.bool = (fun _67_7 -> (match (_67_7) with
| ("repr") | ("post") | ("pre") | ("wp") -> begin
true
end
| _67_494 -> begin
false
end))


let rec sum_to_universe : FStar_Syntax_Syntax.universe  ->  Prims.int  ->  FStar_Syntax_Syntax.universe = (fun u n -> if (n = (Prims.parse_int "0")) then begin
u
end else begin
(let _166_206 = (sum_to_universe u (n - (Prims.parse_int "1")))
in FStar_Syntax_Syntax.U_succ (_166_206))
end)


let int_to_universe : Prims.int  ->  FStar_Syntax_Syntax.universe = (fun n -> (sum_to_universe FStar_Syntax_Syntax.U_zero n))


let rec desugar_maybe_non_constant_universe : FStar_Parser_AST.term  ->  (Prims.int, FStar_Syntax_Syntax.universe) FStar_Util.either = (fun t -> (match ((let _166_211 = (unparen t)
in _166_211.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Wild -> begin
(let _166_212 = (FStar_TypeChecker_Env.new_u_univ ())
in FStar_Util.Inr (_166_212))
end
| FStar_Parser_AST.Uvar (u) -> begin
FStar_Util.Inr (FStar_Syntax_Syntax.U_name (u))
end
| FStar_Parser_AST.Const (FStar_Const.Const_int (repr, _67_504)) -> begin
(

let n = (FStar_Util.int_of_string repr)
in (

let _67_509 = if (n < (Prims.parse_int "0")) then begin
(Prims.raise (FStar_Syntax_Syntax.Error ((((Prims.strcat "Negative universe constant  are not supported : " repr)), (t.FStar_Parser_AST.range)))))
end else begin
()
end
in FStar_Util.Inl (n)))
end
| FStar_Parser_AST.Op (op_plus, (t1)::(t2)::[]) -> begin
(

let _67_517 = ()
in (

let u1 = (desugar_maybe_non_constant_universe t1)
in (

let u2 = (desugar_maybe_non_constant_universe t2)
in (match (((u1), (u2))) with
| (FStar_Util.Inl (n1), FStar_Util.Inl (n2)) -> begin
FStar_Util.Inl ((n1 + n2))
end
| ((FStar_Util.Inl (n), FStar_Util.Inr (u))) | ((FStar_Util.Inr (u), FStar_Util.Inl (n))) -> begin
(let _166_213 = (sum_to_universe u n)
in FStar_Util.Inr (_166_213))
end
| (FStar_Util.Inr (u1), FStar_Util.Inr (u2)) -> begin
(let _166_217 = (let _166_216 = (let _166_215 = (let _166_214 = (FStar_Parser_AST.term_to_string t)
in (Prims.strcat "This universe might contain a sum of two universe variables " _166_214))
in ((_166_215), (t.FStar_Parser_AST.range)))
in FStar_Syntax_Syntax.Error (_166_216))
in (Prims.raise _166_217))
end))))
end
| FStar_Parser_AST.App (_67_540) -> begin
(

let rec aux = (fun t univargs -> (match ((let _166_222 = (unparen t)
in _166_222.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.App (t, targ, _67_548) -> begin
(

let uarg = (desugar_maybe_non_constant_universe targ)
in (aux t ((uarg)::univargs)))
end
| FStar_Parser_AST.Var (max_lid) -> begin
(

let _67_554 = ()
in if (FStar_List.existsb (fun _67_8 -> (match (_67_8) with
| FStar_Util.Inr (_67_558) -> begin
true
end
| _67_561 -> begin
false
end)) univargs) then begin
(let _166_226 = (let _166_225 = (FStar_List.map (fun _67_9 -> (match (_67_9) with
| FStar_Util.Inl (n) -> begin
(int_to_universe n)
end
| FStar_Util.Inr (u) -> begin
u
end)) univargs)
in FStar_Syntax_Syntax.U_max (_166_225))
in FStar_Util.Inr (_166_226))
end else begin
(

let nargs = (FStar_List.map (fun _67_10 -> (match (_67_10) with
| FStar_Util.Inl (n) -> begin
n
end
| FStar_Util.Inr (_67_571) -> begin
(failwith "impossible")
end)) univargs)
in (let _166_230 = (FStar_List.fold_left (fun m n -> if (m > n) then begin
m
end else begin
n
end) (Prims.parse_int "0") nargs)
in FStar_Util.Inl (_166_230)))
end)
end
| _67_577 -> begin
(let _166_235 = (let _166_234 = (let _166_233 = (let _166_232 = (let _166_231 = (FStar_Parser_AST.term_to_string t)
in (Prims.strcat _166_231 " in universe context"))
in (Prims.strcat "Unexpected term " _166_232))
in ((_166_233), (t.FStar_Parser_AST.range)))
in FStar_Syntax_Syntax.Error (_166_234))
in (Prims.raise _166_235))
end))
in (aux t []))
end
| _67_579 -> begin
(let _166_240 = (let _166_239 = (let _166_238 = (let _166_237 = (let _166_236 = (FStar_Parser_AST.term_to_string t)
in (Prims.strcat _166_236 " in universe context"))
in (Prims.strcat "Unexpected term " _166_237))
in ((_166_238), (t.FStar_Parser_AST.range)))
in FStar_Syntax_Syntax.Error (_166_239))
in (Prims.raise _166_240))
end))


let rec desugar_universe : FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.universe = (fun t -> (

let u = (desugar_maybe_non_constant_universe t)
in (match (u) with
| FStar_Util.Inl (n) -> begin
(int_to_universe n)
end
| FStar_Util.Inr (u) -> begin
u
end)))


let check_fields = (fun env fields rg -> (

let _67_592 = (FStar_List.hd fields)
in (match (_67_592) with
| (f, _67_591) -> begin
(

let record = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_record_by_field_name env) f)
in (

let check_field = (fun _67_598 -> (match (_67_598) with
| (f', _67_597) -> begin
if (FStar_Parser_Env.belongs_to_record env f' record) then begin
()
end else begin
(

let msg = (FStar_Util.format3 "Field %s belongs to record type %s, whereas field %s does not" f.FStar_Ident.str record.FStar_Parser_Env.typename.FStar_Ident.str f'.FStar_Ident.str)
in (Prims.raise (FStar_Syntax_Syntax.Error (((msg), (rg))))))
end
end))
in (

let _67_600 = (let _166_248 = (FStar_List.tl fields)
in (FStar_List.iter check_field _166_248))
in (match (()) with
| () -> begin
record
end))))
end)))


let rec desugar_data_pat : FStar_Parser_Env.env  ->  FStar_Parser_AST.pattern  ->  Prims.bool  ->  (env_t * bnd * FStar_Syntax_Syntax.pat) = (fun env p is_mut -> (

let check_linear_pattern_variables = (fun p -> (

let rec pat_vars = (fun p -> (match (p.FStar_Syntax_Syntax.v) with
| (FStar_Syntax_Syntax.Pat_dot_term (_)) | (FStar_Syntax_Syntax.Pat_wild (_)) | (FStar_Syntax_Syntax.Pat_constant (_)) -> begin
FStar_Syntax_Syntax.no_names
end
| FStar_Syntax_Syntax.Pat_var (x) -> begin
(FStar_Util.set_add x FStar_Syntax_Syntax.no_names)
end
| FStar_Syntax_Syntax.Pat_cons (_67_620, pats) -> begin
(FStar_All.pipe_right pats (FStar_List.fold_left (fun out _67_628 -> (match (_67_628) with
| (p, _67_627) -> begin
(let _166_305 = (pat_vars p)
in (FStar_Util.set_union out _166_305))
end)) FStar_Syntax_Syntax.no_names))
end
| FStar_Syntax_Syntax.Pat_disj ([]) -> begin
(failwith "Impossible")
end
| FStar_Syntax_Syntax.Pat_disj ((hd)::tl) -> begin
(

let xs = (pat_vars hd)
in if (not ((FStar_Util.for_all (fun p -> (

let ys = (pat_vars p)
in ((FStar_Util.set_is_subset_of xs ys) && (FStar_Util.set_is_subset_of ys xs)))) tl))) then begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Disjunctive pattern binds different variables in each case"), (p.FStar_Syntax_Syntax.p)))))
end else begin
xs
end)
end))
in (pat_vars p)))
in (

let _67_651 = (match (((is_mut), (p.FStar_Parser_AST.pat))) with
| ((false, _)) | ((true, FStar_Parser_AST.PatVar (_))) -> begin
()
end
| (true, _67_649) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("let-mutable is for variables only"), (p.FStar_Parser_AST.prange)))))
end)
in (

let push_bv_maybe_mut = if is_mut then begin
FStar_Parser_Env.push_bv_mutable
end else begin
FStar_Parser_Env.push_bv
end
in (

let resolvex = (fun l e x -> (match ((FStar_All.pipe_right l (FStar_Util.find_opt (fun y -> (y.FStar_Syntax_Syntax.ppname.FStar_Ident.idText = x.FStar_Ident.idText))))) with
| Some (y) -> begin
((l), (e), (y))
end
| _67_662 -> begin
(

let _67_665 = (push_bv_maybe_mut e x)
in (match (_67_665) with
| (e, x) -> begin
(((x)::l), (e), (x))
end))
end))
in (

let rec aux = (fun loc env p -> (

let pos = (fun q -> (FStar_Syntax_Syntax.withinfo q FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n p.FStar_Parser_AST.prange))
in (

let pos_r = (fun r q -> (FStar_Syntax_Syntax.withinfo q FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n r))
in (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatOp (op) -> begin
(let _166_334 = (let _166_333 = (let _166_332 = (let _166_331 = (let _166_330 = (FStar_Parser_AST.compile_op (Prims.parse_int "0") op)
in (FStar_Ident.id_of_text _166_330))
in ((_166_331), (None)))
in FStar_Parser_AST.PatVar (_166_332))
in {FStar_Parser_AST.pat = _166_333; FStar_Parser_AST.prange = p.FStar_Parser_AST.prange})
in (aux loc env _166_334))
end
| FStar_Parser_AST.PatOr ([]) -> begin
(failwith "impossible")
end
| FStar_Parser_AST.PatOr ((p)::ps) -> begin
(

let _67_689 = (aux loc env p)
in (match (_67_689) with
| (loc, env, var, p, _67_688) -> begin
(

let _67_706 = (FStar_List.fold_left (fun _67_693 p -> (match (_67_693) with
| (loc, env, ps) -> begin
(

let _67_702 = (aux loc env p)
in (match (_67_702) with
| (loc, env, _67_698, p, _67_701) -> begin
((loc), (env), ((p)::ps))
end))
end)) ((loc), (env), ([])) ps)
in (match (_67_706) with
| (loc, env, ps) -> begin
(

let pat = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_disj ((p)::(FStar_List.rev ps))))
in ((loc), (env), (var), (pat), (false)))
end))
end))
end
| FStar_Parser_AST.PatAscribed (p, t) -> begin
(

let _67_717 = (aux loc env p)
in (match (_67_717) with
| (loc, env', binder, p, imp) -> begin
(

let binder = (match (binder) with
| LetBinder (_67_719) -> begin
(failwith "impossible")
end
| LocalBinder (x, aq) -> begin
(

let t = (let _166_337 = (close_fun env t)
in (desugar_term env _166_337))
in LocalBinder ((((

let _67_726 = x
in {FStar_Syntax_Syntax.ppname = _67_726.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = _67_726.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = t})), (aq))))
end)
in ((loc), (env'), (binder), (p), (imp)))
end))
end
| FStar_Parser_AST.PatWild -> begin
(

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _166_338 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_wild (x)))
in ((loc), (env), (LocalBinder (((x), (None)))), (_166_338), (false))))
end
| FStar_Parser_AST.PatConst (c) -> begin
(

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _166_339 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_constant (c)))
in ((loc), (env), (LocalBinder (((x), (None)))), (_166_339), (false))))
end
| (FStar_Parser_AST.PatTvar (x, aq)) | (FStar_Parser_AST.PatVar (x, aq)) -> begin
(

let imp = (aq = Some (FStar_Parser_AST.Implicit))
in (

let aq = (trans_aqual aq)
in (

let _67_745 = (resolvex loc env x)
in (match (_67_745) with
| (loc, env, xbv) -> begin
(let _166_340 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_var (xbv)))
in ((loc), (env), (LocalBinder (((xbv), (aq)))), (_166_340), (imp)))
end))))
end
| FStar_Parser_AST.PatName (l) -> begin
(

let l = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_datacon env) l)
in (

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _166_341 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_cons (((l), ([])))))
in ((loc), (env), (LocalBinder (((x), (None)))), (_166_341), (false)))))
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatName (l); FStar_Parser_AST.prange = _67_751}, args) -> begin
(

let _67_773 = (FStar_List.fold_right (fun arg _67_762 -> (match (_67_762) with
| (loc, env, args) -> begin
(

let _67_769 = (aux loc env arg)
in (match (_67_769) with
| (loc, env, _67_766, arg, imp) -> begin
((loc), (env), ((((arg), (imp)))::args))
end))
end)) args ((loc), (env), ([])))
in (match (_67_773) with
| (loc, env, args) -> begin
(

let l = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_datacon env) l)
in (

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _166_344 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_cons (((l), (args)))))
in ((loc), (env), (LocalBinder (((x), (None)))), (_166_344), (false)))))
end))
end
| FStar_Parser_AST.PatApp (_67_777) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Unexpected pattern"), (p.FStar_Parser_AST.prange)))))
end
| FStar_Parser_AST.PatList (pats) -> begin
(

let _67_797 = (FStar_List.fold_right (fun pat _67_785 -> (match (_67_785) with
| (loc, env, pats) -> begin
(

let _67_793 = (aux loc env pat)
in (match (_67_793) with
| (loc, env, _67_789, pat, _67_792) -> begin
((loc), (env), ((pat)::pats))
end))
end)) pats ((loc), (env), ([])))
in (match (_67_797) with
| (loc, env, pats) -> begin
(

let pat = (let _166_357 = (let _166_356 = (let _166_352 = (FStar_Range.end_range p.FStar_Parser_AST.prange)
in (pos_r _166_352))
in (let _166_355 = (let _166_354 = (let _166_353 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.nil_lid FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor)))
in ((_166_353), ([])))
in FStar_Syntax_Syntax.Pat_cons (_166_354))
in (FStar_All.pipe_left _166_356 _166_355)))
in (FStar_List.fold_right (fun hd tl -> (

let r = (FStar_Range.union_ranges hd.FStar_Syntax_Syntax.p tl.FStar_Syntax_Syntax.p)
in (let _166_351 = (let _166_350 = (let _166_349 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.cons_lid FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor)))
in ((_166_349), ((((hd), (false)))::(((tl), (false)))::[])))
in FStar_Syntax_Syntax.Pat_cons (_166_350))
in (FStar_All.pipe_left (pos_r r) _166_351)))) pats _166_357))
in (

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in ((loc), (env), (LocalBinder (((x), (None)))), (pat), (false))))
end))
end
| FStar_Parser_AST.PatTuple (args, dep) -> begin
(

let _67_823 = (FStar_List.fold_left (fun _67_810 p -> (match (_67_810) with
| (loc, env, pats) -> begin
(

let _67_819 = (aux loc env p)
in (match (_67_819) with
| (loc, env, _67_815, pat, _67_818) -> begin
((loc), (env), ((((pat), (false)))::pats))
end))
end)) ((loc), (env), ([])) args)
in (match (_67_823) with
| (loc, env, args) -> begin
(

let args = (FStar_List.rev args)
in (

let l = if dep then begin
(FStar_Syntax_Util.mk_dtuple_data_lid (FStar_List.length args) p.FStar_Parser_AST.prange)
end else begin
(FStar_Syntax_Util.mk_tuple_data_lid (FStar_List.length args) p.FStar_Parser_AST.prange)
end
in (

let _67_829 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_lid env) l)
in (match (_67_829) with
| (constr, _67_828) -> begin
(

let l = (match (constr.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
fv
end
| _67_833 -> begin
(failwith "impossible")
end)
in (

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _166_360 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_cons (((l), (args)))))
in ((loc), (env), (LocalBinder (((x), (None)))), (_166_360), (false)))))
end))))
end))
end
| FStar_Parser_AST.PatRecord ([]) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Unexpected pattern"), (p.FStar_Parser_AST.prange)))))
end
| FStar_Parser_AST.PatRecord (fields) -> begin
(

let record = (check_fields env fields p.FStar_Parser_AST.prange)
in (

let fields = (FStar_All.pipe_right fields (FStar_List.map (fun _67_843 -> (match (_67_843) with
| (f, p) -> begin
((f.FStar_Ident.ident), (p))
end))))
in (

let args = (FStar_All.pipe_right record.FStar_Parser_Env.fields (FStar_List.map (fun _67_848 -> (match (_67_848) with
| (f, _67_847) -> begin
(match ((FStar_All.pipe_right fields (FStar_List.tryFind (fun _67_852 -> (match (_67_852) with
| (g, _67_851) -> begin
(f.FStar_Ident.idText = g.FStar_Ident.idText)
end))))) with
| None -> begin
(FStar_Parser_AST.mk_pattern FStar_Parser_AST.PatWild p.FStar_Parser_AST.prange)
end
| Some (_67_855, p) -> begin
p
end)
end))))
in (

let app = (let _166_368 = (let _166_367 = (let _166_366 = (let _166_365 = (let _166_364 = (FStar_Ident.lid_of_ids (FStar_List.append record.FStar_Parser_Env.typename.FStar_Ident.ns ((record.FStar_Parser_Env.constrname)::[])))
in FStar_Parser_AST.PatName (_166_364))
in (FStar_Parser_AST.mk_pattern _166_365 p.FStar_Parser_AST.prange))
in ((_166_366), (args)))
in FStar_Parser_AST.PatApp (_166_367))
in (FStar_Parser_AST.mk_pattern _166_368 p.FStar_Parser_AST.prange))
in (

let _67_867 = (aux loc env app)
in (match (_67_867) with
| (env, e, b, p, _67_866) -> begin
(

let p = (match (p.FStar_Syntax_Syntax.v) with
| FStar_Syntax_Syntax.Pat_cons (fv, args) -> begin
(let _166_375 = (let _166_374 = (let _166_373 = (

let _67_872 = fv
in (let _166_372 = (let _166_371 = (let _166_370 = (let _166_369 = (FStar_All.pipe_right record.FStar_Parser_Env.fields (FStar_List.map Prims.fst))
in ((record.FStar_Parser_Env.typename), (_166_369)))
in FStar_Syntax_Syntax.Record_ctor (_166_370))
in Some (_166_371))
in {FStar_Syntax_Syntax.fv_name = _67_872.FStar_Syntax_Syntax.fv_name; FStar_Syntax_Syntax.fv_delta = _67_872.FStar_Syntax_Syntax.fv_delta; FStar_Syntax_Syntax.fv_qual = _166_372}))
in ((_166_373), (args)))
in FStar_Syntax_Syntax.Pat_cons (_166_374))
in (FStar_All.pipe_left pos _166_375))
end
| _67_875 -> begin
p
end)
in ((env), (e), (b), (p), (false)))
end))))))
end))))
in (

let _67_884 = (aux [] env p)
in (match (_67_884) with
| (_67_878, env, b, p, _67_883) -> begin
(

let _67_885 = (let _166_376 = (check_linear_pattern_variables p)
in (FStar_All.pipe_left Prims.ignore _166_376))
in ((env), (b), (p)))
end))))))))
and desugar_binding_pat_maybe_top : Prims.bool  ->  FStar_Parser_Env.env  ->  FStar_Parser_AST.pattern  ->  Prims.bool  ->  (env_t * bnd * FStar_Syntax_Syntax.pat Prims.option) = (fun top env p is_mut -> (

let mklet = (fun x -> (let _166_385 = (let _166_384 = (let _166_383 = (FStar_Parser_Env.qualify env x)
in ((_166_383), (FStar_Syntax_Syntax.tun)))
in LetBinder (_166_384))
in ((env), (_166_385), (None))))
in if top then begin
(match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatOp (x) -> begin
(let _166_387 = (let _166_386 = (FStar_Parser_AST.compile_op (Prims.parse_int "0") x)
in (FStar_Ident.id_of_text _166_386))
in (mklet _166_387))
end
| FStar_Parser_AST.PatVar (x, _67_897) -> begin
(mklet x)
end
| FStar_Parser_AST.PatAscribed ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (x, _67_904); FStar_Parser_AST.prange = _67_901}, t) -> begin
(let _166_391 = (let _166_390 = (let _166_389 = (FStar_Parser_Env.qualify env x)
in (let _166_388 = (desugar_term env t)
in ((_166_389), (_166_388))))
in LetBinder (_166_390))
in ((env), (_166_391), (None)))
end
| _67_912 -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Unexpected pattern at the top-level"), (p.FStar_Parser_AST.prange)))))
end)
end else begin
(

let _67_916 = (desugar_data_pat env p is_mut)
in (match (_67_916) with
| (env, binder, p) -> begin
(

let p = (match (p.FStar_Syntax_Syntax.v) with
| (FStar_Syntax_Syntax.Pat_var (_)) | (FStar_Syntax_Syntax.Pat_wild (_)) -> begin
None
end
| _67_924 -> begin
Some (p)
end)
in ((env), (binder), (p)))
end))
end))
and desugar_binding_pat : FStar_Parser_Env.env  ->  FStar_Parser_AST.pattern  ->  (env_t * bnd * FStar_Syntax_Syntax.pat Prims.option) = (fun env p -> (desugar_binding_pat_maybe_top false env p false))
and desugar_match_pat_maybe_top : Prims.bool  ->  FStar_Parser_Env.env  ->  FStar_Parser_AST.pattern  ->  (env_t * FStar_Syntax_Syntax.pat) = (fun _67_928 env pat -> (

let _67_936 = (desugar_data_pat env pat false)
in (match (_67_936) with
| (env, _67_934, pat) -> begin
((env), (pat))
end)))
and desugar_match_pat : FStar_Parser_Env.env  ->  FStar_Parser_AST.pattern  ->  (env_t * FStar_Syntax_Syntax.pat) = (fun env p -> (desugar_match_pat_maybe_top false env p))
and desugar_term : FStar_Parser_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.term = (fun env e -> (

let env = (

let _67_941 = env
in {FStar_Parser_Env.curmodule = _67_941.FStar_Parser_Env.curmodule; FStar_Parser_Env.curmonad = _67_941.FStar_Parser_Env.curmonad; FStar_Parser_Env.modules = _67_941.FStar_Parser_Env.modules; FStar_Parser_Env.scope_mods = _67_941.FStar_Parser_Env.scope_mods; FStar_Parser_Env.exported_ids = _67_941.FStar_Parser_Env.exported_ids; FStar_Parser_Env.trans_exported_ids = _67_941.FStar_Parser_Env.trans_exported_ids; FStar_Parser_Env.includes = _67_941.FStar_Parser_Env.includes; FStar_Parser_Env.sigaccum = _67_941.FStar_Parser_Env.sigaccum; FStar_Parser_Env.sigmap = _67_941.FStar_Parser_Env.sigmap; FStar_Parser_Env.default_result_effect = _67_941.FStar_Parser_Env.default_result_effect; FStar_Parser_Env.iface = _67_941.FStar_Parser_Env.iface; FStar_Parser_Env.admitted_iface = _67_941.FStar_Parser_Env.admitted_iface; FStar_Parser_Env.expect_typ = false})
in (desugar_term_maybe_top false env e)))
and desugar_typ : FStar_Parser_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.term = (fun env e -> (

let env = (

let _67_946 = env
in {FStar_Parser_Env.curmodule = _67_946.FStar_Parser_Env.curmodule; FStar_Parser_Env.curmonad = _67_946.FStar_Parser_Env.curmonad; FStar_Parser_Env.modules = _67_946.FStar_Parser_Env.modules; FStar_Parser_Env.scope_mods = _67_946.FStar_Parser_Env.scope_mods; FStar_Parser_Env.exported_ids = _67_946.FStar_Parser_Env.exported_ids; FStar_Parser_Env.trans_exported_ids = _67_946.FStar_Parser_Env.trans_exported_ids; FStar_Parser_Env.includes = _67_946.FStar_Parser_Env.includes; FStar_Parser_Env.sigaccum = _67_946.FStar_Parser_Env.sigaccum; FStar_Parser_Env.sigmap = _67_946.FStar_Parser_Env.sigmap; FStar_Parser_Env.default_result_effect = _67_946.FStar_Parser_Env.default_result_effect; FStar_Parser_Env.iface = _67_946.FStar_Parser_Env.iface; FStar_Parser_Env.admitted_iface = _67_946.FStar_Parser_Env.admitted_iface; FStar_Parser_Env.expect_typ = true})
in (desugar_term_maybe_top false env e)))
and desugar_machine_integer : FStar_Parser_Env.env  ->  Prims.string  ->  (FStar_Const.signedness * FStar_Const.width)  ->  FStar_Range.range  ->  (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax = (fun env repr _67_953 range -> (match (_67_953) with
| (signedness, width) -> begin
(

let lid = (Prims.strcat "FStar." (Prims.strcat (match (signedness) with
| FStar_Const.Unsigned -> begin
"U"
end
| FStar_Const.Signed -> begin
""
end) (Prims.strcat "Int" (Prims.strcat (match (width) with
| FStar_Const.Int8 -> begin
"8"
end
| FStar_Const.Int16 -> begin
"16"
end
| FStar_Const.Int32 -> begin
"32"
end
| FStar_Const.Int64 -> begin
"64"
end) (Prims.strcat "." (Prims.strcat (match (signedness) with
| FStar_Const.Unsigned -> begin
"u"
end
| FStar_Const.Signed -> begin
""
end) "int_to_t"))))))
in (

let lid = (FStar_Ident.lid_of_path (FStar_Ident.path_of_text lid) range)
in (

let lid = (match ((FStar_Parser_Env.try_lookup_lid env lid)) with
| Some (lid) -> begin
(Prims.fst lid)
end
| None -> begin
(let _166_407 = (FStar_Util.format1 "%s not in scope\n" (FStar_Ident.text_of_lid lid))
in (failwith _166_407))
end)
in (

let repr = (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_int (((repr), (None))))) None range)
in (let _166_412 = (let _166_411 = (let _166_410 = (let _166_409 = (let _166_408 = (FStar_Syntax_Syntax.as_implicit false)
in ((repr), (_166_408)))
in (_166_409)::[])
in ((lid), (_166_410)))
in FStar_Syntax_Syntax.Tm_app (_166_411))
in (FStar_Syntax_Syntax.mk _166_412 None range))))))
end))
and desugar_name : (FStar_Syntax_Syntax.term'  ->  FStar_Syntax_Syntax.term)  ->  (FStar_Syntax_Syntax.term  ->  (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax)  ->  env_t  ->  FStar_Ident.lid  ->  FStar_Syntax_Syntax.term = (fun mk setpos env l -> (

let _67_976 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_lid env) l)
in (match (_67_976) with
| (tm, mut) -> begin
(

let tm = (setpos tm)
in if mut then begin
(let _166_425 = (let _166_424 = (let _166_423 = (mk_ref_read tm)
in ((_166_423), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Mutable_rval))))
in FStar_Syntax_Syntax.Tm_meta (_166_424))
in (FStar_All.pipe_left mk _166_425))
end else begin
tm
end)
end)))
and desugar_attributes : FStar_Parser_Env.env  ->  FStar_Parser_AST.term Prims.list  ->  FStar_Syntax_Syntax.cflags Prims.list = (fun env cattributes -> (

let desugar_attribute = (fun t -> (match ((let _166_430 = (unparen t)
in _166_430.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Var ({FStar_Ident.ns = _67_988; FStar_Ident.ident = _67_986; FStar_Ident.nsstr = _67_984; FStar_Ident.str = "cps"}) -> begin
FStar_Syntax_Syntax.CPS
end
| _67_992 -> begin
(let _166_434 = (let _166_433 = (let _166_432 = (let _166_431 = (FStar_Parser_AST.term_to_string t)
in (Prims.strcat "Unknown attribute " _166_431))
in ((_166_432), (t.FStar_Parser_AST.range)))
in FStar_Syntax_Syntax.Error (_166_433))
in (Prims.raise _166_434))
end))
in (FStar_List.map desugar_attribute cattributes)))
and desugar_term_maybe_top : Prims.bool  ->  env_t  ->  FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.term = (fun top_level env top -> (

let mk = (fun e -> (FStar_Syntax_Syntax.mk e None top.FStar_Parser_AST.range))
in (

let setpos = (fun e -> (

let _67_1000 = e
in {FStar_Syntax_Syntax.n = _67_1000.FStar_Syntax_Syntax.n; FStar_Syntax_Syntax.tk = _67_1000.FStar_Syntax_Syntax.tk; FStar_Syntax_Syntax.pos = top.FStar_Parser_AST.range; FStar_Syntax_Syntax.vars = _67_1000.FStar_Syntax_Syntax.vars}))
in (match ((let _166_442 = (unparen top)
in _166_442.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Wild -> begin
(setpos FStar_Syntax_Syntax.tun)
end
| FStar_Parser_AST.Labeled (_67_1004) -> begin
(desugar_formula env top)
end
| FStar_Parser_AST.Requires (t, lopt) -> begin
(desugar_formula env t)
end
| FStar_Parser_AST.Ensures (t, lopt) -> begin
(desugar_formula env t)
end
| FStar_Parser_AST.Attributes (ts) -> begin
(failwith "Attributes should not be desugared by desugar_term_maybe_top")
end
| FStar_Parser_AST.Const (FStar_Const.Const_int (i, Some (size))) -> begin
(desugar_machine_integer env i size top.FStar_Parser_AST.range)
end
| FStar_Parser_AST.Const (c) -> begin
(mk (FStar_Syntax_Syntax.Tm_constant (c)))
end
| FStar_Parser_AST.Op ("=!=", args) -> begin
(desugar_term env (FStar_Parser_AST.mk_term (FStar_Parser_AST.Op ((("~"), (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Op ((("=="), (args)))) top.FStar_Parser_AST.range top.FStar_Parser_AST.level))::[])))) top.FStar_Parser_AST.range top.FStar_Parser_AST.level))
end
| FStar_Parser_AST.Op ("*", (_67_1032)::(_67_1030)::[]) when (let _166_443 = (op_as_term env (Prims.parse_int "2") top.FStar_Parser_AST.range "*")
in (FStar_All.pipe_right _166_443 FStar_Option.isNone)) -> begin
(

let rec flatten = (fun t -> (match (t.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Op ("*", (t1)::(t2)::[]) -> begin
(let _166_446 = (flatten t1)
in (FStar_List.append _166_446 ((t2)::[])))
end
| _67_1045 -> begin
(t)::[]
end))
in (

let targs = (let _166_450 = (let _166_447 = (unparen top)
in (flatten _166_447))
in (FStar_All.pipe_right _166_450 (FStar_List.map (fun t -> (let _166_449 = (desugar_typ env t)
in (FStar_Syntax_Syntax.as_arg _166_449))))))
in (

let _67_1051 = (let _166_451 = (FStar_Syntax_Util.mk_tuple_lid (FStar_List.length targs) top.FStar_Parser_AST.range)
in (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_lid env) _166_451))
in (match (_67_1051) with
| (tup, _67_1050) -> begin
(mk (FStar_Syntax_Syntax.Tm_app (((tup), (targs)))))
end))))
end
| FStar_Parser_AST.Tvar (a) -> begin
(let _166_453 = (let _166_452 = (FStar_Parser_Env.fail_or2 (FStar_Parser_Env.try_lookup_id env) a)
in (Prims.fst _166_452))
in (FStar_All.pipe_left setpos _166_453))
end
| FStar_Parser_AST.Uvar (u) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((((Prims.strcat "Unexpected universe variable " (Prims.strcat (FStar_Ident.text_of_id u) " in non-universe context"))), (top.FStar_Parser_AST.range)))))
end
| FStar_Parser_AST.Op (s, args) -> begin
(match ((op_as_term env (FStar_List.length args) top.FStar_Parser_AST.range s)) with
| None -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((((Prims.strcat "Unexpected or unbound operator: " s)), (top.FStar_Parser_AST.range)))))
end
| Some (op) -> begin
if ((FStar_List.length args) > (Prims.parse_int "0")) then begin
(

let args = (FStar_All.pipe_right args (FStar_List.map (fun t -> (let _166_455 = (desugar_term env t)
in ((_166_455), (None))))))
in (mk (FStar_Syntax_Syntax.Tm_app (((op), (args))))))
end else begin
op
end
end)
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = _67_1071; FStar_Ident.ident = _67_1069; FStar_Ident.nsstr = _67_1067; FStar_Ident.str = "Type0"}) -> begin
(mk (FStar_Syntax_Syntax.Tm_type (FStar_Syntax_Syntax.U_zero)))
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = _67_1080; FStar_Ident.ident = _67_1078; FStar_Ident.nsstr = _67_1076; FStar_Ident.str = "Type"}) -> begin
(mk (FStar_Syntax_Syntax.Tm_type (FStar_Syntax_Syntax.U_unknown)))
end
| FStar_Parser_AST.Construct ({FStar_Ident.ns = _67_1089; FStar_Ident.ident = _67_1087; FStar_Ident.nsstr = _67_1085; FStar_Ident.str = "Type"}, ((t, FStar_Parser_AST.UnivApp))::[]) -> begin
(let _166_457 = (let _166_456 = (desugar_universe t)
in FStar_Syntax_Syntax.Tm_type (_166_456))
in (mk _166_457))
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = _67_1103; FStar_Ident.ident = _67_1101; FStar_Ident.nsstr = _67_1099; FStar_Ident.str = "Effect"}) -> begin
(mk (FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_effect)))
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = _67_1112; FStar_Ident.ident = _67_1110; FStar_Ident.nsstr = _67_1108; FStar_Ident.str = "True"}) -> begin
(FStar_Syntax_Syntax.fvar (FStar_Ident.set_lid_range FStar_Syntax_Const.true_lid top.FStar_Parser_AST.range) FStar_Syntax_Syntax.Delta_constant None)
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = _67_1121; FStar_Ident.ident = _67_1119; FStar_Ident.nsstr = _67_1117; FStar_Ident.str = "False"}) -> begin
(FStar_Syntax_Syntax.fvar (FStar_Ident.set_lid_range FStar_Syntax_Const.false_lid top.FStar_Parser_AST.range) FStar_Syntax_Syntax.Delta_constant None)
end
| FStar_Parser_AST.Projector (eff_name, {FStar_Ident.idText = txt; FStar_Ident.idRange = _67_1126}) when ((is_special_effect_combinator txt) && (FStar_Parser_Env.is_effect_name env eff_name)) -> begin
(match ((FStar_Parser_Env.try_lookup_effect_defn env eff_name)) with
| Some (ed) -> begin
(let _166_458 = (FStar_Ident.lid_of_path (FStar_Ident.path_of_text (Prims.strcat (FStar_Ident.text_of_lid ed.FStar_Syntax_Syntax.mname) (Prims.strcat "_" txt))) FStar_Range.dummyRange)
in (FStar_Syntax_Syntax.fvar _166_458 (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "1"))) None))
end
| None -> begin
(failwith "immpossible special_effect_combinator")
end)
end
| FStar_Parser_AST.Assign (ident, t2) -> begin
(

let t2 = (desugar_term env t2)
in (

let _67_1141 = (FStar_Parser_Env.fail_or2 (FStar_Parser_Env.try_lookup_id env) ident)
in (match (_67_1141) with
| (t1, mut) -> begin
(

let _67_1142 = if (not (mut)) then begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Can only assign to mutable values"), (top.FStar_Parser_AST.range)))))
end else begin
()
end
in (mk_ref_assign t1 t2 top.FStar_Parser_AST.range))
end)))
end
| (FStar_Parser_AST.Var (l)) | (FStar_Parser_AST.Name (l)) -> begin
(desugar_name mk setpos env l)
end
| FStar_Parser_AST.Projector (l, i) -> begin
(

let found = ((let _166_459 = (FStar_Parser_Env.try_lookup_datacon env l)
in (FStar_Option.isSome _166_459)) || (let _166_460 = (FStar_Parser_Env.try_lookup_effect_defn env l)
in (FStar_Option.isSome _166_460)))
in if found then begin
(let _166_461 = (FStar_Syntax_Util.mk_field_projector_name_from_ident l i)
in (desugar_name mk setpos env _166_461))
end else begin
(let _166_464 = (let _166_463 = (let _166_462 = (FStar_Util.format1 "Data constructor or effect %s not found" l.FStar_Ident.str)
in ((_166_462), (top.FStar_Parser_AST.range)))
in FStar_Syntax_Syntax.Error (_166_463))
in (Prims.raise _166_464))
end)
end
| FStar_Parser_AST.Discrim (lid) -> begin
(match ((FStar_Parser_Env.try_lookup_datacon env lid)) with
| None -> begin
(let _166_467 = (let _166_466 = (let _166_465 = (FStar_Util.format1 "Data constructor %s not found" lid.FStar_Ident.str)
in ((_166_465), (top.FStar_Parser_AST.range)))
in FStar_Syntax_Syntax.Error (_166_466))
in (Prims.raise _166_467))
end
| _67_1156 -> begin
(

let lid' = (FStar_Syntax_Util.mk_discriminator lid)
in (desugar_name mk setpos env lid'))
end)
end
| FStar_Parser_AST.Construct (l, args) -> begin
(match ((FStar_Parser_Env.try_lookup_datacon env l)) with
| Some (head) -> begin
(

let _67_1166 = (let _166_468 = (mk (FStar_Syntax_Syntax.Tm_fvar (head)))
in ((_166_468), (true)))
in (match (_67_1166) with
| (head, is_data) -> begin
(match (args) with
| [] -> begin
head
end
| _67_1169 -> begin
(

let _67_1176 = (FStar_Util.take (fun _67_1173 -> (match (_67_1173) with
| (_67_1171, imp) -> begin
(imp = FStar_Parser_AST.UnivApp)
end)) args)
in (match (_67_1176) with
| (universes, args) -> begin
(

let universes = (FStar_List.map (fun x -> (desugar_universe (Prims.fst x))) universes)
in (

let args = (FStar_List.map (fun _67_1181 -> (match (_67_1181) with
| (t, imp) -> begin
(

let te = (desugar_term env t)
in (arg_withimp_e imp te))
end)) args)
in (

let app = (let _166_474 = (let _166_473 = (let _166_472 = (mk (FStar_Syntax_Syntax.Tm_uinst (((head), (universes)))))
in ((_166_472), (args)))
in FStar_Syntax_Syntax.Tm_app (_166_473))
in (mk _166_474))
in if is_data then begin
(mk (FStar_Syntax_Syntax.Tm_meta (((app), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Data_app))))))
end else begin
app
end)))
end))
end)
end))
end
| None -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((((Prims.strcat "Constructor " (Prims.strcat l.FStar_Ident.str " not found"))), (top.FStar_Parser_AST.range)))))
end)
end
| FStar_Parser_AST.Sum (binders, t) -> begin
(

let _67_1210 = (FStar_List.fold_left (fun _67_1193 b -> (match (_67_1193) with
| (env, tparams, typs) -> begin
(

let _67_1197 = (desugar_binder env b)
in (match (_67_1197) with
| (xopt, t) -> begin
(

let _67_1203 = (match (xopt) with
| None -> begin
(let _166_477 = (FStar_Syntax_Syntax.new_bv (Some (top.FStar_Parser_AST.range)) FStar_Syntax_Syntax.tun)
in ((env), (_166_477)))
end
| Some (x) -> begin
(FStar_Parser_Env.push_bv env x)
end)
in (match (_67_1203) with
| (env, x) -> begin
(let _166_481 = (let _166_480 = (let _166_479 = (let _166_478 = (no_annot_abs tparams t)
in (FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _166_478))
in (_166_479)::[])
in (FStar_List.append typs _166_480))
in ((env), ((FStar_List.append tparams (((((

let _67_1204 = x
in {FStar_Syntax_Syntax.ppname = _67_1204.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = _67_1204.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = t})), (None)))::[]))), (_166_481)))
end))
end))
end)) ((env), ([]), ([])) (FStar_List.append binders (((FStar_Parser_AST.mk_binder (FStar_Parser_AST.NoName (t)) t.FStar_Parser_AST.range FStar_Parser_AST.Type None))::[])))
in (match (_67_1210) with
| (env, _67_1208, targs) -> begin
(

let _67_1214 = (let _166_482 = (FStar_Syntax_Util.mk_dtuple_lid (FStar_List.length targs) top.FStar_Parser_AST.range)
in (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_lid env) _166_482))
in (match (_67_1214) with
| (tup, _67_1213) -> begin
(FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_app (((tup), (targs)))))
end))
end))
end
| FStar_Parser_AST.Product (binders, t) -> begin
(

let _67_1221 = (uncurry binders t)
in (match (_67_1221) with
| (bs, t) -> begin
(

let rec aux = (fun env bs _67_11 -> (match (_67_11) with
| [] -> begin
(

let cod = (desugar_comp top.FStar_Parser_AST.range true env t)
in (let _166_489 = (FStar_Syntax_Util.arrow (FStar_List.rev bs) cod)
in (FStar_All.pipe_left setpos _166_489)))
end
| (hd)::tl -> begin
(

let mlenv = (FStar_Parser_Env.default_ml env)
in (

let bb = (desugar_binder mlenv hd)
in (

let _67_1235 = (as_binder env hd.FStar_Parser_AST.aqual bb)
in (match (_67_1235) with
| (b, env) -> begin
(aux env ((b)::bs) tl)
end))))
end))
in (aux env [] bs))
end))
end
| FStar_Parser_AST.Refine (b, f) -> begin
(match ((desugar_binder env b)) with
| (None, _67_1242) -> begin
(failwith "Missing binder in refinement")
end
| b -> begin
(

let _67_1250 = (as_binder env None b)
in (match (_67_1250) with
| ((x, _67_1247), env) -> begin
(

let f = (desugar_formula env f)
in (let _166_490 = (FStar_Syntax_Util.refine x f)
in (FStar_All.pipe_left setpos _166_490)))
end))
end)
end
| FStar_Parser_AST.Abs (binders, body) -> begin
(

let binders = (FStar_All.pipe_right binders (FStar_List.map replace_unit_pattern))
in (

let _67_1271 = (FStar_List.fold_left (fun _67_1259 pat -> (match (_67_1259) with
| (env, ftvs) -> begin
(match (pat.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed (_67_1262, t) -> begin
(let _166_494 = (let _166_493 = (free_type_vars env t)
in (FStar_List.append _166_493 ftvs))
in ((env), (_166_494)))
end
| _67_1267 -> begin
((env), (ftvs))
end)
end)) ((env), ([])) binders)
in (match (_67_1271) with
| (_67_1269, ftv) -> begin
(

let ftv = (sort_ftv ftv)
in (

let binders = (let _166_496 = (FStar_All.pipe_right ftv (FStar_List.map (fun a -> (FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatTvar (((a), (Some (FStar_Parser_AST.Implicit))))) top.FStar_Parser_AST.range))))
in (FStar_List.append _166_496 binders))
in (

let rec aux = (fun env bs sc_pat_opt _67_12 -> (match (_67_12) with
| [] -> begin
(

let body = (desugar_term env body)
in (

let body = (match (sc_pat_opt) with
| Some (sc, pat) -> begin
(

let body = (let _166_506 = (let _166_505 = (FStar_Syntax_Syntax.pat_bvs pat)
in (FStar_All.pipe_right _166_505 (FStar_List.map FStar_Syntax_Syntax.mk_binder)))
in (FStar_Syntax_Subst.close _166_506 body))
in (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_match (((sc), ((((pat), (None), (body)))::[])))) None body.FStar_Syntax_Syntax.pos))
end
| None -> begin
body
end)
in (let _166_507 = (no_annot_abs (FStar_List.rev bs) body)
in (setpos _166_507))))
end
| (p)::rest -> begin
(

let _67_1295 = (desugar_binding_pat env p)
in (match (_67_1295) with
| (env, b, pat) -> begin
(

let _67_1346 = (match (b) with
| LetBinder (_67_1297) -> begin
(failwith "Impossible")
end
| LocalBinder (x, aq) -> begin
(

let sc_pat_opt = (match (((pat), (sc_pat_opt))) with
| (None, _67_1305) -> begin
sc_pat_opt
end
| (Some (p), None) -> begin
(let _166_509 = (let _166_508 = (FStar_Syntax_Syntax.bv_to_name x)
in ((_166_508), (p)))
in Some (_166_509))
end
| (Some (p), Some (sc, p')) -> begin
(match (((sc.FStar_Syntax_Syntax.n), (p'.FStar_Syntax_Syntax.v))) with
| (FStar_Syntax_Syntax.Tm_name (_67_1319), _67_1322) -> begin
(

let tup2 = (let _166_510 = (FStar_Syntax_Util.mk_tuple_data_lid (Prims.parse_int "2") top.FStar_Parser_AST.range)
in (FStar_Syntax_Syntax.lid_as_fv _166_510 FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor))))
in (

let sc = (let _166_518 = (let _166_517 = (let _166_516 = (mk (FStar_Syntax_Syntax.Tm_fvar (tup2)))
in (let _166_515 = (let _166_514 = (FStar_Syntax_Syntax.as_arg sc)
in (let _166_513 = (let _166_512 = (let _166_511 = (FStar_Syntax_Syntax.bv_to_name x)
in (FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _166_511))
in (_166_512)::[])
in (_166_514)::_166_513))
in ((_166_516), (_166_515))))
in FStar_Syntax_Syntax.Tm_app (_166_517))
in (FStar_Syntax_Syntax.mk _166_518 None top.FStar_Parser_AST.range))
in (

let p = (let _166_519 = (FStar_Range.union_ranges p'.FStar_Syntax_Syntax.p p.FStar_Syntax_Syntax.p)
in (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_cons (((tup2), ((((p'), (false)))::(((p), (false)))::[])))) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n _166_519))
in Some (((sc), (p))))))
end
| (FStar_Syntax_Syntax.Tm_app (_67_1328, args), FStar_Syntax_Syntax.Pat_cons (_67_1333, pats)) -> begin
(

let tupn = (let _166_520 = (FStar_Syntax_Util.mk_tuple_data_lid ((Prims.parse_int "1") + (FStar_List.length args)) top.FStar_Parser_AST.range)
in (FStar_Syntax_Syntax.lid_as_fv _166_520 FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor))))
in (

let sc = (let _166_527 = (let _166_526 = (let _166_525 = (mk (FStar_Syntax_Syntax.Tm_fvar (tupn)))
in (let _166_524 = (let _166_523 = (let _166_522 = (let _166_521 = (FStar_Syntax_Syntax.bv_to_name x)
in (FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _166_521))
in (_166_522)::[])
in (FStar_List.append args _166_523))
in ((_166_525), (_166_524))))
in FStar_Syntax_Syntax.Tm_app (_166_526))
in (mk _166_527))
in (

let p = (let _166_528 = (FStar_Range.union_ranges p'.FStar_Syntax_Syntax.p p.FStar_Syntax_Syntax.p)
in (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_cons (((tupn), ((FStar_List.append pats ((((p), (false)))::[])))))) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n _166_528))
in Some (((sc), (p))))))
end
| _67_1342 -> begin
(failwith "Impossible")
end)
end)
in ((((x), (aq))), (sc_pat_opt)))
end)
in (match (_67_1346) with
| (b, sc_pat_opt) -> begin
(aux env ((b)::bs) sc_pat_opt rest)
end))
end))
end))
in (aux env [] None binders))))
end)))
end
| FStar_Parser_AST.App ({FStar_Parser_AST.tm = FStar_Parser_AST.Var (a); FStar_Parser_AST.range = rng; FStar_Parser_AST.level = _67_1348}, phi, _67_1355) when ((FStar_Ident.lid_equals a FStar_Syntax_Const.assert_lid) || (FStar_Ident.lid_equals a FStar_Syntax_Const.assume_lid)) -> begin
(

let phi = (desugar_formula env phi)
in (

let a = (FStar_Ident.set_lid_range a rng)
in (let _166_536 = (let _166_535 = (let _166_534 = (FStar_Syntax_Syntax.fvar a FStar_Syntax_Syntax.Delta_equational None)
in (let _166_533 = (let _166_532 = (FStar_Syntax_Syntax.as_arg phi)
in (let _166_531 = (let _166_530 = (let _166_529 = (mk (FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_unit)))
in (FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _166_529))
in (_166_530)::[])
in (_166_532)::_166_531))
in ((_166_534), (_166_533))))
in FStar_Syntax_Syntax.Tm_app (_166_535))
in (mk _166_536))))
end
| FStar_Parser_AST.App (_67_1361, _67_1363, FStar_Parser_AST.UnivApp) -> begin
(

let rec aux = (fun universes e -> (match ((let _166_541 = (unparen e)
in _166_541.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.App (e, t, FStar_Parser_AST.UnivApp) -> begin
(

let univ_arg = (desugar_universe t)
in (aux ((univ_arg)::universes) e))
end
| _67_1377 -> begin
(

let head = (desugar_term env e)
in (mk (FStar_Syntax_Syntax.Tm_uinst (((head), (universes))))))
end))
in (aux [] top))
end
| FStar_Parser_AST.App (_67_1380) -> begin
(

let rec aux = (fun args e -> (match ((let _166_546 = (unparen e)
in _166_546.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.App (e, t, imp) when (imp <> FStar_Parser_AST.UnivApp) -> begin
(

let arg = (let _166_547 = (desugar_term env t)
in (FStar_All.pipe_left (arg_withimp_e imp) _166_547))
in (aux ((arg)::args) e))
end
| _67_1392 -> begin
(

let head = (desugar_term env e)
in (mk (FStar_Syntax_Syntax.Tm_app (((head), (args))))))
end))
in (aux [] top))
end
| FStar_Parser_AST.Seq (t1, t2) -> begin
(let _166_550 = (let _166_549 = (let _166_548 = (desugar_term env (FStar_Parser_AST.mk_term (FStar_Parser_AST.Let (((FStar_Parser_AST.NoLetQualifier), (((((FStar_Parser_AST.mk_pattern FStar_Parser_AST.PatWild t1.FStar_Parser_AST.range)), (t1)))::[]), (t2)))) top.FStar_Parser_AST.range FStar_Parser_AST.Expr))
in ((_166_548), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Sequence))))
in FStar_Syntax_Syntax.Tm_meta (_166_549))
in (mk _166_550))
end
| FStar_Parser_AST.LetOpen (lid, e) -> begin
(

let env = (FStar_Parser_Env.push_namespace env lid)
in (desugar_term_maybe_top top_level env e))
end
| FStar_Parser_AST.Let (qual, ((pat, _snd))::_tl, body) -> begin
(

let is_rec = (qual = FStar_Parser_AST.Rec)
in (

let ds_let_rec_or_app = (fun _67_1414 -> (match (()) with
| () -> begin
(

let bindings = (((pat), (_snd)))::_tl
in (

let funs = (FStar_All.pipe_right bindings (FStar_List.map (fun _67_1418 -> (match (_67_1418) with
| (p, def) -> begin
if (is_app_pattern p) then begin
(let _166_554 = (destruct_app_pattern env top_level p)
in ((_166_554), (def)))
end else begin
(match ((FStar_Parser_AST.un_function p def)) with
| Some (p, def) -> begin
(let _166_555 = (destruct_app_pattern env top_level p)
in ((_166_555), (def)))
end
| _67_1424 -> begin
(match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id, _67_1429); FStar_Parser_AST.prange = _67_1426}, t) -> begin
if top_level then begin
(let _166_558 = (let _166_557 = (let _166_556 = (FStar_Parser_Env.qualify env id)
in FStar_Util.Inr (_166_556))
in ((_166_557), ([]), (Some (t))))
in ((_166_558), (def)))
end else begin
((((FStar_Util.Inl (id)), ([]), (Some (t)))), (def))
end
end
| FStar_Parser_AST.PatVar (id, _67_1438) -> begin
if top_level then begin
(let _166_561 = (let _166_560 = (let _166_559 = (FStar_Parser_Env.qualify env id)
in FStar_Util.Inr (_166_559))
in ((_166_560), ([]), (None)))
in ((_166_561), (def)))
end else begin
((((FStar_Util.Inl (id)), ([]), (None))), (def))
end
end
| _67_1442 -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Unexpected let binding"), (p.FStar_Parser_AST.prange)))))
end)
end)
end
end))))
in (

let _67_1471 = (FStar_List.fold_left (fun _67_1447 _67_1456 -> (match (((_67_1447), (_67_1456))) with
| ((env, fnames, rec_bindings), ((f, _67_1450, _67_1452), _67_1455)) -> begin
(

let _67_1467 = (match (f) with
| FStar_Util.Inl (x) -> begin
(

let _67_1461 = (FStar_Parser_Env.push_bv env x)
in (match (_67_1461) with
| (env, xx) -> begin
(let _166_565 = (let _166_564 = (FStar_Syntax_Syntax.mk_binder xx)
in (_166_564)::rec_bindings)
in ((env), (FStar_Util.Inl (xx)), (_166_565)))
end))
end
| FStar_Util.Inr (l) -> begin
(let _166_566 = (FStar_Parser_Env.push_top_level_rec_binding env l.FStar_Ident.ident FStar_Syntax_Syntax.Delta_equational)
in ((_166_566), (FStar_Util.Inr (l)), (rec_bindings)))
end)
in (match (_67_1467) with
| (env, lbname, rec_bindings) -> begin
((env), ((lbname)::fnames), (rec_bindings))
end))
end)) ((env), ([]), ([])) funs)
in (match (_67_1471) with
| (env', fnames, rec_bindings) -> begin
(

let fnames = (FStar_List.rev fnames)
in (

let desugar_one_def = (fun env lbname _67_1482 -> (match (_67_1482) with
| ((_67_1477, args, result_t), def) -> begin
(

let args = (FStar_All.pipe_right args (FStar_List.map replace_unit_pattern))
in (

let def = (match (result_t) with
| None -> begin
def
end
| Some (t) -> begin
(

let _67_1491 = if (is_comp_type env t) then begin
(match ((FStar_All.pipe_right args (FStar_List.tryFind (fun x -> (not ((is_var_pattern x))))))) with
| None -> begin
()
end
| Some (p) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Computation type annotations are only permitted on let-bindings without inlined patterns; replace this pattern with a variable"), (p.FStar_Parser_AST.prange)))))
end)
end else begin
()
end
in (let _166_574 = (FStar_Range.union_ranges t.FStar_Parser_AST.range def.FStar_Parser_AST.range)
in (FStar_Parser_AST.mk_term (FStar_Parser_AST.Ascribed (((def), (t)))) _166_574 FStar_Parser_AST.Expr)))
end)
in (

let def = (match (args) with
| [] -> begin
def
end
| _67_1496 -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.un_curry_abs args def) top.FStar_Parser_AST.range top.FStar_Parser_AST.level)
end)
in (

let body = (desugar_term env def)
in (

let lbname = (match (lbname) with
| FStar_Util.Inl (x) -> begin
FStar_Util.Inl (x)
end
| FStar_Util.Inr (l) -> begin
(let _166_576 = (let _166_575 = (FStar_Syntax_Util.incr_delta_qualifier body)
in (FStar_Syntax_Syntax.lid_as_fv l _166_575 None))
in FStar_Util.Inr (_166_576))
end)
in (

let body = if is_rec then begin
(FStar_Syntax_Subst.close rec_bindings body)
end else begin
body
end
in (mk_lb ((lbname), (FStar_Syntax_Syntax.tun), (body)))))))))
end))
in (

let lbs = (FStar_List.map2 (desugar_one_def (if is_rec then begin
env'
end else begin
env
end)) fnames funs)
in (

let body = (desugar_term env' body)
in (let _166_579 = (let _166_578 = (let _166_577 = (FStar_Syntax_Subst.close rec_bindings body)
in ((((is_rec), (lbs))), (_166_577)))
in FStar_Syntax_Syntax.Tm_let (_166_578))
in (FStar_All.pipe_left mk _166_579))))))
end))))
end))
in (

let ds_non_rec = (fun pat t1 t2 -> (

let t1 = (desugar_term env t1)
in (

let is_mutable = (qual = FStar_Parser_AST.Mutable)
in (

let t1 = if is_mutable then begin
(mk_ref_alloc t1)
end else begin
t1
end
in (

let _67_1517 = (desugar_binding_pat_maybe_top top_level env pat is_mutable)
in (match (_67_1517) with
| (env, binder, pat) -> begin
(

let tm = (match (binder) with
| LetBinder (l, t) -> begin
(

let body = (desugar_term env t2)
in (

let fv = (let _166_586 = (FStar_Syntax_Util.incr_delta_qualifier t1)
in (FStar_Syntax_Syntax.lid_as_fv l _166_586 None))
in (FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_let (((((false), (({FStar_Syntax_Syntax.lbname = FStar_Util.Inr (fv); FStar_Syntax_Syntax.lbunivs = []; FStar_Syntax_Syntax.lbtyp = t; FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_ALL_lid; FStar_Syntax_Syntax.lbdef = t1})::[]))), (body)))))))
end
| LocalBinder (x, _67_1526) -> begin
(

let body = (desugar_term env t2)
in (

let body = (match (pat) with
| (None) | (Some ({FStar_Syntax_Syntax.v = FStar_Syntax_Syntax.Pat_wild (_); FStar_Syntax_Syntax.ty = _; FStar_Syntax_Syntax.p = _})) -> begin
body
end
| Some (pat) -> begin
(let _166_591 = (let _166_590 = (let _166_589 = (FStar_Syntax_Syntax.bv_to_name x)
in (let _166_588 = (let _166_587 = (FStar_Syntax_Util.branch ((pat), (None), (body)))
in (_166_587)::[])
in ((_166_589), (_166_588))))
in FStar_Syntax_Syntax.Tm_match (_166_590))
in (FStar_Syntax_Syntax.mk _166_591 None body.FStar_Syntax_Syntax.pos))
end)
in (let _166_596 = (let _166_595 = (let _166_594 = (let _166_593 = (let _166_592 = (FStar_Syntax_Syntax.mk_binder x)
in (_166_592)::[])
in (FStar_Syntax_Subst.close _166_593 body))
in ((((false), (((mk_lb ((FStar_Util.Inl (x)), (x.FStar_Syntax_Syntax.sort), (t1))))::[]))), (_166_594)))
in FStar_Syntax_Syntax.Tm_let (_166_595))
in (FStar_All.pipe_left mk _166_596))))
end)
in if is_mutable then begin
(FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_meta (((tm), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Mutable_alloc))))))
end else begin
tm
end)
end))))))
in if (is_rec || (is_app_pattern pat)) then begin
(ds_let_rec_or_app ())
end else begin
(ds_non_rec pat _snd body)
end)))
end
| FStar_Parser_AST.If (t1, t2, t3) -> begin
(

let x = (FStar_Syntax_Syntax.new_bv (Some (t3.FStar_Parser_AST.range)) FStar_Syntax_Syntax.tun)
in (let _166_607 = (let _166_606 = (let _166_605 = (desugar_term env t1)
in (let _166_604 = (let _166_603 = (let _166_598 = (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_constant (FStar_Const.Const_bool (true))) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n t2.FStar_Parser_AST.range)
in (let _166_597 = (desugar_term env t2)
in ((_166_598), (None), (_166_597))))
in (let _166_602 = (let _166_601 = (let _166_600 = (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_wild (x)) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n t3.FStar_Parser_AST.range)
in (let _166_599 = (desugar_term env t3)
in ((_166_600), (None), (_166_599))))
in (_166_601)::[])
in (_166_603)::_166_602))
in ((_166_605), (_166_604))))
in FStar_Syntax_Syntax.Tm_match (_166_606))
in (mk _166_607)))
end
| FStar_Parser_AST.TryWith (e, branches) -> begin
(

let r = top.FStar_Parser_AST.range
in (

let handler = (FStar_Parser_AST.mk_function branches r r)
in (

let body = (FStar_Parser_AST.mk_function (((((FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatConst (FStar_Const.Const_unit)) r)), (None), (e)))::[]) r r)
in (

let a1 = (FStar_Parser_AST.mk_term (FStar_Parser_AST.App ((((FStar_Parser_AST.mk_term (FStar_Parser_AST.Var (FStar_Syntax_Const.try_with_lid)) r top.FStar_Parser_AST.level)), (body), (FStar_Parser_AST.Nothing)))) r top.FStar_Parser_AST.level)
in (

let a2 = (FStar_Parser_AST.mk_term (FStar_Parser_AST.App (((a1), (handler), (FStar_Parser_AST.Nothing)))) r top.FStar_Parser_AST.level)
in (desugar_term env a2))))))
end
| FStar_Parser_AST.Match (e, branches) -> begin
(

let desugar_branch = (fun _67_1567 -> (match (_67_1567) with
| (pat, wopt, b) -> begin
(

let _67_1570 = (desugar_match_pat env pat)
in (match (_67_1570) with
| (env, pat) -> begin
(

let wopt = (match (wopt) with
| None -> begin
None
end
| Some (e) -> begin
(let _166_610 = (desugar_term env e)
in Some (_166_610))
end)
in (

let b = (desugar_term env b)
in (FStar_Syntax_Util.branch ((pat), (wopt), (b)))))
end))
end))
in (let _166_614 = (let _166_613 = (let _166_612 = (desugar_term env e)
in (let _166_611 = (FStar_List.map desugar_branch branches)
in ((_166_612), (_166_611))))
in FStar_Syntax_Syntax.Tm_match (_166_613))
in (FStar_All.pipe_left mk _166_614)))
end
| FStar_Parser_AST.Ascribed (e, t) -> begin
(

let env = (FStar_Parser_Env.default_ml env)
in (

let c = (desugar_comp t.FStar_Parser_AST.range true env t)
in (

let annot = if (FStar_Syntax_Util.is_ml_comp c) then begin
FStar_Util.Inl ((FStar_Syntax_Util.comp_result c))
end else begin
FStar_Util.Inr (c)
end
in (let _166_617 = (let _166_616 = (let _166_615 = (desugar_term env e)
in ((_166_615), (annot), (None)))
in FStar_Syntax_Syntax.Tm_ascribed (_166_616))
in (FStar_All.pipe_left mk _166_617)))))
end
| FStar_Parser_AST.Record (_67_1584, []) -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Unexpected empty record"), (top.FStar_Parser_AST.range)))))
end
| FStar_Parser_AST.Record (eopt, fields) -> begin
(

let record = (check_fields env fields top.FStar_Parser_AST.range)
in (

let user_ns = (

let _67_1596 = (FStar_List.hd fields)
in (match (_67_1596) with
| (f, _67_1595) -> begin
f.FStar_Ident.ns
end))
in (

let get_field = (fun xopt f -> (

let found = (FStar_All.pipe_right fields (FStar_Util.find_opt (fun _67_1604 -> (match (_67_1604) with
| (g, _67_1603) -> begin
(f.FStar_Ident.idText = g.FStar_Ident.ident.FStar_Ident.idText)
end))))
in (

let fn = (FStar_Ident.lid_of_ids (FStar_List.append user_ns ((f)::[])))
in (match (found) with
| Some (_67_1608, e) -> begin
((fn), (e))
end
| None -> begin
(match (xopt) with
| None -> begin
(let _166_625 = (let _166_624 = (let _166_623 = (FStar_Util.format2 "Field %s of record type %s is missing" f.FStar_Ident.idText record.FStar_Parser_Env.typename.FStar_Ident.str)
in ((_166_623), (top.FStar_Parser_AST.range)))
in FStar_Syntax_Syntax.Error (_166_624))
in (Prims.raise _166_625))
end
| Some (x) -> begin
((fn), ((FStar_Parser_AST.mk_term (FStar_Parser_AST.Project (((x), (fn)))) x.FStar_Parser_AST.range x.FStar_Parser_AST.level)))
end)
end))))
in (

let user_constrname = (FStar_Ident.lid_of_ids (FStar_List.append user_ns ((record.FStar_Parser_Env.constrname)::[])))
in (

let recterm = (match (eopt) with
| None -> begin
(let _166_630 = (let _166_629 = (FStar_All.pipe_right record.FStar_Parser_Env.fields (FStar_List.map (fun _67_1621 -> (match (_67_1621) with
| (f, _67_1620) -> begin
(let _166_628 = (let _166_627 = (get_field None f)
in (FStar_All.pipe_left Prims.snd _166_627))
in ((_166_628), (FStar_Parser_AST.Nothing)))
end))))
in ((user_constrname), (_166_629)))
in FStar_Parser_AST.Construct (_166_630))
end
| Some (e) -> begin
(

let x = (FStar_Ident.gen e.FStar_Parser_AST.range)
in (

let xterm = (let _166_632 = (let _166_631 = (FStar_Ident.lid_of_ids ((x)::[]))
in FStar_Parser_AST.Var (_166_631))
in (FStar_Parser_AST.mk_term _166_632 x.FStar_Ident.idRange FStar_Parser_AST.Expr))
in (

let record = (let _166_635 = (let _166_634 = (FStar_All.pipe_right record.FStar_Parser_Env.fields (FStar_List.map (fun _67_1629 -> (match (_67_1629) with
| (f, _67_1628) -> begin
(get_field (Some (xterm)) f)
end))))
in ((None), (_166_634)))
in FStar_Parser_AST.Record (_166_635))
in FStar_Parser_AST.Let (((FStar_Parser_AST.NoLetQualifier), (((((FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatVar (((x), (None)))) x.FStar_Ident.idRange)), (e)))::[]), ((FStar_Parser_AST.mk_term record top.FStar_Parser_AST.range top.FStar_Parser_AST.level)))))))
end)
in (

let recterm = (FStar_Parser_AST.mk_term recterm top.FStar_Parser_AST.range top.FStar_Parser_AST.level)
in (

let e = (desugar_term env recterm)
in (match (e.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_meta ({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_app ({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar (fv); FStar_Syntax_Syntax.tk = _67_1645; FStar_Syntax_Syntax.pos = _67_1643; FStar_Syntax_Syntax.vars = _67_1641}, args); FStar_Syntax_Syntax.tk = _67_1639; FStar_Syntax_Syntax.pos = _67_1637; FStar_Syntax_Syntax.vars = _67_1635}, FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Data_app)) -> begin
(

let e = (let _166_642 = (let _166_641 = (let _166_640 = (let _166_639 = (let _166_638 = (let _166_637 = (let _166_636 = (FStar_All.pipe_right record.FStar_Parser_Env.fields (FStar_List.map Prims.fst))
in ((record.FStar_Parser_Env.typename), (_166_636)))
in FStar_Syntax_Syntax.Record_ctor (_166_637))
in Some (_166_638))
in (FStar_Syntax_Syntax.fvar (FStar_Ident.set_lid_range fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v e.FStar_Syntax_Syntax.pos) FStar_Syntax_Syntax.Delta_constant _166_639))
in ((_166_640), (args)))
in FStar_Syntax_Syntax.Tm_app (_166_641))
in (FStar_All.pipe_left mk _166_642))
in (FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_meta (((e), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Data_app)))))))
end
| _67_1659 -> begin
e
end))))))))
end
| FStar_Parser_AST.Project (e, f) -> begin
(

let _67_1666 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_dc_by_field_name env) f)
in (match (_67_1666) with
| (constrname, is_rec) -> begin
(

let e = (desugar_term env e)
in (

let projname = (FStar_Syntax_Util.mk_field_projector_name_from_ident constrname f.FStar_Ident.ident)
in (

let qual = if is_rec then begin
Some (FStar_Syntax_Syntax.Record_projector (((constrname), (f.FStar_Ident.ident))))
end else begin
None
end
in (let _166_647 = (let _166_646 = (let _166_645 = (FStar_Syntax_Syntax.fvar (FStar_Ident.set_lid_range projname (FStar_Ident.range_of_lid f)) FStar_Syntax_Syntax.Delta_equational qual)
in (let _166_644 = (let _166_643 = (FStar_Syntax_Syntax.as_arg e)
in (_166_643)::[])
in ((_166_645), (_166_644))))
in FStar_Syntax_Syntax.Tm_app (_166_646))
in (FStar_All.pipe_left mk _166_647)))))
end))
end
| (FStar_Parser_AST.NamedTyp (_, e)) | (FStar_Parser_AST.Paren (e)) -> begin
(desugar_term env e)
end
| _67_1677 when (top.FStar_Parser_AST.level = FStar_Parser_AST.Formula) -> begin
(desugar_formula env top)
end
| _67_1679 -> begin
(FStar_Parser_AST.error "Unexpected term" top top.FStar_Parser_AST.range)
end
| FStar_Parser_AST.Let (_67_1681, _67_1683, _67_1685) -> begin
(failwith "Not implemented yet")
end
| FStar_Parser_AST.QForall (_67_1689, _67_1691, _67_1693) -> begin
(failwith "Not implemented yet")
end
| FStar_Parser_AST.QExists (_67_1697, _67_1699, _67_1701) -> begin
(failwith "Not implemented yet")
end))))
and desugar_args : FStar_Parser_Env.env  ->  (FStar_Parser_AST.term * FStar_Parser_AST.imp) Prims.list  ->  (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list = (fun env args -> (FStar_All.pipe_right args (FStar_List.map (fun _67_1708 -> (match (_67_1708) with
| (a, imp) -> begin
(let _166_651 = (desugar_term env a)
in (arg_withimp_e imp _166_651))
end)))))
and desugar_comp : FStar_Range.range  ->  Prims.bool  ->  FStar_Parser_Env.env  ->  FStar_Parser_AST.term  ->  (FStar_Syntax_Syntax.comp', Prims.unit) FStar_Syntax_Syntax.syntax = (fun r default_ok env t -> (

let fail = (fun msg -> (Prims.raise (FStar_Syntax_Syntax.Error (((msg), (r))))))
in (

let is_requires = (fun _67_1720 -> (match (_67_1720) with
| (t, _67_1719) -> begin
(match ((let _166_659 = (unparen t)
in _166_659.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Requires (_67_1722) -> begin
true
end
| _67_1725 -> begin
false
end)
end))
in (

let is_ensures = (fun _67_1730 -> (match (_67_1730) with
| (t, _67_1729) -> begin
(match ((let _166_662 = (unparen t)
in _166_662.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Ensures (_67_1732) -> begin
true
end
| _67_1735 -> begin
false
end)
end))
in (

let is_app = (fun head _67_1741 -> (match (_67_1741) with
| (t, _67_1740) -> begin
(match ((let _166_667 = (unparen t)
in _166_667.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.App ({FStar_Parser_AST.tm = FStar_Parser_AST.Var (d); FStar_Parser_AST.range = _67_1745; FStar_Parser_AST.level = _67_1743}, _67_1750, _67_1752) -> begin
(d.FStar_Ident.ident.FStar_Ident.idText = head)
end
| _67_1756 -> begin
false
end)
end))
in (

let is_decreases = (is_app "decreases")
in (

let pre_process_comp_typ = (fun t -> (

let _67_1762 = (head_and_args t)
in (match (_67_1762) with
| (head, args) -> begin
(match (head.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Name (lemma) when (lemma.FStar_Ident.ident.FStar_Ident.idText = "Lemma") -> begin
(

let unit_tm = (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.unit_lid)) t.FStar_Parser_AST.range FStar_Parser_AST.Type)), (FStar_Parser_AST.Nothing))
in (

let nil_pat = (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.nil_lid)) t.FStar_Parser_AST.range FStar_Parser_AST.Expr)), (FStar_Parser_AST.Nothing))
in (

let req_true = (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Requires ((((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.true_lid)) t.FStar_Parser_AST.range FStar_Parser_AST.Formula)), (None)))) t.FStar_Parser_AST.range FStar_Parser_AST.Type)), (FStar_Parser_AST.Nothing))
in (

let args = (match (args) with
| [] -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Not enough arguments to \'Lemma\'"), (t.FStar_Parser_AST.range)))))
end
| (ens)::[] -> begin
(unit_tm)::(req_true)::(ens)::(nil_pat)::[]
end
| (req)::(ens)::[] when ((is_requires req) && (is_ensures ens)) -> begin
(unit_tm)::(req)::(ens)::(nil_pat)::[]
end
| (ens)::(dec)::[] when ((is_ensures ens) && (is_decreases dec)) -> begin
(unit_tm)::(req_true)::(ens)::(nil_pat)::(dec)::[]
end
| (req)::(ens)::(dec)::[] when (((is_requires req) && (is_ensures ens)) && (is_app "decreases" dec)) -> begin
(unit_tm)::(req)::(ens)::(nil_pat)::(dec)::[]
end
| more -> begin
(unit_tm)::more
end)
in (

let head_and_attributes = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_effect_name_and_attributes env) lemma)
in ((head_and_attributes), (args)))))))
end
| FStar_Parser_AST.Name (l) when (FStar_Parser_Env.is_effect_name env l) -> begin
(let _166_671 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_effect_name_and_attributes env) l)
in ((_166_671), (args)))
end
| FStar_Parser_AST.Name (l) when ((let _166_672 = (FStar_Parser_Env.current_module env)
in (FStar_Ident.lid_equals _166_672 FStar_Syntax_Const.prims_lid)) && (l.FStar_Ident.ident.FStar_Ident.idText = "Tot")) -> begin
(((((FStar_Ident.set_lid_range FStar_Syntax_Const.effect_Tot_lid head.FStar_Parser_AST.range)), ([]))), (args))
end
| FStar_Parser_AST.Name (l) when ((let _166_673 = (FStar_Parser_Env.current_module env)
in (FStar_Ident.lid_equals _166_673 FStar_Syntax_Const.prims_lid)) && (l.FStar_Ident.ident.FStar_Ident.idText = "GTot")) -> begin
(((((FStar_Ident.set_lid_range FStar_Syntax_Const.effect_GTot_lid head.FStar_Parser_AST.range)), ([]))), (args))
end
| FStar_Parser_AST.Name (l) when ((((l.FStar_Ident.ident.FStar_Ident.idText = "Type") || (l.FStar_Ident.ident.FStar_Ident.idText = "Type0")) || (l.FStar_Ident.ident.FStar_Ident.idText = "Effect")) && default_ok) -> begin
(((((FStar_Ident.set_lid_range FStar_Syntax_Const.effect_Tot_lid head.FStar_Parser_AST.range)), ([]))), ((((t), (FStar_Parser_AST.Nothing)))::[]))
end
| _67_1793 when default_ok -> begin
(((((FStar_Ident.set_lid_range env.FStar_Parser_Env.default_result_effect head.FStar_Parser_AST.range)), ([]))), ((((t), (FStar_Parser_AST.Nothing)))::[]))
end
| _67_1795 -> begin
(let _166_675 = (let _166_674 = (FStar_Parser_AST.term_to_string t)
in (FStar_Util.format1 "%s is not an effect" _166_674))
in (fail _166_675))
end)
end)))
in (

let _67_1800 = (pre_process_comp_typ t)
in (match (_67_1800) with
| ((eff, cattributes), args) -> begin
(

let _67_1801 = if ((FStar_List.length args) = (Prims.parse_int "0")) then begin
(let _166_677 = (let _166_676 = (FStar_Syntax_Print.lid_to_string eff)
in (FStar_Util.format1 "Not enough args to effect %s" _166_676))
in (fail _166_677))
end else begin
()
end
in (

let is_universe = (fun _67_1807 -> (match (_67_1807) with
| (_67_1805, imp) -> begin
(imp = FStar_Parser_AST.UnivApp)
end))
in (

let _67_1810 = (FStar_Util.take is_universe args)
in (match (_67_1810) with
| (universes, args) -> begin
(

let universes = (FStar_List.map (fun _67_1813 -> (match (_67_1813) with
| (u, imp) -> begin
(desugar_universe u)
end)) universes)
in (

let _67_1817 = (let _166_682 = (FStar_List.hd args)
in (let _166_681 = (FStar_List.tl args)
in ((_166_682), (_166_681))))
in (match (_67_1817) with
| (result_arg, rest) -> begin
(

let result_typ = (desugar_typ env (Prims.fst result_arg))
in (

let rest = (desugar_args env rest)
in (

let _67_1842 = (FStar_All.pipe_right rest (FStar_List.partition (fun _67_1823 -> (match (_67_1823) with
| (t, _67_1822) -> begin
(match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_app ({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar (fv); FStar_Syntax_Syntax.tk = _67_1829; FStar_Syntax_Syntax.pos = _67_1827; FStar_Syntax_Syntax.vars = _67_1825}, (_67_1834)::[]) -> begin
(FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.decreases_lid)
end
| _67_1839 -> begin
false
end)
end))))
in (match (_67_1842) with
| (dec, rest) -> begin
(

let decreases_clause = (FStar_All.pipe_right dec (FStar_List.map (fun _67_1846 -> (match (_67_1846) with
| (t, _67_1845) -> begin
(match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_app (_67_1848, ((arg, _67_1851))::[]) -> begin
FStar_Syntax_Syntax.DECREASES (arg)
end
| _67_1857 -> begin
(failwith "impos")
end)
end))))
in (

let no_additional_args = (

let is_empty = (fun l -> (match (l) with
| [] -> begin
true
end
| _67_1864 -> begin
false
end))
in ((((is_empty decreases_clause) && (is_empty rest)) && (is_empty cattributes)) && (is_empty universes)))
in if (no_additional_args && (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_Tot_lid)) then begin
(FStar_Syntax_Syntax.mk_Total result_typ)
end else begin
if (no_additional_args && (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_GTot_lid)) then begin
(FStar_Syntax_Syntax.mk_GTotal result_typ)
end else begin
(

let flags = if (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_Lemma_lid) then begin
(FStar_Syntax_Syntax.LEMMA)::[]
end else begin
if (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_Tot_lid) then begin
(FStar_Syntax_Syntax.TOTAL)::[]
end else begin
if (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_ML_lid) then begin
(FStar_Syntax_Syntax.MLEFFECT)::[]
end else begin
if (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_GTot_lid) then begin
(FStar_Syntax_Syntax.SOMETRIVIAL)::[]
end else begin
[]
end
end
end
end
in (

let flags = (FStar_List.append flags cattributes)
in (

let rest = if (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_Lemma_lid) then begin
(match (rest) with
| (req)::(ens)::((pat, aq))::[] -> begin
(

let pat = (match (pat.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_fvar (fv) when (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.nil_lid) -> begin
(

let nil = (FStar_Syntax_Syntax.mk_Tm_uinst pat ((FStar_Syntax_Syntax.U_succ (FStar_Syntax_Syntax.U_zero))::[]))
in (

let pattern = (let _166_686 = (FStar_Syntax_Syntax.fvar (FStar_Ident.set_lid_range FStar_Syntax_Const.pattern_lid pat.FStar_Syntax_Syntax.pos) FStar_Syntax_Syntax.Delta_constant None)
in (FStar_Syntax_Syntax.mk_Tm_uinst _166_686 ((FStar_Syntax_Syntax.U_zero)::[])))
in (FStar_Syntax_Syntax.mk_Tm_app nil ((((pattern), (Some (FStar_Syntax_Syntax.imp_tag))))::[]) None pat.FStar_Syntax_Syntax.pos)))
end
| _67_1879 -> begin
pat
end)
in (let _166_690 = (let _166_689 = (let _166_688 = (let _166_687 = (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_meta (((pat), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Meta_smt_pat))))) None pat.FStar_Syntax_Syntax.pos)
in ((_166_687), (aq)))
in (_166_688)::[])
in (ens)::_166_689)
in (req)::_166_690))
end
| _67_1882 -> begin
rest
end)
end else begin
rest
end
in (FStar_Syntax_Syntax.mk_Comp {FStar_Syntax_Syntax.comp_univs = universes; FStar_Syntax_Syntax.effect_name = eff; FStar_Syntax_Syntax.result_typ = result_typ; FStar_Syntax_Syntax.effect_args = rest; FStar_Syntax_Syntax.flags = (FStar_List.append flags decreases_clause)}))))
end
end))
end))))
end)))
end))))
end)))))))))
and desugar_formula : env_t  ->  FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.term = (fun env f -> (

let connective = (fun s -> (match (s) with
| "/\\" -> begin
Some (FStar_Syntax_Const.and_lid)
end
| "\\/" -> begin
Some (FStar_Syntax_Const.or_lid)
end
| "==>" -> begin
Some (FStar_Syntax_Const.imp_lid)
end
| "<==>" -> begin
Some (FStar_Syntax_Const.iff_lid)
end
| "~" -> begin
Some (FStar_Syntax_Const.not_lid)
end
| _67_1894 -> begin
None
end))
in (

let mk = (fun t -> (FStar_Syntax_Syntax.mk t None f.FStar_Parser_AST.range))
in (

let pos = (fun t -> (t None f.FStar_Parser_AST.range))
in (

let setpos = (fun t -> (

let _67_1901 = t
in {FStar_Syntax_Syntax.n = _67_1901.FStar_Syntax_Syntax.n; FStar_Syntax_Syntax.tk = _67_1901.FStar_Syntax_Syntax.tk; FStar_Syntax_Syntax.pos = f.FStar_Parser_AST.range; FStar_Syntax_Syntax.vars = _67_1901.FStar_Syntax_Syntax.vars}))
in (

let desugar_quant = (fun q b pats body -> (

let tk = (desugar_binder env (

let _67_1908 = b
in {FStar_Parser_AST.b = _67_1908.FStar_Parser_AST.b; FStar_Parser_AST.brange = _67_1908.FStar_Parser_AST.brange; FStar_Parser_AST.blevel = FStar_Parser_AST.Formula; FStar_Parser_AST.aqual = _67_1908.FStar_Parser_AST.aqual}))
in (

let desugar_pats = (fun env pats -> (FStar_List.map (fun es -> (FStar_All.pipe_right es (FStar_List.map (fun e -> (let _166_725 = (desugar_term env e)
in (FStar_All.pipe_left (arg_withimp_t FStar_Parser_AST.Nothing) _166_725)))))) pats))
in (match (tk) with
| (Some (a), k) -> begin
(

let _67_1922 = (FStar_Parser_Env.push_bv env a)
in (match (_67_1922) with
| (env, a) -> begin
(

let a = (

let _67_1923 = a
in {FStar_Syntax_Syntax.ppname = _67_1923.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = _67_1923.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = k})
in (

let pats = (desugar_pats env pats)
in (

let body = (desugar_formula env body)
in (

let body = (match (pats) with
| [] -> begin
body
end
| _67_1930 -> begin
(mk (FStar_Syntax_Syntax.Tm_meta (((body), (FStar_Syntax_Syntax.Meta_pattern (pats))))))
end)
in (

let body = (let _166_728 = (let _166_727 = (let _166_726 = (FStar_Syntax_Syntax.mk_binder a)
in (_166_726)::[])
in (no_annot_abs _166_727 body))
in (FStar_All.pipe_left setpos _166_728))
in (let _166_733 = (let _166_732 = (let _166_731 = (FStar_Syntax_Syntax.fvar (FStar_Ident.set_lid_range q b.FStar_Parser_AST.brange) (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "1"))) None)
in (let _166_730 = (let _166_729 = (FStar_Syntax_Syntax.as_arg body)
in (_166_729)::[])
in ((_166_731), (_166_730))))
in FStar_Syntax_Syntax.Tm_app (_166_732))
in (FStar_All.pipe_left mk _166_733)))))))
end))
end
| _67_1934 -> begin
(failwith "impossible")
end))))
in (

let push_quant = (fun q binders pats body -> (match (binders) with
| (b)::(b')::_rest -> begin
(

let rest = (b')::_rest
in (

let body = (let _166_748 = (q ((rest), (pats), (body)))
in (let _166_747 = (FStar_Range.union_ranges b'.FStar_Parser_AST.brange body.FStar_Parser_AST.range)
in (FStar_Parser_AST.mk_term _166_748 _166_747 FStar_Parser_AST.Formula)))
in (let _166_749 = (q (((b)::[]), ([]), (body)))
in (FStar_Parser_AST.mk_term _166_749 f.FStar_Parser_AST.range FStar_Parser_AST.Formula))))
end
| _67_1948 -> begin
(failwith "impossible")
end))
in (match ((let _166_750 = (unparen f)
in _166_750.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Labeled (f, l, p) -> begin
(

let f = (desugar_formula env f)
in (FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_meta (((f), (FStar_Syntax_Syntax.Meta_labeled (((l), (f.FStar_Syntax_Syntax.pos), (p)))))))))
end
| (FStar_Parser_AST.QForall ([], _, _)) | (FStar_Parser_AST.QExists ([], _, _)) -> begin
(failwith "Impossible: Quantifier without binders")
end
| FStar_Parser_AST.QForall ((_1)::(_2)::_3, pats, body) -> begin
(

let binders = (_1)::(_2)::_3
in (let _166_752 = (push_quant (fun x -> FStar_Parser_AST.QForall (x)) binders pats body)
in (desugar_formula env _166_752)))
end
| FStar_Parser_AST.QExists ((_1)::(_2)::_3, pats, body) -> begin
(

let binders = (_1)::(_2)::_3
in (let _166_754 = (push_quant (fun x -> FStar_Parser_AST.QExists (x)) binders pats body)
in (desugar_formula env _166_754)))
end
| FStar_Parser_AST.QForall ((b)::[], pats, body) -> begin
(desugar_quant FStar_Syntax_Const.forall_lid b pats body)
end
| FStar_Parser_AST.QExists ((b)::[], pats, body) -> begin
(desugar_quant FStar_Syntax_Const.exists_lid b pats body)
end
| FStar_Parser_AST.Paren (f) -> begin
(desugar_formula env f)
end
| _67_2006 -> begin
(desugar_term env f)
end))))))))
and typars_of_binders : FStar_Parser_Env.env  ->  FStar_Parser_AST.binder Prims.list  ->  (FStar_Parser_Env.env * (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list) = (fun env bs -> (

let _67_2030 = (FStar_List.fold_left (fun _67_2011 b -> (match (_67_2011) with
| (env, out) -> begin
(

let tk = (desugar_binder env (

let _67_2013 = b
in {FStar_Parser_AST.b = _67_2013.FStar_Parser_AST.b; FStar_Parser_AST.brange = _67_2013.FStar_Parser_AST.brange; FStar_Parser_AST.blevel = FStar_Parser_AST.Formula; FStar_Parser_AST.aqual = _67_2013.FStar_Parser_AST.aqual}))
in (match (tk) with
| (Some (a), k) -> begin
(

let _67_2022 = (FStar_Parser_Env.push_bv env a)
in (match (_67_2022) with
| (env, a) -> begin
(

let a = (

let _67_2023 = a
in {FStar_Syntax_Syntax.ppname = _67_2023.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = _67_2023.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = k})
in ((env), ((((a), ((trans_aqual b.FStar_Parser_AST.aqual))))::out)))
end))
end
| _67_2027 -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Unexpected binder"), (b.FStar_Parser_AST.brange)))))
end))
end)) ((env), ([])) bs)
in (match (_67_2030) with
| (env, tpars) -> begin
((env), ((FStar_List.rev tpars)))
end)))
and desugar_binder : FStar_Parser_Env.env  ->  FStar_Parser_AST.binder  ->  (FStar_Ident.ident Prims.option * FStar_Syntax_Syntax.term) = (fun env b -> (match (b.FStar_Parser_AST.b) with
| (FStar_Parser_AST.TAnnotated (x, t)) | (FStar_Parser_AST.Annotated (x, t)) -> begin
(let _166_761 = (desugar_typ env t)
in ((Some (x)), (_166_761)))
end
| FStar_Parser_AST.TVariable (x) -> begin
(let _166_762 = (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_type (FStar_Syntax_Syntax.U_unknown)) None x.FStar_Ident.idRange)
in ((Some (x)), (_166_762)))
end
| FStar_Parser_AST.NoName (t) -> begin
(let _166_763 = (desugar_typ env t)
in ((None), (_166_763)))
end
| FStar_Parser_AST.Variable (x) -> begin
((Some (x)), (FStar_Syntax_Syntax.tun))
end))


let mk_data_discriminators = (fun quals env t tps k datas -> (

let quals = (FStar_All.pipe_right quals (FStar_List.filter (fun _67_13 -> (match (_67_13) with
| (FStar_Syntax_Syntax.Abstract) | (FStar_Syntax_Syntax.Private) -> begin
true
end
| _67_2055 -> begin
false
end))))
in (

let quals = (fun q -> if ((FStar_All.pipe_left Prims.op_Negation env.FStar_Parser_Env.iface) || env.FStar_Parser_Env.admitted_iface) then begin
(FStar_List.append ((FStar_Syntax_Syntax.Assumption)::q) quals)
end else begin
(FStar_List.append q quals)
end)
in (FStar_All.pipe_right datas (FStar_List.map (fun d -> (

let disc_name = (FStar_Syntax_Util.mk_discriminator d)
in (let _166_775 = (let _166_774 = (quals ((FStar_Syntax_Syntax.OnlyName)::(FStar_Syntax_Syntax.Discriminator (d))::[]))
in ((disc_name), ([]), (FStar_Syntax_Syntax.tun), (_166_774), ((FStar_Ident.range_of_lid disc_name))))
in FStar_Syntax_Syntax.Sig_declare_typ (_166_775)))))))))


let mk_indexed_projector_names : FStar_Syntax_Syntax.qualifier Prims.list  ->  FStar_Syntax_Syntax.fv_qual  ->  FStar_Parser_Env.env  ->  FStar_Ident.lid  ->  FStar_Syntax_Syntax.binder Prims.list  ->  FStar_Syntax_Syntax.sigelt Prims.list = (fun iquals fvq env lid fields -> (

let p = (FStar_Ident.range_of_lid lid)
in (let _166_803 = (FStar_All.pipe_right fields (FStar_List.mapi (fun i _67_2071 -> (match (_67_2071) with
| (x, _67_2070) -> begin
(

let _67_2075 = (FStar_Syntax_Util.mk_field_projector_name lid x i)
in (match (_67_2075) with
| (field_name, _67_2074) -> begin
(

let only_decl = (((let _166_788 = (FStar_Parser_Env.current_module env)
in (FStar_Ident.lid_equals FStar_Syntax_Const.prims_lid _166_788)) || (fvq <> FStar_Syntax_Syntax.Data_ctor)) || (let _166_790 = (let _166_789 = (FStar_Parser_Env.current_module env)
in _166_789.FStar_Ident.str)
in (FStar_Options.dont_gen_projectors _166_790)))
in (

let no_decl = (FStar_Syntax_Syntax.is_type x.FStar_Syntax_Syntax.sort)
in (

let quals = (fun q -> if only_decl then begin
(let _166_794 = (FStar_List.filter (fun _67_14 -> (match (_67_14) with
| FStar_Syntax_Syntax.Abstract -> begin
false
end
| _67_2083 -> begin
true
end)) q)
in (FStar_Syntax_Syntax.Assumption)::_166_794)
end else begin
q
end)
in (

let quals = (

let iquals = (FStar_All.pipe_right iquals (FStar_List.filter (fun _67_15 -> (match (_67_15) with
| (FStar_Syntax_Syntax.Abstract) | (FStar_Syntax_Syntax.Private) -> begin
true
end
| _67_2088 -> begin
false
end))))
in (quals ((FStar_Syntax_Syntax.OnlyName)::(FStar_Syntax_Syntax.Projector (((lid), (x.FStar_Syntax_Syntax.ppname))))::iquals)))
in (

let decl = FStar_Syntax_Syntax.Sig_declare_typ (((field_name), ([]), (FStar_Syntax_Syntax.tun), (quals), ((FStar_Ident.range_of_lid field_name))))
in if only_decl then begin
(decl)::[]
end else begin
(

let dd = if (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Abstract)) then begin
FStar_Syntax_Syntax.Delta_abstract (FStar_Syntax_Syntax.Delta_equational)
end else begin
FStar_Syntax_Syntax.Delta_equational
end
in (

let lb = (let _166_797 = (let _166_796 = (FStar_Syntax_Syntax.lid_as_fv field_name dd None)
in FStar_Util.Inr (_166_796))
in {FStar_Syntax_Syntax.lbname = _166_797; FStar_Syntax_Syntax.lbunivs = []; FStar_Syntax_Syntax.lbtyp = FStar_Syntax_Syntax.tun; FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_Tot_lid; FStar_Syntax_Syntax.lbdef = FStar_Syntax_Syntax.tun})
in (

let impl = (let _166_802 = (let _166_801 = (let _166_800 = (let _166_799 = (FStar_All.pipe_right lb.FStar_Syntax_Syntax.lbname FStar_Util.right)
in (FStar_All.pipe_right _166_799 (fun fv -> fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)))
in (_166_800)::[])
in ((((false), ((lb)::[]))), (p), (_166_801), (quals), ([])))
in FStar_Syntax_Syntax.Sig_let (_166_802))
in if no_decl then begin
(impl)::[]
end else begin
(decl)::(impl)::[]
end)))
end)))))
end))
end))))
in (FStar_All.pipe_right _166_803 FStar_List.flatten))))


let mk_data_projector_names = (fun iquals env _67_2100 -> (match (_67_2100) with
| (inductive_tps, se) -> begin
(match (se) with
| FStar_Syntax_Syntax.Sig_datacon (lid, _67_2103, t, _67_2106, n, quals, _67_2110, _67_2112) when (not ((FStar_Ident.lid_equals lid FStar_Syntax_Const.lexcons_lid))) -> begin
(

let _67_2118 = (FStar_Syntax_Util.arrow_formals t)
in (match (_67_2118) with
| (formals, _67_2117) -> begin
(match (formals) with
| [] -> begin
[]
end
| _67_2121 -> begin
(

let filter_records = (fun _67_16 -> (match (_67_16) with
| FStar_Syntax_Syntax.RecordConstructor (_67_2124, fns) -> begin
Some (FStar_Syntax_Syntax.Record_ctor (((lid), (fns))))
end
| _67_2129 -> begin
None
end))
in (

let fv_qual = (match ((FStar_Util.find_map quals filter_records)) with
| None -> begin
FStar_Syntax_Syntax.Data_ctor
end
| Some (q) -> begin
q
end)
in (

let iquals = if (FStar_List.contains FStar_Syntax_Syntax.Abstract iquals) then begin
(FStar_Syntax_Syntax.Private)::iquals
end else begin
iquals
end
in (

let _67_2139 = (FStar_Util.first_N n formals)
in (match (_67_2139) with
| (_67_2137, rest) -> begin
(mk_indexed_projector_names iquals fv_qual env lid rest)
end)))))
end)
end))
end
| _67_2141 -> begin
[]
end)
end))


let mk_typ_abbrev : FStar_Ident.lident  ->  FStar_Syntax_Syntax.univ_name Prims.list  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list  ->  FStar_Syntax_Syntax.typ  ->  FStar_Syntax_Syntax.term  ->  FStar_Ident.lident Prims.list  ->  FStar_Syntax_Syntax.qualifier Prims.list  ->  FStar_Range.range  ->  FStar_Syntax_Syntax.sigelt = (fun lid uvs typars k t lids quals rng -> (

let dd = if (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Abstract)) then begin
(let _166_825 = (FStar_Syntax_Util.incr_delta_qualifier t)
in FStar_Syntax_Syntax.Delta_abstract (_166_825))
end else begin
(FStar_Syntax_Util.incr_delta_qualifier t)
end
in (

let lb = (let _166_830 = (let _166_826 = (FStar_Syntax_Syntax.lid_as_fv lid dd None)
in FStar_Util.Inr (_166_826))
in (let _166_829 = (let _166_827 = (FStar_Syntax_Syntax.mk_Total k)
in (FStar_Syntax_Util.arrow typars _166_827))
in (let _166_828 = (no_annot_abs typars t)
in {FStar_Syntax_Syntax.lbname = _166_830; FStar_Syntax_Syntax.lbunivs = uvs; FStar_Syntax_Syntax.lbtyp = _166_829; FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_Tot_lid; FStar_Syntax_Syntax.lbdef = _166_828})))
in FStar_Syntax_Syntax.Sig_let (((((false), ((lb)::[]))), (rng), (lids), (quals), ([]))))))


let rec desugar_tycon : FStar_Parser_Env.env  ->  FStar_Range.range  ->  FStar_Syntax_Syntax.qualifier Prims.list  ->  FStar_Parser_AST.tycon Prims.list  ->  (env_t * FStar_Syntax_Syntax.sigelts) = (fun env rng quals tcs -> (

let tycon_id = (fun _67_17 -> (match (_67_17) with
| (FStar_Parser_AST.TyconAbstract (id, _, _)) | (FStar_Parser_AST.TyconAbbrev (id, _, _, _)) | (FStar_Parser_AST.TyconRecord (id, _, _, _)) | (FStar_Parser_AST.TyconVariant (id, _, _, _)) -> begin
id
end))
in (

let binder_to_term = (fun b -> (match (b.FStar_Parser_AST.b) with
| (FStar_Parser_AST.Annotated (x, _)) | (FStar_Parser_AST.Variable (x)) -> begin
(let _166_844 = (let _166_843 = (FStar_Ident.lid_of_ids ((x)::[]))
in FStar_Parser_AST.Var (_166_843))
in (FStar_Parser_AST.mk_term _166_844 x.FStar_Ident.idRange FStar_Parser_AST.Expr))
end
| (FStar_Parser_AST.TAnnotated (a, _)) | (FStar_Parser_AST.TVariable (a)) -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar (a)) a.FStar_Ident.idRange FStar_Parser_AST.Type)
end
| FStar_Parser_AST.NoName (t) -> begin
t
end))
in (

let tot = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.effect_Tot_lid)) rng FStar_Parser_AST.Expr)
in (

let with_constructor_effect = (fun t -> (FStar_Parser_AST.mk_term (FStar_Parser_AST.App (((tot), (t), (FStar_Parser_AST.Nothing)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level))
in (

let apply_binders = (fun t binders -> (

let imp_of_aqual = (fun b -> (match (b.FStar_Parser_AST.aqual) with
| Some (FStar_Parser_AST.Implicit) -> begin
FStar_Parser_AST.Hash
end
| _67_2216 -> begin
FStar_Parser_AST.Nothing
end))
in (FStar_List.fold_left (fun out b -> (let _166_857 = (let _166_856 = (let _166_855 = (binder_to_term b)
in ((out), (_166_855), ((imp_of_aqual b))))
in FStar_Parser_AST.App (_166_856))
in (FStar_Parser_AST.mk_term _166_857 out.FStar_Parser_AST.range out.FStar_Parser_AST.level))) t binders)))
in (

let tycon_record_as_variant = (fun _67_18 -> (match (_67_18) with
| FStar_Parser_AST.TyconRecord (id, parms, kopt, fields) -> begin
(

let constrName = (FStar_Ident.mk_ident (((Prims.strcat "Mk" id.FStar_Ident.idText)), (id.FStar_Ident.idRange)))
in (

let mfields = (FStar_List.map (fun _67_2231 -> (match (_67_2231) with
| (x, t, _67_2230) -> begin
(FStar_Parser_AST.mk_binder (FStar_Parser_AST.Annotated ((((FStar_Syntax_Util.mangle_field_name x)), (t)))) x.FStar_Ident.idRange FStar_Parser_AST.Expr None)
end)) fields)
in (

let result = (let _166_863 = (let _166_862 = (let _166_861 = (FStar_Ident.lid_of_ids ((id)::[]))
in FStar_Parser_AST.Var (_166_861))
in (FStar_Parser_AST.mk_term _166_862 id.FStar_Ident.idRange FStar_Parser_AST.Type))
in (apply_binders _166_863 parms))
in (

let constrTyp = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (((mfields), ((with_constructor_effect result))))) id.FStar_Ident.idRange FStar_Parser_AST.Type)
in (let _166_865 = (FStar_All.pipe_right fields (FStar_List.map (fun _67_2240 -> (match (_67_2240) with
| (x, _67_2237, _67_2239) -> begin
(FStar_Syntax_Util.unmangle_field_name x)
end))))
in ((FStar_Parser_AST.TyconVariant (((id), (parms), (kopt), ((((constrName), (Some (constrTyp)), (None), (false)))::[])))), (_166_865)))))))
end
| _67_2242 -> begin
(failwith "impossible")
end))
in (

let desugar_abstract_tc = (fun quals _env mutuals _67_19 -> (match (_67_19) with
| FStar_Parser_AST.TyconAbstract (id, binders, kopt) -> begin
(

let _67_2256 = (typars_of_binders _env binders)
in (match (_67_2256) with
| (_env', typars) -> begin
(

let k = (match (kopt) with
| None -> begin
FStar_Syntax_Util.ktype
end
| Some (k) -> begin
(desugar_term _env' k)
end)
in (

let tconstr = (let _166_876 = (let _166_875 = (let _166_874 = (FStar_Ident.lid_of_ids ((id)::[]))
in FStar_Parser_AST.Var (_166_874))
in (FStar_Parser_AST.mk_term _166_875 id.FStar_Ident.idRange FStar_Parser_AST.Type))
in (apply_binders _166_876 binders))
in (

let qlid = (FStar_Parser_Env.qualify _env id)
in (

let typars = (FStar_Syntax_Subst.close_binders typars)
in (

let k = (FStar_Syntax_Subst.close typars k)
in (

let se = FStar_Syntax_Syntax.Sig_inductive_typ (((qlid), ([]), (typars), (k), (mutuals), ([]), (quals), (rng)))
in (

let _env = (FStar_Parser_Env.push_top_level_rec_binding _env id FStar_Syntax_Syntax.Delta_constant)
in (

let _env2 = (FStar_Parser_Env.push_top_level_rec_binding _env' id FStar_Syntax_Syntax.Delta_constant)
in ((_env), (_env2), (se), (tconstr))))))))))
end))
end
| _67_2269 -> begin
(failwith "Unexpected tycon")
end))
in (

let push_tparams = (fun env bs -> (

let _67_2284 = (FStar_List.fold_left (fun _67_2275 _67_2278 -> (match (((_67_2275), (_67_2278))) with
| ((env, tps), (x, imp)) -> begin
(

let _67_2281 = (FStar_Parser_Env.push_bv env x.FStar_Syntax_Syntax.ppname)
in (match (_67_2281) with
| (env, y) -> begin
((env), ((((y), (imp)))::tps))
end))
end)) ((env), ([])) bs)
in (match (_67_2284) with
| (env, bs) -> begin
((env), ((FStar_List.rev bs)))
end)))
in (match (tcs) with
| (FStar_Parser_AST.TyconAbstract (id, bs, kopt))::[] -> begin
(

let kopt = (match (kopt) with
| None -> begin
(let _166_883 = (tm_type_z id.FStar_Ident.idRange)
in Some (_166_883))
end
| _67_2293 -> begin
kopt
end)
in (

let tc = FStar_Parser_AST.TyconAbstract (((id), (bs), (kopt)))
in (

let _67_2303 = (desugar_abstract_tc quals env [] tc)
in (match (_67_2303) with
| (_67_2297, _67_2299, se, _67_2302) -> begin
(

let se = (match (se) with
| FStar_Syntax_Syntax.Sig_inductive_typ (l, _67_2306, typars, k, [], [], quals, rng) -> begin
(

let quals = if (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Assumption)) then begin
quals
end else begin
(

let _67_2315 = (let _166_885 = (FStar_Range.string_of_range rng)
in (let _166_884 = (FStar_Syntax_Print.lid_to_string l)
in (FStar_Util.print2 "%s (Warning): Adding an implicit \'assume new\' qualifier on %s\n" _166_885 _166_884)))
in (FStar_Syntax_Syntax.Assumption)::(FStar_Syntax_Syntax.New)::quals)
end
in (

let t = (match (typars) with
| [] -> begin
k
end
| _67_2320 -> begin
(let _166_888 = (let _166_887 = (let _166_886 = (FStar_Syntax_Syntax.mk_Total k)
in ((typars), (_166_886)))
in FStar_Syntax_Syntax.Tm_arrow (_166_887))
in (FStar_Syntax_Syntax.mk _166_888 None rng))
end)
in FStar_Syntax_Syntax.Sig_declare_typ (((l), ([]), (t), (quals), (rng)))))
end
| _67_2323 -> begin
se
end)
in (

let env = (FStar_Parser_Env.push_sigelt env se)
in ((env), ((se)::[]))))
end))))
end
| (FStar_Parser_AST.TyconAbbrev (id, binders, kopt, t))::[] -> begin
(

let _67_2335 = (typars_of_binders env binders)
in (match (_67_2335) with
| (env', typars) -> begin
(

let k = (match (kopt) with
| None -> begin
if (FStar_Util.for_some (fun _67_20 -> (match (_67_20) with
| FStar_Syntax_Syntax.Effect -> begin
true
end
| _67_2340 -> begin
false
end)) quals) then begin
FStar_Syntax_Syntax.teff
end else begin
FStar_Syntax_Syntax.tun
end
end
| Some (k) -> begin
(desugar_term env' k)
end)
in (

let t0 = t
in (

let quals = if (FStar_All.pipe_right quals (FStar_Util.for_some (fun _67_21 -> (match (_67_21) with
| FStar_Syntax_Syntax.Logic -> begin
true
end
| _67_2348 -> begin
false
end)))) then begin
quals
end else begin
if (t0.FStar_Parser_AST.level = FStar_Parser_AST.Formula) then begin
(FStar_Syntax_Syntax.Logic)::quals
end else begin
quals
end
end
in (

let se = if (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Effect)) then begin
(

let _67_2373 = (match ((let _166_891 = (unparen t)
in _166_891.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Construct (head, args) -> begin
(

let _67_2368 = (match ((FStar_List.rev args)) with
| ((last_arg, _67_2357))::args_rev -> begin
(match ((let _166_892 = (unparen last_arg)
in _166_892.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Attributes (ts) -> begin
((ts), ((FStar_List.rev args_rev)))
end
| _67_2363 -> begin
(([]), (args))
end)
end
| _67_2365 -> begin
(([]), (args))
end)
in (match (_67_2368) with
| (cattributes, args) -> begin
(let _166_893 = (desugar_attributes env cattributes)
in (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Construct (((head), (args)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)), (_166_893)))
end))
end
| _67_2370 -> begin
((t), ([]))
end)
in (match (_67_2373) with
| (t, cattributes) -> begin
(

let c = (desugar_comp t.FStar_Parser_AST.range false env' t)
in (

let typars = (FStar_Syntax_Subst.close_binders typars)
in (

let c = (FStar_Syntax_Subst.close_comp typars c)
in (let _166_897 = (let _166_896 = (FStar_Parser_Env.qualify env id)
in (let _166_895 = (FStar_All.pipe_right quals (FStar_List.filter (fun _67_22 -> (match (_67_22) with
| FStar_Syntax_Syntax.Effect -> begin
false
end
| _67_2380 -> begin
true
end))))
in ((_166_896), ([]), (typars), (c), (_166_895), ((FStar_List.append cattributes (FStar_Syntax_Util.comp_flags c))), (rng))))
in FStar_Syntax_Syntax.Sig_effect_abbrev (_166_897)))))
end))
end else begin
(

let t = (desugar_typ env' t)
in (

let nm = (FStar_Parser_Env.qualify env id)
in (mk_typ_abbrev nm [] typars k t ((nm)::[]) quals rng)))
end
in (

let env = (FStar_Parser_Env.push_sigelt env se)
in ((env), ((se)::[])))))))
end))
end
| (FStar_Parser_AST.TyconRecord (_67_2386))::[] -> begin
(

let trec = (FStar_List.hd tcs)
in (

let _67_2392 = (tycon_record_as_variant trec)
in (match (_67_2392) with
| (t, fs) -> begin
(let _166_902 = (let _166_901 = (let _166_900 = (let _166_899 = (let _166_898 = (FStar_Parser_Env.current_module env)
in (FStar_Ident.ids_of_lid _166_898))
in ((_166_899), (fs)))
in FStar_Syntax_Syntax.RecordType (_166_900))
in (_166_901)::quals)
in (desugar_tycon env rng _166_902 ((t)::[])))
end)))
end
| (_67_2396)::_67_2394 -> begin
(

let env0 = env
in (

let mutuals = (FStar_List.map (fun x -> (FStar_All.pipe_left (FStar_Parser_Env.qualify env) (tycon_id x))) tcs)
in (

let rec collect_tcs = (fun quals et tc -> (

let _67_2407 = et
in (match (_67_2407) with
| (env, tcs) -> begin
(match (tc) with
| FStar_Parser_AST.TyconRecord (_67_2409) -> begin
(

let trec = tc
in (

let _67_2414 = (tycon_record_as_variant trec)
in (match (_67_2414) with
| (t, fs) -> begin
(let _166_914 = (let _166_913 = (let _166_912 = (let _166_911 = (let _166_910 = (FStar_Parser_Env.current_module env)
in (FStar_Ident.ids_of_lid _166_910))
in ((_166_911), (fs)))
in FStar_Syntax_Syntax.RecordType (_166_912))
in (_166_913)::quals)
in (collect_tcs _166_914 ((env), (tcs)) t))
end)))
end
| FStar_Parser_AST.TyconVariant (id, binders, kopt, constructors) -> begin
(

let _67_2426 = (desugar_abstract_tc quals env mutuals (FStar_Parser_AST.TyconAbstract (((id), (binders), (kopt)))))
in (match (_67_2426) with
| (env, _67_2423, se, tconstr) -> begin
((env), ((FStar_Util.Inl (((se), (constructors), (tconstr), (quals))))::tcs))
end))
end
| FStar_Parser_AST.TyconAbbrev (id, binders, kopt, t) -> begin
(

let _67_2438 = (desugar_abstract_tc quals env mutuals (FStar_Parser_AST.TyconAbstract (((id), (binders), (kopt)))))
in (match (_67_2438) with
| (env, _67_2435, se, tconstr) -> begin
((env), ((FStar_Util.Inr (((se), (binders), (t), (quals))))::tcs))
end))
end
| _67_2440 -> begin
(failwith "Unrecognized mutual type definition")
end)
end)))
in (

let _67_2443 = (FStar_List.fold_left (collect_tcs quals) ((env), ([])) tcs)
in (match (_67_2443) with
| (env, tcs) -> begin
(

let tcs = (FStar_List.rev tcs)
in (

let tps_sigelts = (FStar_All.pipe_right tcs (FStar_List.collect (fun _67_24 -> (match (_67_24) with
| FStar_Util.Inr (FStar_Syntax_Syntax.Sig_inductive_typ (id, uvs, tpars, k, _67_2451, _67_2453, _67_2455, _67_2457), binders, t, quals) -> begin
(

let t = (

let _67_2467 = (typars_of_binders env binders)
in (match (_67_2467) with
| (env, tpars) -> begin
(

let _67_2470 = (push_tparams env tpars)
in (match (_67_2470) with
| (env_tps, tpars) -> begin
(

let t = (desugar_typ env_tps t)
in (

let tpars = (FStar_Syntax_Subst.close_binders tpars)
in (FStar_Syntax_Subst.close tpars t)))
end))
end))
in (let _166_917 = (let _166_916 = (mk_typ_abbrev id uvs tpars k t ((id)::[]) quals rng)
in (([]), (_166_916)))
in (_166_917)::[]))
end
| FStar_Util.Inl (FStar_Syntax_Syntax.Sig_inductive_typ (tname, univs, tpars, k, mutuals, _67_2480, tags, _67_2483), constrs, tconstr, quals) -> begin
(

let tycon = ((tname), (tpars), (k))
in (

let _67_2494 = (push_tparams env tpars)
in (match (_67_2494) with
| (env_tps, tps) -> begin
(

let data_tpars = (FStar_List.map (fun _67_2498 -> (match (_67_2498) with
| (x, _67_2497) -> begin
((x), (Some (FStar_Syntax_Syntax.Implicit (true))))
end)) tps)
in (

let _67_2524 = (let _166_929 = (FStar_All.pipe_right constrs (FStar_List.map (fun _67_2505 -> (match (_67_2505) with
| (id, topt, _67_2503, of_notation) -> begin
(

let t = if of_notation then begin
(match (topt) with
| Some (t) -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (((((FStar_Parser_AST.mk_binder (FStar_Parser_AST.NoName (t)) t.FStar_Parser_AST.range t.FStar_Parser_AST.level None))::[]), (tconstr)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
end
| None -> begin
tconstr
end)
end else begin
(match (topt) with
| None -> begin
(failwith "Impossible")
end
| Some (t) -> begin
t
end)
end
in (

let t = (let _166_921 = (FStar_Parser_Env.default_total env_tps)
in (let _166_920 = (close env_tps t)
in (desugar_term _166_921 _166_920)))
in (

let name = (FStar_Parser_Env.qualify env id)
in (

let quals = (FStar_All.pipe_right tags (FStar_List.collect (fun _67_23 -> (match (_67_23) with
| FStar_Syntax_Syntax.RecordType (fns) -> begin
(FStar_Syntax_Syntax.RecordConstructor (fns))::[]
end
| _67_2519 -> begin
[]
end))))
in (

let ntps = (FStar_List.length data_tpars)
in (let _166_928 = (let _166_927 = (let _166_926 = (let _166_925 = (let _166_924 = (let _166_923 = (FStar_All.pipe_right t FStar_Syntax_Util.name_function_binders)
in (FStar_Syntax_Syntax.mk_Total _166_923))
in (FStar_Syntax_Util.arrow data_tpars _166_924))
in ((name), (univs), (_166_925), (tname), (ntps), (quals), (mutuals), (rng)))
in FStar_Syntax_Syntax.Sig_datacon (_166_926))
in ((tps), (_166_927)))
in ((name), (_166_928))))))))
end))))
in (FStar_All.pipe_left FStar_List.split _166_929))
in (match (_67_2524) with
| (constrNames, constrs) -> begin
((([]), (FStar_Syntax_Syntax.Sig_inductive_typ (((tname), (univs), (tpars), (k), (mutuals), (constrNames), (tags), (rng))))))::constrs
end)))
end)))
end
| _67_2526 -> begin
(failwith "impossible")
end))))
in (

let sigelts = (FStar_All.pipe_right tps_sigelts (FStar_List.map Prims.snd))
in (

let _67_2531 = (let _166_930 = (FStar_List.collect FStar_Syntax_Util.lids_of_sigelt sigelts)
in (FStar_Syntax_MutRecTy.disentangle_abbrevs_from_bundle sigelts quals _166_930 rng))
in (match (_67_2531) with
| (bundle, abbrevs) -> begin
(

let env = (FStar_Parser_Env.push_sigelt env0 bundle)
in (

let env = (FStar_List.fold_left FStar_Parser_Env.push_sigelt env abbrevs)
in (

let data_ops = (FStar_All.pipe_right tps_sigelts (FStar_List.collect (mk_data_projector_names quals env)))
in (

let discs = (FStar_All.pipe_right sigelts (FStar_List.collect (fun _67_25 -> (match (_67_25) with
| FStar_Syntax_Syntax.Sig_inductive_typ (tname, _67_2538, tps, k, _67_2542, constrs, quals, _67_2546) when ((FStar_List.length constrs) > (Prims.parse_int "1")) -> begin
(

let quals = if (FStar_List.contains FStar_Syntax_Syntax.Abstract quals) then begin
(FStar_Syntax_Syntax.Private)::quals
end else begin
quals
end
in (mk_data_discriminators quals env tname tps k constrs))
end
| _67_2551 -> begin
[]
end))))
in (

let ops = (FStar_List.append discs data_ops)
in (

let env = (FStar_List.fold_left FStar_Parser_Env.push_sigelt env ops)
in ((env), ((FStar_List.append ((bundle)::[]) (FStar_List.append abbrevs ops))))))))))
end)))))
end)))))
end
| [] -> begin
(failwith "impossible")
end))))))))))


let desugar_binders : FStar_Parser_Env.env  ->  FStar_Parser_AST.binder Prims.list  ->  (FStar_Parser_Env.env * FStar_Syntax_Syntax.binder Prims.list) = (fun env binders -> (

let _67_2575 = (FStar_List.fold_left (fun _67_2560 b -> (match (_67_2560) with
| (env, binders) -> begin
(match ((desugar_binder env b)) with
| (Some (a), k) -> begin
(

let _67_2568 = (FStar_Parser_Env.push_bv env a)
in (match (_67_2568) with
| (env, a) -> begin
(let _166_939 = (let _166_938 = (FStar_Syntax_Syntax.mk_binder (

let _67_2569 = a
in {FStar_Syntax_Syntax.ppname = _67_2569.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = _67_2569.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = k}))
in (_166_938)::binders)
in ((env), (_166_939)))
end))
end
| _67_2572 -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Missing name in binder"), (b.FStar_Parser_AST.brange)))))
end)
end)) ((env), ([])) binders)
in (match (_67_2575) with
| (env, binders) -> begin
((env), ((FStar_List.rev binders)))
end)))


let rec desugar_effect : FStar_Parser_Env.env  ->  FStar_Parser_AST.decl  ->  FStar_Parser_AST.qualifiers  ->  FStar_Ident.ident  ->  FStar_Parser_AST.binder Prims.list  ->  FStar_Parser_AST.term  ->  FStar_Parser_AST.decl Prims.list  ->  FStar_Parser_AST.decl Prims.list  ->  Prims.bool  ->  (FStar_Parser_Env.env * FStar_Syntax_Syntax.sigelt Prims.list) = (fun env d quals eff_name eff_binders eff_kind eff_decls actions for_free -> (

let env0 = env
in (

let monad_env = (FStar_Parser_Env.enter_monad_scope env eff_name)
in (

let _67_2589 = (desugar_binders monad_env eff_binders)
in (match (_67_2589) with
| (env, binders) -> begin
(

let eff_k = (let _166_977 = (FStar_Parser_Env.default_total env)
in (desugar_term _166_977 eff_kind))
in (

let _67_2600 = (FStar_All.pipe_right eff_decls (FStar_List.fold_left (fun _67_2593 decl -> (match (_67_2593) with
| (env, out) -> begin
(

let _67_2597 = (desugar_decl env decl)
in (match (_67_2597) with
| (env, ses) -> begin
(let _166_981 = (let _166_980 = (FStar_List.hd ses)
in (_166_980)::out)
in ((env), (_166_981)))
end))
end)) ((env), ([]))))
in (match (_67_2600) with
| (env, decls) -> begin
(

let binders = (FStar_Syntax_Subst.close_binders binders)
in (

let actions = (FStar_All.pipe_right actions (FStar_List.map (fun d -> (match (d.FStar_Parser_AST.d) with
| FStar_Parser_AST.Tycon (_67_2604, ((FStar_Parser_AST.TyconAbbrev (name, _67_2607, _67_2609, {FStar_Parser_AST.tm = FStar_Parser_AST.Construct (_67_2615, ((def, _67_2622))::((cps_type, _67_2618))::[]); FStar_Parser_AST.range = _67_2613; FStar_Parser_AST.level = _67_2611}), _67_2631))::[]) when (not (for_free)) -> begin
(let _166_987 = (FStar_Parser_Env.qualify env name)
in (let _166_986 = (let _166_983 = (desugar_term env def)
in (FStar_Syntax_Subst.close binders _166_983))
in (let _166_985 = (let _166_984 = (desugar_typ env cps_type)
in (FStar_Syntax_Subst.close binders _166_984))
in {FStar_Syntax_Syntax.action_name = _166_987; FStar_Syntax_Syntax.action_unqualified_name = name; FStar_Syntax_Syntax.action_univs = []; FStar_Syntax_Syntax.action_defn = _166_986; FStar_Syntax_Syntax.action_typ = _166_985})))
end
| FStar_Parser_AST.Tycon (_67_2637, ((FStar_Parser_AST.TyconAbbrev (name, _67_2640, _67_2642, defn), _67_2647))::[]) when for_free -> begin
(let _166_990 = (FStar_Parser_Env.qualify env name)
in (let _166_989 = (let _166_988 = (desugar_term env defn)
in (FStar_Syntax_Subst.close binders _166_988))
in {FStar_Syntax_Syntax.action_name = _166_990; FStar_Syntax_Syntax.action_unqualified_name = name; FStar_Syntax_Syntax.action_univs = []; FStar_Syntax_Syntax.action_defn = _166_989; FStar_Syntax_Syntax.action_typ = FStar_Syntax_Syntax.tun}))
end
| _67_2653 -> begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Malformed action declaration; if this is an \"effect for free\", just provide the direct-style declaration. If this is not an \"effect for free\", please provide a pair of the definition and its cps-type with arrows inserted in the right place (see examples)."), (d.FStar_Parser_AST.drange)))))
end))))
in (

let eff_k = (FStar_Syntax_Subst.close binders eff_k)
in (

let lookup = (fun s -> (

let l = (FStar_Parser_Env.qualify env (FStar_Ident.mk_ident ((s), (d.FStar_Parser_AST.drange))))
in (let _166_994 = (let _166_993 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_definition env) l)
in (FStar_All.pipe_left (FStar_Syntax_Subst.close binders) _166_993))
in (([]), (_166_994)))))
in (

let mname = (FStar_Parser_Env.qualify env0 eff_name)
in (

let qualifiers = (FStar_List.map (trans_qual d.FStar_Parser_AST.drange (Some (mname))) quals)
in (

let se = if for_free then begin
(

let dummy_tscheme = (let _166_995 = (FStar_Syntax_Syntax.mk FStar_Syntax_Syntax.Tm_unknown None FStar_Range.dummyRange)
in (([]), (_166_995)))
in (let _166_1001 = (let _166_1000 = (let _166_999 = (let _166_996 = (lookup "repr")
in (Prims.snd _166_996))
in (let _166_998 = (lookup "return")
in (let _166_997 = (lookup "bind")
in {FStar_Syntax_Syntax.qualifiers = qualifiers; FStar_Syntax_Syntax.cattributes = []; FStar_Syntax_Syntax.mname = mname; FStar_Syntax_Syntax.univs = []; FStar_Syntax_Syntax.binders = binders; FStar_Syntax_Syntax.signature = eff_k; FStar_Syntax_Syntax.ret_wp = dummy_tscheme; FStar_Syntax_Syntax.bind_wp = dummy_tscheme; FStar_Syntax_Syntax.if_then_else = dummy_tscheme; FStar_Syntax_Syntax.ite_wp = dummy_tscheme; FStar_Syntax_Syntax.stronger = dummy_tscheme; FStar_Syntax_Syntax.close_wp = dummy_tscheme; FStar_Syntax_Syntax.assert_p = dummy_tscheme; FStar_Syntax_Syntax.assume_p = dummy_tscheme; FStar_Syntax_Syntax.null_wp = dummy_tscheme; FStar_Syntax_Syntax.trivial = dummy_tscheme; FStar_Syntax_Syntax.repr = _166_999; FStar_Syntax_Syntax.return_repr = _166_998; FStar_Syntax_Syntax.bind_repr = _166_997; FStar_Syntax_Syntax.actions = actions})))
in ((_166_1000), (d.FStar_Parser_AST.drange)))
in FStar_Syntax_Syntax.Sig_new_effect_for_free (_166_1001)))
end else begin
(

let rr = ((FStar_All.pipe_right qualifiers (FStar_List.contains FStar_Syntax_Syntax.Reifiable)) || (FStar_All.pipe_right qualifiers FStar_Syntax_Syntax.contains_reflectable))
in (

let un_ts = (([]), (FStar_Syntax_Syntax.tun))
in (let _166_1017 = (let _166_1016 = (let _166_1015 = (lookup "return_wp")
in (let _166_1014 = (lookup "bind_wp")
in (let _166_1013 = (lookup "if_then_else")
in (let _166_1012 = (lookup "ite_wp")
in (let _166_1011 = (lookup "stronger")
in (let _166_1010 = (lookup "close_wp")
in (let _166_1009 = (lookup "assert_p")
in (let _166_1008 = (lookup "assume_p")
in (let _166_1007 = (lookup "null_wp")
in (let _166_1006 = (lookup "trivial")
in (let _166_1005 = if rr then begin
(let _166_1002 = (lookup "repr")
in (FStar_All.pipe_left Prims.snd _166_1002))
end else begin
FStar_Syntax_Syntax.tun
end
in (let _166_1004 = if rr then begin
(lookup "return")
end else begin
un_ts
end
in (let _166_1003 = if rr then begin
(lookup "bind")
end else begin
un_ts
end
in {FStar_Syntax_Syntax.qualifiers = qualifiers; FStar_Syntax_Syntax.cattributes = []; FStar_Syntax_Syntax.mname = mname; FStar_Syntax_Syntax.univs = []; FStar_Syntax_Syntax.binders = binders; FStar_Syntax_Syntax.signature = eff_k; FStar_Syntax_Syntax.ret_wp = _166_1015; FStar_Syntax_Syntax.bind_wp = _166_1014; FStar_Syntax_Syntax.if_then_else = _166_1013; FStar_Syntax_Syntax.ite_wp = _166_1012; FStar_Syntax_Syntax.stronger = _166_1011; FStar_Syntax_Syntax.close_wp = _166_1010; FStar_Syntax_Syntax.assert_p = _166_1009; FStar_Syntax_Syntax.assume_p = _166_1008; FStar_Syntax_Syntax.null_wp = _166_1007; FStar_Syntax_Syntax.trivial = _166_1006; FStar_Syntax_Syntax.repr = _166_1005; FStar_Syntax_Syntax.return_repr = _166_1004; FStar_Syntax_Syntax.bind_repr = _166_1003; FStar_Syntax_Syntax.actions = actions})))))))))))))
in ((_166_1016), (d.FStar_Parser_AST.drange)))
in FStar_Syntax_Syntax.Sig_new_effect (_166_1017))))
end
in (

let env = (FStar_Parser_Env.push_sigelt env0 se)
in (

let env = (FStar_All.pipe_right actions (FStar_List.fold_left (fun env a -> (let _166_1020 = (FStar_Syntax_Util.action_as_lb mname a)
in (FStar_Parser_Env.push_sigelt env _166_1020))) env))
in (

let env = if (FStar_All.pipe_right quals (FStar_List.contains FStar_Parser_AST.Reflectable)) then begin
(

let reflect_lid = (FStar_All.pipe_right (FStar_Ident.id_of_text "reflect") (FStar_Parser_Env.qualify monad_env))
in (

let refl_decl = FStar_Syntax_Syntax.Sig_declare_typ (((reflect_lid), ([]), (FStar_Syntax_Syntax.tun), ((FStar_Syntax_Syntax.Assumption)::(FStar_Syntax_Syntax.Reflectable (mname))::[]), (d.FStar_Parser_AST.drange)))
in (FStar_Parser_Env.push_sigelt env refl_decl)))
end else begin
env
end
in ((env), ((se)::[]))))))))))))
end)))
end)))))
and desugar_redefine_effect : FStar_Parser_Env.env  ->  FStar_Parser_AST.decl  ->  (FStar_Ident.lident Prims.option  ->  FStar_Parser_AST.qualifier  ->  FStar_Syntax_Syntax.qualifier)  ->  FStar_Parser_AST.qualifier Prims.list  ->  FStar_Ident.ident  ->  FStar_Parser_AST.binder Prims.list  ->  FStar_Parser_AST.term  ->  (FStar_Syntax_Syntax.eff_decl  ->  FStar_Range.range  ->  FStar_Syntax_Syntax.sigelt)  ->  (FStar_Parser_Env.env * FStar_Syntax_Syntax.sigelt Prims.list) = (fun env d trans_qual quals eff_name eff_binders defn build_sigelt -> (

let env0 = env
in (

let env = (FStar_Parser_Env.enter_monad_scope env eff_name)
in (

let _67_2684 = (desugar_binders env eff_binders)
in (match (_67_2684) with
| (env, binders) -> begin
(

let _67_2711 = (

let _67_2687 = (head_and_args defn)
in (match (_67_2687) with
| (head, args) -> begin
(

let ed = (match (head.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Name (l) -> begin
(FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_effect_defn env) l)
end
| _67_2691 -> begin
(let _166_1047 = (let _166_1046 = (let _166_1045 = (let _166_1044 = (let _166_1043 = (FStar_Parser_AST.term_to_string head)
in (Prims.strcat _166_1043 " not found"))
in (Prims.strcat "Effect " _166_1044))
in ((_166_1045), (d.FStar_Parser_AST.drange)))
in FStar_Syntax_Syntax.Error (_166_1046))
in (Prims.raise _166_1047))
end)
in (

let _67_2707 = (match ((FStar_List.rev args)) with
| ((last_arg, _67_2696))::args_rev -> begin
(match ((let _166_1048 = (unparen last_arg)
in _166_1048.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Attributes (ts) -> begin
((ts), ((FStar_List.rev args_rev)))
end
| _67_2702 -> begin
(([]), (args))
end)
end
| _67_2704 -> begin
(([]), (args))
end)
in (match (_67_2707) with
| (cattributes, args) -> begin
(let _166_1050 = (desugar_args env args)
in (let _166_1049 = (desugar_attributes env cattributes)
in ((ed), (_166_1050), (_166_1049))))
end)))
end))
in (match (_67_2711) with
| (ed, args, cattributes) -> begin
(

let binders = (FStar_Syntax_Subst.close_binders binders)
in (

let sub = (fun _67_2717 -> (match (_67_2717) with
| (_67_2715, x) -> begin
(

let _67_2720 = (FStar_Syntax_Subst.open_term ed.FStar_Syntax_Syntax.binders x)
in (match (_67_2720) with
| (edb, x) -> begin
(

let _67_2721 = if ((FStar_List.length args) <> (FStar_List.length edb)) then begin
(Prims.raise (FStar_Syntax_Syntax.Error ((("Unexpected number of arguments to effect constructor"), (defn.FStar_Parser_AST.range)))))
end else begin
()
end
in (

let s = (FStar_Syntax_Util.subst_of_list edb args)
in (let _166_1054 = (let _166_1053 = (FStar_Syntax_Subst.subst s x)
in (FStar_Syntax_Subst.close binders _166_1053))
in (([]), (_166_1054)))))
end))
end))
in (

let mname = (FStar_Parser_Env.qualify env0 eff_name)
in (

let ed = (let _166_1079 = (let _166_1055 = (trans_qual (Some (mname)))
in (FStar_List.map _166_1055 quals))
in (let _166_1078 = (let _166_1056 = (sub (([]), (ed.FStar_Syntax_Syntax.signature)))
in (Prims.snd _166_1056))
in (let _166_1077 = (sub ed.FStar_Syntax_Syntax.ret_wp)
in (let _166_1076 = (sub ed.FStar_Syntax_Syntax.bind_wp)
in (let _166_1075 = (sub ed.FStar_Syntax_Syntax.if_then_else)
in (let _166_1074 = (sub ed.FStar_Syntax_Syntax.ite_wp)
in (let _166_1073 = (sub ed.FStar_Syntax_Syntax.stronger)
in (let _166_1072 = (sub ed.FStar_Syntax_Syntax.close_wp)
in (let _166_1071 = (sub ed.FStar_Syntax_Syntax.assert_p)
in (let _166_1070 = (sub ed.FStar_Syntax_Syntax.assume_p)
in (let _166_1069 = (sub ed.FStar_Syntax_Syntax.null_wp)
in (let _166_1068 = (sub ed.FStar_Syntax_Syntax.trivial)
in (let _166_1067 = (let _166_1057 = (sub (([]), (ed.FStar_Syntax_Syntax.repr)))
in (Prims.snd _166_1057))
in (let _166_1066 = (sub ed.FStar_Syntax_Syntax.return_repr)
in (let _166_1065 = (sub ed.FStar_Syntax_Syntax.bind_repr)
in (let _166_1064 = (FStar_List.map (fun action -> (let _166_1063 = (FStar_Parser_Env.qualify env action.FStar_Syntax_Syntax.action_unqualified_name)
in (let _166_1062 = (let _166_1059 = (sub (([]), (action.FStar_Syntax_Syntax.action_defn)))
in (Prims.snd _166_1059))
in (let _166_1061 = (let _166_1060 = (sub (([]), (action.FStar_Syntax_Syntax.action_typ)))
in (Prims.snd _166_1060))
in {FStar_Syntax_Syntax.action_name = _166_1063; FStar_Syntax_Syntax.action_unqualified_name = action.FStar_Syntax_Syntax.action_unqualified_name; FStar_Syntax_Syntax.action_univs = action.FStar_Syntax_Syntax.action_univs; FStar_Syntax_Syntax.action_defn = _166_1062; FStar_Syntax_Syntax.action_typ = _166_1061})))) ed.FStar_Syntax_Syntax.actions)
in {FStar_Syntax_Syntax.qualifiers = _166_1079; FStar_Syntax_Syntax.cattributes = cattributes; FStar_Syntax_Syntax.mname = mname; FStar_Syntax_Syntax.univs = []; FStar_Syntax_Syntax.binders = binders; FStar_Syntax_Syntax.signature = _166_1078; FStar_Syntax_Syntax.ret_wp = _166_1077; FStar_Syntax_Syntax.bind_wp = _166_1076; FStar_Syntax_Syntax.if_then_else = _166_1075; FStar_Syntax_Syntax.ite_wp = _166_1074; FStar_Syntax_Syntax.stronger = _166_1073; FStar_Syntax_Syntax.close_wp = _166_1072; FStar_Syntax_Syntax.assert_p = _166_1071; FStar_Syntax_Syntax.assume_p = _166_1070; FStar_Syntax_Syntax.null_wp = _166_1069; FStar_Syntax_Syntax.trivial = _166_1068; FStar_Syntax_Syntax.repr = _166_1067; FStar_Syntax_Syntax.return_repr = _166_1066; FStar_Syntax_Syntax.bind_repr = _166_1065; FStar_Syntax_Syntax.actions = _166_1064}))))))))))))))))
in (

let se = (build_sigelt ed d.FStar_Parser_AST.drange)
in (

let monad_env = env
in (

let env = (FStar_Parser_Env.push_sigelt env0 se)
in (

let env = (FStar_All.pipe_right ed.FStar_Syntax_Syntax.actions (FStar_List.fold_left (fun env a -> (let _166_1082 = (FStar_Syntax_Util.action_as_lb mname a)
in (FStar_Parser_Env.push_sigelt env _166_1082))) env))
in (

let env = if (FStar_All.pipe_right quals (FStar_List.contains FStar_Parser_AST.Reflectable)) then begin
(

let reflect_lid = (FStar_All.pipe_right (FStar_Ident.id_of_text "reflect") (FStar_Parser_Env.qualify monad_env))
in (

let refl_decl = FStar_Syntax_Syntax.Sig_declare_typ (((reflect_lid), ([]), (FStar_Syntax_Syntax.tun), ((FStar_Syntax_Syntax.Assumption)::(FStar_Syntax_Syntax.Reflectable (mname))::[]), (d.FStar_Parser_AST.drange)))
in (FStar_Parser_Env.push_sigelt env refl_decl)))
end else begin
env
end
in ((env), ((se)::[])))))))))))
end))
end)))))
and desugar_decl : env_t  ->  FStar_Parser_AST.decl  ->  (env_t * FStar_Syntax_Syntax.sigelts) = (fun env d -> (

let trans_qual = (trans_qual d.FStar_Parser_AST.drange)
in (match (d.FStar_Parser_AST.d) with
| FStar_Parser_AST.Pragma (p) -> begin
(

let se = FStar_Syntax_Syntax.Sig_pragma ((((trans_pragma p)), (d.FStar_Parser_AST.drange)))
in ((env), ((se)::[])))
end
| FStar_Parser_AST.Fsdoc (_67_2743) -> begin
((env), ([]))
end
| FStar_Parser_AST.TopLevelModule (id) -> begin
((env), ([]))
end
| FStar_Parser_AST.Open (lid) -> begin
(

let env = (FStar_Parser_Env.push_namespace env lid)
in ((env), ([])))
end
| FStar_Parser_AST.Include (lid) -> begin
(

let env = (FStar_Parser_Env.push_include env lid)
in ((env), ([])))
end
| FStar_Parser_AST.ModuleAbbrev (x, l) -> begin
(let _166_1087 = (FStar_Parser_Env.push_module_abbrev env x l)
in ((_166_1087), ([])))
end
| FStar_Parser_AST.Tycon (is_effect, tcs) -> begin
(

let quals = if is_effect then begin
(FStar_Parser_AST.Effect)::d.FStar_Parser_AST.quals
end else begin
d.FStar_Parser_AST.quals
end
in (

let tcs = (FStar_List.map (fun _67_2765 -> (match (_67_2765) with
| (x, _67_2764) -> begin
x
end)) tcs)
in (let _166_1089 = (FStar_List.map (trans_qual None) quals)
in (desugar_tycon env d.FStar_Parser_AST.drange _166_1089 tcs))))
end
| FStar_Parser_AST.TopLevelLet (isrec, lets) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (

let attrs = d.FStar_Parser_AST.attrs
in (

let attrs = (FStar_List.map (desugar_term env) attrs)
in (match ((let _166_1091 = (let _166_1090 = (desugar_term_maybe_top true env (FStar_Parser_AST.mk_term (FStar_Parser_AST.Let (((isrec), (lets), ((FStar_Parser_AST.mk_term (FStar_Parser_AST.Const (FStar_Const.Const_unit)) d.FStar_Parser_AST.drange FStar_Parser_AST.Expr))))) d.FStar_Parser_AST.drange FStar_Parser_AST.Expr))
in (FStar_All.pipe_left FStar_Syntax_Subst.compress _166_1090))
in _166_1091.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_let (lbs, _67_2776) -> begin
(

let fvs = (FStar_All.pipe_right (Prims.snd lbs) (FStar_List.map (fun lb -> (FStar_Util.right lb.FStar_Syntax_Syntax.lbname))))
in (

let quals = (match (quals) with
| (_67_2784)::_67_2782 -> begin
(FStar_List.map (trans_qual None) quals)
end
| _67_2787 -> begin
(FStar_All.pipe_right (Prims.snd lbs) (FStar_List.collect (fun _67_26 -> (match (_67_26) with
| {FStar_Syntax_Syntax.lbname = FStar_Util.Inl (_67_2798); FStar_Syntax_Syntax.lbunivs = _67_2796; FStar_Syntax_Syntax.lbtyp = _67_2794; FStar_Syntax_Syntax.lbeff = _67_2792; FStar_Syntax_Syntax.lbdef = _67_2790} -> begin
[]
end
| {FStar_Syntax_Syntax.lbname = FStar_Util.Inr (fv); FStar_Syntax_Syntax.lbunivs = _67_2808; FStar_Syntax_Syntax.lbtyp = _67_2806; FStar_Syntax_Syntax.lbeff = _67_2804; FStar_Syntax_Syntax.lbdef = _67_2802} -> begin
(FStar_Parser_Env.lookup_letbinding_quals env fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)
end))))
end)
in (

let quals = if (FStar_All.pipe_right lets (FStar_Util.for_some (fun _67_2816 -> (match (_67_2816) with
| (_67_2814, t) -> begin
(t.FStar_Parser_AST.level = FStar_Parser_AST.Formula)
end)))) then begin
(FStar_Syntax_Syntax.Logic)::quals
end else begin
quals
end
in (

let lbs = if (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Abstract)) then begin
(let _166_1096 = (FStar_All.pipe_right (Prims.snd lbs) (FStar_List.map (fun lb -> (

let fv = (FStar_Util.right lb.FStar_Syntax_Syntax.lbname)
in (

let _67_2820 = lb
in {FStar_Syntax_Syntax.lbname = FStar_Util.Inr ((

let _67_2822 = fv
in {FStar_Syntax_Syntax.fv_name = _67_2822.FStar_Syntax_Syntax.fv_name; FStar_Syntax_Syntax.fv_delta = FStar_Syntax_Syntax.Delta_abstract (fv.FStar_Syntax_Syntax.fv_delta); FStar_Syntax_Syntax.fv_qual = _67_2822.FStar_Syntax_Syntax.fv_qual})); FStar_Syntax_Syntax.lbunivs = _67_2820.FStar_Syntax_Syntax.lbunivs; FStar_Syntax_Syntax.lbtyp = _67_2820.FStar_Syntax_Syntax.lbtyp; FStar_Syntax_Syntax.lbeff = _67_2820.FStar_Syntax_Syntax.lbeff; FStar_Syntax_Syntax.lbdef = _67_2820.FStar_Syntax_Syntax.lbdef})))))
in (((Prims.fst lbs)), (_166_1096)))
end else begin
lbs
end
in (

let s = (let _166_1099 = (let _166_1098 = (FStar_All.pipe_right fvs (FStar_List.map (fun fv -> fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)))
in ((lbs), (d.FStar_Parser_AST.drange), (_166_1098), (quals), (attrs)))
in FStar_Syntax_Syntax.Sig_let (_166_1099))
in (

let env = (FStar_Parser_Env.push_sigelt env s)
in ((env), ((s)::[]))))))))
end
| _67_2829 -> begin
(failwith "Desugaring a let did not produce a let")
end))))
end
| FStar_Parser_AST.Main (t) -> begin
(

let e = (desugar_term env t)
in (

let se = FStar_Syntax_Syntax.Sig_main (((e), (d.FStar_Parser_AST.drange)))
in ((env), ((se)::[]))))
end
| FStar_Parser_AST.Assume (id, t) -> begin
(

let f = (desugar_formula env t)
in (let _166_1103 = (let _166_1102 = (let _166_1101 = (let _166_1100 = (FStar_Parser_Env.qualify env id)
in ((_166_1100), (f), ((FStar_Syntax_Syntax.Assumption)::[]), (d.FStar_Parser_AST.drange)))
in FStar_Syntax_Syntax.Sig_assume (_166_1101))
in (_166_1102)::[])
in ((env), (_166_1103))))
end
| FStar_Parser_AST.Val (id, t) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (

let t = (let _166_1104 = (close_fun env t)
in (desugar_term env _166_1104))
in (

let quals = if (env.FStar_Parser_Env.iface && env.FStar_Parser_Env.admitted_iface) then begin
(FStar_Parser_AST.Assumption)::quals
end else begin
quals
end
in (

let se = (let _166_1107 = (let _166_1106 = (FStar_Parser_Env.qualify env id)
in (let _166_1105 = (FStar_List.map (trans_qual None) quals)
in ((_166_1106), ([]), (t), (_166_1105), (d.FStar_Parser_AST.drange))))
in FStar_Syntax_Syntax.Sig_declare_typ (_166_1107))
in (

let env = (FStar_Parser_Env.push_sigelt env se)
in ((env), ((se)::[])))))))
end
| FStar_Parser_AST.Exception (id, None) -> begin
(

let _67_2855 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_lid env) FStar_Syntax_Const.exn_lid)
in (match (_67_2855) with
| (t, _67_2854) -> begin
(

let l = (FStar_Parser_Env.qualify env id)
in (

let se = FStar_Syntax_Syntax.Sig_datacon (((l), ([]), (t), (FStar_Syntax_Const.exn_lid), ((Prims.parse_int "0")), ((FStar_Syntax_Syntax.ExceptionConstructor)::[]), ((FStar_Syntax_Const.exn_lid)::[]), (d.FStar_Parser_AST.drange)))
in (

let se' = FStar_Syntax_Syntax.Sig_bundle ((((se)::[]), ((FStar_Syntax_Syntax.ExceptionConstructor)::[]), ((l)::[]), (d.FStar_Parser_AST.drange)))
in (

let env = (FStar_Parser_Env.push_sigelt env se')
in (

let data_ops = (mk_data_projector_names [] env (([]), (se)))
in (

let discs = (mk_data_discriminators [] env FStar_Syntax_Const.exn_lid [] FStar_Syntax_Syntax.tun ((l)::[]))
in (

let env = (FStar_List.fold_left FStar_Parser_Env.push_sigelt env (FStar_List.append discs data_ops))
in ((env), ((FStar_List.append ((se')::discs) data_ops))))))))))
end))
end
| FStar_Parser_AST.Exception (id, Some (term)) -> begin
(

let t = (desugar_term env term)
in (

let t = (let _166_1112 = (let _166_1108 = (FStar_Syntax_Syntax.null_binder t)
in (_166_1108)::[])
in (let _166_1111 = (let _166_1110 = (let _166_1109 = (FStar_Parser_Env.fail_or env (FStar_Parser_Env.try_lookup_lid env) FStar_Syntax_Const.exn_lid)
in (Prims.fst _166_1109))
in (FStar_All.pipe_left FStar_Syntax_Syntax.mk_Total _166_1110))
in (FStar_Syntax_Util.arrow _166_1112 _166_1111)))
in (

let l = (FStar_Parser_Env.qualify env id)
in (

let se = FStar_Syntax_Syntax.Sig_datacon (((l), ([]), (t), (FStar_Syntax_Const.exn_lid), ((Prims.parse_int "0")), ((FStar_Syntax_Syntax.ExceptionConstructor)::[]), ((FStar_Syntax_Const.exn_lid)::[]), (d.FStar_Parser_AST.drange)))
in (

let se' = FStar_Syntax_Syntax.Sig_bundle ((((se)::[]), ((FStar_Syntax_Syntax.ExceptionConstructor)::[]), ((l)::[]), (d.FStar_Parser_AST.drange)))
in (

let env = (FStar_Parser_Env.push_sigelt env se')
in (

let data_ops = (mk_data_projector_names [] env (([]), (se)))
in (

let discs = (mk_data_discriminators [] env FStar_Syntax_Const.exn_lid [] FStar_Syntax_Syntax.tun ((l)::[]))
in (

let env = (FStar_List.fold_left FStar_Parser_Env.push_sigelt env (FStar_List.append discs data_ops))
in ((env), ((FStar_List.append ((se')::discs) data_ops))))))))))))
end
| FStar_Parser_AST.KindAbbrev (id, binders, k) -> begin
(

let _67_2884 = (desugar_binders env binders)
in (match (_67_2884) with
| (env_k, binders) -> begin
(

let k = (desugar_term env_k k)
in (

let name = (FStar_Parser_Env.qualify env id)
in (

let se = (mk_typ_abbrev name [] binders FStar_Syntax_Syntax.tun k ((name)::[]) [] d.FStar_Parser_AST.drange)
in (

let env = (FStar_Parser_Env.push_sigelt env se)
in ((env), ((se)::[]))))))
end))
end
| FStar_Parser_AST.NewEffect (FStar_Parser_AST.RedefineEffect (eff_name, eff_binders, defn)) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (desugar_redefine_effect env d trans_qual quals eff_name eff_binders defn (fun ed range -> FStar_Syntax_Syntax.Sig_new_effect (((ed), (range))))))
end
| FStar_Parser_AST.NewEffectForFree (FStar_Parser_AST.RedefineEffect (eff_name, eff_binders, defn)) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (desugar_redefine_effect env d trans_qual quals eff_name eff_binders defn (fun ed range -> FStar_Syntax_Syntax.Sig_new_effect_for_free (((ed), (range))))))
end
| FStar_Parser_AST.NewEffectForFree (FStar_Parser_AST.DefineEffect (eff_name, eff_binders, eff_kind, eff_decls, actions)) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (desugar_effect env d quals eff_name eff_binders eff_kind eff_decls actions true))
end
| FStar_Parser_AST.NewEffect (FStar_Parser_AST.DefineEffect (eff_name, eff_binders, eff_kind, eff_decls, actions)) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (desugar_effect env d quals eff_name eff_binders eff_kind eff_decls actions false))
end
| FStar_Parser_AST.SubEffect (l) -> begin
(

let lookup = (fun l -> (match ((FStar_Parser_Env.try_lookup_effect_name env l)) with
| None -> begin
(let _166_1123 = (let _166_1122 = (let _166_1121 = (let _166_1120 = (let _166_1119 = (FStar_Syntax_Print.lid_to_string l)
in (Prims.strcat _166_1119 " not found"))
in (Prims.strcat "Effect name " _166_1120))
in ((_166_1121), (d.FStar_Parser_AST.drange)))
in FStar_Syntax_Syntax.Error (_166_1122))
in (Prims.raise _166_1123))
end
| Some (l) -> begin
l
end))
in (

let src = (lookup l.FStar_Parser_AST.msource)
in (

let dst = (lookup l.FStar_Parser_AST.mdest)
in (

let _67_2944 = (match (l.FStar_Parser_AST.lift_op) with
| FStar_Parser_AST.NonReifiableLift (t) -> begin
(let _166_1126 = (let _166_1125 = (let _166_1124 = (desugar_term env t)
in (([]), (_166_1124)))
in Some (_166_1125))
in ((_166_1126), (None)))
end
| FStar_Parser_AST.ReifiableLift (wp, t) -> begin
(let _166_1132 = (let _166_1128 = (let _166_1127 = (desugar_term env wp)
in (([]), (_166_1127)))
in Some (_166_1128))
in (let _166_1131 = (let _166_1130 = (let _166_1129 = (desugar_term env t)
in (([]), (_166_1129)))
in Some (_166_1130))
in ((_166_1132), (_166_1131))))
end
| FStar_Parser_AST.LiftForFree (t) -> begin
(let _166_1135 = (let _166_1134 = (let _166_1133 = (desugar_term env t)
in (([]), (_166_1133)))
in Some (_166_1134))
in ((None), (_166_1135)))
end)
in (match (_67_2944) with
| (lift_wp, lift) -> begin
(

let se = FStar_Syntax_Syntax.Sig_sub_effect ((({FStar_Syntax_Syntax.source = src; FStar_Syntax_Syntax.target = dst; FStar_Syntax_Syntax.lift_wp = lift_wp; FStar_Syntax_Syntax.lift = lift}), (d.FStar_Parser_AST.drange)))
in ((env), ((se)::[])))
end)))))
end)))


let desugar_decls : FStar_Parser_Env.env  ->  FStar_Parser_AST.decl Prims.list  ->  (FStar_Parser_Env.env * FStar_Syntax_Syntax.sigelts) = (fun env decls -> (FStar_List.fold_left (fun _67_2950 d -> (match (_67_2950) with
| (env, sigelts) -> begin
(

let _67_2954 = (desugar_decl env d)
in (match (_67_2954) with
| (env, se) -> begin
((env), ((FStar_List.append sigelts se)))
end))
end)) ((env), ([])) decls))


let open_prims_all : (FStar_Parser_AST.decoration Prims.list  ->  FStar_Parser_AST.decl) Prims.list = ((FStar_Parser_AST.mk_decl (FStar_Parser_AST.Open (FStar_Syntax_Const.prims_lid)) FStar_Range.dummyRange))::((FStar_Parser_AST.mk_decl (FStar_Parser_AST.Open (FStar_Syntax_Const.all_lid)) FStar_Range.dummyRange))::[]


let desugar_modul_common : FStar_Syntax_Syntax.modul Prims.option  ->  FStar_Parser_Env.env  ->  FStar_Parser_AST.modul  ->  (env_t * FStar_Syntax_Syntax.modul * Prims.bool) = (fun curmod env m -> (

let env = (match (curmod) with
| None -> begin
env
end
| Some (prev_mod) -> begin
(FStar_Parser_Env.finish_module_or_interface env prev_mod)
end)
in (

let _67_2977 = (match (m) with
| FStar_Parser_AST.Interface (mname, decls, admitted) -> begin
(let _166_1153 = (FStar_Parser_Env.prepare_module_or_interface true admitted env mname)
in ((_166_1153), (mname), (decls), (true)))
end
| FStar_Parser_AST.Module (mname, decls) -> begin
(let _166_1154 = (FStar_Parser_Env.prepare_module_or_interface false false env mname)
in ((_166_1154), (mname), (decls), (false)))
end)
in (match (_67_2977) with
| ((env, pop_when_done), mname, decls, intf) -> begin
(

let _67_2980 = (desugar_decls env decls)
in (match (_67_2980) with
| (env, sigelts) -> begin
(

let modul = {FStar_Syntax_Syntax.name = mname; FStar_Syntax_Syntax.declarations = sigelts; FStar_Syntax_Syntax.exports = []; FStar_Syntax_Syntax.is_interface = intf}
in ((env), (modul), (pop_when_done)))
end))
end))))


let desugar_partial_modul : FStar_Syntax_Syntax.modul Prims.option  ->  FStar_Parser_Env.env  ->  FStar_Parser_AST.modul  ->  (FStar_Parser_Env.env * FStar_Syntax_Syntax.modul) = (fun curmod env m -> (

let m = if ((FStar_Options.interactive ()) && ((let _166_1162 = (let _166_1161 = (FStar_Options.file_list ())
in (FStar_List.hd _166_1161))
in (FStar_Util.get_file_extension _166_1162)) = "fsti")) then begin
(match (m) with
| FStar_Parser_AST.Module (mname, decls) -> begin
FStar_Parser_AST.Interface (((mname), (decls), (true)))
end
| FStar_Parser_AST.Interface (mname, _67_2991, _67_2993) -> begin
(failwith (Prims.strcat "Impossible: " mname.FStar_Ident.ident.FStar_Ident.idText))
end)
end else begin
m
end
in (

let _67_3001 = (desugar_modul_common curmod env m)
in (match (_67_3001) with
| (x, y, _67_3000) -> begin
((x), (y))
end))))


let desugar_modul : FStar_Parser_Env.env  ->  FStar_Parser_AST.modul  ->  (env_t * FStar_Syntax_Syntax.modul) = (fun env m -> (

let _67_3007 = (desugar_modul_common None env m)
in (match (_67_3007) with
| (env, modul, pop_when_done) -> begin
(

let env = (FStar_Parser_Env.finish_module_or_interface env modul)
in (

let _67_3009 = if (FStar_Options.dump_module modul.FStar_Syntax_Syntax.name.FStar_Ident.str) then begin
(let _166_1167 = (FStar_Syntax_Print.modul_to_string modul)
in (FStar_Util.print1 "%s\n" _166_1167))
end else begin
()
end
in (let _166_1168 = if pop_when_done then begin
(FStar_Parser_Env.export_interface modul.FStar_Syntax_Syntax.name env)
end else begin
env
end
in ((_166_1168), (modul)))))
end)))


let desugar_file : FStar_Parser_Env.env  ->  FStar_Parser_AST.file  ->  (FStar_Parser_Env.env * FStar_Syntax_Syntax.modul Prims.list) = (fun env f -> (

let _67_3022 = (FStar_List.fold_left (fun _67_3015 m -> (match (_67_3015) with
| (env, mods) -> begin
(

let _67_3019 = (desugar_modul env m)
in (match (_67_3019) with
| (env, m) -> begin
((env), ((m)::mods))
end))
end)) ((env), ([])) f)
in (match (_67_3022) with
| (env, mods) -> begin
((env), ((FStar_List.rev mods)))
end)))


let add_modul_to_env : FStar_Syntax_Syntax.modul  ->  FStar_Parser_Env.env  ->  FStar_Parser_Env.env = (fun m en -> (

let _67_3027 = (FStar_Parser_Env.prepare_module_or_interface false false en m.FStar_Syntax_Syntax.name)
in (match (_67_3027) with
| (en, pop_when_done) -> begin
(

let en = (FStar_List.fold_left FStar_Parser_Env.push_sigelt (

let _67_3028 = en
in {FStar_Parser_Env.curmodule = Some (m.FStar_Syntax_Syntax.name); FStar_Parser_Env.curmonad = _67_3028.FStar_Parser_Env.curmonad; FStar_Parser_Env.modules = _67_3028.FStar_Parser_Env.modules; FStar_Parser_Env.scope_mods = _67_3028.FStar_Parser_Env.scope_mods; FStar_Parser_Env.exported_ids = _67_3028.FStar_Parser_Env.exported_ids; FStar_Parser_Env.trans_exported_ids = _67_3028.FStar_Parser_Env.trans_exported_ids; FStar_Parser_Env.includes = _67_3028.FStar_Parser_Env.includes; FStar_Parser_Env.sigaccum = _67_3028.FStar_Parser_Env.sigaccum; FStar_Parser_Env.sigmap = _67_3028.FStar_Parser_Env.sigmap; FStar_Parser_Env.default_result_effect = _67_3028.FStar_Parser_Env.default_result_effect; FStar_Parser_Env.iface = _67_3028.FStar_Parser_Env.iface; FStar_Parser_Env.admitted_iface = _67_3028.FStar_Parser_Env.admitted_iface; FStar_Parser_Env.expect_typ = _67_3028.FStar_Parser_Env.expect_typ}) m.FStar_Syntax_Syntax.exports)
in (

let env = (FStar_Parser_Env.finish_module_or_interface en m)
in if pop_when_done then begin
(FStar_Parser_Env.export_interface m.FStar_Syntax_Syntax.name env)
end else begin
env
end))
end)))




