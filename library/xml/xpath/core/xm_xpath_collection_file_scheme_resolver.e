indexing

	description:

		"Objects that resolve URIs for the file scheme, when XPath fn:collection() function"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2005, Colin Adams and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_COLLECTION_FILE_SCHEME_RESOLVER

inherit

	XM_XPATH_COLLECTION_SCHEME_RESOLVER

	XM_XPATH_DIRECTORY_COLLECTION_ROUTINES

	XM_XPATH_ERROR_TYPES
		export {NONE} all end

	KL_SHARED_FILE_SYSTEM
		export {NONE} all end

	UT_SHARED_FILE_URI_ROUTINES
		export {NONE} all end

create

	make

feature {NONE} -- Initialization

	make is
			-- Establish invariant.
		do
			scheme := "file"
		end

feature -- Status report

	last_error: XM_XPATH_ERROR_VALUE
			-- Last error set by `resolve'

feature -- Element change

	resolve (a_uri: UT_URI; a_context: XM_XPATH_CONTEXT) is
			-- Resolve `a_uri' to a sequence of nodes.
		local
			a_directory_name: STRING
			a_directory: KL_DIRECTORY
		do
			if a_uri.has_fragment then
				create last_error.make_from_string ("Fragment identifiers are not allowed on file URIs for fn:collection()", Xpath_errors_uri, "FODC0004", Dynamic_error)
			elseif a_uri.has_query then
				create last_error.make_from_string ("Parameters are not yet implemented on file URIs for fn:collection()", Xpath_errors_uri, "FODC0004", Dynamic_error)
			elseif not a_uri.has_path then
				create last_error.make_from_string ("File URI passed to fn:collection() must include a path", Xpath_errors_uri, "FODC0004", Dynamic_error)
			elseif a_uri.has_path_base then
				create last_error.make_from_string ("Filtering is not yet implemented on file URIs for fn:collection()", Xpath_errors_uri, "FODC0004", Dynamic_error)
			else
				a_directory_name := file_system.pathname_to_string (File_uri.uri_to_pathname(a_uri))
				if not file_system.directory_exists (a_directory_name) then
					create last_error.make_from_string ("Directory specified in file: argument to fn:collection() does not exist", Xpath_errors_uri, "FODC0004", Dynamic_error)
				else
					create a_directory.make (a_directory_name)
					resolve_directory (a_uri, a_uri, a_context, a_directory)
				end
			end
		end

invariant

	scheme_is_file: STRING_.same_string (scheme, "file")

end