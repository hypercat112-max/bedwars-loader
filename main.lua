local BRAND_NAME = 'Not Cheating Scripts'
local vape
local closet = getgenv().closet
local makestage = getgenv().makestage or function() end
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end

if table.find({'Potassium'}, ({identifyexecutor()})[1]) then
	queue_on_teleport = function() end
end

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local httpService = cloneref(game:GetService('HttpService'))
local playersService = cloneref(game:GetService('Players'))

local GITHUB_USER = 'hypercat112-max'
local GITHUB_REPO = 'bedwars-loader'

local function downloadFile(path, func)
	if not isfile(path) or not shared.VapeDeveloper then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/'..GITHUB_USER..'/'..GITHUB_REPO..'/'..readfile('catrewrite/profiles/commit.txt')..'/'..select(1, path:gsub('catrewrite/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	vape:Load()
	makestage(5, 'Finished!')

	task.spawn(function()
		local saveCount = 0
		local crashCount = 0
		repeat
			local ok = pcall(function()
				if vape and vape.Save then
					vape:Save()
				end
			end)
			
			if not ok then
				crashCount = crashCount + 1
				if crashCount > 3 then
					warn(`[${BRAND_NAME}] Save loop crashed too many times, disabling...`)
					break
				end
			else
				crashCount = 0
			end
			
			saveCount = saveCount + 1
			if saveCount % 3 == 0 then
				pcall(function()
					if type(collectgarbage) == 'function' then
						collectgarbage('collect')
					end
				end)
			end
			
			if saveCount % 12 == 0 then
				pcall(function()
					if type(collectgarbage) == 'function' then
						collectgarbage('collect')
						collectgarbage('collect')
					end
				end)
			end
			
			task.wait(15)
		until not vape or not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.vapereload = true
				loadstring(readfile('catrewrite/init.lua'), 'init.lua')({})
			]]
			if getgenv().catvapedev then
				teleportScript = 'getgenv().catvapedev = true\n'.. teleportScript
			end
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
			end
			if getgenv().username then
				teleportScript = `getgenv().username = {getgenv().username}\n`.. teleportScript
			end
			if getgenv().password then
				teleportScript = `getgenv().password = {getgenv().password}\n`.. teleportScript
			end
			if getgenv().closet then
				teleportScript = 'getgenv().closet = true\n'.. teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		task.spawn(pcall, function()
			if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
				vape:CreateNotification('Finished Loading', UserInputService.TouchEnabled and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 3)
				task.wait(3.5)
				vape:CreateNotification('Cat', `Initialized as {(getgenv().username or 'Guest')} with role {getgenv().catrole or 'Basic'}`, 2.5, 'info')
				task.wait(1)
				if not isfile('newusercat2') then
					vape:CreateNotification('Cat', 'You have been redirected to cat\'s discord server', 3, 'warning')
					writefile('newusercat2', 'True')
					request({
						Url = 'http://127.0.0.1:6463/rpc?v=1',
						Method = 'POST',
						Headers = {
							['Content-Type'] = 'application/json',
							Origin = 'https://discord.com'
						},
						Body = cloneref(game:GetService('HttpService')):JSONEncode({
							invlink = 'catvape',
							cmd = 'INVITE_BROWSER',
							args = {
								code = 'catvape'
							},
							nonce = cloneref(game:GetService('HttpService')):GenerateGUID(true)
						})
					})
				end
			end
		end)
	end
end

if not isfile('catrewrite/profiles/gui.txt') then
	writefile('catrewrite/profiles/gui.txt', 'new')
end
local gui = readfile('catrewrite/profiles/gui.txt')

if gui == nil or gui == '' or not table.find({'rise', 'new', 'old'}, gui) then
	gui = 'new'
end

if not isfolder('catrewrite/assets/'..gui) then
	makefolder('catrewrite/assets/'..gui)
end

if shared.vape then
	shared.vape:Uninject()
end

local guiSuccess, guiResult = pcall(function()
	return loadstring(downloadFile('catrewrite/guis/'..gui..'.lua'), 'gui')
end)

