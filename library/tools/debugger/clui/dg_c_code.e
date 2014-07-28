note

	description:

		"Persistence source of the runtime system written on the C file."


class DG_C_CODE

inherit

	RAW_FILE
		redefine
			default_create,
			read_natural_8
		end

create

	default_create

feature {NONE} -- Initialization 

	default_create
		do
			shift := 4
			bytes_read := 1
		end

feature {PC_DRIVER} -- Reading 

	read_natural_8
		do
			if shift = 4 then
				item_4 := c_item (block, index)
				index := index + 1
				if (index \\ block_size) = 0 then
					block := block + 1
					index := 0
				end
				shift := 0
			end
			last_natural_8 := item_4.as_natural_8
			item_4 := item_4 |>> 8
			shift := shift + 1
		end

feature {NONE} -- Implementation 

	item_4: NATURAL_32

	shift, index, block: INTEGER

	block_size: INTEGER = 1000


feature {NONE} -- External implementation 

	c_item (b, i: INTEGER): NATURAL_32
		external
			"C inline"
		alias
			"(EIF_NATURAL_32)GE_zblk[$b][$i]"
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
