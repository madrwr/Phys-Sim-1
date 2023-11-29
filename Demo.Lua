local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Visualization = require(ReplicatedStorage:WaitForChild("Util",500):WaitForChild("Visualization",500))
local Scene = require(ReplicatedStorage:WaitForChild("Scene",500))
local Euler = require(ReplicatedStorage:WaitForChild("Solvers",500):WaitForChild("Euler",500))
local RungeKutta4 = require(ReplicatedStorage:WaitForChild("Solvers",500):WaitForChild("RungeKutta4",500))
local Box = require(ReplicatedStorage:WaitForChild("Shapes",500):WaitForChild("Box",500))
local Spring = require(ReplicatedStorage:WaitForChild("Constraints",500):WaitForChild("Spring",500))
local Matrix = require(ReplicatedStorage:WaitForChild("Util",500):WaitForChild("Matrix3x3",500))

-- This was built using ROBLOX, so trying to use the code as is won't work
-- Creates a simple simulation for a box and spring

local World = Scene.New()
World.Gravity = Vector3.new()
World.Damping = 0
World.TimeScale = 1

-- We use RungeKutta4 here, as it's the better, more stable solver of the two currently available
local Solver = RungeKutta4.New(World)
Solver.Scene = World
Solver.Iterations = 1

local Box = Box.New()
Box.Position = Vector3.new(10, 10, 10)
Box.Size = Vector3.new(2, 6, 2)
Box:SetMass(1)

local Spring = Spring.New()
Spring.Stiffness = 0.5
Spring.RestLength = 2.5
Spring.Point = Vector3.new(0, 10, 0)
Spring.AttachmentOffset = Vector3.new(0, -3, 0)

local BoxHandle = World:AddShape(Box)
local ConstraintHandle = World:AddConstraint(Spring, BoxHandle)

-- Set up the visualizer so we can view the simulation happening in real time using graphics
local Visualizer = Visualization.New()
Visualizer:AddShape(BoxHandle)
Visualizer:ResizeBuffer(World)

RunService.Heartbeat:Connect(function(Delta)
	Solver:SolveIteration(Delta)
	Visualizer:Render(World)
end)