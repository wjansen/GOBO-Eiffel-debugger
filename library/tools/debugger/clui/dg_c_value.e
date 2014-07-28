note

	description:
		"[ 
		 Variable value for use by C functions: 
		 a copy of the value if its type is an expanded, 
		 a copy of the reference if its type is not expanded. 
		 ]"

class DG_C_VALUE

inherit

	DG_GLOBALS
		rename
			as_any as pointer_to_any,
			as_pointer as any_to_pointer
		undefine
			copy,
			is_equal
		redefine
			default_create,
			out
		end

	MANAGED_POINTER
		rename
			make as make_managed,
			item as c_ptr,
			put_natural_8 as store_natural_8,
			put_natural_16 as store_natural_16,
			put_natural_32 as store_natural_32,
			put_natural_64 as store_natural_64,
			put_integer_8 as store_integer_8,
			put_integer_16 as store_integer_16,
			put_integer_32 as store_integer_32,
			put_integer_64 as store_integer_64,
			put_boolean as store_boolean,
			put_character as store_character,
			put_pointer as store_pointer,
			put_real as store_real,
			put_double as store_double,
			put_real_32 as store_real_32,
			put_real_64 as store_real_64,
			count as size
		redefine
			default_create,
			out
		end

create

	default_create

feature {NONE} -- Initialization 

	default_create
		do
			type := Void
			is_shared := True
		end

feature -- Access 

	type: detachable IS_TYPE
			-- Type of the value.

