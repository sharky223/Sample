local DataStore2 = require(script.DataStore2)
local key = "MasterKey"
DataStore2.Combine(key, "Stats", "Accessories")

local TweenService = game:GetService("TweenService")
local remote = game.ReplicatedStorage.Rocket

local globalCoinsData = game:GetService("DataStoreService"):GetOrderedDataStore("CoinsData")
local globalHeightData = game:GetService("DataStoreService"):GetOrderedDataStore("HeightData")

local plrsData = {}
local plrsShop = {}
local plrsStats = {}
local plrsBonus = {}
local bonusData = {
		b1 = workspace.Breakables.B1;
		b1w = false;
		b2 = workspace.Breakables.B2;
		b2w = false;
		b3 = workspace.Breakables.B3;
		b3w = false;
		b4 = workspace.Breakables.B4;
		b4w = false;
		b5 = workspace.Breakables.B5;
		b5w = false;
		bonus = 0;
		liftoff = false;
}
local plrPos = {}

local HardeningLevels = {
		500,20000,300000,1000000,20000000,500000000
		}

function setDataTable()
	local userData = {
		Stats = {
			Coins = 0;
			Fuel = 0;
			Heat = 0;
			Income = 0;
			Speed = 0;
			Hardening = 0;
			MaxHeight = 0;
		};
		Accessories = {
			Skins = false
		};
	}
	return userData
end

