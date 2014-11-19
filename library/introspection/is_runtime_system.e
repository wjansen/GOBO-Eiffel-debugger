note

	description: "Descriptor of the running system."

class IS_RUNTIME_SYSTEM

inherit

	IS_FACTORY
		rename
			type_exists as c_type_exists,
			type_flags as c_type_flags,
			class_ident as c_class_ident,
			class_flags as c_class_flags,
			generic_count as c_generic_count,
			generic as c_generic,
			field_count as c_field_count,
			field_type_ident as c_field_type_ident
		redefine
			valid_type,
			operand_name
		end
	
create

	make_from_tables

feature {NONE} -- Initialization 

	make_from_tables
		local
			time: like creation_time
			t: like type_at
			nm: STRING
			ptr, null: POINTER
			i, n, nc: INTEGER
			attac: BOOLEAN
		do
			if attached root_type then
				make_guru
			end
			default_create
			time := creation_time
			to_fill := True
			from
				n := c_field_name_count
				create names.make_filled (no_name, n)
			until n = 0 loop
				n := n - 1
				ptr := c_field_name (n)
				if ptr /= null then
					create nm.make_from_c (ptr)
				else
					nm := no_name
				end
				names [n] := nm
			end
			n := c_type_count
			all_types.resize (n)
			nc := 0
			n := c_any_type
			new_type (n, False)
			if attached {IS_NORMAL_TYPE} last_type as normal then
				any_type := normal
			end
			from
				i := Pointer_ident
			until i = 0 loop
				if c_type_exists (i) then
					new_type (i, True)
					t := all_types [i]
				end
				i := i - 1
			end
			n := c_root_type
			if n > 0 then
				new_type (n, True)
				root_type := all_types [n]
			end
			from
				n := c_type_count
			until i = n loop
				if c_type_exists (i) then
					attac := c_type_flags (i) & Attached_flag > 0
					new_type (i, attac)
					t := all_types [i]
					check attached t then end
				end
				i := i + 1
			end
			compilation_time := c_comp_time
			ptr := c_system_name
			if ptr /= null then
				create {STRING_8} fast_name.make_from_c (ptr)
			end
			set_locations				
			creation_time := time
		end

feature -- Access

	any_type: IS_NORMAL_TYPE

	none_type: like any_type

	top_frame: IS_STACK_FRAME
	
	valid_type (i: INTEGER): BOOLEAN
		do
			Result := i < type_count and then c_type_exists (i) 
		end
	
feature -- Status setting

	set_root (root: ANY)
		do
			if not attached root_type then
				root_type := type_of_any (root, Void)
			end
		end
	
feature -- Object creation 

	new_instance (t: IS_TYPE; use_default_creation: BOOLEAN): ANY
		require
			is_alive: t.is_alive
		do
			if t.is_subobject then
				if t.flags & Missing_id_flag = 0 then
					Result := c_new_boxed_object (t.allocate)
				else
					Result := c_new_copy (t.default_instance, t.instance_bytes)
				end
			elseif t.is_meta_type then
			elseif t.is_agent and then attached {IS_AGENT_TYPE} t as at then
				Result := c_new_object (at.declared_type.allocate)
				fill_new_agent (at, Result)
			else
				Result := c_new_object (t.allocate)
				if use_default_creation
					and then attached t.default_creation as dc
					and then dc.target /= root_type	-- do not start the system again
				 then
					c_call_create (dc.call, Result)
				end
			end
		end
	
	new_boxed_instance (t: IS_TYPE): ANY
		do
			Result := c_new_boxed_object (t.allocate)
		end

	new_array (s: IS_SPECIAL_TYPE; n: NATURAL): ANY
		note
			return: "Create a new `SPECIAL' of type `s' and length `n'."
		do
			Result := c_new_array (s.allocate, n)
		end

