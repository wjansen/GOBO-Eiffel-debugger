indexing

	description:

		"Eiffel class interface checkers"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2003, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_INTERFACE_CHECKER

inherit

	ET_CLASS_PROCESSOR
		redefine
			make
		end

creation

	make

feature {NONE} -- Initialization

	make (a_universe: like universe) is
			-- Create a new interface checker for classes in `a_universe'.
		do
			precursor (a_universe)
			create parent_context.make (a_universe.any_class, a_universe.any_class)
		end

feature -- Access

	degree: STRING is "4.4"
			-- ISE's style degree of current processor

feature -- Processing

	process_class (a_class: ET_CLASS) is
		local
			a_processor: like Current
		do
			if a_class = none_class then
				a_class.set_interface_checked
			elseif current_class /= unknown_class then
					-- TODO: Internal error (recursive call)
print ("INTERNAL ERROR%N")
				create a_processor.make (universe)
				a_processor.process_class (a_class)
			elseif a_class /= unknown_class then
				internal_process_class (a_class)
			else
				set_fatal_error (a_class)
			end
		ensure then
			interface_checked: a_class.interface_checked
		end

feature -- Error handling

	set_fatal_error (a_class: ET_CLASS) is
			-- Report a fatal error to `a_class'.
		do
			a_class.set_interface_checked
			a_class.set_interface_error
		ensure then
			interface_checked: a_class.interface_checked
			has_interface_error: a_class.has_interface_error
		end

