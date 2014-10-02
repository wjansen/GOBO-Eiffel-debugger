note

	description:
	"[
	 Writing the persistence closure of an object as C code
	 readable by the debugger.
	 ]"
								
class DG_TARGET

inherit
	
	PC_ABSTRACT_TARGET
		redefine
			reset,
			must_expand_strings,
			put_new_object,
			put_new_special,
			put_void_ident,
			pre_object,
			post_object,
			pre_new_object,
			pre_special,
			post_special,
			pre_new_special,
			pre_agent,
			post_agent,
			put_naturals,
			finish
		end

	IS_BASE
		undefine
			default_create,
			copy, is_equal, out
		end
	
create

	make

feature {} -- Initialization 

	make (a_file: like c_file;
				a_type_prefix, a_value_prefix, a_name: STRING; a_system: DG_SYSTEM)
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
			a_name_table: "type names to be used; use default C names if `Void'"
		require
			c_open: a_file.is_open_write
			type_prefix_not_empty: not type_prefix.is_empty
			value_prefix_not_empty: not value_prefix.is_empty
		do
			c_file := a_file
			type_name_prefix := a_type_prefix
			name_prefix := a_value_prefix
			create extra_type_names.make (199)
			create capacities.make (20)
			rts_name := a_name
			system := a_system
			create type_names.make_filled (Void, 0, system.type_count)
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
			in_chars := False
			in_array := False
			type_names.wipe_out
			extra_type_names.wipe_out
			capacities.clear
		end

feature {PC_DRIVER} -- Termination 

	finish (top: PC_TYPED_IDENT [NATURAL])
		local
			id: NATURAL
		do
			id := top.ident
			if id /= void_ident then
				c_file.put_string (c_type_name (top.type))
				c_file.put_character ('*')
				c_file.put_character (' ')
				c_file.put_string (rts_name)
				c_file.put_character ('=')
				c_file.put_character ('&')
				c_file.put_string (name_prefix)
				c_file.put_natural_32 (id)
				c_file.put_character (';')
				c_file.put_new_line
			end
			c_file.flush
		end

feature -- Access

	inline_specials: BOOLEAN = False

	has_capacities: BOOLEAN = False
	
	must_expand_strings: BOOLEAN
		do      
		end

	system: DG_SYSTEM
	
feature {PC_DRIVER} -- Pre and post handling of data 

	pre_object (t: IS_TYPE; id: NATURAL)
		local
			ready: BOOLEAN
		do
			if id /= void_ident then
				declare (t, 0, id)
				c_file.put_string (declaration)
				length := length + declaration.count + 1
				if t.is_string then
					c_file.put_string (string_decl)
					ready := True
				elseif t.is_unicode then
					c_file.put_string (string_decl)
					ready := True
				else
					c_file.put_character ('=')
				end
			end
			if not ready then
				c_file.put_character ('{')
			end
			length := length + 2
			last_ident := id
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
				elseif id = void_ident or else t.is_subobject then
					c_file.put_character (',')
				else
					c_file.put_character (';')
					c_file.put_new_line
					length := 0
				end
			end
		end

	pre_special (t: IS_SPECIAL_TYPE; n: NATURAL; id: NATURAL)
		do
			in_array := capacities.has (id)
			if in_array then
				adapted_cap := capacities.item (id)
			else
				capacities.force (n, id)
				adapted_cap := n
			end
			declare (t, adapted_cap, id)
			c_file.put_string (declaration)
			length := length + declaration.count + 1
			tmp_str.wipe_out
			tmp_str.extend ('=')
			tmp_str.extend ('{')
			in_chars := t.item_type.is_character
			c_file.put_string (tmp_str)
			length := length + tmp_str.count
			break
		end

	post_special (t: IS_SPECIAL_TYPE; id: NATURAL)
		do
			c_file.put_character ('}')
			c_file.put_character (';')
			c_file.put_new_line
			length := 0
			if in_array then
				item_count := 0
				in_array := False
			end
		end

	pre_agent (a: IS_AGENT_TYPE; id: NATURAL)
		do
			if attached a.closed_operands_tuple as cop then
				next_ident
				closed_tuple_ident := last_ident
				pre_object (cop, closed_tuple_ident)
			end
		end

	post_agent (a: IS_AGENT_TYPE; id: NATURAL)
		do
			if attached a.closed_operands_tuple as cop then
				post_object (cop, closed_tuple_ident)
				if a.base_is_closed then
					c_file.put_character ('1')
				else
					c_file.put_character ('0')
				end
				c_file.put_character (',')
			end
		end