feature -- Basic operation

	sort_fields
		local
			n: INTEGER
		do
			from
				n := all_types.count
			until n = 0 loop
				n := n - 1
				if attached all_types [n] as t and then t.is_normal
					and then attached t.fields as ta
				 then
					ta.default_sort
				end
			end
		end

feature -- Low level access 

	type_of_any (any: detachable ANY; static: detachable IS_TYPE): like type_at
		local
			tid: INTEGER
		do
			if attached any as a then
				tid := c_ident (a)
				if valid_type (tid) then
					Result := type_at (tid)
				end
				if attached Result as r and then r.flags & Agent_expression_flag > 0 then
					if attached {attached like type_at} as_agent (a) as ag then
						Result := ag
					else
						Result := Void
					end
				end
			end
		end

	as_agent (any: detachable ANY): detachable IS_AGENT_TYPE
		note
			return: "Cast type of `any' to an IS_AGENT_TYPE."
		local
			i, did: INTEGER
		do
			if attached any as a then
				did := c_ident (a)
				from
					i := agent_count
				until attached Result or else i = 0 loop
					i := i - 1
					Result := all_agents [i]
					if attached Result as at and then
						(at.declared_type.ident /= did
						 or else at.call_function
						 	/= c_dereference (as_pointer(a) + at.function_offset))
					 then
						Result := Void
					end
				end
			end
		end

	closed_operands (id: ANY; at: IS_AGENT_TYPE): TUPLE
		local
			addr: POINTER
		do
			addr := as_pointer(id) + at.declared_type.fields [0].offset
			if attached {TUPLE} to_any (addr) as co then
				Result := co
			end
		end

	dereferenced (at: POINTER; static: like type_at): POINTER
		note
			return:
				"[
				 Object address on heap given by field address 
				 within another object or the call stack.
				 ]"
			at: "address"
			static: "static type of the field"
		local
			null: POINTER
		do
			if attached static as s and then s.is_subobject then
				Result := at
			elseif at /= null then
				Result := c_dereference (at)
			end
		end

	check_invariant (obj: POINTER; t: attached like type_at): BOOLEAN
		note
			return: "Check the invariant of an object of type `t' located at `obj'."
		require
			not_null: obj /= default_pointer
		local
			retried: BOOLEAN
		do
			if not retried then
				if attached t.invariant_function as r then
					Result := c_call_invariant (r.call, obj)
				end
			end
		rescue
			Result := False
			retried := True
			retry
		end

	special_count (a: ANY; st: IS_SPECIAL_TYPE): NATURAL
		do
			if attached st.count as c then
				($Result).memory_copy (as_pointer(a) + c.offset, natural_32_bytes)
			end
		ensure
			not_negative: Result >= 0
		end

	special_capacity (a: ANY; st: IS_SPECIAL_TYPE): NATURAL
		do
			if attached st.capacity as c then
				($Result).memory_copy (as_pointer(a) + c.offset, natural_32_bytes)
			end
		ensure
			not_negative: Result >= 0
		end

	adjust_special_count (a: ANY; st: IS_SPECIAL_TYPE)
		local
			cap: NATURAL
		do
			if attached st.count as c then
				cap := special_capacity (a, st)
				(as_pointer(a) +c. offset).memory_copy ($cap, natural_32_bytes)
			end
		ensure
			not_negative: Result >= 0
		end

	refresh_all_onces
		local
			n: INTEGER
		do
			from
				n := once_count
			until n = 0 loop
				n := n - 1
				if valid_once (n) then
					once_at (n).refresh
				end
			end
		end

	refresh_initialized_onces (comp: detachable PREDICATE [ANY, TUPLE [IS_ONCE, IS_ONCE]])
		local
			o: IS_ONCE
			n: INTEGER
		do
			if attached initialized_onces as inits then
				inits.clear
			else
				create initialized_onces
			end
			if attached initialized_onces as inits then
				from
					n := once_count
				until n = 0 loop
					n := n - 1
					if valid_once (n) then
						o := once_at (n)
						if o.is_initialized and then
							o.is_function implies not o.type.is_subobject
						 then
							inits.add (o)
						end
					end
				end
				if attached comp as c then
					inits.sort (c)
				end
			end
		end

	once_by_address (loc: POINTER): detachable IS_ONCE
		note
			return: "The once value located at `loc' (if any)."
		require
			not_null: loc /= default_pointer
		local
			o: IS_ONCE
			addr: POINTER
			i: INTEGER
		do
			if attached initialized_onces as inits then
				from
					i := inits.count
				until attached Result or else i = 0 loop
					i := i - 1
					o := inits [i]
					if o.is_function and then o.type.is_reference then 
						addr := o.value_address
						addr := dereferenced (addr, o.type)
					end
					if addr = loc then
						Result := o
					end
				end
			end
		ensure
			when_found: attached Result as o implies
									dereferenced (o.value_address, o.type) = loc
		end

	initialized_onces: detachable IS_SEQUENCE [IS_ONCE]

