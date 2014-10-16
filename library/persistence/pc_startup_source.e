note

	description:

		"Persistence source of the runtime system written on the C file."

class PC_STARTUP_SOURCE

inherit

	PC_STREAM_SOURCE
		redefine
			reset,
			read_byte
		end

create

	default_create

feature -- Initialization 

	reset
		do
			Precursor
			shift := 4
		end

feature {PC_DRIVER} -- Reading 

	read_byte
		do
			if shift = 4 then
				get_item_4
				shift := 0
			end
			last_byte := item_4.as_natural_8
			item_4 := item_4 |>> 8
			shift := shift + 1
		end

feature {} -- Implementation 

	item_4: NATURAL_32

	shift, index, block: INTEGER

	block_size: INTEGER = 1000


	get_item_4
		do
			item_4 := c_item (block, index)
			index := index + 1
			if (index \\ block_size) = 0 then
				block := block + 1
				index := 0
			end
		end

feature {} -- External implementation 

	c_item (b, i: INTEGER): NATURAL_32
		external
			"C inline"
		alias
			"[ 
 
#if defined GEIP_TABLES && GEIP_TABLES == 2
  (EIF_NATURAL_32)geip_blk[$b][$i] 
#else 
  0 
#endif 
 
]"
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