game.Players.PlayerAdded:Connect(function(plr)
	plrsBonus[plr.Name] = bonusData
	
	--Move Rocket
	if(workspace:FindFirstChild("Rocket")) then
		workspace.Rocket.Parent = game.ServerStorage
	end
	
	--MoveUI
	if(game.StarterGui:FindFirstChild("Shop")) then
		game.StarterGui.Shop.Parent = script
	end
	
	local char = plr.Character or plr.CharacterAdded:Wait()
	
	game.ServerStorage.RocketSpawner:Clone().Parent = plr:WaitForChild("Backpack")
	
	--Variables
	local val = Instance.new("StringValue",plr)
	val.Name = "Activated"
	val.Value = "Respawn"
	local dataStore = DataStore2(key,plr):Get(setDataTable())
	plrsData[plr.Name] = dataStore
	
	local stats = Instance.new("Folder",plr) stats.Name = "Stats"
	local fuel = Instance.new("IntValue",stats) fuel.Name = "Fuel"
	local heat = Instance.new("IntValue",stats) heat.Name = "Heat"
	local income = Instance.new("NumberValue",stats) income.Name = "Income"
	local speed = Instance.new("IntValue", stats) speed.Name = "Speed"
	local harden = Instance.new("IntValue", stats) harden.Name = "Hardening"
	local maxfuel = Instance.new("IntValue",stats) maxfuel.Name = "MaxFuel"
	local maxheat = Instance.new("IntValue",stats) maxheat.Name = "MaxHeat"
	local maxheight = Instance.new("IntValue",plr) maxheight.Name = "MaxHeight"
	
	--UI
	local shop = script.Shop:Clone()
	shop.Parent = plr:WaitForChild("PlayerGui")
	local bg = shop:WaitForChild("BG")
	local buttons = bg:WaitForChild("Buttons")
	local fuelB = buttons:WaitForChild("Fuel")
	local heatB = buttons:WaitForChild("Heat")
	local incomeB = buttons:WaitForChild("Income")
	local hardenB = buttons:WaitForChild("Hardening")
	local speedB = buttons:WaitForChild("Speed")
	local reward = bg:WaitForChild("Reward")
	local rewardC = reward:WaitForChild("CoinsI") 
	--DataStore2 Data
	local statsData = DataStore2("Stats",plr)
	plrsStats[plr.Name] = statsData
	local accessData = DataStore2("Accessories",plr)
	plrsShop[plr.Name] = shop
	--Stat functions
	local function updateStats(val)
		bg:WaitForChild("CoinsF"):WaitForChild("CoinsI"):WaitForChild("Coins").Text = statsData:Get(val).Coins
		plr.Stats.Fuel.Value = 50 + statsData:Get(val).Fuel * 5
		plr.Stats.Heat.Value = 0
		plr.Stats.Income.Value = 1 + statsData:Get(val).Income * .05
		plr.Stats.Speed.Value = 5 + statsData:Get(val).Speed * 2
		plr.Stats.MaxFuel.Value = 50 + statsData:Get(val).Fuel * 5
		plr.Stats.MaxHeat.Value = 30 + statsData:Get(val).Heat * 3
		fuelB.Coins.Text = math.floor(25^(1 + dataStore.Stats.Fuel * 0.04)).." Coins"
		incomeB.Coins.Text = math.floor(25^(1 + dataStore.Stats.Income * 0.05)).." Coins"
		heatB.Coins.Text = math.floor(25^(1 + dataStore.Stats.Heat * 0.052)).." Coins"
		speedB.Coins.Text = math.floor(25^(1 + dataStore.Stats.Speed * 0.045)).." Coins"
		speedB.Bubble.Level.Text = dataStore.Stats.Speed
		fuelB.Bubble.Level.Text = dataStore.Stats.Fuel
		heatB.Bubble.Level.Text = dataStore.Stats.Heat
		incomeB.Bubble.Level.Text = dataStore.Stats.Income
		if(dataStore.Stats.Hardening) then
			if(dataStore.Stats.Hardening < #HardeningLevels) then
				hardenB.Coins.Text = HardeningLevels[dataStore.Stats.Hardening+1].." Coins"
			else
				hardenB.Coins.Text = "Maxed"
			end
			hardenB.Bubble.Level.Text = dataStore.Stats.Hardening
		else
			dataStore.Stats["Hardening"] = 0
		end
	end
	
	updateStats(dataStore.Stats)
	statsData:OnUpdate(updateStats)
	
	local function purchaseFuel()
		local prob = 1 + dataStore.Stats.Fuel * 0.04
		if(dataStore.Stats.Coins >= math.floor(25^(prob))) then
			dataStore.Stats.Coins = math.floor(dataStore.Stats.Coins - 25^(prob))
			dataStore.Stats.Fuel = dataStore.Stats.Fuel + 1
			fuelB.Bubble.Level.Text = dataStore.Stats.Fuel
			statsData:Set(dataStore.Stats)
		end
	end
	
	local function purchaseHeat()
		if(dataStore.Stats.Heat > 0) then
			local prob = 1 + dataStore.Stats.Heat * 0.05
			if(dataStore.Stats.Coins >= math.floor(25^(prob))) then
				dataStore.Stats.Coins = math.floor(dataStore.Stats.Coins - 25^(prob))
				dataStore.Stats.Heat = dataStore.Stats.Heat + 1
				heatB.Bubble.Level.Text = dataStore.Stats.Heat
				statsData:Set(dataStore.Stats)
			end
		elseif(dataStore.Stats.Coins >= 25) then
			dataStore.Stats.Coins = dataStore.Stats.Coins - 25
			dataStore.Stats.Heat = dataStore.Stats.Heat + 1
			heatB.Bubble.Level.Text = dataStore.Stats.Heat
			statsData:Set(dataStore.Stats)
		end
	end
	
	local function purchaseIncome()
		local prob = 1 + dataStore.Stats.Income * 0.052
		if(dataStore.Stats.Coins >= math.floor(25^(prob))) then
			dataStore.Stats.Coins = math.floor(dataStore.Stats.Coins - 25^(prob))
			dataStore.Stats.Income = dataStore.Stats.Income + 1
			incomeB.Bubble.Level.Text = dataStore.Stats.Income
			statsData:Set(dataStore.Stats)
		end
	end
	
	local function purchaseSpeed()
		local prob = 1 + dataStore.Stats.Speed * 0.045
		if(dataStore.Stats.Coins >= math.floor(25^(prob))) then
			dataStore.Stats.Coins = math.floor(dataStore.Stats.Coins - 25^(prob))
			dataStore.Stats.Speed = dataStore.Stats.Speed + 1
			speedB.Bubble.Level.Text = dataStore.Stats.Speed
			statsData:Set(dataStore.Stats)
		end
	end
	
	local function purchaseHardening()
		if(dataStore.Stats.Coins >= HardeningLevels[dataStore.Stats.Hardening+1]) then
			dataStore.Stats.Coins = dataStore.Stats.Coins - HardeningLevels[dataStore.Stats.Hardening+1]
			dataStore.Stats.Hardening = dataStore.Stats.Hardening + 1
			hardenB.Bubble.Level.Text = dataStore.Stats.Hardening
			statsData:Set(dataStore.Stats)
		end
	end
	
	fuelB.MouseButton1Down:Connect(function()
		purchaseFuel()
	end)
	heatB.MouseButton1Down:Connect(function()
		purchaseHeat()
	end)
	incomeB.MouseButton1Down:Connect(function()
		purchaseIncome()
	end)
	speedB.MouseButton1Down:Connect(function()
		purchaseSpeed()
	end)
	hardenB.MouseButton1Down:Connect(function()
		purchaseHardening()
	end)
	
	local purchaseHandler = {
		Fuel = purchaseFuel;
		Heat = purchaseHeat;
		Speed = purchaseSpeed;
		Income = purchaseIncome;
		Harden = purchaseHardening;
	}
	
	coroutine.resume(coroutine.create(function()
		while wait(60) do
			local keyData = DataStore2(key, plr)
			keyData:Save()
		end
	end))
end)

function setBonus(plr,bool,bonusVal,hardening)
	print(plr.Name)
	if(plrsData[plr.Name].Stats.Hardening >= hardening) then
		if(bool == "b1w") then
			plrsBonus[plr.Name]["b1w"] = true
			plrsBonus[plr.Name]["bonus"] = bonusVal
		elseif(bool == "b2w") then
			plrsBonus[plr.Name]["b2w"] = true
			plrsBonus[plr.Name]["bonus"] = bonusVal
		elseif(bool == "b3w") then
			plrsBonus[plr.Name]["b3w"] = true
			plrsBonus[plr.Name]["bonus"] = bonusVal
		elseif(bool == "b4w") then
			plrsBonus[plr.Name]["b4w"] = true
			plrsBonus[plr.Name]["bonus"] = bonusVal
		elseif(bool == "b5w") then
			plrsBonus[plr.Name]["b5w"] = true
			plrsBonus[plr.Name]["bonus"] = bonusVal
		end
	else
		plr.Stats.Fuel.Value = 0
		plr.Stats.Heat.Value = 0
	end
end

remote.OnServerEvent:Connect(function(plr,...)
	local bg = plrsShop[plr.Name]:WaitForChild("BG")
	local buttons = bg:WaitForChild("Buttons")
	local fuelB = buttons:WaitForChild("Fuel")
	local heatB = buttons:WaitForChild("Heat")
	local incomeB = buttons:WaitForChild("Income")
	local speedB = buttons:WaitForChild("Speed")
	local reward = bg:WaitForChild("Reward")
	local rewardC = reward:WaitForChild("CoinsI")
	
	local args = {...}
	local rocket = workspace.Rockets:FindFirstChild(plr.Name)
	if(not rocket or plr.Activated.Value == "End") then return end
	if(args[1] == "Activate" and plr.Activated.Value ~= "Respawn" and plr.Activated.Value ~= "Down" and plr.Activated.Value ~= "Down2") then
		rocket.Rocket.Up:Play()
		if(not plrsBonus[plr.Name].LiftOff) then
			rocket.Rocket.LiftOff:Play()
			plrsBonus[plr.Name].LiftOff = true
		end
		rocket.Part.Fire.Enabled = true
		plr.Activated.Value = "Ascend"
		local speed = plr.Stats.Speed.Value
		local goal = rocket.Rocket.Position + Vector3.new(0,1000000,0)
		local distance = (rocket.Rocket.Position - goal).Magnitude
		local tTime = distance / speed
		local g = {}
		g.Position = goal
		local info = TweenInfo.new(tTime)
		local tween = TweenService:Create(rocket.Rocket, info, g)
		tween:Play()
		if(plr.Activated.Value ~= "Ascend") then
			tween:Cancel()
		end
		coroutine.resume(coroutine.create(function()
			if(rocket.Part.Smoke.Enabled == true) then
				wait(2)
				rocket.Part.Smoke.Enabled = false
			end
		end))
		while true do
			local rocketPos,rocketSize = rocket.Rocket.Position, rocket.Rocket.Size
			if(not plrsBonus[plr.Name]["b1w"] and rocketPos.Y + rocketSize.Y/2 >= plrsBonus[plr.Name]["b1"].Position.Y-plrsBonus[plr.Name]["b1"].Size.Y/2) then
				setBonus(plr,"b1w",5,1)
			elseif(not plrsBonus[plr.Name]["b2w"] and rocketPos.Y + rocketSize.Y/2 >= plrsBonus[plr.Name]["b2"].Position.Y-plrsBonus[plr.Name]["b2"].Size.Y/2) then
				setBonus(plr,"b2w",10,2)
			elseif(not plrsBonus[plr.Name]["b3w"] and rocketPos.Y + rocketSize.Y/2 >= plrsBonus[plr.Name]["b3"].Position.Y-plrsBonus[plr.Name]["b3"].Size.Y/2) then
				setBonus(plr,"b3w",20,3)
			elseif(not plrsBonus[plr.Name]["b4w"] and rocketPos.Y + rocketSize.Y/2 >= plrsBonus[plr.Name]["b4"].Position.Y-plrsBonus[plr.Name]["b4"].Size.Y/2) then
				setBonus(plr,"b4w",50,4)
			elseif(not plrsBonus[plr.Name]["b5w"] and rocketPos.Y + rocketSize.Y/2 >= plrsBonus[plr.Name]["b5"].Position.Y-plrsBonus[plr.Name]["b5"].Size.Y/2) then
				setBonus(plr,"b5w",100,5)
			end
			print(plrsBonus[plr.Name]["bonus"])
			local rocketY = rocketPos.Y + rocketSize.Y / 2
			local bPlateY = workspace.Baseplate.Position.Y + workspace.Baseplate.Size.Y / 2
			local mag = (Vector3.new(rocketPos.X, rocketY, rocketPos.Z) - Vector3.new(rocketPos.X, bPlateY, rocketPos.Z)).Magnitude
			if(plr.MaxHeight.Value < mag) then
				plr.MaxHeight.Value = mag
			end
			if(plr.Activated.Value ~= "Ascend") then return end
			if(plr.Stats.Fuel.Value <= 0) then
				plr.Activated.Value = "End"
				plr.Stats.Fuel.Value = plr.Stats.MaxFuel.Value
				plr.Stats.Heat.Value = 0
				rocket.Rocket.Up:Stop()
				local num = speed
				local subtract = num / 5
				for i = num,0, -subtract do
					speed = i
					goal = rocket.Rocket.Position + Vector3.new(0,1000000,0)
					distance = (rocket.Rocket.Position - goal).Magnitude
					tTime = distance / speed
					g = {}
					g.Position = goal
					tween = TweenService:Create(rocket.Rocket, TweenInfo.new(tTime), g)
					tween:Play()
					wait(.1)
				end
				plr.Activated.Value = "Down"
				tween:Cancel()
				rocket.Part.Fire.Enabled = false
				speed = 10
				local rocketPos,rocketSize = rocket.Rocket.Position, rocket.Rocket.Size
				local rocketY = rocketPos.Y - rocketSize.Y / 2
				local bPlateY = workspace.Baseplate.Position.Y + workspace.Baseplate.Size.Y / 2
				local mag = (Vector3.new(rocketPos.X, rocketY, rocketPos.Z) - Vector3.new(rocketPos.X, bPlateY, rocketPos.Z)).Magnitude
				goal = rocket.Rocket.Position - Vector3.new(0,mag,0)
				distance = (rocket.Rocket.Position - goal).Magnitude
				tTime = distance / speed
				g = {}
				g.Position = goal
				info = TweenInfo.new(tTime)
				tween = TweenService:Create(rocket.Rocket, info, g)
				tween:Play()
				local CoinsGained = (plr.MaxHeight.Value * 2.1) * plr.Stats.Income.Value
				plrsBonus[plr.Name].LiftOff = false
				if(plrsBonus[plr.Name]["bonus"] > 0) then
					CoinsGained = CoinsGained * plrsBonus[plr.Name]["bonus"]
				end
				plrsData[plr.Name].Stats.Coins = plrsData[plr.Name].Stats.Coins + math.floor(CoinsGained)
				plrsStats[plr.Name]:Set(plrsData[plr.Name].Stats)
				wait(2)
				reward.Visible = true
				rewardC:WaitForChild("Coins").Text = math.floor(CoinsGained)
				reward:WaitForChild("Height").Text = "Height: "..plr.MaxHeight.Value
				plr.Activated.Value = "Respawn"
				rocket.Part.Smoke.Enabled = true
				tween:Cancel()
				wait()
				rocket:Destroy()
				game.ServerStorage.RocketSpawner:Clone().Parent = plr.Backpack
				plr.MaxHeight.Value = 0
				return
			end
			if(plr.Stats.Fuel.Value >= 3) then
				plr.Stats.Fuel.Value = plr.Stats.Fuel.Value - 3
			else
				plr.Stats.Fuel.Value = 0
			end
			if(plr.Stats.Heat.Value <= plr.Stats.MaxHeat.Value - 2) then
				plr.Stats.Heat.Value = plr.Stats.Heat.Value + 2
			else
				plr.Stats.Heat.Value = plr.Stats.MaxHeat.Value
			end
			if(plr.Stats.Heat.Value >= plr.Stats.MaxHeat.Value) then
				tween:Cancel()
				plr.Activated.Value = "Down2"
				rocket.Rocket.Up:Stop()
				local rocketPos,rocketSize = rocket.Rocket.Position, rocket.Rocket.Size
				local bPlateY = workspace.Baseplate.Position.Y + workspace.Baseplate.Size.Y / 2
				local CoinsGained = (plr.MaxHeight.Value * .3) * plr.Stats.Income.Value
				plrsBonus[plr.Name].LiftOff = false
				if(plrsBonus[plr.Name]["bonus"] > 0) then
					CoinsGained = CoinsGained * plrsBonus[plr.Name]["bonus"]
				end
				for i,v in pairs(rocket:GetDescendants()) do
					if(v:IsA("BasePart")) then
						v.Transparency = 1
						v.Anchored = true
						v.CanCollide = false
					end
				end
				plrsData[plr.Name].Stats.Coins = plrsData[plr.Name].Stats.Coins + math.floor(CoinsGained)
				plrsStats[plr.Name]:Set(plrsData[plr.Name].Stats)
				local explode = game.ServerStorage.Explode:Clone()
				explode.Parent = workspace
				explode.CFrame = CFrame.new(rocketPos)
				explode.Explosion:Emit(5)
				
				wait(3)
				rocket:Destroy()
				game.ServerStorage.RocketSpawner:Clone().Parent = plr.Backpack
				reward.Visible = true
				rewardC:WaitForChild("Coins").Text = math.floor(CoinsGained)
				reward:WaitForChild("Height").Text = "Height: "..plr.MaxHeight.Value
				plr.Activated.Value = "Respawn"
				local rocketPart = rocket:FindFirstChild("Part")
				if(rocketPart and rocket.Part:FindFirstChild("Smoke")) then
					rocket:WaitForChild("Part"):WaitForChild("Smoke").Enabled = true
				end
				explode:Destroy()
				plr.MaxHeight.Value = 0
				return
			end
			wait(.1)
		end
	elseif(args[1] == "Deactivate" and plr.Activated.Value == "Ascend") then
		rocket.Rocket.Up:Stop()
		rocket.Part.Fire.Enabled = false
		plr.Activated.Value = "Descend"
		coroutine.resume(coroutine.create(function()
			while plr.Activated.Value == "Descend" do
				if(plr.Stats.Heat.Value >= 2) then
					if(plr.Stats.MaxHeat.Value / 50 > 2) then
						plr.Stats.Heat.Value = plr.Stats.Heat.Value - plr.Stats.MaxHeat.Value / 100
					else
						plr.Stats.Heat.Value = plr.Stats.Heat.Value - 2
					end
				elseif(plr.Stats.Heat.Value == 1) then
					plr.Stats.Heat.Value = 0
				else
					return
				end
				wait(.1)
			end
		end))
		local speed = 1
		local rocketPos,rocketSize = rocket.Rocket.Position, rocket.Rocket.Size
		local rocketY = rocketPos.Y - rocketSize.Y / 2
		local bPlateY = workspace.Baseplate.Position.Y + workspace.Baseplate.Size.Y / 2
		local mag = (Vector3.new(rocketPos.X, rocketY, rocketPos.Z) - Vector3.new(rocketPos.X, bPlateY, rocketPos.Z)).Magnitude
		local goal = rocket.Rocket.Position - Vector3.new(0,mag,0)
		local distance = (rocket.Rocket.Position - goal).Magnitude
		local tTime = distance / speed
		local g = {}
		g.Position = goal
		local info = TweenInfo.new(tTime)
		local tween = TweenService:Create(rocket.Rocket, info, g)
		if(plr.Activated.Value ~= "Descend") then
			return
		end
		tween:Play()
		for i = 1,33,3 do
			if(plr.Activated.Value ~= "Descend") then
				return
			end
			speed = i
			tTime = distance / speed
			info = TweenInfo.new(tTime)
			tween = TweenService:Create(rocket.Rocket, info, g)
			tween:Play()
			wait(.1)
		end
--		elseif(args[1] == "Purchase" and plr.Activated.Value == "Respawn" and plr.Activated.Value ~= "Down" and plr.Activated.Value ~= "Down2") then
--			local purchaseFunction = purchaseHandler[args[2]]
--			if(purchaseFunction) then
--				purchaseFunction()
--			end
	elseif(args[1] == "Play" and plr.Activated.Value == "Respawn") then
		rocket.Rocket.Up:Stop()
		plr.Activated.Value = ""
	end
	
	plr.CharacterAdded:Connect(function(char)
		if(not workspace.Rockets:FindFirstChild(plr.Name)) then
			game.ServerStorage.RocketSpawner:Clone().Parent = plr:WaitForChild("Backpack")
		end
	end)
end)

game.Players.PlayerRemoving:Connect(function(plr)
	if(workspace.Rockets:FindFirstChild(plr.Name)) then
		workspace.Rockets[plr.Name]:Destroy()
	end
end)