feature {NONE} -- Factory 

	class_name (id: INTEGER): STRING
		do
			create Result.make_from_c (c_class_name (id))
		end

	creation_ident (id: INTEGER): INTEGER
		do
		end
	
	agent_pattern (id: INTEGER): STRING
		do
			create Result.make_from_c (c_agent_pattern (id))
		end

	agent_routine (id: INTEGER): STRING
		do
			create Result.make_from_c (c_agent_routine (id))
		end

	agent_call_field (a: IS_AGENT_TYPE): POINTER
		do
			Result := c_agent_call_field (a.ident)
		end

	set_agent_base (a: IS_AGENT_TYPE)
		local
			id: INTEGER
		do
			id := c_agent_closed_tuple (a.ident)
			new_type (id, True)
			if attached {IS_TUPLE_TYPE} last_type as tt then
				a.set_closed_operands_tuple (tt)
				id := c_agent_declared (a.ident)
			end
			new_type (id, True)
			if attached {IS_NORMAL_TYPE} last_type as nt then
				a.set_declared_type (nt)
			end
			last_type := last_type.generic_at (0)
		end

	set_result_type (a: IS_AGENT_TYPE)
		local
			id: INTEGER
		do
			id := c_declared_type (a.ident)
			last_type := type_at (id)
		end

	field_name (id, i: INTEGER): STRING
		local
			nid: INTEGER
		do
			nid := c_field_name_ident (id, i)
			if nid > 0 then
				Result := names [nid]
			else
				Result := no_name
			end
		end

	operand_name (tid, fid, oid: INTEGER): READABLE_STRING_8
		do
			Result := field_name (tid, fid)
		end
	
	routine_call (tid, i: INTEGER): POINTER
		do
		end
	
	typeset_index (tid, fid: INTEGER): INTEGER
		do
			Result := c_typeset_index (tid, fid)
		end
	
	typeset_size (ts: INTEGER): INTEGER
		do
			Result := c_typeset_size (ts)
		end
	
	typeset_tid (ts, i: INTEGER): INTEGER
		do
			Result := c_typeset_elem (ts, i)
		end
	
