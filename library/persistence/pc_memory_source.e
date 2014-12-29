note

	description: 
		"[
		 Objects for accessing elementary components in memory 
		 and grouping marks in the course of deep object traversal. 
		 ]"
		 
class PC_MEMORY_SOURCE

inherit

	PC_RANDOM_ACCESS_SOURCE [attached ANY]
		undefine
			set_field
		redefine
			field, 
			reset,
			pre_object,
			post_object,
			pre_agent,
			post_agent,
			post_special,
			read_once,
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

	PC_MEMORY_ACCESS
		undefine
			default_create,
			copy,
			is_equal,
			out
		redefine
			field,
			make_memory,
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
	
feature {NONE} -- Initialization 

	make (s: like system)
		do
			make_memory (s)
			make_source 
			-- Add certain types to the typeset of `object':
			object := last_ident
			object := last_string
			object := last_unicode
			object := booleans
			object := characters
			object := characters_32
			object := integers_8
			object := integers_16
			object := integers
			object := integers_64
			object := naturals_8
			object := naturals_16
			object := naturals
			object := naturals_64
			object := reals
			object := doubles
			object := pointers
			object := strings
			object := unicodes
			object := references
			object := Void
		end

	make_memory (s: like system)
		do
			Precursor (s)
				-- Guru section: set `last_ident' to a potentially non-void reference 
			last_string := ""
			last_unicode := last_string
			last_ident := last_string
		end

feature -- Initialization 

	reset
		do
			Precursor
			make_memory (system)
			field_type := Void
			last_ident := void_ident
			last_dynamic_type := Void
		end

feature -- Access 

	has_integer_indices: BOOLEAN = False

	has_position_indices: BOOLEAN = False

	can_expand_strings: BOOLEAN = True

	must_expand_strings: BOOLEAN = False

	has_capacities: BOOLEAN = True

	actionable: BOOLEAN
			-- Do PC_ACTIONABLE objects need special treatment? 

	mode: INTEGER
			-- Traversal mode, one of `Lifo_flag', `Fifo_flag'. 

	void_ident: detachable ANY

	field: detachable IS_FIELD

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

	set_mode (m: INTEGER)
		note
			action: "Set traversal mode."
			m: "new mode"
		require
			lifo_or_fifo: m & Flat_flag = Lifo_flag or m & Flat_flag = Fifo_flag
		local
			flat: INTEGER
		do
			flat := m & Flat_flag
			if mode /= flat then
			end
			mode := flat
		end

	set_actionable (yes_no: BOOLEAN)
		note
			action: "Set the `actionable' option."
		do
			actionable := yes_no
		ensure
			actionable_set: actionable = yes_no
		end

	set_ident (obj: attached ANY)
		do
			process_ident (obj)
		end

feature {PC_DRIVER} -- Reading elementary data 

	read_string
		do
			if attached {STRING} object as s then
				last_string.copy (s)
			end
		end

	read_unicode
		do
			if attached {STRING_32} object as u then
				last_unicode.copy (u)
			end
		end

feature {PC_DRIVER} -- Reading structure definitions 

	read_field_ident
		do
			process_ident (actual_object)
		end

	read_once (id: attached ANY)
		do
			last_class := Void
			if attached system.once_by_address (as_pointer(id)) as o then
				if o.is_initialized then
					last_class := o.home
					last_string := o.name
				end
			end
		end

feature {PC_DRIVER} -- Reading object definitions 

	adjust_to (id: like last_ident)
		do
			process_ident (id)
		end
	
	pre_object (t: IS_TYPE; id: attached ANY)
		do
			if id /= void_ident then
				push_offset (t, id)
			else
				push_expanded_offset
			end
			if actionable and then t.is_actionable then
				if attached {PC_ACTIONABLE} as_actionable (t, id) as act then
					act.pre_store
				end
			end
		end

	post_object (t: IS_TYPE; id: attached ANY)
		do
			pop_offset
			if actionable and then t.is_actionable then
				if attached {PC_ACTIONABLE} as_actionable (t, id) as act then
					act.post_store
				end
			end
		end

	pre_agent (a: IS_AGENT_TYPE; id: attached ANY)
		local
			obj: ANY
		do
			obj := system.closed_operands (id, a)
			push_offset (a, obj)
		end

	post_agent (a: IS_AGENT_TYPE; id: attached ANY)
		do
			pop_offset
		end

	pre_special (s: IS_SPECIAL_TYPE; cap: NATURAL; id: attached ANY)
		do
			push_offset (s, id)
			inspect s.item_type.ident
			when Boolean_ident then
				if attached {like booleans} object as ss then
					booleans := ss
				end
			when Character_ident then
				if attached {like characters} object as ss then
					characters := ss
				end
			when Char32_ident then
				if attached {like characters_32} object as ss then
					characters_32 := ss
				end
			when Int8_ident then
				if attached {like integers_8} object as ss then
					integers_8 := ss
				end
			when Int16_ident then
				if attached {like integers_16} object as ss then
					integers_16 := ss
				end
			when Integer_ident then
				if attached {like integers} object as ss then
					integers := ss
				end
			when Int64_ident then
				if attached {like integers_64} object as ss then
					integers_64 := ss
				end
			when Nat8_ident then
				if attached {like naturals_8} object as ss then
					naturals_8 := ss
				end
			when Nat16_ident then
				if attached {like naturals_16} object as ss then
					naturals_16 := ss
				end
			when Nat32_ident then
				if attached {like naturals} object as ss then
					naturals := ss
				end
			when Nat64_ident then
				if attached {like naturals_64} object as ss then
					naturals_64 := ss
				end
			when Real32_ident then
				if attached {like reals} object as ss then
					reals := ss
				end
			when Real64_ident then
				if attached {like doubles} object as ss then
					doubles := ss
				end
			when Pointer_ident then
				if attached {like pointers} object as ss then
					pointers := ss
				end
			else
			end
		end
	
	post_special (t: IS_SPECIAL_TYPE; id: attached ANY)
		do
			pop_offset
		end

feature {NONE} -- Implementation 

	process_ident (id: like last_ident)
		do
			last_ident := void_ident
			last_dynamic_type := Void
			last_count := 0
			if id /= void_ident then
				last_ident := id
				if field /= Void and then field.type.is_subobject then
					last_dynamic_type := field.type
				elseif attached system.type_of_any (id, field_type) as t then
					last_dynamic_type := t
					if t.is_special and then attached {IS_SPECIAL_TYPE} t as s then
						last_count := system.special_count (id, s)
					end
					if t.is_string then
						if attached {STRING} id as s then
							last_string.copy (s)
						end
					elseif t.is_unicode then
						if attached {STRING_32} id as u then
							last_unicode.copy (u)
						end
					end
				end
			end
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
