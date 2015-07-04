class ET_COMPILATION_ORDER

inherit

	ET_AST_NODE
	HASHABLE
	KL_IMPORTED_STRING_ROUTINES
	
create

	make
	
feature {NONE} -- Initialization

	make (a_class_name: like class_name)
		do
			class_name := a_class_name
			hash_counter.n := hash_counter.n + 1
			internal_hash_code := class_name.hash_code + hash_counter.n
			reset
		ensure 
			class_name_set: STRING_.same_string (class_name, a_class_name)
		end

feature -- Initialization

	reset
		do
			implementation := Void
			feature_name := Void
			type := Void
			base_class := Void
			error_code := 0
		ensure
			not_ready: not ready
			no_errors: not has_errors
		end

feature -- Access

	class_name: STRING

	base_class: detachable ET_CLASS

	type: detachable ET_DYNAMIC_TYPE

	feature_name: detachable STRING

	as_creation: BOOLEAN
	
	implementation: detachable ET_DYNAMIC_FEATURE

	position: ET_COMPRESSED_POSITION
		do
			create Result.make_default
		end

	first_leaf: ET_AST_LEAF
		do
			-- Not defined
		end

	last_leaf: ET_AST_LEAF
		do
			-- Not defined
		end

	break: ET_BREAK
		do
			-- Not defined
		end
	
feature -- Status

	suborder_count: INTEGER
		do
			if suborders /= Void then
				Result := suborders.count
			end
		end

	suborder (i: INTEGER): ET_COMPILATION_ORDER
		require
			valid_index: 0 < i and then i <= suborder_count
		do
			Result := suborders.item (i)
		end
	
	ready: BOOLEAN
		do
			Result := type /= Void
				and then (feature_name /= Void implies implementation /= Void)
		end

	has_errors: BOOLEAN
		do
			Result := error_code /= 0
		ensure
			definition: Result = (error_code /= 0)
		end

	error_code: NATURAL
	
feature -- Error codes
	
	No_class: NATURAL = 0x01
	Bad_generic_count: NATURAL = 0x02
	No_generic: NATURAL = 0x04
	No_feature: NATURAL = 0x08
	Not_conforming: NATURAL = 0x10
	Not_creation: NATURAL = 0x20
	Not_public: NATURAL = 0x40
	No_attributes: NATURAL = 0x100
	No_user_expanded_target: NATURAL = 0x200
	No_user_expanded_args: NATURAL = 0x400

feature -- Setting

	set_feature_name (a_feature_name: attached like feature_name)
		require
			not_ready: not ready
		do
			implementation := Void
			feature_name := a_feature_name
		ensure
			feature_name_set: STRING_.same_string (feature_name, a_feature_name)
			no_implementation: implementation = Void
		end
	
	set_as_creation (for_creation: BOOLEAN)
		require
			not_ready: not ready
			has_feature_name: feature_name /= Void
			no_implementation: implementation = Void
		do
			implementation := Void
			as_creation := for_creation
		ensure
			as_creation_set: as_creation = for_creation
			no_implementation: implementation = Void
		end
	
	add_suborder (an_order: ET_COMPILATION_ORDER)
		require
			no_base_class: base_class = Void
		do
			if suborders = Void then
				create suborders.make (2)
			end
			suborders.put_last (an_order)
		ensure
			has_suborder: suborders /= Void and then suborders.has (an_order)
		end

