note
	description:
	"[ 
	 Abstract descriptor of an Eiffel system capable 
	 of creating its classes and types. 
	 ]"

deferred class IS_FACTORY

inherit

	IS_SYSTEM

feature -- Status 

	type_exists (id: INTEGER): BOOLEAN
		deferred
		end

feature -- Factory 

	to_fill: BOOLEAN
			-- Are scanned objects to be filled by scanned items?
	
	new_class (cid, fl: INTEGER)
		note
			action:
			"[
			 Create class of ident `cid' if it does not yet exist
			 and put it into `all_classes'.
			 ]"
		require
			not_negative: cid >= 0
		local
			cls: detachable like class_at
		do
			if cid < all_classes.count then
				cls := all_classes [cid]
			end
			if not attached cls as c or else c.ident /= cid then
				create cls.make_in_system (cid, fl, class_name (cid), Current)
				all_classes.force (cls, cid)
			end
		ensure
			has_class: valid_class (cid)
		end

	new_type (tid: INTEGER; attac: BOOLEAN)
		note
			action:
			"[
			 Create type of ident `tid' if it does not yet exist
			 and put it into `all_types'.
			 ]"
		require
			not_negative: tid >= 0
		local
			t: like type_at
			nm, ocp: READABLE_STRING_8
			fl, cid: INTEGER
		do
			if tid < all_types.count and then attached all_types [tid] as ti then
				last_type := ti
			elseif type_exists (tid) then
				fl := type_flags (tid)
				if attac then
					fl := fl | Attached_flag
				end
				if fl & Flexible_flag = Flexible_flag then
					new_special_type (tid, fl)
					t := last_type
				elseif fl & Tuple_flag = Tuple_flag then
					new_tuple_type (tid, fl)
					t := last_type
				elseif fl & Agent_flag = Agent_flag then
					nm := agent_routine (tid)
					ocp := agent_pattern (tid)
					new_agent_type (tid, fl, nm, ocp)
					t := last_type
				else
					cid := class_ident (tid)
					new_class (cid, class_flags (cid))
					if attached class_at (cid) as bc then
						if fl & Subobject_flag = 0 then
							new_normal_type (tid, fl, bc)
						else
							new_expanded_type (tid, fl, bc)
						end
						t := last_type
					end
				end
				check attached t end
				all_types.force (t, tid)
			end
		ensure
			has_type: valid_type (tid)
		end

	new_field (t: attached like last_type; i: INTEGER)
		note
			action: "Create (if not exists) or provide field."
			t: "type of new field"
			i: "index of field"
		require
			not_negative: i >= 0
		local
			at: like type_at
			last: like last_field
			nm: READABLE_STRING_8
			id, fid: INTEGER
			attac: BOOLEAN
		do
			if t.valid_field (i)
				and then attached {like last_field} t.field_at (i) as lf
			 then
				last := lf
			end
			id := t.ident
			if t.is_agent then
				nm := no_name
			else
				nm := field_name (id, i)
				attac := nm [1].is_upper
			end
			fid := field_type_ident (id, i)
			new_type (fid, attac)
			at := all_types [fid]
			check attached at end
			if attached last then
				last.scan_in_system (id, fid, Current)
			else
				create last.make_in_system (nm, at, t, i, Current)
			end
			last_field := last
		end

