local TweenService = game:GetService("TweenService")
local Spiral = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Spiral", {
    duration = 0.8,
    rings = 3,
    color = Color3.fromRGB(255, 255, 255)
})
]]

function Spiral.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.elements = {}
	self.rings = self.config.rings or 3
	self.color = self.config.color or Color3.fromRGB(255, 182, 255)

	function self:start()
		if self.running then return end
		self.running = true

		local container = Instance.new("Frame")
		container.Size = UDim2.fromScale(1, 1)
		container.Position = UDim2.fromScale(0.5, 0.5)
		container.AnchorPoint = Vector2.new(0.5, 0.5)
		container.BackgroundTransparency = 1
		container.Parent = self.target

		table.insert(self.elements, container)

		local segments = 12 * self.rings
		for i = 1, segments do
			local segment = Instance.new("Frame")
			local radius = (i / segments) * 0.5
			local angle = (i / segments) * math.pi * 2 * self.rings

			segment.Size = UDim2.fromScale(0.1, 0.1)
			segment.Position = UDim2.fromScale(
				0.5 + math.cos(angle) * radius,
				0.5 + math.sin(angle) * radius
			)
			segment.AnchorPoint = Vector2.new(0.5, 0.5)
			segment.BackgroundColor3 = self.color
			segment.BackgroundTransparency = 0.2
			segment.Parent = container

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = segment

			table.insert(self.elements, segment)

			local endRadius = 1
			local endAngle = angle + math.pi * 2

			local tween = TweenService:Create(segment, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
				Position = UDim2.fromScale(
					0.5 + math.cos(endAngle) * endRadius,
					0.5 + math.sin(endAngle) * endRadius
				),
				BackgroundTransparency = 1
			})

			task.spawn(function()
				task.wait(i * 0.02)
				tween:Play()
			end)
		end

		task.wait(1)
		self:stop()
	end

	function self:stop()
		self.running = false
		for _, element in ipairs(self.elements) do
			element:Destroy()
		end
		self.elements = {}
	end

	return self
end

return Spiral