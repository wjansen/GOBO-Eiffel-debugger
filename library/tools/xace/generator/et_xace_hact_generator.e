indexing

	description:

		"Ace file generators for Halstenbach"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2001-2002, Andreas Leitner and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_XACE_HACT_GENERATOR

inherit

	ET_XACE_GENERATOR

	KL_IMPORTED_ARRAY_ROUTINES

	UT_STRING_ROUTINES
		export {NONE} all end

creation

	make

feature -- Access

	ace_filename: STRING is "hact.ace"
			-- Name of generated Ace file

feature -- Output

	generate_system (a_system: ET_XACE_SYSTEM) is
			-- Generate a new Ace file from `a_system'.
		local
			a_filename: STRING
			a_file: KL_TEXT_OUTPUT_FILE
			an_externals: ET_XACE_EXTERNALS
		do
			if output_filename /= Void then
				a_filename := output_filename
			else
				a_filename := ace_filename
			end
			!! a_file.make (a_filename)
			a_file.open_write
			if a_file.is_open_write then
				an_externals := a_system.externals
				if an_externals /= Void then
					an_externals := an_externals.cloned_externals
				end
				a_system.merge_externals
				print_ace_file (a_system, a_file)
				a_file.close
				a_system.set_externals (an_externals)
			else
				error_handler.report_cannot_write_file_error (a_filename)
			end
		end

	generate_cluster (a_cluster: ET_XACE_CLUSTER) is
			-- Generate a new precompilation Ace file from `a_cluster'.
		local
			a_filename: STRING
			a_file: KL_TEXT_OUTPUT_FILE
		do
			if output_filename /= Void then
				a_filename := output_filename
			else
				a_filename := ace_filename
			end
			!! a_file.make (a_filename)
			a_file.open_write
			if a_file.is_open_write then
				print_precompile_ace_file (a_cluster, a_file)
				a_file.close
			else
				error_handler.report_cannot_write_file_error (a_filename)
			end
		end

