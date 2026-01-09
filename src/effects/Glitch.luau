local TweenService = game:GetService("TweenService")
local Glitch = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Glitch", {
    duration = 1,
    intensity = 2,
    color = Color3.fromRGB(255, 0, 128)
})
]]

function Glitch.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.elements = {}
	self.intensity = self.config.intensity or 1
	self.color = self.config.color or Color3.fromRGB(0, 255, 255)

	function self:start()
		if self.running then return end
		self.running = true

		local redShift = Instance.new("Frame")
		redShift.Size = UDim2.fromScale(1, 1)
		redShift.Position = UDim2.fromScale(0.5, 0.5)
		redShift.AnchorPoint = Vector2.new(0.5, 0.5)
		redShift.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
		redShift.BackgroundTransparency = 0.8
		redShift.BorderSizePixel = 0
		redShift.Parent = self.target

		local blueShift = Instance.new("Frame")
		blueShift.Size = UDim2.fromScale(1, 1)
		blueShift.Position = UDim2.fromScale(0.5, 0.5)
		blueShift.AnchorPoint = Vector2.new(0.5, 0.5)
		blueShift.BackgroundColor3 = self.color
		blueShift.BackgroundTransparency = 0.8
		blueShift.BorderSizePixel = 0
		blueShift.Parent = self.target

		table.insert(self.elements, redShift)
		table.insert(self.elements, blueShift)

		for i = 1, 5 do
			local scanline = Instance.new("Frame")
			scanline.Size = UDim2.new(1, 0, 0, 2)
			scanline.Position = UDim2.fromScale(0, math.random())
			scanline.BackgroundColor3 = Color3.new(1, 1, 1)
			scanline.BackgroundTransparency = 0.7
			scanline.BorderSizePixel = 0
			scanline.Parent = self.target
			table.insert(self.elements, scanline)
		end

		task.spawn(function()
			while self.running do
				local offsetX = (math.random() - 0.5) * 0.02 * self.intensity
				local offsetY = (math.random() - 0.5) * 0.02 * self.intensity

				redShift.Position = UDim2.fromScale(0.5 + offsetX, 0.5 + offsetY)
				blueShift.Position = UDim2.fromScale(0.5 - offsetX, 0.5 - offsetY)

				for i = 3, #self.elements do
					if math.random() > 0.7 then
						self.elements[i].Position = UDim2.fromScale(0, math.random())
						self.elements[i].BackgroundTransparency = 0.5 + math.random() * 0.4
					end
				end

				task.wait(0.05 / self.intensity)
			end
		end)
	end

	function self:stop()
		self.running = false
		for _, element in ipairs(self.elements) do
			local fadeTween = TweenService:Create(element, TweenInfo.new(0.2), {
				BackgroundTransparency = 1
			})
			fadeTween:Play()
			fadeTween.Completed:Connect(function()
				element:Destroy()
			end)
		end
		self.elements = {}
	end

	return self
end

return Glitch