feature {NONE} -- Implementation 

	names: SPECIAL [READABLE_STRING_8]
	
	set_locations
		local
			cot: IS_TUPLE_TYPE
			off: INTEGER
			i, j, k, m, n, na: INTEGER
		do
			m := all_types.count
			from
				i := m
			until i = 0 loop
				i := i - 1
				if valid_type (i) and then attached type_at (i) as t then
					if not attached any_type
						and then STRING_.same_string (any_name, t.class_name)
					 then
						if attached {IS_NORMAL_TYPE} t as normal then
							any_type := normal
						end
					end
					if not attached none_type
						and then STRING_.same_string (none_name, t.class_name)
					 then
						if attached {IS_NORMAL_TYPE} t as normal then
							none_type := normal
						end
					end
					if t.is_alive then
						t.set_bytes (c_type_bytes (i))
						t.set_default (c_type_default (i))
						t.set_allocate (c_allocate (i))
						if t.is_agent then
							na := na + 1
						else
							from
								j := t.field_count
							until j = 0 loop
								j := j - 1
								if attached t.field_at (j) as f then
									off := c_indexed_offset (i, j)
									f.set_offset (off)
								end
							end
						end
						if t.is_subobject and then attached {IS_EXPANDED_TYPE} t as et then
							et.set_boxed_bytes (c_boxed_bytes (i))
							off := c_boxed_offset (i)
							et.set_boxed_offset (off)
						elseif t.is_special and then attached {IS_SPECIAL_TYPE} t as st then
							off := c_indexed_offset (i, 2)
						end
					end
				end
			end
			check attached any_type end
			check attached none_type end
			if na > 0 then
				from
					i := all_types.count
					j := 0
				until i = 0 loop
					i := i - 1
					if attached {IS_AGENT_TYPE} type_at (i) as at then
						if j = 0 then
							create all_agents.make (na, at)
						end
						all_agents.add (at)
						prepare_agent (at)
						j := j + 1
					end
				end
			end
		end

	prepare_agent (at: IS_AGENT_TYPE)
		local
			j, off: INTEGER
		do
			if attached {IS_NORMAL_TYPE} at.declared_type as dt then
				at.set_function_location (c_agent_function_loc (at.ident))
				at.set_call_function (c_agent_call (at.ident))
				if attached at.closed_operands_tuple as cot then
					j := cot.field_count
					if attached at.result_type as rt
						and then attached at.field_at (j) as f 
					 then
						off := dt.field_at (2).offset
						f.set_offset (off)
					end
					from
					until j = 0 loop
						j := j - 1
						if attached at.field_at (j) as f then
							off := cot.field_at (j).offset
							f.set_offset (off)
						end
					end
				end
			end
		end
	
	fill_new_agent (at: IS_AGENT_TYPE; a: ANY)
		local
			dt: IS_TYPE
			f: IS_FIELD
			addr, cf, cot: POINTER
			i: INTEGER
			b: BOOLEAN
		do
			addr := as_pointer (a) + at.function_offset
			cf := at.call_function
			addr.memory_copy ($cf, Pointer_bytes)
			addr := as_pointer (a) + at.declared_type.fields [0].offset
			cot := as_pointer(new_instance (at.closed_operands_tuple, False))
			addr.memory_copy ($cot, Pointer_bytes)
			if at.base_is_closed then
				from
					dt := at.declared_type
					i := dt.field_count
				until i = 0 loop
					i := i - 1
					f := dt.field_at (i)
					if f.has_name (is_target_closed) then
						b := True
						addr := as_pointer (a) + f.offset
						addr.memory_copy ($b, Boolean_bytes)
						i := 0
					end
				end
			end
		end

feature {NONE} -- Implementation
	
	any_name: STRING = "ANY"

	none_name: STRING = "NONE"

	is_target_closed: STRING = "is_target_closed"
	
