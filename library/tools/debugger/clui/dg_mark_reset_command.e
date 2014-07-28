note

	description: "Apparatus to store and retrieve of the program state."

class DG_MARK_RESET_COMMAND

inherit

	DG_GLOBALS

	PC_BASE
		undefine
			default_create,
			copy,
			is_equal,
			out
		end
	
	DISPOSABLE
		undefine
			default_create,
			copy,
			is_equal,
			out
		redefine
			dispose
		end

create

	make,
	make_simple

feature {NONE} -- Initialization 

	make (id: INTEGER; st: like orig_frame; name: STRING)
		note
			action:
				"[
				 Store the common persistence closure of all stack
				 variables in `st' and all once functionvalues in `sys'.
				 ]"
			name: "file name"
		local
			fn: STRING
			f: RAW_FILE
			h: PC_HEADER
		do
			default_create
			orig_frame := st
			saved_frame := st.twin
			fn := home_directory.twin
			fn.extend (Operating_environment.Directory_separator)
			fn.append (name)
			fn.extend ('.')
			fn.extend ('m')
			fn.append_integer (id)
			create f.make_open_write (fn)
			create objects.make (100)
			memory_source.reset
			memory_source.set_frame (orig_frame)
			memory_source.set_objects (objects)
			file_target.set_file (f)
			create h
			h.put (file_target, debuggee, Void, Deep_flag, Basic_flag | Stack_flag)
			create onces.make (0, Void)
			determine_initialized_onces
			mark_driver.traverse_stack (file_target, memory_source, onces)
			mark_driver.reset
			memory_source.reset
			file_target.reset
			f.close
			buffer := c_new_buffer
			st.set_buffer (buffer)
			file_name := fn
		ensure
			orig_frame_set: orig_frame = st
			saved_frame_set: saved_frame.is_equal (st)
		end

	make_simple (st: like orig_frame)
		note
			action: "Create `Current' for reset to `st' but without storing anything."
		do
			default_create
			orig_frame := st
			saved_frame := st.twin
			create objects.make (100)
			create onces.make (0, Void)
			determine_initialized_onces
			buffer := c_new_buffer
			st.set_buffer (buffer)
			file_name := Void
		ensure
			orig_frame_set: orig_frame = st
			saved_frame_set: saved_frame.is_equal (st)
		end

feature -- Access 

	orig_frame, saved_frame: IS_STACK_FRAME

	file_name: detachable STRING

	line: INTEGER
		do
			Result := saved_frame.line
		ensure
			definition: Result = saved_frame.line
		end
	
	column: INTEGER
		do
			Result := saved_frame.column
		ensure
			definition: Result = saved_frame.column
		end
	
	depth: INTEGER
		do
			Result := saved_frame.depth
		ensure
			definition: Result = saved_frame.depth
		end
	
	onces: IS_SPARSE_ARRAY [IS_ONCE_CALL]

	pre_initialized_onces: IS_SPARSE_ARRAY [IS_ONCE_CALL]
		local
			old_onces: like onces
		once
			old_onces := onces
			determine_initialized_onces
			Result := onces
			onces := old_onces
		end

	buffer: POINTER

	byte_count: INTEGER
	
feature -- Basic operation 

	restore (actual: like orig_frame)
		note
			action:
			"[
			 Retore the common persistence closure of all
			 stack variables in `saved_frame' and all once function values
			 (provided they have been stored by `make').
			 Then prepare the reset to `actual'.
			 ]"
		local
			pre: like onces
			f: RAW_FILE
			h: PC_HEADER
			i, mode: INTEGER
		do
			orig_frame.copy (saved_frame)
			memory_target.set_frame (orig_frame)
			pre := pre_initialized_onces
			debuggee.refresh_all_onces
			from
				i := pre.count
			until i = 0 loop
				i := i - 1
				pre [i].re_initialize
			end
			from
				i := onces.count
			until i = 0 loop
				i := i - 1
				onces [i].re_initialize
			end
			if attached file_name as fn then
				memory_target.set_objects (objects)
				create f.make_open_read (fn)
				file_source.set_system (debuggee)
				file_source.set_file (f)
				create h.make_from_source (file_source)
				if not h.is_basic then
					raise (Invalid_file)
				end
				if not h.creation_time.is_equal (debuggee.creation_time) then
					raise (Invalid_file)
				end
				reset_driver.traverse_stack (memory_target, file_source, onces)
				reset_driver.reset
				file_source.reset
				memory_target.reset
				f.close
			end
			actual.set_buffer (buffer)
			actual.set_marker (orig_frame)
		end

feature -- DISPOSABLE 

	dispose
		local
			f: RAW_FILE
			null: POINTER
		do
			if buffer /= null then
				c_free (buffer)
				buffer := null
				if attached file_name as fn then
					create f.make (fn)
					if f.exists then
						f.delete
					end
					file_name := Void
				end
			end
		end

feature {} -- Implementation 

	objects: ARRAYED_LIST [ANY]

	determine_initialized_onces
		local
			pre: like onces
			o: IS_ONCE_CALL
			i, k: INTEGER
		do
			pre := pre_initialized_onces
			if debuggee.valid_class (k) and then attached debuggee.class_at (k) as c then
				from
					i := debuggee.once_count
				until i = 0 loop
					i := i - 1
					o := debuggee.once_at (i)
					if o.is_initialized and then not pre.has (o) then
						onces.force (o, onces.count)
					end
				end
			end
		ensure
			not_void: attached onces
		end

	memory_source: DG_MARK_SOURCE
		once
			create Result.make (debuggee, Deep_flag)
		end

	file_target: DG_MARK_TARGET
		once
			create Result
		end

	file_source: DG_RESET_SOURCE
		once
			create Result.make (Deep_flag)
		end

	memory_target: DG_RESET_TARGET
		once
			create Result.make (debuggee, False)
		end

	mark_driver: DG_PERSISTENCE [NATURAL, ANY]
		local
			objs: PC_ANY_TABLE [NATURAL]
			types: PC_ANY_TABLE [detachable IS_TYPE]
		once
			create objs.make (1000, 0)
			create types.make (1000, Void)
			create Result.make (objs, types)
		end

	reset_driver: DG_PERSISTENCE [ANY, NATURAL]
		local
			objs: PC_LINEAR_TABLE [detachable ANY]
			types: PC_LINEAR_TABLE [detachable IS_TYPE]
		once
			create objs.make (1000, Void)
			create types.make (1000, Void)
			create Result.make (objs, types)
		end

	invalid_file: STRING = "Invalid mark/reset file."


feature {} -- External implementation 

	c_new_buffer: POINTER
		external
			"C inline use <setjmp.h>"
		alias
			"malloc(sizeof(GE_jmp_buf))"
		end

	c_free (p: POINTER)
		external
			"C inline use <stdlib.h>"
		alias
			"free($p)"
		end

invariant

	buffer_not_null: buffer /= default_pointer

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
