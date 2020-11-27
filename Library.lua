local Library = { Tabs = {}, Keybinds = {}, Opened = true, Binding = false, Dragging = false }

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local CoreGui = game:GetService("CoreGui")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

UserInputService.InputBegan:Connect(function(input, isrbx)
	if input.UserInputType == Enum.UserInputType.Keyboard and Library.Binding == false and isrbx == false then
		for i, v in next, Library.Keybinds do
			if v.Value == input.KeyCode then
				v.Callback(v.Value)
			end
		end
	end
end)

function Create(obj, props, round)
	local Obj = Instance.new(obj)
	for i, v in pairs(props) do
		if i ~= "Parent" then
			if typeof(v) == "Instance" then
				v.Parent = Obj
			else
				Obj[i] = v
			end
		end			
	end
	if round then
		local Corner = Instance.new("UICorner", Obj)
		Corner.CornerRadius = UDim.new(0, 4)
	end
	Obj.Parent = props.Parent
	return Obj
end

function MakeDraggable(obj)
	local Connection = nil
	obj.InputBegan:Connect(function(input)
		if Library.Dragging == false and input.UserInputType == Enum.UserInputType.MouseButton1 then
			if Connection then
				Connection:Disconnect()
			end
			local Offset = Vector2.new(obj.AbsoluteSize.X * obj.AnchorPoint.X, obj.AbsoluteSize.Y * obj.AnchorPoint.Y)
			local Pos = Vector2.new(Mouse.X - (obj.AbsolutePosition.X + Offset.X), Mouse.Y - (obj.AbsolutePosition.Y + Offset.Y))
			Connection = RunService.Heartbeat:Connect(function()
				obj:TweenPosition(UDim2.new(0, Mouse.X - Pos.X, 0, Mouse.Y - Pos.Y), "InOut", "Sine", 0.08, true)
			end)
		end
	end)
	obj.InputEnded:Connect(function(input)
		if Connection and input.UserInputType == Enum.UserInputType.MouseButton1 then
			Connection:Disconnect()
		end
	end)
end

function Scale(obj)
	assert(obj:IsA("ScrollingFrame"), "function Scale - ScrollingFrame Expected.")
	local Offset = obj:FindFirstChild("UIListLayout") and obj.UIListLayout.Padding.Offset or 0
	local Height = 0
	for i, v in next, obj:GetChildren() do
		if not v:IsA("UIListLayout") then
			Height = Height + v.AbsoluteSize.Y + Offset
		end
	end
	obj.CanvasSize = UDim2.new(0, 0, 0, Height - Offset)
end

function Ripple(obj)
	local Effect = Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(220, 220, 220),
		Parent = obj,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		Transparency = 0.4
	}, true)
	local Tween = TweenService:Create(Effect, TweenInfo.new(0.5), {
		Size = UDim2.new(1, 0, 1, 0),
		Transparency = 0.8
	})
	Tween:Play()
	Tween.Completed:Connect(function()
		Effect:Destroy()
	end)
end

function LoadTab(tab)
	tab.ButtonFrame = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		Name = tab.Name,
		Parent = tab.ButtonContainer,
		Size = UDim2.new(1, -6, 0, 32),
		Create("Frame", {
			BackgroundColor3 = #Library.Tabs == 0 and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(89, 183, 248),
			Name = "Indicator",
			Position = UDim2.new(0, 4, 0, 4),
			Size = UDim2.new(0, 24, 0, 24)
		}, true),
		Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = "Label",
			Position = UDim2.new(0, 33, 0, 0),
			Size = UDim2.new(1, -33, 1, 0),
			Text = tab.Name,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	}, true)
	tab.Frame = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ClipsDescendants = true,
		Name = tab.Name,
		Parent = tab.Container,
		Position = UDim2.new(0, 10, 0, 55),
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
		ScrollBarThickness = 3,
		Size = UDim2.new(1, -14, 1, -65),
		Visible = #Library.Tabs == 0,
		Create("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	})
	tab.ButtonFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Ripple(tab.ButtonFrame)
			for i, v in next, Library.Tabs do
				v.Frame.Visible = false
				v.ButtonFrame.Indicator.BackgroundColor3 = Color3.fromRGB(89, 183, 248)
			end
			tab.Frame.Visible = true
			tab.ButtonFrame.Indicator.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
			tab.Container.Tab.Text = tab.Name
		end
	end)
	tab.Frame.ChildAdded:Connect(function(child)
		Scale(tab.Frame)
	end)
	table.insert(Library.Tabs, tab)
	return tab
