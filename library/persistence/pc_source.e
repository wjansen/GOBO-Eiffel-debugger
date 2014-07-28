note

	description:
	"[ 
	 Abstract class for accessing elementary components and grouping marks 
	 in the course of deep object traversal. 
	 ]"

deferred class PC_SOURCE [I_]
	-- I_: type of object idents 

inherit

	PC_BASE

	IS_BASE

	PLATFORM
		undefine
			copy,
			is_equal,
			out
		end

feature {} -- Initialization 

	make_source
		local
			a: detachable ANY
		do
			create last_string.make (32)
			create last_unicode.make (32)
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
			create strings.make_filled (Void, 0)
			create unicodes.make_filled (Void, 0)
			create references.make_filled (void_ident, 0)
			default_create
			reset
				-- Make some attributes alive: 
			if system.valid_type (0) then
				a := last_string
				a := last_unicode
			end
		end
	
feature -- Initialization 

	reset
		do
			last_string.wipe_out
			last_unicode.wipe_out
			field := Void
		end

feature -- Access 

	system: IS_SYSTEM
		note
			return: "Descriptor of the source system."
		deferred
		end

	has_integer_indices: BOOLEAN
		note
			return: "Is O_ NATURAL?"
		deferred
		end
	
	has_consecutive_indices: BOOLEAN
		note
			return: "Are indices consecutive NATURALs?"
		deferred
		end
	
	has_position_indices: BOOLEAN
		note
			return: "Are indices file positions?"
		deferred
		end
	
	can_expand_strings: BOOLEAN
		note
			return: "May STRING and STRING_32 objects be expanded?"
		deferred
		end

	must_expand_strings: BOOLEAN
		note
			return: "Are STRING and STRING_32 objects to be expanded?"
		deferred
		end

	has_capacities: BOOLEAN
		note
			return: "Is capacity of SPECIAL objects preserved?"
		deferred
		end
	
	is_serial: BOOLEAN
		note
			return: "Is the object order prescribed by the source?"
		deferred
		end

	void_ident: detachable I_
		note
			return: "Ident of `Void' objects (also used for anchoring)."
		deferred
		ensure
			is_default: attached Result as r implies Result = r.default
		end

