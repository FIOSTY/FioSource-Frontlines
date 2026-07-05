local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Frontlines ESP - by fiosty",
    Icon = 0,
    LoadingTitle = "Frontlines ESP",
    LoadingSubtitle = "by fiosty",
    Theme = "Default",
    ToggleUIKeybind = Enum.KeyCode.RightShift,
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

local VisualsTab = Window:CreateTab("Visuals", "eye")
local ColorsTab = Window:CreateTab("Colors", "palette")
local ConfigTab = Window:CreateTab("Configs", "save")

local Settings = {
    ESP_Enabled = true,
    Box_Enabled = true,
    Chams_Enabled = true,
    Chams_Walls = true,
    HideTeam = true,
    ShowTracers = true,
    MinPartSize = 0.5,
    BoxHeight = 7.5,
    BoxWidth = 3.5,
    MaxDistance = 500,
    MaxESPObjects = 50,
    MergeDistance = 6,
    BoxType = "2D",
    ChamMatchRadius = 10,
    EnemyColor = {R = 255, G = 0, B = 0},
    FriendlyColor = {R = 0, G = 255, B = 0},
    EnemyChamsFill = {R = 255, G = 0, B = 0},
    FriendlyChamsFill = {R = 0, G = 255, B = 0},
    ChamsOutline = {R = 255, G = 255, B = 255},
    TracerColor = {R = 255, G = 255, B = 255}
}

local liveSettings = {
    EnemyColor = Color3.fromRGB(Settings.EnemyColor.R, Settings.EnemyColor.G, Settings.EnemyColor.B),
    FriendlyColor = Color3.fromRGB(Settings.FriendlyColor.R, Settings.FriendlyColor.G, Settings.FriendlyColor.B),
    EnemyChamsFill = Color3.fromRGB(Settings.EnemyChamsFill.R, Settings.EnemyChamsFill.G, Settings.EnemyChamsFill.B),
    FriendlyChamsFill = Color3.fromRGB(Settings.FriendlyChamsFill.R, Settings.FriendlyChamsFill.G, Settings.FriendlyChamsFill.B),
    ChamsOutline = Color3.fromRGB(Settings.ChamsOutline.R, Settings.ChamsOutline.G, Settings.ChamsOutline.B),
    TracerColor = Color3.fromRGB(Settings.TracerColor.R, Settings.TracerColor.G, Settings.TracerColor.B)
}

local configFolder = "FrontlinesESP/Configs/"
local currentConfigName = ""

local function colorToTable(color)
    return {R = math.floor(color.R * 255), G = math.floor(color.G * 255), B = math.floor(color.B * 255)}
end

local function tableToColor(tbl)
    return Color3.fromRGB(tbl.R or 255, tbl.G or 255, tbl.B or 255)
end

local function updateLiveColors()
    liveSettings.EnemyColor = tableToColor(Settings.EnemyColor)
    liveSettings.FriendlyColor = tableToColor(Settings.FriendlyColor)
    liveSettings.EnemyChamsFill = tableToColor(Settings.EnemyChamsFill)
    liveSettings.FriendlyChamsFill = tableToColor(Settings.FriendlyChamsFill)
    liveSettings.ChamsOutline = tableToColor(Settings.ChamsOutline)
    liveSettings.TracerColor = tableToColor(Settings.TracerColor)
end

local function safeSet(element, value)
    if not element then return end
    pcall(function()
        if typeof(value) == "table" then
            element:Set(value)
        else
            element:Set(value)
        end
    end)
end

local function serializeSettings()
    local copy = {}
    for k, v in pairs(Settings) do
        copy[k] = v
    end
    return game:GetService("HttpService"):JSONEncode(copy)
end

local function deserializeSettings(json)
    local ok, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(json)
    end)
    if not ok then return nil end
    return result
end

local function ensureFolder()
    if typeof(makefolder) == "function" then
        pcall(function()
            makefolder(configFolder)
        end)
    end
end

local function listConfigs()
    ensureFolder()
    local files = {}
    if typeof(listfiles) == "function" then
        local ok, result = pcall(listfiles, configFolder)
        if ok then
            for _, path in ipairs(result) do
                local name = string.match(path, configFolder .. "(.+)%.json$")
                if name then
                    table.insert(files, name)
                end
            end
        end
    end
    return files
