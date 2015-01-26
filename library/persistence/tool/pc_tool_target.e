note

	description: "Extracting per object information from a persistence closure."

class PC_TOOL_TARGET

inherit

	PC_STATISTICS_TARGET
		rename
			make as make_statistics
		undefine
			put_void_ident
		redefine
			default_create,
			reset,
			pre_object,
			post_object,
			pre_special,
			post_special,
			put_known_ident,
			put_new_object,
			put_new_special,
			set_field,
			set_index
		end

	PC_QUALIFIER_TARGET 
		undefine
			pre_agent,
			copy,
			is_equal,
			out
		redefine
			default_create,
			reset,
			pre_object,
			post_object,
			pre_special,
			post_special,
			put_known_ident,
			put_new_object,
			put_new_special,
			set_field,
			set_index
		end

create

	make

feature {NONE} -- Initialization 

	default_create
		do
			Precursor {PC_STATISTICS_TARGET} 
			Precursor {PC_QUALIFIER_TARGET} 
		end
	
	make (f: FILE)
		require
			open: f.is_open_read
		do
			default_create
			make_statistics (True)
			create data_positions.make (1000)
			file := f	
		ensure
			file_set: file = f
		end

feature -- Initialization

	reset
		do
			Precursor {PC_STATISTICS_TARGET} 
			Precursor {PC_QUALIFIER_TARGET} 
		end
	
feature -- Access 

	data_positions: PC_LINEAR_TABLE [INTEGER]

feature {PC_DRIVER} -- Push and pop data
	
	pre_object (t: IS_TYPE; id: attached like void_ident)
		do
			if id /= void_ident then
				data_positions.put (file.position, id)
			end
			Precursor {PC_STATISTICS_TARGET} (t, id)
		end
	
	post_object (t: IS_TYPE; id: attached like void_ident)
		do
			Precursor {PC_STATISTICS_TARGET} (t, id)
		end
	
	pre_special (s: IS_SPECIAL_TYPE; cap: NATURAL; id: attached like void_ident)
		do
			data_positions.put (file.position, id)
			Precursor {PC_STATISTICS_TARGET} (s, cap, id)
		end
	
	post_special (s: IS_SPECIAL_TYPE; id: attached like void_ident)
		do
			Precursor {PC_STATISTICS_TARGET} (s, id)
		end

feature {PC_DRIVER} -- Writing elementary data
	
	put_known_ident (t: IS_TYPE; id: NATURAL)
		do
			Precursor {PC_STATISTICS_TARGET} (t, id)
			Precursor {PC_QUALIFIER_TARGET} (t, id)
		end

	put_new_object (t: IS_TYPE)
		do
			Precursor {PC_STATISTICS_TARGET} (t)
			Precursor {PC_QUALIFIER_TARGET} (t)
		end

	put_new_special (st: IS_SPECIAL_TYPE; n, cap: NATURAL)
		do
			Precursor {PC_STATISTICS_TARGET} (st, n, cap)
			Precursor {PC_QUALIFIER_TARGET} (st, n, cap)
		end

feature {PC_DRIVER} -- Object location

	set_field (f: like field; in: NATURAL)
		do
			Precursor {PC_STATISTICS_TARGET} (f, in)
			Precursor {PC_QUALIFIER_TARGET} (f, in)
		end

	set_index (s: IS_SPECIAL_TYPE; i: NATURAL; in: NATURAL)
		do
			Precursor {PC_STATISTICS_TARGET} (s, i, in)
			Precursor {PC_QUALIFIER_TARGET} (s, i, in)
		end
	
feature {NONE} -- Implementation 

	file: FILE

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
