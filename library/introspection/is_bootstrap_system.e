class IS_BOOTSTRAP_SYSTEM

inherit

	IS_RUNTIME_SYSTEM
		redefine
			valid_type
		end
	
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

feature {} -- Initialization

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
				names.put (nm, n)
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
				n := Pointer_ident
				i := 0
			until i = n loop
				if c_type_exists (i) then
					new_type (i, True)
					t := all_types [i]
				end
				i := i + 1
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

	valid_type (i: INTEGER): BOOLEAN
		do
			Result := i < type_count and then c_type_exists (i) 
		end
	
feature {} -- Factory 

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

	operand_name (id, i: INTEGER): READABLE_STRING_8
		do
			Result := field_name (id, i)
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
	
feature {} -- Implementation

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
	
feature {} -- External implementation
	
	c_type_exists (id: INTEGER): BOOLEAN
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
(GE_zt[$id] != 0)
#else
0
#endif

]"
		end
	
	c_system_name: POINTER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_zself
#else
0
#endif

]"
		end
	
	c_comp_time: INTEGER_64
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_ztime
#else
0
#endif

]"
		end
	
	c_class_count: INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_zcc
#else
0
#endif

]"
		end
	
	c_class_name (id: INTEGER): POINTER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_zc[$id]
#else
0
#endif

]"
		end
	
	c_class_flags (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_zcf[$id]
#else
0
#endif

]"
		end
	
	c_type_count: INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_ztc
#else
0
#endif

]"
		end
	
	c_root_type: INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_zroot
#else
0
#endif

]"
		end
	
	c_any_type: INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_zany
#else
0
#endif

]"
		end

	c_type_flags (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_zt[$id]->flags
#else
0
#endif

]"
		end
	
	c_class_ident (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_zt[$id]->class_id
#else
0
#endif

]"
		end
	
	c_generic_count (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_zt[$id]->ngenerics
#else
0
#endif

]"
		end
	
	c_generic (id, i: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
(GE_zt[$id]->generics)[$i]
#else
0
#endif

]"
		end
	
	c_field_count (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_zt[$id]->nfields
#else
0
#endif

]"
		end
	
	c_creation_ident (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_zt[$id]->create_id
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

#ifdef GE_ZTABLES
GE_zt[$id]->alloc
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

#ifdef GE_ZTABLES
GE_zt[$id]->def
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

#ifdef GE_ZTABLES
GE_zt[$id]->size
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

#ifdef GE_ZTABLES
((GE_ZTb*)GE_zt[$id])->boxed_size
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

#ifdef GE_ZTABLES
((GE_ZA*)GE_zt[$id])->declared_id
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

#ifdef GE_ZTABLES
((GE_ZA*)GE_zt[$id])->closed_tuple_id
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

#ifdef GE_ZTABLES
((GE_ZA*)GE_zt[$id])->result_id
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

#ifdef GE_ZTABLES
((GE_ZA*)GE_zt[$id])->open_closed
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

#ifdef GE_ZTABLES
GE_zn ? GE_zn[((GE_ZA*)GE_zt[$id])->routine_name] : 0
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

#ifdef GE_ZTABLES
((GE_ZA*)GE_zt[$id])->call_field
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

#ifdef GE_ZTABLES
((GE_ZA*)GE_zt[$id])->call
#else
0
#endif

]"
		end
	
	c_field_type_ident (id, i: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_zt[$id]->fields[$i].type_id
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

#ifdef GE_ZTABLES
(int)((size_t)((GE_zt[$id]->fields)[$i].def)-(size_t)(GE_zt[$id]->def))
#else
0
#endif

]"
		end
	
	c_boxed_offset (id: INTEGER): INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
(int)((size_t)(((GE_ZTb*)GE_zt[$id])->subobject)-(size_t)(((GE_ZTb*)GE_zt[$id])->boxed_def))
#else
0
#endif

]"
		end
	
	c_field_name_count: INTEGER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_znc
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

#ifdef GE_ZTABLES
GE_zt[$id]->fields[$i].name_id
#else
0
#endif

]"
		end

	c_field_name (i: INTEGER): POINTER
		external "C inline"
		alias
"[

#ifdef GE_ZTABLES
GE_zn ? GE_zn[$i] : 0
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

#ifdef GE_ZTABLES
GE_zt[$tid]->fields[$fid].typeset_id
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

#ifdef GE_ZTABLES
GE_ztss[$id]
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

#ifdef GE_ZTABLES
GE_zts[$id][$i]
#else
0
#endif

]"
		end
	
invariant
	
end
