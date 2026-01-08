local TweenService = game:GetService("TweenService")
local Ripple = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Ripple", {
    duration = 0.5,
    scale = 1.2,
    color = Color3.fromRGB(255, 255, 255)
})
]]

function Ripple.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.elements = {}
	self.color = self.config.color or Color3.fromRGB(255, 182, 255)
	self.scale = self.config.scale or 1.2

	function self:start()
		if self.running then return end
		self.running = true

		local mouse = game:GetService("Players").LocalPlayer:GetMouse()
		local relativeX = (mouse.X - self.target.AbsolutePosition.X) / self.target.AbsoluteSize.X
		local relativeY = (mouse.Y - self.target.AbsolutePosition.Y) / self.target.AbsoluteSize.Y

		local ripple = Instance.new("Frame")
		ripple.Size = UDim2.fromScale(0, 0)
		ripple.Position = UDim2.fromScale(relativeX, relativeY)
		ripple.AnchorPoint = Vector2.new(0.5, 0.5)
		ripple.BackgroundColor3 = self.color
		ripple.BackgroundTransparency = 0.4
		ripple.Parent = self.target

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = ripple
		
		local aspectRatio = Instance.new("UIAspectRatioConstraint")
		aspectRatio.Parent = ripple

		table.insert(self.elements, ripple)

		local maxDistance = math.max(
			math.max(relativeX, 1 - relativeX) * 2,
			math.max(relativeY, 1 - relativeY) * 2
		) * self.scale

		local expandTween = TweenService:Create(ripple, TweenInfo.new(0.5), {
			Size = UDim2.fromScale(maxDistance, maxDistance),
			BackgroundTransparency = 1
		})

		expandTween:Play()
		expandTween.Completed:Connect(function()
			ripple:Destroy()
			table.remove(self.elements, table.find(self.elements, ripple))
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

return Ripple