feature -- Status 

	is_defined: BOOLEAN
		note
			return: "Has the value been set?"
		do
			Result := attached type
		ensure
			definition: Result = attached type
		end

	is_assignable_to (t: IS_TYPE): BOOLEAN
		note
			return: "Can the value be assigned to a variable of type `t'?"
		do
			if attached type as tp then
				Result := t = tp
				if not Result then
					if t.is_subobject then
						inspect t.ident
						when Boolean_ident then
							Result := True
						when Char8_ident, Char32_ident then
							inspect tp.ident
							when Char8_ident, Char32_ident then
								Result := True
							else
							end
						else
						end
						inspect t.ident
						when Real32_ident, Real64_ident then
							inspect tp.ident
							when Int8_ident, Int16_ident, Int32_ident, Int64_ident, Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident, Real32_ident, Real64_ident then
								Result := True
							else
							end
						else
						end
						inspect t.ident
						when Int8_ident, Int16_ident, Int32_ident, Int64_ident, Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
							inspect tp.ident
							when Int8_ident, Int16_ident, Int32_ident, Int64_ident, Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
								Result := True
							else
							end
						else
						end
					else
						Result := -- tp = none_type or else
							tp.conforms_to_type (t)
					end
				end
			else
				Result := not t.is_subobject
			end
		end

	as_any: detachable ANY
		note
			return: "Reference type value."
		require
			is_reference: attached type as tp implies not tp.is_subobject
		do
			if attached type as tp then
				if c_ptr /= default_pointer then
					Result := to_any (c_ptr)
					type := debuggee.type_of_any (Result, tp)
				end
			end
		end

	as_boolean: BOOLEAN
		note
			return: "BOOLEAN value."
		require
			defined: is_defined
			is_boolean: attached type as tp and then tp.is_boolean
		do
			Result := read_boolean (0)
		end

	as_character: CHARACTER_8
		require
			defined: is_defined
			is_character: is_assignable_to (debuggee.character_type)
		do
			if attached type as tp and then tp.ident = Char8_ident then
				Result := read_character (0)
			else
				Result := read_integer_32 (0).to_character_8
				type := debuggee.character_type
			end
		end

	as_character_32: CHARACTER_32
		require
			defined: is_defined
			is_character: is_assignable_to (debuggee.char32_type)
		do
			if attached type as tp and then tp.ident = Char32_ident then
				Result := read_integer_32 (0).to_character_32
			else
				Result := read_character (0).to_character_32
				type := debuggee.char32_type
			end
		end

	as_integer_8: INTEGER_8
		require
			defined: is_defined
			is_integer_8: is_assignable_to (debuggee.int8_type)
		do
			if attached type as tp and then tp.ident = Int8_ident then
				Result := read_integer_8 (0)
			else
				convert_buffer.copy_value (Current)
				convert_buffer.convert_to (debuggee.int8_type)
				Result := convert_buffer.as_integer_8
				type := debuggee.int8_type
			end
		end

	as_integer_16: INTEGER_16
		require
			defined: is_defined
			is_integer_16: is_assignable_to (debuggee.int16_type)
		do
			if attached type as tp and then tp.ident = Int16_ident then
				Result := read_integer_16 (0)
			else
				convert_buffer.copy_value (Current)
				convert_buffer.convert_to (debuggee.int16_type)
				Result := convert_buffer.as_integer_16
				type := debuggee.int16_type
			end
		end

	as_integer_32: INTEGER_32
		require
			defined: is_defined
			is_integer_32: is_assignable_to (debuggee.int32_type)
		do
			if attached type as tp and then tp.ident = Int32_ident then
				Result := read_integer_32 (0)
			else
				convert_buffer.copy_value (Current)
				convert_buffer.convert_to (debuggee.int32_type)
				Result := convert_buffer.as_integer_32
				type := debuggee.int32_type
			end
		end

	as_integer_64: INTEGER_64
		require
			defined: is_defined
			is_integer_64: is_assignable_to (debuggee.int64_type)
		do
			if attached type as tp and then tp.ident = Int64_ident then
				Result := read_integer_64 (0)
			else
				convert_buffer.copy_value (Current)
				convert_buffer.convert_to (debuggee.int64_type)
				Result := convert_buffer.as_integer_64
				type := debuggee.int64_type
			end
		end

	as_natural_8: NATURAL_8
		require
			defined: is_defined
			is_natural_8: is_assignable_to (debuggee.nat8_type)
		do
			if attached type as tp and then tp.ident = Nat8_ident then
				Result := read_natural_8 (0)
			else
				convert_buffer.copy_value (Current)
				convert_buffer.convert_to (debuggee.nat8_type)
				Result := convert_buffer.as_natural_8
				type := debuggee.nat8_type
			end
		end

	as_natural_16: NATURAL_16
		require
			defined: is_defined
			is_natural_16: is_assignable_to (debuggee.nat16_type)
		do
			if attached type as tp and then tp.ident = Nat16_ident then
				Result := read_natural_16 (0)
			else
				convert_buffer.copy_value (Current)
				convert_buffer.convert_to (debuggee.nat16_type)
				Result := convert_buffer.as_natural_16
				type := debuggee.nat16_type
			end
		end

	as_natural_32: NATURAL_32
		require
			defined: is_defined
			is_natural_32: is_assignable_to (debuggee.nat32_type)
		do
			if attached type as tp and then tp.ident = Nat32_ident then
				Result := read_natural_32 (0)
			else
				convert_buffer.copy_value (Current)
				convert_buffer.convert_to (debuggee.nat32_type)
				Result := convert_buffer.as_natural_32
				type := debuggee.nat32_type
			end
		end

	as_natural_64: NATURAL_64
		require
			defined: is_defined
			is_natural_64: is_assignable_to (debuggee.nat64_type)
		do
			if attached type as tp and then tp.ident = Nat64_ident then
				Result := read_natural_64 (0)
			else
				convert_buffer.copy_value (Current)
				convert_buffer.convert_to (debuggee.nat64_type)
				Result := convert_buffer.as_natural_64
				type := debuggee.nat64_type
			end
		end

	as_real: REAL_32
		require
			defined: is_defined
			is_real: is_assignable_to (debuggee.real_type)
		do
			if attached type as tp and then tp.ident = Real32_ident then
				Result := read_real_32 (0)
			else
				convert_buffer.copy_value (Current)
				convert_buffer.convert_to (debuggee.real_type)
				Result := convert_buffer.read_real_32 (0)
				type := debuggee.real_type
			end
		end

	as_double: REAL_64
		require
			defined: is_defined
			is_double: is_assignable_to (debuggee.double_type)
		do
			if attached type as tp and then tp.ident = Real64_ident then
				Result := read_real_64 (0)
			else
				convert_buffer.copy_value (Current)
				convert_buffer.convert_to (debuggee.double_type)
				Result := convert_buffer.as_double
				type := debuggee.double_type
			end
		end

	as_pointer: POINTER
		require
			defined: is_defined
			is_real: is_assignable_to (debuggee.pointer_type)
		do
			Result := read_pointer (0)
		end

