note

	description: "Writing the type definitons as C code."

class ET_TYPE_TARGET

inherit
	
	PC_STATISTICS_TARGET
		rename
			make as make_stat
		redefine
			put_new_object,
			put_new_special,
			finish,
			must_expand_strings
		end
	
create

	make

feature {} -- Initialization 

	make (a_file: like h_file; a_prefix: STRING; a_generator: like c_generator)
		local
			n: INTEGER
		do
			make_stat (False)
			c_generator := a_generator
			h_file := a_file
			type_prefix := a_prefix
			n := c_generator.compilee.type_count
			create name_table.make_filled (Void, 0, n)
			create declared_table.make_filled (False, 0, n)
			create defined_table.make_filled (False, 0, n)
		end
	
feature -- Access

	c_generator: ET_INTROSPECT_GENERATOR
	
	must_expand_strings: BOOLEAN = True

feature {PC_DRIVER} -- Put new data 

	put_new_object (t: IS_TYPE)
		do
			Precursor (t)
			put_typedef (t)
		end

	put_new_special (st: IS_SPECIAL_TYPE; cap: NATURAL)
		do
			Precursor (st, cap)
			put_typedef (st)
		end

	finish (top: NATURAL; t: detachable IS_TYPE)
		local
			sys: IS_SYSTEM
			i: INTEGER
		do
			h_file.put_string("%Npublic string* chars(GE_STRING_8* s) {%N")
			h_file.put_string("return s.area!=null ? ")
			h_file.put_string("(string*)s.area.item : null;%N}")
			h_file.flush
		end

feature {}
	
	put_typedef (t: IS_TYPE)
		require
			has_c_name: attached t.c_name
		local
			f: IS_FIELD
			r: IS_ROUTINE
			tn: STRING
			i, j, k, tid: INTEGER
		do
			tid := t.ident
			if tid > name_table.upper or else not attached name_table[tid] then
				tn:= t.c_name
				if t.is_basic then
					i := tn.index_of('_', 1)
					if i > 0 then
						tn := tn.twin
						tn.remove_tail(2)
					end
					name_table.force (tn, tid)
				else
					from
						i := t.generic_count
					until i = 0 loop
						i := i - 1
						put_typedef (t.generic_at (i))
					end
					if not declared_table [tid] then
						name_table.force (tn, tid)
						declared_table.force (True, tid)
					end
					from
						i := t.field_count
					until i = 0 loop
						i := i - 1
						f := t.field_at (i)
						put_typedef (f.type)
						if attached f.type_set as ts then
							from
								j := ts.count
							until j = 0 loop
								j := j - 1
								put_typedef (ts [j])
							end
						end
					end
					from
						i := t.routine_count
					until i = 0 loop
						i := i - 1
						r := t.routine_at (i)
						from
							k := r.variable_count
						until k = 0 loop
							k := k - 1
							if attached r.var_at(k) as v then
								put_typedef (v.type)
								if attached v.type_set as ts then
									from
										j := ts.count
									until j = 0 loop
										j := j - 1
										put_typedef (ts [j])
									end
								end
							end
						end
					end
					if not defined_table [tid] then
						put_type_struct (t)
						defined_table.force (TRUE, tid)
					end
				end
			end
		end
	
	put_type_struct (t: IS_TYPE)
		require
			has_c_name: attached t.c_name
		local
			f: IS_FIELD
			ft: IS_TYPE
			tn, sn, fn: STRING
			i, n, tid: INTEGER
		do
			tid := t.ident
			if not t.is_basic then
				tn := t.c_name
				h_file.put_string (once "public struct ")
				h_file.put_string (tn)
				h_file.put_character (' ')
				h_file.put_character ('{')
				if t.flags & t.Missing_id_flag = 0 then
					h_file.put_new_line
					h_file.put_string (once "%Tint id;")
				end
				from
					n := t.field_count
					i := 0
				until i = n loop
					f := t.field_at (i)
					ft := f.type
					h_file.put_new_line
					h_file.put_character ('%T')
					h_file.put_string (name_table[ft.ident])
					if not ft.is_subobject then
						h_file.put_character ('*')
					end
					h_file.put_character (' ')
					h_file.put_string (f.name)
					if (t.is_special and then f.has_name(once "item")) then
						h_file.put_string ("[1]")
					end
					h_file.put_character (';')
					i := i + 1
				end
				h_file.put_new_line
				h_file.put_character ('}')
				h_file.put_new_line
				h_file.put_string ("public const int ")
				h_file.put_string (tn)
				h_file.put_string ("_ID = ")
				h_file.put_integer (tid)
				h_file.put_character (';')
				h_file.put_new_line
				if t.is_alive and then t.is_special
					and then attached {IS_SPECIAL_TYPE} t as sp
				 then
					sn := name_table[sp.item_type.ident]
					fn := sp.item_type.c_name.as_lower
					put_functions(tn, sn, fn, sp.item_type.is_subobject, false);
				elseif attached {IS_NORMAL_TYPE} t as nt 
					and then array_names.has(nt.base_class.name) then
					sn := name_table[nt.generic_at(0).ident]
					fn := name_table[t.ident].as_lower
					put_functions(tn, sn, fn, false, true);
				end
				h_file.put_new_line
				h_file.flush
			end
		end
	
	put_functions(tn, in, fn: STRING; is_expanded, is_array: BOOLEAN)
		note
			action: "Put functions for array access."
			tn: "name of array or special type"
			in: "name of item type"
			fn: "prefix of function name"
			is_expanded: "Is the item type expanded?"
			is_array: "Is this an IS_ARRAY type?"
		do
			h_file.put_string ("public uint ")
			h_file.put_string (fn)
			if is_array then
				h_file.put_string ("_count(")
			else
				h_file.put_string ("_size(")
			end
			h_file.put_string (tn)
			h_file.put_string ("* x)%N%T{ return x!=null ? x.count : 0; }")
			h_file.put_new_line
			h_file.put_string ("public ")
			h_file.put_string (in)
			h_file.put_character (' ')
			if not is_expanded then
				h_file.put_character ('*')
			end
			h_file.put_string (fn)
			if is_array then
				h_file.put_character ('(')
			else
				h_file.put_string ("_at(")
			end
			h_file.put_string (tn)
			h_file.put_string("* x, uint i)%N%T{ return x!=null ? ")
			if is_array then
				h_file.put_string ("x.data.item[i] : ")
			else
				h_file.put_string ("x.item[i] : ")
			end
			if not is_expanded then
				h_file.put_string ("null")
			else
				h_file.put_character ('0');
			end
			h_file.put_string ("; }")
			h_file.put_new_line
		end
	
feature {} -- Implementation
	
	h_file: PLAIN_TEXT_FILE

	type_prefix: STRING
	
	name_table: ARRAY [detachable READABLE_STRING_8]

	declared_table, defined_table: ARRAY [BOOLEAN]

	array_names: DS_ARRAYED_LIST[STRING]
		once
			create Result.make_equal(5)
			Result.put_last("IS_ARRAY")
			Result.put_last("IS_SEQUENCE")
			Result.put_last("IS_SET")
			Result.put_last("IS_STACK")
			Result.put_last("IS_SPARSE_ARRAY")			
		end
	
invariant

end
