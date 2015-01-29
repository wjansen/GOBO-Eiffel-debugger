note

	description: ""

deferred class PC_SERIAL_BASE

inherit

	PC_BASE

feature

	common (obj: detachable ANY): TUPLE [top: detachable ANY]
		once
			Result := [obj]
		end
	
end