end

function LoadButton(btn)
	btn.Frame = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		Name = btn.Name,
		Parent = btn.Tab.Frame,
		Size = UDim2.new(1, -6, 0, 32),
		Create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = Color3.fromRGB(89, 183, 248),
			Font = Enum.Font.Gotham,
			Name = "Button",
			Position = UDim2.new(0, 4, 0, 4),
			Size = UDim2.new(0, 120, 1, -8),
			Text = btn.Name,
			TextColor3 = Color3.fromRGB(30, 30, 30),
			TextSize = 14
		}, true),
		Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = "Description",
			Position = UDim2.new(0, 129, 0, 0),
			Size = UDim2.new(1, -134, 1, 0),
			Text = btn.Description,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right
		})
	}, true)
	btn.Frame.Button.MouseButton1Click:Connect(function()
		Ripple(btn.Frame.Button)
		btn.Callback()
	end)
	return btn
end

function LoadToggle(toggle)
	toggle.Frame = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		Name = toggle.Name,
		Parent = toggle.Tab.Frame,
		Size = UDim2.new(1, -6, 0, 32),
		Create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = Color3.fromRGB(89, 183, 248),
			Font = Enum.Font.Gotham,
			Name = "Button",
			Position = UDim2.new(0, 4, 0, 4),
			Size = UDim2.new(0, 24, 0, 24),
			Text = "",
			TextColor3 = Color3.fromRGB(30, 30, 30),
			TextSize = 16
		}, true),
		Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = "Label",
			Position = UDim2.new(0, 33, 0, 0),
			Size = UDim2.new(1, -38, 1, 0),
			Text = toggle.Name,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = "Description",
			Position = UDim2.new(0, 33, 0, 0),
			Size = UDim2.new(1, -38, 1, 0),
			Text = toggle.Description,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right
		})
	}, true)
	toggle.Set = function(bool)
		assert(bool ~= nil and type(bool) == "boolean", "function Toggle.Set - bool expected.")
		toggle.Enabled = bool
		toggle.Frame.Button.BackgroundColor3 = bool and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(89, 183, 248)
		toggle.Callback(bool)
	end
	toggle.Frame.Button.MouseButton1Click:Connect(function()
		Ripple(toggle.Frame.Button)
		toggle.Set(not toggle.Enabled)
	end)
	return toggle
end

function LoadBox(box)
	box.Frame = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		Name = box.Name,
		Parent = box.Tab.Frame,
		Size = UDim2.new(1, -6, 0, 60),
		Create("TextBox", {
			BackgroundColor3 = Color3.fromRGB(89, 183, 248),
			Font = Enum.Font.Gotham,
			Name = "Box",
			PlaceholderColor3 = Color3.fromRGB(50, 50, 50),
			PlaceholderText = box.NumbersOnly and "Enter Number..." or "Enter Text...",
			Position = UDim2.new(0, 4, 0, 32),
			Size = UDim2.new(1, -8, 0, 24),
			Text = "",
			TextColor3 = Color3.fromRGB(30, 30, 30),
			TextSize = 14,
			TextWrapped = true
		}, true),
		Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = "Label",
			Position = UDim2.new(0, 5, 0, 0),
			Size = UDim2.new(1, -10, 0, 32),
			Text = box.Name,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = "Description",
			Position = UDim2.new(0, 5, 0, 0),
			Size = UDim2.new(1, -10, 0, 32),
			Text = box.Description,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right
		})
	}, true)
	box.Set = function(val)
		assert(val ~= nil and type(val) == "string", "function Box.Set - string expected.")
		
		if val ~= "" or (not box.NumbersOnly or tonumber(val)) then
			box.Value = val
			if val == "" then
				box.Callback(box.NumbersOnly and tonumber(val) or val)
			end
		else
			box.Frame.Box.Text = box.Value
		end
	end
	box.Frame.Box.FocusLost:Connect(function()
		box.Set(box.Frame.Box.Text)
	end)
	return box
