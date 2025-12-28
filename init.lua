
local loadonscreen = not game:IsLoaded()

repeat
	task.wait()
until game:IsLoaded()

if loadonscreen then
    task.wait(2)
end

if shared.vape then
	shared.vape:Uninject()
end

local license = ({...})[1] or {}
local developer =  license.Developer or getgenv().catvapedev or false
local closet = license.Closet or getgenv().closet or false
local commit = license.Commit or nil

local BRAND_NAME = 'Not Cheating Scripts'

-- Your GitHub repository
local GITHUB_USER = 'hypercat112-max'
local GITHUB_REPO = 'bedwars-loader'

local loadstring = function(...)
	local res, err = loadstring(...)
	if err then
		error(err)
	end
	return res
end

if not commit or commit == 'main' then
	local success, subbed = pcall(function()
		return game:HttpGet('https://github.com/'..GITHUB_USER..'/'..GITHUB_REPO)
	end)
	
	if success and subbed and type(subbed) == 'string' then
		commit = subbed:find('currentOid')
		commit = commit and subbed:sub(commit + 13, commit + 52) or nil
		commit = commit and #commit == 40 and commit or 'main'

		if commit and #commit > 7 then
			commit = commit:sub(1, 7)
		end
	else
		commit = 'main'
	end
end

local cloneref = cloneref or function(ref) return ref end
local gethui = gethui or function() return game:GetService('Players').LocalPlayer.PlayerGui end

local inputService = cloneref(game:GetService('UserInputService'))
local tweenService = cloneref(game:GetService('TweenService'))
local guiService = cloneref(game:GetService('GuiService'))
local httpService = cloneref(game:GetService('HttpService'))

local gui : ScreenGui = Instance.new('ScreenGui', gethui())
gui.Enabled = not closet

local Connections: {RBXScriptConnection} = {}

local stages = {
	UDim2.new(0, 50, 1, 0),
	UDim2.new(0, 100, 1, 0),
	UDim2.new(0, 160, 1, 0),
	UDim2.new(0, 200, 1, 0),
	UDim2.new(0, 240, 1, 0)
}

local function createinstance(class : string, properties : {[string] : any})
	local res = Instance.new(class)
	
	for property, value in properties do
		res[property] = value
	end

	return res
end

local function addCallback(image : ImageLabel | ImageButton, ...)
	if not (image:IsA('ImageLabel') or image:IsA('ImageButton')) then
		return
	end
	
	local Original = image.ImageColor3
	
	table.insert(Connections, image.MouseEnter:Connect(function()  
		tweenService:Create(image, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			ImageColor3 = Color3.fromRGB(44, 43, 44)
		}):Play()
	end))

	table.insert(Connections, image.MouseLeave:Connect(function()  
		tweenService:Create(image, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			ImageColor3 = Original
		}):Play()
	end))

	table.insert(Connections, image.MouseButton1Click:Connect(...))
end

if closet then
	task.spawn(function()
		repeat
			for _, v in getconnections(game:GetService('LogService').MessageOut) do
				v:Disable()
			end

			for _, v in getconnections(game:GetService('ScriptContext').Error) do
				v:Disable()
			end

			task.wait(1)
		until not getgenv().closet
	end)
end

