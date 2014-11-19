note

	description:
		"Writing the persistence closure of an objects in XML format."

class PC_XML_TARGET

inherit

	PC_ABSTRACT_TARGET
		redefine
			must_expand_strings,
			pre_object,
			post_object,
			pre_special,
			post_special,
			finish
		end

create

	make

feature {NONE} -- Initialization 

	make (f: like file; c: detachable READABLE_STRING_8; top: STRING; s: IS_SYSTEM)
		note
			action: "Create object for storing."
			f: "file to write"
			c: "comment"
			top: "name of top object"
		require
			f_open: f.is_open_write
			top_not_empty: top.count > 0
		do
			file := f
			top_name := top
			create tags.make (8)
			indent_increment := 2
			put_header
			open_tag (closure_tag)
			field_to_xml ("version", "1")
			finish_open_tag
		ensure
			file_set: file = f
		end

feature -- Access 

	must_expand_strings: BOOLEAN = False

	has_capacities: BOOLEAN = False
	
	top_name: STRING

feature {PC_DRIVER} -- Pre and post handling of data 

	pre_object (t: IS_TYPE; id: NATURAL)
		local
			tag: detachable STRING
		do
			Precursor (t, id)
			if t.is_subobject then
				tag := embedded_tag
			else
				if t.is_string or else t.is_unicode then
					string_id := id
				elseif t.is_agent then
					tag := agent_tag
				elseif t.is_special then
					tag := special_tag
				else
					tag := object_tag
				end
			end
			if attached tag as tg then
				open_tag (tg)
				if id /= void_ident then
					field_to_xml (ident_tag, id.out)
				else
					append_name
				end
				field_to_xml (type_tag, type_name (t))
				finish_open_tag
				tags.force (tg)
			else
				tags.force (Void)
			end
		end

	post_object (t: IS_TYPE; id: NATURAL)
		local
			tag: detachable STRING
		do
			tag := tags.item
			if attached tag as tg then
				close_tag (tg)
			end
			tags.remove
			file.flush
		end

	pre_special (t: IS_SPECIAL_TYPE; cap: NATURAL; id: NATURAL)
		local
			tag: STRING
		do
			Precursor (t, cap, id)
			tag := special_tag
			open_tag (tag)
			field_to_xml (ident_tag, id.out)
			field_to_xml (type_tag, type_name (t.item_type))
			field_to_xml (count_tag, cap.out)
			finish_open_tag
			tags.force (tag)
		end

	post_special (t: IS_SPECIAL_TYPE; id: NATURAL)
		do
			if attached tags.item as tg then
				close_tag (tg)
			end
			tags.remove
			file.flush
		end

	finish (top: PC_TYPED_IDENT [NATURAL])
		do
			top_ident := top.ident
			if top_ident /= void_ident then
				open_tag (reference_tag)
				field_to_xml (name_tag, top_name)
				field_to_xml (ident_tag, top_ident.out)
				finish_empty_tag
				close_tag (closure_tag)
			end
		end

feature {PC_DRIVER} -- Put elementary data 

	put_boolean (b: BOOLEAN)
		do
			basic_to_xml (b.out)
		end

	put_character (c: CHARACTER)
		do
			tmp_str.wipe_out
			tmp_str.append_integer (c.code)
			basic_to_xml (tmp_str)
		end

	put_character_32 (c: CHARACTER_32)
		do
			tmp_str.wipe_out
			tmp_str.append_integer (c.code)
			basic_to_xml (tmp_str)
		end

	put_integer (i: INTEGER_32)
		do
			basic_to_xml (i.out)
		end

	put_natural (n: NATURAL_32)
		do
			basic_to_xml (n.out)
		end

	put_integer_64 (i: INTEGER_64)
		do
			basic_to_xml (i.out)
		end

	put_natural_64 (n: NATURAL_64)
		do
			basic_to_xml (n.out)
		end

	put_real (r: REAL_32)
		do
			basic_to_xml (r.out)
		end

	put_double (d: REAL_64)
		do
			basic_to_xml (d.out)
		end

	put_pointer (p: POINTER)
		do
			basic_to_xml (p.out)
		end

	put_string (s: STRING)
		do
			open_tag (string_tag)
			field_to_xml (ident_tag, string_id.out)
			field_to_xml (value_tag, s)
			finish_empty_tag
		end

	put_unicode (u: STRING_32)
		do
			open_tag (unicode_tag)
			field_to_xml (ident_tag, string_id.out)
			field_to_xml (value_tag, u.to_string_8)
			finish_empty_tag
		end

	put_known_ident (id: NATURAL; t: IS_TYPE)
		do
			if id /= void_ident then
				open_tag (reference_tag)
				append_name
				field_to_xml (ident_tag, id.out)
				finish_empty_tag
			end
		end

