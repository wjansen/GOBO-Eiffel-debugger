note

	description:
		"[ 
		 Abstract class for treating elementary components and grouping marks 
		 in the course of deep object traversal. 
		 ]"

deferred class PC_TARGET [O_]
	-- O_: type of idents generated 

inherit

	PC_BASE

	IS_BASE

feature {PC_BASE} -- Initialization 

	reset
		note
			action: "Reset the object to the initial state."
		do
			top_ident := void_ident
		end

feature -- Access 

	field: detachable IS_ENTITY
			-- Definition of the currently treated object. 

	void_ident: detachable O_
		note
			return: "Ident of `Void' objects (also used for anchoring)."
		deferred
		ensure
			is_default: attached Result as r implies Result = r.default
		end

	last_ident: O_
			-- Ident of the currently treated object. 

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
	
	top_ident: detachable O_
			-- Ident of top object. 

feature {PC_DRIVER} -- Pre and post handling of data 

	pre_object (t: IS_TYPE; id: detachable O_)
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

	post_object (t: IS_TYPE; id: detachable O_)
		note
			action:
				"[
				 Finish treatment of an object.
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

	pre_agent (a: IS_AGENT_TYPE; id: detachable O_)
		note
			action:
				"[
				 Begin treatment of an agent's closed operands. 
				 Default action: do nothing.
				 ]"
			a: "dynamic object type"
			id: "object ident"
		require
			is_agent: a.is_agent
		do
		end

	post_agent (a: IS_AGENT_TYPE; id: detachable O_)
		note
			action:
				"[
				 Finish treatment of an agent's closed operands.
				 Default action: do nothing.
				 ]"
			a: "dynamic object type"
			id: "object ident"
		do
		end

	pre_special (s: IS_SPECIAL_TYPE; n: NATURAL; id: detachable O_)
		note
			action:
				"[
				 Begin treatment of a new SPECIAL object.
				 Default action: do nothing.
				 ]"
			t: "dynamic object type"
			n: "count"
			id: "object ident"
		require
			n_not_negative: n >= 0
		do
		end

	post_special (s: IS_SPECIAL_TYPE; id: detachable O_)
		note
			action:
				"[
				 End action on a new SPECIAL.
				 Default action: do nothing.
				 ]"
			s: "object type"
			id: "object ident"
		do
		end

	finish (top: PC_TYPED_IDENT [O_])
		note
			action:
				"[
				 Finish action on the persistence closure.
				 Default action: set `top_ident'.
				 ]"
			top: "top_object"
		do
			top_ident := top.ident
		ensure
			top_ident_set: top_ident = top.ident
		end

feature {PC_DRIVER} -- Writing elementary data 

	put_boolean (b: BOOLEAN)
		note
			action: "Treat value `b' located within object at `loc'."
		deferred
		end

	put_character (c: CHARACTER)
		note
			action: "Treat value `c' located within object at `loc'."
		deferred
		end

	put_character_32 (c: CHARACTER_32)
		note
			action: "Treat value `c' located within object at `loc'."
		deferred
		end

	put_integer (i: INTEGER_32)
		note
			action: "Treat value `i' located within object at `loc'."
		deferred
		end

	put_natural (n: NATURAL_32)
		note
			action: "Treat value `n' located within object at `loc'."
		deferred
		end

	put_integer_64 (i: INTEGER_64)
		note
			action: "Treat value `i' located within object at `loc'."
		deferred
		end

	put_natural_64 (n: NATURAL_64)
		note
			action: "Treat value `n' located within object at `loc'."
		deferred
		end

	put_real (r: REAL_32)
		note
			action: "Treat value `r' located within object at `loc'."
		deferred
		end

	put_double (d: REAL_64)
		note
			action: "Treat value `d' located within object at `loc'."
		deferred
		end

	put_pointer (p: POINTER)
		note
			action: "Treat value `p' located within object at `loc'."
		deferred
		end

	put_string (s: STRING)
		note
			action: "Treat value `s' located within object at `loc'."
		deferred
		end

	put_unicode (u: STRING_32)
		note
			action: "Treat value `u' located within object at `loc'."
		deferred
		end

	put_known_ident (id: O_; t: IS_TYPE)
		note 
			action: "Perform a certain action on an already completed object."
			id: "object ident"
			t: "dynamic type of `id'"
		require
			not_void: id /= void_ident
		deferred
		end

	put_void_ident (stat: detachable IS_TYPE)
		note
			action: "[
							 Convenience routine for `put_known_ident(void_ident,...)'.
							 Default action: do nothing.
							 ]"
		do
		end
	
	put_next_ident (id: detachable O_)
		note
			action:
			"[
			 Announce new object.
			 Default action: do nothing.
			 ]"
			id: "object ident"
		do
		end

	put_new_object (t: IS_TYPE)
		note
			action: "Set `last_ident' for a new object."
			t: "dynamic object type"
		require
			not_special: not t.is_special
		deferred
		end

	put_new_special (st: IS_SPECIAL_TYPE; n, cap: NATURAL)
		note
			action: "Set `last_ident' for a new SPECIAL object."
			st: "dynamic object type"
			n: "count"
			cap: "capacity"
		deferred
		end
	
	pre_new_object (t: IS_TYPE)
		note
			action:
			"[
			 Set `last_ident' for a new object and begin treatment of the object.
			 Default action: call `put_new_object' and 'pre_object'.
			 ]"
			t: "dynamic object type"
		require
			not_special: not t.is_special
			not_agent: not t.is_agent
		local
			id: O_
		do
			put_new_object (t)
			id := last_ident
			pre_object (t, id)
			last_ident := id
		end

	pre_new_special (st: IS_SPECIAL_TYPE; n, cap: NATURAL)
		note
			action:
			"[
			 Set `last_ident' for a new special object and begin treatment
			 of the object.
			 Default action: call `put_new_special' and 'pre_special'.
			 ]"
			 st: "dynamic object type"
			 n: "count"
			 cap: "capacity"
		local
			id: O_
		do
			put_new_special (st, n, cap)
			id := last_ident
			pre_special (st, n, id)
			last_ident := id
		end

