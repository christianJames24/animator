local TweenService = game:GetService("TweenService")
local Shatter = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Shatter", {
    duration = 0.8,
    pieces = 16,
    color = Color3.fromRGB(255, 255, 255)
})
]]

function Shatter.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.elements = {}
	self.pieces = self.config.pieces or 16
	self.color = self.config.color or Color3.fromRGB(255, 220, 255)

	function self:start()
		if self.running then return end
		self.running = true

		local cols = math.ceil(math.sqrt(self.pieces))
		local rows = cols

		for x = 1, cols do
			for y = 1, rows do
				local shard = Instance.new("Frame")
				shard.Size = UDim2.fromScale(1/cols, 1/rows)
				shard.Position = UDim2.fromScale((x-1)/cols, (y-1)/rows)
				shard.BackgroundColor3 = self.color
				shard.BackgroundTransparency = 0.3
				shard.BorderSizePixel = 0
				shard.Parent = self.target

				local stroke = Instance.new("UIStroke")
				stroke.Color = Color3.new(1, 1, 1)
				stroke.Thickness = 1
				stroke.Transparency = 0.5
				stroke.Parent = shard

				table.insert(self.elements, shard)

				local centerX = (x - 0.5) / cols - 0.5
				local centerY = (y - 0.5) / rows - 0.5
				local angle = math.atan2(centerY, centerX)
				local distance = math.sqrt(centerX^2 + centerY^2)

				local endX = centerX + math.cos(angle) * distance * 2
				local endY = centerY + math.sin(angle) * distance * 2

				task.spawn(function()
					task.wait(distance * 0.3)

					local shatterTween = TweenService:Create(shard, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
						Position = UDim2.fromScale(0.5 + endX, 0.5 + endY),
						Rotation = math.random(-180, 180),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.05, 0.05)
					})
					shatterTween:Play()
					shatterTween.Completed:Connect(function()
						shard:Destroy()
						table.remove(self.elements, table.find(self.elements, shard))
					end)
				end)
			end
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

return Shatter