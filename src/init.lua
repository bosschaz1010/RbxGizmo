local RunService = game:GetService("RunService")

-- Constants
local gizmoContainer = workspace.Terrain
local shouldRender = RunService:IsStudio() == true

-- Functions
local function alignBoxToLine(box: BoxHandleAdornment, origin: Vector3, goal: Vector3, lineWidth: number)
    lineWidth = lineWidth or 0.2
    local displacement = origin - goal
    box.CFrame = CFrame.lookAt(origin, goal) * CFrame.new(0, 0, -displacement.Magnitude / 2)
    box.Size = Vector3.new(lineWidth, lineWidth, displacement.Magnitude)
end

local function alignCylinderToLine(cylinder: CylinderHandleAdornment, origin: Vector3, goal: Vector3)
    local displacement = origin - goal
    cylinder.CFrame = CFrame.lookAt(origin, goal) * CFrame.new(0, 0, -displacement.Magnitude / 2)
    cylinder.Height = displacement.Magnitude
end

local function alignBoxToPlane(object: BoxHandleAdornment, origin: CFrame, size: Vector2)
    object.CFrame = origin
    object.Size = Vector3.new(size.X, 0.1, size.Y)
end

local function insertProperties(object: Instance, properties: { [string]: any })
    local instanceToApply = object
    if (object:IsA("Attachment")) then
        -- *probably* has Billboard inside
        instanceToApply = object.BillboardGui.TextLabel
    end

    if (not properties) then
        return
    end
    for i, v in pairs(properties) do
        instanceToApply[i] = v
    end
end

local function isPlaneClass(value)
    if (type(value) == "table") then
        if (typeof(value[1]) == "CFrame" and typeof(value[2]) == "Vector2") then
            return true
        end
    end
    return false
end

local function isBoxClass(value)
    if (type(value) == "table") then
        if (typeof(value[1]) == "CFrame" and typeof(value[2]) == "Vector3") then
            return true
        end
    end
    return false
end

local function isSphereClass(value)
    if (type(value) == "table") then
        if (typeof(value[1]) == "Vector3" and typeof(value[2]) == "number") then
            return true
        end
    end
    return false
end

local function isTextClass(value)
    if (type(value) == "table") then
        if (typeof(value[1]) == "string" and typeof(value[2]) == "Vector3") then
            return true
        end
    end
    return false
end

-- Main
local Gizmo = {}
Gizmo.active = {}

