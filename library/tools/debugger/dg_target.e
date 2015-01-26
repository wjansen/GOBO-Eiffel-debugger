note

	description:
	"[
	 Writing the persistence closure of an object as C code
	 readable by the debugger.
	 ]"
								
class DG_TARGET

inherit
	
	PC_C_TARGET
		rename
			make as make_c
		redefine
			reset,
			must_expand_strings,
			pre_special,
			pre_object,
			post_object,
			post_special,
			put_string,
			put_unicode,
			put_known_ident,
			put_void_ident,
			put_integer,
			put_naturals,
			finish,
			declaration,
			declare,
			declare_special,
			extra_key
		end

	KL_IMPORTED_STRING_ROUTINES
	
create

	make

feature {NONE} -- Initialization 

	make (a_file: like c_file;
				a_type_prefix, a_value_prefix, a_name: STRING;
				a_system: DG_SYSTEM)
		note
			action:
				"[
				 Create object for storing the system description. 
				 Write address definition of top object to the C file
				 like `void *a_name=&(void*)...;'.
				 ]"
			a_file: "C file"
			a_type_prefix: "type name prefix"
			a_value_prefix: "object name prefix"
			a_name: "name of top object"
			a_system: "System to store"
		require
			c_open: a_file.is_open_write
			type_prefix_not_empty: not a_type_prefix.is_empty
			value_prefix_not_empty: not a_value_prefix.is_empty
		local
			n: INTEGER
		do
			rts_name := a_name
			system := a_system
			n := a_system.type_count
			create type_names.make_filled (Void, 0, n)
			create extra_typedefs.make (199)
			create capacities.make (20)
			make_c (a_file, Void, Void,
							a_type_prefix, a_value_prefix, a_name, a_system, False, False)
			rts_name := a_name
			system := a_system
			n := a_system.type_count
			if attached pointer_home then
				-- Fill typeset of `pointer_home':
				pointer_home := system.any_type
				pointer_home := system.any_type.routine_at (0)
				pointer_home := system.any_type.field_at (0)
				pointer_home := system.once_at (0)
			end
		ensure
			c_file_set: c_file = a_file
			system_set: system = a_system
		end

feature {PC_BASE} -- Initialization 

	reset
		do
			Precursor
			in_array := False
			capacities.wipe_out
		end
	
feature {PC_DRIVER} -- Termination 

	finish (top: NATURAL; type: IS_TYPE)
		do
			if top /= void_ident then
				c_file.put_string (c_type_name (type))
				c_file.put_character ('*')
				c_file.put_character (' ')
				c_file.put_string (rts_name)
				c_file.put_character ('=')
				c_file.put_character ('&')
				c_file.put_string (name_prefix)
				c_file.put_natural_32 (top)
				c_file.put_character (';')
				c_file.put_new_line
			end
			c_file.flush
		end

feature -- Access

	must_expand_strings: BOOLEAN

	system: DG_SYSTEM
	
