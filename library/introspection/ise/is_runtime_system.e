note

	description: "Descriptor of the running system."

class IS_RUNTIME_SYSTEM

inherit

	IS_FACTORY
		redefine
			default_create,
			class_by_name,
			type_by_class_and_generics,
			new_type,
			new_field
		end

	INTERNAL_HELPER
		undefine
			copy, is_equal, out
		redefine
			default_create
		end

create

	default_create

feature {} -- Initialization

	default_create
		local
			bc: IS_CLASS_TEXT
			str: STRING
			tid: INTEGER
		do
			Precursor {IS_FACTORY}
			creation_time := actual_time_as_integer
			compilation_time := creation_time
			fast_name := "ISE"
			str := "ANY"
			tid := dynamic_type_from_string (str)
			if tid < reference_type then
				-- this shoud not happen, just make the compiler happy:
				tid := reference_type
			end
			create bc.make (0, str, 0, Void, Void, Void, Void, Void)
			create any_type.make (tid, bc, 0, Void, Void, Void, Void, Void)
			new_type (tid, False)
			if attached {IS_NORMAL_TYPE} last_type as lt then
				any_type := lt
			end
			from
				basic_idents.start
			until basic_idents.after loop
				str := basic_idents.key_for_iteration
				tid := dynamic_type_from_string (str)
				if tid >= 0 then
					create bc.make (0, str, 0, Void, Void, Void, Void, Void)
					create any_type.make (tid, bc, 0, Void, Void, Void, Void, Void)
					new_type (tid, True)
				end
				basic_idents.forth
			end
			to_fill := True
		end
			
feature -- Access

	any_type: IS_NORMAL_TYPE

feature -- Status 

	type_exists (tid: INTEGER): BOOLEAN
		do
--			Result := internal_dynamic_type_string_table.has_item (tid)
			Result := True
		end

feature -- Searching 

	class_by_name (nm: READABLE_STRING_8): detachable like class_at
		local
			cid: INTEGER
		do
			if attached Precursor (nm) as cls then
				Result := cls
			else
				cid := class_count
				create Result.make (cid, nm, 0, Void, Void, Void, Void, Void)
				all_classes.force (Result, cid)
			end
		end
	
	type_by_class_and_generics (nm: READABLE_STRING_8; gc: INTEGER; attac: BOOLEAN)
	: detachable like type_at
		local
			str: STRING
			i, tid: INTEGER
		do
			Result := Precursor (nm, gc, attac)
			if not attached Result then
				if gc > 0 then
					create str.make_from_string (nm)
					if attac then
						str.precede ('!')
					end
					from
						i := gc
					until i = 0 loop
						if i = gc then
							str.extend (' ')
							str.extend ('[')
						else
							str.extend (',')
							str.extend (' ')
						end
						i := i - 1
						str.append (type_stack.below_top (i).fast_name)
					end
					str.extend (']')
				else
					if attac then
						str := "!" + nm
					else
						str := nm
					end
				end
				tid := dynamic_type_from_string (str)
				if attac then
					tid := attached_type (tid)
				else
					tid := detachable_type (tid)
				end
				if tid >= 0 then
					new_type (tid, attac)
					Result := last_type
				end
			end
		end
	
feature {IS_TYPE} -- Factory 

	new_type (tid: INTEGER; attack: BOOLEAN)
		local
			exp: IS_EXPANDED_TYPE
			nm: STRING
			id: INTEGER
		do
			Precursor (tid, attack)
			nm := last_type.fast_name
			nm := type_name_of_type (tid)
			if basic_idents.has (nm) and then attached {IS_NORMAL_TYPE} last_type as t then
				id := basic_idents.item (nm)
				create exp.make (id, t.base_class, Basic_expanded_flag, Void, Void, Void, Void, Void)
				t.copy (exp)
				all_types.force (t, id)
				nm := t.fast_name
			end
			if attack then
				id := attached_type (tid)
				if id /= tid then
					Precursor (id, attack)
				end
			end
		end

	new_field (t: attached like last_type; i: INTEGER)
		local
			at: like type_at
			last: like last_field
			nm: READABLE_STRING_8
			tid, fid: INTEGER
			attac: BOOLEAN
		do
			tid := t.ident
			nm := field_name (tid, i)
			fid := field_type_ident (tid, i)
			if fid > 0 then
				attac := fid = attached_type (fid)
				new_type (fid, attac)
				at := last_type
				check attached at end
				create last.make_in_system (nm, at, t, i, Current)
				last.set_offset (i + 1)
			end
			last_field := last
		end
	
	set_agent_base (a: IS_AGENT_TYPE)
		do
			-- Not yet implemented
		end
	
