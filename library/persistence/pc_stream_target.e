note

	description:
		"[ 
		 Writing the persistence closure of one object and the 
		 related type information in binary format. 
		 ]"

class PC_STREAM_TARGET

inherit

	PC_BASIC_TARGET
		undefine
			copy,
			is_equal,
			out
		redefine
			default_create,
			reset,
			write_header,
			put_new_object,
			put_new_special,
			put_once
		end

	IS_FACTORY
		rename
			make as make_system
		redefine
			default_create,
			class_at,
			type_at,
			once_at,
			new_normal_type,
			new_expanded_type,
			new_special_type,
			new_tuple_type,
			new_agent_type,
			set_agent_base
		end

create

	make

feature {NONE} -- Initialization 

	default_create
		do
			Precursor {PC_BASIC_TARGET}
			Precursor {IS_FACTORY}
		end
	
	make (s: like source_system)
		do
			source_system := s
			create known_types.make_filled (0, 0, 1000)
			fast_name := no_name
			default_create
			set_system (s)
			set_file (Void)
			root_type := s.root_type
			last_type := Void
			to_fill := False
		end

feature -- Initialization 

	reset
		do
			Precursor
			known_types.clear_all
			field := Void
			file := Void
		end

feature -- Access

	class_at (id: INTEGER): detachable IS_CLASS_TEXT
		require else
			valid_class: source_system.valid_class (id)
		do
			Result := source_system.class_at (id)
		end

	type_at (id: INTEGER): detachable IS_TYPE
		require else
			valid_type: source_system.valid_type (id)
		do
			Result := source_system.type_at (id)
		end
	
	once_at (id: INTEGER): IS_ONCE
		do
			Result := source_system.once_at (id)
		end
	
	any_type: IS_NORMAL_TYPE
		do
			Result := source_system.any_type
		end

	none_type: like any_type
		do
			Result := source_system.none_type
		end

feature -- Status setting 

	set_system (s: like source_system)
		do
			source_system := s
			all_classes.clear
			all_classes.resize (s.class_count)
			all_types.clear
			all_types.resize (s.type_count)
			all_agents.clear
		ensure
			source_system: source_system = s
		end

feature {NONE} -- Push and pop types 

	put_once (cls: detachable IS_CLASS_TEXT; nm: STRING; id: like void_ident)
		local
			cid: INTEGER
		do
			last_ident := id
			if attached cls as c then
				cid := c.ident
				write_int (cid)
				new_class (cid, 0)
				write_str (nm)
			else
				write_int (0)
			end
		end

feature {PC_DRIVER} -- Put elementary data 

	put_new_object (t: IS_TYPE)
		local
			tid: INTEGER
		do
			next_ident
			tid := t.ident
			write_int (tid)
			new_type (tid, True)
			if attached file as f then
				f.flush
			end
		end

	put_new_special (s: IS_SPECIAL_TYPE; n, cap: NATURAL)
		local
			tid: INTEGER
		do
			next_ident
			tid := s.ident
			write_int (tid)
			new_type (tid, True)
			write_uint (n)
			if has_capacities then
				write_uint (cap)
			end
			if attached file as f then
				f.flush
			end
		end

feature {PC_BASE} -- Writing header information 

	write_header (src: IS_SYSTEM)
		do
			Precursor (src)
			write_int (src.class_count)
			write_int (src.type_count)
			write_int (src.once_count)
		end

feature -- Auxiliary routines of factory 

	type_exists (id: INTEGER): BOOLEAN
		do
			Result := valid_type (id)
			if not Result then
				Result := source_system.valid_type (id)
				all_types.force (type_at (id), id)
			end
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
	
feature {NONE} -- Auxiliary routines of factory 

	new_normal_type (id, fl: INTEGER; bc: attached like class_at)
		do
			if attached {IS_NORMAL_TYPE} type_at (id) as nt then
				nt.scan_in_system (Current)
				last_type := nt
			end
		end

	new_expanded_type (id, fl: INTEGER; bc: attached like class_at)
		do
			if attached {IS_EXPANDED_TYPE} type_at (id) as et then
				et.scan_in_system (Current)
				last_type := et
			end
		end

	new_special_type (id, fl: INTEGER)
		do
			if attached {IS_SPECIAL_TYPE} type_at (id) as st then
				st.scan_in_system (Current)
				last_type := st
			end
		end

	new_tuple_type (id, fl: INTEGER)
		do
			if attached {IS_TUPLE_TYPE} type_at (id) as tt then
				tt.scan_in_system (Current)
				last_type := tt	
			end
		end

	new_agent_type (id, fl: INTEGER; nm, ocp: READABLE_STRING_8)
		do
			if attached {IS_AGENT_TYPE} type_at (id) as ag then
				ag.scan_in_system (Current)
				last_type := ag
			end
		end

	type_flags (id: INTEGER): INTEGER
		do
			if attached type_at (id) as t then
				Result := t.flags
				write_int (Result & {IS_BASE}.Type_category_flag)
			end
		end

	class_ident (id: INTEGER): INTEGER
		do
			if attached {IS_NORMAL_TYPE} type_at (id) as n then
				Result := n.base_class.ident
			end
			write_int (Result)
		end

	class_flags (cid: INTEGER): INTEGER
		do
		end

	class_name (id: INTEGER): READABLE_STRING_8 
		do
			Result := class_at (id).fast_name
			write_str (Result)
		end

	agent_routine (id: INTEGER): READABLE_STRING_8
		do
			if attached {IS_AGENT_TYPE} type_at (id) as a then
				Result := a.routine_name
			else
				Result := no_name
			end
			write_str (Result)
		end

	agent_pattern (id: INTEGER): READABLE_STRING_8
		do
			if attached {IS_AGENT_TYPE} type_at (id) as a then
				Result := a.open_closed_pattern
			else
				Result := no_name
			end
			write_str (Result)
		end
	
	set_agent_base (a: IS_AGENT_TYPE)
		local
			bid: INTEGER
		do
			bid := a.base.ident
			write_int (bid)
			new_type (bid, True)
			last_type := a.base
		end

	generic_count (id: INTEGER): INTEGER
		do
			if attached type_at (id) as t then
				Result := t.generic_count
				write_int (Result)
			end
		end

	generic (id, i: INTEGER): INTEGER
		do
			if attached type_at (id) as t then
				Result := t.generic_at (i).ident
				write_int (Result)
			end
		end

	field_count (id: INTEGER): INTEGER
		do
			if attached type_at (id) as t then
				Result := t.field_count
				write_int (Result)
			end
		end

	field_type_ident (id, i: INTEGER): INTEGER
		local
			ft: IS_TYPE
		do
			if attached type_at (id) as t then
				ft := t.field_at (i).type
				Result := ft.ident
				write_int (Result)
			end
		end

	field_name (id, i: INTEGER): STRING_8
		local
			f: IS_FIELD
			c: CHARACTER
		do
			if attached type_at (id) as t then
				f := t.field_at (i)
				Result := f.fast_name
				if f.is_attached then
					Result := Result.twin
					c := Result [1]
					c := c.as_upper
					Result.put (c, 1)
				end
				write_str (Result)
			else
				Result := no_name
			end
		end

	creation_ident (id: INTEGER): INTEGER
		do
		end

	routine_call (tid, i: INTEGER): POINTER
		do
		end

feature {NONE} -- Implementation 

	Known_class: INTEGER_8 = 1

	Raw_type: INTEGER_8 = 2

	known_types: ARRAY [INTEGER_8]

feature -- Implementation

	source_system: IS_SYSTEM

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