if not guiSuccess or not guiResult then
	warn(`[${BRAND_NAME}] Failed to load GUI {gui}, trying 'new'...`)
	gui = 'new'
	guiSuccess, guiResult = pcall(function()
		return loadstring(downloadFile('catrewrite/guis/new.lua'), 'gui')
	end)
end

if guiSuccess and guiResult then
	local execSuccess, execResult = xpcall(guiResult, function(err)
		local errStr = tostring(err)
		if errStr:find('Actor environment') or errStr:find('attempt to call a nil value') then
			return nil
		end
		return errStr
	end)
	
	if execSuccess and execResult then
		vape = execResult
		shared.vape = vape
	else
		if execResult and tostring(execResult):find('Actor environment') then
			warn(`[${BRAND_NAME}] GUI Actor environment error (non-critical), continuing...`)
			-- Try to continue anyway
			if not vape then
				error('Failed to execute GUI: '..tostring(execResult))
			end
		else
			error('Failed to execute GUI: '..tostring(execResult))
		end
	end
else
	error('Failed to load GUI: '..tostring(guiResult))
end

local function callback(func)
	local success, result

	task.spawn(function()
		success, result = pcall(func)
	end)

	local Start = os.clock()

	repeat task.wait() until success ~= nil or (os.clock() - Start) >= 10

	return success, result
end

if not shared.VapeIndependent then
	loadstring(downloadFile('catrewrite/games/universal.lua'), 'universal')()
	shared.vape.Libraries.Cat = true
	makestage(4, 'Launching packages')
	callback(function()
		loadstring(downloadFile('catrewrite/libraries/whitelist.lua'), 'whitelist.lua')()
	end)
	local success, result = callback(function(...)
		if isfile('catrewrite/games/'..game.PlaceId..'.lua') then
			loadstring(readfile('catrewrite/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
		else
			if not shared.VapeDeveloper then
				local suc, res = pcall(function()
					return game:HttpGet('https://raw.githubusercontent.com/'..GITHUB_USER..'/'..GITHUB_REPO..'/'..readfile('catrewrite/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
				end)
				if suc and res ~= '404: Not Found' then
					loadstring(downloadFile('catrewrite/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
				end
			end
		end
	end)

	if success or not canDebug then
		pcall(function()
			local bedwarsModule = downloadFile('catrewrite/games/bedwars/modules.luau')
			if bedwarsModule then
				local func = loadstring(bedwarsModule, 'stupid ac mods like orion pmo - max')
				if func then
					local execOk, execErr = xpcall(func, function(err)
						local errStr = tostring(err)
						if errStr:find('attempt to call a nil value') or
						   errStr:find('Parent property') or errStr:find('is locked') or
						   errStr:find('is not a valid member') or errStr:find('Actor environment') then
							return nil
						end
						return errStr
					end)
					if not execOk and execErr then
						warn(`[${BRAND_NAME}] Bedwars module error (non-critical): {execErr}`)
					end
				end
			end
		end)
		finishLoading()
	else
		task.spawn(error, result)
		if not closet then
			callback(function()
				if setthreadidentity then
					setthreadidentity(8)
				end

				local errorPrompt = getrenv().require(game:GetService('CoreGui').RobloxGui.Modules.ErrorPrompt)
				local game = cloneref(game)

				local gui = Instance.new('ScreenGui', cloneref(game:GetService('CoreGui')))
				gui.OnTopOfCoreBlur = true


				local prompt = errorPrompt.new('Default')
				prompt._hideErrorCode = true
				prompt:setErrorTitle('Loading Failure')

				prompt:updateButtons({
					{
						Text = 'Ok',
						Callback = function()
							prompt:_close()
						end,
						Primary = true
					}
				}, 'Default')

				prompt:setParent(gui)
				prompt:_open('Failed to load catvape with this error code, Please report this to the discord server\n\n'.. result.. '\n(Error Code: 0)')
			end)
		end
	end
else
	vape.Init = finishLoading
	return vape
end

