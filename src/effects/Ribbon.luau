local TweenService = game:GetService("TweenService")
local Ribbon = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Ribbon", {
    duration = 3,
    scale = 1,
    speed = 1,
    color = Color3.fromRGB(255, 182, 255)
})
]]

function Ribbon.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.segments = {}
	self.scale = self.config.scale or 1
	self.speed = self.config.speed or 1
	self.color = self.config.color or Color3.fromRGB(255, 182, 255)

	function self:start()
		if self.running then return end
		self.running = true

		local segmentCount = 20

		for i = 1, segmentCount do
			local segment = Instance.new("Frame")
			segment.Size = UDim2.fromOffset(15 * self.scale, 6 * self.scale)
			segment.AnchorPoint = Vector2.new(0.5, 0.5)
			segment.BackgroundColor3 = self.color:Lerp(Color3.new(1, 1, 1), (i / segmentCount) * 0.3)
			segment.BackgroundTransparency = 0.2 + (i / segmentCount) * 0.3
			segment.BorderSizePixel = 0
			segment.Parent = self.target

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = segment

			table.insert(self.segments, {segment = segment, index = i})
		end

		task.spawn(function()
			local startTime = tick()
			while self.running do
				local elapsed = (tick() - startTime) * self.speed

				for _, data in ipairs(self.segments) do
					local offset = data.index * 0.15
					local t = elapsed - offset

					local x = 0.5 + math.sin(t * 2) * 0.35
					local y = 0.5 + math.cos(t * 3) * 0.25

					data.segment.Position = UDim2.fromScale(x, y)
					data.segment.Rotation = math.deg(math.atan2(
						math.cos(t * 3) * 0.25 * 3,
						math.cos(t * 2) * 0.35 * 2
						))
				end

				task.wait()
			end
		end)
	end

	function self:stop()
		self.running = false
		for i, data in ipairs(self.segments) do
			task.spawn(function()
				task.wait(i * 0.02)
				local fadeTween = TweenService:Create(data.segment, TweenInfo.new(0.3), {
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(0, 0)
				})
				fadeTween:Play()
				fadeTween.Completed:Connect(function()
					data.segment:Destroy()
				end)
			end)
		end
		self.segments = {}
	end

	return self
end

return Ribbon