feature {} -- Auxiliary routines of factory 

	type_flags (tid: INTEGER): INTEGER
		do
			if basic_idents.has (type_name_of_type (tid)) then
				Result := Result | Basic_expanded_flag
			else
				Result := Result | Reference_flag
				if is_special_type (tid) then
					Result := Result | Flexible_flag	
				elseif is_tuple_type (tid) then
					Result := Result | Tuple_flag	
				end
			end
			if tid = attached_type (tid) then
				Result := Result | Attached_flag
			end
		end

	class_ident (tid: INTEGER): INTEGER
		local
			nm: READABLE_STRING_8
		do
			nm := class_name_of_type (tid)
			if attached class_by_name (nm) as cls then
				Result := cls.ident
			end
		end

	class_name (cid: INTEGER): READABLE_STRING_8
		do
			if valid_class (cid) then
				Result := all_classes [cid].fast_name
			else
				Result := no_class.fast_name
			end
		end
	
	agent_routine (tid: INTEGER): READABLE_STRING_8
		do
			-- Not yet implemented
			Result := ""
		end

	agent_pattern (tid: INTEGER): READABLE_STRING_8
		do
			-- Not yet implemented
			Result := ""
		end

	generic_count (tid: INTEGER): INTEGER
		do
			Result := generic_count_of_type (tid)
		end

	generic (tid, i: INTEGER): INTEGER
		do
			Result := generic_dynamic_type_of_type (tid, i + 1)
		end

	field_count (tid: INTEGER): INTEGER
		do
			Result := field_count_of_type (tid)
		end

	field_type_ident (tid, i: INTEGER): INTEGER
		do
			Result := field_static_type_of_type (i + 1, tid)
		end

	field_name (tid, i: INTEGER): READABLE_STRING_8
		do
			Result := field_name_of_type (i + 1, tid)
		end

	creation_ident (tid: INTEGER): INTEGER
		do
			Result := -1
		end

	routine_call (tid, i: INTEGER): POINTER
		do
			-- Not yet implemented
		end
	
feature -- Object creation 

	new_instance (t: IS_TYPE; use_default_creation: BOOLEAN): ANY
		require
			is_alive: t.is_alive and then not t.is_subobject
		do
			Result := new_instance_of (t.ident)
		end
	
	new_boxed_instance (t: IS_TYPE): ANY
		require
			is_alive: t.is_alive and then t.is_subobject
		do
			Result := new_instance_of (t.ident)
		end

	new_array (s: IS_SPECIAL_TYPE; n: NATURAL): ANY
		note
			return: "Create a new `SPECIAL' of type `s' and length `n'."
		require
			is_alive: s.is_alive and then s.is_special
		local
			sa: SPECIAL [detachable ANY]
			i: INTEGER
		do
			i := n.to_integer_32
			if s.item_type.is_basic then
				inspect s.item_type.ident
				when Boolean_ident then
					create {SPECIAL [BOOLEAN]} Result.make_filled (False, i)
				when Char8_ident then
					create {SPECIAL [CHARACTER_8]} Result.make_filled ('%U', i)
				when Char32_ident then
					create {SPECIAL [CHARACTER_32]} Result.make_filled ('%U', i)
				when Int8_ident then
					create {SPECIAL [INTEGER_8]} Result.make_filled (0, i)
				when Int16_ident then
					create {SPECIAL [INTEGER_16]} Result.make_filled (0, i)
				when Int32_ident then
					create {SPECIAL [INTEGER_32]} Result.make_filled (0, i)
				when Int64_ident then
					create {SPECIAL [INTEGER_64]} Result.make_filled (0, i)
				when Nat8_ident then
					create {SPECIAL [NATURAL_8]} Result.make_filled (0, i)
				when Nat16_ident then
					create {SPECIAL [NATURAL_16]} Result.make_filled (0, i)
				when Nat32_ident then
					create {SPECIAL [NATURAL_32]} Result.make_filled (0, i)
				when Nat64_ident then
					create {SPECIAL [NATURAL_64]} Result.make_filled (0, i)
				when Real32_ident then
					create {SPECIAL [REAL_32]} Result.make_filled (0, i)
				when Real64_ident then
					create {SPECIAL [REAL_64]} Result.make_filled (0, i)
				else
					check s.item_type.ident = Pointer_ident end
					create {SPECIAL [POINTER]} Result.make_filled (default_pointer, i)
				end
			else
				sa := new_special_any_instance (s.ident, i)
				Result := sa
			end
		end

