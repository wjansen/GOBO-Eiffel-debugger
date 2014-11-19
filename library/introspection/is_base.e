note

	description: "Type and object inspection."

expanded class IS_BASE

feature -- Type idents

	Boolean_ident: INTEGER = 1

	Character_ident: INTEGER = 2

	Char8_ident: INTEGER = 2

	Char32_ident: INTEGER = 3

	Integer_ident: INTEGER = 6

	Int8_ident: INTEGER = 4

	Int16_ident: INTEGER = 5

	Int32_ident: INTEGER = 6

	Int64_ident: INTEGER = 7

	Nat8_ident: INTEGER = 8

	Nat16_ident: INTEGER = 9

	Nat32_ident: INTEGER = 10

	Nat64_ident: INTEGER = 11

	Real32_ident: INTEGER = 12

	Real64_ident: INTEGER = 13

	Pointer_ident: INTEGER = 14
	
	Max_basic_ident: INTEGER = 14

	String_ident: INTEGER = 17

	String8_ident: INTEGER = 17

	String32_ident: INTEGER = 18

feature -- System Flags

	Foreign_flag: INTEGER = 0x08

	Scoop_flag: INTEGER = 0x10

	No_gc_flag: INTEGER = 0x20

feature -- Class flags

	Actionable_flag: INTEGER = 0x40
	
	Invariant_flag: INTEGER = 0x80

	Debugger_flag: INTEGER = 0x100

feature -- Class and type flags

	Subobject_flag: INTEGER = 1

	Reference_flag: INTEGER = 2

	Proxy_flag: INTEGER = 3

	Alive_flag: INTEGER = 3

	Flexible_flag: INTEGER = 4

	Memory_category_flag: INTEGER = 7

	Basic_expanded_flag: INTEGER = 0x9

	Bits_flag: INTEGER = 0x11

	Tuple_flag: INTEGER = 0x10

	Agent_flag: INTEGER = 0x20

	Anonymous_flag: INTEGER = 0x30

	Type_category_flag: INTEGER = 0x3f

feature -- Type flags

	Attached_flag: INTEGER = 0x40

	Copy_semantics_flag: INTEGER = 0x200

	Missing_id_flag: INTEGER = 0x800

	Agent_expression_flag: INTEGER = 0x1000

	Meta_type_flag: INTEGER = 0x2000

feature -- Routine flags

	Do_flag: INTEGER = 0

	External_flag: INTEGER = 1

	Once_flag: INTEGER = 2

	Deferred_flag: INTEGER = 3

	Implementation_flag: INTEGER = 3

	Function_flag: INTEGER = 4

	Operator_flag: INTEGER = 0xC

	Bracket_flag: INTEGER = 0x14

	Creation_flag: INTEGER = 0x20

	Default_creation_flag: INTEGER = 0x60

	Precursor_flag: INTEGER = 0x100

	Rescue_flag: INTEGER = 0x200

	No_current_flag: INTEGER = 0x400

	Anonymous_routine_flag: INTEGER = 0x800

	Inlined_flag: INTEGER = 0x1000

	Frozen_flag: INTEGER = 0x2000

	Side_effect_flag: INTEGER = 0x4000

	Routine_flag: INTEGER = 0x8000

	runtime_system: IS_RUNTIME_SYSTEM
		note
			return: "The actual IS_SYSTEM."
		once
			create Result.make_from_tables
		end

	actual_time_as_integer: INTEGER_64
		do
			Result := c_time			
		end
	
feature {NONE} -- POINTER conversion 

	to_any (p: POINTER): ANY
		require
			not_null: p /= default_pointer
		external
			"C inline"
		alias
			"*(EIF_REFERENCE*)$p"
		end

	as_any (p: POINTER): detachable ANY
		external
			"C inline"
		alias
			"(EIF_REFERENCE)$p"
		end

	as_pointer(a: ANY): POINTER
		note
			action:
			"[
			Address of `a' even if it is of a SPECIAL type
			(in this case, `$a' yields the address of the element array).
			]"
		external
			"C inline"
		alias
			"$a ? (void*)$a : 0"
		end

	c_time: INTEGER_64
		external
			"C inline use <time.h>"
		alias
			"((EIF_INTEGER_64)time(0))*1000 "
		end

	c_tables: BOOLEAN
		external
			"C inline"
		alias
			"[
			
			#ifdef GEIP_TABLES 
				(EIF_BOOLEAN)1
			#else 
				(EIF_BOOLEAN)0
			#endif 
			
			 ]"
		end
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
