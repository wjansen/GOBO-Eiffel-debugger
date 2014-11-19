note

	description:
		"[ 
		 Header information to be written to or read from
		 the persistence closure of one object. 
		 ]"

class PC_HEADER

inherit

	PC_BASE
		redefine
			default_create
		end
	
	IS_BASE
		redefine
			default_create
		end
	
	EXCEPTIONS
		redefine
			default_create
		end
	
create

	default_create,
	make_from_source

feature {NONE} -- Initialization

	default_create
		do
			root_name := ""
			create last_word.make (8)
		end
	
	make_from_source (src: PC_MEDIUM_SOURCE)
		require
			is_open: src.medium.is_open_read
		local
			m: IO_MEDIUM
			flags: INTEGER
			failed: BOOLEAN
		do
			m := src.medium
			create last_word.make (8)
			read_word (m)
			if not equal (last_word, Manifest) then
				raise ("")
			end
			read_word (m)
			failed := last_word.substring_index ("2.", 1) /= 1
			if not failed then
				last_word.keep_tail (last_word.count - 2)
				if last_word.is_integer then
					minor := last_word.to_integer
				end
				failed := (minor < 5) or else (minor > 6)
			end
			if failed then
				raise_retrieval_exception (store_version_error)
			end
			src.read_string
			root_name := src.last_string
			src.read_integer_64
			compilation_time := src.last_integer_64
			src.read_integer_64
			creation_time := src.last_integer_64
			src.read_integer_64
			store_time := src.last_integer_64
			src.read_string
			comment := src.last_string
			src.read_integer
			flags := src.last_integer
			options := flags & Order_flag.bit_not
			order := flags & Order_flag
			is_basic := options & Basic_flag /= 0
		ensure
			is_open: src.medium.is_open_read
		end
	
feature -- Access
	
	creation_time: INTEGER_64
	
	compilation_time: INTEGER_64

	store_time: INTEGER_64
	
	minor: INTEGER

	root_name: STRING

	comment: detachable READABLE_STRING_8

	order: INTEGER
	
	options: INTEGER

	is_basic: BOOLEAN

	may_be_fast: BOOLEAN

feature -- Basic operation

	put_explicitly (tgt: PC_BASIC_TARGET; root: READABLE_STRING_8;
									c: like comment; ord, opts: INTEGER;
									comp_time, create_time, actual_time: INTEGER_64)
		require
			file_open: tgt.medium.is_open_write
		do
			root_name := root
			store_time := actual_time
			compilation_time := comp_time
			creation_time := create_time
			comment := c
			if not tgt.has_consecutive_indices then
				options := Non_consecutive_flag
				if tgt.has_position_indices then
					options := options | File_position_flag
				end
			end
			options := opts
			options := options & Order_flag.bit_not
			order := ord
			write_word (tgt.medium, Manifest)
			write_word (tgt.medium, Version)
			tgt.put_string (root)
			tgt.put_integer_64 (compilation_time)
			tgt.put_integer_64 (creation_time)
			tgt.put_integer_64 (store_time)
			if attached comment as comm then
				tgt.put_string (comm)
			else
				tgt.put_string ("")
			end
			tgt.put_integer (options | order)
		ensure
			file_open: tgt.medium.is_open_write
		end

	put (tgt: PC_BASIC_TARGET; s: IS_SYSTEM; c: like comment; ord, opts: INTEGER)
		do
			if attached s.root_type as root then
				root_name := root.name
			else
				root_name := s.name.as_upper
			end
			put_explicitly (tgt, root_name, c, ord, opts,
											s.compilation_time, s.creation_time,
											s.actual_time_as_integer)
		end

feature {NONE} -- Implementation

	Manifest: STRING = "EIFFEL_OBJECT"

	Version: STRING = "2.6"
	
	write_word (m: IO_MEDIUM; s: STRING)
		local
			i: INTEGER
		do
			from
			until i = s.count loop
				i := i + 1
				m.put_character (s [i])
			end
			m.put_character (' ')
		end
	
	read_word (medium: IO_MEDIUM)
		require
			medium_is_open: medium.is_open_read
		local
			c: CHARACTER
			eof: BOOLEAN
		do
			last_word.wipe_out
			from
				eof := attached {FILE} medium as f and then f.end_of_file
			until c = ' ' or else eof loop
				medium.read_character
				c := medium.last_character
				last_word.extend (c)
				eof := attached {FILE} medium as f and then f.end_of_file
			end
			if eof then
				last_word.wipe_out
			else
				last_word.remove_tail (1)
			end
		end

	last_word: STRING

	destroyed_file_error: STRING = "Destroyed persistence file."

	store_version_error: STRING = "Incompatible persistence version."

	store_order_error: STRING = "Unsupported storage order."

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
