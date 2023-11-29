local Matrix = {}

local Sin = math.sin
local Cos = math.cos

function Matrix.New()
	return {
		M11 = 1, M12 = 0, M13 = 0,
		M21 = 0, M22 = 1, M23 = 0,
		M31 = 0, M32 = 0, M33 = 1
	}
end

function Matrix.Multiply(A, B)
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

function Matrix.Transform(V, M)
	return Vector3.new(
		M.M11*V.X + M.M21*V.Y + M.M31*V.Z,
		M.M12*V.X + M.M22*V.Y + M.M32*V.Z,
		M.M13*V.X + M.M23*V.Y + M.M33*V.Z
	)
end

function Matrix.InertiaTensorIntegration(V, M)
	return Vector3.new(
		M.M11*V.X + M.M12*V.Y + M.M13*V.Z,
		M.M21*V.X + M.M22*V.Y + M.M23*V.Z,
		M.M31*V.X + M.M32*V.Y + M.M33*V.Z
	)
end

function Matrix.Transpose(M) -- I probably don't need this
	
end

function Matrix.ToMatrix(RadX, RadY, RadZ)
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


	return Matrix.Multiply(Z, Matrix.Multiply(X, Y))
end

function Matrix.ToCFrame(Position, Matrix)
	local VectorX = Vector3.new(Matrix.M11, Matrix.M12, Matrix.M13)
	local VectorY = Vector3.new(Matrix.M21, Matrix.M22, Matrix.M23)
	local VectorZ = Vector3.new(Matrix.M31, Matrix.M32, Matrix.M33)

	return CFrame.new(
		Position.X, Position.Y, Position.Z,
		VectorX.X, VectorY.X, VectorZ.X,
		VectorX.Y, VectorY.Y, VectorZ.Y,
		VectorX.Z, VectorY.Z, VectorZ.Z
	)
end

return Matrix