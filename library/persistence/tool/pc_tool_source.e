note

	description:
		"[ 
		 Scanning the persistence closure from a file 
		 monitoring the object positions. 
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
			read_once,
			pre_object,
			post_object,
			pre_special,
			post_special,
			set_field,
			set_index,
			new_class,
			new_type,
			class_at
		end

create

	make

feature {NONE} -- Initialization 

	default_create
		do
			Precursor
			create data_positions.make (1000)
			create announce_positions.make (1000)
			create type_positions.make (100)
			create class_positions.make (100)
			create object_types.make (1000)
			create capacities.make (1000)
			create onces.make (1000)
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
			type_positions.clear
			class_positions.clear
			object_types.clear
			capacities.clear
			onces.clear
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

	class_positions: PC_LINEAR_TABLE [INTEGER]

	type_positions: PC_LINEAR_TABLE [INTEGER]

	data_positions: PC_LINEAR_TABLE [INTEGER]

	announce_positions: PC_LINEAR_TABLE [INTEGER]

	object_types: PC_LINEAR_TABLE [like last_type]

	capacities: PC_LINEAR_TABLE [NATURAL]

	onces: PC_LINEAR_TABLE [like last_once]

	fields: PC_LINEAR_TABLE [like field]

	parents: PC_LINEAR_TABLE [NATURAL]

feature {PC_DRIVER} -- Reading structure definitions 

	read_context (id: NATURAL)
		do
			if not announce_positions.has (id) then
				announce_positions.add (position, id)
			end
			Precursor (id)
			object_types.add (last_type, id)
			parents.add (actual_ident, id)
			fields.add (field, id)
			if attached {IS_SPECIAL_TYPE} last_type then
				capacities.add (last_capacity, id)
			else
				capacities.add (index, id)
			end
		end

	 read_once (id: NATURAL)
		do
			Precursor (id)
			onces.put (last_once, id)
		end
	
feature {PC_DRIVER} -- Reading object definitions 

	pre_object (t: IS_TYPE; id: attached like void_ident)
		do
			if id /= void_ident then
				data_positions.put (position, id)
			end
			if top_ident = 0 then
				top_ident := id
			end
			if depths.has (id) and then depths.item (id) > depth then
				depths.put (depth, id)
				parents.put (actual_ident, id)
				fields.put (field, id)
				capacities.put (index, id)
			end
			actual_ident := id
			depth := depth + 1
			Precursor (t, id)
		end

	pre_special (st: IS_SPECIAL_TYPE; cap: NATURAL; id: attached like void_ident)
		do
			data_positions.put (position, id)
			if depths.has (id) and then depths.item (id) > depth then
				depths.put (depth, id)
				parents.put (actual_ident, id)
				fields.put (field, id)
				capacities.put (index, cap)
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

	new_class (id, fl: INTEGER)
		local
			n: NATURAL
		do
			n := id.to_natural_32
			if class_positions [n] = 0 then
				class_positions.put (position, n)
			end
			Precursor (id, fl)
		end

	new_type (id: INTEGER; attac: BOOLEAN)
		local
			n: NATURAL
			i: INTEGER
		do
			n := id.to_natural_32
			if type_positions [n] = 0 then
				type_positions.put (position, n)
			end
			Precursor (id, attac)
			from
				i := last_type.field_count
			until i = 0 loop
				i := i - 1
				last_type.field_at (i).set_offset (i)
			end
		end

feature {} -- Implementation

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
