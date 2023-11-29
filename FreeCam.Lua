local ContextActionService = game:GetService("ContextActionService") -- Allows developers to bind user inputs to functions
local UserInputService = game:GetService("UserInputService") -- Center of all user input related services, used here for mouse manipulation
local RunService = game:GetService("RunService") -- Allows developers to tie functions to simulation events
local Camera = workspace.CurrentCamera -- Player's local camera


-- (Euler Angles) X Roll, Y Pitch, Z Yaw
-- (Cardinal Axes) X Pitch, Y Yaw, Z Roll

--[[
	(Euler Angles) X Roll, Y Pitch, Z Yaw
	(Cardinal Axes) X Pitch, Y Yaw, Z Roll
	
	Roblox's part Orientation property uses extrinsic cardinal axes for rotations. (-180 degrees to 180 degrees)
	Roblox's CFrames are intrinsic, structed as a 4x4 matrix. Position, transposed 3x3, and then the untouchable scale part.
]]


-- Objects
local CameraActor = script.CameraActor; CameraActor.Parent = workspace
CameraActor.Position = Vector3.new(0, 8.5, 14)

-- Controller state
local MoveSpeed = 36
local MoveVector = Vector3.new()

local MouseLock = true
local CameraX = 0
local CameraY = 0

local KeyState = {
	W = 0,
	S = 0,
	D = 0,
	A = 0,

	E = 0,
	Q = 0
}

-- Math lib shortcuts
local Sin = math.sin
local Cos = math.cos


-- Matrix math lib
function Multiply(A, B)
	return {
		M11 = A.M11*B.M11 + A.M12*B.M21 + A.M13*B.M31, 
		M12 = A.M11*B.M12 + A.M12*B.M22 + A.M13*B.M32, 
		M13 = A.M11*B.M13 + A.M12*B.M23 + A.M13*B.M33,
		
		M21 = A.M21*B.M11 + A.M22*B.M21 + A.M23*B.M31, 
		M22 = A.M21*B.M12 + A.M22*B.M22 + A.M23*B.M32, 
		M23 = A.M21*B.M13 + A.M22*B.M23 + A.M23*B.M33,
		
		M31 = A.M31*B.M11 + A.M32*B.M21 + A.M33*B.M31, 
		M32 = A.M31*B.M12 + A.M32*B.M22 + A.M33*B.M32, 
		M33 = A.M31*B.M13 + A.M32*B.M23 + A.M33*B.M33
	}
end

function Transform(V, M)
	return Vector3.new(
		M.M11*V.X + M.M21*V.Y + M.M31*V.Z,
		M.M12*V.X + M.M22*V.Y + M.M32*V.Z,
		M.M13*V.X + M.M23*V.Y + M.M33*V.Z
	)
end


-- Main loop
RunService.Heartbeat:Connect(function(Delta)
	local RadX, RadY, RadZ = math.rad(CameraX), math.rad(CameraY), 0
	
	RadX = -RadX
	RadZ = -RadZ

	local X = { -- Cardinal Matrix X (Pitch)
		M11 = 1, M12 = 0, M13 = 0,
		M21 = 0, M22 = Cos(RadX), M23 = -Sin(RadX),
		M31 = 0, M32 = Sin(RadX), M33 = Cos(RadX)
	}

	local Y = { -- Cardinal Matrix Y (Yaw)
		M11 = Cos(RadY), M12 = 0, M13 = -Sin(RadY),
		M21 = 0, M22 = 1, M23 = 0,
		M31 = Sin(RadY), M32 = 0, M33 = Cos(RadY)
	}

	local Z = { -- Cardinal Matrix Z (Roll)
		M11 = Cos(RadZ), M12 = -Sin(RadZ), M13 = 0,
		M21 = Sin(RadZ), M22 = Cos(RadZ), M23 = 0,
		M31 = 0, M32 = 0, M33 = 1
	}


	local Matrix = Multiply(Z, Multiply(X, Y)) -- Yaw, Pitch, Roll
	local VectorX = Vector3.new(Matrix.M11, Matrix.M12, Matrix.M13)
	local VectorY = Vector3.new(Matrix.M21, Matrix.M22, Matrix.M23)
	local VectorZ = Vector3.new(Matrix.M31, Matrix.M32, Matrix.M33)

	local RotatedMoveVector = Transform(MoveVector, Matrix) * Delta * MoveSpeed
	local Position = CameraActor.Position + RotatedMoveVector
	local ConstructedCFrame = CFrame.new(
		Position.X, Position.Y, Position.Z,
		VectorX.X, VectorY.X, VectorZ.X,
		VectorX.Y, VectorY.Y, VectorZ.Y,
		VectorX.Z, VectorY.Z, VectorZ.Z
	)
	
	CameraActor.CFrame = ConstructedCFrame
	Camera.CFrame = CameraActor.CFrame
end)










