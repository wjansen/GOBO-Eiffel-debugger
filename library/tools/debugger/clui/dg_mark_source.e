note

	description:
		"[ 
		 Class for accessing elementary components in memory 
		 and grouping marks in the course of deep object traversal. 
		 ]"
		 
class DG_MARK_SOURCE

inherit

	PC_MEMORY_SOURCE
		redefine
			pre_object,
			pre_special,
			field,
			last_boolean,
			last_character,
			last_character_32,
			last_integer,
			last_natural,
			last_integer_64,
			last_natural_64,
			last_real,
			last_double,
			last_pointer,
			last_string,
			last_unicode
		end

	DG_MS_SOURCE [ANY]
		undefine
			copy,
			is_equal,
			out
		redefine
			field,
			last_boolean,
			last_character,
			last_character_32,
			last_integer,
			last_natural,
			last_integer_64,
			last_natural_64,
			last_real,
			last_double,
			last_pointer,
			last_string,
			last_unicode
		end

create
 
	make

feature -- Access 

	field: detachable IS_ENTITY 

	last_boolean: BOOLEAN
	last_character: CHARACTER
	last_character_32: CHARACTER_32
	last_integer: INTEGER_32
	last_natural: NATURAL_32
	last_integer_64: INTEGER_64
	last_natural_64: NATURAL_64
	last_real: REAL_32
	last_double: REAL_64
	last_pointer: POINTER
	last_string: STRING
	last_unicode: STRING_32

feature -- Status setting 

	set_frame (sf: IS_STACK_FRAME)
		do
			frame := sf
			at_line := sf.line
			at_column := sf.column
		end

	set_objects (o: like objects)
		do
			objects := o
		ensure
			objects_set: objects = o
		end

feature {PC_DRIVER} -- Reading object definitions 

	pre_object (t: IS_TYPE; as_ref: BOOLEAN; id: attached like void_ident)
		do
			Precursor (t, as_ref, id)
			if as_ref then
				objects.force (id)
			end
		end

	pre_special (st: IS_SPECIAL_TYPE; cap: NATURAL; id: attached like void_ident)
		do
			Precursor (st, cap, id)
			objects.force (id)
		end

feature {PC_DRIVER} -- Routine structure and call stack data 

	read_routine
		do
			last_routine := frame.routine
		end

	read_scope_var
		do
			last_scope_var := attached {IS_SCOPE_VARIABLE} field as ot
				and then ot.in_scope (at_line, at_column)
		end

feature -- Object location 

	set_local (l: IS_LOCAL)
		do
			field_type := l.type
			field := l
			share_from_pointer ($frame, 0)
			set_offset (l)
		end

	set_once (c: IS_ONCE_CALL)
		local
			t: IS_TYPE
			a: POINTER
		do
			last_once_init := c.is_initialized
			if last_once_init then
				if attached c.value as v then
					field_type := v.type
					t := v.type
					a := v.address
					offset_sum := 0
					offset := 0
					set_address (a, t.instance_bytes)
				end
				top_object := Void
			end
		end

feature {NONE} -- Implementation 

	objects: ARRAYED_LIST [ANY]

	frame: IS_STACK_FRAME

	at_line, at_column: INTEGER

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