feature {NONE} -- Guru section 

	make_guru
		note
			action:
			"[
			 Dummy creation routine ensuring that several types become alive.
			 The routine must syntactically be reachable
			 but it should never be called during runtime.
			 ]"
		local
			c: IS_CLASS_TEXT
			t: IS_TYPE
			n: IS_NORMAL_TYPE
			b: IS_EXPANDED_TYPE
			s: IS_SPECIAL_TYPE
			u: IS_TUPLE_TYPE
			g: IS_AGENT_TYPE
			o: IS_ONCE
			a0, a1, a2: IS_FIELD
			r: IS_ROUTINE
			l: IS_LOCAL
			ot: IS_SCOPE_VARIABLE
			f: IS_FEATURE_TEXT
			rf: IS_ROUTINE_TEXT
			x: IS_ENTITY 
			m: IS_NAME
			cb: IS_CONSTANT 
			cc: IS_CONSTANT
			ci: IS_CONSTANT
			cn: IS_CONSTANT 
			cr: IS_CONSTANT 
			cs: IS_CONSTANT 
			cu: IS_CONSTANT 
			cy: IS_CONSTANT 
			sf: IS_SEQUENCE [IS_FEATURE_TEXT]
			sr: IS_SEQUENCE [IS_ROUTINE_TEXT]
			sa: IS_SEQUENCE [IS_FIELD]
			sc: IS_SEQUENCE [IS_CONSTANT]
			se: IS_SEQUENCE [IS_ROUTINE]
			al: IS_SEQUENCE [IS_LOCAL]
			qt: IS_SEQUENCE [IS_TYPE]
			qc: IS_SEQUENCE [IS_CLASS_TEXT]
			qy: IS_SEQUENCE [IS_CONSTANT]
			qo: IS_SEQUENCE [IS_ONCE]
			st: IS_SET [IS_TYPE]
			any: ANY
			i: INTEGER
		do
			flags := No_gc_flag
			assertion_check := 8
			fast_name := ""
			create f.make (no_name, no_name, 2, 1, 2)
			create sf.make_1 (f)
			create sr.make_1 (rf)
			create qc
			create qo
			create qy
			create c.make (0, no_name, 0, no_name, sf, qc)
			create all_classes.make_1 (c)
			i := all_classes.count
			qc.add (c)
			create rf.make (no_name, no_name, Routine_flag, 2, 3, sf, 2, 3, 1, sr)
			f := rf
			f.set_tuple_labels (sf)
			f.set_home (c)
			f.set_result_text (c)
			create sa
			create se
			create qt
			create n.make (0, c, 0, qt, Void, sa, sc, se)	
			create st.make_1 (n)
			create n.make (0, c, 0, qt, st, sa, sc, se)	
			t := n
			st.add (t)
			qt.add (t)
			create l.make (no_name, t, Void, rf)
			create al.make_1 (l)
			create r.make (no_name, no_name, g, 0, t, 1, 2, 3, 4, 5, al, rf)
			create o.make (no_name, no_name, g, 0, t, 1, 2, 3, 4, 5, al, rf)
			create b.make (0, c, 0, qt, st, sa, sc, se)
			qt.add (b)
			create u.make (0, 0, c, qt, st, sa, se)
			qt.add (u)
			create s.make (0, 0, c, n, sa, st, se)
			create g.make (0, n, u.fields, no_name, r)
			t := b
			t := s
			t := u
			t := g
			t.set_c_name (no_name)
			create a0.make (no_name, t, st, f)
			create a1.make (no_name, t, st, f)
			create a2.make (no_name, t, st, f)
			sa.add (a0)
			sa.add (a1)
			sa.add (a2)
			create all_types.make_1 (t)
			i := all_types.count
			t := all_types [0]
			create all_agents.make_1 (g)
			i := all_agents.count
			g := all_agents [0]
			create l.make (no_name, t, st, f)
			create ot.make (no_name, t, st, t/=Void , f)
			ot.	set_lower_scope_limit (123)
			ot.	set_upper_scope_limit (456)
			l := ot
			create al.make_1 (l)
			i := al.count
			o.set_addresses ($Current, $i)
			qo.add (o)
			sf.add (f)
			se.add (r)
			x := r
			x := o
			x := a0
			x := l
			m := x
			m := f
			m := c
			m := t
			create all_onces.make_1 (o)
			qo.add (o)
			all_onces.add (o)
			i := all_onces.count
			create cb.make (no_name, 0, c, n, f)
			cb.set_boolean_value (n=t)
			create cc.make (no_name, 0, c, n, f)
			cc.set_character_value ('?')
			create ci.make (no_name, 0, c, n, f)
			ci.set_integer_value (1)
			create cn.make (no_name, 0, c, n, f)
			cn.set_natural_32_value (2)
			create cr.make (no_name, 0, c, n, f)
			cr.set_real_64_value (3)
			create cs.make (no_name, 0, c, n, f)
			cs.set_string_value ("??")
			create cu.make (no_name, 0, c, n, f)
			cu.set_string_32_value ("???")
			create all_constants
			all_constants.add (ci)
			cy := cb
			cy := cc
			cy := ci
			cy := cn
			cy := cr
			cy := cs
			cy := cu
			x := cy
			m := x
			all_constants.add (cy)
			create sc.make_1 (cy)
			create top_frame
			any_type := n
			none_type := n
			root_type := n
			r.set_call (default_pointer)
			root_creation_procedure := r
			f.set_bounds (1, 5, 12, 9)
			rf.set_body (2, 3, 4)
			compilation_time := creation_time
			x := some_entity
			push_type (root_type.ident)
			pop_types (1)
		end

	some_entity: IS_ENTITY
		once
			Result := root_creation_procedure
			Result := root_creation_procedure.var_at(0)
		end
	