feature {PC_DRIVER} -- Pre and post handling of data 

	pre_object (t: IS_TYPE; id: NATURAL)
		local
			ready: BOOLEAN
		do
			if id /= void_ident then
				flush_declaration (id)
				declarations.remove (id)
				cached_id := 0
				c_file.put_string (declaration)
				length := length + declaration.count + 1
				if t.is_string or else t.is_unicode then
					c_file.put_string (string_decl)
					length := length + 4
				else
					c_file.put_character ('=')
					c_file.put_character ('{')
				end
			else
				c_file.put_character ('{')
			end
			length := length + 2
			if t.is_reference and then system.type_enums.has(t.c_name) then
				home_ident := system.type_enums.item(t.c_name) 
			end
		end

	post_object (t: IS_TYPE; id: NATURAL)
		do
			if t.is_string or else t.is_unicode then
				c_file.put_character ('"')
				c_file.put_character (';')
				c_file.put_new_line
				length := 0
			else
				c_file.put_character ('}')
				if t.is_special then
				elseif id = void_ident then
					c_file.put_character (',')
				else
					c_file.put_character (';')
					c_file.put_new_line
					length := 0
				end
			end
		end

	pre_special (st: IS_SPECIAL_TYPE; n: NATURAL; id: NATURAL)
		local
			k: NATURAL_64
		do
			in_array := capacities.has (id)
			if in_array then
				adapted_cap := capacities.item (id)
			else
				capacities.force (n, id)
				adapted_cap := n
			end
			adapted_cap := capacities.item (id)
			flush_declaration (id)
			declarations.remove (id)
			cached_id := 0
			k := extra_key(st, n)
			if extra_typedefs.has (k) then
				declaration.copy(extra_typedefs[k])
				declaration.append_character (' ')
				declaration.append (name_prefix)
				declaration.append_natural_32 (id)
			end
			c_file.put_string (declaration)
			length := length + declaration.count + 1
			tmp_str.wipe_out
			tmp_str.append_character ('=')
			tmp_str.append_character ('{')
			tmp_str.append_character ('{')
			c_file.put_string (tmp_str)
			length := length + tmp_str.count
			break
		end

	post_special (t: IS_SPECIAL_TYPE; id: NATURAL)
		do
			c_file.put_character ('}')
			c_file.put_character ('}')
			c_file.put_character (';')
			c_file.put_new_line
			length := 0
			if in_array then
				item_count := 0
				in_array := False
			end
		end

feature {PC_DRIVER} -- Handling of elementary data 

	put_string (s: STRING)
		local
			i, n: INTEGER
		do
			in_chars := True
			from
				n := s.count
				adapted_cap := n.to_natural_32
			until i = n loop
				i := i + 1
				put_character (s[i])
			end
			in_chars := False
		end

	put_unicode (u: STRING_32)
		local
			s: STRING
			i, n: INTEGER
		do
			in_chars := True
			s := u.as_string_8
			from
				n := s.count
				adapted_cap := n.to_natural_32
			until i = n loop
				i := i + 1
				put_character (s[i])
			end
			in_chars := False
		end

	put_known_ident (t: IS_TYPE; id: NATURAL)
		local
			stat: IS_TYPE
			skip: BOOLEAN
		do
			if in_array then
				item_count := item_count + 1
				skip := item_count > adapted_cap
			end
			if not skip then
				tmp_str.wipe_out
				stat := field_type
				if t /= stat or else t.is_special then
					tmp_str.append_character ('(')
					tmp_str.append (c_type_name (stat))
					tmp_str.append_character ('*')
					if t.is_special and then not t.generic_at (0).is_subobject then
						tmp_str.append_character ('*')
					end
					tmp_str.append_character (')')
				end
				if t.is_string or else t.is_unicode then
				else
					tmp_str.append_character ('&')
				end
				tmp_str.append (name_prefix)
				tmp_str.append_natural_32 (id)
				tmp_str.append_character (',')
				if capacities.has (id) then
					tmp_str.append_natural_32 (capacities.item (id))
					tmp_str.append_character (',')
				end
				length := length + tmp_str.count
				break	
				c_file.put_string (tmp_str)
			end
		end
	
	put_void_ident (stat: detachable IS_TYPE)
		do
			tmp_str.wipe_out
			tmp_str.append_character ('0')
			tmp_str.append_character (',')
			if stat /= Void and then
				(stat.is_special or else attached {IS_ARRAY[IS_NAME]} stat)
			 then
				tmp_str.append_character ('0')
				tmp_str.append_character (',')
			end
			length := length + tmp_str.count
			break
			c_file.put_string (tmp_str)
		end

feature {PC_DRIVER} -- Handling of elementary data
	
	put_integer (i: INTEGER_32)
		local
			n: INTEGER
		do
			n := i
			if field.has_name(once "_id") then
				n := home_ident
			end
			tmp_str.wipe_out
			if n = n.Min_value then
				tmp_str.append (int32)
				tmp_str.append (n.to_hex_string)
				tmp_str.extend ('U')
			else
				tmp_str.append_integer (n)
			end
			length := length + tmp_str.count + 1
			break
			c_file.put_string (tmp_str)
			c_file.put_character (',')
		end

  put_naturals (nn: SPECIAL [NATURAL_32]; n: INTEGER)
		local
			i: INTEGER
		do
			from
			until i = n loop
				tmp_str.wipe_out
				tmp_str.append_natural_32 (nn[i])
				length := length + tmp_str.count + 1
				break
				c_file.put_string (tmp_str)
				c_file.put_character (',')
				i := i + 1
			end
			index := n
		end
	
