note

	description: "Abstract class for traversal of a PC_TABLE."

deferred class PC_CURSOR [V_, K_]

inherit

	ITERATION_CURSOR [V_]

feature {NONE} -- Initalization

	make (t: like target)
		do
			target := t
		ensure
			target_set: target = t
		end
	
feature {NONE} -- Implementation

	target: PC_TABLE [V_ , K_]
	
end
