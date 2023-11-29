local Box = {}
local BoxMT = {__index = Box}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Set = require(ReplicatedStorage:WaitForChild("Util",500):WaitForChild("Set",500))

function Box.New()
	local self = setmetatable({
		Position = Vector3.new(),
		Rotation = Vector3.new(),
		
		LinearVelocity = Vector3.new(),
		AngularVelocity = Vector3.new(),
		
		Size = Vector3.new(),
		
		Mass = 0,
		Inertia = Vector3.new(),
		I_Mass = 0, -- Inverse Mass
		I_Inertia = Vector3.new(), -- Inverse Inertia,
		
		Constraints = Set.New()
	}, BoxMT)

	return self
end

function Box:SetMass(Mass)
	local Size = self.Size
	self.Mass = Mass
	self.I_Mass = 1 / Mass
	
	
	
	local InertiaX = (1/12) * Mass * (Size.Y*Size.Y + Size.Z*Size.Z)
	local InertiaY = (1/12) * Mass * (Size.X*Size.X + Size.Z*Size.Z)
	local InertiaZ = (1/12) * Mass * (Size.X*Size.X + Size.Y*Size.Y)
	self.Inertia = {
		M11 = InertiaX, M12 = 0, M13 = 0,
		M21 = 0, M22 = InertiaY, M23 = 0,
		M31 = 0, M32 = 0, M33 = InertiaZ
	}
	self.I_Inertia = {
		M11 = 1 / InertiaX, M12 = 0, M13 = 0,
		M21 = 0, M22 = 1 / InertiaY, M23 = 0,
		M31 = 0, M32 = 0, M33 = 1 / InertiaZ
	}
end

function Box:Broadcast()
	return {
		Position = self.Position,
		Rotation = self.Rotation,
		
		LinearVelocity = self.LinearVelocity,
		AngularVelocity = self.AngularVelocity,
	}, {
		Mass = self.Mass,
		Inertia = self.Inertia,
		I_Mass = self.I_Mass,
		I_Inertia = self.I_Inertia
	}
end

return Box