feature {IS_TYPE,IS_FIELD} -- Factory 

	last_types: detachable IS_SEQUENCE [attached like type_at]

	last_type: like type_at

	last_field: detachable IS_FIELD

	last_fields: detachable IS_SEQUENCE [attached like last_field]

	last_typeset: detachable IS_SET [attached like type_at]

	last_once: like once_at

	add_type (t: attached like type_at)
		do
			all_types.force (t, t.ident)
		end
	
	set_generics_of_type (t: attached like type_at)
		local
			ta: like last_types
			id, gid: INTEGER
			i, n: INTEGER
		do
			id := t.ident
			all_types.force (t, id)
			if t.is_basic then
			else
				n := generic_count (id)
				ta := t.generics
				from
				until i = n loop
					gid := generic (id, i)
					new_type (gid, False)
					if to_fill and then attached {like type_at} last_type as tg then
						if not attached ta then
							create ta.make (n, tg)
						end
						check attached ta end
						ta.add (tg)
					end
					i := i + 1
				end
				last_types := ta
			end
		ensure
			has_t: type_at (t.ident) = t
			same_generics: attached t.generics as gen implies gen = last_types
		end
	
	set_single_generic_of_type (t: attached like type_at)
		require
			one_generic: t.generic_count = 1
		local
			gg: IS_SEQUENCE [attached like type_at]
			id, gid: INTEGER
		do
			id := t.ident
			all_types.force (t, id)
			gid := generic (id, 0)
			new_type (gid, False)
			if to_fill and then attached last_type as lt then
				create gg.make_1 (lt)
				t.generics.copy (gg)
			end
		ensure
			has_t: type_at (t.ident) = t
			same_generics: t.generic_count > 0 implies t.generic_at (0) = last_type
		end
	
	set_fields_of_type (t: attached like type_at)
		local
			fs: like last_fields
			id: INTEGER
			i, n: INTEGER
		do
			id := t.ident
			all_types.force (t, id)
			if t.is_basic then
			else
				n := field_count (id)
				from
				until i = n loop
					new_field (t, i)
					if to_fill and then attached last_field as f then
						if not attached fs then
							create fs.make (n, f)
						end
						check attached fs end
						fs.add (f)
					end
					i := i + 1
				end
			end
			if to_fill then
				last_fields := fs
			else
				last_fields := t.fields
			end
		ensure
			has_t: type_at (t.ident) = t
			same_fields: attached t.fields as attr implies attr = last_fields
		end
	
	set_agent_base (a: IS_AGENT_TYPE)
		deferred
		ensure
			when_set: last_type = a.base
		end

	set_field_typeset (tid, fid: INTEGER; is_attached: BOOLEAN)
		require
			valid_type: valid_type (tid)
		local
			ts: like last_typeset
			i, j, k, n: INTEGER
		do
			k := typeset_index (tid, fid)
			n := typeset_size (k)
			if n > 0 then
				create ts.make (n, any_type)
				from
				until i = n loop
					j := typeset_tid (k, i)
					new_type (j, is_attached)
					ts.add (last_type)
					i := i + 1
				end
			end
			last_typeset := ts
		ensure
			same_typeset: t.valid_field (i)
										and then attached t.field_at (i).type_set as ts
										implies ts = last_typeset
		end

	item_name (i: INTEGER): READABLE_STRING_8
		require
			i_not_negative: i >= 0
		local
			str: STRING
		do
			if item_names.upper < i then
				item_names.conservative_resize (item_names.lower, i)
			end
			if attached item_names [i] as nm
				and then not STRING_.same_string(nm, no_name)
			 then
				Result := nm
			else
				create str.make (8)
				str.append (once "item_")
				str.append_integer (i)
				item_names.force (str, i)
				Result := str
			end
		end

	operand_name (tid, fid, oid: INTEGER): READABLE_STRING_8
		note
			return: "Name of agent's operand."
			tid: "agent's type ident"
			fid: "index within closed operands array"
			oid: "index of routine operand"
		require
			fid_not_negative: fid >= 0
			oid_large_enough: oid >= fid
		local
			str: STRING
		do
			if operand_names.upper < oid then
				operand_names.conservative_resize (operand_names.lower, oid)
			end
			if attached operand_names [oid] as nm
				and then not STRING_.same_string(nm, no_name) then
				Result := nm
			else
				create str.make (8)
				str.append (once "op_")
				str.append_integer (oid)
				operand_names.force (str, oid)
				Result := str
			end
		end
	
