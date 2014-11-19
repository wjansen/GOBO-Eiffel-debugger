note

	description: "Writing the persistence closure of an object as C code."

class PC_C_TARGET

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
			pre_special,
			post_special,
			pre_agent,
			post_agent,
			pre_new_object,
			pre_new_special,
			finish
		end

create

	make

create {IS_NAME}
	-- Dummy creation to make attributes alive 

	default_create

feature {NONE} -- Initialization 

	make (c: like c_file; h: like h_file;
			type_prefix, value_prefix: STRING; top_name: detachable STRING;
			with_typedefs: BOOLEAN)
		note
			action: "[
							 Create object for storing the system description. 
							 Write address definition of top object to the C file
							 like `void *top_name=&(void*)...;'.
							 ]"
			c: "C file"
			h: "header file"
			type_prefix: "type name prefix"
			value_prefix: "object name prefix"
			top_name: "name of top object"
			with_typedefs: "add type declarations"
		require
			c_open: c.is_open_write
			type_prefix_not_empty: not type_prefix.is_empty
			value_prefix_not_empty: not value_prefix.is_empty
		local
			ch: like h_file
		do
			c_file := c
			h_file := h
			type_name_prefix := type_prefix
			name_prefix := value_prefix
			needs_typedefs := with_typedefs
			if with_typedefs then
				if h_file /=Void then
					ch := h_file
				else
					ch := c_file
				end
				create typedefs.make (200)
				ch.put_string ("#include <inttypes.h>%N")
				ch.put_string ("typedef struct {int id;} T0;%N")
				if h_file /= Void then
					c_file.put_string ("#include %"")
					c_file.put_string ("test.h")
					c_file.put_string ("%"%N")
				end
			end
			create extra_typedefs.make (10)
			reset
			c_name := top_name
		ensure
			c_file_set: c_file = c
		end

feature {PC_BASE} -- Initialization 

	reset
		do
			Precursor
			in_chars := False
			in_array := False
			if attached typedefs as td then
				td.wipe_out
			end
			extra_typedefs.wipe_out
			last_string := ""
			declaration := ""
		end

feature {PC_DRIVER} -- Termination 

	finish (top: PC_TYPED_IDENT [NATURAL])
		do
			if c_name /= Void then
				tmp_str.wipe_out
				tmp_str.append ("T0 *")
				tmp_str.append (c_name)
				if h_file /= Void then
					h_file.put_string ("extern ")
					h_file.put_string (tmp_str)
					h_file.put_string ("; /* Root object */%N")
				end
				c_file.put_string (tmp_str)
				c_file.put_string ("=(T0*)&")
				c_file.put_string (name_prefix)
				c_file.put_natural_32 (top.ident)
				c_file.put_character (';')
				c_file.put_new_line
			end
		end

feature -- Access 

	has_capacities: BOOLEAN = False
	
	inline_specials: BOOLEAN = False

	must_expand_strings: BOOLEAN = True

feature {PC_DRIVER} -- Pre and post handling of data 

	pre_object (t: IS_TYPE; id: NATURAL)
		do
			Precursor (t, id)
			if not t.is_agent then
				declare (t, 0, id)
				if not t.is_subobject then
					c_file.put_string (declaration)
					c_file.put_character ('=')
					length := length + declaration.count + 1
				end
				c_file.put_character ('{')
				length := length + 2
				if (t.flags & Missing_id_flag) = 0 then
					c_file.put_integer (t.ident)
					c_file.put_character (',')
					length := length + 5
				end
			end
		end

	post_object (t: IS_TYPE; id: NATURAL)
		do
			c_file.put_character ('}')
			if t.is_special then
			elseif t.is_subobject then
				c_file.put_character (',')
			else
				c_file.put_character (';')
				c_file.put_new_line
				c_file.flush
				length := 0
			end
			Precursor (t, id)
		end

	pre_special (t: IS_SPECIAL_TYPE; cap: NATURAL; id: NATURAL)
		do
			Precursor (t, cap, id)
			adapted_cap := cap
			declare (t, adapted_cap, id)
			c_file.put_string (declaration)
			length := length + declaration.count + 1
			tmp_str.wipe_out
			tmp_str.extend ('=')
			tmp_str.extend ('{')
			tmp_str.append_integer (t.ident)
			tmp_str.extend (',')
			tmp_str.append_natural_32 (adapted_cap)
			tmp_str.extend (',')
			in_chars := t.item_type.is_character
			if in_chars then
				c_file.put_string (tmp_str)
				length := length + adapted_cap.to_integer_32 + tmp_str.count
				break
				c_file.put_character ('"')
				length := length + 1
			else
				c_file.put_string (tmp_str)
				length := length + tmp_str.count
				break
				c_file.put_character ('{')
				length := length + 1
			end
		end

	post_special (t: IS_SPECIAL_TYPE; id: NATURAL)
		do
			if in_chars then
				c_file.put_character ('"')
				in_chars := False
			else
				c_file.put_character ('}')
			end
			c_file.put_character ('}')
			c_file.put_character (';')
			c_file.put_new_line
			c_file.flush
			length := 0
			Precursor (t, id)
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
				pre_object (a.declared_type, id)
				put_known_ident (closed_tuple_ident, a.declared_type)
				if a.base_is_closed then
					c_file.put_character ('1')
				else
					c_file.put_character ('0')
				end
				c_file.put_character (',')
			end
		end

feature {PC_DRIVER} -- Put elementary data 

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
			if index >= adapted_cap.to_integer_32 then
			else
				if  c= '%U' then
					adapted_cap := index.to_natural_32
				elseif c < ' ' or else c > '~' then
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
			end
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
		do
			tmp_str.wipe_out
			if i = i.Min_value then
				tmp_str.append_string (once "(int32_t)0x")
				tmp_str.append_string (i.to_hex_string)
				tmp_str.extend ('U')
			else
				tmp_str.append_integer (i)
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
				tmp_str.append_string (once "(int64_t)0x")
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
			break
			c_file.put_character ('0')
			c_file.put_character (',')
			length := length + 2
		end

	put_known_ident (id: NATURAL; t: IS_TYPE)
		local
			skip: BOOLEAN
		do
			if in_array then
				item_count := item_count + 1
				skip := item_count > adapted_cap
			end
			if not skip then
				tmp_str.wipe_out
				if id = void_ident then
					tmp_str.extend ('0')
				else
					tmp_str.append (once "(T0*)&")
					tmp_str.append (name_prefix)
					tmp_str.append_natural_32 (id)
				end
				tmp_str.extend (',')
				length := length + tmp_str.count
				break
				c_file.put_string (tmp_str)
			end
		end

	put_string (s: STRING)
		do
			last_string := s
		end
	
	put_unicode (u: STRING_32)
		do
			last_string := u.out
		end
	
	put_void_ident (stat: detachable IS_TYPE)
		do
			length := length + 2
			break
			c_file.put_character ('0')
			c_file.put_character (',')
		end
	
feature {NONE} -- Implementation 

	c_file: PLAIN_TEXT_FILE

	h_file: detachable PLAIN_TEXT_FILE

	type_name_prefix: STRING

	name_prefix: STRING

	c_name: detachable STRING

	needs_typedefs: BOOLEAN

	in_chars, in_array: BOOLEAN

	last_string: STRING
	
	line_length: INTEGER = 76

	length: INTEGER

	agent_type: detachable IS_AGENT_TYPE

	closed_tuple_ident: NATURAL

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
				tmp_str.copy (once "000")
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

	declaration: STRING -- = "                                                  "

	typedefs: detachable HASH_TABLE [IS_TYPE, IS_TYPE]

	extra_typedefs: HASH_TABLE [IS_TYPE, NATURAL]

	declaration_type: detachable IS_TYPE

	adapted_cap, item_count: NATURAL

	declare_type (td: IS_TYPE)
		require
			needs_typedefs: needs_typedefs
		local
			f: IS_FIELD
			ft: IS_TYPE
			h: like h_file
			i, n: INTEGER
		do
			if td.is_alive and then not typedefs.has (td) then
				if h_file /=Void then
					h := h_file
				else
					h := c_file
				end
				typedefs.force (td, td)
				if td.is_basic then
					h.put_string (once "typedef ")
					inspect td.ident
					when Boolean_ident THEN
						h.put_string ("char")
					when Char8_ident THEN
						h.put_string ("unsigned char")
					when Char32_ident THEN
						h.put_string ("uint32_t")
					when Int8_ident THEN
						h.put_string ("int8_t")
					when Int16_ident THEN
						h.put_string ("int16_t")
					when Int32_ident THEN
						h.put_string ("int32_t")
					when Int64_ident THEN
						h.put_string ("int64_t")
					when Nat8_ident THEN
						h.put_string ("uint8_t")
					when Nat16_ident THEN
						h.put_string ("uint16_t")
					when Nat32_ident THEN
						h.put_string ("uint32_t")
					when Nat64_ident THEN
						h.put_string ("uint64_t")
					when Real32_ident THEN
						h.put_string ("float")
					when Real64_ident THEN
						h.put_string ("double")
					when Pointer_ident THEN
						h.put_string ("void*")
					else
					end
				else
					from
						n := td.field_count
					until i = n loop
						f := td.field_at (i)
						declare_type (f.type)
						i := i + 1
					end
					h.put_string (once "typedef struct {")
					if td.flags & td.Missing_id_flag = 0 then
						h.put_new_line
						h.put_string (once "  int id;")
					end
					from
						i := 0
					until i = n loop
						f := td.field_at (i)
						ft := f.type
						h.put_new_line
						h.put_character (' ')
						h.put_character (' ')
						if not ft.is_subobject then
							h.put_character ('T')
							h.put_character ('0')
							h.put_character ('*')
						else
							h.put_string (type_name_prefix)
							h.put_integer (ft.ident)
						end
						h.put_character (' ')
						h.put_string (f.name)
						h.put_character (';')
						i := i + 1
					end
					h.put_new_line
					h.put_character ('}')
				end
				h.put_character (' ')
				h.put_string (type_name_prefix)
				h.put_integer (td.ident)
				h.put_character (';')
				if not td.is_basic then
					h.put_string (once " /* ")
					h.put_string (td.name)
					h.put_string (once " */")
				end
				h.put_new_line
				h.flush
			end
		ensure
			type_definded: td.is_alive implies typedefs.has (td)
		end

	static: STRING = "static "

	extern: STRING = "extern "
	
	declare (t: IS_TYPE; cap: NATURAL; id: NATURAL)
		require
			not_expanded: not t.is_subobject
		local
			g: IS_TYPE
			tid: INTEGER
		do
			if needs_typedefs then
				declare_type (t)
			end
			declaration_type := t
			declaration.wipe_out
			if t.is_special then
				if extra_typedefs.has (id) then
					declaration.append (name_prefix)
					declaration.append_natural_32 (id)
					declaration.extend ('_')
					declaration.extend (' ')
					declaration.append (name_prefix)
				else
					declaration.append (once "struct {int id; int32_t")
					declaration.append (once " count; ")
					g := t.generic_at (0)
					if g.is_subobject then
						declaration.append (type_name_prefix)
						declaration.append_integer (g.ident)
					else
						declaration.append (once "T0*")
					end
					declaration.append (once " data[")
					if g.is_character then
						in_chars := True
						adapted_cap := cap
					else
						adapted_cap := cap.max (1)
					end
					declaration.append_natural_32 (adapted_cap)
					declaration.extend (']')
					declaration.append (once ";} ")
					declaration.append (name_prefix)
				end
			else
				if t.is_agent and then attached {IS_AGENT_TYPE} t as at
					and then attached at.declared_type as dt 
				 then
					tid := dt.ident
					declaration_type := at.declared_type
					declare_type (declaration_type)
				else
					tid := t.ident
				end
				declaration.append (type_name_prefix)
				declaration.append_integer (tid)
				declaration.extend (' ')
				declaration.append (name_prefix)
			end
			declaration.append_natural_32 (id)
		ensure
			declaration_type_set: declaration_type = t
		end

invariant

	typedefs_not_void: needs_typedefs implies attached typedefs

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