end

function LoadKeybind(keybind)
	keybind.Frame = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		Name = keybind.Name,
		Parent = keybind.Tab.Frame,
		Size = UDim2.new(1, -6, 0, 32),
		Create("TextLabel", {
			BackgroundColor3 = Color3.fromRGB(89, 183, 248),
			Font = Enum.Font.Gotham,
			Name = "Bind",
			Position = UDim2.new(0, 4, 0, 4),
			Size = UDim2.new(0, 92, 1, -8),
			Text = keybind.Name,
			TextColor3 = Color3.fromRGB(30, 30, 30),
			TextSize = 14
		}, true),
		Create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = Color3.fromRGB(89, 183, 248),
			Font = Enum.Font.Gotham,
			Name = "Button",
			Position = UDim2.new(0, 100, 0, 4),
			Size = UDim2.new(0, 24, 1, -8),
			Text = "S",
			TextColor3 = Color3.fromRGB(30, 30, 30),
			TextSize = 14
		}, true),
		Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = "Description",
			Position = UDim2.new(0, 129, 0, 0),
			Size = UDim2.new(1, -134, 1, 0),
			Text = keybind.Description,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right
		})
	}, true)
	keybind.Set = function(bind)
		assert(bind ~= nil and string.find(tostring(bind), "Enum.KeyCode."), "function Keybind.Set - Enum.KeyCode expected.")
		keybind.Value = bind
		keybind.Frame.Bind.Text = string.gsub(tostring(bind), "Enum.KeyCode.", "")
	end
	keybind.Frame.Button.MouseButton1Click:Connect(function()
		Library.Binding = true
		Ripple(keybind.Frame.Button)
		keybind.Frame.Bind.Text = "..."
		local Set = false
		repeat
			local Input = UserInputService.InputBegan:Wait()
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				keybind.Set(Input.KeyCode)
				Set = true
			end
		until Set == true
		wait(0.25)
		Library.Binding = false
	end)
	table.insert(Library.Keybinds, keybind)
	return keybind
end

function LoadSlider(slider)
	slider.Frame = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		Name = slider.Name,
		Parent = slider.Tab.Frame,
		Size = UDim2.new(1, -6, 0, 48),
		Create("Frame", {
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			ClipsDescendants = true,
			Name = "Background",
			Position = UDim2.new(0, 4, 0, 32),
			Size = UDim2.new(1, -8, 0, 12),
			Create("Frame", {
				BackgroundColor3 = Color3.fromRGB(89, 183, 248),
				Name = "Slider",
				Size = UDim2.new(0, 0, 1, 0)
			}, true)
		}, true),
		Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = "Label",
			Position = UDim2.new(0, 5, 0, 0),
			Size = UDim2.new(1, -10, 0, 32),
			Text = slider.Name .. " - " .. slider.Min,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = "Description",
			Position = UDim2.new(0, 5, 0, 0),
			Size = UDim2.new(1, -10, 0, 32),
			Text = slider.Description,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right
		})
	}, true)
	slider.Set = function(val)
		assert(val ~= nil and type(val) == "number", "function Slider.Set - number expected.")
		assert(val >= slider.Min and val <= slider.Max, "function Slider.Set - number is not between min and max value.")
		local Percent = (val - slider.Min) / (slider.Max - slider.Min)
		slider.Frame.Label.Text = slider.Name .. " - " .. val
		slider.Frame.Background.Slider:TweenSize(UDim2.new(Percent, 0, 1, 0), "InOut", "Sine", 0.08, true)
		slider.Callback(val)
	end
	slider.Frame.Background.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Library.Dragging = true
			slider.Dragging = true
		end
	end)
	slider.Frame.Background.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			slider.Dragging = false
			Library.Dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and slider.Dragging == true then
			local Percent = math.clamp((input.Position.X - slider.Frame.Background.AbsolutePosition.X) / slider.Frame.Background.AbsoluteSize.X, 0, 1)
			slider.Set(math.floor(slider.Min + (Percent * (slider.Max - slider.Min))))
		end
	end)
	return slider