feature -- Low level access 

	type_of_any (any: detachable ANY; static: detachable IS_TYPE): like type_at
		do
			if attached any as a then
				new_type (int_dynamic_type (a), True)
				Result := last_type
			end
		end

	as_agent (any: detachable ANY): detachable IS_AGENT_TYPE
		note
			return: "Cast type of `any' to an IS_AGENT_TYPE."
		do
			-- Not yet implemented
		end

	closed_operands (id: ANY; at: IS_AGENT_TYPE): TUPLE
		do
			-- Not yet implemented
			Result := []
		end

	once_by_address (loc: POINTER; is_status: BOOLEAN): detachable IS_ONCE_VALUE
		do
		end

	check_invariant (obj: POINTER; t: attached like type_at): BOOLEAN
		note
			return: "Check the invariant of an object of type `t' located at `obj'."
		require
			not_special: not t.is_subobject
			not_null: obj /= default_pointer
		local
			retried: BOOLEAN
		do
			if not retried then
				if attached t.invariant_function as r then
					-- Not yet implemented
				end
			end
		rescue
			Result := False
			retried := True
			retry
		end

	special_capacity (a: ANY; st: IS_SPECIAL_TYPE): NATURAL
		require
			a_not_void: attached a
			st_not_void: attached st
		local
			i: INTEGER
		do
			if st.item_type.is_basic then
				inspect st.item_type.ident
				when boolean_ident then
					if attached {SPECIAL [BOOLEAN]} a as sa then
						i:= sa.count
					end
				when Char8_ident then
					if attached {SPECIAL [CHARACTER_8]} a as sa then
						i:= sa.count
					end
				when Char32_ident then
					if attached {SPECIAL [CHARACTER_32]} a as sa then
						i:= sa.count
					end
				when Int8_ident then
					if attached {SPECIAL [INTEGER_8]} a as sa then
					i:= sa.count
					end
				when Int16_ident then
					if attached {SPECIAL [INTEGER_16]} a as sa then
						i:= sa.count
					end
				when Int32_ident then
					if attached {SPECIAL [INTEGER_32]} a as sa then
						i:= sa.count
					end
				when Int64_ident then
					if attached {SPECIAL [INTEGER_64]} a as sa then
						i:= sa.count
					end
				when Nat8_ident then
					if attached {SPECIAL [NATURAL_8]} a as sa then
						i:= sa.count
					end
				when Nat16_ident then
					if attached {SPECIAL [NATURAL_16]} a as sa then
						i:= sa.count
					end
				when Nat32_ident then
					if attached {SPECIAL [NATURAL_32]} a as sa then
						i:= sa.count
					end
				when Nat64_ident then
					if attached {SPECIAL [NATURAL_64]} a as sa then
						i:= sa.count
					end
				when Real32_ident then
					if attached {SPECIAL [REAL_32]} a as sa then
						i:= sa.count
					end
				when Real64_ident then
					if attached {SPECIAL [REAL_64]} a as sa then
						i:= sa.count
					end
				when Pointer_ident then
					if attached {SPECIAL [POINTER]} a as sa then
						i:= sa.count
					end
				else
				end
			elseif not st.item_type.is_subobject
				and then attached {SPECIAL [ANY]} a as sa
			 then
				i:= sa.count				
			end
			Result := i.to_natural_32
		end

feature {NONE} -- Implementation 

	any_name: STRING = "ANY"

	none_name: STRING = "NONE"

	basic_idents: HASH_TABLE [INTEGER, STRING]
		once
			create Result.make (50)
			Result.force (Boolean_ident, "BOOLEAN")
			Result.force (Char8_ident, "CHARACTER_8")
			Result.force (Char32_ident, "CHARACTER_32")
			Result.force (Int8_ident, "INTEGER_8")
			Result.force (Int16_ident, "INTEGER_16")
			Result.force (Int32_ident, "INTEGER_32")
			Result.force (Int64_ident, "INTEGER_64")
			Result.force (Nat8_ident, "NATURAL_8")
			Result.force (Nat16_ident, "NATURAL_16")
			Result.force (Nat32_ident, "NATURAL_32")
			Result.force (Nat64_ident, "NATURAL_64")
			Result.force (Real32_ident, "REAL_32")
			Result.force (Real64_ident, "REAL_64")
			Result.force (Pointer_ident, "POINTER")
		end
		
invariant
	
note
	
	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"
	
end
