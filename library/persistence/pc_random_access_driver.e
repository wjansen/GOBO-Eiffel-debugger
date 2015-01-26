note
	
	description:
		"[ 
		 Class scanning the persistence closure of one object.
		 The items of the closure must be freely accessible. 
		 ]"
	 
class PC_RANDOM_ACCESS_DRIVER [TI_, SI_ -> attached ANY]
	-- TI_: type of idents generated by the `target' 
	-- SI_: type of idents generated by the `source' 

inherit

	PC_DRIVER [TI_, SI_]
		rename
			traverse as common_traverse
		redefine
			make,
			reset
		end

create

	make

feature {NONE} -- Initialization 

	make (t: like target; s: like source; ord, opts: INTEGER;
		oo: like known_objects)
		local
			n: INTEGER
		do
			Precursor (t, s, ord, opts, oo)
			if deep then
			 	-- Create only a dummy dispenser:
				n := 1
			else
				n := 199
			end
			if ord & Lifo_flag = Lifo_flag then
				create {ARRAYED_STACK [SI_]} todo_idents.make (n)
			else
				create {ARRAYED_QUEUE [SI_]} todo_idents.make (n)
			end
		end

	reset
		do
			Precursor
			todo_idents.wipe_out
		end
	
feature -- Access

	valid_flags (f: INTEGER): BOOLEAN
		do
			Result := f & Forward_flag < Forward_flag
		end

feature -- Status

	valid_target (t: like target): BOOLEAN
		do
			Result := True
		end
			
	valid_source (s: like source): BOOLEAN
		do
			Result := not s.is_serial
		end
			
feature -- Basic operation
	
	traverse (id: like source_root_ident) 
		note
			action: "Deep traversal of object `id'."
		do
			source_root_ident := id
			source.set_ident (id)
			common_traverse 
		end

feature {NONE} -- Implementation 

	todo_idents: DISPENSER [SI_]

	todo_count: INTEGER
		do
			Result := todo_idents.count
		end
	
	add_todo (si: SI_)
		do
			todo_idents.extend (si)
		end

	remove_todo (si: SI_)
		do
			if todo_idents.item = si then
				todo_idents.remove
			else
				-- What now?
			end
		end

	move_to_next_ident
		do
			if todo_idents.is_empty then
				next_ident := source_root_ident
			else
				next_ident := todo_idents.item
			end
			source.set_ident (next_ident)
		end
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
