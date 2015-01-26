note

	description:
		"[ 
		 Scanning the persistence closure from a file 
		 monitoring the object and type positions. 
		 ]"

class PC_TOOL_SOURCE

inherit

	PC_STREAM_SOURCE
		rename
			medium as file
		redefine
			file,
			default_create,
			reset,
			read_next_ident,
			read_description,
			pre_object,
			post_object,
			pre_special,
			post_special,
			set_field,
			set_index,
			new_type,
			new_class,
			class_at
		end

create

	make

feature {NONE} -- Initialization 

	default_create
		do
			Precursor
			create class_positions.make_filled (0, 0, 100)
			create type_positions.make_filled (0, 0, 100)
			create data_positions.make (1000)
			create announce_positions.make (1000)
			create object_types.make (1000)
			create counts.make (1000)
			create capacities.make (1000)
			create parents.make (1000)
			create fields.make (1000)
			create depths.make (1000)
		end

feature -- Initialization 

	reset
		do
			Precursor
			data_positions.clear
			announce_positions.clear
			object_types.clear
			class_positions.wipe_out
			type_positions.wipe_out
			counts.clear
			capacities.clear
			parents.clear
			fields.clear
			actual_ident := void_ident
			depth := 0
		end

feature -- Access 

	class_at (i: INTEGER): detachable PC_CLASS_TEXT
		do
			Result := all_classes [i]
		end
	
	file: FILE

	data_positions: PC_LINEAR_TABLE [INTEGER]

	announce_positions: PC_LINEAR_TABLE [INTEGER]

	object_types: PC_LINEAR_TABLE [like last_type]

	counts: PC_LINEAR_TABLE [NATURAL]

	capacities: PC_LINEAR_TABLE [NATURAL]

	class_positions: ARRAY [INTEGER]

	type_positions: ARRAY [INTEGER]

	fields: PC_LINEAR_TABLE [like field]

	parents: PC_LINEAR_TABLE [NATURAL]

feature -- Status setting

	set_compilation_time (ct: like compilation_time)
		do
			compilation_time := ct
		ensure
			compilation_time_set: compilation_time = ct
		end
	
feature {PC_DRIVER} -- Reading structure definitions

	read_next_ident
		local
			pos: INTEGER
		do
			pos := position
			Precursor
			if last_ident /= void_ident
				and then not announce_positions.has (last_ident)
			 then
				announce_positions.put (position, last_ident)
			end
		end

	read_description
		local
			id: NATURAL
			p: INTEGER
		do
			id := last_ident
			p := position
			Precursor
			object_types[id] := last_dynamic_type
			counts[id] := last_count
			capacities[id] := last_capacity
			announce_positions [id] := p
		end
	
feature {PC_DRIVER} -- Reading object definitions 

	pre_object (t: IS_TYPE; id: attached like void_ident)
		do
			if top_ident = 0 then
				top_ident := id
			end
			data_positions[id] := position
			if depths.has (id) and then depths.item (id) > depth then
				depths.put (depth, id)
				parents.put (actual_ident, id)
				fields.put (field, id)
			end
			actual_ident := id
			depth := depth + 1
			Precursor (t, id)
		end

	pre_special (st: IS_SPECIAL_TYPE; cap: NATURAL; id: attached like void_ident)
		do
			data_positions[id] := position
			if depths.has (id) and then depths.item (id) > depth then
				depths.put (depth, id)
				parents.put (actual_ident, id)
				fields.put (field, id)
			end
			actual_ident := id
			depth := depth + 1
			Precursor (st, cap, id)
		end

	post_object (t: IS_TYPE; id: NATURAL)
		do
			Precursor (t, id)
			actual_ident := parents [id]
			depth := depth - 1
		end

	post_special (s: IS_SPECIAL_TYPE; id: NATURAL)
		do
			Precursor (s, id)
			actual_ident := parents [id]
			depth := depth - 1
		end

feature {PC_DRIVER} -- Object location

	set_field (f: attached like field; in: NATURAL)
		do
			index := (-1).to_natural_32
		end
	
	set_index (s: IS_SPECIAL_TYPE; i: NATURAL; in: NATURAL)
		do
			index := i
		end
	
feature -- Factory

	new_class (cid, fl: INTEGER)
		do
			if class_positions.upper < cid or else class_positions [cid] = 0 then
				class_positions.force (position, cid)
			end
			Precursor (cid, fl)
		end
	
	new_type (tid: INTEGER; attac: BOOLEAN)
		do
			if type_positions.upper < tid or else type_positions [tid] = 0 then
				type_positions.force (position, tid)
			end
			Precursor (tid, attac)
		end

feature {NONE} -- Implementation

	actual_ident: like last_ident

	index: NATURAL

	depth: INTEGER

	depths: PC_LINEAR_TABLE [INTEGER]
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