feature {NONE} -- Output

	print_ace_file (a_system: ET_XACE_SYSTEM; a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print Ace `a_system' to `a_file'.
		require
			a_system_not_void: a_system /= Void
			system_name_not_void: a_system.system_name /= Void
			root_class_name_not_void: a_system.root_class_name /= Void
			creation_procedure_name_not_void: a_system.creation_procedure_name /= Void
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			an_option: ET_XACE_OPTIONS
			a_clusters: ET_XACE_CLUSTERS
			an_external: ET_XACE_EXTERNALS
		do
			a_file.put_line ("system")
			a_file.put_new_line
			print_indentation (1, a_file)
			a_file.put_line (a_system.system_name)
			a_file.put_new_line
			a_file.put_line ("root")
			a_file.put_new_line
			print_indentation (1, a_file)
			a_file.put_string (a_system.root_class_name)
			a_file.put_string (": %"")
			a_file.put_string (a_system.creation_procedure_name)
			a_file.put_character ('%"')
			a_file.put_new_line
			a_file.put_new_line
			an_option := a_system.options
			if an_option /= Void then
				a_file.put_line ("default")
				a_file.put_new_line
				print_options (an_option, 1, a_file)
				a_file.put_new_line
			end
			a_file.put_line ("cluster")
			a_file.put_new_line
			a_clusters := a_system.clusters
			if a_clusters /= Void then
				print_clusters (a_clusters, 1, a_file)
				a_file.put_new_line
			end
			print_component (a_file)
			an_external := a_system.externals
			if
				an_external /= Void and then
				(an_external.has_include_directories or an_external.has_link_libraries)
			then
				a_file.put_line ("external")
				a_file.put_new_line
				print_include_directories (an_external.include_directories, a_file)
				print_link_libraries_and_link_libraries_directories (an_external.link_libraries, an_external.link_libraries_directories, a_file)
			end
			a_file.put_line ("end")
		end

	print_precompile_ace_file (a_cluster: ET_XACE_CLUSTER; a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print precompilation Ace file to `a_file'.
		require
			a_cluster_not_void: a_cluster /= Void
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			an_option: ET_XACE_OPTIONS
			an_external: ET_XACE_EXTERNALS
		do
			a_file.put_line ("system")
			a_file.put_new_line
			print_indentation (1, a_file)
			a_file.put_line (a_cluster.name)
			a_file.put_new_line
			a_file.put_line ("root")
			a_file.put_new_line
			print_indentation (1, a_file)
			a_file.put_line ("ANY")
			a_file.put_new_line
			an_option := a_cluster.options
			if an_option /= Void then
				a_file.put_line ("default")
				a_file.put_new_line
				print_options (an_option, 1, a_file)
			end
			a_file.put_new_line
			a_file.put_line ("cluster")
			a_file.put_new_line
			print_cluster (a_cluster, 1, a_file)
			a_file.put_new_line
			print_component (a_file)
			!! an_external.make
			a_cluster.merge_externals (an_external)
			if
				not an_external.is_empty and then
				(an_external.has_include_directories or an_external.has_link_libraries)
			then
				a_file.put_line ("external")
				a_file.put_new_line
				print_include_directories (an_external.include_directories, a_file)
				print_link_libraries_and_link_libraries_directories (an_external.link_libraries, an_external.link_libraries_directories, a_file)
			end
			a_file.put_line ("end")
		end

	print_component (a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print component clause to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		do
			a_file.put_string ("component")
			a_file.put_new_line
			a_file.put_new_line
			print_indentation (2, a_file)
			a_file.put_string ("-- ISS-Baselib")
			a_file.put_new_line
			print_indentation (1, a_file)
			a_file.put_string ("base: %"$ISS_BASE/spec/$PLATFORM/component/base.cl%"")
			a_file.put_new_line
			a_file.put_new_line
		end

	print_options (an_option: ET_XACE_OPTIONS; indent: INTEGER; a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print `an_option' to `a_file'.
		require
			an_option_not_void: an_option /= Void
			indent_positive: indent >= 0
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		do
			if an_option.has_optimize.is_true then
				print_indentation (indent, a_file)
				a_file.put_string ("assertion (no)")
				a_file.put_new_line
			elseif an_option.has_optimize.is_false then
				print_indentation (indent, a_file)
				a_file.put_string ("assertion (all)")
				a_file.put_new_line
			else
				if an_option.has_check.is_true then
					print_indentation (indent, a_file)
					a_file.put_string ("assertion (check)")
					a_file.put_new_line
				elseif an_option.has_loop.is_true then
					print_indentation (indent, a_file)
					a_file.put_string ("assertion (loop)")
					a_file.put_new_line
				elseif an_option.has_invariant.is_true then
					print_indentation (indent, a_file)
					a_file.put_string ("assertion (invariant)")
					a_file.put_new_line
				elseif an_option.has_ensure.is_true then
					print_indentation (indent, a_file)
					a_file.put_string ("assertion (ensure)")
					a_file.put_new_line
				elseif an_option.has_require.is_true then
					print_indentation (indent, a_file)
					a_file.put_string ("assertion (require)")
					a_file.put_new_line
				else
					print_indentation (indent, a_file)
					a_file.put_string ("assertion (no)")
					a_file.put_new_line
				end
			end
		end

	print_clusters (a_clusters: ET_XACE_CLUSTERS; indent: INTEGER; a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print `a_clusters' to `a_file'.
		require
			a_clusters_not_void: a_clusters /= Void
			indent_positive: indent >= 0
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			i, nb: INTEGER
			cluster_list: DS_ARRAYED_LIST [ET_XACE_CLUSTER]
		do
			cluster_list := a_clusters.clusters
			nb := cluster_list.count
			from i := 1 until i > nb loop
				print_cluster (cluster_list.item (i), indent, a_file)
				i := i + 1
			end
		end

	print_cluster (a_cluster: ET_XACE_CLUSTER; indent: INTEGER; a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print `a_cluster' to `a_file'.
		require
			a_cluster_not_void: a_cluster /= Void
			indent_positive: indent >= 0
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			a_pathname, a_name: STRING
			an_option: ET_XACE_OPTIONS
			subclusters: ET_XACE_CLUSTERS
			need_end_keyword: BOOLEAN
			an_externals: ET_XACE_EXTERNALS
			a_cursor: DS_LINKED_LIST_CURSOR [ET_XACE_EXPORTED_CLASS]
		do
			if not a_cluster.is_fully_abstract then
				print_indentation (indent, a_file)
				if a_cluster.is_abstract then
					a_file.put_string ("abstract ")
				end
				a_name := a_cluster.name
				if is_lace_keyword (a_name) then
					a_file.put_character ('%"')
					a_file.put_string (a_cluster.name)
					a_file.put_character ('%"')
				else
					a_file.put_string (a_cluster.name)
				end
				a_pathname := a_cluster.pathname
				if a_pathname /= Void then
					a_file.put_string (": %"")
					a_file.put_string (a_pathname)
					a_file.put_character ('%"')
				end
				an_option := a_cluster.options
				if an_option /= Void then
					a_file.put_new_line
					print_indentation (indent + 1, a_file)
					a_file.put_line ("default")
					print_options (an_option, indent + 2, a_file)
					need_end_keyword := True
				end
				an_externals := a_cluster.externals
				if an_externals /= Void and then not an_externals.exported_classes.is_empty then
					a_file.put_new_line
					print_indentation (indent + 1, a_file)
					a_file.put_line ("visible")
					a_cursor := an_externals.exported_classes.new_cursor
					from a_cursor.start until a_cursor.after loop
						print_exported_class (a_cursor.item, indent + 2, a_file)
						a_cursor.forth
					end
					need_end_keyword := True
				end
				subclusters := a_cluster.subclusters
				if subclusters /= Void then
					a_file.put_new_line
					print_indentation (indent + 1, a_file)
					a_file.put_line ("cluster")
					print_clusters (subclusters, indent + 2, a_file)
					need_end_keyword := True
				end
				if need_end_keyword then
					print_indentation (indent + 1, a_file)
					a_file.put_string ("end;")
					a_file.put_new_line
				else
					a_file.put_character (';')
					a_file.put_new_line
				end
			end
		end

	print_exported_class (a_class: ET_XACE_EXPORTED_CLASS; indent: INTEGER; a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print `a_class' to `a_file'.
		require
			a_class_not_void: a_class /= Void
			indent_positive: indent >= 0
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			a_cursor: DS_LINKED_LIST_CURSOR [ET_XACE_EXPORTED_FEATURE]
		do
			print_indentation (indent, a_file)
			a_file.put_string (a_class.class_name)
			a_file.put_new_line
			if not a_class.features.is_empty then
				print_indentation (indent + 1, a_file)
				a_file.put_string ("export")
				a_file.put_new_line
				a_cursor := a_class.features.new_cursor
				from a_cursor.start until a_cursor.after loop
					print_indentation (indent + 2, a_file)
					a_file.put_string (a_cursor.item.feature_name)
					if not a_cursor.is_last then
						a_file.put_character (',')
					end
					a_file.put_new_line
					a_cursor.forth
				end
			end
			print_indentation (indent + 1, a_file)
			a_file.put_string ("end")
			a_file.put_new_line
		end

	print_include_directories (a_directories: DS_LINKED_LIST [STRING]; a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print `a_directories' to `a_file'.
		require
			a_directories_not_void: a_directories /= Void
			no_void_directory: not a_directories.has (Void)
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			a_cursor: DS_LINKED_LIST_CURSOR [STRING]
			a_pathname: STRING
		do
			if not a_directories.is_empty then
				print_indentation (1, a_file)
				a_file.put_string ("include_path:")
				a_file.put_new_line
				a_cursor := a_directories.new_cursor
				from a_cursor.start until a_cursor.after loop
					print_indentation (2, a_file)
					a_file.put_character ('%"')
					a_pathname := a_cursor.item
					if is_windows then
						a_pathname := replace_all_characters (a_pathname, '{', '(')
						a_pathname := replace_all_characters (a_pathname, '}', ')')
					end
					a_file.put_string (a_pathname)
					if a_cursor.is_last then
						a_file.put_string ("%";")
					else
						a_file.put_string ("%",")
					end
					a_file.put_new_line
					a_cursor.forth
				end
				a_file.put_new_line
			end
		end

	print_link_libraries_and_link_libraries_directories (link_libraries, link_libraries_directories: DS_LINKED_LIST [STRING]; a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print `link_libraries' and `link_libraries_directories' to
			-- `a_file'.
		require
			link_libraries_not_void: link_libraries /= Void
			no_void_library: not link_libraries.has (Void)
			link_libraries_directories_not_void: link_libraries_directories /= Void
			no_void_directory: not link_libraries_directories.has (Void)
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			a_cursor: DS_LINKED_LIST_CURSOR [STRING]
			a_pathname: STRING
			may_close_statement: BOOLEAN
			lib_contains_path,
			has_dot_lib_extension,
			lib_needs_option: BOOLEAN
		do
			if
				not link_libraries.is_empty or else
				not link_libraries_directories.is_empty
			then
				print_indentation (1, a_file)
				a_file.put_line ("object:")
				may_close_statement := link_libraries_directories.is_empty
				a_cursor := link_libraries.new_cursor
				from a_cursor.start until a_cursor.after loop
					a_pathname := a_cursor.item
					print_indentation (2, a_file)
					lib_contains_path := a_pathname.has ('/') or a_pathname.has ('\')
					if lib_contains_path then
						lib_needs_option := False
					else
						has_dot_lib_extension := a_pathname.count > 4 and then a_pathname.substring (a_pathname.count - 3, a_pathname.count).is_equal (".lib")
						lib_needs_option := not has_dot_lib_extension
					end
					if lib_needs_option then
						a_file.put_string ("%"-l")
					else
						a_file.put_character ('%"')
						if is_windows then
							a_pathname := replace_all_characters (a_pathname, '{', '(')
							a_pathname := replace_all_characters (a_pathname, '}', ')')
						end
					end
					a_file.put_string (a_pathname)
					if a_cursor.is_last and may_close_statement then
						a_file.put_line ("%";")
					else
						a_file.put_line ("%",")
					end
					a_cursor.forth
				end
				-- employ trick to get linker paths to the C compiler.
				-- Works on Unix, I'm doubtful about Windows with MSC.
				-- Windows and bcc probably work fine.
				a_cursor := link_libraries_directories.new_cursor
				from a_cursor.start until a_cursor.after loop
					print_indentation (2, a_file)
					a_file.put_string ("%"-L")
					a_pathname := a_cursor.item
					if is_windows then
						a_pathname := replace_all_characters (a_pathname, '{', '(')
						a_pathname := replace_all_characters (a_pathname, '}', ')')
					end
					a_file.put_string (a_pathname)
					if a_cursor.is_last then
						a_file.put_line ("%";")
					else
						a_file.put_line ("%",")
					end
					a_cursor.forth
				end
				a_file.put_new_line
			end
		end

feature {NONE} -- Implementation

	is_lace_keyword (a_name: STRING): BOOLEAN is
			-- Is `a_name' a LACE keyword?
		require
			a_name_not_void: a_name /= Void
		local
			i, nb: INTEGER
			a_keywords: like lace_keywords
		do
			a_keywords := lace_keywords
			i := a_keywords.lower
			nb := a_keywords.upper
			from until i > nb loop
				if a_keywords.item (i).is_equal (a_name) then
					Result := True
					i := nb + 1 -- Jump out of the loop.
				else
					i := i + 1
				end
			end
		end

	lace_keywords: ARRAY [STRING] is
			-- LACE keywors
		once
			Result := <<
				"abstract",
				"assertion",
				"cluster",
				"component",
				"debug",
				"default",
				"end",
				"export",
				"external",
				"include_path",
				"object",
				"option",
				"root",
				"system",
				"visible"
			>>
		ensure
			lace_keywords_not_void: Result /= Void
			no_void_keyword: not STRING_ARRAY_.has (Result, Void)
		end

end -- class ET_XACE_HACT_GENERATOR
