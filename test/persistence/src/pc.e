note

	description:
		"[
		 Class to store the persitence closure of an object composed
		 of old version classes.
		 ]"

class PC

inherit

	KL_SHARED_FILE_SYSTEM
	KL_SHARED_EXECUTION_ENVIRONMENT
	
create

	make

feature {NONE} -- Initialization

	make (obj: like object; dir: STRING)
		do
			object := obj
			directory := dir
			filename := file_system.pathname (directory, "mix")
			filename := Execution_environment.interpreted_string (filename)
		ensure
			object_set: object = obj
			directory_set: directory = dir
			filename_prefix: dirname (filename).is_equal (directory)
		end

feature -- Access

	basic_flag: INTEGER = 1
	fast_flag: INTEGER = 2
	old_flag: INTEGER = 4

	object: STORABLE

	retrieved: detachable ANY

	no_file: BOOLEAN
	
feature -- Basic operation

	execute (flags: INTEGER)
		local
			fn: STRING
			f: RAW_FILE
			flag: INTEGER
		do
			flag := 0
			if flags & old_flag /= 0 then
				flag := old_flag
				fn := filename + ".gs"
				load_test (fn, False)
			end
			if flags & fast_flag /= 0 then
				flag := fast_flag
				fn := filename + ".gs"
				store_test (fn, False)
				load_test (fn, False)
			end
			if flags & basic_flag /= 0 then
				flag := basic_flag
				fn := filename + ".bs"
				store_test (fn, True)
				load_test (fn, True)
			end
		end

feature {NONE} -- Implementation

	directory: STRING
	filename: STRING

	store_test (fn: STRING; basic: BOOLEAN)
		local
			f: RAW_FILE
		do
			create f.make_open_write (fn)
			if basic then
				object.basic_store (f)
			else
				object.independent_store (f)
			end
			f.close
		end
	
	load_test (fn: STRING; basic: BOOLEAN)
		local
			f: RAW_FILE
		do
			create f.make_with_name (fn)
			if f.exists then
				no_file := False
				f.open_read
				retrieved := object.retrieved (f)
				f.close
			else
				no_file := True
			end
		end
	
invariant
	
end
