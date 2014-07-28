note

	description: "Restoring the persistence closure of one object in memory."

class PC_MEMORY_TARGET

inherit

	PC_TARGET [ANY]
		redefine
			field,
			default_create,
			reset,
			pre_object,
			post_object,
			pre_special,
			post_special,
			pre_agent,
			post_agent,
			finish,
			put_once
		end

	PC_MEMORY_ACCESS
		redefine
			field,
			default_create
		end

create

	make,
	default_create

feature {NONE} -- Initialization 

	make (s: like system; act: BOOLEAN)
		do
			make_memory (s)
			create references.make_filled (Void, 0)
			create booleans.make_filled (False, 0)
			create characters.make_filled ('%U', 0)
			create characters_32.make_filled ('%U', 0)
			create integers_8.make_filled (0, 0)
			create integers_16.make_filled (0, 0)
			create integers.make_filled (0, 0)
			create integers_64.make_filled (0, 0)
			create naturals_8.make_filled (0, 0)
			create naturals_16.make_filled (0, 0)
			create naturals.make_filled (0, 0)
			create naturals_64.make_filled (0, 0)
			create reals.make_filled (0, 0)
			create doubles.make_filled (0, 0)
			create pointers.make_filled (default_pointer, 0)
			reset
		ensure
			system_set: system = s
		end

	default_create
		do
			make (runtime_system, False)
		end

feature {PC_BASE} -- Initialization 

	reset
		do
			Precursor
			make_memory (system)
			last_ident := Void
			top_ident := Void
			top_object := Void
			top_type := Void
			first := True
				-- Guru section: set `last_ident' to a potentially non-void reference 
			last_ident := system
		ensure then
			no_object: not attached top_object
		end

feature -- Access 

	has_integer_indices: BOOLEAN = False

	has_consecutive_indices: BOOLEAN = False

	has_position_indices: BOOLEAN = False

	are_types_known: BOOLEAN = True

	void_ident: detachable ANY

	top_object: detachable ANY
			-- New object representing the persisence closure. 

	top_type: detachable IS_TYPE
			-- Type of `top_object' 

	actionable: BOOLEAN = False

	can_expand_strings: BOOLEAN = True

	must_expand_strings: BOOLEAN = False

	use_default_creation: BOOLEAN

	field: detachable IS_ENTITY [INTEGER]

feature -- Status setting
	
	set_top (t: attached like top_object)
		do
			if first then
					-- Add typset of `obj' to typeset of `top_array.item': 
				top_array.extend (t)
				top_object := top_array.last
				top_array.wipe_out
			end
		end

	set_actionable (act: BOOLEAN)
		note
			ction: "Not applicable."
		do
		end

	set_use_default_creation (use: BOOLEAN)
		do
			use_default_creation := use
		ensure
			use_default_creation_set: use_default_creation = use
		end

feature {PC_DRIVER} -- Reading object definitions 

	pre_object (t: IS_TYPE; as_ref: BOOLEAN; id: detachable ANY)
		do
			if as_ref then
				push_offset (t, id)
			else
				push_expanded_offset
			end
		end

	post_object (t: IS_TYPE; id: detachable ANY)
		do
			Precursor (t, id)
		end

	pre_agent (a: IS_AGENT_TYPE; id: detachable ANY)
		local
			obj: detachable ANY
		do
			if attached id as id_ then
				obj := system.closed_operands (id_, a)
			end
			push_offset (a, obj)
		end

	post_agent (a: IS_AGENT_TYPE; id: detachable ANY)
		do
			pop_offset
		end

	pre_special (s: IS_SPECIAL_TYPE; cap: NATURAL; id: detachable ANY)
		do
			object_is_special := True
			push_offset (s, id)
			if s.is_basic then
				inspect s.item_type.ident
				when Boolean_ident then
					if attached {like booleans} id as ss then
						booleans := ss
					end
				when Char8_ident then
					if attached {like characters} id as ss then
						characters := ss
					end
				when Char32_ident then
					if attached {like characters_32} id as ss then
						characters_32 := ss
					end
				when Int8_ident then
					if attached {like integers_8} id as ss then
						integers_8 := ss
					end
				when Int16_ident then
					if attached {like integers_16} id as ss then
						integers_16 := ss
					end
				when Int32_ident then
					if attached {like integers} id as ss then
						integers := ss
					end
				when Int64_ident then
					if attached {like integers_64} id as ss then
						integers_64 := ss
					end
				when Nat8_ident then
					if attached {like naturals_8} id as ss then
						naturals_8 := ss
					end
				when Nat16_ident then
					if attached {like naturals_16} id as ss then
						naturals_16 := ss
					end
				when Nat32_ident then
					if attached {like naturals} id as ss then
						naturals := ss
					end
				when Nat64_ident then
					if attached {like naturals_64} id as ss then
						naturals_64 := ss
					end
				when Real32_ident then
					if attached {like reals} id as ss then
						reals := ss
					end
				when Real64_ident then
					if attached {like doubles} id as ss then
						doubles := ss
					end
				when Pointer_ident then
					if attached {like pointers} id as ss then
						pointers := ss
					end
				else
				end
			elseif attached {like references} id as obj then
				references := obj
			end
		end

	post_special (t: IS_SPECIAL_TYPE; id: detachable ANY)
		do
			pop_offset
			object_is_special := False
		end

	finish (top: detachable ANY)
		do
			top_ident := top
		end