feature -- Status 

	field: detachable IS_ENTITY
			-- Definition of the actually treated object. 

	last_ident: detachable I_
			-- Ident of the most recently started object. 

	last_dynamic_type: detachable IS_TYPE
		-- Dynamic type of the object represented by `last_ident'
	
	last_count: NATURAL
			-- Count of the SPECIAL object represented by `last_ident'
	
	last_capacity: NATURAL
			-- Capacity of the SPECIAL object represented by `last_ident'
	
	last_class: detachable IS_CLASS_TEXT
	
	last_routine: detachable IS_ROUTINE
			-- Routine descriptor of the most recently read stack frame. 

	last_boolean: BOOLEAN
			-- Most recently read BOOLEAN value. 

	last_character: CHARACTER_8
			-- Most recently read CHARACTER value. 

	last_character_32: CHARACTER_32
			-- Most recently read CHARACTER_32 value. 

	last_integer: INTEGER_32
			-- Most recently read INTEGER_32 value. 

	last_natural: NATURAL_32
			-- Most recently read NATURAL_32 value. 

	last_integer_64: INTEGER_64
			-- Most recently read INTEGER_64 value. 

	last_natural_64: NATURAL_64
			-- Most recently read NATURAL_64 value. 

	last_real: REAL_32
			-- Most recently read REAL_32 value. 

	last_double: REAL_64
			-- Most recently read REAL_64 value. 

	last_pointer: POINTER
			-- Most recently read POINTER value. 
			-- True POINTER 

	last_string: STRING
			-- Most recently read STRING value. 

	last_unicode: STRING_32
			-- Most recently read STRING_32 value. 

	booleans: SPECIAL [BOOLEAN]
			-- Array filled with entries of most recently read
			-- SPECIAL [BOOLEAN] object.
	
	characters: SPECIAL [CHARACTER_8]
			-- Array filled with entries of most recently read
			-- SPECIAL [CHARACTER_8] object.
	
	characters_32: SPECIAL [CHARACTER_32]
			-- Array filled with entries of most recently read
			-- SPECIAL [CHARACTER_32] object.
	
	integers_8: SPECIAL [INTEGER_8]
			-- Array filled with entries of most recently read
			-- SPECIAL [INTEGER_32] object.
	
	integers_16: SPECIAL [INTEGER_16]
			-- Array filled with entries of most recently read
			-- SPECIAL [INTEGER_32] object.
	
	integers: SPECIAL [INTEGER_32]
			-- Array filled with entries of most recently read
			-- SPECIAL [INTEGER_32] object.
	
	integers_64: SPECIAL [INTEGER_64]
			-- Array filled with entries of most recently read
			-- SPECIAL [INTEGER_64] object.
	
	naturals_8: SPECIAL [NATURAL_8]
			-- Array filled with entries of most recently read
			-- SPECIAL [NATURAL_32] object.
	
	naturals_16: SPECIAL [NATURAL_16]
			-- Array filled with entries of most recently read
			-- SPECIAL [NATURAL_32] object.
	
	naturals: SPECIAL [NATURAL_32]
			-- Array filled with entries of most recently read
			-- SPECIAL [NATURAL_32] object.
	
	naturals_64: SPECIAL [NATURAL_64]
			-- Array filled with entries of most recently read
			-- SPECIAL [NATURAL_64] object.
	
	reals: SPECIAL [REAL_32]
			-- Array filled with entries of most recently read
			-- SPECIAL [REAL_32] object.
	
	doubles: SPECIAL [REAL_64]
			-- Array filled with entries of most recently read
			-- SPECIAL [REAL_64] object.
	
	pointers: SPECIAL [POINTER]
			-- Array filled with entries of most recently read
			-- SPECIAL [POINTER] object.
	
	strings: SPECIAL [detachable STRING_8]
			-- Array filled with entries of most recently read
			-- SPECIAL [detachable STRING_8] object.
	
	unicodes: SPECIAL [detachable STRING_32]
			-- Array filled with entries of most recently read
			-- SPECIAL [detachable STRING_32] object.
	
	references: SPECIAL [detachable I_]
			-- Array filled with entries of most recently read
			-- SPECIAL [detachable I_] object.
	
feature {PC_DRIVER} -- Reading object definitions 

	adjust_to (id: like last_ident)
		note
			action: "Set `last_dynamic_type' and `last_count' according to `id'."
		deferred
		end

	read_field_ident
		note
			action: "Read object ident of a field and put it into `last_ident'."
		deferred
		end
	
	pre_object (t: IS_TYPE; id: detachable I_)
		note
			action: 
				"[
				 Begin treatment of an object.
				 Default action: do nothing.
				 ]"
			t: "dynamic object type"
			id:
			"[
			 object ident, equals `void_ident' if the object is of
			 an expanded type and is not boxed
			 ]"
		require
			not_special: not t.is_special
		do
		end

	post_object (t: IS_TYPE; id: detachable I_)
		note
			action: 
				"[
				 Finish treatment of object `id'.
				 Default action: do nothing.
				 ]"
			t: "dynamic type"
			id:
			"[
			 object ident, equals `void_ident' if the object is of
			 an expanded type and is not boxed
			 ]"
		require
			not_special: not t.is_special
		do
		end

	pre_agent (a: IS_AGENT_TYPE; id: I_)
		note
			action: 
				"[
				 Begin treatment of an agent's closed operands x
				 and set `last_ident' to the closed operands tuple of `a'.
				 Default action: do nothing.
				 ]"
			a: "dynamic object type"
			id: "object ident"
		do
		end

	post_agent (a: IS_AGENT_TYPE; id: I_)
		note
			action: 
				"[
				 Finish treatment of an agent's closed operands.
				 Default action: do nothing.
				 ]"
			a: "dynamic object type"
			id: "object ident"
		require
			id_not_void: id /= void_ident
		do
		end

	pre_special (s: IS_SPECIAL_TYPE; n: NATURAL; id: I_)
		note
			action: 
				"[
				 Begin treatment of SPECIAL object.
				 Default action: fill `booleans' or ... if `s.item_type' is a basic type.
			]"
			s: "object type"
			n: "count"
			id: "object ident"
		require
			n_not_negative: n >= 0
			id_not_void: id /= void_ident
		deferred
		end

	post_special (s: IS_SPECIAL_TYPE; id: I_)
		note
			action: 
				"[
				 End action on a new SPECIAL.
				 Default action: do nothing.
				 ]"
			s: "object type"
			id: "object ident"
		require
			not_null: id /= void_ident
		do
		end

