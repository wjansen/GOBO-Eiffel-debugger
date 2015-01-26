note

	description: "Analysis of the persistence closure of Eiffel objects."

class PC_TOOL

inherit

	PC_DESERIALIZER
		rename
			source as make_source
		undefine
			raise
		redefine
			reset
		end

	PC_TOOL_PARSER
		rename
			reset as reset_parser
		undefine
			default_create,
			copy,
			is_equal,
			out
		end

	ARGUMENTS
		rename
			command_name as line_command
		undefine
			default_create,
			copy,
			is_equal,
			out
		end

create

	make

feature {NONE} -- Initialization 

	make
		local
			lv, rv: PC_TOOL_VALUE
		do
			create objects.make (0)
			create types.make (0)
			create attr
			create file.make ("no_name")
			create source.make (Deep_flag)
			default_create
			if argument_count = 1 then
				load (argument (1))
			elseif argument_count > 1 then
				raise ("Too many parameters.")
			end
			make_parser
			process_commands
		end

	reset
		do
			Precursor
			objects.clear
			types.clear
		end
	
feature -- Access 

	file: RAW_FILE

feature -- Basic operation 

	process_commands
		local
			cmd: STRING
			f_in: detachable RAW_FILE
			tf, cf: PLAIN_TEXT_FILE
			tt: PC_TEXT_TARGET
			dr: PC_SERIAL_DRIVER [NATURAL]
			fn, hn: STRING
			code: INTEGER
		do
			from
			until code = Quit_code loop
				io.output.put_string (command_prompt)
				io.output.flush
				io.input.read_line
				cmd := io.last_string
				cmd.left_adjust
				cmd.right_adjust
				if not cmd.is_empty then
					reset_parser
					parse_line (cmd)
					code := command_code
					if not attached file then
						inspect code
						when load_code, help_code, quit_code then
						else
							raise ("No store file loaded.")
						end
					elseif is_basic then
						inspect code
						when actual_code, load_code then
						else
							raise ("Command not available for basic stored mode.")
						end
					elseif store_order = Deep_flag then
						inspect code
						when qualifier_code, long_code, xml_code, cc_code, extract_code then
							raise ("Command not available for deep store mode.")
						else
						end
					end
					f_in := file
					check attached f_in and store_mode /= Basic_store end
					inspect code
					when actual_code then
						print_header
					when size_code then
						io.output.put_string ("Statistics:%N")
						io.output.put_string (tool_target.out)
					else
					end
					inspect code
					when print_code then
						if not is_basic then
							file.open_read 
							create source.make (Deep_flag)
							source.set_file (file)
							create header.make_from_source (source)
							is_basic := header.is_basic
							source.read_header
							create tt.make (io.output, source)
							tt.set_flat ((header.order & Deep_flag) = 0)
							tt.set_prefix("$")
							if filename.is_empty then
								tf := Void
							else
								if need_extension then
									fn := filename + ".txt"
								else
									fn := filename
								end
								create tf.make_open_write(fn)
								tt.set_file (tf)
							end
							dr := integer_driver (tt, source, header.order, header.options)
							dr.traverse
							file.close
						end
						if tf /= Void then
							tf.close
						end
					when types_code then
						print_types
					when fields_code then
						if tool_target.types.count > ident
							and then attached tool_target.types [ident] as ti
						 then
							print_fields (ti)
						else
							raise_no_type (ident)
						end
					when objects_code then
						print_objects (ident)
					when qualifier_code, long_code then
						print_qualified (ident.to_natural_32, code = Long_code)
					when rename_code then
						new_names (filename)
					when extract_code then
						if need_extension then
							fn := filename + ".gs"
						else
							fn := filename
						end
						extract (f_in, ident.to_natural_32, fn)
					when load_code then
						if need_extension then
							fn := filename + ".gs"
						else
							fn := filename
						end
						load (fn)
					when xml_code then
						if need_extension then
							fn := filename + ".xml"
						else
							fn := filename
						end
						to_xml (f_in, fn)
					when cc_code then
						if need_extension then
							fn := filename + ".c"
							hn := filename
						else
							fn := filename
						end
						to_c (f_in, fn, hn)
					when help_code then
						print_help
					when quit_code then
					else
					end
				end
			end
		rescue
			io.output.put_string (error_prompt)
			io.output.put_string (original_msg)
			io.output.put_new_line
			original_msg.wipe_out
			retry
		end
	
	deserialize (tgt: PC_ABSTRACT_TARGET; forward: BOOLEAN)
		local
			dr: PC_SERIAL_DRIVER [NATURAL]
		do
			file.open_read 
			create source.make (Deep_flag)
			source.set_file (file)
			create header.make_from_source (source)
			source.read_header
			top_object := Void
			create dr.make (tgt, source, header.order, header.options)
			dr.traverse
			if attached {like objects} dr.known_objects as ko then
					objects := ko
			end
			file.close
			types := source.object_types
		ensure
			not_open: not f.is_open
		end
	