feature {NONE} -- External implementation 
	
	c_system: ANY
		external "C inline"
		alias
			"[
			 
			#ifdef GEIP_INTRO
				geip_rts
			#else
				0
			#endif
			 
			 ]"
		end
	
	c_ident (a: detachable ANY): INTEGER
		external
			"C inline"
		alias
			"$a ? ((EIF_ANY*)$a)->id : 0"
		end
	
	c_new_object (call: POINTER): ANY
		external
			"C inline"
		alias
			"((EIF_REFERENCE (*)(EIF_BOOLEAN))($call))(EIF_TRUE)"
		end
	
	c_new_boxed_object (call: POINTER): ANY
		external
			"C inline"
		alias
			"((EIF_REFERENCE (*)(EIF_BOOLEAN))($call))(EIF_TRUE)"
		end
	
	c_new_copy (src: POINTER; size: NATURAL): ANY
		external
			"C inline use <string.h>"
		alias
			"(EIF_REFERENCE)(memcpy(GE_alloc($size),$src,$size))"
		end

	c_new_array (call: POINTER; n: NATURAL): ANY
		external
			"C inline"
		alias
			"((EIF_REFERENCE (*)(EIF_INTEGER,EIF_BOOLEAN))($call))($n,EIF_TRUE)"
		end
	
	c_call_create (call: POINTER; a: ANY)
		external
			"C inline"
		alias
			"((void (*)(EIF_ANY*))$call)((EIF_ANY*)$a)"
		end
	
	c_call_invariant (call: POINTER; at: POINTER): BOOLEAN
		external
			"C inline"
		alias
			"EIF_TRUE"
			-- To be implemented properly! 
		end
	
	c_dereference (p: POINTER): POINTER
		external
			"C inline"
		alias
			"(EIF_POINTER*)(*(void**)$p)"
		end
	
	c_type (id: INTEGER): TYPE [ANY]
		external 
			"C inline"
		alias
			"(EIF_REFERENCE)&GE_types[$id]"
		end
	
	c_field_offset (t, f: POINTER): INTEGER
		external
			"C inline"
		alias
			"(EIF_INTEGER)((size_t)$f - (size_t)$t)"
		end

feature {NONE} -- External implementation
	
	c_type_exists (id: INTEGER): BOOLEAN
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  (geip_t[$id] != 0)
#else
  0
#endif

]"
		end
	
	c_system_name: POINTER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_self
#else
  0
#endif

]"
		end
	
	c_comp_time: INTEGER_64
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_time
#else
  0
#endif

]"
		end
	
	c_class_count: INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_cc
#else
  0
#endif

]"
		end
	
	c_class_name (id: INTEGER): POINTER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_c[$id]
#else
  0
#endif

]"
		end
	
	c_class_flags (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_cf[$id]
#else
  0
#endif

]"
		end
	
	c_type_count: INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_tc
#else
  0
#endif

]"
		end
	
	c_root_type: INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_root
#else
  0
#endif

]"
		end
	
	c_any_type: INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_any
#else
  0
