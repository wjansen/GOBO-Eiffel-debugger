note

	description: "Internal description of a SCOOP processor."

expanded class DG_PROCESSOR

inherit

	IS_NAME
		redefine
			append_name,
			is_equal
		end

create

	default_create

feature -- Constants 

	Starting: INTEGER = 0

	Idle: INTEGER = 1

	Running: INTEGER = 2

	Blocked: INTEGER = 3

	Waiting: INTEGER = 4

	Stopping: INTEGER = 5

	status_names: ARRAY [STRING]
		once
			create Result.make_filled ("", Starting, Stopping)
			Result.put ("starting", Starting)
			Result.put ("idle", Idle)
			Result.put ("running", Running)
			Result.put ("blocked", Blocked)
			Result.put ("waiting", Waiting)
			Result.put ("stopping", Stopping)
		end

feature -- Initalization 

	set (addr: POINTER)
		do
			ptr := addr
		ensure
			ptr_set: ptr = addr
		end

feature -- Status 

	exists: BOOLEAN
		do
			Result := ptr /= default_pointer
		end

	top_frame: IS_STACK_FRAME
		require
			exists: exists
		do
			Result := c_top_frame (ptr)
		end

	ident: INTEGER
		require
			exists: exists
		do
			Result := c_ident (ptr)
		end

	creator (sys: IS_RUNTIME_SYSTEM): detachable IS_CLASS_TEXT
		local
			nm: STRING
		do
			create nm.make_from_c (c_name (ptr))
			Result := sys.class_by_name (nm)
		end

	status: INTEGER
		require
			exists: exists
		do
			Result := c_status (ptr)
		end

	db_steps: INTEGER
		require
			exists: exists
		do
			Result := c_db_steps (ptr)
		end

	db_stack: IS_STACK_FRAME
		require
			exists: exists
		do
			Result := c_db_stack (ptr)
		end

	next: DG_PROCESSOR
		note
			return: "{
Next processor (if `exists') or first processor (otherwise)
in the list of all processors.
`Result' exists iff there is such a processor.
}"
		local
			addr: POINTER
		do
			addr := c_next (ptr)
			Result.set (addr)
		end

feature -- Status setting 

	set_db_steps (n: INTEGER)
		require
			exists: exists
		do
			c_set_db_steps (ptr, n)
		end

	set_db_stack (s: POINTER)
		require
			exists: exists
		do
			c_set_db_stack (ptr, s)
		end

feature -- Comparison 

	is_equal (other: like Current): BOOLEAN
		do
			Result := ptr = other.ptr
		end

feature -- Output 

	append_name (s: STRING)
		do
			s.append (status_names [status])
		end

feature {IS_NAME} -- Implementation

	fast_name: STRING
		do
			Result := no_name
		end

feature {DG_PROCESSOR} -- External implementation 

	ptr: POINTER

feature {NONE} -- External implementation 

	c_next (p: POINTER): POINTER
		external
			"C inline"
		alias
			"[ 

#ifdef GE_SCOOP 
	se_next_proc((se_subsystem_t*)$p) 
#else 
	NULL 
#endif 

			 ]"
		end

	c_top_frame (p: POINTER): IS_STACK_FRAME
		external
			"C inline"
		alias
			"[

#ifdef GE_SCOOP 
	(EIF_ANY)(((se_subsystem_thread_t*)$p)->dst)
#else 
	NULL 
#endif 

			 ]"
		end

	c_ident (p: POINTER): INTEGER
		external
			"C inline"
		alias
			"[ 

#ifdef GE_SCOOP 
	((se_subsystem_t*)$p)->num 
#else 
	0 
#endif 

			 ]"
		end

	c_name (p: POINTER): POINTER
		external
			"C inline"
		alias
			"[ 

#ifdef GE_SCOOP 
	(((se_subsystem_t*)$p)->name)+9 
#else 
	0 
#endif 

			 ]"
		end

	c_status (p: POINTER): INTEGER
		external
			"C inline"
		alias
			"[

#ifdef GE_SCOOP 
	((se_subsystem_t*)$p)->state 
#else 
	0 
#endif 

			 ]"
		end

	c_db_stack (p: POINTER): IS_STACK_FRAME
		external
			"C inline"
		alias
			"[

#ifdef GE_SCOOP 
	(EIF_ANY)(((se_subsystem_t*)$p)->db_stack)
#else 
	0 
#endif 

			 ]"
		end

	c_db_steps (p: POINTER): INTEGER
		external
			"C inline"
		alias
			"[

#ifdef GE_SCOOP 
	((se_subsystem_t*)$p)->db_steps 
#else 
	0 
#endif 

			 ]"
		end

	c_set_db_steps (p: POINTER; n: INTEGER)
		external
			"C inline"
		alias
			"[

#ifdef GE_SCOOP 
	((se_subsystem_t*)$p)->db_steps=$n 
#endif 

			 ]"
		end

	c_set_db_stack (p, s: POINTER)
		external
			"C inline"
		alias
			"[ 

#ifdef GE_SCOOP 
	((se_subsystem_t*)$p)->db_stack=$s 
#endif 

			 ]"
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
