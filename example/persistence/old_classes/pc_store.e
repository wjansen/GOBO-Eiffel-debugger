note

	description:
		"[
		 Class to store the persitence closure of an object composed
		 of old version classes.
		 ]"

class PC_STORE

inherit

	KL_SHARED_FILE_SYSTEM
	KL_SHARED_EXECUTION_ENVIRONMENT

create
	
	make

feature {NONE} -- Initialization

	make
		local
			dir, fn: STRING
			f: RAW_FILE
			ft: PLAIN_TEXT_FILE
			txt: STRING
		do
			create object.make
			dir := file_system.nested_pathname ("${GOBO}", <<"example", "persistence", "data">>)
			fn := file_system.pathname (dir, "mix.gs")
			fn := Execution_environment.interpreted_string (fn)
			create f.make_open_write (fn)
			object.independent_store (f)
			f.close

			txt := object.out
			io.output.put_string (txt)
			fn := file_system.pathname (dir, "mix.old")
			fn := Execution_environment.interpreted_string (fn)
			create ft.make_open_write (fn)
			ft.put_string (txt)
			ft.close
		end

feature -- Access

	object: MIX

end