end

local espToggle = VisualsTab:CreateToggle({Name = "Enable ESP", CurrentValue = true, Flag = "esp_enabled", Callback = function(v) Settings.ESP_Enabled = v end})
local boxToggle = VisualsTab:CreateToggle({Name = "Show Box", CurrentValue = true, Flag = "box_enabled", Callback = function(v) Settings.Box_Enabled = v end})
local tracerToggle = VisualsTab:CreateToggle({Name = "Show Tracers", CurrentValue = true, Flag = "show_tracers", Callback = function(v) Settings.ShowTracers = v end})
local chamsToggle = VisualsTab:CreateToggle({Name = "Body Chams", CurrentValue = true, Flag = "chams_enabled", Callback = function(v) Settings.Chams_Enabled = v end})
local chamsWallsToggle = VisualsTab:CreateToggle({Name = "Chams Through Walls", CurrentValue = true, Flag = "chams_walls", Callback = function(v) Settings.Chams_Walls = v end})
local hideTeamToggle = VisualsTab:CreateToggle({Name = "Hide Teammates", CurrentValue = true, Flag = "hide_team", Callback = function(v) Settings.HideTeam = v end})
local boxTypeDropdown = VisualsTab:CreateDropdown({Name = "Box Type", Options = {"2D", "3D"}, CurrentOption = {"2D"}, MultipleOptions = false, Flag = "box_type", Callback = function(v) Settings.BoxType = v[1] end})
local boxHeightSlider = VisualsTab:CreateSlider({Name = "Box Height", Range = {5, 10}, Increment = 0.5, Suffix = "stud", CurrentValue = 7.5, Flag = "box_height", Callback = function(v) Settings.BoxHeight = v end})
local boxWidthSlider = VisualsTab:CreateSlider({Name = "Box Width", Range = {2, 5}, Increment = 0.5, Suffix = "stud", CurrentValue = 3.5, Flag = "box_width", Callback = function(v) Settings.BoxWidth = v end})
local maxDistanceSlider = VisualsTab:CreateSlider({Name = "Max Distance", Range = {100, 1000}, Increment = 50, Suffix = "stud", CurrentValue = 500, Flag = "max_distance", Callback = function(v) Settings.MaxDistance = v end})
local mergeDistanceSlider = VisualsTab:CreateSlider({Name = "Merge Distance", Range = {3, 15}, Increment = 0.5, Suffix = "stud", CurrentValue = 6, Flag = "merge_distance", Callback = function(v) Settings.MergeDistance = v end})

local enemyColorPicker = ColorsTab:CreateColorPicker({
    Name = "Enemy Box Color",
    Color = liveSettings.EnemyColor,
    Flag = "enemy_esp_color",
    Callback = function(v)
        Settings.EnemyColor = colorToTable(v)
        updateLiveColors()
    end
})
local friendlyColorPicker = ColorsTab:CreateColorPicker({
    Name = "Friendly Box Color",
    Color = liveSettings.FriendlyColor,
    Flag = "friendly_esp_color",
    Callback = function(v)
        Settings.FriendlyColor = colorToTable(v)
        updateLiveColors()
    end
})
local enemyChamsFillPicker = ColorsTab:CreateColorPicker({
    Name = "Enemy Chams Fill",
    Color = liveSettings.EnemyChamsFill,
    Flag = "enemy_chams_fill",
    Callback = function(v)
        Settings.EnemyChamsFill = colorToTable(v)
        updateLiveColors()
    end
})
local friendlyChamsFillPicker = ColorsTab:CreateColorPicker({
    Name = "Friendly Chams Fill",
    Color = liveSettings.FriendlyChamsFill,
    Flag = "friendly_chams_fill",
    Callback = function(v)
        Settings.FriendlyChamsFill = colorToTable(v)
        updateLiveColors()
    end
})
local chamsOutlinePicker = ColorsTab:CreateColorPicker({
    Name = "Chams Outline",
    Color = liveSettings.ChamsOutline,
    Flag = "chams_outline",
    Callback = function(v)
        Settings.ChamsOutline = colorToTable(v)
        updateLiveColors()
    end
})
local tracerColorPicker = ColorsTab:CreateColorPicker({
    Name = "Tracer Color",
    Color = liveSettings.TracerColor,
    Flag = "tracer_color",
    Callback = function(v)
        Settings.TracerColor = colorToTable(v)
        updateLiveColors()
    end
})

