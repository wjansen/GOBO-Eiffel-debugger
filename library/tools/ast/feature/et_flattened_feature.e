indexing

	description:

		"Eiffel features being flattened"

	library:    "Gobo Eiffel Tools Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 2001, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date$"
	revision:   "$Revision$"

class ET_FLATTENED_FEATURE

creation

	make, make_inherited

feature {NONE} -- Initialization

	make (a_feature: like current_feature; a_class: like current_class) is
			-- Create a new flattened feature and set
			-- `current_feature' to `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
			name := a_feature.name
			current_feature := a_feature
			current_class := a_class
			!! inherited_features.make
			seeds := current_feature.seeds
		ensure
			current_feature_set: current_feature = a_feature
			current_class_set: current_class = a_class
		end

	make_inherited (a_feature: ET_INHERITED_FEATURE; a_class: like current_class) is
			-- Create a new flattened feature and add
			-- `a_feature' to `inherited_features'.
		require
			a_feature_not_void: a_feature /= Void
		do
			name := a_feature.name
			current_class := a_class
			!! inherited_features.make
			put_inherited_feature (a_feature)
		ensure
			current_class_set: current_class = a_class
		end

feature -- Access

	name: ET_FEATURE_NAME
			-- Feature name

	current_feature: ET_FEATURE
			-- Feature declared in current class

	inherited_features: DS_LINKED_LIST [ET_INHERITED_FEATURE]
			-- Features inherited from parents

	seeds: ET_FEATURE_SEEDS
			-- Seeds

	signature: ET_SIGNATURE
			-- Signature of flattened feature;
			-- Void if not yet computed

	current_class: ET_CLASS
			-- Class where current feature is flattened

	flattened_feature: ET_FEATURE
			-- Feature resulting from current feature adaptation;
			-- Void if not computed yet or if an error occurred
			-- during compilation

	integer_constant: ET_INTEGER_CONSTANT is
			-- Constant value if current feature is an
			-- integer constant attribute, void otherwise
		local
			a_constant_attribute: ET_CONSTANT_ATTRIBUTE
			a_cursor: DS_LINKED_LIST_CURSOR [ET_INHERITED_FEATURE]
		do
			a_constant_attribute ?= current_feature
			if a_constant_attribute /= Void then
				Result ?= a_constant_attribute.constant
			end
			if Result = Void then
				a_cursor := inherited_features.new_cursor
				from a_cursor.start until a_cursor.after loop
					a_constant_attribute ?= a_cursor.item.inherited_feature
					if a_constant_attribute /= Void then
						Result ?= a_constant_attribute.constant
					end
					if Result /= Void then
						a_cursor.go_after -- Jump out of the loop.
					else
						a_cursor.forth
					end
				end
			end
		end

feature -- Status report

	is_selected: BOOLEAN
			-- Has an inherited feature been selected?

	is_replicated: BOOLEAN
			-- Has current feature been replicated?

	is_inherited: BOOLEAN is
			-- Is current feature inherited from a parent?
		do
			Result := not inherited_features.is_empty
		ensure
			definition: Result = not inherited_features.is_empty
		end

feature -- Status setting

	set_replicated (a_seed: INTEGER) is
			-- Set `is_replicated' to true.
			-- `a_seed' is the seed which needs replication.
		require
			has_seed: seeds.has (a_seed)
		local
			need_twin: BOOLEAN
		do
			is_replicated := True
			feature_id := current_class.universe.next_feature_id
			need_twin := (seeds = inherited_features.first.inherited_feature.seeds)
			if need_twin then
				seeds := clone (seeds)
			end
			seeds.replace (a_seed, feature_id)
		ensure
			is_replicated: is_replicated
		end

feature -- Element change

	put_inherited_feature (a_feature: ET_INHERITED_FEATURE) is
			-- Add `a_feature' to `inherited_features'.
		require
			a_feature_not_void: a_feature /= Void
			same_name: a_feature.name.same_feature_name (name)
		local
			other_seeds: like seeds
			a_seed: INTEGER
			i, nb: INTEGER
			need_twin: BOOLEAN
		do
			if inherited_features.is_empty then
				seeds := a_feature.inherited_feature.seeds
			else
				need_twin := (seeds = inherited_features.first.inherited_feature.seeds)
				other_seeds := a_feature.inherited_feature.seeds
				nb := other_seeds.count
				from i := 1 until i > nb loop
					a_seed := other_seeds.item (i)
					if not seeds.has (a_seed) then
						if need_twin then
							seeds := clone (seeds)
							need_twin := False
						end
						seeds.put (a_seed)
					end
					i := i + 1
				end
			end
			inherited_features.put_last (a_feature)
			if a_feature.is_selected then
				if is_selected then
						-- Error: two selected features.
				end
				is_selected := True
			end
		end

