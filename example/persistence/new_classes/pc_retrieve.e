note

	description:
		"[
		 Class to store the persitence closure of an object composed
		 of old version classes.
		 ]"

class PC_RETRIEVE

inherit

	STORABLE
	KL_SHARED_FILE_SYSTEM
	KL_SHARED_EXECUTION_ENVIRONMENT

create
	
	make

feature {NONE} -- Initialization

	make
		local
			fn, dir: STRING
			f: RAW_FILE
			ft: PLAIN_TEXT_FILE
			txt: STRING
			any: detachable ANY
			retried: BOOLEAN
		do
			if not retried then
				create {MIX} any.make	-- make MIX alive
				dir := file_system.nested_pathname ("${GOBO}", <<"example", "persistence", "data">>)	
				fn := file_system.pathname (dir, "mix.gs")	
				fn := Execution_environment.interpreted_string (fn)
				create f.make_with_name (fn)
				if f.exists then
					create f.make_open_read (fn)
					any := retrieved (f)
					f.close
				else
					io.error.put_string ("File ")
					io.error.put_string (fn)
					io.error.put_string (" does not exist,%Nrun system in '")
					io.error.put_string (dir)
					io.error.put_string ("' first.%N")
				end
				if any /= Void then
					txt := any.out
					io.output.put_string (txt)
					fn := file_system.pathname (dir, "mix.new")
					fn := Execution_environment.interpreted_string (fn)
					create ft.make_open_write (fn)
					ft.put_string (txt)
					ft.close
				else
					io.error.put_string ("Severe retrieve error.%N")
				end
			end
		rescue
			io.error.put_string ("Severe retrieve error.%N")
			retried := True
			retry
		end

end
