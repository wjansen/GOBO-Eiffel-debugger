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
			put_known_ident,
			put_new_object,
			put_new_special,
			put_object,
			set_field,
			set_index
		end

create

	make

feature {NONE} -- Initialization 

	make (s: like system; act: BOOLEAN)
		do
			create missing_types.make (10)
			create missing_fields.make (100)
			create default_fields.make (100)
			create violated_invariants.make (100)
			create associated_classes.make (2*s.class_count + 1, Void)
			create associated_types.make (2*s.type_count + 1, Void)
			max_real := c_max_real
			Precursor (s, act)
		end

feature {PC_BASE} -- Initialization 

	reset
		do
			Precursor
			associated_classes.clear
			associated_types.clear
			missing_types.wipe_out
			missing_fields.wipe_out
			violated_invariants.wipe_out
			large_integer := False
			truncated_real := False
			not_utf8 := False
		end

feature -- Error codes 

	is_ok: BOOLEAN
		note
			return: "{
Could all source data be (converted and) strored
without leaving default settings?
}"
		do
			Result := not (large_integer or not_utf8) and then default_fields.is_empty and then missing_types.is_empty and then missing_fields.is_empty and then violated_invariants.is_empty
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

	default_fields: HASH_TABLE [IS_TYPE, attached like field]
			-- Attributes in the running system not occuring 
			-- in the store file (i.e. set to default values). 

	violated_invariants: HASH_TABLE [STRING, STRING]
			-- Names of classes violating the invariant. 

feature {PC_DRIVER} -- Push and pop data 

	pre_object (t: IS_TYPE; as_ref: BOOLEAN; id: detachable ANY)
		do
			if attached {IS_TYPE} associated (t) as dt then
				Precursor (dt, as_ref, id)
			else
				push_offset (system.any_type, void_ident)
			end
		end

	pre_agent (a: IS_AGENT_TYPE; id: detachable ANY)
		do
			if attached {IS_AGENT_TYPE} associated (a) as da then
				Precursor (da, id)
			else
				push_offset (system.any_type, void_ident)
			end
		end

	pre_special (s: IS_SPECIAL_TYPE; cap: NATURAL; id: detachable ANY)
		do
			if attached {IS_SPECIAL_TYPE} associated (s) as ds then
				Precursor (ds, cap, id)
			else
				push_offset (system.any_type, void_ident)
			end
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
				if field_type.is_double then
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
				if field_type.is_real then
					if d.abs >= max_real then
						if d < 0 then
							r := -c_max_real
						else
							r := c_max_real
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
				if attached {STRING} object as o then
					o.copy (s)
				end
			end
		end

	put_unicode (u: STRING_32)
		do
			if valid then
				if attached {STRING_32} object as o then
					o.copy (u)
				end
			end
		end

	put_known_ident (id: detachable ANY)
		do
			if valid then
				Precursor (id)
			end
		end

	put_new_object (t: IS_TYPE)
		do
			if attached associated (t) as dt then
				if valid or first then
					Precursor (dt)
				else
					last_ident := void_ident
				end
			else
				last_ident := void_ident
				if not missing_types.has (t) then
					missing_types.force (t, t)
				end
				if attached field as f and then not default_fields.has (f)
					and then attached field_type as ft and then valid
				 then
					default_fields.force (ft, f)
				end
			end
		end

	put_new_special (s: IS_SPECIAL_TYPE; cap: NATURAL)
		do
			if attached {IS_SPECIAL_TYPE} associated (s) as ds then
				if valid or first then
					Precursor (ds, cap)
				else
					last_ident := void_ident
				end
			else
				last_ident := void_ident
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

feature {PC_DRIVER} -- Object location 

	set_field (f: IS_FIELD; in: detachable ANY)
		do
			Precursor (f, in)
			valid := valid_field (f)
			if valid then
				if attached associated (f.type) as ft then
					field_type := ft
				else
					field_type := system.any_type
				end
			end
		end

	set_index (s: IS_SPECIAL_TYPE; i: NATURAL; in: ANY)
		local
			i0: detachable IS_FIELD
		do
			Precursor (s, i, in)
			i0 := s.item_0
			check attached i0 end
			valid := valid_field (i0)
			if valid then
				if field_type.is_basic then
					field_type := i0.type
				end
			end
		end

feature {NONE} -- Implementation 

	max_real: REAL_64

	valid: BOOLEAN
	
	associated_classes: PC_ANY_TABLE [detachable IS_CLASS_TEXT]

	associated_types: PC_ANY_TABLE [detachable IS_TYPE]

	associated (t: IS_TYPE): detachable IS_TYPE
		local
			bc: IS_CLASS_TEXT
			f: IS_FIELD
			fa: detachable IS_FIELD
			ocp, nm: STRING
			i, m, n: INTEGER
			failed: BOOLEAN
		do
			if associated_types.has (t) then
				Result := associated_types [t]
			else
				if t.is_agent and then attached {IS_AGENT_TYPE} t as a then
					if attached associated (a.base) as g then
						ocp := a.open_closed_pattern
						nm := a.routine_name
						Result := system.agent_by_base_and_routine (g, ocp, nm)
					else
						failed := True
					end
				else
					if attached {IS_NORMAL_TYPE} t as nt then
						bc := nt.base_class
						if not associated_classes.has (bc) then
							if attached system.class_by_name (bc.fast_name) as c then
								associated_classes.force (c, bc)
							else
								failed := True
							end
						end
					end
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
						Result := system.type_by_class_and_generics (t.class_name, i, t.is_attached)
					end
					system.pop_types (i)
				end
				if attached Result as r then
					associated_types.force (r, t)
					t.set_bytes (r.instance_bytes)
					t.set_allocate (r.allocate)
					t.adapt_flags (r)
					from
						n := t.attribute_count
						m := n.min (r.attribute_count)
						i := 0
					until i = n loop
						f := t.attribute_at (i)
						if t.is_normal then
							fa := r.attribute_by_name (f.fast_name)
						elseif i < m then
							fa := r.attribute_at (i)
						else
							fa := Void
						end
						if attached fa as a then
							f.set_offset (a.offset)
						end
						i := i + 1
					end
					from
						n := r.attribute_count
						i := 0
					until i = n loop
						fa := r.attribute_at (i) 
						if fa.offset < 0 then
							default_fields.force (r, fa)
						end
						i := i + 1
					end
				end
			end
		end

	put_object (obj: detachable ANY; t: detachable IS_TYPE)
		local
			failed: BOOLEAN
			vnm, fnm: STRING
			vid, fid: INTEGER
			conf: BOOLEAN
		do
			if obj /= Void then
				vid := int_dynamic_type (obj)
				fid := field_static_type_of_type (field.location, int_dynamic_type (object))
				vnm := type_name_of_type (vid)
				fnm := type_name_of_type (fid)
				conf := field_conforms_to (vid, fid)
			end
			if failed and then attached field as f then
				if not missing_fields.has (f)
					and then attached {IS_TYPE} system.type_of_any (obj, Void) as d
				 then
					missing_fields.force (d, f)
				end
			end
			if failed then
				last_ident := void_ident
			else
				Precursor (obj, t)
			end
		end

	valid_field (f: IS_FIELD): BOOLEAN
		do
			Result := attached object and then f.offset >= 0
		end
	
feature {NONE} -- External implementation 

	c_max_real: REAL_32
		external
			"C inline use <float.h>"
		alias
			"(EIF_REAL_32)FLT_MAX"
		end

	c_max_double: REAL_64
		external
			"C inline use <float.h>"
		alias
			"(EIF_REAL_64)DBL_MAX"
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
