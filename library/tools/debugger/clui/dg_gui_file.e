note

	description:

		"Socket stream serving external GUI."

class DG_GUI_FILE

inherit

	DG_FILE
		rename
			stream as socket
		redefine
			default_create,
			socket,
			put_string
		end

create

	default_create

feature {NONE} -- Initialization 

	default_create
		local
			host: EPX_HOST
			service: EPX_SERVICE
			client: EPX_TCP_CLIENT_SOCKET
			sa: EPX_HOST_PORT
			arg: STRING
			iaa: like internal_argument_array
			ac, cc, port: INTEGER
			retried: BOOLEAN
		do
			if not retried then
				last_string := ""
				ac := argument_count
				if ac > 0 then
					arg := argument (ac).twin
					cc := arg.count
					if cc > 1 and then arg [1] = '#' and then arg [cc] = '#' then
						arg := arg.substring (2, cc - 1)
						if arg.is_integer then
							port := arg.to_integer
							c_reduce_argc
							create host.make_from_name ("localhost")
							create service.make_from_port (port, "tcp")
							create sa.make (host, service)
							create client.open_by_address (sa)
							socket := client
						end
					end
				end
			end
		rescue
			socket := Void
			retried := True
			retry
		end

feature -- Access 

	socket: detachable ABSTRACT_TCP_SOCKET

feature -- Status 

	more: BOOLEAN = True

feature -- Status setting 

	set_print_mode (to_ask: BOOLEAN)
		do
		end

feature -- Basic operation 

	read_command_line
		local
			r_text: STRING
			m, n: INTEGER
			eof: BOOLEAN
		do
			if eof then
				die (4)
			else
				socket.write_string (command_prompt)
				socket.put_new_line
				socket.flush
				if not socket.is_open_read or else socket.end_of_input then
					eof := True
				else
					socket.read_string (250)
					last_string.copy (socket.last_string)
					if last_string.count > 0 and then last_string [1] = '#' then
						last_string.remove_head (1)
						if last_string [1] = '#' then
							m := Path_only
							last_string.remove_head (1)
						elseif last_string [1] = '$' then
							m := Range_only
							last_string.remove_head (1)
							n := last_string.index_of ('.', 1)
							if n > 0 then
								r_text := last_string.substring (n + 1, last_string.count)
								r_text.right_adjust
								last_string.keep_head (n - 1)
							end
						end
						last_string.left_adjust
						last_string.right_adjust
						if attached debuggee.class_by_name (last_string) as cls then
							put_positions (cls, r_text, m)
						end
						read_command_line
					end
				end
			end
		rescue
			eof := True
			retry
		end

	put_string (str: STRING)
		do
			if socket.is_open_write then
				socket.put_string (str)
			end
		end

	menu (prompt: STRING; options: ARRAY [STRING]; def: CHARACTER): CHARACTER
		do
			Result := def
		end

feature {NONE} -- Implementation 

	Path_only: INTEGER = 1

	Range_only: INTEGER = 2

	Last_mode: INTEGER = 3

	put_positions (cls: IS_CLASS_TEXT; r_text: STRING; m: INTEGER)
		require
			mode_range: 0 <= m and then m < Last_mode
			when_range: m = Range_only implies attached r_text
		local
			j, k, l, n, pk: INTEGER
		do
			inspect m
			when Path_only then
				if attached cls.path as p then
					put_line (p)
				end
			when Range_only then
				if attached cls.feature_by_name (r_text) as x then
					tmp_str.clear_all
					tmp_str.extend ('%%')
					tmp_str.append (x.first_pos.out)
					tmp_str.extend (' ')
					tmp_str.append (x.last_pos.out)
					if attached {IS_ROUTINE_TEXT} x as rx then
						tmp_str.extend (' ')
						tmp_str.append (rx.entry_pos.out)
					end
					put_line (tmp_str)
				else
				end
		else
				from
					j := cls.feature_count
				until j = 0 loop
					tmp_str.clear_all
					j := j - 1
					if attached {IS_ROUTINE_TEXT} cls.feature_at (j) as rt
						and then attached rt.instruction_positions as p
					 then
						from
							n := p.count
							k := 0
						until k = n loop
							pk := p [k]
							if pk /= 0 then
								if tmp_str.count > 80 then
									put_line (tmp_str)
									tmp_str.clear_all
									l := 0
								end
								tmp_str.append_integer (pk)
								tmp_str.extend (' ')
								k := k + 1
							else
								k := n
							end
						end
					end
					if not tmp_str.is_empty then
						put_line (tmp_str)
					end
				end
			end
			put_line (once "0")
		end

feature {NONE} -- External implementation

	c_reduce_argc
		external
			"C inline"
		alias
			"--GE_argc"
		end


note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
