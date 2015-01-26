note

	description: "Scanning the persistence closure from a file."

class PC_STREAM_SOURCE

inherit

	PC_BASIC_SOURCE
		redefine
			last_class,
			default_create,
			make, 
			reset,
			read_header,
			read_once,
			read_type
		end

	IS_FACTORY 
		rename
			make as make_system
		undefine
			copy,
			is_equal,
			out
		redefine
			last_class,
			default_create
		end

create

	make

feature {NONE} -- Initialization 

	default_create
		do
			Precursor {IS_FACTORY}
			Precursor {PC_BASIC_SOURCE}
		end
	
	make (fl: INTEGER)
		local
			bc: IS_CLASS_TEXT
		do
			create bc.make (0, any_name, 0, Void, Void, Void)
			create {IS_NORMAL_TYPE} any_type.make (0, bc, 0,
																						 Void, Void, Void, Void, Void)	
			create bc.make (0, none_name, 0, Void, Void, Void)
			create {IS_NORMAL_TYPE} none_type.make (0, bc, 0,
																							Void, Void, Void, Void, Void)	
			Precursor (fl)
			system := Current
			to_fill := True
		end

feature -- Initialization 

	reset
		do
			Precursor
			last_class := Void
			all_classes.clear
			all_types.clear
			all_onces.clear
			all_agents.clear
			all_constants.clear
			fast_name := no_name
		end

feature -- Access 

	any_type: IS_NORMAL_TYPE

	none_type: like any_type
	
	last_class: like class_at
	
feature -- Status setting 

	set_name (nm: READABLE_STRING_8)
		do
			fast_name := nm.twin
		ensure
			name_set: fast_name.is_equal (nm)
		end

feature {PC_DRIVER} -- Reading structure definitions 

	read_once (id: NATURAL)
		local
			cid: INTEGER
		do
			last_class := Void
			read_int
			cid := last_int
			if cid > 0 then
				new_class (cid, 0)
				read_str
				last_string := last_str
			end
		end

feature {PC_BASE} -- Reading header information

	read_header
		do
			Precursor
			read_int
			all_classes.resize (last_int)
			read_int
			all_types.resize (last_int)
			read_int	-- once_count
		end

feature {NONE} -- Implementation 

	read_type (tid: INTEGER)
		do
			new_type (tid, False)
			last_dynamic_type := type_at (tid)
			if attached {IS_NORMAL_TYPE} last_dynamic_type as t then
				if any_type.ident = 0 and then t.class_name.is_equal (any_name) then
					any_type := t
				end
				if not attached root_type then
					root_type := t
				end
			end
		end

feature -- Auxiliary routines of factory 

	type_exists (id: INTEGER): BOOLEAN
		do
			Result := True
		end

feature {NONE} -- Auxiliary routines of factory 

	type_flags (id: INTEGER): INTEGER
		do
			read_int
			Result := last_int
		end

	class_ident (id: INTEGER): INTEGER
		do
			read_int
			Result := last_int
		end

	class_name (id: INTEGER): STRING
		do
			read_str
			Result := last_str
		end

	class_flags (cid: INTEGER): INTEGER
		do
		end

	agent_routine (id: INTEGER): STRING
		do
			read_str
			Result := last_str
		end

	agent_pattern (id: INTEGER): STRING
		do
			read_str
			Result := last_str
		end

	set_agent_base (a: IS_AGENT_TYPE)
		local
			bid: INTEGER
		do
			read_int
			bid := last_int
			new_type (bid, True)
		end

	generic_count (id: INTEGER): INTEGER
		do
			read_int
			Result := last_int
		end

	generic (id, i: INTEGER): INTEGER
		do
			read_int
			Result := last_int
		end

	field_count (id: INTEGER): INTEGER
		do
			read_int
			Result := last_int
		end

	field_type_ident (id, i: INTEGER): INTEGER
		do
			read_int
			Result := last_int
		end

	field_name (id, i: INTEGER): STRING
		do
			read_str
			Result := last_str
		end

	creation_ident (id: INTEGER): INTEGER
		do
		end

	routine_call (tid, i: INTEGER): POINTER
		do
		end

	typeset_index (tid, fid: INTEGER): INTEGER
		do
		end
	
	typeset_size (ts: INTEGER): INTEGER
		do
		end
	
	typeset_tid (ts, i: INTEGER): INTEGER
		do
		end
	
feature {NONE} -- Implementation

	any_name: STRING = "ANY"
	
	none_name: STRING = "NONE"

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
