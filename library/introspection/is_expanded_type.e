note

	description: "Internal description of expanded types in an Eiffel system."

class IS_EXPANDED_TYPE

inherit

	IS_NORMAL_TYPE
		redefine
			make,
			make_in_system,
			is_subobject
		end
	
create {IS_SYSTEM, IS_TYPE}

	make,
	make_in_system

feature {} -- Initialization 

	make (id: INTEGER; bc: like base_class; fl: INTEGER;
			g: like generics; e: like effectors;
			a: like fields; c: like constants; r: like routines)
		do
			Precursor (id, bc, fl | Subobject_flag, g, e, a, c, r)
			boxed_bytes := instance_bytes + pointer_bytes.to_natural_32
			boxed_offset := pointer_bytes
			unboxed_location := default_pointer
		end

	make_in_system (id, fl: INTEGER; bc: like base_class; f: IS_FACTORY)
		do
			Precursor (id, fl | Subobject_flag, bc, f)
		end
	
feature -- Status 
	
	is_subobject: BOOLEAN = True
	
feature -- Instance sizes and offsets

	boxed_bytes: NATURAL
			-- Memory size of boxed instances. 

	boxed_offset: INTEGER
			-- Offset of unboxed item within boxed instance. 

feature -- Status setting 

	set_boxed_bytes (x: NATURAL)
		require
			x_not_negative: x >= 0
		do
			boxed_bytes := x
		ensure
			boxed_bytes_set: boxed_bytes = x
		end

	set_boxed_offset (o: INTEGER)
		require
			o_not_negative: o >= 0
		do
			boxed_offset := o
		ensure
			boxed_offset_set: boxed_offset = o
		end

feature {IS_RUNTIME_SYSTEM} -- Implementation

	unboxed_location: POINTER

invariant
	
note
	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
