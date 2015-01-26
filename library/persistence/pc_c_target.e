note

	description: "Writing the persistence closure of an object as C code."

class PC_C_TARGET

inherit

	PC_ABSTRACT_TARGET
		redefine
			must_expand_strings,
			reset,
			put_new_object,
			put_new_special,
			put_void_ident,
			pre_object,
			post_object,
			pre_special,
			post_special,
			pre_agent,
			post_agent,
			finish
		end

create

	make

create {IS_NAME}
	-- Dummy creation to make attributes alive 

	default_create

feature {NONE} -- Initialization 

	make (c: like c_file; h: like h_file; header_name: detachable STRING;
			type_prefix, value_prefix: STRING; top_name: detachable STRING;
			system: IS_SYSTEM; with_typedefs, expanded_strings: BOOLEAN)
		note
			action: "[
							 Create object for storing the system description. 
							 Write address definition of top object to the C file
							 like `void *top_name=&(void*)...;'.
							 ]"
			c: "C file"
			h: "header file"
			header_name: "name of `h' (without extension) for include clause"
			type_prefix: "type name prefix"
			value_prefix: "object name prefix"
			top_name: "name of top object"
			system: "underlying IS_SYSTEM needed for its `type_count'"
			with_typedefs: "Are C typedefs to be generated"
			expanded_strings: "Are STRING_* objects already expanded?"
		require
			c_open: c.is_open_write
			type_prefix_not_empty: not type_prefix.is_empty
			value_prefix_not_empty: not value_prefix.is_empty
		local
			t: IS_TYPE
			f: IS_FIELD
			n: INTEGER
		do
			c_file := c
			if h /= Void then
				h_file := h
				n := 200
			else
				h_file := c_file
				n := 1
			end
			to_expand := not expanded_strings
			must_expand_strings := expanded_strings
			if to_expand then 
				t := system.string_type
				if t /= Void then
					f := t.field_by_name ("area")
					if f /= Void and then attached {like chars_type} f.type as ft then
						chars_type := ft
					end
				end
				t := system.string32_type
				if t /= Void then
					f := t.field_by_name ("area")
					if f /= Void and then attached {like chars32_type} f.type as ft then
						chars32_type := ft
					end
				end
				delayed_declaration := ""
			end
			type_name_prefix := type_prefix
			name_prefix := value_prefix
			needs_typedefs := with_typedefs
			create extra_typedefs.make (100)
			create declarations.make (100)
			create declaration.make (0)
			from
				n := system.type_count
			until n = 0 loop
				shift := shift + 1
				n := n |>> 1
			end
			if header_name /= Void then
				c_file.put_string ("#include %"")
				c_file.put_string (header_name)
				c_file.put_string (".h%"%N")
			else
			end
			if needs_typedefs then 
				h_file.put_string ("#include <inttypes.h>%N")
				h_file.put_string ("#include <math.h>%N")
				h_file.put_string ("typedef struct {int id;} T0;%N")
			end
			create typedefs.make (n)
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
			typedefs.wipe_out
			extra_typedefs.wipe_out
			last_string := ""
			declaration.keep_head (0)
		end

feature {PC_DRIVER} -- Termination 

	finish (top: NATURAL; type: IS_TYPE)
		do
			if c_name /= Void then
				tmp_str.wipe_out
				tmp_str.append ("T0 *")
				tmp_str.append (c_name)
				if h_file /= Void then
					h_file.put_string (extern)
					h_file.put_string (tmp_str)
					h_file.put_string ("; /* Root object */%N")
				end
				c_file.put_string (tmp_str)
				c_file.put_string ("=(T0*)&")
				c_file.put_string (name_prefix)
				c_file.put_natural_32 (top)
				c_file.put_character (';')
				c_file.put_new_line
			end
			c_file.flush
		end

feature -- Access

	must_expand_strings: BOOLEAN
	
	has_capacities: BOOLEAN = False
	
	inline_specials: BOOLEAN = False

feature {PC_DRIVER} -- Pre and post handling of data 

	pre_object (t: IS_TYPE; id: NATURAL)
		local
			delayed: BOOLEAN
		do
			if t.is_agent and then attached {IS_AGENT_TYPE} t as at
				and then at.declared_type /= Void
			 then
			else
				if to_expand then
					delayed := not in_chars and then (t.is_string or else t.is_unicode)
				end
				if delayed then
					delayed_type := t
					delayed_ident := id
					delayed_declaration.copy (declaration.twin)
				else
					if id /= void_ident then
						flush_declaration (id)
						declarations.remove (id)
						cached_id := 0
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
		end

	post_object (t: IS_TYPE; id: NATURAL)
		do
			c_file.put_character ('}')
			if t.is_special then
			elseif id = void_ident then
				c_file.put_character (',')
			else
				c_file.put_character (';')
				c_file.put_new_line
				length := 0
			end
			c_file.flush
		end

	pre_special (st: IS_SPECIAL_TYPE; cap: NATURAL; id: NATURAL)
		local
			k: NATURAL_64
		do
			flush_declaration (id)
			declarations.remove (id)
			cached_id := 0
			k := extra_key(st, cap)
			if extra_typedefs.has (k) then
				declaration.copy (extra_typedefs[k])
				declaration.append_character (' ')
				declaration.append (name_prefix)
				declaration.append_natural_32 (id)
			end
			if to_expand and in_chars then
				declaration.extend ('_')
			end
			c_file.put_string (declaration)
			length := length + declaration.count + 1
			tmp_str.wipe_out
			tmp_str.append_character ('=')
			tmp_str.append_character ('{')
			tmp_str.append_integer (st.ident)
			tmp_str.append_character (',')
			tmp_str.append_natural_32 (cap)
			tmp_str.append_character (',')
			in_chars := st.item_type.is_character
			if in_chars then
				c_file.put_string (tmp_str)
				adapted_cap := cap + 1
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

	post_special (st: IS_SPECIAL_TYPE; id: NATURAL)
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
			Precursor (st, id)
			c_file.flush
		end

	pre_agent (at: IS_AGENT_TYPE; id: NATURAL)
		do
			if attached at.closed_operands_tuple as cop then
				put_new_object (cop)
				closed_tuple_ident := last_ident
				pre_object (cop, closed_tuple_ident)
			end
		end

	post_agent (at: IS_AGENT_TYPE; id: NATURAL)
		do
			if attached at.closed_operands_tuple as cop then
				post_object (cop, closed_tuple_ident)
				pre_object (at.declared_type, id)
				put_known_ident (at, closed_tuple_ident)
				if at.base_is_closed then
					c_file.put_character ('1')
				else
					c_file.put_character ('0')
				end
				c_file.put_character (',')
				c_file.flush
			end
		end

feature {PC_DRIVER} -- Put elementary data 

	put_new_object (t: IS_TYPE)
		note
			action:
			"[
			 Update `last_ident' and prepare `declaration'
			 but do not yet print it.
			 ]"
		do
			next_ident
			flush_declaration (last_ident)
			declare (t, last_ident)
		end

	put_new_special (st: IS_SPECIAL_TYPE; n, cap: NATURAL)
		note
			action:
			"[
			 Update `last_ident' and prepare `declaration'
			 but do not yet print it.
			 ]"
		do
			next_ident
			flush_declaration (last_ident)
			declare_special (st, n, last_ident)
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

	adapted_cap: NATURAL
	
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
				if  c = '%U' then
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
				tmp_str.append_character ('U')
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
				tmp_str.append_character ('U')
			else
				tmp_str.append_integer_64 (i)
			end
			if i <= {INTEGER}.min_value or else {INTEGER}.max_value < i then
				tmp_str.append_character ('L')
				tmp_str.append_character ('L')
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
				tmp_str.append_character ('U')
				tmp_str.append_character ('L')
				tmp_str.append_character ('L')
			end
			length := length + tmp_str.count + 1
			break
			c_file.put_string (tmp_str)
			c_file.put_character (',')
		end

	put_real (r: REAL_32)
		do
			if r.is_nan then
				tmp_str.copy (once "NAN")
			elseif r.is_negative_infinity then
				tmp_str.copy (once "-INFINITY")
			elseif r.is_positive_infinity then
				tmp_str.copy (once "INFINITY")
			else
				tmp_str.copy (r.out)
			end
			length := length + tmp_str.count + 1
			break
			c_file.put_string (tmp_str)
			c_file.put_character (',')
		end

	put_double (d: REAL_64)
		do
			if d.is_nan then
				tmp_str.copy (once "NAN")
			elseif d.is_negative_infinity then
				tmp_str.copy (once "-INFINITY")
			elseif d.is_positive_infinity then
				tmp_str.copy (once "INFINITY")
			else
				tmp_str.copy (d.out)
			end
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

	put_string (s: STRING)
		local
			t: IS_TYPE
			f: IS_FIELD
			id: NATURAL
			cap: NATURAL
			i, k, n: INTEGER
		do
			t := delayed_type
			id := delayed_ident
			last_string := s
			if to_expand then
				in_chars := True
				n := s.count
				cap := (n+1).to_natural_32
				declare_special (chars_type, cap, id)
				pre_special (chars_type, cap, id)
				from
				until i = n loop
					i := i + 1
					put_character (s[i])
				end
				post_special (chars_type, delayed_ident)
				in_chars := True
				declaration.copy (delayed_declaration)
				pre_object (t, id)
				-- TODO: fields of object
				from
					i := 0
					k := t.field_count
				until i = k loop
					f := t.field_at (i)
					if f.type.is_basic then
						put_integer (n)
					else
						put_known_ident (t, id)
					end
					i := i + 1
				end
				in_chars := False
			end
		end
	
	put_unicode (u: STRING_32)
		do
			last_string := u.out
		end
	
	put_known_ident (t: IS_TYPE; id: NATURAL)
		do
			tmp_str.wipe_out
			if id = void_ident then
				tmp_str.append_character ('0')
			else
				tmp_str.append (once "(T0*)&")
				tmp_str.append (name_prefix)
				tmp_str.append_natural_32 (id)
				if in_chars then
					tmp_str.append_character ('_')
				end
			end
			tmp_str.append_character (',')
			length := length + tmp_str.count
			break
			c_file.put_string (tmp_str)
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

	to_expand: BOOLEAN
	
	in_chars: BOOLEAN

	last_string: STRING

	delayed_ident: NATURAL
	
	delayed_type: IS_TYPE

	delayed_declaration: STRING
	
	chars_type, chars32_type: IS_SPECIAL_TYPE

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

	typedefs: HASH_TABLE [IS_TYPE, IS_TYPE]

	extra_typedefs: HASH_TABLE [like declaration, NATURAL_64]

	extra_key (st: IS_SPECIAL_TYPE; n: NATURAL): NATURAL_64
		local
			g: IS_TYPE
			gid, n1: NATURAL_64
		do
			g := st.item_type
			if g.is_subobject then
				gid := g.ident.to_natural_64
			end
			n1 := n.max (1)
			Result := (n1 |<< shift) | gid
		end

	shift: INTEGER
	
	declaration_type: detachable IS_TYPE

	declare_type (t: IS_TYPE)
		require
			needs_typedefs: needs_typedefs
		local
			f: IS_FIELD
			ft: IS_TYPE
			i, n: INTEGER
		do
			if (t.is_alive or else t.is_basic) and then not typedefs.has (t) then
				typedefs.force (t, t)
				if t.is_basic then
					h_file.put_string (once "typedef ")
					inspect t.ident
					when Boolean_ident THEN
						h_file.put_string ("char")
					when Char8_ident THEN
						h_file.put_string ("unsigned char")
					when Char32_ident THEN
						h_file.put_string ("uint32_t")
					when Int8_ident THEN
						h_file.put_string ("int8_t")
					when Int16_ident THEN
						h_file.put_string ("int16_t")
					when Int32_ident THEN
						h_file.put_string ("int32_t")
					when Int64_ident THEN
						h_file.put_string ("int64_t")
					when Nat8_ident THEN
						h_file.put_string ("uint8_t")
					when Nat16_ident THEN
						h_file.put_string ("uint16_t")
					when Nat32_ident THEN
						h_file.put_string ("uint32_t")
					when Nat64_ident THEN
						h_file.put_string ("uint64_t")
					when Real32_ident THEN
						h_file.put_string ("float")
					when Real64_ident THEN
						h_file.put_string ("double")
					when Pointer_ident THEN
						h_file.put_string ("void*")
					else
					end
				else
					from
						n := t.field_count
					until i = n loop
						f := t.field_at (i)
						declare_type (f.type)
						i := i + 1
					end
					h_file.put_string (once "typedef struct {")
					if t.flags & t.Missing_id_flag = 0 then
						h_file.put_new_line
						h_file.put_string (once "  int id;")
					end
					from
						i := 0
					until i = n loop
						f := t.field_at (i)
						ft := f.type
						h_file.put_new_line
						h_file.put_character (' ')
						h_file.put_character (' ')
						if not ft.is_subobject then
							h_file.put_character ('T')
							h_file.put_character ('0')
							h_file.put_character ('*')
						else
							h_file.put_string (type_name_prefix)
							h_file.put_integer (ft.ident)
						end
						h_file.put_character (' ')
						h_file.put_string (f.name)
						h_file.put_character (';')
						i := i + 1
					end
					h_file.put_new_line
					h_file.put_character ('}')
				end
				h_file.put_character (' ')
				h_file.put_string (type_name_prefix)
				h_file.put_integer (t.ident)
				h_file.put_character (';')
				if not t.is_basic then
					h_file.put_string (once " /* ")
					h_file.put_string (t.name)
					h_file.put_string (once " */")
				end
				h_file.put_new_line
				h_file.flush
			end
		ensure
			type_definded: t.is_alive implies typedefs.has (t)
		end

	static: STRING = "static "

	extern: STRING = "extern "

	typedef: STRING = "typedef ";

	special_struct: STRING = "struct {int id; int count; "

	data: STRING = " data"

	end_data: STRING= "];} "

	declare_special (st: IS_SPECIAL_TYPE; cap: NATURAL; id: NATURAL)
		require
			valid_id: id /= void_ident
		local
			g: IS_TYPE
			s: STRING
			gid: INTEGER
			n1: NATURAL
			k: NATURAL_64
		do
			n1 := cap.max (1)
			g := st.item_type
			if g.is_alive or else g.is_basic then
				gid := g.ident
			end
			k := extra_key (st, n1)
			if not extra_typedefs.has (k) then
				if needs_typedefs then
					declare_type (g)
				end
				s := type_name_prefix.twin
				s.append_integer (gid)
				s.extend('_')
				s.append_natural_32 (n1)
				extra_typedefs[k] := s
				tmp_str.copy(typedef)
				tmp_str.append(special_struct)
				tmp_str.append (type_name_prefix)
				if g.is_subobject then
					tmp_str.append_integer (gid)
				else
					tmp_str.append_character ('0')
					tmp_str.append_character ('*')
				end
				tmp_str.append (data)
				tmp_str.append_character ('[')
				tmp_str.append_natural_32 (n1)
				tmp_str.append (end_data)
				tmp_str.append (s)
				tmp_str.append_character (';')
				c_file.put_string (tmp_str)
				c_file.put_new_line
			end
			s := extra_typedefs[k].twin
			s.append_character (' ')
			s.append (name_prefix)
			s.append_natural_32 (id)
			declaration := s
			declarations.put (s, id)
			cached_id := id
		ensure
			cached_id: cached_id = id declarations [id] = declaration
			cached_decl: declarations [id] = declaration
		end
	
	declare (t: IS_TYPE; id: NATURAL)
		require
			valid_id: id /= void_ident
			not_expanded: not t.is_subobject
			not_special: not t.is_special
		local
			s: STRING
			tid: INTEGER
		do
			declaration_type := t
			if t.is_agent and then attached {IS_AGENT_TYPE} t as at
				and then attached at.declared_type as dt 
			 then
				tid := dt.ident
				declaration_type := at.declared_type
				declare_type (declaration_type)
			else
				tid := t.ident
			end
			if needs_typedefs then
				declare_type (declaration_type)
			end
			s := ""
			s.append (type_name_prefix)
			s.append_integer (tid)
			s.append_character (' ')
			s.append (name_prefix)
			s.append_natural_32 (id)
			declaration := s
			declarations.put (s, id)
			cached_id := id
		ensure
			cached_id: cached_id = id declarations [id] = declaration
			cached_decl: declarations [id] = declaration
			declaration_type_set: declaration_type = t
		end

	declarations: PC_INTEGER_TABLE [like declaration]

	cached_id: NATURAL
	
	flush_declaration (now: NATURAL)
		require
			valid_id: now /= void_ident
			not_yet_done: declarations.has (now)
		do
			if cached_id = now then
				check declaration = declarations [now] end
				c_file.put_string (static)
				length := length + 7
			elseif declarations.has (cached_id) then
				c_file.put_string (extern)
				declaration := declarations [cached_id]
				c_file.put_string (declaration)
				c_file.put_character (';')
				c_file.put_new_line
				length := 0
				declaration := declarations [now]
			elseif declarations.has (now) then
				declaration := declarations [now]
			end
		ensure
			updated: declaration = old declarations.twin [now]
			done: not declarations.has (old chashed_id)
			invalid_id: cached_id = void_ident
		end

invariant

	typedefs_not_void: needs_typedefs implies attached typedefs

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
