local Set = {}
local SetMT = {__index = Set}

function Set.New()
	return setmetatable({
		Memory = {},
		HandleToIndex = {},
		IndexToHandle = {},
		Count = 0
	}, SetMT)
end

function Set:Add(Thing, Handle)
	local Index = self.Count
	self.Count += 1
	self.Memory[Index] = Thing
	self.HandleToIndex[Handle] = Index
	self.IndexToHandle[Index] = Handle
	return Index
end

function Set:RemoveAt(Handle)
	local Index = self.HandleToIndex[Handle]
	self.Count -= 1
	if Index < self.Count then
		local MovedIndex = self.Count
		self.Memory[Index] = self.Memory[MovedIndex]
		local MovedBodyHandle = self.IndexToHandle[self.Count]
		self.IndexToHandle[Index] = MovedBodyHandle
		return true, MovedIndex
	end
	return false, -1
end

return Set