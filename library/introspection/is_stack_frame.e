note

	description: "Internal description of a frame of the call stack."

class IS_STACK_FRAME

inherit

	ANY
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
		do
			if attached routine then
				-- make attributes alive
				create routine.make ("", "", Void, 0, Void, 1, 2, 3, 4, 5, Void, Void)
				caller := Current
--				marker := Current
--				rescue_buffer := default_pointer
--				mark_buffer := default_pointer
				depth := 1
				scope_depth := 2
				pos := 3
				class_id := 4
			end
		end
	
feature -- Status 

	is_default: BOOLEAN
		do
			Result := not attached routine
		end

	has_caller: BOOLEAN
		do
			Result := attached caller
		end

	caller: detachable IS_STACK_FRAME

	line: INTEGER
		do
			Result := pos // 256
		end

	column: INTEGER
		do
			Result := pos \\ 256
		end

	class_id: INTEGER
	
	routine: IS_ROUTINE

	is_rescueing: BOOLEAN
		do
			Result := rescue_buffer /= default_pointer
		end

	depth: INTEGER

	scope_depth: INTEGER

	target_type: IS_TYPE
		do
			Result := routine.target
		end

	target: POINTER
		note
			return: "Dereferenced address of the target of the call."
		local
			null: POINTER
		do
			Result := stack_address (0)
			if Result /= null then
				-- Target is always	a pointer: 
				Result := to_ptr (Result)
			end
		end

	valid_index (i: INTEGER): BOOLEAN
		do
			Result := routine.valid_var (i)
		end

	var_at (i: INTEGER): detachable IS_LOCAL
		note
			return: "`i-th' argumenent, local variable, or old value."
		require
			valid_index: valid_index (i)
		do
			Result := routine.var_at (i)
		end

	marker: detachable IS_STACK_FRAME

	mark_buffer: POINTER
	
	rescue_buffer: POINTER
	
	stack_address (i: INTEGER): POINTER
		note
			return:
			"[
			 Address on stack (i.e. not dereferenced) of the `i-th'
			 routine argument or local variable.
			 ]"
		require
			valid_index: valid_index (i)
		do
			if attached routine as r and then attached r.var_at (i) as l then
				Result := $Current + l.offset
			end
		end

feature -- Status setting 

	to_default
		do
			routine := Void
			caller := Void
--			marker := Void
			pos := 0
			depth := 0
			scope_depth := 0
--			mark_buffer := default_pointer
--			rescue_buffer := default_pointer
		end
	
	set_buffer (b: POINTER)
		do
			mark_buffer := b
		ensure
			mark_buffer_set: mark_buffer = b
		end

	set_marker (m: IS_STACK_FRAME)
		do
			marker := m
		ensure
			marker_set: marker = m
		end

	set_position (row, col: INTEGER)
		do
			pos := row * 256 + col \\ 256
		ensure
			pos_set: pos = row * 256 + col \\ 256
		end

feature {NONE} -- Implementation 

	pos: INTEGER

	to_ptr (p: POINTER): POINTER
		external "C inline"
		alias "*(EIF_POINTER*)$p"
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
