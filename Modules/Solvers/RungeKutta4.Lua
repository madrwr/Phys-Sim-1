local Solver = {}
local SolverMT = {__index = Solver}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matrix = require(ReplicatedStorage:WaitForChild("Util",500):WaitForChild("Matrix3x3",500))
local RungeKuttaStep = 1/6

function Solver.New()
	local self = setmetatable({
		Scene = nil,
		Iterations = 1
	}, SolverMT)

	return self
end

function Solver:SolveIteration(Delta)
	local Delta = Delta / self.Iterations
	for i = 0, self.Iterations - 1 do
		self:Solve(Delta)
	end
end

function Solver:Solve(Delta)
	local TimeScale = self.Scene.TimeScale
	Delta *= TimeScale
	
	for i = 0, self.Scene.Shapes.Count - 1 do
		local Box = self.Scene.Shapes.Memory[i]
		local State, Properties = Box:Broadcast()
		
		local Phase1 = self:CalculateChange(State, Properties, Box.Constraints)
		local Phase2 = self:CalculateChange(self:CalculateNext(State, Phase1, Delta * 0.5), Properties, Box.Constraints)
		local Phase3 = self:CalculateChange(self:CalculateNext(State, Phase2, Delta * 0.5), Properties, Box.Constraints)
		local Phase4 = self:CalculateChange(self:CalculateNext(State, Phase3, Delta), Properties, Box.Constraints)
		
		
		Box.Position += (Phase1.Position + 2*Phase2.Position + 2*Phase3.Position + Phase4.Position)*Delta*RungeKuttaStep
		Box.Rotation += (Phase1.Rotation + 2*Phase2.Rotation + 2*Phase3.Rotation + Phase4.Rotation)*Delta*RungeKuttaStep
		Box.LinearVelocity += (Phase1.LinearVelocity + 2*Phase2.LinearVelocity + 2*Phase3.LinearVelocity + Phase4.LinearVelocity)*Delta*RungeKuttaStep
		Box.AngularVelocity += (Phase1.AngularVelocity + 2*Phase2.AngularVelocity + 2*Phase3.AngularVelocity + Phase4.AngularVelocity)*Delta*RungeKuttaStep
	end
end

function Solver:CalculateChange(State, Properties, Constraints)
	local Change = {
		Position = Vector3.new(),
		Rotation = Vector3.new(),

		LinearVelocity = Vector3.new(),
		AngularVelocity = Vector3.new(),
	}
	
	-- Constraint force laws
	Change.Position = State.LinearVelocity
	Change.Rotation = State.AngularVelocity
	
	for i = 0, Constraints.Count-1 do
		local Constraint = Constraints.Memory[i]
		local LinearForce, AngularForce = Constraint:Solve(State)
		Change.LinearVelocity += LinearForce
		Change.AngularVelocity += AngularForce
	end
	
	-- Gravity force law
	local Gravity = self.Scene.Gravity
	Change.LinearVelocity += Gravity * Properties.Mass
	
	-- Damping force law
	local Damping = self.Scene.Damping
	Change.LinearVelocity += State.LinearVelocity * -Damping
	Change.AngularVelocity += State.AngularVelocity * -Damping
	
	Change.LinearVelocity *= Properties.I_Mass
	Change.AngularVelocity = Matrix.InertiaTensorIntegration(Change.AngularVelocity, Properties.I_Inertia)
	
	return Change
end

function Solver:CalculateNext(State, Change, Step)
	local Next = {
		Position = Vector3.new(),
		Rotation = Vector3.new(),

		LinearVelocity = Vector3.new(),
		AngularVelocity = Vector3.new(),
	}
	
	Next.Position = State.Position + Change.Position * Step
	Next.Rotation = State.Rotation + Change.Rotation * Step
	Next.LinearVelocity = State.LinearVelocity + Change.LinearVelocity * Step
	Next.AngularVelocity = State.AngularVelocity + Change.AngularVelocity * Step
	
	return Next
end

return Solver