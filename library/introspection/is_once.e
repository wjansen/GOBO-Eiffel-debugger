note

	description:
		"[ 
		 Internal description of the status of once routines. 
		 The description is immutable up to the `init_address' and `value_address' 
		 which may be set later. 
		 ]"

class IS_ONCE

inherit

	IS_ROUTINE
		redefine
			make
		end
	
create

	make

feature {NONE} -- Initialization 

	make (nm: READABLE_STRING_8; anm: detachable READABLE_STRING_8;
				ia: like inline_agent; fl: INTEGER; t: like target;
				ac, lc, oc, cc, tc: INTEGER; v: like vars; x: like text)
		do
			Precursor (nm, anm, ia, fl, t, ac, lc, oc, cc, tc, v, x)
			if attached {IS_NORMAL_TYPE} t as nt then
				home := nt.base_class
			end
		end

feature -- Access 

	home: attached IS_CLASS_TEXT
			-- Class containing `Current'. 

	is_initialized: BOOLEAN
		note
			return: "Has `Current' already been computed?"
		do
			Result := init_address /= default_pointer and then c_status (init_address)
		end

	init_address: POINTER
	
	value_address: POINTER
	
feature -- status setting

	set_addresses (init, val: POINTER)
		require
			init_not_null: init /= default_pointer
			when_address: is_function implies val /= default_pointer
		do
			init_address := init
			if is_function then
				value_address := val
			end
		ensure
			init_address_set: init_address = init
			value_address_set: is_function implies value_address = val
		end
	
feature -- Low level implementation 

	initialize_by (x: POINTER)
		note
			action: "Intitialize the object by setting its value given by `x'."
		require
			is_function: is_function
			has_status: init_address /= default_pointer
			not_yet_initialized: not is_initialized
		do
			if not type.is_subobject then
				c_initialize (init_address, value_address, x)
			end
		ensure
			initialized: is_initialized
		end

	refresh
		note
			action: "Reset the object into the virgin state."
		require
			has_status: init_address /= default_pointer
			initialized: is_initialized
		local
			null: POINTER
		do
			c_refresh (init_address, null)
		ensure
			not_longer_initialized: not is_initialized
		end

feature {NONE} -- External implementation 

	c_status (s: POINTER): BOOLEAN
		external
			"C inline"
		alias
			"*(EIF_BOOLEAN*)$s"
		end

	c_initialize (s, v, x: POINTER)
		external
			"C inline"
		alias
			"*(EIF_BOOLEAN*)$s=1;  if ($v) *(void**)$v=$x"
		end

	c_refresh (s, v: POINTER)
		external
			"C inline"
		alias
			"*(EIF_BOOLEAN*)$s=0;  if ($v) *(void**)$v=0"
		end

invariant
	
	when_function: is_function and then init_address /= default_pointer 
		implies value_address /= default_pointer
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