#endif

]"
		end

	c_type_flags (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_t[$id]->flags
#else
  0
#endif

]"
		end
	
	c_class_ident (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_t[$id]->class_id
#else
  0
#endif

]"
		end
	
	c_generic_count (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_t[$id]->ngenerics
#else
  0
#endif

]"
		end
	
	c_generic (id, i: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
(geip_t[$id]->generics)[$i]
#else
  0
#endif

]"
		end
	
	c_field_count (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_t[$id]->nfields
#else
  0
#endif

]"
		end
	
	c_creation_ident (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_t[$id]->create_id
#else
  0
#endif

]"
		end
	
	c_allocate (id: INTEGER): POINTER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_t[$id]->alloc
#else
  0
#endif

]"
		end
	
	c_type_default (id: INTEGER): POINTER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_t[$id]->def
#else
  0
#endif

]"
		end
	
	c_type_bytes (id: INTEGER): NATURAL
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_t[$id]->size
#else
  0
#endif

]"
		end
	
	c_boxed_bytes (id: INTEGER): NATURAL
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
((GEIP_Tb*)geip_t[$id])->boxed_size
#else
  0
#endif

]"
		end
	
	c_agent_declared (id: INTEGER): INTEGER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
((GEIP_A*)geip_t[$id])->declared_id
#else
  0
#endif

]"
		end
	
	c_agent_closed_tuple (id: INTEGER): INTEGER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
((GEIP_A*)geip_t[$id])->closed_tuple_id
#else
  0
#endif

]"
		end
	
	c_agent_result (id: INTEGER): INTEGER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
((GEIP_A*)geip_t[$id])->result_id
#else
  0
#endif

]"
		end
	
	c_agent_pattern (id: INTEGER): POINTER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
((GEIP_A*)geip_t[$id])->open_closed
#else
  0
#endif

]"
		end
	
	c_agent_routine (id: INTEGER): POINTER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_n ? geip_n[((GEIP_A*)geip_t[$id])->routine_name] : 0
#else
  0
#endif

]"
		end
	
	c_agent_function_loc (id: INTEGER): POINTER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
((GEIP_A*)geip_t[$id])->call_field
#else
  0
#endif

]"
		end
	
	c_agent_call (id: INTEGER): POINTER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
((GEIP_A*)geip_t[$id])->call
#else
  0
#endif

]"
		end
	
	c_field_type_ident (id, i: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_t[$id]->fields[$i].type_id
#else
  0
#endif

]"
		end
	
	c_indexed_offset (id, i: INTEGER): INTEGER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
(int)((size_t)((geip_t[$id]->fields)[$i].def)-(size_t)(geip_t[$id]->def))
#else
  0
#endif

]"
		end
	
	c_boxed_offset (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
(int)((size_t)(((GEIP_Tb*)geip_t[$id])->subobject)-(size_t)(((GEIP_Tb*)geip_t[$id])->boxed_def))
#else
  0
#endif

]"
		end
	
	c_field_name_count: INTEGER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_nc
#else
  0
#endif

]"
		end
	
	c_field_name_ident (id, i: INTEGER): INTEGER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_t[$id]->fields[$i].name_id
#else
  0
#endif

]"
		end

	c_field_name (i: INTEGER): POINTER
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_n ? geip_n[$i] : 0
#else
  0
#endif

]"
		end

	c_typeset_index (tid, fid: INTEGER): INTEGER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_t[$tid]->fields[$fid].typeset_id
#else
  0
#endif

]"
		end
	
	c_typeset_size (id: INTEGER): INTEGER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_tss[$id]
#else
  0
#endif

]"
		end
	
	c_typeset_elem (id, i: INTEGER): INTEGER
		require
			exists: c_type_exists (id)
		external "C inline"
		alias
"[

#ifdef GEIP_TABLES
  geip_ts[$id][$i]
#else
  0
#endif

]"
		end
	
invariant
	
note
	
	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"
	
end
