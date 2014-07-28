note

	description: "IO stream mimicking standard IO."

class DG_CLUI_FILE

inherit

	DG_FILE
		redefine
			default_create,
			is_open,
			put_string,
			put_new_line
		end

create

	default_create

feature {NONE} -- Initialization 

	default_create
		do
			create {KL_STDERR_FILE} stream.make
			last_string := ""
		end

feature -- Status 

	is_open: BOOLEAN = True
	
feature -- Status setting 

	set_print_mode (to_ask: BOOLEAN)
		do
			asking_more := to_ask
			if to_ask then
				printed_lines := 0
			end
			skip_lines := False
		ensure then
			asking_more_set: asking_more = to_ask
			when_asking: to_ask implies printed_lines = 0
		end

	more: BOOLEAN
		do
			if not skip_lines and then asking_more and then printed_lines >= max_lines then
				inspect menu (once "More", yes_no_all, 'y')
				when 'a' then
					printed_lines := -{INTEGER}.max_value
				when 'y' then
					printed_lines := 0
				when 'n' then
					skip_lines := True
				end
			end
			Result := not skip_lines
		end

feature -- Basic operation 

	read_command_line
		local
			ready: BOOLEAN
		do
			from
				last_string.wipe_out
				io.error.put_string (command_prompt)
				io.error.flush
			until ready loop
				io.input.read_line
				last_string.append (io.input.last_string)
				ready := io.input.last_string.count < 3 or else not io.input.last_string.ends_with (once "...")
				if not ready then
					last_string.remove_tail (3)
					io.error.put_string (continuation_prompt)
					io.error.flush
				end
			end
		end

	put_new_line
		do
			if not skip_lines then
				stream.put_new_line
				printed_lines := printed_lines + 1
				stream.flush
			end
		end

	put_string (str: STRING)
		do
			if not skip_lines then
				stream.put_string (str)
				printed_lines := printed_lines + str.occurrences ('%N') + 1
			end
		end

	menu (prompt: STRING; options: ARRAY [STRING]; def: CHARACTER): CHARACTER
		local
			i: INTEGER
			ok: BOOLEAN
		do
			io.error.put_string (prompt)
			io.error.put_character (' ')
			io.error.put_character ('{')
			from
				i := options.lower
			until i > options.upper loop
				if i > options.lower then
					io.error.put_character (',')
					io.error.put_character (' ')
				end
				io.error.put_string (options [i])
				i := i + 1
			end
			io.error.put_character ('}')
			io.error.put_character (' ')
			from
			until ok loop
				if Result /= '%U' then
					io.error.put_string (repeat_prompt)
				end
				io.error.put_character ('[')
				io.error.put_character (def)
				io.error.put_string (once "] : ")
				io.input.read_line
				tmp_str.copy (io.input.last_string)
				tmp_str.left_adjust
				if tmp_str.is_empty then
					Result := def
					ok := True
				else
					Result := tmp_str [1].as_lower
					from
						i := options.lower
					until ok or else i > options.upper loop
						ok := Result = (options [i]) [1].as_lower
						if ok then
						else
							i := i + 1
						end
					end
				end
			end
		end

feature {NONE} -- Implementation 

	printed_lines: INTEGER

	asking_more: BOOLEAN

	yes_no_all: ARRAY [STRING]
		once
			Result := <<"yes", "no", "all">>
		end

	repeat_prompt: STRING = "	??	: "


note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
