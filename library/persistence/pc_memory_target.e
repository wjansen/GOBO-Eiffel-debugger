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
			pre_agent,
			post_agent,
			pre_special,
			post_special,
			finish,
			put_once
		end

	PC_MEMORY_ACCESS
		redefine
			default_create,
			field,
			put_integer_64,
			put_natural_64
		end

create

	make,
	default_create

feature {NONE} -- Initialization 

	make (s: like system; act: BOOLEAN)
		do
			set_actionable (act)
			make_memory (s)
			create actionables.make (100)
			reset
		ensure
			system_set: system = s
			actionable_set: actionable = act
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
			actionables.wipe_out
			first := True
				-- Guru section: set `last_ident' to a potentially non-void reference 
			last_ident := system
		ensure then
			first: first
		end

feature -- Access 

	has_integer_indices: BOOLEAN = False

	has_consecutive_indices: BOOLEAN = False

	has_position_indices: BOOLEAN = False

	has_capacities: BOOLEAN

	are_types_known: BOOLEAN = True

	void_ident: detachable ANY

	actionable: BOOLEAN

	can_expand_strings: BOOLEAN = True

	must_expand_strings: BOOLEAN = False

	use_default_creation: BOOLEAN

	field: detachable IS_FIELD

feature -- Status setting
	
	set_actionable (act: BOOLEAN)
		do
			actionable := act
		ensure
			actionable_set: actionable = act
		end

	set_use_default_creation (use: BOOLEAN)
		do
			use_default_creation := use
		ensure
			use_default_creation_set: use_default_creation = use
		end

feature {PC_DRIVER} -- Reading object definitions 

	pre_object (t: IS_TYPE; id: detachable ANY)
		do
			if id /= Void_ident then
				push_offset (t, id)
			else
				push_expanded_offset
			end
		end

	post_object (t: IS_TYPE; id: detachable ANY)
		do
			pop_offset
			if actionable and then t.is_actionable then
				if attached {PC_ACTIONABLE} as_actionable (t, id) as act then
					actionables.extend (act)
				end
			end
		end

	pre_agent (a: IS_AGENT_TYPE; id: detachable ANY)
		do
			push_offset (a, system.closed_operands (id, a))
		end

	post_agent (a: IS_AGENT_TYPE; id: detachable ANY)
		do
			pop_offset
		end

	pre_special (s: IS_SPECIAL_TYPE; cap: NATURAL; id: detachable ANY)
		do
			push_offset (s, id)
		end

	post_special (t: IS_SPECIAL_TYPE; id: detachable ANY)
		do
			pop_offset
		end

	finish (top: ANY; type: IS_TYPE)
		do
			Precursor (top, type)
			across actionables as act loop
				act.item.post_retrieve
			end
			actionables.wipe_out
		end

feature {PC_DRIVER} -- Push and pop data 

	put_new_object (t: IS_TYPE)
		do
			if t.flags & t.Missing_id_flag /= 0 then
				last_ident := system.new_boxed_instance (t)
			else
				last_ident := system.new_instance (t, use_default_creation)
			end
			if first and then attached last_ident as id then
				first := False
			else
				put_pointer (as_pointer(last_ident))
			end
		end

	put_new_special (s: IS_SPECIAL_TYPE; n, cap: NATURAL)
		do
			last_ident := system.new_array (s, cap)
			system.set_special_count (last_ident, s, n)
			put_pointer (as_pointer(last_ident))
		end

	put_once (cls: detachable IS_CLASS_TEXT; nm: STRING; id: ANY)
		do
			last_ident := id
			if cls /= Void and then
				attached system.once_by_name_and_class (nm, cls) as o
			 then
				if not o.is_initialized then
					if id = void_ident then
						o.initialize_by (default_pointer)
					else
						o.initialize_by (as_pointer(id))
					end
				elseif attached to_any (o.value_address) as a
					and then system.type_of_any (a, Void) = system.type_of_any (last_ident, Void)
				 then
					last_ident := a
				end
			end
		end

feature {PC_DRIVER} -- Writing elementary data 

	put_integer (i: INTEGER_32)
		do
			inspect field_type.ident
			when Int8_ident then
				put_integer_8 (i.to_integer_8)
			when Int16_ident then
				put_integer_16 (i.to_integer_16)
			else
				put_integer_32 (i.to_integer_32)
			end
		end

	put_integer_64 (i: INTEGER_64)
		do
			inspect field_type.ident
			when Int8_ident then
				put_integer_8 (i.to_integer_8)
			when Int16_ident then
				put_integer_16 (i.to_integer_16)
			when Int32_ident then
				put_integer_32 (i.to_integer_32)
			else
				Precursor (i)
			end
		end

	put_natural (n: NATURAL_32)
		do
			inspect field_type.ident
			when Nat8_ident then
				put_natural_8 (n.to_natural_8)
			when Nat16_ident then
				put_natural_16 (n.to_natural_16)
			else
				put_natural_32 (n.to_natural_32)
			end
		end

	put_natural_64 (n: NATURAL_64)
		do
			inspect field_type.ident
			when Nat8_ident then
				put_natural_8 (n.to_natural_8)
			when Nat16_ident then
				put_natural_16 (n.to_natural_16)
			when Nat32_ident then
				put_natural_32 (n.to_natural_32)
			else
				Precursor (n)
			end
		end

	put_string (s: STRING)
		local
			a: detachable ANY
		do
			a := object
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
			a := object
			if attached {STRING_32} a as o then
				o.copy (u)
			else
					-- Guru: let assignment attempt work. 
				a := u
			end
		end

	put_known_ident (t: IS_TYPE; id: detachable ANY)
		do
			put_pointer (as_pointer(id))
		end

feature {PC_DRIVER} -- Writing array data
	
	put_booleans (bb: SPECIAL [BOOLEAN]; n: INTEGER)
		do
			put_mem (address, offset, bb.base_address, n*Boolean_bytes)
		end
	
	put_characters (cc: SPECIAL [CHARACTER_8]; n: INTEGER)
		do
			put_mem (address, offset, cc.base_address, n*Character_8_bytes)
		end
	
	put_characters_32 (cc: SPECIAL [CHARACTER_32]; n: INTEGER)
		do
			put_mem (address, offset, cc.base_address, n*Character_32_bytes)
		end
	
	put_integers_8 (ii: SPECIAL [INTEGER_8]; n: INTEGER)
		do
			put_mem (address, offset, ii.base_address, n*Integer_8_bytes)
		end
	
	put_integers_16 (ii: SPECIAL [INTEGER_16]; n: INTEGER)
		do
			put_mem (address, offset, ii.base_address, n*Integer_16_bytes)
		end
	
	put_integers (ii: SPECIAL [INTEGER_32]; n: INTEGER)
		do
			put_mem (address, offset, ii.base_address, n*Integer_32_bytes)
		end
	
	put_integers_64 (ii: SPECIAL [INTEGER_64]; n: INTEGER)
		do
			put_mem (address, offset, ii.base_address, n*Integer_64_bytes)
		end
	
	put_naturals_8 (nn: SPECIAL [NATURAL_8]; n: INTEGER)
		do
			put_mem (address, offset, nn.base_address, n*Natural_8_bytes)
		end
	
	put_naturals_16 (nn: SPECIAL [NATURAL_16]; n: INTEGER)
		do
			put_mem (address, offset, nn.base_address, n*Natural_16_bytes)
		end
	
	put_naturals (nn: SPECIAL [NATURAL_32]; n: INTEGER)
		do
			put_mem (address, offset, nn.base_address, n*Natural_32_bytes)
		end
	
	put_naturals_64 (nn: SPECIAL [NATURAL_64]; n: INTEGER)
		do
			put_mem (address, offset, nn.base_address, n*Natural_64_bytes)
		end
	
	put_reals (rr: SPECIAL [REAL_32]; n: INTEGER)
		do
			put_mem (address, offset, rr.base_address, n*Real_32_bytes)
		end
	
	put_doubles (dd: SPECIAL [REAL_64]; n: INTEGER)
		do
			put_mem (address, offset, dd.base_address, n*Real_64_bytes)
		end
	
	put_pointers (pp: SPECIAL [POINTER]; n: INTEGER)
		do
			put_mem (address, offset, pp.base_address, n*Pointer_bytes)
		end
	
	oldput_booleans (bb: SPECIAL [BOOLEAN]; n: INTEGER)
		local
			a: ANY
		do
			a := bb
			a := object
			if attached {SPECIAL [BOOLEAN]} a as ss then
				ss.copy_data (bb, 0, 0, n)
			end
		end
	
	oldput_characters (cc: SPECIAL [CHARACTER_8]; n: INTEGER)
		local
			a: ANY
		do
			a := cc
			a := object
			if attached {SPECIAL [CHARACTER_8]} a as ss then
				ss.copy_data (cc, 0, 0, n)
			end
		end
	
	oldput_characters_32 (cc: SPECIAL [CHARACTER_32]; n: INTEGER)
		local
			a: ANY
		do
			a := cc
			a := object
			if attached {SPECIAL [CHARACTER_32]} a as ss then
				ss.copy_data (cc, 0, 0, n)
			end
		end
	
	oldput_integers_8 (ii: SPECIAL [INTEGER_8]; n: INTEGER)
		local
			a: ANY
		do
			a := ii
			a := object
			if attached {SPECIAL [INTEGER_8]} a as ss then
				ss.copy_data (ii, 0, 0, n)
			end
		end
	
	oldput_integers_16 (ii: SPECIAL [INTEGER_16]; n: INTEGER)
		local
			a: ANY
		do
			a := ii
			a := object
			if attached {SPECIAL [INTEGER_16]} a as ss then
				ss.copy_data (ii, 0, 0, n)
			end
		end
	
	oldput_integers (ii: SPECIAL [INTEGER_32]; n: INTEGER)
		local
			a: ANY
		do
			a := ii
			a := object
			if attached {SPECIAL [INTEGER_32]} a as ss then
				ss.copy_data (ii, 0, 0, n)
			end
		end
	
	oldput_integers_64 (ii: SPECIAL [INTEGER_64]; n: INTEGER)
		local
			a: ANY
		do
			a := ii
			a := object
			if attached {SPECIAL [INTEGER_64]} a as ss then
				ss.copy_data (ii, 0, 0, n)
			end
		end
	
	oldput_naturals_8 (nn: SPECIAL [NATURAL_8]; n: INTEGER)
		local
			a: ANY
		do
			a := nn
			a := object
			if attached {SPECIAL [NATURAL_8]} a as ss then
				ss.copy_data (nn, 0, 0, n)
			end
		end
	
	oldput_naturals_16 (nn: SPECIAL [NATURAL_16]; n: INTEGER)
		local
			a: ANY
		do
			a := nn
			a := object
			if attached {SPECIAL [NATURAL_16]} a as ss then
				ss.copy_data (nn, 0, 0, n)
			end
		end
	
	oldput_naturals (nn: SPECIAL [NATURAL_32]; n: INTEGER)
		local
			a: ANY
		do
			a := nn
			a := object
			if attached {SPECIAL [NATURAL_32]} a as ss then
				ss.copy_data (nn, 0, 0, n)
			end
		end
	
	oldput_naturals_64 (nn: SPECIAL [NATURAL_64]; n: INTEGER)
		local
			a: ANY
		do
			a := nn
			a := object
			if attached {SPECIAL [NATURAL_64]} a as ss then
				ss.copy_data (nn, 0, 0, n)
			end
		end
	
	oldput_reals (rr: SPECIAL [REAL_32]; n: INTEGER)
		local
			a: ANY
		do
			a := rr
			a := object
			if attached {SPECIAL [REAL_32]} a as ss then
				ss.copy_data (rr, 0, 0, n)
			end
		end
	
	oldput_doubles (dd: SPECIAL [REAL_64]; n: INTEGER)
		local
			a: ANY
		do
			a := dd
			a := object
			if attached {SPECIAL [REAL_64]} a as ss then
				ss.copy_data (dd, 0, 0, n)
			end
		end
	
	oldput_pointers (pp: SPECIAL [POINTER]; n: INTEGER)
		local
			a: ANY
		do
			a := pp
			a := object
			if attached {SPECIAL [POINTER]} a as ss then
				ss.copy_data (pp, 0, 0, n)
			end
		end
	
feature {NONE} -- Implementation 

	dummy_string: STRING = ""

	dummy_unicode: STRING_32 = ""

	first: BOOLEAN
	
	actionables: ARRAYED_LIST [PC_ACTIONABLE]

	put_mem(addr: POINTER; off: INTEGER; p: POINTER; bytes: INTEGER)
		external "C inline use <string.h>"
		alias "memcpy(((char*)$addr)+$off, $p, $bytes)"
		end

invariant

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