-- Controller lib
function CalculateMoveVector()
	-- X Left Right
	-- Y Up Down
	-- Z Forward Back (Flip W and S to match ROBLOX's cardinal axes)
	
	MoveVector = Vector3.new(KeyState.D-KeyState.A, KeyState.E-KeyState.Q, KeyState.S-KeyState.W)
end


-- Movement Bindings
ContextActionService:BindAction("Forward", function(ActionName, InputState:UserInputState, InputObject:InputObject)
	if InputState == Enum.UserInputState.Begin then
		KeyState.W = 1
	else
		KeyState.W = 0
	end
	
	CalculateMoveVector()
	
	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.W)

ContextActionService:BindAction("Back", function(ActionName, InputState:UserInputState, InputObject:InputObject)
	if InputState == Enum.UserInputState.Begin then
		KeyState.S = 1
	else
		KeyState.S = 0
	end
	
	CalculateMoveVector()

	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.S)

ContextActionService:BindAction("Right", function(ActionName, InputState:UserInputState, InputObject:InputObject)
	if InputState == Enum.UserInputState.Begin then
		KeyState.D = 1
	else
		KeyState.D = 0
	end
	
	CalculateMoveVector()

	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.D)

ContextActionService:BindAction("Left", function(ActionName, InputState:UserInputState, InputObject:InputObject)
	if InputState == Enum.UserInputState.Begin then
		KeyState.A = 1
	else
		KeyState.A = 0
	end
	
	CalculateMoveVector()

	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.A)

ContextActionService:BindAction("Up", function(ActionName, InputState:UserInputState, InputObject:InputObject)
	if InputState == Enum.UserInputState.Begin then
		KeyState.E = 1
	else
		KeyState.E = 0
	end
	
	CalculateMoveVector()

	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.E)

ContextActionService:BindAction("Down", function(ActionName, InputState:UserInputState, InputObject:InputObject)
	if InputState == Enum.UserInputState.Begin then
		KeyState.Q = 1
	else
		KeyState.Q = 0
	end
	
	CalculateMoveVector()

	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.Q)


-- Camera Bindings
ContextActionService:BindAction("Shift", function(ActionName, InputState:UserInputState, InputObject:InputObject)
	if InputObject.KeyCode == Enum.KeyCode.LeftShift then
		if InputState == Enum.UserInputState.Begin then
			MoveSpeed = 8
		else
			MoveSpeed = 36
		end
	else
		if InputState == Enum.UserInputState.Begin then
			UserInputService.MouseIconEnabled = not UserInputService.MouseIconEnabled
		end
	end

	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.LeftShift, Enum.KeyCode.LeftControl)

ContextActionService:BindAction("Mouse", function(ActionName, InputState:UserInputState, InputObject:InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		if InputState == Enum.UserInputState.Begin then
			MouseLock = not MouseLock
		end
	else
		local Delta = -InputObject.Delta / 2
		CameraX = math.clamp(CameraX + Delta.Y, -85, 85)
		CameraY = (CameraY + Delta.X)%360
	end
	
	if MouseLock then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	return Enum.ContextActionResult.Pass
end, false, Enum.UserInputType.MouseMovement, Enum.UserInputType.MouseButton1)