feature  {NONE} -- Implementation
	
	extra_key (st: IS_SPECIAL_TYPE; n: NATURAL): NATURAL_64
		local
			g: IS_TYPE
			gid, n1: NATURAL_64
		do
			g := st.item_type
			gid := g.ident.to_natural_64
			n1 := n.max (1)
			Result := (n1 |<< shift) | gid
		end

	declare_special (st: IS_SPECIAL_TYPE; n: NATURAL; id: NATURAL)
		local
			g: IS_TYPE
			s: like declaration
			gid: INTEGER
			k: NATURAL_64
		do
			if capacities.has (id) then
				adapted_cap := capacities.item (id)
			else
				capacities.force(n, id)
				adapted_cap := n
			end
			adapted_cap := adapted_cap.max (1)
			g := st.generic_at (0)
			gid := g.ident
			k := extra_key (st, adapted_cap)
			if not extra_typedefs.has (k) then
				create s.make_from_string (type_name_prefix)
				s.append_integer (gid)
				s.extend('_')
				s.append_natural_32 (adapted_cap)
				extra_typedefs[k] := s
				tmp_str.copy(typedef)
				tmp_str.append(struct)
				tmp_str.append (g.c_name)
				if not g.is_subobject then
					tmp_str.append_character ('*')
				end
				tmp_str.append (data)
				tmp_str.append_character ('[')
				tmp_str.append_natural_32 (adapted_cap)
				tmp_str.append (end_data)
				tmp_str.append_character (' ')
				tmp_str.append (s)
				tmp_str.append_character (';')
				c_file.put_string (tmp_str)
				c_file.put_new_line
			end
			create declaration.make (0)
			declaration.copy (extra_typedefs[k])
			declaration.append_character (' ')
			declaration.append (name_prefix)
			declaration.append_natural_32 (id)
			declarations.put (declaration, id)
			cached_id := id
		end

	declare (t: IS_TYPE; id: NATURAL)
		local
			g: IS_TYPE
			tn: STRING
		do
			create declaration.make (0)
			declaration.append (c_type_name(t))
			declaration.append_character (' ')
			declaration.append (name_prefix)
			declaration.append_natural_32 (id)
			declarations.put (declaration, id)
			cached_id := id
		end

	declaration: STRING --UC_UTF8_STRING
	
	capacities: DS_HASH_TABLE [NATURAL, NATURAL]

	item_count: NATURAL
	
	in_array: BOOLEAN
	
	rts_name: STRING

	pointer_home: ANY
	
	c_type_name(t: IS_TYPE): READABLE_STRING_8
		local
			str: STRING
		do
			if t.ident <= type_names.upper then
				Result := type_names [t.ident]
			end
			if Result = Void then
				if attached t.c_name as tn then
					Result := tn
				else
					create str.make (type_name_prefix.count+5)
					str.append (type_name_prefix)
					str.append_integer (t.ident)
					Result := str
				end
				type_names.force (Result, t.ident)
			end
		ensure
			type_names.has (Result)
		end
	
	type_names: ARRAY [detachable READABLE_STRING_8]

	home_ident: INTEGER
	
	string_decl: STRING = "[]=%""

	allocate: STRING = "allocate"

	instance: STRING = "default_instance"

	function_loc: STRING = "function_location"
	
	call_function: STRING = "call_function"
	
	function: STRING = "function"
	
	unboxed_location: STRING = "unboxed_location"
	
	instance_bytes: STRING = "instance_bytes"
	
	boxed_bytes: STRING = "boxed_bytes"

	co_tuple: STRING = ")->z1"
					
	struct: STRING = "struct {"

	int32: STRING = "(int32_t)0x"
	
	int64: STRING = "(int64_t)0x"
	
	sizeof: STRING = "sizeof("

	any_cast: STRING = "(T0*)"
	
	void_cast: STRING = "(void*)"

invariant

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
