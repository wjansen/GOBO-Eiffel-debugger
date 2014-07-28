note

	description:

		"Pre and post processing of objects during activities of PC_DRIVER."

class PC_ACTIONABLE

feature {PC_BASE} -- Object modification and repair. 

	pre_store
		note
			action:
				"[
				 Modify `Current' to the contents that is to be stored.
				 Before modification, save `Current' using `preserve'.
				 
				 Default action: no operation.
				 
				 Caution: saving is based on `standard_copy'.
				 Thus, modification of an attributes's attribute will modify
				 the saved contents if the former is of a reference type,
				 i.e. those modifications should be avoided.
				 Caution: `Current' must satisfy the class invariant if modified.
				 ]"
		do
		end

	post_store
		note
			action:
				"[
				 Undo modifications of `Current' made by `pre_store'.
				 If `Current' has been saved by `preserve', simply call `restore'.
				 
				 Default action: no operation.
				 
				 Caution: `preserve' and `restore' are related to each other
				 by push/pop of a stack, thus, they must be called precisely
				 as many often.
				 ]"
		do
		end

	post_retrieve
		note
			action:
				"[
				 Repair incorrectness (such as POINTER values)
				 of `Current' just retrieved.
				 
				 Default action: no operation.
				 
				 Caution: all attributes are defined when the procedure is called
				 but, in case of cyclic dependency, they may have not yet
				 been retrieved or repaired completely.
				 Thus, the procedure should not rely on features of attributes.
				 ]"
		do
		end

feature {} -- Implementation 

	frozen backup_stack: ARRAYED_STACK [PC_ACTIONABLE]
		note
			return:
				"[
				 Auxiliary variable; must not be used by routines
				 other than the ones below. 
				 ]"
		once
			create Result.make (10)
		ensure
			not_void: attached Result
		end

	frozen preserve
		note
			action: "Save object contents before modification."
		do
			backup_stack.force (standard_twin)
		end

	frozen restore
		note
			action: "Restore object from saved contents."
		local
			stack: like backup_stack
		do
			stack := backup_stack
			if attached {attached like Current} stack.item as backup then
				standard_copy (backup)
			end
			stack.remove
		end

	frozen make_as_actionable
		note
			action:
				"[
				 Dummy initialization to make called features alive.
				 Routine must not be called explicitly, it is the compiler's job!
				 ]"
		do
			backup_stack.force (Current)
			pre_store
			post_store
			post_retrieve
		end

note

	author: "Wolfgang Jansen"
	date: "$Date: 2005/12/13 12:31:35 $"
	revision: "$Revision: 2.4 $"

end
