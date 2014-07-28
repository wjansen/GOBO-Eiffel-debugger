note

	description:
		"[ 
		 Formatting elementary data within the persistence closure 
		 of an object for human reading. 
		 ]"

class PC_TEXT_TARGET

inherit

	PC_ABSTRACT_TARGET
		redefine
			must_expand_strings,
			reset,
			pre_object,
			pre_special,
			post_object,
			post_special,
			put_new_object,
			put_new_special,
			put_void_ident,
			put_once
		end

create

	make

feature {} -- Initialization 

	make (f: like file; s: like system)
		do
			create field_stack
			system := s
			reset
			set_file (f)
		ensure
			file_set: (attached f implies file = f)
								and (not attached f implies file = io.output)
		end

feature {PC_BASE} -- Initialization 

	reset
		do
			Precursor
			field_stack.clear
			indent_increment := 2
			indent_size := 0 
			index := -1
			field := Void
			top_name.copy (once "all")
			set_file (Void)
			on_top := True
		end

feature -- Constants 

	As_hexadecimal: INTEGER = 1

	As_global_definition: INTEGER = 2

feature -- Access 

	must_expand_strings: BOOLEAN = False

	has_capacities: BOOLEAN = False
	
	flat: BOOLEAN
			-- Output formatted for FIFO traversal if `True' 
			-- (otherwise, for DEEP traversal). 

	pre_fix: STRING = "_"

	post_fix: STRING = ""

	top_name: STRING = "__"

	indent_increment: INTEGER
			-- Prefix of known object idents. 
			--
			-- Postfix of object idents. 
			--
			-- Name of top object (an attribute name is not available). 
			--
			-- Increment for indentation of nested subobjects. 

	format: INTEGER
			-- Overlay of `As_hexadecimal', `As_global_definition'. 

feature -- Status setting 

	set_flat (fl: BOOLEAN)
		do
			flat := fl
		ensure
			flat_set: flat = fl
		end

	set_format (fmt: like format)
		note
			action:
			"[
			 Set the formatting to `fmt' according to definitions in `s'
			 (don't use definitions if `s=Void').
			 ]"
		require
			valid_format: fmt <= As_hexadecimal + As_global_definition
		do
			format := fmt
		ensure
			format_set: format = fmt
		end

	set_prefix (p: STRING)
		do
			pre_fix.copy (p)
		ensure
			pre_fix_set: pre_fix.is_equal (p)
		end

	set_postfix (p: STRING)
		do
			post_fix.copy (p)
		ensure
			post_fix_set: post_fix.is_equal (p)
		end

	set_top_name (s: STRING)
		do
			top_name.copy (s)
			on_top := True
		ensure
			top_name_set: top_name.is_equal (s)
			on_top: on_top
		end

	set_indent_increment (incr: INTEGER)
		note
			action: "Set `ident_increment'."
		require
			not_negative: incr >= 0
		do
			indent_increment := incr
		ensure
			indent_increment_set: indent_increment = incr
		end

	set_file (f: detachable like file)
		do
			if attached f then
				file := f
			else
				file := io.output
			end
		ensure
			file_set: (attached f implies file = f)
								and (not attached f implies file = io.output)
		end

feature {PC_DRIVER} -- Push and pop data 

	pre_object (t: IS_TYPE; id: NATURAL)
		local
			f: like field
		do
			f := field
			check attached f end
			field_stack.push (f)
			write_reference (t, id)
			indent_size := indent_size + indent_increment
		end

	pre_special (s: IS_SPECIAL_TYPE; n: NATURAL; id: NATURAL)
		local
			f: like field
		do
			f := s.item_0
			check attached f end
			field_stack.push (f)
			write_array (s, n, id)
			indent_size := indent_size + indent_increment
		end

	post_object (t: IS_TYPE; id: NATURAL)
		do
			field_stack.pop (1)
			indent_size := indent_size - indent_increment
		end

	post_special (t: IS_SPECIAL_TYPE; id: NATURAL)
		do
			field_stack.pop (1)
			indent_size := indent_size - indent_increment
		end

