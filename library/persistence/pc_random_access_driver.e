note
	
	description:
		"[ 
		 Class scanning the persistence closure of one object.
		 The items of the closure must be freely accessible. 
		 ]"
	 
class PC_RANDOM_ACCESS_DRIVER [TI_, SI_]
	-- TI_: type of idents generated by the `target' 
	-- SI_: type of idents generated by the `source' 

inherit

	PC_DRIVER [TI_, SI_]
		redefine
			source,
			reset
		end

create

	make
	
feature {} -- Initialization
	
	make (t: like target; s: like source; ord, opts: INTEGER;
			oo: like known_objects)
		note
			action: ""
			t: "traversal target"
			s: "traversal source"
			ord: 
				"[
				 traversal ordering:
				 one of `Fifo_flag', `Lifo_flag', `Deep_flag', `Forward_flag'
				 ]"
			opts: "ORing of non-traversal options"
			oo: "auxiliary storage"
		require
			valid_flags: valid_flags (opts)
			when_target_expands_strings: t.must_expand_strings implies s.can_expand_strings
			when_source_expands_strings: s.must_expand_strings implies t.can_expand_strings
		local
			n: INTEGER
		do
			common_make (t, s, ord | opts, oo)
			if deep then
				-- Create only a dummy dispenser:
				n := 1
			else
				n := 199
			end
			if ord & Lifo_flag = Lifo_flag then
				create {ARRAYED_STACK [SI_]} todo_objects.make (n)
			else
				create {ARRAYED_QUEUE [SI_]} todo_objects.make (n)
			end
		ensure
			taget_set: target = t
			source_set: source = s
		end

	reset
		do
			Precursor
			todo_objects.wipe_out
		end
	
feature -- Access

	source: PC_RANDOM_ACCESS_SOURCE [SI_]

	valid_flags (f: INTEGER): BOOLEAN
		do
			Result := f & Forward_flag < Forward_flag
		end

feature -- Basic operation
	
	traverse (id: like source_root_ident) 
		note
			action: "Deep traversal of object `id'."
		local
			n: NATURAL
		do
			source_root_ident := id
			common_traverse 
		end

feature {} -- Scanning structures 

	process_closure
		local
			si, si0: detachable SI_
		do
			from
				check not todo_objects.is_empty end
				si := source_root_ident
				source.set_ident (si)
				process_announcement (si)
			until todo_objects.is_empty loop
				si := todo_objects.item
				todo_objects.remove
				source.set_ident (si)
				process_data (si)
			end
		end

	add_announced (si: SI_)
		do
			todo_objects.extend (si)
		end

feature {} -- Implementation 

	todo_objects: detachable DISPENSER [SI_]
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
