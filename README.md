# RbxGizmo

# Accepted values
- Vector3 | Point
- CFrame | CFrame
- Ray | Line
- {CFrame, Vector2} | Plane
- {CFrame, Vector3} | Box
- {Vector3, number} | Sphere
- {Vector3, string} | Text

# Notes
You cannot give a new value to an already created Gizmo, this will throw an error

You cannot edit children of a visualised Gizmo (this does not apply to Text which is edited instead of the billboard it is parented to.)

# Example
```lua
while true do
  local depth = 20 + math.sin(time() * 2)
  local ray = Ray.new(Vector3.new(), Vector3.new(0, depth, 0))
  Gizmo:render("GizmoID", ray, {
      Color3 = Color3.new(1, 0, 0)
  })

  task.wait()
end

Gizmo:disable("GizmoID")
