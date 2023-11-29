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




local DebugLineBuffer = {}
DebugLineBuffer.__index = DebugLineBuffer

function DebugLineBuffer.New(InitialSize, DisplayThickness)
	local self = setmetatable({}, DebugLineBuffer)

	self.DisplayThickness = DisplayThickness or 0.75
	self.Size = 0
	self.Pool = CyclePool.New()
	self.Lines = {}

	if InitialSize > 0 then
		self:Resize(InitialSize)
	end

	return self
end

function DebugLineBuffer:CreateSphere()
	local Line = Instance.new("Part")
	Line.CanCollide = false
	Line.Anchored = true
	Line.Name = "DisplaySphere"
	Line.Size = Vector3.new(self.DisplayThickness, 0, self.DisplayThickness)
	Line.Locked = true

	local Highlight = Instance.new("Highlight")
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.FillColor = Color3.new(1,0,0)
	Highlight.FillTransparency = 0
	Highlight.OutlineColor = Color3.new(1,1,1)
	Highlight.OutlineTransparency = 0
	Highlight.Adornee = Line
	Highlight.Parent = Line

	Line.Parent = workspace

	return Line
end

function DebugLineBuffer:Resize(InitialSize)
	self.Pool:Clear()

	for i = 0, InitialSize - 1 do
		local Line = self:CreateSphere()
		local Index = self.Pool:Add(Line)
		self.Lines[Index] = Line
	end

	self.Size = InitialSize
end

function DebugLineBuffer:Update(PointA, PointB)
	local PreviousBall = self.Pool:TakePrevious()
	local Line = self.Pool:Take()

	PreviousBall.Highlight.FillColor = Color3.new(1,0,0)
	Line.Highlight.FillColor = Color3.new(0,1,0)
	
	local Cframe = CFrame.lookAt(PointA, PointB) * CFrame.Angles(math.rad(-90), 0, 0)
	local Distance = (PointA-PointB).Magnitude
	Line.CFrame = Cframe + Cframe.UpVector * Distance * 0.5
	Line.Size = Vector3.new(self.DisplayThickness, Distance, self.DisplayThickness)
end

return DebugLineBuffer