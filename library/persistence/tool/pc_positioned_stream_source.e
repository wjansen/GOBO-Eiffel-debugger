note

	description:
		"[ 
		 Scanning the persistence closure from a file. 
		 Objects are located at known positions (e.g. got by previous scanning 
		 of the file). 
		 ]"

class PC_POSITIONED_STREAM_SOURCE

inherit

	PC_BASIC_SOURCE
		rename
			make as make_stream_source,
			medium as file,
			system as origin
		undefine
			default_create,
			make_stream_source
		redefine
			origin,
			file,
			pre_object,
			pre_special,
			read_field_ident,
			read_once
		select
			read_type,
			read_once
		end

	PC_STREAM_SOURCE
		rename
			make as make_stream_source,
			medium as file,
			system as origin,
			read_type as orig_read_type,
			read_once as orig_read_once
		undefine
			reset,
			read_header
		redefine
			origin,
			file,
			pre_object,
			pre_special,
			read_field_ident,
			new_type,
			new_class,
			type_at,
			class_at
		end

create

	make

feature {NONE} -- Initialization 

	make (o: PC_TOOL_SOURCE; with_onces: BOOLEAN)
		do	
			class_positions := o.class_positions
			type_positions := o.type_positions
			data_positions := o.data_positions
			announce_positions := o.announce_positions
			types := o.object_types
			capacities := o.capacities
			onces := o.onces
			make_stream_source (Once_observation_flag)
			origin := o
			create all_classes.make (o.class_count, Void)
			create all_types.make (o.type_count, Void)
			file := o.file
			is_once_observing := with_onces
			set_top (o.top_ident)
		end

feature -- Access 

	file: FILE

	types: PC_LINEAR_TABLE [detachable IS_TYPE]

	capacities: PC_LINEAR_TABLE [NATURAL]

	onces: PC_LINEAR_TABLE [detachable IS_ONCE]

	data_positions: PC_LINEAR_TABLE [INTEGER]

	announce_positions: PC_LINEAR_TABLE [INTEGER]

	class_positions: PC_LINEAR_TABLE [INTEGER]

	type_positions: PC_LINEAR_TABLE [INTEGER]

	class_at (i: INTEGER): detachable IS_CLASS_TEXT
		do
			Result := origin.class_at (i)
		end
	
	type_at (i: INTEGER): detachable IS_TYPE
		do
			Result := origin.type_at (i)
		end
	
feature -- Status setting 

	set_top (id: NATURAL)
		do
			top_ident := id
			position := data_positions [top_ident]
			file.go (position)
			in_object := id
		end

feature {PC_DRIVER} -- Reading structure definitions

	read_field_ident
		local
			id: like last_ident
		do
			Precursor
			id := last_ident
			if announce_positions.has (id)
				and then announce_positions [id] = position
			 then
				read_int
				orig_read_type (last_int)
				if last_type.is_special then
					read_uint
					check last_uint = capacities [id] end
				end
				if is_once_observing then
					orig_read_once (id)
				end
			end
		end
	
	read_once (id: NATURAL)
		do
			if onces.has (id) then
				last_once := onces [id]
			end
		end
	
feature {PC_DRIVER} -- Push and pop data 

	pre_object (t: IS_TYPE; id: NATURAL)
		do
			if id /= void_ident then
				position := data_positions [id]
				file.go (position)
			end
			Precursor (t, id)
			in_object := id
		end

	pre_special (s: IS_SPECIAL_TYPE; cap: NATURAL; id: NATURAL)
		do
			position := data_positions [id]
			file.go (position)
			Precursor (s, cap, id)
			in_object := id
		end

feature -- IS_FACTROY

	new_class (id, fl: INTEGER)
		do
			if position = class_positions [id.to_natural_32] then	
				Precursor (id, fl)
			else
				last_class := origin.all_classes [id]
				all_classes.force (last_class, id)
			end
		end	
	
	new_type (id: INTEGER; attac: BOOLEAN)
		do
			if position = type_positions [id.to_natural_32] then	
				Precursor (id, attac)
			else
				last_type := origin.all_types [id]
				all_types.force (last_type, id)
			end
		end
	
feature {} -- Implementation
	
	origin: IS_SYSTEM

	in_object: like last_ident

	is_once_observing: BOOLEAN
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
