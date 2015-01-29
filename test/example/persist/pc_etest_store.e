note

	description:

		"Test 'persistence' example"

	library: "Gobo Eiffel Persistence Closure Library"
	copyright: "Copyright (c) 2015, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class PC_ETEST_STORE

inherit

	EXAMPLE_TEST_CASE

create

	make_default

feature -- Access

	program_name: STRING = "demo"
			-- Program name

	library_name: STRING = "persistence"
			-- Library name of example

feature -- Test

	test_demo
			-- Test 'persistence' example.
		local
			store_exe: STRING
		do
			compile_program
				-- Run example.
			store_exe := program_exe
			assert_execute (store_exe + output_log)
			assert_integers_equal ("no_error_log", 0, file_system.file_count (error_log_filename))
			if file_system.same_text_files (text_filename, output_log_filename) then
				assert ("diff", True)
				assert_files_equal ("diff2", text_filename, output_log_filename)
			end
		end

feature {NONE} -- Implementation

	store_dirname: STRING
			-- Name of directory where data files are located
		once
			Result := file_system.nested_pathname ("${GOBO}", <<"test", "example", "persist", "data">>)
			Result := Execution_environment.interpreted_string (Result)
		ensure
			store_dirname_not_void: Result /= Void
			store_dirname_not_empty: Result.count > 0
		end

	text_filename: STRING
			-- Name of expected output file
		once
			Result := file_system.pathname (store_dirname, "pc_example.bs")
		ensure
			text_filename_not_void: Result /= Void
			text_filename_not_empty: Result.count > 0
		end

end