function Gizmo:render(id: string, value, properties: { [string]: any })
    if (not shouldRender) then
        return
    end
    if (Gizmo.active[id]) then
        if (Gizmo.active[id]:IsA("HandleAdornment")) then
            Gizmo.active[id].Visible = true
            for i, v in pairs(Gizmo.active[id]:GetChildren()) do
                v.Visible = true
            end
        elseif (Gizmo.active[id]:IsA("Attachment")) then
            Gizmo.active[id].BillboardGui.Enabled = true
        end

        insertProperties(Gizmo.active[id], properties)
        Gizmo:update(id, value)
        return
    end

    -- Find create Adornement instance
    local valueType = typeof(value)
    local gizmoInstance = nil
    if (valueType == "Vector3") then
        gizmoInstance = Instance.new("SphereHandleAdornment")
    elseif (valueType == "CFrame") then
        gizmoInstance = Instance.new("BoxHandleAdornment") do
            local forward = Instance.new("BoxHandleAdornment", gizmoInstance)
            forward.Name = "Forward"
            forward.AlwaysOnTop = true
            forward.Color3 = Color3.new(1, 0, 0)
            forward.Adornee = gizmoContainer
            forward.Transparency = 0.5
            local up = Instance.new("BoxHandleAdornment", gizmoInstance)
            up.Name = "Up"
            up.AlwaysOnTop = true
            up.Color3 = Color3.new(0, 1, 0)
            up.Adornee = gizmoContainer
            up.Transparency = 0.5
            local right = Instance.new("BoxHandleAdornment", gizmoInstance)
            right.Name = "Right"
            right.AlwaysOnTop = true
            right.Color3 = Color3.new(0, 0, 1)
            right.Adornee = gizmoContainer
            right.Transparency = 0.5
        end
        gizmoInstance.Size = Vector3.new(0, 0, 0)
    elseif (valueType == "Ray") then
        gizmoInstance = Instance.new("CylinderHandleAdornment")
    elseif (isPlaneClass(value)) then
        gizmoInstance = Instance.new("BoxHandleAdornment") do
            local streak = Instance.new("BoxHandleAdornment", gizmoInstance)
            streak.Name = "Streak"
            streak.Adornee = gizmoContainer
            streak.Transparency = 0
            streak.AlwaysOnTop = true
            streak.Color3 = Color3.new(0, 0, 0)
            streak.ZIndex = 2
        end
    elseif (isBoxClass(value)) then
        gizmoInstance = Instance.new("BoxHandleAdornment")
    elseif (isSphereClass(value)) then
        gizmoInstance = Instance.new("SphereHandleAdornment")
    elseif (isTextClass(value)) then
        gizmoInstance = Instance.new("Attachment") do
            local bbg = Instance.new("BillboardGui")
            bbg.Adornee = gizmoInstance
            bbg.Size = UDim2.fromOffset(1000, 32)
            bbg.AlwaysOnTop = true
            bbg.ClipsDescendants = false
            bbg.Parent = gizmoInstance
            
            local tl = Instance.new("TextLabel")
            tl.Text = value[1]
            tl.Size = UDim2.fromScale(1, 1)
            tl.BackgroundTransparency = 1
            tl.TextSize = 18
            tl.Font = Enum.Font.SourceSansBold
            tl.TextColor3 = Color3.new(1, 1, 1)
            tl.Parent = bbg
        end
    else
        error("Invalid Gizmo value.")
    end
    
    -- Apply custom properties
    if (gizmoInstance:IsA("HandleAdornment")) then
        gizmoInstance.AlwaysOnTop = true
        gizmoInstance.Transparency = 0.5
        gizmoInstance.ZIndex = 0
        gizmoInstance.Adornee = workspace.Terrain
    elseif (gizmoInstance:IsA("Attachment")) then
        -- nothing to add really
    end
    insertProperties(gizmoInstance, properties)

    -- Store
    Gizmo.active[id] = gizmoInstance

    -- First update
    Gizmo:update(id, value)
    gizmoInstance.Parent = gizmoContainer
end

function Gizmo:disable(id: string)
    if (not Gizmo.active[id]) then
        return
    end
    if (Gizmo.active[id]:IsA("HandleAdornment")) then
        Gizmo.active[id].Visible = false
        for i, v in pairs(Gizmo.active[id]:GetChildren()) do
            v.Visible = false
        end
    elseif (Gizmo.active[id]:IsA("Attachment")) then
        Gizmo.active[id].BillboardGui.Enabled = false
    end
end

function Gizmo:update(id: string, value)
    if (not shouldRender) then
        return
    end
    local gizmoInstance = Gizmo.active[id]
    local valueType = typeof(value)
    if (valueType == "Vector3") then
        gizmoInstance.CFrame = CFrame.new(value)
    elseif (valueType == "CFrame") then
        local position = value.Position
        alignBoxToLine(gizmoInstance.Forward, position, position + value.LookVector * 2)
        alignBoxToLine(gizmoInstance.Up, position, position + value.UpVector * 2)
        alignBoxToLine(gizmoInstance.Right, position, position + value.RightVector * 2)
        gizmoInstance.CFrame = value
    elseif (valueType == "Ray") then
        alignCylinderToLine(gizmoInstance, value.Origin, value.Origin + value.Direction)
    elseif (isPlaneClass(value)) then
        alignBoxToPlane(gizmoInstance, value[1], value[2])

        local TL = value[1] * CFrame.new(value[2].X / 2 * 0.99, 0, value[2].Y / 2 * 0.99)
        local BL = value[1] * CFrame.new(-value[2].X / 2 * 0.99, 0, -value[2].Y / 2 * 0.99)
        alignBoxToLine(gizmoInstance.Streak, TL.p, BL.p, 0.05)
    elseif (isBoxClass(value)) then
        gizmoInstance.CFrame = value[1]
        gizmoInstance.Size = value[2]
    elseif (isSphereClass(value)) then
        gizmoInstance.CFrame = CFrame.new(value[1])
        gizmoInstance.Radius = value[2]
    elseif (isTextClass(value)) then
        gizmoInstance.BillboardGui.TextLabel.Text = value[1]
        gizmoInstance.CFrame = CFrame.new(value[2])
    end
end

return Gizmo