feature {PC_DRIVER} -- Push and pop data 

	put_new_object (t: IS_TYPE)
		do
			if t.is_subobject then
				if t.generic_count > 0 then
					last_ident := system.new_instance (t, use_default_creation)
				else
					last_ident := system.new_boxed_instance (t)
				end
			else
				last_ident := system.new_instance (t, use_default_creation)
			end
			if first and then attached last_ident as id then
				set_top (id)
				top_type := t
				first := False
			else
				put_object (last_ident, t)
			end
		end

	put_new_special (s: IS_SPECIAL_TYPE; cap: NATURAL)
		do
			last_ident := system.new_array (s, cap)
			put_object (last_ident, s)
		end

	put_once (oc: detachable IS_ONCE_CALL; t: detachable IS_TYPE; id: ANY)
		do
			last_ident := id
			if attached oc as o then
				if not o.is_initialized then
					if id = void_ident then
						o.initialize_by (default_pointer)
					else
						o.initialize_by (as_pointer(id))
					end
				elseif attached as_any (o.address) as a and then system.type_of_any (a, o.type) = t then
					last_ident := a
				end
			end
		end

feature {PC_DRIVER} -- Writing elementary data 

	put_boolean (b: BOOLEAN)
		do
			if object_is_special then
				booleans [offset] := b
			elseif attached object as obj then
				set_boolean_field (offset, obj, b)
			end
		end

	put_character (c: CHARACTER)
		do
			if object_is_special then
				characters [offset] := c
			elseif attached object as obj then
				set_character_8_field (offset, obj, c)
			end
		end
	
	put_character_32 (c: CHARACTER_32)
		do
			if object_is_special then
				characters_32 [offset] := c
			elseif attached object as obj then
				set_integer_32_field (offset, obj, c.code)
			end
		end

	put_integer (i: INTEGER_32)
		do
			inspect field_type.ident
			when Int8_ident then
				if object_is_special then
					integers_8 [offset] := i.to_integer_8
				elseif attached object as obj then
					set_integer_8_field (offset, obj, i.to_integer_8)
				end
			when Int16_ident then
				if object_is_special then
					integers_16 [offset] := i.to_integer_16
				elseif attached object as obj then
					set_integer_16_field (offset, obj, i.to_integer_16)
				end
			else
				if object_is_special then
					integers [offset] := i
				elseif attached object as obj then
					set_integer_32_field (offset, obj, i)
				end
			end
		end

	put_natural (n: NATURAL_32)
		do
			inspect field_type.ident
			when Nat8_ident then
				if object_is_special then
					naturals_8 [offset] := n.to_natural_8
				elseif attached object as obj then
					set_natural_8_field (offset, obj, n.to_natural_8)
				end
			when Nat16_ident then
				if object_is_special then
					naturals_16 [offset] := n.to_natural_16
				elseif attached object as obj then
					set_natural_16_field (offset, obj, n.to_natural_16)
				end
			else
				if object_is_special then
					naturals [offset] := n
				elseif attached object as obj then
					set_natural_32_field (offset, obj, n)
				end
			end
		end

	put_integer_64 (i: INTEGER_64)
		do
			inspect field_type.ident
			when Int8_ident then
				if object_is_special then
					integers_8 [offset] := i.to_integer_8
				elseif attached object as obj then
					set_integer_8_field (offset, obj, i.to_integer_8)
				end
			when Int16_ident then
				if object_is_special then
					integers_16 [offset] := i.to_integer_16
				elseif attached object as obj then
					set_integer_16_field (offset, obj, i.to_integer_16)
				end
			when Int32_ident then
				if object_is_special then
					integers [offset] := i.to_integer_32
				elseif attached object as obj then
					set_integer_32_field (offset, obj, i.to_integer_32)
				end
			else
				if object_is_special then
					integers_64 [offset] := i
				elseif attached object as obj then
					set_integer_64_field (offset, obj, i)
				end
			end
		end

	put_natural_64 (n: NATURAL_64)
		do
			inspect field_type.ident
			when Nat8_ident then
				if object_is_special then
					naturals_8 [offset] := n.to_natural_8
				elseif attached object as obj then
					set_natural_8_field (offset, obj, n.to_natural_8)
				end
			when Nat16_ident then
				if object_is_special then
					naturals_16 [offset] := n.to_natural_16
				elseif attached object as obj then
					set_natural_16_field (offset, obj, n.to_natural_16)
				end
			when Nat32_ident then
				if object_is_special then
					naturals [offset] := n.to_natural_32
				elseif attached object as obj then
					set_natural_32_field (offset, obj, n.to_natural_8)
				end
			else
				if object_is_special then
					naturals_64 [offset] := n
				elseif attached object as obj then
					set_natural_64_field (offset, obj, n)
				end
			end
		end

	put_real (r: REAL_32)
		do
			if object_is_special then
				reals [offset] := r
			elseif attached object as obj then
				set_real_32_field (offset, obj, r)
			end
		end

	put_double (d: REAL_64)
		do
			if object_is_special then
				doubles [offset] := d
			elseif attached object as obj then
				set_real_64_field (offset, obj, d)
			end
		end

	put_pointer (p: POINTER)
		do
			if object_is_special then
				pointers [offset] := p
			elseif attached object as obj then
				set_pointer_field (offset, obj, p)
			end
		end

	put_string (s: STRING)
		local
			a: detachable ANY
		do
			a := as_any (address)
			if attached {STRING} a as o then
				o.copy (s)
			else
					-- Guru: let assignment attempt work. 
				a := s
			end
		end

	put_unicode (u: STRING_32)
		local
			a: detachable ANY
		do
			a := as_any (address)
			if attached {STRING_32} a as o then
				o.copy (u)
			else
					-- Guru: let assignment attempt work. 
				a := u
			end
		end

	put_known_ident (id: detachable ANY)
		do
			put_object (id, field_type)
		end

