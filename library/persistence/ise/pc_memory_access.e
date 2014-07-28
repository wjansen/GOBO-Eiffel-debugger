note

	description:
		"[ 
		 Base class of PC_MEMORY_SOURCE and PC_MEMORY_TARGET 
		 to manage traversal through expanded objects. 
		 ]"

deferred class PC_MEMORY_ACCESS

inherit

	IS_BASE

	PC_BASE

	PC_ACTIONABLE
		undefine
			copy,
			is_equal,
			out
		end

feature {NONE} -- Initialization 

	make_memory (s: like system)
		local
			s8: STRING
			s32: STRING_32
		do
			create object_stack.make (100)
			create offset_stack.make (100)
			system := s
				-- Guru section: 
			create s8.make (0)
			create s32.make (0)
			object := s	-- attach `object'
		ensure
			system_set: system = s
		end

feature -- Access 

	system: IS_RUNTIME_SYSTEM
			-- Descriptor of the target system. 

feature {PC_DRIVER} -- Object location 

	set_field (f: attached like field; in: detachable ANY)
		do
			field := f
			field_type := f.type
			offset := f.location
		end

	set_index (s: IS_SPECIAL_TYPE; i: NATURAL; in: ANY)
		do
			field := Void
			field_type := s.item_type
			offset := i.to_integer_32
		end

feature {} -- Implementation 

	field: detachable IS_ENTITY [INTEGER]

	field_type: detachable IS_TYPE

	field_increment: INTEGER = 1

	null: POINTER
	
	offset: INTEGER

	object_stack: ARRAYED_STACK [like object]

	offset_stack: ARRAYED_STACK [INTEGER]

	object_is_special: BOOLEAN

	object: ANY

	push_offset (t: IS_TYPE; obj: detachable ANY)
		require
			not_expanded: not t.is_subobject
		local
			i: INTEGER
		do
			object_stack.force (object)
			if attached field as f then
				i := field.location
			end
			offset_stack.force (i)
			if attached obj as o then
				object := o
			end
		end

	push_expanded_offset
		do
			object_stack.force (object)
			offset_stack.force (-1)
		end

	pop_offset
		do
			object := object_stack.item
			object_stack.remove
			offset := offset_stack.item
			offset_stack.remove
		end

	address: POINTER
	
	as_actionable (t: IS_TYPE; a: detachable ANY): detachable PC_ACTIONABLE
		do
		end
	
	top_array: ARRAYED_LIST [ANY]
		note
			return:
				"[
				 Auxiliary object to share typesets of serializer and
				 deserializer top objects.
				 ]"
		once
			create Result.make (1)
		end

	deep: BOOLEAN = True
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
