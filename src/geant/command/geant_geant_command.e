indexing

	description:

		"Geant commands"

	library: "Gobo Eiffel Ant"
	copyright: "Copyright (c) 2001, Sven Ehrke and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class GEANT_GEANT_COMMAND

inherit

	GEANT_COMMAND

creation

	make

feature -- Status report

	is_filename_executable: BOOLEAN is
			-- Can command be executed on a project file?
		do
			Result := filename /= Void and then filename.count > 0
		ensure
			filename_not_void: Result implies filename /= Void
			filename_not_empty: Result implies filename.count > 0
		end

	is_target_executable: BOOLEAN is
			-- Can command be executed on a target?
		do
			Result := start_target_name /= Void and then start_target_name.count > 0
		ensure
			target_not_void: Result implies start_target_name /= Void
			target_not_empty: Result implies start_target_name.count > 0
		end

	is_executable: BOOLEAN is
			-- Can command be executed?
		do
			Result := is_filename_executable or is_target_executable
		ensure then
			project_or_target: Result implies is_filename_executable or is_target_executable
		end

feature -- Access

	filename: STRING
			-- Geant build file to invoke.

	reuse_variables: BOOLEAN
			-- Are variables reused in new project?

	start_target_name: STRING
			-- Name of the target the build process starts with

feature -- Setting

	set_filename (a_filename: like filename) is
			-- Set `filename' to `a_filename'.
		require
			a_filename_not_void: a_filename /= Void
			a_filename_not_empty: a_filename.count > 0
			-- file_exists:
		do
			filename := a_filename
		ensure
			filename_set: filename = a_filename
		end

	set_reuse_variables(a_reuse_variables: BOOLEAN) is
			-- Set `reuse_variables' to a_reuse_variables
		do
			reuse_variables := a_reuse_variables
		ensure
			reuse_variables_set: reuse_variables = a_reuse_variables
		end

	set_start_target_name (a_start_target_name: like start_target_name) is
			-- Set `start_target_name' to `a_start_target_name'.
		require
			a_start_target_name_not_void: a_start_target_name /= Void
			a_start_target_name_not_empty: a_start_target_name.count > 0
			-- file_exists:
		do
			start_target_name := a_start_target_name
		ensure
			start_target_name_set: start_target_name = a_start_target_name
		end

feature -- Execution

	execute is
			-- Execute command.
		local
			a_project: GEANT_PROJECT
			a_variables: GEANT_VARIABLES
			a_target: GEANT_TARGET
			a_filename: STRING
			a_project_loader: GEANT_PROJECT_LOADER
		do
			exit_code := 0
			if is_filename_executable then
					-- Create a new project and run it's build process:
				if reuse_variables then
					a_variables := project.variables
				else
					create a_variables.make
				end
				a_filename := file_system.pathname_from_file_system (filename, unix_file_system)

				create a_project_loader.make (a_filename)
				a_project_loader.load (a_variables, project.options)
				a_project := a_project_loader.project_element.project
				a_project.merge_in_parent_projects

					-- Load build configuration:
				if start_target_name /= Void and then start_target_name.count > 0 then
					if not a_project.targets.has (start_target_name) then
						exit_application (1, <<"Project '", a_project.name,
							"' does not contain a target named `", start_target_name + "%'">>)
					end
						-- Check export status of target to be called:
					a_target := a_project.targets.item (start_target_name)
					if not (a_target.is_exported_to_any or else
						a_target.is_exported_to_project (project)) then
						exit_application (1, <<"target: `", a_target.full_name,
							"%' is not exported to project '", project.name, "'">>)
					end

					a_project.set_start_target_name (start_target_name)
				end
					-- Start build process:
				if exit_code = 0 then
					a_project.build
					if not a_project.build_successful then
						exit_code := 1
					end
				end
			else
				check target_executable: is_target_executable end

					-- call target of current project:
				if project.targets.has (start_target_name) then
					a_target := project.targets.item (start_target_name)
					a_target := a_target.final_target
					a_target.project.build_target (a_target)
				else
					project.log (<<"  [geant] error: unknown target: `", start_target_name, "%'">>)
					exit_code := 1
				end
			end
		end

end
