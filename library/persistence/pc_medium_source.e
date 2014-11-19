note

	description:
		"[ 
		 Scanning the persistence closure from a file. 
		 The information is taken form the current system. 
		 ]"

deferred class PC_MEDIUM_SOURCE

inherit

	PC_SERIAL_SOURCE [NATURAL]
		redefine
			reset
		end

	IS_BASE
		undefine
			default_create,
			copy, is_equal, out
		end 
	
feature {NONE} -- Initialization 

	make (flags: INTEGER)
		do
			system := runtime_system
			make_source 
			reset
			if flags & Non_consecutive_flag /= 0 then
				has_consecutive_indices := False
				if flags & File_position_flag /= 0 then
					has_position_indices := True
				end
			end
		end
	
feature -- Initialization 

	reset
		do
			set_file (io.input)
			last_dynamic_type := Void
			top_ident := void_ident
			has_consecutive_indices := True
			has_position_indices := False
		end

feature -- Access 

	has_position_indices: BOOLEAN

	void_ident: NATURAL = 0

	system: IS_SYSTEM

	medium: IO_MEDIUM

	top_ident: NATURAL

feature -- Status setting 

	set_system (s: like system)
		do
			system := s
		ensure
			system_set: system = s
		end

	set_file (m: like medium)
		do
			medium := m
		ensure
			medium_set: medium = m
		end

feature {PC_DRIVER} -- Object location
	
	set_index (s: IS_SPECIAL_TYPE; i: NATURAL; in: NATURAL)
		do
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