feature {PC_DRIVER} -- Put reference data 

	put_new_object (t: IS_TYPE)
		local
			id: NATURAL
		do
			next_ident
			id := last_ident
			c_file.put_string (extern)
			declare (t, 0, last_ident)
			c_file.put_string (declaration)
			c_file.put_character (';')
			c_file.put_new_line
			last_ident := id
		end
	
	put_new_special (st: IS_SPECIAL_TYPE; n, cap: NATURAL)
		local
			id: NATURAL
		do
			next_ident
			id := last_ident
			c_file.put_string (extern)
			capacities.force (n, id) 
			declare (st, 0, id)
			c_file.put_string (declaration)
			c_file.put_character (';')
			c_file.put_new_line
			last_ident := id
		end
	
	pre_new_object (t: IS_TYPE)
		local
			id: NATURAL
		do
			next_ident
			c_file.put_string (static)
			length := length + 7
			id := last_ident
			pre_object (t, id)
			last_ident := id
		end
	
	pre_new_special (st: IS_SPECIAL_TYPE; n, cap: NATURAL)
		local
			id: NATURAL
		do
			next_ident
			id := last_ident
			c_file.put_string (static)
			length := length + 7
			pre_special (st, n, id)
			last_ident := id
		end
	
feature {PC_DRIVER} -- Handling of elementary data 

