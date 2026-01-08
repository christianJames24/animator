local TweenService = game:GetService("TweenService")
local FlashPop = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("FlashPop", {
    duration = 0.3,
    intensity = 1,
    color = Color3.fromRGB(255, 255, 255)
})
]]

function FlashPop.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.elements = {}
	self.intensity = self.config.intensity or 1
	self.color = self.config.color or Color3.fromRGB(255, 182, 255)

	function self:start()
		if self.running then return end
		self.running = true

		local flash = Instance.new("Frame")
		flash.Size = UDim2.fromScale(1, 1)
		flash.Position = UDim2.fromScale(0.5, 0.5)
		flash.AnchorPoint = Vector2.new(0.5, 0.5)
		flash.BackgroundColor3 = self.color
		flash.BackgroundTransparency = 0
		flash.Parent = self.target

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = flash

		table.insert(self.elements, flash)

		local fadeOut = TweenService:Create(flash, TweenInfo.new(0.3), {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1.2, 1.2)
		})

		fadeOut:Play()
		fadeOut.Completed:Connect(function()
			flash:Destroy()
			table.remove(self.elements, table.find(self.elements, flash))
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

return FlashPop