local IdPool = {}
local IdPoolMT = {__index = IdPool}

function IdPool.New(InitialCapacity)
	local self = setmetatable({
		NextIndex = 0,
		AvailableIdCount = 0,
		Capacity = 0,
		AvailableIds = 0
	}, IdPoolMT)

	self:InternalResize(InitialCapacity)

	return self
end

function IdPool:Take()
	if self.AvailableIdCount > 0 then
		self.AvailableIdCount -= 1
		return self.AvailableIds[self.AvailableIdCount]
	end
	local Index = self.NextIndex
	self.NextIndex += 1
	return self.Capacity+Index
end

function IdPool:Return(Id)
	if self.AvailableIdCount == self.Capacity then
		self:InternalResize(math.floor(self.AvailableIdCount * 2) + 1)
	end
	self:ReturnUnsafely(Id)
end

function IdPool:ReturnUnsafely(Id)
	self.AvailableIds[self.AvailableIdCount] = Id
	self.AvailableIdCount += 1
end

function IdPool:Clear()
	self.NextIndex = 0
	self.AvailableIdCount = 0
end

function IdPool:InternalResize(NewSize)
	self.NextIndex -= NewSize - self.Capacity
	self.Capacity = NewSize
	for i = self.Capacity, NewSize - 1 do
		self.AvailableIds[i] = i
	end 
end

return IdPool