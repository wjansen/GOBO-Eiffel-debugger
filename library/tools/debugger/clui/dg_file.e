note

	description: "Output stream mimicking `IO.error'."

deferred class DG_FILE

inherit

	DG_GLOBALS

	PLAIN_TEXT_FILE
		export
			{NONE} all
			{ANY}
				extendible,
				last_string,
				put_string,
				put_new_line,
				is_open_write,
				is_closed,
				open_read,
				close,
				count,
				file_pointer
		redefine
			put_string,
			put_new_line
		end

feature -- Status 

	is_open: BOOLEAN
		do
			Result := attached stream as s and then s.is_open_write
		end

	skip_lines: BOOLEAN

	more: BOOLEAN
		note
			return: "Ask user whether to continue output when the screen is full."
		deferred
		end

feature -- Status setting 

	set_print_mode (to_ask: BOOLEAN)
		deferred
		ensure
			do_not_skip: not skip_lines
		end

feature -- Basic operation 

	read_command_line
		deferred
		end

	put_string (str: STRING)
		do
			stream.put_string (str)
		end

	put_new_line
		do
			stream.put_new_line
			stream.flush
		end

	put_line (str: STRING)
		note
			action: "Put `str' on output and add a new line."
		do
			put_string (str)
			put_new_line
		end

	menu (prompt: STRING; options: ARRAY [STRING]; def: CHARACTER): CHARACTER
		note
			return: "first character of chosen option"
			def: "first character of the default option"
		deferred
		ensure
				-- `Result' is the first character of one of the `options'. 
		end

feature {NONE} -- Implementation 

	stream: KI_TEXT_OUTPUT_STREAM

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
