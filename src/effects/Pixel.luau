local TweenService = game:GetService("TweenService")
local Pixel = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Pixel", {
    duration = 0.5,
    pixelSize = 10,
    color = Color3.fromRGB(255, 255, 255)
})
]]

function Pixel.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.elements = {}
	self.pixelSize = self.config.pixelSize or 10
	self.color = self.config.color or Color3.fromRGB(255, 182, 255)

	function self:start()
		if self.running then return end
		self.running = true

		local container = Instance.new("Frame")
		container.Size = UDim2.fromScale(1, 1)
		container.BackgroundTransparency = 1
		container.ClipsDescendants = true
		container.Parent = self.target

		table.insert(self.elements, container)

		local cols = math.ceil(self.target.AbsoluteSize.X / self.pixelSize)
		local rows = math.ceil(self.target.AbsoluteSize.Y / self.pixelSize)

		for x = 1, cols do
			for y = 1, rows do
				local pixel = Instance.new("Frame")
				pixel.Size = UDim2.fromOffset(self.pixelSize, self.pixelSize)
				pixel.Position = UDim2.fromScale((x-1)/cols, (y-1)/rows)
				pixel.BackgroundColor3 = self.color
				pixel.BackgroundTransparency = 1
				pixel.BorderSizePixel = 0
				pixel.Parent = container

				table.insert(self.elements, pixel)

				local delay = math.random() * 0.3
				local appear = TweenService:Create(pixel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					BackgroundTransparency = 0
				})

				local disappear = TweenService:Create(pixel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					BackgroundTransparency = 1
				})

				task.spawn(function()
					task.wait(delay)
					appear:Play()
					task.wait(0.2)
					disappear:Play()
				end)
			end
		end

		task.wait(0.7)
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

return Pixel