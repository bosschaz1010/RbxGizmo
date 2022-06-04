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
You cannot give a different value type to an already created Gizmo, this will throw an error

You cannot edit children of a visualised Gizmo. This mainly affects the **CFrame** type, **Text** is not affected by this any properties passed will be applied to that directly.

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
