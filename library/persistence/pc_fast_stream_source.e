note

	description:
		"[ 
		 Scanning the persistence closure from a file. 
		 The information is taken form the current system. 
		 ]"

class PC_FAST_STREAM_SOURCE

inherit

	PC_STREAM_SOURCE
		redefine
			make,
			new_normal_type,
			new_expanded_type,
			new_special_type,
			new_tuple_type,
			new_agent_type,
			set_fields_of_type,
			set_agent_base
		end

create

	make

feature {NONE} -- Initialization

	make (fl: INTEGER)
		do
			Precursor (fl)
			system := runtime_system
			to_fill := False
		end
	
feature {NONE} -- Auxiliary routines of factory 

	new_normal_type (id, fl: INTEGER; bc: attached like class_at)
		do
			if attached {IS_NORMAL_TYPE} system.type_at (id) as nt then
				nt.scan_in_system (Current)
				last_type := nt
			end
		end

	new_expanded_type (id, fl: INTEGER; bc: attached like class_at)
		do
			if attached {IS_EXPANDED_TYPE} system.type_at (id) as et then
				et.scan_in_system (Current)
				last_type := et
			end
		end

	new_special_type (id, fl: INTEGER)
		do
			if attached {IS_SPECIAL_TYPE} system.type_at (id) as st then
				st.scan_in_system (Current)
				last_type := st
			end
		end

	new_tuple_type (id, fl: INTEGER)
		do
			if attached {IS_TUPLE_TYPE} system.type_at (id) as tt then
				tt.scan_in_system (Current)
				last_type := tt	
			end
		end

	new_agent_type (id, fl: INTEGER; nm, ocp: READABLE_STRING_8)
		do
			if attached {IS_AGENT_TYPE} system.type_at (id) as at then
				at.scan_in_system (Current)
				last_type := at
			end
		end

feature {IS_TYPE} -- Factory 

	set_fields_of_type (t: attached like type_at)
		do
			Precursor (t)
			last_fields := t.fields
		end
	
	set_agent_base (a: IS_AGENT_TYPE)
		do
			Precursor (a)
			last_type := Void
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