feature {PC_BASE} -- Reading elementary data 

	read_boolean
		note
			action: 
				"[
				 Set `last_boolean' according to the value at `loc'
				 and having the declared type `t'.
				 ]"
		deferred
		end

	read_character
		note
			action: "Set `last_character' according to the value at `loc'."
		deferred
		end

	read_character_32
		note
			action: "Set `last_character_32' according to the value at `loc'."
		deferred
		end

	read_integer_8
		note
			action: "Set `last_integer' according to the value at `loc'."
		deferred
		end

	read_integer_16
		note
			action: "Set `last_integer' according to the value at `loc'."
		deferred
		end

	read_integer
		note
			action: "Set `last_integer' according to the value at `loc'."
		deferred
		end

	read_integer_64
		note
			action: "Set `last_integer_64' according to the value at `loc'."
		deferred
		end

	read_natural_8
		note
			action: "Set `last_natural' according to the value at `loc'."
		deferred
		end

	read_natural_16
		note
			action: "Set `last_natural' according to the value at `loc'."
		deferred
		end

	read_natural
		note
			action: "Set `last_natural' according to the value at `loc'."
		deferred
		end

	read_natural_64
		note
			action: "Set `last_natural_64' according to the value at `loc'."
		deferred
		end

	read_real
		note
			action: "Set `last_real' according to the value at `loc'."
		deferred
		end

	read_double
		note
			action: "Set `last_double' according to the value at `loc'."
		deferred
		end

	read_pointer
		note
			action: "Set `last_boolean' according to the value at `loc'."
		deferred
		end

	read_string
		note
			action: "Set `last_string' according to the value at `loc'."
		deferred
		end

	read_unicode
		note
			action: "Set `last_unicode' according to the value at `loc'."
		deferred
		end

feature {PC_DRIVER} -- Reading type components 

	read_once (id: I_)
		note
			action: 
				"[
				 If `id' is the ident of a once value set `last_class' to its home class
				 and `last_string' to its name.
				 Default action: `last_class:=Void'.
				 ]"
			id: ""
		require
			not_trivial: id /= void_ident
		do
			last_class := Void
		end

feature {PC_DRIVER} -- Object location 

	set_field (f: attached like field; in: detachable I_)
		note
			action: "Set the descriptor for the next field to be treated."
			f: "field descriptor"
			in: "ident of enclosing object"
		do
			field := f
		ensure
			field_set: field = f
		end

	set_index (s: IS_SPECIAL_TYPE; i: NATURAL; in: I_)
		note
			action: "Set the array index `i' and of the next array field to be treated."
			s: "type descriptor"
			in: "ident of enclosing object"
		deferred
		end

feature -- Object finalization 

	finalize: detachable PROCEDURE [ANY, TUPLE [id: attached I_]]
			-- Procedure to be applied to all objects after 
			-- end of traversal (may be `Void'). 

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
