note

	description: "Elementary data read from store file."

class PC_TOOL_VALUE

inherit

	IS_BASE
		redefine
			default_create,
			copy, is_equal
		end

	EXCEPTIONS
		redefine
			default_create,
			copy, is_equal
		end

	DISPOSABLE
		redefine
			default_create, 
			dispose,
			copy, is_equal
		end

create

	default_create
	
feature {} -- Initialization

	default_create
		do
			ptr := c_new
		end

feature -- Access

	type: INTEGER

	head_name: STRING
	
	is_boolean: BOOLEAN
		do
			Result := type = Boolean_ident
		end
	
	is_reference: BOOLEAN
		do
			Result := type > Max_basic_ident
		end
	
feature -- Status

	ident_value: NATURAL
		require
			is_ident: is_reference
		do
			Result := c_ident (ptr)
		end

	boolean_value: BOOLEAN
		require
			is_boolen: type = Boolean_ident
		do
			Result := c_boolean (ptr)
		end

	integer_value: INTEGER_64
		require
			is_integer: type = Int64_ident
		do
			Result := c_integer (ptr)
		end

	natural_value: NATURAL_64
		require
			is_natural: type = Nat64_ident
		do
			Result := c_natural (ptr)
		end

	real_value: REAL_64
		require
			is_real: type = Real_ident
		do
			Result := c_real (ptr)
		end

feature -- Status setting

	set_name (nm: STRING)
		do
			head_name := nm
		ensure
			head_name_set: head_name = nm
		end
	
	copy_value (other: PC_TOOL_VALUE)
		do
			inspect other.type
			when Boolean_ident then
				set_boolean (other.boolean_value)
			when Int64_ident then
				set_integer (other.integer_value)
			when Nat64_ident then
				set_natural (other.natural_value)
			when Real64_ident then
				set_real (other.real_value)
			else
				set_ident (other.ident_value, other.type)
			end
		end
	
	set_ident (id: NATURAL; t: INTEGER)
		require
			valid_type: t /= 0 implies t > Max_basic_ident
		do
			if t /= 0 then 
				type := t
			else
				type := Max_basic_ident + 1
			end
			c_set_ident (id, ptr)
		ensure
			type_set: type = t.ident
			ident_set: ident = id
		end
	
	set_boolean (b: BOOLEAN)
		do
			type := BOOLEAN_ident
			c_set_boolean (b, ptr)
		ensure
			type_set: type = Boolean_ident
			ident_set: boolean_value = b
		end
	
	set_integer (i: INTEGER_64)
		do
			type := Int64_ident
			c_set_integer (i, ptr)
		ensure
			type_set: type = Int64_ident
			ident_set: integer_value = i
		end
	
	set_natural (n: NATURAL_64)
		do
			type := Nat64_ident
			c_set_natural (n, ptr)
		ensure
			type_set: type = Nat64_ident
			ident_set: natural_value = n
		end
	
	set_real (r: REAL_64)
		do
			type := Real64_ident
			c_set_real (r, ptr)
		ensure
			type_set: type = Real64_ident
			ident_set: real_value = r
		end

feature -- Basic operation

	evaluate (id: NATURAL; driver: PC_SELECT_DRIVER)
		require
			valid_id: id > 0
		local
			cid: NATURAL
		do
			if is_reference then
				cid := ident_value
				if cid = 0 then
					cid := id
				end
				set_ident (cid, driver.source.types [cid].ident)
			end
		end

feature -- Duplication

	copy (other: like Current)
		do
			standard_copy (other)
			ptr := c_new
			copy_value (other)
		end
			
	is_equal (other: like Current): BOOLEAN
		do
			Result := Current = other
			if not Result then
				Result := type = other.type
				if Result then
					inspect other.type
					when Boolean_ident then
						Result := boolean_value = other.boolean_value
					when Int64_ident then
						Result := integer_value = other.integer_value
					when Nat64_ident then
						Result := natural_value = other.natural_value
					when Real64_ident then
						Result := real_value = other.real_value
					else
						Result := ident_value = other.ident_value
					end
				elseif type > Max_basic_ident and other.type > Max_basic_ident then
					Result := ident_value = other.ident_value
				end
			end
		end
	
feature -- Output

	value_string: STRING
		do
			inspect type
			when Boolean_ident then
				Result := boolean_value.out
			when Int8_ident, Int16_ident, Int32_ident, Int64_ident then
				Result := integer_value.out
			when Nat8_ident, Nat16_ident, Nat32_ident, Nat64_ident then
				Result := natural_value.out
			when Real32_ident, Real64_ident then
				Result := real_value.out
			else
				if is_reference then
					if ident_value = 0 then
						Result := Void_name
					else
						Result := ident_value.out
						Result.precede ('_')
					end
				elseif type = 0 then
					Result := Void_name
				else
					Result := ""
				end
			end
		end
	
feature {} -- DISPOSABLE

	dispose
		do
			c_free (ptr)
			ptr := default_pointer
		end

feature {} -- Implementation

	Void_name: STRING = "Void"
	False_name: STRING = "False"
	True_name: STRING = "True"
	
feature {} -- External implementation

	ptr: POINTER

	c_new: POINTER
		external
			"C inline"
		alias
			"calloc(1,sizeof(union {EIF_INTEGER_64 i; EIF_REAL_64 r;}))"
		end
	
	c_free (p: POINTER)
		external
			"C inline"
		alias
			"free($p)"
		end
	
	c_ident(p: POINTER): NATURAL
		external
			"C inline"
		alias
			"*(EIF_NATURAL_32*)$p"
		end
	
	c_boolean (p: POINTER): BOOLEAN
		external
			"C inline"
		alias
			"*(EIF_BOOLEAN*)$p"
		end
	
	c_integer(p: POINTER): INTEGER_64
		external
			"C inline"
		alias
			"*(EIF_INTEGER_64*)$p"
		end
	
	c_natural(p: POINTER): NATURAL_64
		external
			"C inline"
		alias
			"*(EIF_NATURAL_64*)$p"
		end
	
	c_real(p: POINTER): REAL_64
		external
			"C inline"
		alias
			"*(EIF_REAL_64*)$p"
		end

	c_set_ident (id: NATURAL; p: POINTER)
		external
			"C inline"
		alias
			"*(EIF_NATURAL_32*)$p = $id"
		end
	
	c_set_boolean (b: BOOLEAN; p: POINTER)
		external
			"C inline"
		alias
			"*(EIF_BOOLEAN*)$p = $b"
		end
	
	c_set_integer (i: INTEGER_64; p: POINTER)
		external
			"C inline"
		alias
			"*(EIF_INTEGER_64*)$p = $i"
		end
	
	c_set_natural (n: NATURAL_64; p: POINTER)
		external
			"C inline"
		alias
			"*(EIF_NATURAL_64*)$p = $n"
		end
	
	c_set_real (r: REAL_64; p: POINTER)
		external
			"C inline"
		alias
			"*(EIF_REAL_64*)$p = $r"
		end
	
invariant
	
end