feature {PC_DRIVER} -- Handling of elementary data 

	put_boolean (b: BOOLEAN)
		do
			break
			if b then
				c_file.put_integer (1)
			else
				c_file.put_integer (0)
			end
			c_file.put_character (',')
			length := length + 2
		end

	put_character (c: CHARACTER)
		local
			need_quote: BOOLEAN
		do
			if not in_chars then
				break
				c_file.put_character ('%'')
				need_quote := True
			end
			if c < ' ' or else c > '~' then
				put_non_printable (c)
			else
				inspect c
				when '\' then
					c_file.put_character ('\')
				when '%'' then
					if not in_chars then
						c_file.put_character ('\')
					end
				when '%"' then
					if in_chars then
						c_file.put_character ('\')
					end
				else
				end
				c_file.put_character (c)
			end
			length := length + 1
			if need_quote then
				c_file.put_character ('%'')
				c_file.put_character (',')
				length := length + 3
				break
			end
		end

	put_character_32 (c: CHARACTER_32)
		do
			put_integer (c.code)
		end

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
	
	put_natural (n: NATURAL_32)
		do
			tmp_str.wipe_out
			tmp_str.append_natural_32 (n)
			length := length + tmp_str.count + 1
			break
			c_file.put_string (tmp_str)
			c_file.put_character (',')
		end

	put_integer_64 (i: INTEGER_64)
		do
			tmp_str.wipe_out
			if i = i.Min_value then
				tmp_str.append_string (int64)
				tmp_str.append_string (i.to_hex_string)
				tmp_str.extend ('U')
			else
				tmp_str.append_integer_64 (i)
			end
			if i <= {INTEGER}.min_value or else {INTEGER}.max_value < i then
				tmp_str.extend ('L')
				tmp_str.extend ('L')
			end
			length := length + tmp_str.count + 1
			break
			c_file.put_string (tmp_str)
			c_file.put_character (',')
		end

	put_natural_64 (n: NATURAL_64)
		do
			tmp_str.wipe_out
			tmp_str.append_natural_64 (n)
			if {NATURAL}.max_value <= n then
				tmp_str.extend ('U')
				tmp_str.extend ('L')
				tmp_str.extend ('L')
			end
			length := length + tmp_str.count + 1
			break
			c_file.put_string (tmp_str)
			c_file.put_character (',')
		end

	put_real (r: REAL_32)
		do
			tmp_str.copy (r.out)
			length := length + tmp_str.count + 1
			break
			c_file.put_string (tmp_str)
			c_file.put_character (',')
		end

	put_double (d: REAL_64)
		do
			tmp_str.copy (d.out)
			length := length + tmp_str.count + 1
			break
			c_file.put_string (tmp_str)
			c_file.put_character (',')
		end

	put_pointer (p: POINTER)
		do
			length := length + 2
			break
			c_file.put_character ('0')
			c_file.put_character (',')
		end
	
	put_string (s: STRING)
		local
			i, n: INTEGER
		do
			in_chars := True
			from
				n := s.count
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
			until i = n loop
				i := i + 1
				put_character (s[i])
			end
			in_chars := False
		end

	put_known_ident (id: NATURAL; t: IS_TYPE)
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
					tmp_str.extend ('(')
					tmp_str.append (c_type_name (stat))
					tmp_str.extend ('*')
					if t.is_special and then not t.generic_at (0).is_subobject then
						tmp_str.extend ('*')
					end
					tmp_str.extend (')')
				end
				if t.is_string or else t.is_unicode then
				else
					tmp_str.extend ('&')
				end
				tmp_str.append (name_prefix)
				tmp_str.append_natural_32 (id)
				tmp_str.extend (',')
				if capacities.has (id) then
					tmp_str.append_natural_32 (capacities.item (id))
					tmp_str.extend (',')
				end
				length := length + tmp_str.count
				break	
				c_file.put_string (tmp_str)
			end
		end
	
	put_void_ident (stat: detachable IS_TYPE)
		do
			tmp_str.wipe_out
			tmp_str.extend ('0')
			tmp_str.extend (',')
			if stat /= Void and then
				(stat.is_special or else attached {IS_ARRAY[IS_NAME]} stat)
			 then
				tmp_str.extend ('0')
				tmp_str.extend (',')
			end
			length := length + tmp_str.count
			break
			c_file.put_string (tmp_str)
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
	
feature  {} -- Implementation
	
	adapted_cap, item_count: NATURAL

	declare (td: IS_TYPE; cap: NATURAL; id: NATURAL)
		local
			g: IS_TYPE
		do
			declaration.wipe_out
			if td.is_special then
				g := td.generic_at (0)
				declaration.append (g.c_name)
				if not g.is_subobject then
					declaration.extend ('*')
				end
				declaration.extend (' ')
				declaration.append (name_prefix)
				declaration.append_natural_32 (id)
				declaration.extend ('[')
				if capacities.has (id) then
					adapted_cap := capacities.item (id)
				else
					adapted_cap := cap.max (1)
				end
				declaration.append_natural_32 (adapted_cap)
				declaration.extend (']')
				declaration_type := td
			else
				declaration.wipe_out
				if td.is_special then
					if extra_type_names.has (id) then
						declaration.append (name_prefix)
						declaration.append_natural_32 (id)
						declaration.extend ('_')
						declaration.extend (' ')
						declaration.append (name_prefix)
					else
						declaration.append (once "struct {int id; int32_t a1; int32_t a2; ")
						g := td.generic_at (0)
						declaration.append (c_type_name (g))
						if not g.is_subobject then
							declaration.extend ('*')
						end
						declaration.append (once " z2[")
						if g.is_character then
							in_chars := True
							adapted_cap := cap + 1
						elseif capacities.has (id) then
							adapted_cap := capacities.item (id)
						else
							adapted_cap := cap.max (1)
						end
						declaration.append_natural_32 (adapted_cap)
						declaration.extend (']')
						declaration.append (once ";} ")
						declaration.append (name_prefix)
					end
				else
					declaration.append (c_type_name(td))
					declaration.extend (' ')
					declaration.append (name_prefix)
				end
				declaration.append_natural_32 (id)
				declaration_type := td
			end
		end

feature {} -- Implementation

	c_file: PLAIN_TEXT_FILE

	type_name_prefix: STRING

	name_prefix: STRING

	rts_name: STRING

	in_chars, in_array: BOOLEAN

	line_length: INTEGER = 76

	length: INTEGER

	closed_tuple_ident: NATURAL

	capacities: DS_HASH_TABLE [NATURAL, NATURAL]

	pointer_home: ANY
	
	break
		do
			if length > line_length then
				c_file.put_new_line
				c_file.put_character (' ')
				c_file.put_character (' ')
				length := 2
			end
		end

	put_non_printable (c: CHARACTER)
		local
			i, code: INTEGER
		do
			c_file.put_character ('\')
			inspect c
			when '%N' then
				c_file.put_character ('n')
			when '%T' then
				c_file.put_character ('t')
			when '%F' then
				c_file.put_character ('f')
			when '%R' then
				c_file.put_character ('r')
			else
				tmp_str.wipe_out
				tmp_str.extend ('0')
				tmp_str.extend ('0')
				tmp_str.extend ('0')
				from
					code := c.code
					i := 3
				until code = 0 loop
					tmp_str.put ('0' + (code \\ 8), i)
					i := i - 1
					code := code // 8
				end
				c_file.put_string (tmp_str)
				length := length + 2
			end
			length := length + 2
		end

	c_type_name(t: IS_TYPE): READABLE_STRING_8
		local
			str: STRING
		do
			if t.ident <=type_names.upper then
				Result := type_names [t.ident]
			end
			if not attached Result then
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
	
	declaration: STRING = "                                                  "

	type_names: ARRAY [detachable READABLE_STRING_8]

	extra_type_names: HASH_TABLE [IS_TYPE, NATURAL]

	declaration_type: detachable IS_TYPE

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
					
	extern: STRING = "extern "
	
	static: STRING = "static "
	
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
