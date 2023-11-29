local Scene = {}
local SceneMT = {__index = Scene}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Set = require(ReplicatedStorage:WaitForChild("Util",500):WaitForChild("Set",500))
local IdPool = require(ReplicatedStorage:WaitForChild("Util",500):WaitForChild("IdPool",500))

--[[ Thoughts
***	There isn't going to be any crazy systems and code for collision detection, or collision response
	since this was built as a chemistry project. Although, I'll probably make it so I can add mutliple
	mass bodies and constraints in order to show multiple thingies simultaniously.

***	I really wish ROBLOX would actually doccument their rotations, took me two whole days to figure out
	the nitty gritty details needed in order for me to actually do anything with rotations.
	
***	It was quite the headache planning and settling on a caching method. There are unlimited ways to do
	this, but each one had their pros and cons. I needed something traversable and easily loopable, so
	I went with the "handle route," where I give each element its own unique id, and pop it into a contained
	cache. Was I overthinking this for a simple chemistry project? Yeah. Is this overly convoluted? Yup,
	but I wouldn't want it any other way.
]]

function Scene.New()
	local self = setmetatable({
		Shapes = Set.New(),
		IdPool = IdPool.New(12),
		
		Gravity = Vector3.new(),
		Damping = 0,
		TimeScale = 1,
	}, SceneMT)
	
	return self
end

function Scene:AddShape(Shape)
	local Handle = self.IdPool:Take()
	self.Shapes:Add(Shape, Handle)
	return Handle
end

function Scene:RemoveShape(Handle)
	self.Shapes:RemoveAt(Handle)
	self.IdPool:Return(Handle)
end

function Scene:AddConstraint(Constraint, ShapeHandle)
	local ConstraintHandle = self.IdPool:Take()
	local Shape = self.Shapes.Memory[self.Shapes.HandleToIndex[ShapeHandle]]
	Shape.Constraints:Add(Constraint, ConstraintHandle)
	return ConstraintHandle
end

function Scene:RemoveConstraint(ShapeHandle, ConstraintHandle)
	local Shape = self.Shapes.Memory[self.Shapes.HandleToIndex[ShapeHandle]]
	Shape.Constraints:RemoveAt(ConstraintHandle)
	self.IdPool:Return(ConstraintHandle)
end

return Scene