local function updateUIFromSettings()
    updateLiveColors()

    safeSet(espToggle, Settings.ESP_Enabled)
    safeSet(boxToggle, Settings.Box_Enabled)
    safeSet(tracerToggle, Settings.ShowTracers)
    safeSet(chamsToggle, Settings.Chams_Enabled)
    safeSet(chamsWallsToggle, Settings.Chams_Walls)
    safeSet(hideTeamToggle, Settings.HideTeam)
    safeSet(boxTypeDropdown, {Settings.BoxType})
    safeSet(boxHeightSlider, Settings.BoxHeight)
    safeSet(boxWidthSlider, Settings.BoxWidth)
    safeSet(maxDistanceSlider, Settings.MaxDistance)
    safeSet(mergeDistanceSlider, Settings.MergeDistance)

    safeSet(enemyColorPicker, liveSettings.EnemyColor)
    safeSet(friendlyColorPicker, liveSettings.FriendlyColor)
    safeSet(enemyChamsFillPicker, liveSettings.EnemyChamsFill)
    safeSet(friendlyChamsFillPicker, liveSettings.FriendlyChamsFill)
    safeSet(chamsOutlinePicker, liveSettings.ChamsOutline)
    safeSet(tracerColorPicker, liveSettings.TracerColor)
end

local configNameInput = ConfigTab:CreateInput({
    Name = "Config Name",
    PlaceholderText = "myconfig",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        currentConfigName = tostring(v):gsub("[^%w_-]", "")
    end
})

local configDropdown
local function refreshConfigList()
    local configs = listConfigs()
    if configDropdown then
        configDropdown:Refresh(configs, {configs[1] or "none"})
    end
end

