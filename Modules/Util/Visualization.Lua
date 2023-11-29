local Visualization = {}
local VisualizationMT = {__index = Visualization}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Set = require(ReplicatedStorage:WaitForChild("Util",500):WaitForChild("Set",500))
local Matrix = require(ReplicatedStorage:WaitForChild("Util",500):WaitForChild("Matrix3x3",500))
local DebugSphereBuffer = require(ReplicatedStorage:WaitForChild("Util",500):WaitForChild("DebugSphereBuffer",500))
local DebugLineBuffer = require(ReplicatedStorage:WaitForChild("Util",500):WaitForChild("DebugLineBuffer",500))

function Visualization.New()
	local self = setmetatable({
		Objects = Set.New(),
		SphereBuffer = DebugSphereBuffer.New(2, 0.6),
		LineBuffer = DebugLineBuffer.New(1, 0.3)
	}, VisualizationMT)
	
	return self
end

function Visualization:ResizeBuffer(Scene)	
	local ConstraintCount = 0
	for i = 0, self.Objects.Count - 1 do
		local Shape = Scene.Shapes.Memory[self.Objects.IndexToHandle[i]]
		ConstraintCount += Shape.Constraints.Count
	end
	
	self.LineBuffer:Resize(ConstraintCount)
	self.SphereBuffer:Resize(ConstraintCount * 2)
end

function Visualization:AddShape(Handle)
	local Part = Instance.new("Part")
	Part.Anchored = true
	Part.CanCollide = false
	Part.Parent = workspace
	
	self.Objects:Add(Part, Handle)
end

function Visualization:Render(Scene)
	for i = 0, self.Objects.Count - 1 do
		local Part = self.Objects.Memory[i]
		local Handle = self.Objects.IndexToHandle[i]
		local Shape = Scene.Shapes.Memory[self.Objects.IndexToHandle[i]]
		local Rotation = Shape.Rotation * math.rad(1)
		local RotationMatrix = Matrix.ToMatrix(Rotation.X, Rotation.Y, Rotation.Z)
		Part.CFrame = Matrix.ToCFrame(Shape.Position, RotationMatrix)
		Part.Size = Shape.Size
		
		local Constraints = Shape.Constraints
		for i = 0, Constraints.Count-1 do
			local Constraint = Constraints.Memory[i]
			local End = Constraint:GetEndPoint(Shape)
			local Point = Constraint.Point
			self.SphereBuffer:Update(End)
			self.SphereBuffer:Update(Point)
			self.LineBuffer:Update(End, Point)
		end
	end
end

return Visualization