feature {NONE} -- Command implementation 
	
	load (fn: STRING)
		do
			file.make (fn)
			if not file.exists then
				raise_no_file (fn)
			end
			reset
			create tool_target.make (file)
			deserialize (tool_target, False)
			is_basic := header.is_basic
			store_order := header.order
			print_header
		ensure
			when_loaded: attached file as ff implies not ff.is_open_read
		end
	
	print_header
		require
			file_loaded: attached file
		local
			dt: DT_DATE_TIME
		do
			io.output.put_string (once "File:%T%T")
			io.output.put_string (file.name)
			io.output.put_new_line
			io.output.put_string (once "System:%T%T")
			io.output.put_string (header.root_name)
			io.output.put_new_line
			compilation_time := header.compilation_time
			create dt.make_from_epoch ((compilation_time // 1000).to_integer_32)
			dt.set_millisecond ((compilation_time \\ 1000).to_integer_32)
			source.set_compilation_time (compilation_time)
			io.output.put_string (once "Compiled at:%T")
			io.output.put_string (dt.out)
			io.output.put_new_line
			io.output.put_string (once "Store mode:%T")
			if is_basic then
				io.output.put_string (once "basic")
			else
				io.output.put_string (once "general")
			end
			io.output.put_character (',')
			io.output.put_character (' ')
			inspect store_order
			when Fifo_flag then
				io.output.put_string (once "fifo")
			when Lifo_flag, Forward_flag then
				io.output.put_string (once "lifo")
			when Deep_flag then
				io.output.put_string (once "deep")
			else
			end
			if with_onces then
				io.output.put_string (once ", with once value identification")
			end
			io.output.put_new_line
			if attached comment as c and then c.count > 0 then
				io.output.put_string (once "Description:")
				if c.count > 60 then
					io.output.put_new_line
				else
					io.output.put_character ('%T')
				end
				io.output.put_string (c)
				io.output.put_new_line
			end
			if header.minor < 6 then
				raise ("Store file too old.%N")
			end
		end

	print_types
		local
			ti: IS_TYPE
			ts: IS_SEQUENCE [IS_TYPE]
			i, l, n: INTEGER
		do
			n := tool_target.types.count
			tmp_str.copy (n.out)
			l := tmp_str.count
			create ts
			from
				i := n
			until i = 0 loop
				i := i - 1
				if attached tool_target.types [i] as t and then not t.is_agent then
					ts.add (t)
				end
			end
			ts.sort (agent compare_types)
			from
				n := ts.count
			until i = n loop
				ti := ts [i]
				tmp_str.copy (ti.ident.out)
				pad (tmp_str, l, True)
				tmp_str.extend (' ')
				ti.append_name (tmp_str)
				io.output.put_string (tmp_str)
				io.output.put_new_line
				i := i + 1
			end
		end

	print_objects (id: INTEGER)
		local
			i, n: NATURAL
			l: INTEGER
			comma: BOOLEAN
		do
			from
				n := types.count.to_natural_32
			until i = n loop
				if attached {IS_TYPE} types [i] as t and then t.ident = id then
					tmp_str.wipe_out
					if l + tmp_str.count > 64 then
						io.output.put_new_line
						l := 0
					end
					if comma then
						tmp_str.extend (',')
						tmp_str.extend (' ')
					end
					tmp_str.append (pre_fix)
					tmp_str.append_natural_32 (i)
					io.output.put_string (tmp_str)
					l := l + tmp_str.count
					comma := True
				end
				i := i + 1
			end
			io.output.put_new_line
		end

	print_fields (t: IS_TYPE)
		local
			a: IS_FIELD
			j, m: INTEGER
		do
			tmp_str.copy ("Fields of type ")
			t.append_name (tmp_str)
			tmp_str.extend (':')
			io.output.put_string (tmp_str)
			io.output.put_new_line
			attr.clear
			from
				m := t.field_count
			until j = m loop
				attr.add (t.field_at (j))
				j := j + 1
			end
			attr.default_sort
			from
				j := 0
			until j = m loop
				tmp_str.wipe_out
				a := attr [j]
				a.append_name (tmp_str)
				tmp_str.extend (':')
				tmp_str.extend (' ')
				a.type.append_name (tmp_str)
				io.output.put_string (tmp_str)
				io.output.put_new_line
				j := j + 1
			end
		end

	print_qualified (id: NATURAL; typed: BOOLEAN)
		local
			str: STRING
		do
			create str.make (1001)
			tool_target.append_qualified_name (id, str, typed, True)
			io.output.put_string (str)
			io.output.put_new_line
		end

	print_help
		local
			cmd: attached like no_command
			name: STRING
			i, l, l0, n: INTEGER
		do
			io.output.put_string (once "Overview of commands%N")
			io.output.put_new_line
			from
				n := commands.count
			until i = n loop
				i := i + 1
				cmd := commands [i]
				name := cmd.name
				l0 := name.count
				if attached cmd.help_arg as ha then
					l0 := l0 + 1 + ha.count
				end
				l := l.max (l0)
			end
			l := l + 1
			from
				i := 0
			until i = n loop
				i := i + 1
				cmd := commands [i]
				name := cmd.name
				if attached cmd.help_line as hl then
					tmp_str.wipe_out
					tmp_str.append (name)
					if attached cmd.help_arg as ha then
						tmp_str.extend (' ')
						tmp_str.append (ha)
					end
					pad (tmp_str, l, False)
					tmp_str.append (hl)
					io.output.put_string (tmp_str)
					io.output.put_new_line
				end
			end
		end

	new_names (fn: STRING)
		local
			f: PLAIN_TEXT_FILE
			ss: IS_SYSTEM
			entry, new, last_class: STRING
			n: INTEGER
		do
			create f.make_open_read (fn)
			if not f.exists then
				raise ("Dictionary file does not exist.")
			end
			last_class := ""
			ss := source.system
			from
			until f.end_of_file loop
				f.read_line
				entry := f.last_string
				entry.left_adjust
				if entry.count > 0 and then not entry.starts_with (comment_sign) then
					parse_rename (entry)
					if attached rename_tuple.cls as nm then
						last_class := nm
					end
					if attached {PC_CLASS_TEXT} ss.class_by_name (last_class) as cls then
						new := rename_tuple.new
						if attached rename_tuple.f as an then
							from
								n := ss.type_count
							until n = 0 loop
								n := n - 1 
								if attached {IS_NORMAL_TYPE} ss.type_at (n) as t
									and then t.base_class = cls
								 then
									if attached t.field_by_name (an) as a then
										a.set_name (new)
									end
								end
							end
						end
					end
				end
			end
			f.close
			f.open_read 
			from
			until f.end_of_file loop
				f.read_line
				entry := f.last_string
				entry.left_adjust
				if entry.count > 0 and then not entry.starts_with (comment_sign) then
					parse_rename (entry)
					ss := source.system
					if not attached rename_tuple.f and then
						attached {PC_CLASS_TEXT} ss.class_by_name (rename_tuple.cls) as cls
					 then
						new := rename_tuple.new
						cls.set_name (new)
					end
				end
			end
			f.close
		end
	
	extract (f_in: RAW_FILE; id: NATURAL; fn: STRING)
		local
			ps: PC_POSITIONED_STREAM_SOURCE
			st: PC_STREAM_TARGET
			dr: PC_RANDOM_ACCESS_DRIVER [NATURAL, NATURAL]
			h: PC_HEADER
			f: RAW_FILE
			opts: INTEGER
		do
			f_in.open_read
			create header.make_from_source (source)
			is_basic := header.is_basic
			store_order := header.order
			opts := header.options & Once_observation_flag
			create ps.make (source)
			create st.make (source)
			create dr.make (st, ps, header.order, header.options, objects)
			create f.make_open_write (fn)
			st.set_file (f)
			create h.make_for_target (header.root_name, source.system,
																Void, header.order, header.options)
			h.put (st)
			st.write_header (source.system)
			dr.traverse (id)
			f_in.close
			f.close
		end
	
	to_xml (f_in: FILE; fn: STRING)
		require
			not_basic: not is_basic
		local
			ps: PC_POSITIONED_STREAM_SOURCE
			fd: PC_FORWARD_DRIVER [NATURAL, NATURAL]
			oo: PC_INTEGER_TABLE [PC_TYPED_IDENT [NATURAL]]
			xml: PC_XML_TARGET
			xf: PLAIN_TEXT_FILE
		do
			create xf.make_open_write (fn)
			f_in.open_read 
			create xml.make (xf, comment, "_no_name", source)
			create oo.make (objects.count)
			create ps.make (source)
			create fd.make (xml, ps, oo)
			fd.traverse (tool_target.top_ident)
			f_in.close
			xf.close
		end
	
	to_c (f_in: FILE; fn: STRING; hn: detachable STRING)
		local
			cf: PLAIN_TEXT_FILE
			hf: detachable PLAIN_TEXT_FILE
			tt: PC_LINEAR_TABLE [PC_TYPED_IDENT [NATURAL]]
			ps: PC_POSITIONED_STREAM_SOURCE
			fd: PC_FORWARD_DRIVER [NATURAL, NATURAL]
			ct: PC_C_TARGET
		do
			f_in.open_read
			create cf.make_open_write (fn)
			if hn /= Void then
				create hf.make_open_write (hn + ".h")
			end
			create ps.make (source)
			create ct.make (cf, hf, hn, "T", "x", "x0", source.system, True, False)
			create tt.make (objects.count*2)
			create fd.make (ct, ps, tt)
			fd.traverse (source.top_ident)
			cf.close
			if hf /= Void then
				hf.close
			end
			f_in.close
		end
	
feature {NONE} -- Error handling 

	raise_no_file (fn: STRING)
		do
			raise ("File " + fn + " cannot be opened.")
		end

	raise_no_type (id: INTEGER)
		do
			raise ("Type " + (id.out) + " is not present.")
		end

feature {NONE} -- Implementation 

	command_prompt: STRING = "pc> "

	error_prompt: STRING = "pc: "

	comment_sign: STRING = "--"

	source: PC_TOOL_SOURCE

	tool_target: PC_TOOL_TARGET

	objects: PC_LINEAR_TABLE [PC_TYPED_IDENT [NATURAL]]

	types: PC_LINEAR_TABLE [detachable IS_TYPE]
	
	positions: PC_LINEAR_TABLE [INTEGER]
	
	attr: IS_SEQUENCE [IS_FIELD]

	pad (s: STRING; n: INTEGER; left: BOOLEAN)
		require
			positive: n > 0
		local
			i: INTEGER
		do
			from
				i := s.count
			until i >= n loop
				if left then
					s.precede (' ')
				else
					s.extend (' ')
				end
				i := i + 1
			end
		ensure
			not_smaller: s.count >= old s.count
			extended: old s.count < n implies s.count = n
		end

	compare_types (u, v: IS_TYPE): BOOLEAN
		local
			u_name, v_name: STRING
			i, n: INTEGER
		do
			u_name := u.class_name
			v_name := v.class_name
			if u_name < v_name then
				Result := True
			elseif u_name = v_name then
				from
					n := u.generic_count
				until Result or else i = n loop
					Result := compare_types (u.generic_at (i), v.generic_at (i))
					i := i + 1
				end
			end
		end

	append_path (id: NATURAL; typed: BOOLEAN; to: STRING)
		local
			tt: PC_LINEAR_TABLE [detachable IS_TYPE]
			cc: PC_LINEAR_TABLE [NATURAL]
			ff: PC_LINEAR_TABLE [detachable IS_ENTITY [INTEGER]]
			pp: PC_LINEAR_TABLE [NATURAL]
			i: NATURAL
		do
			ff := source.fields
			pp := source.parents
			tt := source.object_types
			path.wipe_out
			top_name := "all"
			from
				i := id
			until i = 0 loop
				path.put_front ([ff[i], i, tt[i], cc[i]])
				i := pp[i]
			end
			append_qualified_name (id, to, typed)
		end

	print_chars (f: FILE; c: CHARACTER; n: INTEGER)
		require
			not_negative: n >= 0
		local
			i: INTEGER
		do
			from
				i := n
			until i = 0 loop
				f.put_character (c)
				i := i - 1
			end
		end

	pre_fix: STRING = "$"
	
	tmp_str: STRING = "                                          "

invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
