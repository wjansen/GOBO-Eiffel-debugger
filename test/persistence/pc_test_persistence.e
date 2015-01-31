note

	description:

		"Test persistence closure routines"

	library: "Gobo Eiffel Persistence Closure Library"
	copyright: "Copyright (c) 2015, Wolfgang Jansen and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class PC_TEST_PERSISTENCE

inherit

	TS_TEST_CASE
		redefine
			make_default
		end
	
	KL_SHARED_FILE_SYSTEM
	KL_SHARED_EXECUTION_ENVIRONMENT
	
create

	make_default

feature {NONE}

	make_default
		local
			f: PLAIN_TEXT_FILE
		do
			Precursor
			create {MIX} object.make
			create f.make_open_write (out_filename)
			f.put_string (object.out)
			f.close
		end
	
feature -- Access

	object: STORABLE

feature -- Test

	test_old
			-- Test independent retrieve
		local
			pc: PC
		do
			create pc.make (object, data_dirname)
			pc.execute (pc.old_flag)
			check_retrieved (pc, pc.old_flag)
		end

	test_fast
			-- Test fast store/retrieve
		local
			pc: PC
		do
			create pc.make (object, data_dirname)
			pc.execute (pc.fast_flag)
			check_retrieved (pc, pc.fast_flag)
		end

	test_basic
			-- Test basic store/retrieve
		local
			pc: PC
			fn: STRING
			f: PLAIN_TEXT_FILE
		do
			create pc.make (object, data_dirname)
			pc.execute (pc.basic_flag)
			check_retrieved (pc, pc.basic_flag)
		end

feature {NONE} -- Implementation

	dirname: STRING
			-- Name of test directory
		once
			Result := file_system.nested_pathname ("${GOBO}", <<"test", "persistence">>)
			Result := Execution_environment.interpreted_string (Result)
		ensure
			dirname_not_empty: Result.count > 0
		end

	data_dirname: STRING
			-- Name of directory where data files are located
		once
			Result := file_system.pathname (dirname, "data")
			Result := Execution_environment.interpreted_string (Result)
		ensure
			store_dirname_not_empty: Result.count > 0
		end

	out_filename: STRING
			-- Name of file to write `oubject.out' before storing
		once
			Result := file_system.pathname (data_dirname, "out.txt")
			Result := Execution_environment.interpreted_string (Result)
		ensure
			out_filename_not_empty: Result.count > 0
		end

	in_filename: STRING
			-- Name of file to write `oubject.out' after retrieval
		once
			Result := file_system.pathname (data_dirname, "in.txt")
			Result := Execution_environment.interpreted_string (Result)
		ensure
			in_filename_not_empty: Result.count > 0
		end

	check_retrieved (pc: PC; flag: INTEGER)
		local
			ret: detachable ANY
			f: PLAIN_TEXT_FILE
		do
			ret := pc.retrieved
			assert ("file-exists", not pc.no_file)
			assert ("not-void", ret /= Void)
			if ret /= Void then 
				assert ("same-type", ret.same_type (object))
				create f.make_open_write (in_filename)
				f.put_string (ret.out)
				f.close
				assert ("same-contents", file_system.same_text_files (in_filename, out_filename))
				if attached {MIX} ret as mix then
					assert_integers_equal ("agent-call", mix.func.item ([mix.some_object.s]), 0)
				end
			end
		end
	
end
