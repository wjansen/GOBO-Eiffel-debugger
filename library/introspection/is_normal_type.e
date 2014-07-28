note

	description: "Internal description of types in an Eiffel system."

class IS_NORMAL_TYPE

inherit

	IS_TYPE
		redefine
			is_actionable
		end

create 

	make

create {IS_SYSTEM, IS_TYPE}

	make_in_system

feature {} -- Initialization 

	make (id: INTEGER; bc: like base_class; fl: INTEGER;
			g: like generics; e: like effectors;
			a: like fields; c: like constants;  r: like routines)
		note
			action: "Construct the descriptor."
		require
			not_negative: id >= 0
		do
			ident := id
			base_class := bc
			flags := fl
			generics := g
			effectors := e
			fields := a
			constants := c
			routines := r
			instance_bytes := pointer_bytes.to_natural_32
			default_instance := default_pointer
			fast_name := out
		ensure
			ident_set: ident = id
			base_set: base_class = bc
			flags_set: flags & fl = fl
		end

	make_in_system (tid, fl: INTEGER; bc: like base_class; f: IS_FACTORY)
		require
			valid_index: 0 <= tid 
			when_made: ident > 0 implies ident = tid
		do
			ident := tid
			flags := fl
			f.add_type (Current)
			base_class := bc
			scan_in_system (f)
		ensure
			ident_set: ident = tid
			flags_set: flags & fl = fl
			base_class_set: base_class.is_equal (bc)
		end
	
feature {IS_FACTORY} -- Initialization 

	scan_in_system (f: IS_FACTORY)
		do
			if not is_basic then
				f.set_generics_of_type (Current)
				if f.to_fill and then attached {like generics} f.last_types as gg then
					generics := gg
				end
				if is_alive then
					f.set_fields_of_type (Current)
					if f.to_fill and then attached {like fields} f.last_fields as aa then
						fields := aa
					end
				end
			end
		end

feature -- Access 

	base_class: IS_CLASS_TEXT
			-- Type descriptor of base type.

	class_name: READABLE_STRING_8
		do
			Result := base_class.fast_name
		end

feature -- Status 

	is_normal: BOOLEAN = True

	is_special: BOOLEAN = False

	is_tuple: BOOLEAN = False

	is_agent: BOOLEAN = False

	is_actionable: BOOLEAN
		do
			Result := base_class.is_actionable
		end
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