feature {PC_DRIVER} -- Writing array data
	
	put_booleans (bb: SPECIAL [BOOLEAN]; n: INTEGER)
		do
			if attached {SPECIAL [BOOLEAN]} object as ss then
				ss.copy_data (bb, 0, 0, n)
			end
		end
	
	put_characters (cc: SPECIAL [CHARACTER_8]; n: INTEGER)
		do
			if attached {SPECIAL [CHARACTER_8]} object as ss then
				ss.copy_data (cc, 0, 0, n)
			end
		end
	
	put_characters_32 (cc: SPECIAL [CHARACTER_32]; n: INTEGER)
		do
			if attached {SPECIAL [CHARACTER_32]} object as ss then
				ss.copy_data (cc, 0, 0, n)
			end
		end
	
	put_integers_8 (ii: SPECIAL [INTEGER_8]; n: INTEGER)
		do
			if attached {SPECIAL [INTEGER_8]} object as ss then
				ss.copy_data (ii, 0, 0, n)
			end
		end
	
	put_integers_16 (ii: SPECIAL [INTEGER_16]; n: INTEGER)
		do
			if attached {SPECIAL [INTEGER_16]} object as ss then
				ss.copy_data (ii, 0, 0, n)
			end
		end
	
	put_integers (ii: SPECIAL [INTEGER_32]; n: INTEGER)
		do
			if attached {SPECIAL [INTEGER_32]} object as ss then
				ss.copy_data (ii, 0, 0, n)
			end
		end
	
	put_integers_64 (ii: SPECIAL [INTEGER_64]; n: INTEGER)
		do
			if attached {SPECIAL [INTEGER_64]} object as ss then
				ss.copy_data (ii, 0, 0, n)
			end
		end
	
	put_naturals_8 (nn: SPECIAL [NATURAL_8]; n: INTEGER)
		do
			if attached {SPECIAL [NATURAL_8]} object as ss then
				ss.copy_data (nn, 0, 0, n)
			end
		end
	
	put_naturals_16 (nn: SPECIAL [NATURAL_16]; n: INTEGER)
		do
			if attached {SPECIAL [NATURAL_16]} object as ss then
				ss.copy_data (nn, 0, 0, n)
			end
		end
	
	put_naturals (nn: SPECIAL [NATURAL_32]; n: INTEGER)
		do
			if attached {SPECIAL [NATURAL_32]} object as ss then
				ss.copy_data (nn, 0, 0, n)
			end
		end
	
	put_naturals_64 (nn: SPECIAL [NATURAL_64]; n: INTEGER)
		do
			if attached {SPECIAL [NATURAL_64]} object as ss then
				ss.copy_data (nn, 0, 0, n)
			end
		end
	
	put_reals (rr: SPECIAL [REAL_32]; n: INTEGER)
		do
			if attached {SPECIAL [REAL_32]} object as ss then
				ss.copy_data (rr, 0, 0, n)
			end
		end
	
	put_doubles (dd: SPECIAL [REAL_64]; n: INTEGER)
		do
			if attached {SPECIAL [REAL_64]} object as ss then
				ss.copy_data (dd, 0, 0, n)
			end
		end
	
	put_pointers (pp: SPECIAL [POINTER]; n: INTEGER)
		do
			if attached {SPECIAL [POINTER]} object as ss then
				ss.copy_data (pp, 0, 0, n)
			end
		end
	
	put_strings (ss: SPECIAL [detachable STRING_8]; n: INTEGER)
		do
			if attached {SPECIAL [detachable STRING_8]} object as aa then
				aa.copy_data (ss, 0, 0, n)
			end
		end
	
	put_unicodes (uu: SPECIAL [detachable STRING_32]; n: INTEGER)
		do
			if attached {SPECIAL [detachable STRING_32]} object as ss then
				ss.copy_data (uu, 0, 0, n)
			end
		end
	
	put_references (rr: SPECIAL [detachable ANY]; n: INTEGER)
		do
			if attached {SPECIAL [detachable ANY]} object as ss then
				ss.copy_data (rr, 0, 0, n)
			end
		end
	