feature {} -- Auxiliary routines of factory 

	new_normal_type (id, fl: INTEGER; bc: attached like class_at)
		require
			id_positive: id > 0
			normal_flag: fl & Flexible_flag = 0 and fl & Tuple_flag = 0
									 and fl & Agent_flag = 0 
		local
			nt: IS_NORMAL_TYPE
		do
			create nt.make_in_system (id, fl, bc, Current)
			last_type := nt
		ensure
			last_typeset: attached last_type as t and then t.ident = id
		end

	new_expanded_type (id, fl: INTEGER; bc: attached like class_at)
		require
			id_positive: id >= 0
			normal_flag: fl & Subobject_flag = Subobject_flag
									 and fl & Flexible_flag = 0
									 and fl & Tuple_flag = 0
									 and fl & Agent_flag = 0 
		local
			et: IS_EXPANDED_TYPE
		do
			create et.make_in_system (id, fl, bc, Current)
			last_type := et
		ensure
			last_typeset: attached last_type as t and then t.ident = id
		end

	new_special_type (id, fl: INTEGER)
		require
			id_positive: id > 0
			normal_flag: fl & Flexible_flag = Flexible_flag
		local
			st: IS_SPECIAL_TYPE
		do
			create st.make_in_system (id, fl, Current)
			last_type := st
		ensure
			last_typeset: attached last_type as t and then t.ident = id
		end

	new_tuple_type (id, fl: INTEGER)
		require
			id_positive: id > 0
			normal_flag: fl & Tuple_flag = Tuple_flag
		local
			tt: IS_TUPLE_TYPE
		do
			create tt.make_in_system (id, fl, Current)
			last_type := tt
		ensure
			last_typeset: attached last_type as t and then t.ident = id
		end

	new_agent_type (id, fl: INTEGER; nm, ocp: READABLE_STRING_8)
		require
			id_positive: id > 0
			normal_flag: fl & Agent_flag = Agent_flag
		local
			at: IS_AGENT_TYPE
		do
			create at.make_in_system (id, fl, nm, ocp, Current)
			last_type := at
		ensure
			last_typeset: attached last_type as t and then t.ident = id
		end

	type_flags (tid: INTEGER): INTEGER
		require
			type_exists: type_exists (tid)
		deferred
		end

	class_ident (tid: INTEGER): INTEGER
		require
			type_exists: type_exists (tid)
		deferred
		end

	class_name (tid: INTEGER): READABLE_STRING_8
		deferred
		end

	class_flags (cid: INTEGER): INTEGER
		require
			class_exists: class_exists (tid)
		deferred
		end

feature {IS_TYPE} -- Auxiliary routines of factory 

	agent_routine (tid: INTEGER): READABLE_STRING_8
		require
			type_exists: type_exists (tid)
			not_valid: not valid_type (tid)
		deferred
		end

	agent_pattern (tid: INTEGER): READABLE_STRING_8
		require
			type_exists: type_exists (tid)
			not_valid: not valid_type (tid)
		deferred
		end

	generic_count (tid: INTEGER): INTEGER
		require
			type_exists: valid_type (tid)
		deferred
		end

	generic (tid, i: INTEGER): INTEGER
		require
			type_exists: valid_type (tid)
		deferred
		end

	field_count (tid: INTEGER): INTEGER
		require
			type_exists: valid_type (tid)
		deferred
		end

	field_type_ident (tid, i: INTEGER): INTEGER
		require
			type_exists: valid_type (tid)
		deferred
		end

	field_name (tid, i: INTEGER): READABLE_STRING_8
		require
			type_exists: valid_type (tid)
		deferred
		end

	creation_ident (tid: INTEGER): INTEGER
		note
			return:
			"[
			 Index of routine describing the default creation of type
			 having index `tid'; negative if no such routine exists.
			 ]"
		require
			type_exists: valid_type (tid)
		deferred
		end

	routine_call (tid, i: INTEGER): POINTER
		require
			type_exists: valid_type (tid)
		deferred
		end

	type_class (tid: INTEGER): detachable like class_at
		note
			return:
			"[
			 Create class for type of ident `tid' if it does not yet exist
			 and put it into `all_classes'.
			 ]"
		require
			type_exists: type_exists (tid)
		local
			t: like type_at
		do
			new_type (tid, False)
			t := all_types [tid]
			if attached {IS_NORMAL_TYPE} t as n then
				Result := n.base_class
			end
		end

	typeset_index (tid, fid: INTEGER): INTEGER
		deferred
		end
	
	typeset_size (ts: INTEGER): INTEGER
		deferred
		end
	
	typeset_tid (ts, i: INTEGER): INTEGER
		deferred
		end
	
feature {} -- Implementation 

	item_names: ARRAY [READABLE_STRING_8]
		once
			create Result.make_filled (no_name, 0, 20)
		end

	operand_names: ARRAY [READABLE_STRING_8]
		once
			create Result.make_filled (no_name, 0, 20)
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