if gui.Enabled then
	local window = createinstance('ImageLabel', {
		Name = 'Main',
		Parent = gui,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(685, 399),
		ZIndex = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ScaleType = Enum.ScaleType.Fit,
		Image = 'rbxassetid://93496634716737'
	})

	local scale = Instance.new('UIScale', window)
	scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.485)
	
	window.InputBegan:Connect(function(inputObj)
		if
			(inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
			and (inputObj.Position.Y - window.AbsolutePosition.Y < 40)
		then
			local dragPosition = Vector2.new(
				window.AbsolutePosition.X - inputObj.Position.X,
				window.AbsolutePosition.Y - inputObj.Position.Y + guiService:GetGuiInset().Y
			) / scale.Scale

			local changed = inputService.InputChanged:Connect(function(input)
				if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					local position = input.Position
					if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						dragPosition = (dragPosition // 3) * 3
						position = (position // 3) * 3
					end
					window.Position = UDim2.fromOffset((position.X / scale.Scale) + dragPosition.X, (position.Y / scale.Scale) + dragPosition.Y)
				end
			end)

			local ended
			ended = inputObj.Changed:Connect(function()
				if inputObj.UserInputState == Enum.UserInputState.End then
					if changed then
						changed:Disconnect()
					end
					if ended then
						ended:Disconnect()
					end
				end
			end)
		end
	end)

	local exit = createinstance('ImageButton', {
		Name = 'Exit',
		Parent = window,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(624, 23),
		Size = UDim2.fromOffset(40, 30),
		AutoButtonColor = false,
		ZIndex = 2,
		ImageColor3 = Color3.fromRGB(34, 33, 34),
		Image = 'rbxassetid://110629770884920',
		ScaleType = Enum.ScaleType.Fit
	})

	addCallback(exit, function()
		gui.Enabled = false
	end)

	createinstance('ImageLabel', {
		Name = 'Icon',
		Parent = exit,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		ZIndex = 2,
		AnchorPoint = Vector2.new(0, 0.5),
		ImageTransparency = 0.4,
		ImageColor3 = Color3.new(1, 1, 1),
		Image = 'rbxassetid://128518278755224',
		ScaleType = Enum.ScaleType.Fit
	})

	local minimize = createinstance('ImageButton', {
		Name = 'Minimize',
		Parent = window,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(582, 23),
		ZIndex = 2,
		Size = UDim2.fromOffset(40, 30),
		AutoButtonColor = false,
		ImageColor3 = Color3.fromRGB(34, 33, 34),
		Image = 'rbxassetid://133363055871405',
		ScaleType = Enum.ScaleType.Fit
	})

	addCallback(minimize, function() end)

	createinstance('ImageLabel', {
		Name = 'Icon',
		Parent = minimize,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(0, 0.5),
		ImageTransparency = 0.4,
		ImageColor3 = Color3.new(1, 1, 1),
		Image = 'rbxassetid://83568668289707',
		ScaleType = Enum.ScaleType.Fit
	})

	createinstance('TextLabel', {
		Name = 'Title',
		Parent = window,
		AnchorPoint = Vector2.new(0.48, 0.31),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Position = UDim2.fromScale(0.48, 0.31),
		Size = UDim2.fromOffset(200, 40),
		Text = BRAND_NAME,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 16,
		Font = Enum.Font.Arial,
		TextStrokeTransparency = 0.5
	})

	createinstance('Frame', {
		Name = 'loadbar',
		Parent = window,
		AnchorPoint = Vector2.new(0.5, 0.53),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BorderSizePixel = 0,
		ZIndex = 2,
		Position = UDim2.fromScale(0.5, 0.53),
		Size = UDim2.fromOffset(240, 6)
	})

	createinstance('Frame', {
		Name = 'fullbar',
		Parent = window.loadbar,
		BackgroundColor3 = Color3.fromRGB(3, 102, 79),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		ZIndex = 2
	})

	createinstance('TextLabel', {
		Name = 'action',
		Parent = window,
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.353284657, 0.556391001),
		Size = UDim2.fromOffset(200, 15),
		Font = Enum.Font.Arial,
		ZIndex = 2,
		Text = '',
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 12,
		TextTransparency = 0.3
	})

	Instance.new('UICorner', window.loadbar)
	Instance.new('UICorner', window.loadbar.fullbar)

	task.spawn(function()
		repeat 
			task.wait()
			local ok = pcall(function()
				return shared.vape and shared.vape.Loaded
			end)
		until ok and shared.vape and shared.vape.Loaded

		task.wait(2)

		pcall(function()
			gui:Destroy()
		end)
	end)
end;

local debug = debug

if table.find({'Xeno', 'Solara'}, ({identifyexecutor()})[1]) then
	debug = table.clone(debug)
	debug.getupvalue = nil
	debug.getconstant = nil
	debug.setstack = nil

	getgenv().debug = debug
end

local canDebug = debug.getupvalue ~= nil

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = nil, nil
		local attempts = 0
		local maxAttempts = 3
		
		repeat
			attempts = attempts + 1
			suc, res = pcall(function()
				local subbed = path:gsub('catrewrite/', '')
				subbed = subbed:gsub(' ', '%%20')
				local url = 'https://raw.githubusercontent.com/'..GITHUB_USER..'/'..GITHUB_REPO..'/'..commit..'/'..subbed
				local response = game:HttpGet(url, true)
				if not response or response == '' then
					error('Empty response from server')
				end
				return response
			end)
			
			if not suc or res == '404: Not Found' or not res then
				if attempts < maxAttempts then
					warn(`[${BRAND_NAME}] Failed to download {path} (attempt {attempts}/{maxAttempts}), retrying...`)
					task.wait(2)
				else
					warn(`[${BRAND_NAME}] Failed to download {path} after {maxAttempts} attempts: {res}`)
					-- Try downloading from original repo as fallback
					local fallbackSuc, fallbackRes = pcall(function()
						local subbed = path:gsub('catrewrite/', '')
						subbed = subbed:gsub(' ', '%%20')
						return game:HttpGet('https://raw.githubusercontent.com/new-qwertyui/CatV5/'..commit..'/'..subbed, true)
					end)
					if fallbackSuc and fallbackRes and fallbackRes ~= '404: Not Found' then
						warn(`[${BRAND_NAME}] Using fallback repo for {path}`)
						res = fallbackRes
						suc = true
					else
						error(res or 'Download failed after retries')
					end
				end
			end
		until suc or attempts >= maxAttempts
		
		if suc and res then
			pcall(function()
				writefile(path, res)
			end)
		else
			error('Failed to download '..path)
		end
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('init') then continue end
		if isfile(file) then
			delfile(file)
		end
	end
end 

local function makestage(stage, package)
	if gui.Enabled and gui.Main and gui.Main.loadbar and gui.Main.loadbar.fullbar then
		tweenService:Create(gui.Main.loadbar.fullbar, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Size = stages[stage]
		}):Play()
		if gui.Main.action then
			gui.Main.action.Text = package or ''
		end
	end
end

makestage(1, 'Downloading packages')

for _, folder in {'catrewrite', 'catrewrite/communication', 'catrewrite/translations', 'catrewrite/games', 'catrewrite/cache', 'catrewrite/games/bedwars', 'catrewrite/profiles', 'catrewrite/assets', 'catrewrite/libraries', 'catrewrite/libraries/Enviroments', 'catrewrite/guis', 'catrewrite/libraries/Weather', 'catrewrite/libraries/LightningLib', 'catrewrite/libraries/LightningLib/Sparks'} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

if (not license.Developer and not shared.VapeDeveloper) then
	local Updated: boolean = (commit == 'main' or (isfile('catrewrite/profiles/commit.txt') and readfile('catrewrite/profiles/commit.txt') or '') ~= commit)

	if Updated then
		wipeFolder('catrewrite')
		wipeFolder('catrewrite/games')
		wipeFolder('catrewrite/guis')
		wipeFolder('catrewrite/cache')
		wipeFolder('catrewrite/libraries')
	end
	
	if #listfiles('catrewrite/profiles') <= 2 then
		makestage(2, 'Downloading config, This may take up to 20s')

		local preloaded = pcall(function()
			local apiResponse = game:HttpGet('https://api.github.com/repos/'..GITHUB_USER..'/'..GITHUB_REPO..'/contents/profiles')
			if not apiResponse or apiResponse == '' then
				error('Empty API response')
			end
			local req = httpService:JSONDecode(apiResponse)
			
			if not req or type(req) ~= 'table' then
				error('Invalid API response format')
			end

			for _, v in req do
				if v and v.path and v.path ~= 'profiles/commit.txt' then
					pcall(downloadFile, `catrewrite/{v.path}`)
				end
			end
		end)

		if not preloaded then
			makestage(2, `Failed to download preset config ({identifyexecutor()}), Will recontinue in 2 seconds.`)
			task.wait(2)
		end
	end

	if #listfiles('catrewrite/translations') <= 2 then
		makestage(2, 'Skipping translations (optional)')
	end
	
	if not canDebug and Updated then
		makestage(2, 'Skipping cache (optional)')
	end
end

writefile('catrewrite/profiles/commit.txt', commit)

makestage(3, 'Downloading core libraries...')
pcall(downloadFile, 'catrewrite/libraries/pathfind.lua')
pcall(downloadFile, 'catrewrite/init.lua')
pcall(downloadFile, 'catrewrite/libraries/oldpath.lua')

makestage(4, 'Loading main script...')

shared.VapeDeveloper = developer
getgenv().used_init = true
getgenv().catvapedev = developer
getgenv().closet = closet
getgenv().makestage = makestage
getgenv().canDebug = canDebug

getgenv().username = license.Username or getgenv().username
getgenv().password = license.Password or getgenv().password

local errorHandlerConnection
local errorCount = 0
local lastErrorTime = 0
local seenErrors = {}
local errorSuppressTime = {}
local errorHandlerEnabled = true

task.spawn(function()
	local ScriptContext = game:GetService('ScriptContext')
	
	errorHandlerConnection = ScriptContext.Error:Connect(function(message, trace, script)
		if not errorHandlerEnabled then
			return true
		end
		
		local msgStr = tostring(message)
		local currentTime = tick()
		
		if currentTime - lastErrorTime > 10 then
			errorCount = 0
			seenErrors = {}
			errorSuppressTime = {}
		end
		errorCount = errorCount + 1
		lastErrorTime = currentTime
		
		if errorCount > 10 then
			return true
		end
		
		if errorCount > 30 then
			warn(`[${BRAND_NAME}] Too many errors ({errorCount}), disabling error handler to prevent crash...`)
			errorHandlerEnabled = false
			pcall(function()
				if errorHandlerConnection then
					errorHandlerConnection:Disconnect()
				end
			end)
			return true
		end
		
		local errorKey = msgStr:match('^[^:]+') or msgStr:sub(1, 50)
		if seenErrors[errorKey] then
			seenErrors[errorKey] = seenErrors[errorKey] + 1
			if seenErrors[errorKey] > 3 then
				if not errorSuppressTime[errorKey] or currentTime - errorSuppressTime[errorKey] > 60 then
					errorSuppressTime[errorKey] = currentTime
				end
				return true
			end
		else
			seenErrors[errorKey] = 1
		end
		
		if msgStr:find('accessory') or msgStr:find('wing') or msgStr:find('character') or 
		   msgStr:find('Could not find') or msgStr:find('Failed to update') or
		   msgStr:find('HumanoidRootPart') or msgStr:find('is not a valid member') or
		   msgStr:find('C0') or msgStr:find('Co is not') or
		   msgStr:find('Parent property') or msgStr:find('is locked') or
		   msgStr:find('spirit_dagger') or msgStr:find('spirit-assassin') then
			return true
		end
		
		return true
	end)
end)

local function runMainWithRetries()
	local lastErr = nil

	for attempt = 1, 3 do
		local ok, err = xpcall(function()
			local success, result = pcall(function()
				return loadstring(downloadFile('catrewrite/main.lua'), 'main')
			end)
			
			if success and result then
				local execOk, execErr = xpcall(result, function(err)
					local errStr = tostring(err)
					if errStr:find('attempt to call a nil value') then
						return nil
					end
					if errStr:find('accessory') or errStr:find('wing') or errStr:find('Could not find') or 
					   errStr:find('Failed to update') or errStr:find('HumanoidRootPart') or
					   errStr:find('is not a valid member') or errStr:find('C0') or
					   errStr:find('Parent property') or errStr:find('is locked') or
					   errStr:find('spirit_dagger') or errStr:find('spirit-assassin') then
						return nil
					end
					return errStr .. '\n' .. debug.traceback()
				end)
				if not execOk and execErr then
					error(execErr)
				end
			else
				error(result or "Failed to load main.lua")
			end
		end, function(err)
			return tostring(err) .. '\n' .. debug.traceback()
		end)

		if ok then
			return true
		else
			lastErr = err
			local errStr = tostring(err)
			if errStr:find('attempt to call a nil value') or 
			   errStr:find('accessory') or errStr:find('wing') or 
			   errStr:find('Could not find') or errStr:find('Failed to update') or
			   errStr:find('HumanoidRootPart') or errStr:find('is not a valid member') or
			   errStr:find('Parent property') or errStr:find('is locked') or
			   errStr:find('spirit_dagger') or errStr:find('spirit-assassin') then
				warn(`[${BRAND_NAME}] main.lua has non-critical error (attempt {attempt}), but continuing...`)
				if attempt == 3 then
					return true, "Continued despite non-critical error"
				end
			else
				warn(`[${BRAND_NAME}] main.lua failed (attempt {attempt}): {err}`)
			end
			task.wait(2)
		end
	end

	return false, lastErr
end

local success, err = runMainWithRetries()

for _, v in Connections do
	v:Disconnect()
end

for i = #Connections, 1, -1 do
	Connections[i] = nil
end

if not success then
	warn(`[${BRAND_NAME}] Failed to initialize: {err}`)
	warn(`[${BRAND_NAME}] Continuing anyway to prevent crash...`)
elseif not closet then
	pcall(function()
		loadstring(downloadFile('catrewrite/libraries/annc.lua'), 'announcements.lua')()
	end)
end

if shared.vape then
	task.spawn(function()
		local checkCount = 0
		local lastCheck = tick()
		while true do
			local ok = pcall(function()
				task.wait(10)
				checkCount = checkCount + 1
				
				if shared.vape and type(shared.vape) == 'table' then
					local _ = shared.vape.Loaded
				end
				
				if checkCount % 12 == 0 then
					if type(collectgarbage) == 'function' then
						collectgarbage('collect')
					end
				end
			end)
			
			if not ok then
				task.wait(30)
			end
		end
	end)
end

task.spawn(function()
	local cleanupCount = 0
	local lastMemory = 0
	local crashCount = 0
	while true do
		local ok = pcall(function()
			task.wait(10)
			cleanupCount = cleanupCount + 1
			crashCount = 0
			
			if type(collectgarbage) == 'function' then
				local currentMemory = collectgarbage('count')
				if lastMemory > 0 and currentMemory > lastMemory * 1.3 then
					collectgarbage('collect')
					collectgarbage('collect')
					collectgarbage('collect')
				else
					collectgarbage('collect')
				end
				lastMemory = currentMemory
			end
			
			if Connections and #Connections > 25 then
				local toRemove = #Connections - 10
				for i = toRemove, 1, -1 do
					pcall(function()
						if Connections[i] then
							Connections[i]:Disconnect()
						end
					end)
					Connections[i] = nil
				end
			end
			
			if cleanupCount % 4 == 0 then
				pcall(function()
					if type(collectgarbage) == 'function' then
						collectgarbage('collect')
					end
				end)
			end
		end)
		
		if not ok then
			crashCount = crashCount + 1
			if crashCount > 3 then
				task.wait(30)
				crashCount = 0
			else
				task.wait(15)
			end
		end
	end
end)

task.spawn(function()
	local healthCheckCount = 0
	local lastHealthCheck = tick()
	while true do
		local ok = pcall(function()
			task.wait(20)
			healthCheckCount = healthCheckCount + 1
			
			local RunService = game:GetService('RunService')
			if not RunService or not RunService:IsRunning() then
				return
			end
			
			if healthCheckCount % 6 == 0 then
				if type(collectgarbage) == 'function' then
					collectgarbage('collect')
				end
			end
		end)
		
		if not ok then
			task.wait(40)
		end
	end
end)

task.spawn(function()
	local watchdogCount = 0
	local lastMemory = 0
	local crashCount = 0
	while true do
		local ok = pcall(function()
			task.wait(30)
			watchdogCount = watchdogCount + 1
			crashCount = 0
			
			if type(collectgarbage) == 'function' then
				local memBefore = collectgarbage('count')
				collectgarbage('collect')
				collectgarbage('collect')
				collectgarbage('collect')
				local memAfter = collectgarbage('count')
				
				if memBefore > 300 then
					warn(`[${BRAND_NAME}] High memory: {memBefore}MB -> {memAfter}MB, forcing cleanup...`)
					for i = 1, 5 do
						collectgarbage('collect')
					end
				end
				
				if lastMemory > 0 and memBefore > lastMemory * 1.5 then
					warn(`[${BRAND_NAME}] Memory spike detected! {lastMemory}MB -> {memBefore}MB`)
					for i = 1, 10 do
						collectgarbage('collect')
					end
				end
				lastMemory = memAfter
			end
			
			if watchdogCount % 2 == 0 then
				if Connections and #Connections > 15 then
					local toRemove = #Connections - 5
					for i = toRemove, 1, -1 do
						pcall(function()
							if Connections[i] then
								Connections[i]:Disconnect()
							end
						end)
						Connections[i] = nil
					end
				end
			end
			
			if watchdogCount % 5 == 0 then
				pcall(function()
					if shared.vape and type(shared.vape) == 'table' then
						local _ = shared.vape.Loaded
					end
				end)
			end
		end)
		
		if not ok then
			crashCount = crashCount + 1
			if crashCount > 5 then
				warn(`[${BRAND_NAME}] Watchdog crashed too many times, restarting...`)
				crashCount = 0
			end
			task.wait(60)
		end
	end
end)

task.spawn(function()
	local survivalCount = 0
	while true do
		task.wait(60)
		survivalCount = survivalCount + 1
		
		pcall(function()
			if type(collectgarbage) == 'function' then
				for i = 1, 3 do
					collectgarbage('collect')
				end
			end
			
			if survivalCount % 2 == 0 then
				if Connections and #Connections > 10 then
					for i = #Connections - 5, 1, -1 do
						pcall(function()
							if Connections[i] then
								Connections[i]:Disconnect()
							end
						end)
						Connections[i] = nil
					end
				end
			end
			
			if survivalCount >= 5 then
				survivalCount = 0
				warn(`[${BRAND_NAME}] Still running after 5 minutes! Memory cleanup...`)
				if type(collectgarbage) == 'function' then
					for i = 1, 10 do
						collectgarbage('collect')
					end
				end
			end
		end)
	end
end)
