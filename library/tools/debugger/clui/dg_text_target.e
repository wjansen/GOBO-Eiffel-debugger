note 

	description: 
		"Formatting and displaying of command results of the debugger." 
	 
class DG_TEXT_TARGET
	 
inherit 
	 
	PC_TEXT_TARGET
		rename
			make as make_text,
			reset as reset_text,
			tmp_str as var_str
		export
			{DG_OUTPUT}
				indent_size,
				put_indented,
				append_name
		redefine
			default_create,
			reset_text,
			file,
			set_file,
			pre_object, pre_special, post_object, post_special, 
			put_known_ident, put_new_object, put_new_special,
			put_string, put_unicode,
			set_field, set_index,
			append_simple_string, append_simple_unicode,
			append_ident, append_reference, append_array 
		end 

	PC_QUALIFIER_TARGET 
		rename
			reset as reset_text,
			tmp_str as var_str
		undefine
			can_expand_strings,
			must_expand_strings,
			put_void_ident,
			put_once, 
			pre_agent,
			copy,
			is_equal,
			out
		redefine
			default_create,
			reset_text,
			pre_object,
			post_object,
			pre_special,
			post_special,
			put_known_ident,
			put_new_object,
			put_new_special,
			set_field,
			set_index
		end

	DG_GLOBALS
		redefine
			default_create
		select
			debuggee
		end
	
create

	make

feature {NONE} -- Initialization 

	default_create
		do
			Precursor {PC_QUALIFIER_TARGET} 
		end
	
	make (sys: like system; src: like source)
		do
			default_create
			make_text (ui_file, sys)
			source := src
			indent_increment := 3 
			any_to_print := "" 
			any_to_print := create {STRING_32}.make (0) 
			any_to_print := Void 			
		end
	
feature -- Initialization
	
	reset_text
		do
			Precursor {PC_TEXT_TARGET} 
			Precursor {PC_QUALIFIER_TARGET} 
		end
	
	reset (total: BOOLEAN)
		local 
			m: NATURAL 
		do
			if not total then
				m := max_ident
			end
			reset_text
			max_ident := m
			max_closure_ident := 0 
		end 

feature -- Constants 
 
	With_address: INTEGER = 0x04 
	Without_defaults: INTEGER = 0x08 
	Long_output: INTEGER = 0x10

	short_count: INTEGER = 48

	dots: STRING_8 = " ..."
	
feature -- Access

	source: PC_MEMORY_SOURCE

	file: DG_FILE
	
	any_to_print: detachable ANY

	in_closure: BOOLEAN 

	short_output: BOOLEAN
	
feature -- Status setting

	set_field_and_type (f: like field; t: IS_TYPE)
		do
			field := f
			field_type := t
		ensure
			field_set: field = f
			field_type_set: field_type = t
		end
	
	set_any_to_print (any: detachable ANY)
		do
			any_to_print := any
		ensure
			any_to_print_set: any_to_print = any
		end
	
	set_closure (closure: BOOLEAN)
		do
			in_closure := closure
		ensure
			in_closure_set: in_closure = closure
		end
	
	set_short_output (short: BOOLEAN)
		do
			short_output := short
		ensure
			short_output_set: short_output = short
		end

	set_indent_size (size: INTEGER)
		do
			indent_size := size
		ensure
			indent_size_set: indent_size = size
		end

	set_file (f: detachable like file)
		do
			if attached f as f_ then
				file := f_
			else
				file := ui_file
			end
		end

	indent
		do
			indent_size := indent_size + indent_increment
		end
	
	dedent
		do
			indent_size := indent_size - indent_increment
		end
	
feature {PC_DRIVER} -- Writing elementary data 
	
	pre_object (t: IS_TYPE; as_ref: BOOLEAN; id: NATURAL) 
		do 
			Precursor {PC_TEXT_TARGET} (t, as_ref, id)
			Precursor {PC_QUALIFIER_TARGET} (t, as_ref, id)
			if in_closure then 
				if file.skip_lines then 
					raise (once "") 
				end 
			end 
		end 
 
	post_object (t: IS_TYPE; id: NATURAL) 
		do 
			Precursor {PC_TEXT_TARGET} (t, id)
			if in_closure then 
				max_closure_ident := max_closure_ident.max (id) 
			end 
		end 
 
	pre_special (t: IS_SPECIAL_TYPE; cap: NATURAL; id: NATURAL) 
		do 
			Precursor {PC_TEXT_TARGET} (t, cap, id)
			Precursor {PC_QUALIFIER_TARGET} (t, cap, id)
			if in_closure then 
				if file.skip_lines then 
					raise (once "") 
				end 
			end 
		end 
	 
	post_special (s: IS_SPECIAL_TYPE; id: NATURAL) 
		do 
			Precursor {PC_TEXT_TARGET} (s, id)
			if in_closure then 
				max_closure_ident := max_closure_ident.max (id) 
			end 
		end 
	 