feature {NONE} -- Implementation 

	first: BOOLEAN

	dummy_string: STRING = ""

	dummy_unicode: STRING_32 = ""

	references: SPECIAL [detachable ANY]
	booleans: SPECIAL [BOOLEAN]
	characters: SPECIAL [CHARACTER_8]
	characters_32: SPECIAL [CHARACTER_32]
	integers_8: SPECIAL [INTEGER_8]
	integers_16: SPECIAL [INTEGER_16]
	integers: SPECIAL [INTEGER_32]
	integers_64: SPECIAL [INTEGER_64]
	naturals_8: SPECIAL [NATURAL_8]
	naturals_16: SPECIAL [NATURAL_16]
	naturals: SPECIAL [NATURAL_32]
	naturals_64: SPECIAL [NATURAL_64]
	reals: SPECIAL [REAL_32]
	doubles: SPECIAL [REAL_64]
	pointers: SPECIAL [POINTER]
	
	put_object (val: detachable ANY; t: detachable IS_TYPE)
		do
			if object_is_special then
				if references.count = 0 then
					references.fill_with (val, 0, references.capacity - 1)
				end
				references [offset] := val
			else
				set_reference_field (offset, object, val)
			end
		end
	
invariant

	when_top_object: attached top_object implies attached top_type

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