feature {PC_DRIVER} -- Writing array data
	
	put_booleans (bb: SPECIAL [BOOLEAN]; n: INTEGER)
		note
			action: "Treat array `bb'."
		require
			large_enough: bb.capacity >= n
		deferred
		end
	
	put_characters (cc: SPECIAL [CHARACTER]; n: INTEGER)
		note
			action: "Treat array `cc'."
		require
			large_enough: cc.capacity >= n
		deferred
		end
	
	put_characters_32 (cc: SPECIAL [CHARACTER_32]; n: INTEGER)
		note
			action: "Treat array `cc'."
		require
			large_enough: cc.count >= n
		deferred
		end
	
	put_integers_8 (ii: SPECIAL [INTEGER_8]; n: INTEGER)
		note
			action: "Treat array `ii'."
		require
			large_enough: ii.capacity >= n
		deferred
		end
	
	put_integers_16 (ii: SPECIAL [INTEGER_16]; n: INTEGER)
		note
			action: "Treat array `ii'."
		require
			large_enough: ii.capacity >= n
		deferred
		end
	
	put_integers (ii: SPECIAL [INTEGER_32]; n: INTEGER)
		note
			action: "Treat array `ii'."
		require
			large_enough: ii.capacity >= n
		deferred
		end
	
	put_integers_64 (ii: SPECIAL [INTEGER_64]; n: INTEGER)
		note
			action: "Treat array `ii'."
		require
			large_enough: ii.capacity >= n
		deferred
		end
	
	put_naturals_8 (nn: SPECIAL [NATURAL_8]; n: INTEGER)
		note
			action: "Treat array `nn'."
		require
			large_enough: nn.capacity >= n
		deferred
		end
	
	put_naturals_16 (nn: SPECIAL [NATURAL_16]; n: INTEGER)
		note
			action: "Treat array `nn'."
		require
			large_enough: nn.capacity >= n
		deferred
		end
	
	put_naturals (nn: SPECIAL [NATURAL_32]; n: INTEGER)
		note
			action: "Treat array `nn'."
		require
			large_enough: nn.capacity >= n
		deferred
		end
	
	put_naturals_64 (nn: SPECIAL [NATURAL_64]; n: INTEGER)
		note
			action: "Treat array `nn'."
		require
			large_enough: nn.capacity >= n
		deferred
		end
	
	put_reals (rr: SPECIAL [REAL_32]; n: INTEGER)
		note
			action: "Treat array `rr'."
		require
			large_enough: rr.capacity >= n
		deferred
		end
	
	put_doubles (dd: SPECIAL [REAL_64]; n: INTEGER)
		note
			action: "Treat array `dd'."
		require
			large_enough: dd.capacity >= n
		deferred
		end
	
	put_pointers (pp: SPECIAL [POINTER]; n: INTEGER)
		note
			action: "Treat array `pp'."
		require
			large_enough: pp.capacity >= n
		deferred
		end
	
	put_strings (ss: SPECIAL [detachable STRING_8]; n: INTEGER)
		note
			action: "Treat array `ss'."
		require
			large_enough: ss.capacity >= n
		deferred
		end
	
	put_unicodes (uu: SPECIAL [detachable STRING_32]; n: INTEGER)
		note
			action: "Treat array `uu'."
		require
			large_enough: uu.capacity >= n
		deferred
		end
	
	put_references (rr: SPECIAL [detachable O_]; n: INTEGER)
		note
			action: "Treat array `rr'."
		require
			large_enough: rr.capacity >= n
		deferred
		end
	
feature {PC_DRIVER, PC_TARGET} -- 

	put_once (cls: detachable IS_CLASS_TEXT; nm: STRING; id: O_)
		note
			action:
			"[
			 If `cls/=Void' then put object as once call of name `nm'
			 located in class `cls', `last_ident' is set to `id'
			 if the new once value has been accepted,
			 otherwise to the actual once value. 
			 Default action: set `last_ident' to `id'.
			 ]"
			 cls: "once call descriptor"
			 nm: "routine name"
			id: "object ident"
		require
			not_null: id /= void_ident
		do
			last_ident := id
		ensure
			when_no_once: cls = Void implies last_ident = id
		end

feature {PC_DRIVER} -- Object location 

	set_field (f: like field; in: detachable O_)
		note
			action: "Set the descriptor for the next field to be treated."
			f: "field descriptor"
			in: "ident of enclosing object"
		deferred
		ensure
			field_set: field = f
		end

	set_index (s: IS_SPECIAL_TYPE; i: NATURAL; in: detachable O_)
		note
			action: "Set the descriptor and index for the array item to be treated."
			s: "type descriptor"
			i: "index"
			in: "ident of enclosing object"
		deferred
		ensure
			field_type_set: field_type = s.generic_at (0)
		end

feature -- Object finalization 

	finalize: detachable PROCEDURE [ANY, TUPLE [id: PC_TYPED_IDENT [O_]]]
			-- Procedure to be applied to all objects after 
			-- end of traversal (may be `Void'). 

feature {NONE} -- Implementation 

	field_type: detachable IS_TYPE
		note
			return: "Descriptor of the type of the next field to be treated."
		deferred
		end

feature {NONE} -- Implementation 

	tmp_str: STRING = "..............................................."

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