feature {PC_DRIVER} -- Forward data 

	put_new_object (t: IS_TYPE)
		do
			Precursor (t)
			if flat then
				put_known_ident (last_ident, t)
			end
		end

	put_new_special (s: IS_SPECIAL_TYPE; n, cap: NATURAL)
		do
			Precursor (s, n, cap)
			if flat then
				put_known_ident (last_ident, s)
			end
		end

feature {PC_DRIVER} -- Writing elementary data 

	put_boolean (b: BOOLEAN)
		do
			if b /= b.default or else index = -1 then
				tmp_str.wipe_out
				append_name (True, tmp_str)
				tmp_str.append_boolean (b)
				file.put_string (tmp_str)
				file.put_new_line
			end
		end

	put_character (c: CHARACTER)
		do
			if c /= c.default or else index = -1 then
				tmp_str.wipe_out
				append_name (True, tmp_str)
				if (format & As_hexadecimal) /= 0 then
					tmp_str.extend ('0')
					tmp_str.extend ('x')
					tmp_str.append (c.code.to_natural_8.to_hex_string)
					tmp_str.append (once " C8")
				else
					tmp_str.extend ('%'')
					tmp_str.extend (c)
					tmp_str.extend ('%'')
				end
				file.put_string (tmp_str)
				file.put_new_line
			end
		end

	put_character_32 (c: CHARACTER_32)
		do
			if c /= c.default or else index = -1 then
				tmp_str.wipe_out
				append_name (True, tmp_str)
				if (format & As_hexadecimal) /= 0 then
					tmp_str.extend ('0')
					tmp_str.extend ('x')
					tmp_str.append (c.code.to_hex_string)
				else
					tmp_unicode.wipe_out
					tmp_unicode.extend (c)
					tmp_str.extend ('%'')
					tmp_str.append (tmp_unicode.out)
					tmp_str.extend ('%'')
				end
				tmp_str.append (once " C32")
				file.put_string (tmp_str)
				file.put_new_line
			end
		end

	put_integer (i: INTEGER_32)
		do
			if i /= i.default or else index = -1 then
				tmp_str.wipe_out
				append_name (True, tmp_str)
				value_printed := False
				if (format & As_global_definition) /= 0 then
					append_unique (i, tmp_str)
				end
				if attached field_type as ft then
					if not value_printed then
						if (format & As_hexadecimal) /= 0 then
							tmp_str.extend ('0')
							tmp_str.extend ('x')
							inspect ft.ident
							when Int8_ident then
								tmp_str.append (i.to_integer_8.to_hex_string)
								tmp_str.append (once " I8")
							when Int16_ident then
								tmp_str.append (i.to_integer_16.to_hex_string)
								tmp_str.append (once " I16")
							when Int32_ident then
								tmp_str.append (i.to_hex_string)
							else
							end
						else
							inspect ft.ident
							when Int8_ident then
								tmp_str.append_integer (i.to_integer)
								tmp_str.append (once " I8")
							when Int16_ident then
								tmp_str.append_integer (i.to_integer)
								tmp_str.append (once " I16")
							when Int32_ident then
								tmp_str.append_integer (i)
							else
							end
						end
					end
				end
				file.put_string (tmp_str)
				file.put_new_line
			end
		end

	put_natural (n: NATURAL_32)
		do
			if n /= n.default or else index = -1 then
				tmp_str.wipe_out
				append_name (True, tmp_str)
				value_printed := False
				if (format & As_global_definition) /= 0 then
					append_unique (n.to_integer_32, tmp_str)
				end
				if attached field_type as ft then
					if not value_printed then
						if (format & As_hexadecimal) /= 0 then
							tmp_str.extend ('0')
							tmp_str.extend ('x')
							inspect ft.ident
							when Nat8_ident then
								tmp_str.append (n.to_natural_8.to_hex_string)
								tmp_str.append (once " N8")
							when Nat16_ident then
								tmp_str.append (n.to_natural_16.to_hex_string)
								tmp_str.append (once " N16")
							when Nat32_ident then
								tmp_str.append (n.to_hex_string)
								tmp_str.append (once " N32")
							else
							end
						else
							inspect ft.ident
							when Nat8_ident then
								tmp_str.append_natural_32 (n)
								tmp_str.append (once " N8")
							when Nat16_ident then
								tmp_str.append_natural_32 (n)
								tmp_str.append (once " N16")
							when Nat32_ident then
								tmp_str.append_natural_32 (n)
								tmp_str.append (once " N32")
							else
							end
						end
					end
				end
				file.put_string (tmp_str)
				file.put_new_line
			end
		end

	put_integer_64 (i: INTEGER_64)
		do
			if i /= i.default or else index = -1 then
				tmp_str.wipe_out
				append_name (True, tmp_str)
				value_printed := False
				if (format & As_global_definition) /= 0 then
					append_unique (i.to_integer_32, tmp_str)
				end
				if not value_printed then
					if (format & As_hexadecimal) /= 0 then
						tmp_str.extend ('0')
						tmp_str.extend ('x')
						tmp_str.append (i.to_hex_string)
					else
						tmp_str.append_integer_64 (i)
					end
					tmp_str.append (once " I64")
				end
				file.put_string (tmp_str)
				file.put_new_line
			end
		end

	put_natural_64 (n: NATURAL_64)
		do
			if n /= n.default or else index = -1 then
				tmp_str.wipe_out
				append_name (True, tmp_str)
				value_printed := False
				if (format & As_global_definition) /= 0 then
					append_unique (n.to_integer_32, tmp_str)
				end
				if not value_printed then
					if (format & As_hexadecimal) /= 0 then
						tmp_str.extend ('0')
						tmp_str.extend ('x')
						tmp_str.append (n.to_hex_string)
					else
						tmp_str.append_natural_64 (n)
					end
					tmp_str.append (once " N64")
				end
				file.put_string (tmp_str)
				file.put_new_line
			end
		end

	put_real (r: REAL_32)
		do
			if r /= r.default or else index = -1 then
				tmp_str.wipe_out
				append_name (True, tmp_str)
				tmp_str.append_real (r)
				if tmp_str.index_of ('.', 1) = 0 then
					tmp_str.extend ('.')
				end
				tmp_str.append (once " R32")
				file.put_string (tmp_str)
				file.put_new_line
			end
		end

	put_double (d: REAL_64)
		do
			if d /= d.default or else index = -1 then
				tmp_str.wipe_out
				append_name (True, tmp_str)
				tmp_str.append_double (d)
				if tmp_str.index_of ('.', 1) = 0 then
					tmp_str.extend ('.')
				end
				file.put_string (tmp_str)
				file.put_new_line
			end
		end

	put_pointer (p: POINTER)
		do
			if p /= p.default or else index = -1 then
				tmp_str.wipe_out
				append_name (True, tmp_str)
				tmp_str.append_string (p.out)
				file.put_string (tmp_str)
				file.put_new_line
			end
		end

	put_string (s: STRING)
		do
			tmp_str.wipe_out
			append_simple_string (s, tmp_str)
			file.put_string (tmp_str)
			file.put_new_line
		end

	put_unicode (u: STRING_32)
		do
			tmp_str.wipe_out
			append_simple_unicode (u.as_string_8, tmp_str)
			file.put_string (tmp_str)
			file.put_new_line
		end

	put_known_ident (id: NATURAL; t: IS_TYPE)
		do
			if id = void_ident then
				put_void_ident (field_type)
			else
				write_name
				write_ident (id)
				file.put_new_line
			end
		end
	
	put_void_ident (stat: detachable IS_TYPE)
		do
			if index = -1 then
				write_name
				file.put_string (once "Void")
				file.put_new_line
			end
		end

	put_once (cls: detachable IS_CLASS_TEXT; nm: STRING; id: NATURAL)
		do
			tmp_str.wipe_out
			last_ident := id
			if attached cls as c then
				value_printed := False
				cls.append_name (tmp_str)
				tmp_str.extend ('.')
				tmp_str.append (nm)
				value_printed := True
				file.put_string (tmp_str)
				file.put_new_line
			end
		end

feature {} -- Implementation 

	append_simple_string (s: STRING; to: STRING)
		do
			to.extend ('"')
			to.append (s)
			to.extend ('"')
		end

	append_simple_unicode (s: STRING_32; to: STRING)
		do
			append_simple_string (s.as_string_8, to)
			to.append (once " S32")
		end

	append_unique (i: INTEGER; to: STRING)
		do
			if attached system.search_unique (i) as u then
				u.home.append_name (to)
				to.extend ('.')
				if attached {IS_FEATURE_TEXT} u.text as f then
					f.append_name (to)
				else
					u.append_name (to)
				end
				value_printed := True
			end
		end

feature {} -- Implementation 

	file: PLAIN_TEXT_FILE

	system: IS_SYSTEM

	on_top: BOOLEAN

	tmp_unicode: STRING_32 = ""

	field_stack: IS_STACK [IS_ENTITY]

	write_ident (i: NATURAL)
		do
			tmp_str.wipe_out
			append_ident (i, tmp_str)
			file.put_string (tmp_str)
		end

	write_name
		local
			f: like field
		do
			f := field
			check attached f end
			field_stack.push (f)
			tmp_str.wipe_out
			append_name (True, tmp_str)
			file.put_string (tmp_str)
			field_stack.pop (1)
		end

	write_reference (t: IS_TYPE; id: NATURAL)
		do
			tmp_str.wipe_out
			append_reference (t, id, tmp_str)
			file.put_string (tmp_str)
			if not t.is_string and then not t.is_unicode then
				file.put_new_line
			end
		end

	write_array (t: IS_SPECIAL_TYPE; n: NATURAL; id: NATURAL)
		do
			tmp_str.wipe_out
			append_array (t, n, id, tmp_str)
			file.put_string (tmp_str)
			file.put_new_line
		end

	value_printed: BOOLEAN

feature {} -- Filling strings 

	append_ident (i: NATURAL; to: STRING)
		do
			to.append (pre_fix)
			to.append_natural_32 (i)
			to.append (post_fix)
			to.extend (' ')
		end

	append_name (of_value: BOOLEAN; to: STRING)
		local
			has_name: BOOLEAN
		do
			put_indented (to)
			if on_top then
				to.append (top_name)
				on_top := False
			elseif index = -1 then
				if field_stack.count > 1 then
					if attached field_stack.below_top (1) as parent then
						if attached parent.text as x and then attached x.tuple_labels then
							x.append_label (field.name, to)
							has_name := True
						end
					end
				end
				if not has_name then
					field.append_name (to)
				end
			else
				to.extend ('[')
				to.append (index.out)
				to.extend (']')
			end
			to.extend (' ')
			if of_value then
				to.extend ('=')
				to.extend (' ')
			end
		end

	append_new_name (to: STRING)
		local
			needed: BOOLEAN
		do
			if flat then
				needed := attached field_type as ft
					and then ft.is_subobject and then not ft.is_basic
			else
				needed := True
			end
			if needed then
				append_name (False, to)
			end
		end

	append_type_name (td: IS_TYPE; to: STRING)
		local
			x: detachable IS_FEATURE_TEXT
		do
			to.extend (':')
			to.extend (' ')
			if not field_stack.is_empty and then td.is_tuple
				and then attached {IS_TUPLE_TYPE} td as tu
			 then
				if attached field_stack.top as top then
					x := top.text
					if attached x then
						tu.append_labeled_type_name (top, to)
					end
				end
			end
			if attached x then
			else
				td.append_name (to)
			end
		end

	append_reference (t: IS_TYPE; id: NATURAL; to: STRING)
		do
			append_new_name (to)
			if id = void_ident then
				append_type_name (t, to)
			else
				append_ident (id, to)
				if t.is_agent then
					to.extend (':')
					to.extend (' ')
					t.append_name (to)
				elseif t.is_string or else t.is_unicode then
					to.extend ('=')
					to.extend (' ')
				else
					append_type_name (t, to)
				end
			end
		end

	append_array (t: IS_SPECIAL_TYPE; n: NATURAL; id: NATURAL; to: STRING)
		do
			append_new_name (to)
			append_ident (id, to)
			to.append (once ": ")
			t.generic_at (0).append_name (to)
			to.extend (' ')
			to.extend ('[')
			to.append_natural_32 (n)
			to.extend (']')
		end

	indent_size: INTEGER

	put_indented (to: STRING)
		local
			i, n: INTEGER
		do
			n := indent_size
			if n > 0 then
				from
					i := n // 8
				until i = 0 loop
					to.extend ('%T')
					i := i - 1
				end
				from
					i := n \\ 8
				until i = 0 loop
					to.extend (' ')
					i := i - 1
				end
			end
		end

invariant

	indent_increment_not_netative: 0 <= indent_increment

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
