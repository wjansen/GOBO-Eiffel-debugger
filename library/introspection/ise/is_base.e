note

	description: "Type and object inspection."

expanded class IS_BASE

inherit

	ANY

inherit {NONE}
	
	INTERNAL
		rename
			boolean_type as Boolean_ident,
			character_type as Character_ident,
			character_8_type as Char8_ident,
			character_32_type as Char32_ident,
			integer_type as Integer_ident,
			integer_8_type as Int8_ident,
			integer_16_type as Int16_ident,
			integer_32_type as Int32_ident,
			integer_64_type as Int64_ident,
			natural_8_type as Nat8_ident,
			natural_16_type as Nat16_ident,
			natural_32_type as Nat32_ident,
			natural_64_type as Nat64_ident,
			real_type as Real_ident,
			real_32_type as Real32_ident,
			double_type as Double_ident,
			real_64_type as Real64_ident,
			pointer_type as Pointer_ident,
			none_type as None_ident,
			max_predefined_type as max_basic_ident,
			is_special as int_is_special,
			is_tuple as int_is_tuple,
			generic_count as int_generic_count,
			class_name as int_class_name,
			field as int_field,
			field_type as int_field_type,
			field_name as int_field_name,
			field_count as int_field_count,
			dynamic_type as int_dynamic_type,
			type_name as int_type_name
		end
	
feature {ANY} -- Constants 

	String8_ident: INTEGER
		once
			Result := runtime_system.dynamic_type_from_string ("STRING_8")
		end
	
	String32_ident: INTEGER
		once
			Result := runtime_system.dynamic_type_from_string ("STRING_32")
		end
	
	Foreign_flag: INTEGER = 0x08

	Scoop_flag: INTEGER = 0x10

	No_gc_flag: INTEGER = 0x20

	Debugger_flag: INTEGER = 0x40

	Actionable_flag: INTEGER = 0x80
	
	Subobject_flag: INTEGER = 1

	Reference_flag: INTEGER = 2

	Proxy_flag: INTEGER = 3

	Flexible_flag: INTEGER = 4

	Memory_category_flag: INTEGER = 7

	Basic_expanded_flag: INTEGER = 0x9

	Bits_flag: INTEGER = 0x11

	Tuple_flag: INTEGER = 0x10

	Agent_flag: INTEGER = 0x20

	Anonymous_flag: INTEGER = 0x30
	
	Attached_flag: INTEGER = 0x40
	
	Type_category_flag: INTEGER = 0x7f

	Copy_semantics_flag: INTEGER = 0x200

	Missing_id_flag: INTEGER = 0x800

	Agent_expression_flag: INTEGER = 0x1000

	Meta_type_flag: INTEGER = 0x2000

	Invariant_flag: INTEGER = 0x08

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

	runtime_system: IS_RUNTIME_SYSTEM
		note
			return: "The actual IS_SYSTEM."
		once
			create Result
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
			"((EIF_INTEGER_64)time(0))*1000"
		end
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