end

function LoadDropdown(dropdown)
	dropdown.Frame = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		ClipsDescendants = true,
		Name = dropdown.Name,
		Parent = dropdown.Tab.Frame,
		Size = UDim2.new(1, -6, 0, 32),
		Create("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ClipsDescendants = true,
			Name = "Drop",
			Position = UDim2.new(0, 10, 0, 37),
			ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
			ScrollBarThickness = 3,
			Size = UDim2.new(1, -14, 0, 96),
			Create("UIListLayout", { })
		}),
		Create("TextButton", {
			BackgroundColor3 = Color3.fromRGB(89, 183, 248),
			Name = "Button",
			Position = UDim2.new(1, -28, 0, 4),
			Size = UDim2.new(0, 24, 0, 24),
			Text = ""
		}, true),
		Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = "Label",
			Position = UDim2.new(0, 5, 0, 0),
			Size = UDim2.new(1, -38, 0, 32),
			Text = dropdown.Name,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		Create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = "Description",
			Position = UDim2.new(0, 5, 0, 0),
			Size = UDim2.new(1, -38, 0, 32),
			Text = dropdown.Description,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right
		})
	}, true)
	dropdown.Frame.Drop.ChildAdded:Connect(function(child)
		Scale(dropdown.Frame.Drop)
	end)
	dropdown.Frame:GetPropertyChangedSignal("Size"):Connect(function()
		Scale(dropdown.Tab.Frame)
	end)
	dropdown.Frame.Button.MouseButton1Click:Connect(function()
		Ripple(dropdown.Frame.Button)
		dropdown.Opened = not dropdown.Opened
		dropdown.Frame.Button.BackgroundColor3 = dropdown.Opened and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(89, 183, 248)
		local Size = #dropdown.Items < 5 and (42 + (24 * #dropdown.Items)) or 138
		dropdown.Frame:TweenSize(UDim2.new(1, -6, 0, dropdown.Opened and Size or 32), "InOut", "Sine", 0.4, true)
	end)
	dropdown.AddItem = function(name)
		assert(name ~= nil, "function Dropdown.AddItem - anything expected.")
		name = tostring(name)
		if rawget(dropdown.Items, name) then
			dropdown.RemoveItem(name)
		end
		local Item = Create("TextButton", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Name = name,
			Parent = dropdown.Frame.Drop,
			Size = UDim2.new(1, 0, 0, 24),
			Text = name,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		Item.MouseButton1Click:Connect(function()
			dropdown.Callback(name)
		end)
		dropdown.Items[name] = Item
	end
	dropdown.RemoveItem = function(name)
		assert(name ~= nil and type(name) == "string", "function Dropdown.RemoveItem - string expected.")
		for i, v in next, dropdown.Items do
			if i == name and not v:IsA("UIListLayout") then
				table.remove(dropdown.Items, i)
				v:Destroy()
			end
		end
	end
	dropdown.SetItems = function(items)
		assert(items ~= nil and type(items) == "table", "function Dropdown.SetItems - table expected.")
		for i, v in next, dropdown.Frame.Drop:GetChildren() do
			if not v:IsA("UIListLayout") then
				v:Destroy()
			end
		end
		for i, v in next, items do
			if type(i) == "number" then
				dropdown.AddItem(v)
			end
		end
	end
	dropdown.SetItems(dropdown.Items)
	return dropdown
end

Library.AddTab = function(name)
	assert(Library.Gui, "function AddTab - Gui Has Not Been Initialised")
	local tab = {
		ButtonContainer = Library.Gui.Main.Left.Scroll,
		Container = Library.Gui.Main.Right,
		Name = name
	}
	tab.AddButton = function(name, desc, func)
		assert(name ~= nil and type(name) == "string", "function Tab.AddButton - string expected (arg 1)")
		assert(desc ~= nil and type(desc) == "string", "function Tab.AddButton - string expected (arg 2)")
		assert(func ~= nil and type(func) == "function", "function Tab.AddButton - function expected (arg 3)")
		return LoadButton({
			Callback = func or function() end,
			Description = desc,
			Name = name,
			Tab = tab
		})
	end
	tab.AddToggle = function(name, desc, func)
		assert(name ~= nil and type(name) == "string", "function Tab.AddToggle - string expected (arg 1)")
		assert(desc ~= nil and type(desc) == "string", "function Tab.AddToggle - string expected (arg 2)")
		assert(func ~= nil and type(func) == "function", "function Tab.AddToggle - function expected (arg 3)")
		return LoadToggle({
			Callback = func or function() end,
			Description = desc,
			Enabled = false,
			Name = name,
			Tab = tab
		})
	end
	tab.AddBox = function(name, desc, numonly, func)
		assert(name ~= nil and type(name) == "string", "function Tab.AddBox - string expected (arg 1)")
		assert(desc ~= nil and type(desc) == "string", "function Tab.AddBox - string expected (arg 2)")
		assert(numonly ~= nil and type(numonly) == "boolean", "function Tab.AddBox - bool expected (arg 3)")
		assert(func ~= nil and type(func) == "function", "function Tab.AddBox - function expected (arg 4)")
		return LoadBox({
			Callback = func or function() end,
			Description = desc,
			Name = name,
			NumbersOnly = numonly,
			Tab = tab,
			Value = ""
		})
	end
	tab.AddKeybind = function(name, desc, func)
		assert(name ~= nil and type(name) == "string", "function Tab.AddToggle - string expected (arg 1)")
		assert(desc ~= nil and type(desc) == "string", "function Tab.AddToggle - string expected (arg 2)")
		assert(func ~= nil and type(func) == "function", "function Tab.AddToggle - function expected (arg 3)")
		return LoadKeybind({
			Callback = func or function() end,
			Description = desc,
			Name = name,
			Tab = tab,
			Value = nil
		})
	end
	tab.AddSlider = function(name, desc, min, max, func)
		assert(name ~= nil and type(name) == "string", "function Tab.AddToggle - string expected (arg 1)")
		assert(desc ~= nil and type(desc) == "string", "function Tab.AddToggle - string expected (arg 2)")
		assert(min ~= nil and type(min) == "number", "function Tab.AddToggle - number expected (arg 3)")
		assert(max ~= nil and type(max) == "number", "function Tab.AddToggle - number expected (arg 4)")
		assert(func ~= nil and type(func) == "function", "function Tab.AddToggle - function expected (arg 5)")
		return LoadSlider({
			Callback = func or function() end,
			Description = desc,
			Dragging = false,
			Min = min,
			Max = max,
			Name = name,
			Tab = tab
		})
	end
	tab.AddDropdown = function(name, desc, items, func)
		assert(name ~= nil and type(name) == "string", "function Tab.AddDropdown - string expected (arg 1)")
		assert(desc ~= nil and type(desc) == "string", "function Tab.AddDropdown - string expected (arg 2)")
		assert(items ~= nil and type(items) == "table", "function Tab.AddDropdown - table expected (arg 3)")
		assert(func ~= nil and type(func) == "function", "function Tab.AddDropdown - function expected (arg 4)")
		return LoadDropdown({
			Callback = func or function() end,
			Description = desc,
			Items = items,
			Name = name,
			Opened = false,
			Tab = tab
		})
	end
	return LoadTab(tab)
end

Library.Init = function(name)
	Library.Gui = Create("ScreenGui", {
		Name = "Project: Evolution",
		Parent = CoreGui,
		Create("ImageLabel", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			ClipsDescendants = true,
			Image = "rbxassetid://5997008502",
			Name = "Main",
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Selectable = true,
			Size = UDim2.new(0, 580, 0, 356),
			Create("Frame", {
				BackgroundTransparency = 1,
				Name = "Left",
				Size = UDim2.new(0, 205, 1, 0),
				Create("ScrollingFrame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ClipsDescendants = true,
					Name = "Scroll",
					Position = UDim2.new(0, 10, 0, 55),
					ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
					ScrollBarThickness = 3,
					Size = UDim2.new(1, -14, 1, -65),
					Create("UIListLayout", {
						Padding = UDim.new(0, 5),
						SortOrder = Enum.SortOrder.LayoutOrder
					})
				}),
				Create("ImageButton", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://5997008398",
					Name = "Close",
					Position = UDim2.new(0, 10, 0, 10),
					Size = UDim2.new(0, 35, 0, 35)
				}),
				Create("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Name = "Title",
					Position = UDim2.new(0, 55, 0, 10),
					Size = UDim2.new(1, -55, 0, 35),
					Text = "Project: Evolution",
					TextColor3 = Color3.fromRGB(220, 220, 220),
					TextSize = 17,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			}),
			Create("Frame", {
				Name = "Separation",
				Position = UDim2.new(0, 205, 0, 0),
				Size = UDim2.new(0, 5, 1, 0),
				Create("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(22, 22, 22)),
					Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 0), NumberSequenceKeypoint.new(0.6, 0.4), NumberSequenceKeypoint.new(1, 1) })
				})
			}),
			Create("Frame", {
				BackgroundTransparency = 1,
				Name = "Right",
				Position = UDim2.new(0, 210, 0, 0),
				Size = UDim2.new(1, -210, 1, 0),
				Create("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Name = "Game",
					Position = UDim2.new(0, 10, 0, 10),
					Size = UDim2.new(0, 350, 0, 35),
					Text = name,
					TextColor3 = Color3.fromRGB(220, 220, 220),
					TextSize = 17,
					TextXAlignment = Enum.TextXAlignment.Left
				}),
				Create("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Name = "Tab",
					Position = UDim2.new(0, 10, 0, 10),
					Size = UDim2.new(0, 350, 0, 35),
					Text = "",
					TextColor3 = Color3.fromRGB(220, 220, 220),
					TextSize = 17,
					TextXAlignment = Enum.TextXAlignment.Right
				})
			})
		}, true)
	})
	Library.Gui.Main.Left.Close.MouseButton1Click:Connect(function()
		Library.Opened = not Library.Opened
		Library.Gui.Main:TweenSize(UDim2.new(0, Library.Opened and 580 or 205, 0, Library.Opened and 356 or 55), "InOut", "Sine", 0.4, true)
	end)
	Library.Gui.Main.Left.Scroll.ChildAdded:Connect(function(child)
		Scale(Library.Gui.Main.Left.Scroll)
	end)
	MakeDraggable(Library.Gui.Main)
	local Label = Library.Gui.Main.Left.Title
	local function TypeWord(word)
		for i = 1, #word do
			if string.find(Label.Text, "|") then
				Label.Text = string.sub(Label.Text, 1, #Label.Text - 1)
			end
			Label.Text = Label.Text .. string.sub(word, i, i) .. "|"
			wait(math.random(5, 15) / 100)
		end
		Label.Text = string.sub(Label.Text, 1, #Label.Text - 1)
	end
	local function FlickerLine()
		Label.Text = Label.Text .. "|"
		wait(0.5)
		Label.Text = string.sub(Label.Text, 1, #Label.Text - 1)
		wait(0.5)
	end
	coroutine.wrap(function()
		while wait(5) do
			Label.Text = ""
			FlickerLine()
			TypeWord("Project: ")
			FlickerLine()
			TypeWord("Evolution")
			FlickerLine()
			FlickerLine()
		end
	end)()
end

return Library