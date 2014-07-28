note

	description: "Restoring the persistence closure of one object in memory."

class DG_RESET_TARGET

inherit

	DG_GLOBALS
		rename
			tmp_str as global_str
		undefine
			default_create,
			copy,
			is_equal,
			out
		end

	PC_MEMORY_TARGET
		rename
			runtime_system as debuggee
		undefine
			debuggee
		redefine
			reset,
			put_pointer,
			put_string,
			put_unicode,
			put_new_object,
			put_new_special,
			field
		end

	DG_MS_TARGET [ANY]
		rename
			runtime_system as debuggee
		undefine
			debuggee,
			finish,
			copy,
			is_equal,
			out
		redefine
			field
		end

create

	make

feature -- Initialization 

	reset
		do
			Precursor
			create objects.make (10)
			object_index := 0
		end

feature -- Access 

	field: detachable IS_ENTITY 

feature -- Status setting 

	set_frame (sf: IS_STACK_FRAME)
		do
			frame := sf
		end

	set_objects (o: like objects)
		do
			objects := o
		ensure
			objects_set: objects = o
		end

feature {PC_DRIVER, PC_TARGET} -- Push and pop structures 

	pre_routine (r: IS_ROUTINE)
		do
		end

	post_routine (r: IS_ROUTINE)
		do
		end

feature -- Writing elementary data 

	put_scope_var (t: BOOLEAN)
		do
		end

feature {PC_DRIVER} -- Object location 

	set_local (l: IS_LOCAL)
		do
			field_type := l.type
			share_from_pointer ($frame, 0)
			set_offset (l)
		end

	set_once (c: IS_ONCE_CALL; init: BOOLEAN)
		do
			if init then
				if attached c.value as v then
					set_address (v.address, v.type.instance_bytes)
				end
			else
				c.re_initialize
			end
		end

feature {PC_DRIVER}

	put_new_object (t: IS_TYPE)
		do
			object_index := object_index + 1
			last_ident := objects [object_index]
			put_object (last_ident, t)
		end

	put_new_special (s: IS_SPECIAL_TYPE; cap: NATURAL)
		do
			object_index := object_index + 1
			last_ident := objects [object_index]
			put_object (last_ident, s)
		end

feature {PC_DRIVER} -- Writing elementary data 

	put_pointer (p: POINTER)
		note
			action: "Do nothing."
		do
		end

	put_string (s: STRING)
		do
		end

	put_unicode (u: STRING_32)
		do
		end

feature {NONE} -- Implementation 

	objects: ARRAYED_LIST [ANY]

	object_index: INTEGER

	frame: IS_STACK_FRAME

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
