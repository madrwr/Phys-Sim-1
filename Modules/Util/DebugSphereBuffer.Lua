local CyclePool = {}
CyclePool.__index = CyclePool

function CyclePool.New()
	local self = setmetatable({}, CyclePool)
	
	self.Pool = {}
	self.Count = 0
	self.Next = 0
	self.Previous = 0
	
	return self
end

function CyclePool:Add(Item)
	self.Pool[self.Count] = Item
	self.Count += 1
	return self.Count - 1
end

function CyclePool:Remove(Index)
	self.Count -= 1
	if Index < self.Count then
		self.Pool[Index] = self.Pool[self.Count]
		self.Pool[self.Count] = nil
	else
		self.Pool[Index] = nil
	end
end

function CyclePool:Take()
	if self.Count > 1 then
		local Next = self.Pool[self.Next]
		self.Previous = self.Next
		self.Next += 1
		if self.Next >= self.Count  then
			self.Next = 0
		end
		return Next
	else
		return self.Pool[self.Count - 1]
	end
end

function CyclePool:TakePrevious()
	return self.Pool[self.Previous]
end

function CyclePool:ForEach(Function)
	for i = 0, self.Count - 1 do
		Function(self.Pool[i], i)
	end
end

function CyclePool:Clear()
	self.Pool = {}
	self.Count = 0
	self.Next = 0
	self.Previous = 0
end




local DebugSphereBuffer = {}
DebugSphereBuffer.__index = DebugSphereBuffer

function DebugSphereBuffer.New(InitialSize, DisplaySize)
	local self = setmetatable({}, DebugSphereBuffer)
	
	self.DisplaySize = DisplaySize or 0.75
	self.Size = 0
	self.Pool = CyclePool.New()
	self.Spheres = {}
	
	if InitialSize > 0 then
		self:Resize(InitialSize)
	end
	
	return self
end

function DebugSphereBuffer:CreateSphere()
	local Ball = Instance.new("Part")
	Ball.Shape = Enum.PartType.Ball
	Ball.CanCollide = false
	Ball.Anchored = true
	Ball.Name = "DisplaySphere"
	Ball.Size = Vector3.one * self.DisplaySize
	Ball.Locked = true
	
	local Highlight = Instance.new("Highlight")
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.FillColor = Color3.new(1,0,0)
	Highlight.FillTransparency = 0
	Highlight.OutlineColor = Color3.new(1,1,1)
	Highlight.OutlineTransparency = 0
	Highlight.Adornee = Ball
	Highlight.Parent = Ball
	
	Ball.Parent = workspace
	
	return Ball
end

function DebugSphereBuffer:Resize(NewSize)
	self.Pool:Clear()
	
	for i = 0, NewSize - 1 do
		local Ball = self:CreateSphere()
		local Index = self.Pool:Add(Ball)
		self.Spheres[Index] = Ball
	end
	
	self.Size = NewSize
end

function DebugSphereBuffer:Update(Position)
	local PreviousBall = self.Pool:TakePrevious()
	local Ball = self.Pool:Take()
	
	PreviousBall.Highlight.FillColor = Color3.new(1,0,0)
	Ball.Highlight.FillColor = Color3.new(0,1,0)
	
	Ball.Position = Position
end

return DebugSphereBuffer