configDropdown = ConfigTab:CreateDropdown({
    Name = "Saved Configs",
    Options = listConfigs(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "config_dropdown",
    Callback = function(v)
        currentConfigName = v[1] or currentConfigName
        configNameInput:Set(currentConfigName)
    end
})

ConfigTab:CreateButton({
    Name = "Save Config",
    Callback = function()
        if currentConfigName == "" then
            Rayfield:Notify({Title = "Config", Content = "Enter a config name first", Duration = 3})
            return
        end
        ensureFolder()
        local path = configFolder .. currentConfigName .. ".json"
        local ok, err = pcall(function()
            writefile(path, serializeSettings())
        end)
        if ok then
            Rayfield:Notify({Title = "Config", Content = "Saved: " .. currentConfigName, Duration = 3})
            refreshConfigList()
        else
            Rayfield:Notify({Title = "Config", Content = "Save failed: " .. tostring(err), Duration = 3})
        end
    end
})

ConfigTab:CreateButton({
    Name = "Load Config",
    Callback = function()
        if currentConfigName == "" then
            Rayfield:Notify({Title = "Config", Content = "Enter/select a config name first", Duration = 3})
            return
        end
        local path = configFolder .. currentConfigName .. ".json"
        local ok, content = pcall(function()
            return readfile(path)
        end)
        if not ok then
            Rayfield:Notify({Title = "Config", Content = "Config not found", Duration = 3})
            return
        end
        local loaded = deserializeSettings(content)
        if not loaded then
            Rayfield:Notify({Title = "Config", Content = "Failed to load config", Duration = 3})
            return
        end
        for k, v in pairs(loaded) do
            if Settings[k] ~= nil then
                Settings[k] = v
            end
        end
        updateUIFromSettings()
        Rayfield:Notify({Title = "Config", Content = "Loaded: " .. currentConfigName, Duration = 3})
    end
})

ConfigTab:CreateButton({
    Name = "Delete Config",
    Callback = function()
        if currentConfigName == "" then
            Rayfield:Notify({Title = "Config", Content = "Enter/select a config name first", Duration = 3})
            return
        end
        local path = configFolder .. currentConfigName .. ".json"
        local ok = pcall(function()
            delfile(path)
        end)
        if ok then
            Rayfield:Notify({Title = "Config", Content = "Deleted: " .. currentConfigName, Duration = 3})
            refreshConfigList()
        else
            Rayfield:Notify({Title = "Config", Content = "Delete failed", Duration = 3})
        end
    end
})

Rayfield:Notify({Title = "Frontlines ESP", Content = "by fiosty - loaded", Duration = 3})

local ESP_Objects = {}
local Cham_Objects = {}
local cachedParts = {}
local lastCacheUpdate = 0
local frameCount = 0

local function FindSoldierModels()
    local models = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            local hasMesh = false
            local hasPrimary = obj.PrimaryPart ~= nil
            for _, desc in ipairs(obj:GetDescendants()) do
                if desc:IsA("MeshPart") or desc:IsA("SpecialMesh") then
                    hasMesh = true
                    break
                end
            end
            if hasMesh and hasPrimary then
                table.insert(models, obj)
            end
        end
    end
    return models
end

local function RemoveCham(key)
    local cham = Cham_Objects[key]
    if cham then cham:Destroy(); Cham_Objects[key] = nil end
end

local function ClearAllChams()
    for key, cham in pairs(Cham_Objects) do
        if cham and cham.Parent then cham:Destroy() end
    end
    table.clear(Cham_Objects)
end

local function ApplyCham(model, color)
    if Cham_Objects[model] and Cham_Objects[model].Parent then
        Cham_Objects[model].FillColor = color
        Cham_Objects[model].OutlineColor = liveSettings.ChamsOutline
        Cham_Objects[model].DepthMode = Settings.Chams_Walls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "FL_ESP_Cham"
    highlight.Adornee = model
    highlight.FillColor = color
    highlight.OutlineColor = liveSettings.ChamsOutline
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Settings.Chams_Walls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    highlight.Parent = model
    Cham_Objects[model] = highlight
end

local function HideAll(objects)
    if objects.Box then objects.Box.Visible = false end
    if objects.Tracer then objects.Tracer.Visible = false end
    if objects.Lines then
        for _, line in ipairs(objects.Lines) do line.Visible = false end
    end
end

local function RemoveAll(objects)
    if objects.Box then objects.Box:Remove(); objects.Box = nil end
    if objects.Tracer then objects.Tracer:Remove(); objects.Tracer = nil end
    if objects.Lines then
        for _, line in ipairs(objects.Lines) do line:Remove() end
        objects.Lines = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not Camera then Camera = workspace.CurrentCamera return end

    frameCount = frameCount + 1
    if frameCount % 3 ~= 0 then return end

    if not Settings.ESP_Enabled then
        for _, objects in pairs(ESP_Objects) do HideAll(objects) end
        ClearAllChams()
        return
    end

    local cameraPos = Camera.CFrame.Position
    local currentTime = tick()
    local allSoldierModels = Settings.Chams_Enabled and FindSoldierModels() or {}

    if currentTime - lastCacheUpdate > 0.5 then
        cachedParts = {}
        local activeChams = {}

        for _, part in ipairs(CollectionService:GetTagged("ENEMY_SOLDIER")) do
            if part:IsA("BasePart") and part.Transparency == 1 and part.Size.X > Settings.MinPartSize then
                local dist = (part.Position - cameraPos).Magnitude
                if dist <= Settings.MaxDistance then
                    table.insert(cachedParts, {part = part, isEnemy = true, dist = dist})
                    if Settings.Chams_Enabled then
                        local bestModel, bestDist = nil, Settings.ChamMatchRadius
                        for _, model in ipairs(allSoldierModels) do
                            if model.PrimaryPart then
                                local d = (model.PrimaryPart.Position - part.Position).Magnitude
                                if d < bestDist then bestDist = d; bestModel = model end
                            end
                        end
                        if bestModel then activeChams[bestModel] = liveSettings.EnemyChamsFill end
                    end
                end
            end
        end

        if not Settings.HideTeam then
            for _, part in ipairs(CollectionService:GetTagged("FRIENDLY_SOLDIER")) do
                if part:IsA("BasePart") and part.Transparency == 1 and part.Size.X > Settings.MinPartSize then
                    local dist = (part.Position - cameraPos).Magnitude
                    if dist <= Settings.MaxDistance then
                        table.insert(cachedParts, {part = part, isEnemy = false, dist = dist})
                        if Settings.Chams_Enabled then
                            local bestModel, bestDist = nil, Settings.ChamMatchRadius
                            for _, model in ipairs(allSoldierModels) do
                                if model.PrimaryPart then
                                    local d = (model.PrimaryPart.Position - part.Position).Magnitude
                                    if d < bestDist then bestDist = d; bestModel = model end
                                end
                            end
                            if bestModel then activeChams[bestModel] = liveSettings.FriendlyChamsFill end
                        end
                    end
                end
            end
        end

        for model, color in pairs(activeChams) do ApplyCham(model, color) end
        for model in pairs(Cham_Objects) do
            if not activeChams[model] then RemoveCham(model) end
        end

        table.sort(cachedParts, function(a, b) return a.dist < b.dist end)
        lastCacheUpdate = currentTime
    end

    local currentFrameClusters = {}
    local clusterCount = 0

    for _, data in ipairs(cachedParts) do
        if clusterCount >= Settings.MaxESPObjects then break end
        local part = data.part
        local pos = part.Position
        local minP = pos - part.Size / 2
        local maxP = pos + part.Size / 2
        local volume = part.Size.X * part.Size.Y * part.Size.Z

        local bestClusterId, bestScore = nil, Settings.MergeDistance

        for cid, cluster in pairs(currentFrameClusters) do
            if data.isEnemy == cluster.isEnemy then
                local center = (cluster.min + cluster.max) / 2
                local dx = pos.X - center.X
                local dz = pos.Z - center.Z
                local dy = pos.Y - center.Y
                local distanceScore = math.sqrt(dx * dx + dz * dz) + (math.abs(dy) / 3)
                if distanceScore < bestScore then
                    bestScore = distanceScore
                    bestClusterId = cid
                end
            end
        end

        if bestClusterId then
            local cluster = currentFrameClusters[bestClusterId]
            currentFrameClusters[bestClusterId] = {
                min = Vector3.new(math.min(cluster.min.X, minP.X), math.min(cluster.min.Y, minP.Y), math.min(cluster.min.Z, minP.Z)),
                max = Vector3.new(math.max(cluster.max.X, maxP.X), math.max(cluster.max.Y, maxP.Y), math.max(cluster.max.Z, maxP.Z)),
                isEnemy = cluster.isEnemy,
                cframe = volume > cluster.largestVolume and part.CFrame or cluster.cframe,
                largestVolume = math.max(volume, cluster.largestVolume)
            }
        else
            clusterCount = clusterCount + 1
            currentFrameClusters[clusterCount] = {min = minP, max = maxP, isEnemy = data.isEnemy, cframe = part.CFrame, largestVolume = volume}
        end
    end

    local activeClusters = {}
    for tempId, cluster in pairs(currentFrameClusters) do
        local center = (cluster.min + cluster.max) / 2
        local gridSize = 4
        local cid = string.format("%d_%d_%d_%s", math.floor(center.X / gridSize), math.floor(center.Y / gridSize), math.floor(center.Z / gridSize), tostring(cluster.isEnemy))
        local finalCid = cid
        local counter = 1
        while activeClusters[finalCid] do
            counter = counter + 1
            finalCid = cid .. "_" .. counter
        end
        activeClusters[finalCid] = cluster
    end

    local drawnClusters = {}
    for cid, cluster in pairs(activeClusters) do
        drawnClusters[cid] = true
        local color = cluster.isEnemy and liveSettings.EnemyColor or liveSettings.FriendlyColor
        local center = (cluster.min + cluster.max) / 2
        local camDist = (center - cameraPos).Magnitude

        if camDist <= Settings.MaxDistance then
            if not ESP_Objects[cid] then
                ESP_Objects[cid] = {Box = Drawing.new("Square"), Lines = {}, Tracer = Drawing.new("Line")}
                local objects = ESP_Objects[cid]
                objects.Box.Thickness = 2
                objects.Box.Filled = false
                objects.Tracer.Thickness = 1
                for i = 1, 4 do
                    local line = Drawing.new("Line")
                    line.Thickness = 2
                    table.insert(objects.Lines, line)
                end
            end

            local objects = ESP_Objects[cid]
            local screenCenter, onScreen = Camera:WorldToViewportPoint(center)

            if Settings.BoxType == "2D" then
                local topPos = center + Vector3.new(0, Settings.BoxHeight / 2, 0)
                local bottomPos = center - Vector3.new(0, Settings.BoxHeight / 2, 0)
                local screenTop, onScreenTop = Camera:WorldToViewportPoint(topPos)
                local screenBottom, onScreenBottom = Camera:WorldToViewportPoint(bottomPos)

                if onScreenTop or onScreenBottom then
                    local boxHeight = math.abs(screenBottom.Y - screenTop.Y)
                    local boxWidth = boxHeight * (Settings.BoxWidth / Settings.BoxHeight)

                    objects.Box.Visible = Settings.Box_Enabled
                    objects.Box.Color = color
                    objects.Box.Position = Vector2.new(screenTop.X - boxWidth / 2, screenTop.Y)
                    objects.Box.Size = Vector2.new(boxWidth, boxHeight)

                    if Settings.ShowTracers then
                        objects.Tracer.Visible = true
                        objects.Tracer.Color = liveSettings.TracerColor
                        objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        objects.Tracer.To = Vector2.new(screenTop.X, screenTop.Y + boxHeight / 2)
                    else
                        objects.Tracer.Visible = false
                    end
                else
                    objects.Box.Visible = false
                    objects.Tracer.Visible = false
                end

                for _, line in ipairs(objects.Lines) do line.Visible = false end

            elseif Settings.BoxType == "3D" then
                local cf = cluster.cframe
                local lookDir = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
                if lookDir.Magnitude < 0.001 then lookDir = Vector3.new(0, 0, 1) else lookDir = lookDir.Unit end
                local rightDir = lookDir:Cross(Vector3.new(0, 1, 0)).Unit
                local upDir = rightDir:Cross(lookDir).Unit
                local halfW = Settings.BoxWidth / 2
                local halfH = Settings.BoxHeight / 2

                local p1, vis1 = Camera:WorldToViewportPoint(center + upDir * halfH - rightDir * halfW)
                local p2, vis2 = Camera:WorldToViewportPoint(center + upDir * halfH + rightDir * halfW)
                local p3, vis3 = Camera:WorldToViewportPoint(center - upDir * halfH + rightDir * halfW)
                local p4, vis4 = Camera:WorldToViewportPoint(center - upDir * halfH - rightDir * halfW)

                if vis1 or vis2 or vis3 or vis4 then
                    local lines = objects.Lines
                    for _, line in ipairs(lines) do line.Color = color end
                    lines[1].From = Vector2.new(p1.X, p1.Y); lines[1].To = Vector2.new(p2.X, p2.Y); lines[1].Visible = true
                    lines[2].From = Vector2.new(p2.X, p2.Y); lines[2].To = Vector2.new(p3.X, p3.Y); lines[2].Visible = true
                    lines[3].From = Vector2.new(p3.X, p3.Y); lines[3].To = Vector2.new(p4.X, p4.Y); lines[3].Visible = true
                    lines[4].From = Vector2.new(p4.X, p4.Y); lines[4].To = Vector2.new(p1.X, p1.Y); lines[4].Visible = true

                    if Settings.ShowTracers then
                        objects.Tracer.Visible = true
                        objects.Tracer.Color = liveSettings.TracerColor
                        objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        objects.Tracer.To = Vector2.new(screenCenter.X, screenCenter.Y)
                    else
                        objects.Tracer.Visible = false
                    end
                else
                    for _, line in ipairs(objects.Lines) do line.Visible = false end
                    objects.Tracer.Visible = false
                end
                objects.Box.Visible = false
            end
        elseif ESP_Objects[cid] then
            HideAll(ESP_Objects[cid])
        end
    end

    for cid, objects in pairs(ESP_Objects) do
        if not drawnClusters[cid] then
            RemoveAll(objects)
            ESP_Objects[cid] = nil
        end
    end
end)
