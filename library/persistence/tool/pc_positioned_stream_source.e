note

	description:
		"[ 
		 Scanning the persistence closure from a file. 
		 Objects are located at known data positions (e.g. got by previous scanning 
		 of the file). 
		 ]"

class PC_POSITIONED_STREAM_SOURCE

inherit

	PC_STREAM_SOURCE
		rename
			make as make_basic
		redefine
			file,
			set_ident,
			read_field_ident,
			read_description,
			pre_object,
			post_object,
			pre_special,
			post_special,
			new_type,
			new_class,
			class_at,
			type_at,
			integer_type
		end

create

	make

feature {NONE} -- Initialization 

	make (o: PC_TOOL_SOURCE)
		require
			has_file: o.file /= Void
			has_positions: not o.data_positions.is_empty
		do
			origin := o
			make_basic (o.flags)
			can_expand_strings := o.can_expand_strings
			must_expand_strings := o.must_expand_strings
			create position_stack.make (100)
			set_file (o.file)
		end

feature -- Access 

	file: FILE
	
  class_at (i: INTEGER): detachable IS_CLASS_TEXT
		do
			Result := origin.class_at (i)
		end
	
	type_at (i: INTEGER): detachable IS_TYPE
		do
			Result := origin.type_at (i)
		end
	
feature {PC_DRIVER} -- Reading structure definitions

	set_ident (id: NATURAL)
		do
			last_ident := id
			position := origin.data_positions [id]
			file.go (position)
		end

	read_field_ident
		local
			p, ap: INTEGER
		do
			Precursor
			p := position
			ap := origin.announce_positions [last_ident]
			if p = ap then
				read_description
			end
		end
	
	read_description
		local
			id: NATURAL
			p, ap: INTEGER
		do
			id := last_ident
			p := position
			ap := origin.announce_positions[id]
			if ap = p then
				Precursor
			else
				last_dynamic_type := origin.object_types[id]
				last_count := origin.counts[id]
				last_capacity := origin.capacities[id]
			end
		end
	
	pre_object (t: IS_TYPE; id: NATURAL)
		local
			p: INTEGER
		do
			if not t.is_subobject then
				p := position
				position := origin.data_positions [id]
				if p = position then
					p := 0
				else
					file.go (position)
				end
				position_stack.force (p)
			end
			Precursor (t, id)
		end
	
	post_object (t: IS_TYPE; id: NATURAL)
		local
			p: INTEGER
		do
			Precursor (t, id)
			if not t.is_subobject then
				p := position_stack.item
				position_stack.remove
				if p /= 0 then --and then not t.is_agent then
					position := p
					file.go (p)
				end
			end
		end

	pre_special (st: IS_SPECIAL_TYPE; n: NATURAL; id: NATURAL)
		local
			p: INTEGER
		do
			p := position
			position := origin.data_positions [id]
			if p = position then
				p := 0
			else
				file.go (position)
			end
			position_stack.force (p)
			Precursor (st, n, id)
		end

	post_special (st: IS_SPECIAL_TYPE; id: NATURAL)
		local
			p: INTEGER
		do
			Precursor (st, id)
			p := position_stack.item
			position_stack.remove
			if p /= 0 then
				position := p
				file.go (p)
			end
		end
	
feature {NONE} -- Implementation

	origin: PC_TOOL_SOURCE
	
	position_stack: DS_ARRAYED_STACK [INTEGER]
	
	is_once_observing: BOOLEAN

	new_class (cid, fl: INTEGER)
		local
			p, cp: INTEGER
		do
			p := position
			cp := origin.class_positions [cid]
			if position = cp then
				Precursor (cid, fl)
				all_classes.force (Void, cid)
			end
			last_class := origin.all_classes [cid]
		end
			
	new_type (tid: INTEGER; attac: BOOLEAN)
		local
			p, tp: INTEGER
		do
			p := position
			tp := origin.type_positions [tid]
			if p = tp then
				Precursor (tid, attac)
				all_types.force(Void, tid)
			end
			last_type := origin.system.type_at (tid)
		end

	integer_type: attached like type_at
		do
			Result := origin.integer_type
		end
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
