local Spring = {}
local SpringMT = {__index = Spring}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matrix = require(ReplicatedStorage:WaitForChild("Util",500):WaitForChild("Matrix3x3",500))
-- Because we're only simulating a single box and spring, we don't require kinetic points used for attatching two objects.

function SafeUnit(Vector)
	local Unit = Vector.Unit
	if Unit.X ~= Unit.X then -- Trying to get the unit of a vector with a magnitude of 0 results in NaN.
		return Vector3.new()
	else
		return Vector
	end
end

function Spring.New()
	local self = setmetatable({
		Stiffness = 0,
		RestLength = 0,
		
		Point = Vector3.new(),
		
		AttachmentOffset = Vector3.new()
	}, SpringMT)

	return self
end

function Spring:GetEndPoint(Shape)
	local RotationRadian = Shape.Rotation * math.rad(1)
	local RotationMatrix = Matrix.ToMatrix(RotationRadian.X, RotationRadian.Y, RotationRadian.Z)
	local Offset = Matrix.Transform(self.AttachmentOffset, RotationMatrix)
	return Shape.Position + Offset, Offset
end

function Spring:Solve(Shape)
	local EndPoint, Offset = self:GetEndPoint(Shape)
	local Direction = self.Point - EndPoint
	
	local UnitLength = SafeUnit(Direction)
	local SpringForce = self.Stiffness * (Direction.Magnitude - self.RestLength)
	local LinearForce = SpringForce * UnitLength

	local AngularForce = Offset:Cross(LinearForce)

	return LinearForce, AngularForce
end

return Spring