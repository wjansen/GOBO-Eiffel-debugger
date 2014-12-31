note

	description:
		"[ 
		 Internal description of attributes of a type 
		 or of closed operands of an agent. 
		 The description is immutable up to `offset' which may be set later. 
		 ]"

class IS_FIELD

inherit

	IS_ENTITY
		redefine
			type
		end
	
create

	make,
	make_in_system

feature {NONE} -- Initialization 

	make (nm: READABLE_STRING_8; t: like type; ts: like type_set; f: like text)
		note
			action: "Initialize `Current'."
		do
			make_entity (nm, f)
			type := t
			type_set := ts
			is_attached := t.is_attached
				-- `offset' is not yet valid: 
			offset := -1 
		ensure
			name_set: has_name (nm)
			type_set: type = t
			type_set_set: type_set = ts
			text_set: text = f
		end

	make_in_system (nm: READABLE_STRING_8; t: like type; home: like type;
			idx: INTEGER; f: IS_FACTORY)
		do
			make_entity (nm, Void)
			type := t
			is_attached := nm [1].is_upper
			-- `offset' is not yet valid:
			offset := -1
			scan_in_system (home.ident, idx, f)
		ensure
			name_set: fast_name.is_equal (nm)
			type_set: type = t
		end
	
feature {IS_FACTORY} -- Initialization 

	scan_in_system (tid, idx: INTEGER; f: IS_FACTORY)
		do
			if f.to_fill then
				f.set_field_typeset (tid, idx, is_attached)
				if attached {like type_set} f.last_typeset as ts then
					type_set := ts
				end
			end
		end

feature -- Access 

	is_attached: BOOLEAN 

	type: attached IS_TYPE
	
feature {IS_BASE} -- Status setting 

	set_name (nm: like fast_name)
		do
			fast_name := nm
		ensure
			fast_name_set: fast_name = nm
		end
	
	set_offset (off: INTEGER)
		do
			offset := off
		ensure
			offset_set: offset = off
		end
	
	set_type_set (ts: like type_set)
		do
			type_set := ts
		ensure
			typeset_set: type_set = ts
		end

feature {IS_BASE} -- Implemention

	offset: INTEGER
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
