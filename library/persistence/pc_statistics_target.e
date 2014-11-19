note

	description:

		"Formatting the persistence closure of an object for human reading "

class PC_STATISTICS_TARGET

inherit

	PC_ABSTRACT_TARGET
		redefine
			reset,
			pre_object,
			pre_agent,
			pre_special,
			put_void_ident,
			out
		end

	MEMORY
		redefine
			out
		end

	PLATFORM
		redefine
			out
		end

create

	make

feature {NONE} -- Initialization 

	make (full: BOOLEAN)
		do
			with_types := full
			create types.make (100, Void)
		end

feature {PC_DRIVER} -- Initialization 

	reset
		note
			action: "Reset the object to the initial state."
		do
			Precursor
			memory_size := 0
			object_count := 0
			special_count := 0
			once_count := 0
			types.clear
		end

feature -- Access 

	has_capacities: BOOLEAN = False
	
	with_types: BOOLEAN
			-- Register object types in `types'. 

	memory_size: INTEGER
			-- 

	type_count: INTEGER
		note
			return: ""
		local
			i: INTEGER
		do
			from
				i := types.count
			until i = 0 loop
				i := i - 1
				if attached types [i] then
					Result := Result + 1
				end
			end
		end

	once_count: INTEGER
			-- 

	object_count: INTEGER
			-- 

	special_count: INTEGER
			-- 

	agent_count: INTEGER
			-- 

	types: IS_SPARSE_ARRAY [detachable IS_TYPE]
			-- 

feature -- Output 

	out: attached STRING
		local
			m, tc: INTEGER
		do
			tc := type_count
			m := tc.max (memory_size)
			m := m.max (tc)
			m := m.max (object_count)
			m := m.max (agent_count)
			m := m.max (special_count)
			m := m.max (once_count)
			m := m.max (memory_size)
			m := m.out.count
			create Result.make (150)
			Result.append (once "  types:        ")
			append_formatted_integer (tc, m, Result)
			Result.extend ('%N')
			Result.append (once "  objects:      ")
			append_formatted_integer (object_count, m, Result)
			Result.extend ('%N')
			if agent_count > 0 then
				Result.append (once "  agents:       ")
				append_formatted_integer (agent_count, m, Result)
				Result.extend ('%N')
			end
			if special_count > 0 then
				Result.append (once "  arrays:       ")
				append_formatted_integer (special_count, m, Result)
				Result.extend ('%N')
			end
			if once_count > 0 then
				Result.append (once "  once results: ")
				append_formatted_integer (once_count, m, Result)
				Result.extend ('%N')
			end
			Result.append (once "  memory size:  ")
			append_formatted_integer (memory_size, m, Result)
			Result.extend ('%N')
		end

feature {PC_DRIVER} -- Push and pop data 

	pre_object (t: IS_TYPE; id: NATURAL)
		do
			if t.is_reference then
				if not t.is_agent then
					object_count := object_count + 1
				end
				memory_size := memory_size + integer_32_bytes
			end
			if id /= void_ident then
				types.force (t, t.ident)
			end
		end

	pre_agent (a: IS_AGENT_TYPE; id: NATURAL)
		do
			agent_count := agent_count + 1
			memory_size := memory_size + integer_32_bytes + 2*pointer_bytes
		end

	pre_special (s: IS_SPECIAL_TYPE; cap: NATURAL; id: NATURAL)
		do
			special_count := special_count + 1
			memory_size := memory_size + 2*integer_32_bytes
			types.force (s, s.ident)
		end

feature {PC_DRIVER} -- Writing elementary data 

	put_boolean (b: BOOLEAN)
		do
			memory_size := memory_size + 1
		end

	put_character (c: CHARACTER)
		do
			memory_size := memory_size + 1
		end

	put_character_32 (c: CHARACTER_32)
		do
			memory_size := memory_size + 4
		end

	put_integer (i: INTEGER_32)
		do
			inspect field_type.ident
			when Int8_ident then
				memory_size := memory_size + 1
			when Int16_ident then
				memory_size := memory_size + 2
			when Int32_ident then
				memory_size := memory_size + 4
			else
			end
		end

	put_natural (n: NATURAL_32)
		do
			inspect field_type.ident
			when Nat8_ident then
				memory_size := memory_size + 1
			when Nat16_ident then
				memory_size := memory_size + 2
			when Nat32_ident then
				memory_size := memory_size + 4
			else
			end
		end

	put_integer_64 (i: INTEGER_64)
		do
			inspect field_type.ident
			when Int8_ident then
				memory_size := memory_size + 1
			when Int16_ident then
				memory_size := memory_size + 2
			when Int32_ident then
				memory_size := memory_size + 4
			when Int64_ident then
				memory_size := memory_size + 8
			end
		end

	put_natural_64 (n: NATURAL_64)
		do
			inspect field_type.ident
			when Nat8_ident then
				memory_size := memory_size + 1
			when Nat16_ident then
				memory_size := memory_size + 2
			when Nat32_ident then
				memory_size := memory_size + 4
			when Nat64_ident then
				memory_size := memory_size + 8
			end
		end

	put_real (r: REAL_32)
		do
			memory_size := memory_size + 4
		end

	put_double (d: REAL_64)
		do
			memory_size := memory_size + 8
		end

	put_pointer (p: POINTER)
		do
			memory_size := memory_size + pointer_bytes
		end

	put_string (s: STRING)
		do
			if not must_expand_strings then
				special_count := special_count + 1
			end
			memory_size := memory_size + s.count + 5 * integer_32_bytes + pointer_bytes
		end

	put_unicode (u: STRING_32)
		do
			if not must_expand_strings then
				special_count := special_count + 1
			end
			memory_size := memory_size + u.count * 4 + 5 * integer_32_bytes + 2 * pointer_bytes
		end

	put_known_ident (id: NATURAL; t: IS_TYPE)
		do
			memory_size := memory_size + pointer_bytes
		end

	put_void_ident (stat: detachable IS_TYPE)
		do
			memory_size := memory_size + pointer_bytes
		end

feature {NONE} -- Implementation 

	append_formatted_integer (i: INTEGER; l: INTEGER; to: STRING)
		local
			k0, k1: INTEGER
		do
			k0 := to.count
			to.append_integer (i)
			k1 := l - (to.count - k0)
			k1 := k1 + k0
			from
			until k0 > k1 loop
				to.insert_character (' ', k0)
				k0 := k0 + 1
			end
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