feature {NONE} -- Processing

	internal_process_class (a_class: ET_CLASS) is
		require
			a_class_not_void: a_class /= Void
		local
			old_class: ET_CLASS
			a_parents: ET_PARENT_LIST
			a_parent_class: ET_CLASS
			i, nb: INTEGER
		do
			old_class := current_class
			current_class := a_class
			if not current_class.interface_checked then
					-- Resolve qualified anchored types in signatures of features
					-- of `current_class' if not already done.
				current_class.process (universe.qualified_signature_resolver)
				if not current_class.has_qualified_signatures_error then
					current_class.set_interface_checked
						-- Process parents first.
					a_parents := current_class.parents
					if a_parents = Void or else a_parents.is_empty then
						if current_class = universe.general_class then
							a_parents := Void
						elseif current_class = universe.any_class then
								-- ISE Eiffel has no GENERAL class anymore.
								-- Use ANY has class root now.
							a_parents := Void
						else
							a_parents := universe.any_parents
						end
					end
					if a_parents /= Void then
						nb := a_parents.count
						from i := 1 until i > nb loop
								-- This is a controlled recursive call to `internal_process_class'.
							a_parent_class := a_parents.parent (i).type.direct_base_class (universe)
							internal_process_class (a_parent_class)
							if a_parent_class.has_interface_error then
								set_fatal_error (current_class)
							end
							i := i + 1
						end
					end
					if not current_class.has_interface_error then
						error_handler.report_compilation_status (Current)
							-- Check validity rules of the parents and of formal
							-- generic parameters of `current_class'.
						--check_formal_parameters_validity
						--check_parents_validity
					end
					if not current_class.has_interface_error then
						check_signatures_validity
					end
				else
					set_fatal_error (current_class)
				end
			end
			current_class := old_class
		ensure
			interface_checked: a_class.interface_checked
		end

feature {NONE} -- Signature validity

	check_signatures_validity is
			-- Check validity of redeclarations and joinings for all
			-- feature signatures of `current_class' which could not
			-- be checked before in the feature flattener because
			-- of the presence of some qualified anchired types.
		local
			a_features: ET_FEATURE_LIST
			a_feature: ET_ADAPTED_FEATURE
			i, nb: INTEGER
		do
			a_features := current_class.features
			nb := a_features.count
			from i := 1 until i > nb loop
				a_feature ?= a_features.item (i)
				if a_feature /= Void then
						-- The signature of this feature needs to be checked
						-- again. It probably contains a qualified anchored type.
					check_signature_validity (a_feature)
					a_features.put (a_feature.flattened_feature, i)
				end
				i := i + 1
			end
		end

	check_signature_validity (a_feature: ET_ADAPTED_FEATURE) is
			-- Check signature validity for redeclarations and joinings.
		require
			a_feature_not_void: a_feature /= Void
		local
			a_flattened_feature: ET_FLATTENED_FEATURE
			an_inherited_flattened_feature: ET_FEATURE
			a_redeclared_feature: ET_REDECLARED_FEATURE
			an_inherited_feature: ET_FEATURE
		do
			if a_feature.is_redeclared then
					-- Redeclaration.
				a_redeclared_feature := a_feature.redeclared_feature
				a_flattened_feature := a_feature.flattened_feature
				from
					an_inherited_feature := a_redeclared_feature.parent_feature
				until
					an_inherited_feature = Void
				loop
					check_redeclared_signature_validity (a_flattened_feature, an_inherited_feature)
					an_inherited_feature := an_inherited_feature.merged_feature
				end
			elseif a_feature.is_inherited then
				a_flattened_feature := a_feature.flattened_feature
				an_inherited_flattened_feature := a_feature.inherited_feature.inherited_flattened_feature
				if a_flattened_feature.is_deferred then
						-- Joining (merging deferred features together).
					from
						an_inherited_feature := a_feature
					until
						an_inherited_feature = Void
					loop
						if not an_inherited_feature.same_version (an_inherited_flattened_feature.precursor_feature) then
							check_joined_signature_validity (an_inherited_flattened_feature, an_inherited_feature)
						end
						an_inherited_feature := an_inherited_feature.merged_feature
					end
				else
						-- Redeclaration (merging deferred features into
						-- an effective one).
					from
						an_inherited_feature := a_feature
					until
						an_inherited_feature = Void
					loop
						if an_inherited_feature.is_deferred then
							check_merged_signature_validity (a_feature, an_inherited_feature)
						end
						an_inherited_feature := an_inherited_feature.merged_feature
					end
				end
			end
		end

	check_redeclared_signature_validity (a_feature: ET_FLATTENED_FEATURE; other: ET_FEATURE) is
			-- Check whether the signature of `a_feature' conforms
			-- to the signature of `other'. This check has to be done
			-- when `a_feature' is a redeclaration in `current_class'
			-- of the inherited feature `other'.
		require
			a_feature_not_void: a_feature /= Void
			other_not_void: other /= Void
			other_inherited: other.is_inherited
			other_not_redeclared: not other.is_redeclared
		local
			a_type: ET_TYPE
			other_type: ET_TYPE
			other_precursor: ET_FLATTENED_FEATURE
			an_arguments: ET_FORMAL_ARGUMENT_LIST
			other_arguments: ET_FORMAL_ARGUMENT_LIST
			i, nb: INTEGER
		do
			a_type := a_feature.type
			parent_context.set (other.parent.type, current_class)
			other_precursor := other.precursor_feature
			other_type := other_precursor.type
			if a_type /= Void and other_type /= Void then
				if not a_type.conforms_to_type (other_type, parent_context, current_class, universe) then
					set_fatal_error (current_class)
					error_handler.report_vdrd2a_error (current_class, a_feature, other.inherited_feature)
				end
			else
				-- This case has already been handled in the feature flattener.
			end
			an_arguments := a_feature.arguments
			other_arguments := other_precursor.arguments
			if an_arguments /= Void and other_arguments /= Void then
				nb := an_arguments.count
				if other_arguments.count = nb then
					from i := 1 until i > nb loop
						a_type := an_arguments.formal_argument (i).type
						other_type := other_arguments.formal_argument (i).type
						if not a_type.conforms_to_type (other_type, parent_context, current_class, universe) then
							set_fatal_error (current_class)
							error_handler.report_vdrd2a_error (current_class, a_feature, other.inherited_feature)
						end
						i := i + 1
					end
				else
					-- This case has already been handled in the feature flattener.
				end
			else
				-- This case has already been handled in the feature flattener.
			end
		end

	check_merged_signature_validity (a_feature, other: ET_FEATURE) is
			-- Check whether the signature of `a_feature' conforms
			-- to the signature of `other'. This check has to be done
			-- when the inherited deferred feature `other' is merged
			-- to the other inherted feature `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
			a_feature_inherited: a_feature.is_inherited
			a_feature_flattened: not a_feature.is_redeclared
			other_not_void: other /= Void
			other_inherited: other.is_inherited
			other_not_redeclared: not other.is_redeclared
			other_deferred: other.is_deferred
		local
			a_type: ET_TYPE
			other_type: ET_TYPE
			a_flattened_feature: ET_FLATTENED_FEATURE
			an_inherited_feature: ET_INHERITED_FEATURE
			other_precursor: ET_FLATTENED_FEATURE
			an_arguments: ET_FORMAL_ARGUMENT_LIST
			other_arguments: ET_FORMAL_ARGUMENT_LIST
			i, nb: INTEGER
		do
			a_flattened_feature := a_feature.flattened_feature
			a_type := a_flattened_feature.type
			parent_context.set (other.parent.type, current_class)
			other_precursor := other.precursor_feature
			other_type := other_precursor.type
			if a_type /= Void and other_type /= Void then
				if not a_type.conforms_to_type (other_type, parent_context, current_class, universe) then
					set_fatal_error (current_class)
					an_inherited_feature := a_feature.inherited_feature.inherited_flattened_feature.inherited_feature
					error_handler.report_vdrd2b_error (current_class, an_inherited_feature, other.inherited_feature)
				end
			else
				-- This case has already been handled in the feature flattener.
			end
			an_arguments := a_flattened_feature.arguments
			other_arguments := other_precursor.arguments
			if an_arguments /= Void and other_arguments /= Void then
				nb := an_arguments.count
				if other_arguments.count = nb then
					from i := 1 until i > nb loop
						a_type := an_arguments.formal_argument (i).type
						other_type := other_arguments.formal_argument (i).type
						if not a_type.conforms_to_type (other_type, parent_context, current_class, universe) then
							set_fatal_error (current_class)
							an_inherited_feature := a_feature.inherited_feature.inherited_flattened_feature.inherited_feature
							error_handler.report_vdrd2b_error (current_class, an_inherited_feature, other.inherited_feature)
						end
						i := i + 1
					end
				else
					-- This case has already been handled in the feature flattener.
				end
			else
				-- This case has already been handled in the feature flattener.
			end
		end

	check_joined_signature_validity (a_feature, other: ET_FEATURE) is
			-- Check that `a_feature' and `other' have the same signature
			-- when viewed from `current_class'. This check has to be done
			-- when joining two or more deferred features, the `a_feature'
			-- being the result of the join in `current_class' and `other'
			-- being one of the other deferred features inherited from a
			-- parent of `current_class'. (See ETL2 page 165 about Joining.)
		require
			a_feature_not_void: a_feature /= Void
			a_feature_inherited: a_feature.is_inherited
			a_feature_not_redeclared: not a_feature.is_redeclared
			other_not_void: other /= Void
			other_inherited: other.is_inherited
			other_not_redeclared: not other.is_redeclared
		local
			a_joined_feature: ET_FLATTENED_FEATURE
			other_precursor: ET_FLATTENED_FEATURE
			an_arguments, other_arguments: ET_FORMAL_ARGUMENT_LIST
			a_type, other_type: ET_TYPE
			i, nb: INTEGER
		do
			a_joined_feature := a_feature.flattened_feature
			a_type := a_joined_feature.type
			other_precursor := other.precursor_feature
			other_type := other_precursor.type
			parent_context.set (other.parent.type, current_class)
			if a_type /= Void and other_type /= Void then
				if not a_type.same_syntactical_type (other_type, parent_context, current_class, universe) then
					set_fatal_error (current_class)
					error_handler.report_vdjr0c_error (current_class, a_feature.inherited_feature, other.inherited_feature)
				end
			else
				-- This case has already been handled in the feature flattener.
			end
			an_arguments := a_joined_feature.arguments
			other_arguments := other_precursor.arguments
			if an_arguments /= Void and other_arguments /= Void then
				nb := an_arguments.count
				if other_arguments.count = nb then
					from i := 1 until i > nb loop
						if not an_arguments.formal_argument (i).type.same_syntactical_type (other_arguments.formal_argument (i).type, parent_context, current_class, universe) then
							set_fatal_error (current_class)
							error_handler.report_vdjr0b_error (current_class, a_feature.inherited_feature, other.inherited_feature, i)
						end
						i := i + 1
					end
				else
					-- This case has already been handled in the feature flattener.
				end
			else
				-- This case has already been handled in the feature flattener.
			end
		end

	parent_context: ET_NESTED_TYPE_CONTEXT
			-- Parent context for type conformance checking

invariant

	parent_context_not_void: parent_context /= Void

end