feature -- Status setting 

	clear
		do
			type := Void
			free_memory
		ensure
			is_null: c_ptr = default_pointer
		end

	free_memory
		do
			c_ptr := default_pointer
		ensure
			no_address: c_ptr = default_pointer
		end

	share (ptr: POINTER; t: detachable IS_TYPE)
		require
			not_null: ptr /= default_pointer
		local
			s: INTEGER
		do
			is_shared := True
			type := t
			if attached type as tp then
				s := tp.field_bytes
			else
				s := c_bytes
			end
			set_from_pointer (ptr, s)
		ensure
			share: is_shared
			pointer_set: c_ptr = ptr
			type_set: type = t
		end

	fix_value
		note
			action: "Turn shared memory into own not shared memory."
		require
			defined: is_defined
		local
			old_ptr: like c_ptr
		do
			if is_shared and then attached type as tp then
				is_shared := False
				old_ptr := c_ptr
				make_managed (tp.instance_bytes)
				c_ptr.memory_copy (old_ptr, size)
			end
		ensure
			not_shared: not is_shared
		end

	copy_value (other: DG_C_VALUE)
		note
			action:
			"[
			 Copy from `other':
			 copy value if `type' is an expanded type,
			 copy reference if `type' is a reference type.
			 Values of basic expanded type get converted if necessary.
			 ]"
		require
			other_defined: other.is_defined
			is_assignable: attached type as tp and then other.is_assignable_to (tp)
		do
			if attached other.type as otp then
				size := otp.instance_bytes
				if otp.is_subobject then
					if attached type as tp and then otp /= tp then
						convert_buffer.set_type (otp)
						convert_buffer.c_ptr.memory_copy (other.c_ptr, size)
						convert_buffer.convert_to (tp)
						c_ptr.memory_copy (convert_buffer.c_ptr, size)
					elseif size > 0 then
						if c_ptr = default_pointer then
							c_ptr := other.c_ptr
							is_shared := True
						else
							c_ptr.memory_copy (other.c_ptr, size)
							is_shared := False
						end
					end
				else
					if c_ptr = default_pointer then
						c_ptr := other.c_ptr
						is_shared := True
					end
					put_pointer (debuggee.dereferenced (other.c_ptr, otp))
				end
				type := otp
			end
		ensure
			defined: is_defined
			when_was_defined: old is_defined implies c_ptr = old c_ptr
		end

	put_boolean (b: BOOLEAN)
		do
			set_type (debuggee.boolean_type)
			store_boolean (b, 0)
		ensure
			set: as_boolean = b
		end

	put_character (c: CHARACTER)
		do
			set_type (debuggee.character_type)
			store_character (c, 0)
		ensure
			set: as_character = c
		end

	put_character_32 (c: CHARACTER_32)
		do
			set_type (debuggee.char32_type)
			store_integer_32 (c.code, 0)
		ensure
			set: as_character_32 = c
		end

	put_integer_8 (i: INTEGER_8)
		do
			set_type (debuggee.int8_type)
			store_integer_8 (i, 0)
		ensure
			set: as_integer_8 = i
		end

	put_integer_16 (i: INTEGER_16)
		do
			set_type (debuggee.int16_type)
			store_integer_16 (i, 0)
		ensure
			set: as_integer_16 = i
		end

	put_integer_32 (i: INTEGER_32)
		do
			set_type (debuggee.int32_type)
			store_integer_32 (i, 0)
		ensure
			set: as_integer_32 = i
		end

	put_integer_64 (i: INTEGER_64)
		do
			set_type (debuggee.int64_type)
			store_integer_64 (i, 0)
		ensure
			set: as_integer_64 = i
		end

	put_natural_8 (n: NATURAL_8)
		do
			set_type (debuggee.nat8_type)
			store_natural_8 (n, 0)
		ensure
			set: as_natural_8 = n
		end

	put_natural_16 (n: NATURAL_16)
		do
			set_type (debuggee.nat16_type)
			store_natural_16 (n, 0)
		ensure
			set: as_natural_16 = n
		end

	put_natural_32 (n: NATURAL_32)
		do
			set_type (debuggee.nat32_type)
			store_natural_32 (n, 0)
		ensure
			set: as_natural_32 = n
		end

	put_natural_64 (n: NATURAL_64)
		do
			set_type (debuggee.nat64_type)
			store_natural_64 (n, 0)
		ensure
			set: as_natural_64 = n
		end

	put_real (r: REAL_32)
		do
			set_type (debuggee.real_type)
			store_real_32 (r, 0)
		ensure
			set: as_real = r
		end

	put_double (d: REAL_64)
		do
			set_type (debuggee.double_type)
			store_real_64 (d, 0)
		ensure
			set: as_double = d
		end

	put_pointer (p: POINTER)
		do
			type := debuggee.pointer_type
			store_pointer (p, 0)
		ensure
			set: as_pointer = p
		end

	put_any (a: detachable ANY)
		do
			if attached a as a_ then
				put_pointer (any_to_pointer(a_))
				type := debuggee.type_of_any (a_, Void)
			else
				put_pointer (default_pointer)
				type := none_type
			end
		ensure
			set: as_any = a
		end

	convert_to (to: IS_TYPE)
		require
			different_types: type /= to
			is_assignable: is_assignable_to (to)
		local
			i_64: INTEGER_64
			n_64: NATURAL_64
			r: REAL_32
			d: REAL_64
		do
			if  attached type as tp then
				inspect tp.ident
				when Real32_ident then
					d := as_real
					i_64 := d.rounded
				when Real64_ident then
					d := as_double
					i_64 := d.rounded
				when Int8_ident then
					i_64 := as_integer_8
					n_64 := i_64.to_natural_64
					d := i_64.to_double
				when Int16_ident then
					i_64 := as_integer_16
					n_64 := i_64.to_natural_64
					d := i_64.to_double
				when Int32_ident then
					i_64 := as_integer_32
					n_64 := i_64.to_natural_64
					d := i_64.to_double
				when Int64_ident then
					i_64 := as_integer_64
					n_64 := i_64.to_natural_64
					d := i_64.to_double
				when Nat8_ident then
					n_64 := as_natural_8
					i_64 := n_64.to_integer_64
					d := n_64.to_real_64
				when Nat16_ident then
					n_64 := as_natural_16
					i_64 := n_64.to_integer_64
					d := n_64.to_real_64
				when Nat32_ident then
					n_64 := as_natural_32
					i_64 := n_64.to_integer_64
					d := n_64.to_real_64
				when Nat64_ident then
					n_64 := as_natural_64
					i_64 := n_64.to_integer_64
					d := n_64.to_real_64
				else
				end
				inspect to.ident
				when Real32_ident then
					r := d.truncated_to_real
					put_real (r)
				when Real64_ident then
					put_double (d)
				when Int8_ident then
					put_integer_8 (i_64.to_integer_8)
				when Int16_ident then
					put_integer_16 (i_64.to_integer_16)
				when Int32_ident then
					put_integer_32 (i_64.to_integer_32)
				when Int64_ident then
					put_integer_64 (i_64)
				when Nat8_ident then
					put_natural_8 (n_64.to_natural_8)
				when Nat16_ident then
					put_natural_16 (n_64.to_natural_16)
				when Nat32_ident then
					put_natural_32 (n_64.to_natural_32)
				when Nat64_ident then
					put_natural_64 (n_64)
				else
				end
			end
		end

feature -- Duplication & comparison 

	compare_to (other: DG_C_VALUE): BOOLEAN
		note
			return: "Compare contents."
		require
			defined: is_defined
			other_defined: other.is_defined
			assignable: attached other.type as otp and then is_assignable_to (otp)
		local
			a: detachable ANY
		do
			if c_ptr = other.c_ptr then
				Result := True
			elseif  attached type as tp then
				if tp.is_subobject then
					inspect tp.ident
					when Real32_ident then
						Result := as_real = other.as_real
					when Real64_ident then
						Result := as_double = other.as_double
					when Int8_ident then
						Result := as_integer_8 = other.as_integer_8
					when Int16_ident then
						Result := as_integer_16 = other.as_integer_16
					when Int32_ident then
						Result := as_integer_32 = other.as_integer_32
					when Int64_ident then
						Result := as_integer_64 = other.as_integer_64
					when Nat8_ident then
						Result := as_natural_8 = other.as_natural_8
					when Nat16_ident then
						Result := as_natural_16 = other.as_natural_16
					when Nat32_ident then
						Result := as_natural_32 = other.as_natural_32
					when Nat64_ident then
						Result := as_natural_64 = other.as_natural_64
					else
						Result := c_ptr.memory_compare (other.c_ptr, size)
					end
				else
					a := Current	-- make the compiler happy !
					a := to_any (c_ptr)
					Result := a = to_any (other.c_ptr)
				end
			else
				Result := as_pointer = default_pointer and then other.as_pointer = default_pointer
			end
		end

feature -- Output 

	out: STRING
		do
			if  attached type as tp then
				if tp.is_subobject then
					inspect tp.ident
					when Boolean_ident then
						Result := as_boolean.out
					when Char8_ident then
						Result := as_character.out
					when Char32_ident then
						Result := as_character_32.out
					when Int8_ident then
						Result := as_integer_8.out
					when Int16_ident then
						Result := as_integer_16.out
					when Int32_ident then
						Result := as_integer_32.out
					when Int64_ident then
						Result := as_integer_64.out
					when Nat8_ident then
						Result := as_natural_8.out
					when Nat16_ident then
						Result := as_natural_16.out
					when Nat32_ident then
						Result := as_natural_32.out
					when Nat64_ident then
						Result := as_natural_64.out
					when Real32_ident then
						Result := as_real.out
					when Real64_ident then
						Result := as_double.out
					else
						Result := as_pointer.out
					end
				elseif attached type and then c_ptr /= default_pointer then
					Result := as_pointer.out
					Result.extend (' ')
					Result.extend (':')
					Result.extend (' ')
					type.append_name(Result)
				else
					Result := once "0"
				end
			else
				Result := ""
			end
		end

feature {DG_C_VALUE, DG_VALUE_STACK} -- Implementation 

	set_type (t: like type)
		do
			type := t
		ensure
			type_set: type = t
			defined: is_defined
		end

feature {NONE} -- Implementation 

	convert_buffer: DG_C_VALUE
		once
			create Result
			Result.resize (c_bytes)
		end

feature {NONE} -- Externals 

	c_bytes: INTEGER
		external
			"C inline"
		alias
			"GE_z_usize"
		end

invariant

	when_defined: is_defined implies attached type as tp and then size = tp.field_bytes and c_ptr /= default_pointer

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
