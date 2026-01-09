local TweenService = game:GetService("TweenService")
local Pulse = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Pulse", {
    duration = 2,
    scale = 1.2,
    color = Color3.fromRGB(255, 182, 255)
})
]]

function Pulse.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.elements = {}
	self.scale = self.config.scale or 1.2
	self.color = self.config.color or Color3.fromRGB(255, 182, 255)

	function self:start()
		if self.running then return end
		self.running = true

		task.spawn(function()
			while self.running do
				local ring = Instance.new("Frame")
				ring.Size = UDim2.fromScale(0.8, 0.8)
				ring.Position = UDim2.fromScale(0.5, 0.5)
				ring.AnchorPoint = Vector2.new(0.5, 0.5)
				ring.BackgroundTransparency = 1
				ring.Parent = self.target

				local stroke = Instance.new("UIStroke")
				stroke.Color = self.color
				stroke.Thickness = 3
				stroke.Transparency = 0
				stroke.Parent = ring

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0.2, 0)
				corner.Parent = ring

				table.insert(self.elements, ring)

				local expandTween = TweenService:Create(ring, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.fromScale(self.scale, self.scale)
				})

				local fadeTween = TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				})

				expandTween:Play()
				fadeTween:Play()

				fadeTween.Completed:Connect(function()
					ring:Destroy()
					table.remove(self.elements, table.find(self.elements, ring))
				end)

				task.wait(0.6)
			end
		end)
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

return Pulse