feature -- Processing
	
	process (a_processor: ET_AST_PROCESSOR)
		do
			-- Do nothing.
		end
	
	resolve (a_system: ET_DYNAMIC_SYSTEM)
		note
			action:
			"[
			 Set `base_class' according to `class_name'; set `type' according to
			 `base_class' and `suborders' (these for generic parameters);
			 set `implementation' according to `feature_name'.
			 ]"
			a_system: "The system where the names have to be resolved"
		local
			l_suborder: ET_COMPILATION_ORDER
			l_actuals: ET_ACTUAL_PARAMETER_LIST
			l_type: ET_CLASS_TYPE
      l_procedure: ET_PROCEDURE
      l_query: ET_QUERY
			l_static: ET_FEATURE
			l_any: ET_BASE_TYPE
			l_conformings: ET_DYNAMIC_STANDALONE_TYPE_SET
			l_heir, l_root: ET_DYNAMIC_TYPE
			l_heir_impl: ET_DYNAMIC_FEATURE
      l_id: ET_IDENTIFIER
			i, n: INTEGER
			failed: BOOLEAN
		do
			if attached a_system.current_system.class_by_name (class_name) as bc then
				n := suborder_count
				base_class := bc
				if n > 0 then
					create l_actuals.make_with_capacity (n)
					from
					until has_errors or else i = n loop
						i := i + 1
						l_suborder := suborder (i)
						l_suborder.resolve (a_system)
						if l_suborder.ready then
							l_actuals.put_first (l_suborder.type.base_type)
						else
							error_code := error_code | no_generic
						end
					end
					if not has_errors then
						create {ET_GENERIC_CLASS_TYPE} l_type.make (Void, bc.name, l_actuals, bc)
					end
				else
					create l_type.make(Void, bc.name, bc)
				end
				if not has_errors then
					l_any := a_system.any_type.base_type
					-- The following function call has a side effect:
					-- base class `bc' of `l_type' gets initialized,
					-- afterwards we can check its generics count.
					type := a_system.dynamic_type (l_type, bc)
					if bc.formal_parameter_count /= n then
						error_code := error_code | bad_generic_count
					end
				end
				if not has_errors and then feature_name /= Void then						
					create l_id.make(feature_name)
					l_static := type.base_class.named_feature(l_id)
					if l_static /= Void then
						if l_static.is_query then
							implementation := type.seeded_dynamic_query (l_static.first_seed, a_system)
						else
							implementation := type.seeded_dynamic_procedure (l_static.first_seed, a_system)
						end
					end
					if implementation = Void then
						error_code := error_code | no_feature
					else
						implementation.set_creation (as_creation)
						if as_creation then
							if not l_static.is_creation_exported_to (l_any.base_class, base_class) then
								error_code := error_code | not_public
							end
						else
							if not l_static.is_exported_to (l_any.base_class) then
								error_code := error_code | not_public
							end
							if implementation.is_attribute then
								error_code := error_code | No_attributes
							end
						end
						if implementation.target_type.is_expanded
							and then not implementation.target_type.is_basic
						 then
							error_code := error_code | No_user_expanded_target
						end
						from
							n := l_static.arguments_count
							i := 0
						until i = n loop
							i := i + 1
							if attached {ET_BASE_TYPE} l_static.arguments.formal_argument (i).type as t 
								and then t.is_expanded and then not t.base_class.is_basic
							 then
								error_code := error_code | No_user_expanded_args
							end
						end
					end
				end
			else
				error_code := error_code | no_class
			end
			if has_errors then
				implementation := Void
				type := Void
				base_class := Void
			elseif ready then
				if implementation /= Void then
					from
						l_conformings := type.conforming_dynamic_types
						n := l_conformings.count
						i := 0
					until i = n loop
						i := i + 1
						l_heir := l_conformings.dynamic_type (i)
						l_heir_impl := l_heir.seeded_dynamic_query (l_static.first_seed, a_system)
					end
				end
			end
		ensure
			ready_or_failed: ready or has_errors
		end
	
feature -- Validity checking

	valid_generics (a_type: attached like type): BOOLEAN
		-- Has `a_type' the generics specified in `suborders'?
		local
			i, n: INTEGER
		do
			n := suborder_count
			if n = 0 then
				Result := not a_type.is_generic
			elseif attached {ET_BASE_CLASS} a_type.base_class as bc then
				Result := bc.formal_parameter_count = n
				if Result then
					from
						i := 0
					until not Result or else i = n loop
						if attached suborder (i).type as ti then
							Result := bc.actual_parameters.type (i) = ti.base_type
						end
					end
				end
			end
		end

feature -- HASHABLE

	hash_code: INTEGER
		do
			Result := internal_hash_code
		end
	
feature {NONE}

	suborders: detachable DS_ARRAYED_LIST [ET_COMPILATION_ORDER]

	internal_hash_code: INTEGER

	hash_counter: TUPLE [n: INTEGER]
		once
			Result := [0]
		end

invariant

	when_base_class: base_class /= Void implies STRING_.same_string (base_class.upper_name, class_name)
	when_type: type /= Void implies type.base_class = base_class
	and then valid_generics (type)
	when_implementation: implementation /= Void implies
		STRING_.same_string (implementation.lower_name, feature_name)
		and then (as_creation implies implementation.is_creation)
		and then implementation.target_type = type
	when_ready:	ready implies not has_errors
	
end
