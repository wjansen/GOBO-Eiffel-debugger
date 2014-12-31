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
			system := s
			create address_stack.make (100)
			create offset_stack.make (100)
			system.refresh_initialized_onces (Void)
				-- Guru section: 
			create s8.make (0)
			create s32.make (0)
			last_string := s8
			last_unicode := s32
			if attached backup_stack as bs and then not bs.is_empty then
				maybe_actionable := bs.item
			end
		ensure
			system_set: system = s
		end

feature -- Access 

	system: IS_RUNTIME_SYSTEM
			-- Descriptor of the target system. 

	actual_object: detachable ANY
		note
			return: "Object at field in `object' according to the `offset'."
		local
			act: POINTER
		do
			if address /= null then
				act := address + offset
				if act /= null then
					-- Guru section: ensure that `Result' is not always void 
					Result := object
					Result := as_any (system.dereferenced (act, field_type))
				end
			end
		end

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

feature {PC_DRIVER} -- Reading elementary data
	
	read_boolean 
		do  
			($last_boolean).memory_copy (address +  offset, Boolean_bytes)
		end

	read_character 
		do
			($last_character).memory_copy (address +  offset, Character_8_bytes)
		end

	read_character_32
		do
			($last_character_32).memory_copy (address +  offset, Character_32_bytes)
		end

	read_integer_8 
		do
			($last_integer).memory_copy (address +  offset, natural_8_bytes)
		end

	read_integer_16 
		do
			($last_integer).memory_copy (address +  offset, natural_16_bytes)
		end

	read_integer, read_integer_32 
		do
			($last_integer).memory_copy (address +  offset, natural_32_bytes)
		end

	read_integer_64 
		do
			($last_integer_64).memory_copy (address +  offset, natural_64_bytes)
		end

	read_natural_8 
		do
			($last_natural).memory_copy (address +  offset, natural_8_bytes)
		end

	read_natural_16 
		do
			($last_natural).memory_copy (address +  offset, natural_16_bytes)
		end

	read_natural, read_natural_32 
		do
			($last_natural).memory_copy (address +  offset, natural_32_bytes)
		end

	read_natural_64 
		do
			($last_natural_64).memory_copy (address +  offset, natural_64_bytes)
		end

	read_pointer 
		do
			($last_pointer).memory_copy (address +  offset, Pointer_bytes)
		end

	read_real 
		do
			($last_real).memory_copy (address +  offset, Real_32_bytes)
		end

	read_double 
		do
			($last_double).memory_copy (address +  offset, Real_64_bytes)
		end

	put_boolean (b: BOOLEAN)
		do
			(address + offset).memory_copy ($b, Boolean_bytes)
		end

	put_character (c: CHARACTER)
		do
			(address + offset).memory_copy ($c, Character_8_bytes)
		end

	put_character_32 (c: CHARACTER_32)
		do
			(address + offset).memory_copy ($c, Character_32_bytes)
		end

	put_integer_8 (i: INTEGER_8)
		do
			(address + offset).memory_copy ($i, natural_8_bytes)
		end

	put_integer_16 (i: INTEGER_16)
		do
			(address + offset).memory_copy ($i, natural_16_bytes)
		end

	put_integer_32 (i: INTEGER)
		do
			(address + offset).memory_copy ($i, natural_32_bytes)
		end

	put_integer_64 (i: INTEGER_64)
		do
			(address + offset).memory_copy ($i, natural_64_bytes)
		end

	put_natural_8 (i: NATURAL_8)
		do
			(address + offset).memory_copy ($i, natural_8_bytes)
		end

	put_natural_16 (i: NATURAL_16)
		do
			(address + offset).memory_copy ($i, natural_16_bytes)
		end

	put_natural_32 (i: NATURAL_32)
		do
			(address + offset).memory_copy ($i, natural_32_bytes)
		end

	put_natural_64 (i: NATURAL_64)
		do
			(address + offset).memory_copy ($i, natural_64_bytes)
		end

	put_real (r: REAL)
		do
			(address + offset).memory_copy ($r, Real_32_bytes)
		end

	put_double (d: DOUBLE)
		do
			(address + offset).memory_copy ($d, Real_64_bytes)
		end

	put_pointer (p: POINTER)
		do
			(address + offset).memory_copy ($p, Pointer_bytes)
		end

feature {PC_DRIVER} -- Object location 

	set_field (f: attached like field; in: attached ANY)
		do
			field := f
			field_type := f.type
			set_offset (f)
		end

	set_index (s: IS_SPECIAL_TYPE; i: NATURAL; in: attached ANY)
		do
			field := s.item_0
			field_type := s.item_type
			field_increment := field_type.field_bytes
			set_indexed_offset (s, i)
		end

feature {NONE} -- Implementation 

	address: POINTER
	
	field: detachable IS_FIELD

	field_type: detachable IS_TYPE

	field_increment: NATURAL
	
	set_offset (f: like field)
		do
			offset := offset_sum + f.offset
		end

	set_indexed_offset (s: IS_SPECIAL_TYPE; n: NATURAL)
		do
			offset := s.item_offset (n.to_integer_32)
		end

feature {NONE} -- Implementation 

	offset, offset_sum: INTEGER

	address_stack: ARRAYED_STACK [POINTER]

	offset_stack: ARRAYED_STACK [INTEGER]

	object: detachable ANY

	null: POINTER
	
	push_offset (t: IS_TYPE; obj: detachable ANY)
		require
			not_expanded: not t.is_subobject
		do
			offset_stack.force (offset_sum)
			offset_sum := 0
			address_stack.force (address)
			if attached obj then
				object := obj
				address := as_pointer(obj)
			else
				object := Void
				address := default_pointer
			end
		end

	push_expanded_offset
		do
			offset_stack.force (offset_sum)
			offset_sum := offset
			address_stack.force (address)
		end

	pop_offset
		do
			offset := offset_sum
			offset_sum := offset_stack.item
			offset_stack.remove
			address := address_stack.item
			object := as_any (address)
				-- To be improved! 
			address_stack.remove
		end

	as_actionable (t: IS_TYPE; a: detachable ANY): detachable PC_ACTIONABLE
		require
			is_actionable: t.is_actionable
		local
			a0: detachable ANY
		do
			if attached a0 then
					-- Add all known descendants of PC_ACTIONABLE to typeset of `a0': 
				a0 := backup_stack.item
			end
			a0 := a
			if attached {PC_ACTIONABLE} a0 as act then
				Result := act
			end
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

	maybe_actionable: detachable PC_ACTIONABLE

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"
	source:
	"[
	 Routines `read_...' and `put_...' are adapted versions
	 of class MANAGED_POINTER of GOBO's "free_elks/support" cluster.
	 ]"

end