feature {NONE} -- Implementation 

	closure_tag: STRING = "closure"

	reference_tag: STRING = "ref"

	object_tag: STRING = "object"

	embedded_tag: STRING = "subobject"

	special_tag: STRING = "special"

	agent_tag: STRING = "agent"

	type_tag: STRING = "type"

	name_tag: STRING = "name"

	index_tag: STRING = "index"

	ident_tag: STRING = "id"

	string_tag: STRING = "string"

	unicode_tag: STRING = "unicode"

	basic_tag: STRING = "basic"

	value_tag: STRING = "value"

	count_tag: STRING = "count"
	
	file: PLAIN_TEXT_FILE

	string_id: NATURAL

	tags: ARRAYED_STACK [detachable STRING]

	append_name
		do
			if index = -1 then
				tmp_str.wipe_out
				field.append_name (tmp_str)
				field_to_xml (name_tag, tmp_str)
			else
				field_to_xml (index_tag, index.out)
			end
		end

	type_name (td: IS_TYPE): STRING
		do
			create Result.make (20)
			td.append_name (Result)
		end

	open_tag (tag: STRING)
		do
			indent
			indent_size := indent_size + indent_increment
			file.put_character ('<')
			file.put_string (tag)
		end

	finish_open_tag
		do
			file.put_character ('>')
			file.put_character ('%N')
			file.flush
		end

	finish_empty_tag
		do
			file.put_character ('/')
			finish_open_tag
			indent_size := indent_size - indent_increment
		end

	close_tag (tag: STRING)
		do
			indent_size := indent_size - indent_increment
			indent
			file.put_character ('<')
			file.put_character ('/')
			file.put_string (tag)
			file.put_character ('>')
			file.put_character ('%N')
			file.flush
		end

	field_to_xml (key, val: STRING)
		do
			file.put_character (' ')
			file.put_string (key)
			file.put_character ('=')
			file.put_character ('%'')
			file.put_string (val)
			file.put_character ('%'')
		end

	field_name_to_xml
		do
			append_name
		end

	basic_to_xml (value: STRING)
		do
			if attached field_type as ft then
				inspect ft.ident
				when Boolean_ident then
					open_tag (once "boolean")
				when Char8_ident then
					open_tag (once "char8")
				when Char32_ident then
					open_tag (once "char32")
				when Int8_ident then
					open_tag (once "int8")
				when Int16_ident then
					open_tag (once "int16")
				when Int32_ident then
					open_tag (once "int32")
				when Int64_ident then
					open_tag (once "int64")
				when Nat8_ident then
					open_tag (once "nat8")
				when Nat16_ident then
					open_tag (once "nat16")
				when Nat32_ident then
					open_tag (once "nat32")
				when Nat64_ident then
					open_tag (once "nat64")
				when Real32_ident then
					open_tag (once "real32")
				when Real64_ident then
					open_tag (once "real64")
				when Pointer_ident then
					open_tag (once "pointer")
				else
				end
				append_name
				field_to_xml (value_tag, value)
				finish_empty_tag
			end
		end

	xml_char (c: CHARACTER)
		do
			inspect c
			when '&' then
				file.put_string (once "&amp;")
			when '<' then
				file.put_string (once "&lt;")
			when '>' then
				file.put_string (once "&gt;")
			when '"' then
				file.put_string (once "&quot;")
			when '%'' then
				file.put_string (once "&aposr;")
			else
				file.put_character (c)
			end
		end

	ident_to_xml (i: INTEGER)
		do
			file.put_string (once " id=%'")
			file.put_string (i.out)
			file.put_character ('%'')
		end

	indent_increment, indent_size: INTEGER

	indent
		local
			i: INTEGER
		do
			from
				i := indent_size
			until i = 0 loop
				file.put_character (' ')
				i := i - 1
			end
		end

	doctype: STRING = 
	"{ 
	<!--  --> 
	<!-- Persistence closure of one Eiffel object --> 

	<!DOCTYPE closure [
	<!ELEMENT closure (object | special | agent)* >
	<!ELEMENT object (ref | basic | subobject)* >
	<!ATTLIST object 
		id ID #REQUIRED
		type CDATA #REQUIRED >
	<!ELEMENT special (ref | basic)* >
	<!ATTLIST special
		id ID #REQUIRED
		type CDATA #REQUIRED
		count CDATA #REQUIRED >
	<!ELEMENT subobject (ref | basic | subobject)* >
	<!ATTLIST subobject
		name CDATA #REQUIRED
		type CDATA #REQUIRED >
	<!ELEMENT agent (ref | basic | subobject)* >
	<ATTLIST agent
		id ID #REQUIRED
		type CDATA #REQUIRED >
	<!ELEMENT ref EMPTY>
	<!ATTLIST ref
		name IDREF #REQUIRED 
		id ID #REQUIRED >
	<!ELEMENT basic (boolean | char8 | char32 
		| int8 | int16 | int32 | int64
		| nat8 | nat16 | nat32 | nat64
		| real32 | real64
		| pointer | string | unicode) >
	<!ELEMENT boolean EMPTY>
	<!ATTLIST boolean
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT char8 EMPTY>
	<!ATTLIST char8
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT char32 EMPTY>
	<!ATTLIST char32
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT int8 EMPTY>
	<!ATTLIST int8
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT int16 EMPTY>
	<!ATTLIST int16
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT int32 EMPTY>
	<!ATTLIST int32
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT int64 EMPTY>
	<!ATTLIST int64
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT nat8 EMPTY>
	<!ATTLIST nat8
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT nat16 EMPTY>
	<!ATTLIST nat16
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT nat32 EMPTY>
	<!ATTLIST nat32
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT nat64 EMPTY>
	<!ATTLIST nat64
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT real32f EMPTY>
	<!ATTLIST real32
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT real64 EMPTY>
	<!ATTLIST real64
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT pointer EMPTY>
	<!ATTLIST pointer
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT string EMPTY>
	<!ATTLIST string
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	<!ELEMENT unicode EMPTY>
	<!ATTLIST unicode
		name CDATA #REQUIRED
		value CDATA #REQUIRED >
	]>
	<!--  -->

	}"
	 
	 put_header
		note
			action: "Print header (provided for future use)"
		do
			file.put_string (once "<?xml version=%"1.0%" ?>%N")
			if True then
				file.put_string (doctype)
			end
		end
	
note

author: "Wolfgang Jansen"
date: "$Date$"
revision: "$Revision$"

end