feature -- Compilation

	process_flattened_feature (a_flattener: ET_FEATURE_FLATTENER) is
			-- Process current feature adaptation and
			-- put the result in `flattened_feature'.
		require
			a_flattener_not_void: a_flattener /= Void
		do
			if inherited_features.is_empty then
				process_immediate_feature (a_flattener)
			elseif current_feature = Void then
				process_inherited_feature (a_flattener)
			else
				process_redeclared_feature (a_flattener)
			end
		end

feature {NONE} -- Compilation

	process_immediate_feature (a_flattener: ET_FEATURE_FLATTENER) is
			-- Process feature that aas been introduced
			-- in `current_class' (ETL2, p. 56).
		require
			immediate_feature: inherited_features.is_empty
			a_flattener_not_void: a_flattener /= Void
		do
			current_feature.resolve_identifier_types (a_flattener)
			flattened_feature := current_feature
			signature := current_feature.signature
		end

	process_redeclared_feature (a_flattener: ET_FEATURE_FLATTENER) is
			-- Process an inherited feature which has been
			-- given a new declaration in `current_class'.
		require
			inherited_feature: not inherited_features.is_empty
			redeclared_feature: current_feature /= Void
			a_flattener_not_void: a_flattener /= Void
		local
			a_feature: ET_INHERITED_FEATURE
			is_deferred, has_redefined: BOOLEAN
		do
			current_feature.resolve_identifier_types (a_flattener)
			flattened_feature := current_feature
			flattened_feature.set_seeds (seeds)
			signature := current_feature.signature
				-- Check redeclaration.
			from inherited_features.start until inherited_features.after loop
				a_feature := inherited_features.item_for_iteration
				a_feature.check_undefine_clause (current_class)
				a_feature.check_redefine_clause (current_class)
				if a_feature.is_redefined then
					if has_redefined then
						-- Warning: two redefines.
					end
					has_redefined := True
				end
				inherited_features.forth
			end
			is_deferred := current_feature.is_deferred
			from inherited_features.start until inherited_features.after loop
				a_feature := inherited_features.item_for_iteration
				if a_feature.is_redefined then
					if is_deferred /= a_feature.is_deferred then
						if is_deferred then
							-- Error: Used 'redefine' instead of 'undefine'.
							-- Need to use 'undefine' to redeclare an
							-- effective feature to a deferred feature.
						else
							-- Error: No need to 'redefine' to redeclare
							-- a deferred feature to an effective feature.
						end
					end
				elseif is_deferred then
					if a_feature.is_deferred then
						if not has_redefined then
							-- Error: Need 'redefine' to redeclare a
							-- deferred feature to a deferred feature.
						end
					else
						-- Error: need 'undefine' to redeclare an
						-- effective feature to a deferred feature.
					end
				elseif not a_feature.is_deferred then
					-- Error: need 'redefine' to redeclare an effective
					-- feature to an effective feature.
				end
				inherited_features.forth
			end
		end

	process_inherited_feature (a_flattener: ET_FEATURE_FLATTENER) is
			-- Process an inherited feature which has not been
			-- given a new declaration in `current_class'.
		require
			inherited_feature: current_feature = Void
			a_flattener_not_void: a_flattener /= Void
		local
			a_feature, effective, a_deferred: ET_INHERITED_FEATURE
			same_version, duplication_needed: BOOLEAN
		do
				-- Check redeclaration.
			from inherited_features.start until inherited_features.after loop
				a_feature := inherited_features.item_for_iteration
				a_feature.check_undefine_clause (current_class)
				a_feature.check_redefine_clause (current_class)
				if a_feature.is_redefined then
					-- Error: Not a redefinition.
				end
				if not a_feature.is_deferred then
					if effective = Void then
						effective := a_feature
					else
						if not a_feature.same_version (effective) then
								-- Error: two effective features which
								-- are not shared.
						end
						if effective.is_renamed then
								-- Trying to choose one which is not renamed
								-- to avoid duplication.
							effective := a_feature
						end
					end
				end
				inherited_features.forth
			end
			if effective /= Void then
				from inherited_features.start until inherited_features.after loop
					a_feature := inherited_features.item_for_iteration
					if a_feature.is_deferred then
						duplication_needed := False
						-- TODO
					end
					inherited_features.forth
				end
				a_feature := effective
				same_version := True
			else
				same_version := True
				from inherited_features.start until inherited_features.after loop
					a_feature := inherited_features.item_for_iteration
					if a_deferred = Void then
						a_deferred := a_feature
					elseif a_feature.same_version (a_deferred) then
							-- Sharing.
						if a_deferred.is_renamed then
								-- Trying to choose one which is not renamed
								-- to avoid duplication.
							a_deferred := a_feature
						end
					elseif a_feature.same_syntactical_signature (a_deferred) then
						same_version := False
						if a_deferred.is_renamed then
								-- Trying to choose one which is not renamed
								-- to avoid duplication.
							a_deferred := a_feature
						end
					else
						same_version := False
print ("PROBLEM with DEFERRED%N")
						-- TODO
					end
					inherited_features.forth
				end
				a_feature := a_deferred
				duplication_needed := not same_version
			end
			if is_replicated then
				flattened_feature := a_feature.replicated_feature (feature_id, current_class)
			else
				if not duplication_needed then
						-- Force duplication when there is a
						-- sharing of features but the seeds
						-- have been extended.
					duplication_needed := not a_feature.seeds.is_equal (seeds)
				end
				flattened_feature := a_feature.adapted_feature (duplication_needed, current_class)
				if same_version then
					flattened_feature.set_version (a_feature.inherited_feature.version)
				end
			end
			flattened_feature.set_seeds (seeds)
			signature := a_feature.signature
		end

feature {ET_REPLICABLE_FEATURE} -- Replication

	feature_id: INTEGER
			-- New feature ID when feature is replicated
--		require
--			is_replicated: is_replicated
--		ensure
--			id_positive: Result >= 0

invariant

	inherited_features_not_void: inherited_features /= Void
	no_void_inherited_feature: not inherited_features.has (Void)
	at_least_one: current_feature /= Void or else not inherited_features.is_empty
	current_class_not_void: current_class /= Void
	seeds_not_void: seeds /= Void

end -- class ET_FLATTENED_FEATURE