feature {PC_DRIVER} -- Writing elementary data

	put_new_object (t: IS_TYPE)
		do
			Precursor {PC_TEXT_TARGET} (t)
			Precursor {PC_QUALIFIER_TARGET} (t)
		end

	put_new_special (st: IS_SPECIAL_TYPE; cap: NATURAL)
		do
			Precursor {PC_TEXT_TARGET} (st, cap)
			Precursor {PC_QUALIFIER_TARGET} (st, cap)
		end

	put_known_ident (id: NATURAL; dynamic, static: IS_TYPE) 
		do 
			if in_closure then 
				Precursor {PC_TEXT_TARGET} (id, dynamic, static)
				Precursor {PC_QUALIFIER_TARGET} (id, dynamic, static)
			else 
				var_str.wipe_out 
				if id = void_ident then 
					append_name (True, var_str) 
					var_str.append (once "Void") 
				end 
				file.put_line (var_str) 
			end 
		end 
	 
	put_string (s: STRING_8) 
		do 
			if in_closure then 
			else
				Precursor (s)
			end 
			file.put_new_line 
		end 
	 
	put_unicode (u: STRING_32)
		do 
			if in_closure then
			else
				Precursor (u)
			end
			file.put_new_line 
		end 
	 
	append_simple_string (s: STRING_8; to: STRING)
		local
			short: STRING_8
			n: INTEGER
		do
			to.extend ('"')
			short := s
			if short_output then
				n := short.count
				if n > short_count then
					short := short.substring (1, short_count)
				end
				n := short.index_of ('%N', 1)
				if n > 0 then
					short := short.substring (1, n - 1)
				end
			end
			to.append (short.as_string_8)
			to.extend ('"')
			if short /= s then
				to.append (dots)
			end
		end
	
	append_simple_unicode (u: STRING_32; to: STRING)
		local
			short: STRING_32
			n: INTEGER
		do
			to.extend ('"')
			short := u
			if short_output then
				n := short.count
				if n > short_count then
					short := short.substring (1, short_count)
				end
				n := short.index_of ('%N', 1)
				if n > 0 then
					short := short.substring (1, n - 1)
				end
			end
			to.append (short.as_string_8)
			to.extend ('"')
			if short /= u then
				to.append (dots)
			end
			to.append (once " S32")
		end
	
	append_reference (t: IS_TYPE; as_ref: BOOLEAN; id: NATURAL; to: STRING) 
		do 
			Precursor (t, as_ref, id, to) 
			if as_ref then 
				if in_closure then 
					any_to_print := source.last_ident 
				else 
				end 
				if attached any_to_print as a then 
					if t.is_string and then attached {STRING_8} a as s then 
						append_simple_string (s, to) 
					elseif t.is_unicode and then attached {STRING_32} a as u then 
						append_simple_unicode (u, to) 
					end 
					if format & With_address = With_address then 
						to.append (once " at ") 
						to.append (as_pointer (any_to_print).out) 
						to.extend (' ') 
					end 
				end 
			end 
		end 
	 
	append_array (t: IS_SPECIAL_TYPE; n: NATURAL; id: NATURAL; to: STRING) 
		do 
			Precursor (t, n, id, to) 
			if in_closure then 
				any_to_print := source.last_ident 
			end 
			if attached any_to_print as a then 
				if format & With_address = With_address then 
					to.append (once " at ") 
					to.append (as_pointer (any_to_print).out) 
				end 
			end 
		end 
	 
	append_ident (id: NATURAL; to: STRING) 
		do 
			if in_closure then 
				Precursor (id, to) 
			end 
		end 
	 
	append_simple_name (ex: DG_EXPRESSION; ds: IS_STACK_FRAME; to: STRING_8) 
		require 
			is_closure_entity: ex.is_manifest and then ex.entity = closure_entity 
		local 
			root: like closure_top 
			top: DG_EXPRESSION 
			k: INTEGER 
			id: NATURAL 
		do 
			var_str.wipe_out 
			ex.append_name (var_str) 
		end 

feature {PC_DRIVER} -- Object location

	set_field (f: like field; in: NATURAL)
		do
			Precursor {PC_TEXT_TARGET} (f, in)
			Precursor {PC_QUALIFIER_TARGET} (f, in)
		end

	set_index (s: IS_SPECIAL_TYPE; i: NATURAL; in: NATURAL)
		do
			Precursor {PC_TEXT_TARGET} (s, i, in)
			Precursor {PC_QUALIFIER_TARGET} (s, i, in)
		end
	
invariant

note 
	author: "Wolfgang Jansen" 
	date: "$Date$" 
	revision: "$Revision$"	 
 
end
