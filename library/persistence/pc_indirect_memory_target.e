note

	description:
		"[ 
		 Restoring the persistence closure of one object in memory. 
		 Type descriptions are taken from a remote description. 
		 ]"

class PC_INDIRECT_MEMORY_TARGET

inherit

	PC_MEMORY_TARGET
		redefine
			make,
			reset,
			pre_object,
			pre_agent,
			pre_special,
			post_object,
			post_agent,
			post_special,
			put_boolean,
			put_character,
			put_character_32,
			put_integer,
			put_natural,
			put_integer_64,
			put_natural_64,
			put_real,
			put_double,
			put_pointer,
			put_string,
			put_unicode,
			put_new_object,
			put_new_special,
			put_booleans,
			put_characters,
			put_characters_32,
			put_integers_8,
			put_integers_16,
			put_integers,
			put_integers_64,
			put_naturals_8,
			put_naturals_16,
			put_naturals,
			put_naturals_64,
			put_reals,
			put_doubles,
			put_pointers,
			field,
			field_type,
			set_field,
			set_index
		end

create

	make

feature {NONE} -- Initialization 

	make (s: like system; act: BOOLEAN)
		local
			s0: STRING
			u0: STRING_32
		do
			create missing_types.make (10)
			create missing_fields.make (100)
			create inconsistent_fields.make (100)
			create default_fields.make (100)
			create violated_invariants.make (100)
			create associated_classes.make (2*s.class_count + 1)
			create associated_types.make (2*s.type_count + 1)
			create valid_stack.make (20)
			Precursor (s, act)
			-- Guru section: add some types to the type set of `object':
			s0 := ""
			u0 := s0
			object := s0
			object := u0
		end

feature {PC_BASE} -- Initialization 

	reset
		do
			Precursor
			associated_classes.clear
			associated_types.clear
			valid_stack.wipe_out
			missing_types.wipe_out
			missing_fields.wipe_out
			inconsistent_fields.wipe_out
			default_fields.wipe_out
			violated_invariants.wipe_out
			large_integer := False
			truncated_real := False
			not_utf8 := False
			valid := True
		end

feature -- Error codes 

	is_ok: BOOLEAN
		note
			return:
			"[
			 Could all source data be (converted and) strored
			 without leaving default settings?
			 ]"
		do
			Result := not (large_integer or not_utf8)
				and then default_fields.is_empty
				and then missing_types.is_empty
				and then missing_fields.is_empty
				and then inconsistent_fields.is_empty
				and then violated_invariants.is_empty
		end

	large_integer: BOOLEAN
			-- Did the source contain not fitting INTEGER_* attributes? 

	truncated_real: BOOLEAN
			-- Did the source contain too large REAL_32 attributes 
			-- (since they are originally large REAL_64s) 

	not_utf8: BOOLEAN
			-- Did the source contain a not convertible UTF8 string? 

	missing_types: HASH_TABLE [IS_TYPE, IS_TYPE]
			-- Types occuring in the store file 
			-- but not available in the running system. 

	missing_fields: HASH_TABLE [IS_TYPE, attached like field]
			-- Attributes occuring in the store file 
			-- but not available in the running system. 

	inconsistent_fields: HASH_TABLE [IS_TYPE, attached like field]
			-- Attributes occuring in the store file 
			-- but of not belonging to the typeset of the attribute
			-- in the running system
 
	default_fields: HASH_TABLE [IS_TYPE, attached like field]
			-- Attributes in the running system not occuring 
			-- in the store file (i.e. set to default values). 

	violated_invariants: HASH_TABLE [STRING, STRING]
			-- Names of classes violating the invariant. 

feature {PC_DRIVER} -- Push and pop data 
	
	pre_object (t: IS_TYPE; id: detachable ANY)
		do
			valid_stack.force (valid)
			if attached associated (t) as dt then
				valid := true
				Precursor (dt, id)
			else
				valid := false
				push_offset (system.any_type, void_ident)
			end
		end

	post_object (t: IS_TYPE; id: detachable ANY)
		do
			if attached id and then attached {IS_TYPE} associated (t) as dt then
				Precursor (dt, id)
			else
				pop_offset
			end
			valid := valid_stack.item
			valid_stack.remove
		end
	
	pre_agent (a: IS_AGENT_TYPE; id: detachable ANY)
		do
			valid_stack.force (valid)
			if id /= Void and then attached {IS_AGENT_TYPE} associated (a) as da then
				valid := true
				Precursor (da, id)
			else
				push_offset (system.any_type, void_ident)
				valid := false
			end
		end

	post_agent (a: IS_AGENT_TYPE; id: detachable ANY)
		do
			if id /= Void and then attached {IS_AGENT_TYPE} associated (a) as da then
				Precursor (a, id)
			else
				pop_offset
			end
			valid := valid_stack.item
			valid_stack.remove
		end
		
	pre_special (s: IS_SPECIAL_TYPE; n: NATURAL; id: detachable ANY)
		do
			valid_stack.force (valid)
			if id /= Void and then attached {IS_SPECIAL_TYPE} associated (s) as ds then
				valid := true
				Precursor (ds, n, id)
			else
				push_offset (system.any_type, void_ident)
				valid := false
			end
		end
	
	post_special (s: IS_SPECIAL_TYPE; id: detachable ANY)
		do
			if id /= Void and then attached {IS_SPECIAL_TYPE} associated (s) as ds then
				Precursor (s, id)
			else
				pop_offset
			end
			valid := valid_stack.item
			valid_stack.remove
		end
	
feature {PC_DRIVER} -- Writing elementary data 

	put_boolean (b: BOOLEAN)
		do
			if valid then
				Precursor (b)
			end
		end

	put_character (c: CHARACTER)
		do
			if valid then
				Precursor (c)
			end
		end

	put_character_32 (c: CHARACTER_32)
		do
			if valid then
				Precursor (c)
			end
		end

	put_integer (i: INTEGER_32)
		do
			if valid then
				inspect field_type.ident
				when Int8_ident then
					Precursor (i)
					if (i < {INTEGER_8}.Min_value) or else (i > {INTEGER_8}.Max_value) then
						large_integer := True
					end
				when Int16_ident then
					Precursor (i)
					if (i < {INTEGER_16}.Min_value) or else (i > {INTEGER_16}.Max_value) then
						large_integer := True
					end
				when Int64_ident then
					put_integer_64 (i)
				else
					Precursor (i)
				end
			end
		end

	put_natural (n: NATURAL_32)
		do
			if valid then
				inspect field_type.ident
				when Nat8_ident then
					Precursor (n)
					if n > {NATURAL_8}.Max_value then
						large_integer := True
					end
				when Nat16_ident then
					Precursor (n)
					if n > {NATURAL_16}.Max_value then
						large_integer := True
					end
				when Nat64_ident then
					put_natural_64 (n)
				else
					Precursor (n)
				end
			end
		end

	put_integer_64 (i: INTEGER_64)
		do
			if valid then
				inspect field_type.ident
				when Int8_ident then
					put_integer (i.to_integer_32)
					if (i < {INTEGER_8}.Min_value) or else (i > {INTEGER_8}.Max_value) then
						large_integer := True
					end
				when Int16_ident then
					put_integer (i.to_integer_32)
					if (i < {INTEGER_16}.Min_value) or else (i > {INTEGER_16}.Max_value) then
						large_integer := True
					end
				when Int32_ident then
					put_integer (i.to_integer_32)
					if (i < {INTEGER_32}.Min_value) or else (i > {INTEGER_32}.Max_value) then
						large_integer := True
					end
				else
					Precursor (i)
				end
			end
		end

	put_natural_64 (n: NATURAL_64)
		do
			if valid then
				inspect field_type.ident
				when Nat8_ident then
					put_natural (n.to_natural_32)
					if n > {NATURAL_8}.Max_value then
						large_integer := True
					end
				when Nat16_ident then
					put_natural (n.to_natural_32)
					if n > {NATURAL_16}.Max_value then
						large_integer := True
					end
				when Nat32_ident then
					put_natural (n.to_natural_32)
					if n > {NATURAL_32}.Max_value then
						large_integer := True
					end
				else
					Precursor (n)
				end
			end
		end

	put_real (r: REAL_32)
		do
			if valid then
				if attached type_set as ts and then ts [0].is_double then
					put_double (r)
				else
					Precursor (r)
				end
			end
		end

	put_double (d: REAL_64)
		local
			r: REAL_32
		do
			if valid then
				if attached type_set as ts and then ts [0].is_real then
					if d.abs > {REAL_32}.Max_value then
						r := {REAL_32}.Max_value
						if d < 0 then
							r := - r
						end
					else
						r := d.truncated_to_real
						truncated_real := True
					end
					put_real (r)
				else
					Precursor (d)
				end
			end
		end

	put_pointer (p: POINTER)
		do
			if valid then
				Precursor (p)
			end
		end

	put_string (s: STRING)
		do
			if valid then
				Precursor (s)
			end
		end
	
	put_unicode (u: STRING_32)
		do
			if valid then
				Precursor (u)
			end
		end

	put_new_object (t: IS_TYPE)
		do
			if attached associated (t) as dt
				and then dt.allocate /= default_pointer
			 then
				Precursor (dt)
			else
				last_ident := void_ident
				valid := False
				if not missing_types.has (t) then
					missing_types.force (t, t)
				end
				if attached field as f and then not inconsistent_fields.has (f)
					and then attached field_type as ft and then valid
				 then
					inconsistent_fields.force (ft, f)
				end
			end
		end

	put_new_special (s: IS_SPECIAL_TYPE; n, cap: NATURAL)
		do
			if attached {IS_SPECIAL_TYPE} associated (s) as ds then
				Precursor (ds, n, cap)
			else
				last_ident := void_ident
				valid := False
				if not missing_types.has (s) then
					missing_types.force (s, s)
				end
				if attached field as f and then not default_fields.has (f)
					and then attached field_type as ft and then valid
				 then
					default_fields.force (ft, f)
				end
			end
		end

feature {PC_DRIVER} -- Writing array data

	put_booleans (bb: SPECIAL [BOOLEAN]; n: INTEGER)
		do
			if valid then
				Precursor (bb, n)
			end
		end

	put_characters (cc: SPECIAL [CHARACTER]; n: INTEGER)
		do
			if valid then
				Precursor (cc, n)
			end
		end
			
	put_characters_32 (cc: SPECIAL [CHARACTER_32]; n: INTEGER)
		do
			if valid then
				Precursor (cc, n)
			end
		end
			
	put_integers_8 (ii: SPECIAL [INTEGER_8]; n: INTEGER)
		do
			if valid then
				Precursor (ii, n)
			end
		end
			
	put_integers_16 (ii: SPECIAL [INTEGER_16]; n: INTEGER)
		do
			if valid then
				Precursor (ii, n)
			end
		end
			
	put_integers (ii: SPECIAL [INTEGER_32]; n: INTEGER)
		do
			if valid then
				Precursor (ii, n)
			end
		end
			
	put_integers_64 (ii: SPECIAL [INTEGER_64]; n: INTEGER)
		do
			if valid then
				Precursor (ii, n)
			end
		end
			
	put_naturals_8 (nn: SPECIAL [NATURAL_8]; n: INTEGER)
		do
			if valid then
				Precursor (nn, n)
			end
		end
			
	put_naturals_16 (nn: SPECIAL [NATURAL_16]; n: INTEGER)
		do
			if valid then
				Precursor (nn, n)
			end
		end
			
	put_naturals (nn: SPECIAL [NATURAL_32]; n: INTEGER)
		do
			if valid then
				Precursor (nn, n)
			end
		end
			
	put_naturals_64 (nn: SPECIAL [NATURAL_64]; n: INTEGER)
		do
			if valid then
				Precursor (nn, n)
			end
		end
			
	put_reals (rr: SPECIAL [REAL_32]; n: INTEGER)
		do
			if valid then
				Precursor (rr, n)
			end
		end
			
	put_doubles (dd: SPECIAL [REAL_64]; n: INTEGER)
		do
			if valid then
				Precursor (dd, n)
			end
		end
			
	put_pointers (pp: SPECIAL [POINTER]; n: INTEGER)
		do
			if valid then
				Precursor (pp, n)
			end
		end
			
feature {PC_DRIVER} -- Object location 

	set_field (f: IS_FIELD; in: detachable ANY)
		note
			f: "field in the source"
		do
			Precursor (f, in)
			valid := valid_field (f)
			if valid then
				set_field_type_and_typeset (f)
			end
		end

	set_index (s: IS_SPECIAL_TYPE; i: NATURAL; in: ANY)
		note
			s: "type of object in the source"
		do
			Precursor (s, i, in)
			if attached s.item_0 as i0 then
				valid := valid_field (i0)
				if valid then
					set_field_type_and_typeset (i0)
				end
			else
				valid := False
			end
		end

feature {NONE} -- Implementation 

	field: detachable IS_FIELD
		-- Field as defined in the source.
	
	field_type: detachable IS_TYPE
		-- Type of the field associated to `field'.
	
	type_set: detachable IS_SEQUENCE [IS_TYPE]
		-- Typeset of the field associated to `field'.

	minor: INTEGER
	
	valid: BOOLEAN
	
	associated_classes: PC_ANY_TABLE [detachable IS_CLASS_TEXT]

	associated_types: PC_ANY_TABLE [detachable IS_TYPE]

	associated (t: IS_TYPE): detachable IS_TYPE
		local
			bc: IS_CLASS_TEXT
			fr: IS_FIELD
			ft: detachable IS_FIELD
			ocp, nm: STRING
			i, m, n: INTEGER
			attac, failed, needs_fields: BOOLEAN
		do
			if associated_types.has (t) then
				Result := associated_types [t]
			else
				nm := t.out	-- for test only
				if t.is_agent and then attached {IS_AGENT_TYPE} t as a then
					if attached associated (a.base) as g then
						ocp := a.open_closed_pattern
						nm := a.routine_name
						Result := system.agent_by_base_and_routine (g, ocp, nm)
					else
						failed := True
					end
				elseif t.is_special and then attached {IS_SPECIAL_TYPE} t as st then
					needs_fields := True
					Result := associated (st.item_type)
					failed := not attached Result
					if not failed then
						Result := system.special_type_by_item_type (Result, attac)
					end
				else
					from
						n := t.generic_count
					until failed or else i = n loop
						if attached associated (t.generic_at (i)) as g then
							system.push_type (g.ident)
							i := i + 1
						else
							failed := True
						end
					end
					if not failed then
						if t.is_normal and then attached {IS_NORMAL_TYPE} t as nt then
							needs_fields := True
							bc := nt.base_class
							if not associated_classes.has (bc) then
								if attached system.class_by_name (bc.name) as c then
									associated_classes.put (c, bc)
								else
									failed := True
								end
							end
							if not failed then
								Result := system.type_by_class_and_generics (t.class_name, n, attac)
							end
						else
							Result := system.tuple_type_by_generics (n, attac)
						end
					end
					system.pop_types (i)
				end
				if attached Result as r then
					nm := Result.out	-- for test only
					associated_types.put (r, t)
					t.set_bytes (r.instance_bytes)
					t.set_allocate (r.allocate)
					t.adapt_flags (r)
					from
						n := r.field_count
						m := n.min (t.field_count)
						i := 0
					until i = n loop
						fr := r.field_at (i)
						if r.is_normal then
							ft := t.field_by_name (fr.name)
						elseif i < m then
							ft := t.field_at (i)
						else
							ft := Void
							default_fields.force (t, fr)
						end
						if attached ft as a then
							a.set_offset (fr.offset)
							a.set_type_set (fr.type_set)
						end
						i := i + 1
					end
					from
						i := t.field_count
					until i = 0 loop
						i := i - 1
						ft := t.field_at (i)
						if ft.offset < 0 then
							missing_fields.force (t, ft)
						end
					end
				end
			end
		end

	set_field_type_and_typeset (f: IS_FIELD)
		require
			valid: valid
		do
			if attached associated (f.type) as ft then
				field_type := ft
				type_set := f.type_set
			else
				valid := False
				field_type := system.none_type
				type_set := Void
			end
		end
	
	valid_field (f: IS_FIELD): BOOLEAN
		do
			Result := object /= Void and then f.offset >= 0
		end
	
	valid_stack: ARRAYED_STACK [BOOLEAN]

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
