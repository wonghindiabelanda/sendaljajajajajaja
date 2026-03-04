local ASSET_CONFIG = {
    BASE_URL = "https://zenithhub.cloud/panel/",
    LUARMOR_URL = "https://sdkapi-public.luarmor.net/library.lua",
    NOTIFY_URL = "https://zenithhub.cloud/panel/zenithnotification",
    KEY_FILE = "Zenith Key.txt",
    ASSET_ROOT = "ZenithUI/",
    DISCORD_URL = "discord.gg/zenithstudios",
    DISCORD_FULL = "https://discord.gg/zenithstudios",
    TUTORIAL_URL = "https://www.youtube.com/watch?v=dS92RVnVm30",
    DEFAULT_SCRIPT_ID = "2ef8fd6bd9548054ae8c4412307980ab",
    TESTER_SCRIPT_ID = "3226832bad9b1dcfc4cbc973827fee8a",
}

local Log = {
    info = function(...) print("[Zenith/Loader]", ...) end,
    warn = function(...) warn("[Zenith/Loader]", ...) end,
}

local cloneref = cloneref or clonereference or function(inst) return inst end

local ExecutorName = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Unknown"
local ExecutorLower = string.lower(ExecutorName)

if getgenv().TrashExecutor == nil then
    getgenv().TrashExecutor = ExecutorLower:find("xeno") or ExecutorLower:find("solara") or false
end

local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))

local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function() return CoreGui end

local function BuildHTTPMethods()
    if getgenv().TrashExecutor then
        return { function(u) return game:HttpGet(u, true) end }
    end

    return {
        function(u) return game:HttpGet(u, true) end,
        function(u) return game:HttpGet(u) end,
        function(u) return game:HttpGetAsync(u) end,
        function(u) return request({Url = u, Method = "GET"}).Body end,
        function(u) return http_request({Url = u, Method = "GET"}).Body end,
        function(u) return syn.request({Url = u, Method = "GET"}).Body end,
        function(u) return http.request({Url = u, Method = "GET"}).Body end,
    }
end

local function FetchRemote(url)
    local methods = BuildHTTPMethods()
    for _, method in ipairs(methods) do
        local ok, result = pcall(method, url)
        if ok and result then return result end
    end
    return nil
end

local function LoadRemote(url)
    local source = FetchRemote(url)
    if source then
        local fn, compileErr = loadstring(source)
        if fn then
            local ok, result = pcall(fn)
            if ok then return result end
        end
    end
    return nil
end

local function SafeParentUI(Instance, Parent)
    local success = pcall(function()
        local dest = typeof(Parent) == "function" and Parent() or (Parent or CoreGui)
        Instance.Parent = dest
    end)

    if not (success and Instance.Parent) then
        pcall(function()
            Instance.Parent = Players.LocalPlayer:WaitForChild("PlayerGui", 10)
        end)
    end
end

local function ParentUI(UI, SkipHiddenUI)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end

    pcall(protectgui, UI)
    SafeParentUI(UI, gethui)
end

local function MakeDraggable(dragHandle, frame)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(frame, TweenInfo.new(0.2), {Position = newPos}):Play()
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function hoverEffect(btn, hoverColor, normalColor)
    hoverColor  = hoverColor  or Color3.fromRGB(175, 85, 85)
    normalColor = normalColor or Color3.fromRGB(255, 85, 85)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
    end)
end

local function safeUIUpdate(element, property, value)
    if element and element.Parent then
        pcall(function() element[property] = value end)
        return true
    end
    return false
end

local api = nil

do
    local ok, result = pcall(LoadRemote, ASSET_CONFIG.LUARMOR_URL)
    if ok and result then
        api = result
        local filename = string.format("%02d.txt", 100)
        pcall(writefile, filename, api)
    end
end

if api then
    if getgenv().TesterScript == true then
        api.script_id = ASSET_CONFIG.TESTER_SCRIPT_ID
    else
        local PLACE_ID_MAP = {
            [2753915549] = "ae225a50bc5c5afd3cba10b375de4378",
            [4442272183] = "ae225a50bc5c5afd3cba10b375de4378",
            [7449423635] = "ae225a50bc5c5afd3cba10b375de4378",
            [72907489978215] = "addde86a80ce00e57bf0a270a39b170d",
            [131716211654599]= "addde86a80ce00e57bf0a270a39b170d",
            [16732694052] = "addde86a80ce00e57bf0a270a39b170d",
            [85896571713843] = "79d15dd7daecbde9a451298621057f9c",
            [126884695634066]= "b4154c552fa0dc9919cbb76bbaf1df92",
            [99519129453387] = "870b60ec96a7e1780c4a4e5681d20b0a",
            [121864768012064]= "ca2a56e457d5e90ae0697000e0a08c0a",
            [13772394625] = "bebe82ff30ee19066d901e38df564e72",
            [94101948530988] = "d9576cf6d588be8b661ff1a9ea63639b",
            [76558904092080] = "4be077018e077bd50674642ef3bc38d9",
            [129009554587176] = "4be077018e077bd50674642ef3bc38d9",
            [131884594917121] = "4be077018e077bd50674642ef3bc38d9",
            [79546208627805] = "3f8a81859b16cd9642d832053b439b53",
            [126509999114328] = "3f8a81859b16cd9642d832053b439b53",
            [131623223084840] = "ca7121c0f77ceae60782aa509544156d",
        }

        local CREATOR_ID_MAP = {
            [7381705] = "addde86a80ce00e57bf0a270a39b170d",
            [34898222] = "c6cc4567dd55aecc2279a286c2eb2b98",
            [35489258] = "4be077018e077bd50674642ef3bc38d9",
	        [460048752] = "e1aee8ab578a48b2a57d1a2ac51d2082",
        }

        local scriptId = PLACE_ID_MAP[game.PlaceId]

        if not scriptId then
            local MarketplaceService = cloneref(game:GetService("MarketplaceService"))
            local ok, productInfo = pcall(function()
                return MarketplaceService:GetProductInfo(game.PlaceId)
            end)

            if ok and productInfo and productInfo.Creator then
                scriptId = CREATOR_ID_MAP[productInfo.Creator.CreatorTargetId]
            end
        end

        api.script_id = scriptId or ASSET_CONFIG.DEFAULT_SCRIPT_ID
    end
else
    Log.warn("Unable to load Luarmor API!")
end

local ZenithAssets = {
    Assets = {
        ZenithLogoShape = { RobloxId = 95474178623916,  Path = "ZenithUI/assets/ZenithLogoShape.png", Id = nil },
        ZenithLogoZ = { RobloxId = 78056884165305,  Path = "ZenithUI/assets/ZenithLogoZ.png",     Id = nil },
        ZenithLogoBottom = { RobloxId = 71439567375542,  Path = "ZenithUI/assets/ZenithLogoBottom.png", Id = nil },
        ZenithLogoTop = { RobloxId = 135898721586377,  Path = "ZenithUI/assets/ZenithLogoTop.png",     Id = nil },
        LogoGlow = { RobloxId = 110200893526647, Path = "ZenithUI/assets/LogoGlow.png",        Id = nil },
        HideUIIcon = { RobloxId = 89810507329608,  Path = "ZenithUI/assets/HideUIIcon.png",      Id = nil },
        DropdownArrow = { RobloxId = 137555765572417, Path = "ZenithUI/assets/DropdownArrow.png",   Id = nil },
        CheckIcon = { RobloxId = 112315656061835, Path = "ZenithUI/assets/CheckIcon.png",       Id = nil },
        GlowMain = { RobloxId = 82454449164045,  Path = "ZenithUI/assets/GlowMain.png",        Id = nil },
        LogoMain = { RobloxId = 138929814993200, Path = "ZenithUI/assets/LogoMain.png",        Id = nil },
        LogoMainNew = { RobloxId = 98085346035268, Path = "ZenithUI/assets/LogoMainNew.png",        Id = nil },
        Settings = { RobloxId = 110219844095579, Path = "ZenithUI/assets/Settings.png",        Id = nil },
        Main = { RobloxId = 117626442624797, Path = "ZenithUI/assets/Main.png",            Id = nil },
        Others = { RobloxId = 82711452097205,  Path = "ZenithUI/assets/Others.png",          Id = nil },
        Server = { RobloxId = 111370206552811, Path = "ZenithUI/assets/Server.png",          Id = nil },
        Chat = { RobloxId = 138368006212972, Path = "ZenithUI/assets/Chat.png",            Id = nil },
    },
}

do
    local function RecursiveCreatePath(Path, IsFile)
        if not isfolder or not makefolder then return end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then table.remove(Segments, #Segments) end

        for _, Segment in ipairs(Segments) do
            local fullPath = TraversedPath .. Segment
            local checkOk, exists = pcall(isfolder, fullPath)
            if not checkOk or not exists then
                local mkOk = pcall(makefolder, fullPath)
                if not mkOk then
                    local recheck, nowExists = pcall(isfolder, fullPath)
                    if not recheck or not nowExists then
                        return nil
                    end
                end
            end
            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function ZenithAssets.GetAsset(AssetName)
        local AssetData = ZenithAssets.Assets[AssetName]
        if not AssetData then return nil end
        if AssetData.Id then return AssetData.Id end

        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

        if getcustomasset then
            local ok, NewID = pcall(getcustomasset, AssetData.Path)
            if ok and NewID then AssetID = NewID end
        end

        AssetData.Id = AssetID
        return AssetID
    end

    function ZenithAssets.DownloadAsset(AssetPath)
        pcall(function()
            if not getcustomasset or not writefile or not isfile then return end

            RecursiveCreatePath(AssetPath, true)

            local checkOk, fileExists = pcall(isfile, AssetPath)
            if checkOk and fileExists then return end

            local URLPath = AssetPath:gsub(ASSET_CONFIG.ASSET_ROOT, "")
            local ok, result = pcall(function()
                return game:HttpGet(ASSET_CONFIG.BASE_URL .. URLPath)
            end)

            if ok and result then
                pcall(writefile, AssetPath, result)
            end
        end)
    end

    getgenv().ZenithAssets = ZenithAssets

    for _, Data in ZenithAssets.Assets do
        task.spawn(ZenithAssets.DownloadAsset, Data.Path)
    end
end

local function CreateCopyButton(btn, textDefault, textCopied, clipboardContent)
    local copying = false
    btn.MouseButton1Click:Connect(function()
        if copying then return end
        copying = true
        pcall(setclipboard, clipboardContent)
        btn.Text = textCopied
        task.wait(1)
        btn.Text = textDefault
        copying = false
    end)
end

local function CreateKeySystemUI()
    local UIParent = (gethui and gethui()) or CoreGui

    local existing = UIParent:FindFirstChild("KeySystem")
    if existing then existing:Destroy() end
    local existing2 = UIParent:FindFirstChild("ScreenGui")
    if existing2 then existing2:Destroy() end

    local KeySystem = Instance.new("ScreenGui")
    local Main = Instance.new("ImageLabel")
    local UICorner = Instance.new("UICorner")
    local Header = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Subtitle = Instance.new("TextLabel")
    local KeyInput = Instance.new("TextBox")
    local UICorner_2 = Instance.new("UICorner")
    local SubmitBtn = Instance.new("TextButton")
    local UICorner_3 = Instance.new("UICorner")
    local SupportText = Instance.new("TextLabel")
    local DiscordLink = Instance.new("TextButton")
    local ButtonsFrame = Instance.new("Frame")
    local LinkvertiseBtn = Instance.new("TextButton")
    local UICorner_4 = Instance.new("UICorner")
    local WorkinkBtn = Instance.new("TextButton")
    local UICorner_5 = Instance.new("UICorner")

    KeySystem.Name = "KeySystem"
    KeySystem.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ParentUI(KeySystem)

    Main.Name = "Main"
    Main.Parent = KeySystem
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 380, 0, 285)
    Main.Image = ZenithAssets.GetAsset("GlowMain")

    local ImageLabel = Instance.new("ImageLabel")
    ImageLabel.Parent = Main
    ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel.BackgroundTransparency = 1.000
    ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel.BorderSizePixel = 0
    ImageLabel.Position = UDim2.new(0.05, -8, 0.0717872535, -8)
    ImageLabel.Size = UDim2.new(0, 45, 0, 44)
    ImageLabel.Image = ZenithAssets.GetAsset("LogoMainNew")

    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Main

    Header.Name = "Header"
    Header.Parent = Main
    Header.BackgroundTransparency = 1
    Header.Size = UDim2.new(1, 0, 0, 100)

    Title.Name = "Title"
    Title.Parent = Header
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 30, 0, 20)
    Title.Size = UDim2.new(1, -60, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "    Welcome to The,"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left

    Subtitle.Name = "Subtitle"
    Subtitle.Parent = Header
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 30, 0, 50)
    Subtitle.Size = UDim2.new(1, -60, 0, 30)
    Subtitle.Font = Enum.Font.GothamBold
    Subtitle.Text = "Zenith Hub"
    Subtitle.TextColor3 = Color3.fromRGB(255, 85, 85)
    Subtitle.TextSize = 22
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left

    KeyInput.Name = "KeyInput"
    KeyInput.Parent = Main
    KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    KeyInput.BorderSizePixel = 0
    KeyInput.Position = UDim2.new(0, 30, 0, 100)
    KeyInput.Size = UDim2.new(1, -60, 0, 45)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    KeyInput.PlaceholderText = "Insert your key here"
    local _savedKey = ""
    pcall(function()
        if isfile and isfile(ASSET_CONFIG.KEY_FILE) then
            _savedKey = readfile(ASSET_CONFIG.KEY_FILE) or ""
        end
    end)
    KeyInput.Text = _savedKey
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14
    KeyInput.TextTruncate = Enum.TextTruncate.AtEnd
    KeyInput.TextWrapped = true
    KeyInput.ClearTextOnFocus = false
    KeyInput.Focused:Connect(function()
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Return then
                KeyInput.Text = KeyInput.Text:gsub("\n", "")
                KeyInput:ReleaseFocus()
                connection:Disconnect()
            end
        end)
    end)

    local keyStroke = Instance.new("UIStroke")
    keyStroke.Name = "UIStroke"
    keyStroke.Parent = KeyInput
    keyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    keyStroke.Color = Color3.fromRGB(50, 50, 50)
    keyStroke.LineJoinMode = Enum.LineJoinMode.Round
    keyStroke.Thickness = 1
    keyStroke.Transparency = 0

    UICorner_2.CornerRadius = UDim.new(0, 8)
    UICorner_2.Parent = KeyInput

    SubmitBtn.Name = "SubmitBtn"
    SubmitBtn.Parent = Main
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    SubmitBtn.BorderSizePixel = 0
    SubmitBtn.Position = UDim2.new(0, 30, 0, 155)
    SubmitBtn.Size = UDim2.new(1, -60, 0, 45)
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.Text = "Submit Key >"
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.TextSize = 16

    UICorner_3.CornerRadius = UDim.new(0, 8)
    UICorner_3.Parent = SubmitBtn

    SupportText.Name = "SupportText"
    SupportText.Parent = Main
    SupportText.BackgroundTransparency = 1
    SupportText.Position = UDim2.new(0, 95, 0, 255)
    SupportText.Size = UDim2.new(1, -60, 0, 20)
    SupportText.Font = Enum.Font.Gotham
    SupportText.Text = "Need support?"
    SupportText.TextColor3 = Color3.fromRGB(150, 150, 150)
    SupportText.TextSize = 13
    SupportText.TextXAlignment = Enum.TextXAlignment.Left

    DiscordLink.Name = "DiscordLink"
    DiscordLink.Parent = SupportText
    DiscordLink.BackgroundTransparency = 1
    DiscordLink.Position = UDim2.new(0, 92, 0, 0)
    DiscordLink.Size = UDim2.new(0, 150, 0, 20)
    DiscordLink.Font = Enum.Font.GothamBold
    DiscordLink.Text = "Join the Discord"
    DiscordLink.TextColor3 = Color3.fromRGB(255, 85, 85)
    DiscordLink.TextSize = 13
    DiscordLink.TextXAlignment = Enum.TextXAlignment.Left

    ButtonsFrame.Name = "ButtonsFrame"
    ButtonsFrame.Parent = Main
    ButtonsFrame.BackgroundTransparency = 1
    ButtonsFrame.Position = UDim2.new(0, 30, 0, 280)
    ButtonsFrame.Size = UDim2.new(1, -60, 0, 35)

    LinkvertiseBtn.Name = "LinkvertiseBtn"
    LinkvertiseBtn.Parent = ButtonsFrame
    LinkvertiseBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    LinkvertiseBtn.BorderSizePixel = 0
    LinkvertiseBtn.Position = UDim2.new(0, 0, 0, -70)
    LinkvertiseBtn.Size = UDim2.new(0.6, -5, 1, 0)
    LinkvertiseBtn.Font = Enum.Font.GothamBold
    LinkvertiseBtn.Text = "Get Key"
    LinkvertiseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LinkvertiseBtn.TextSize = 13

    UICorner_4.CornerRadius = UDim.new(0, 6)
    UICorner_4.Parent = LinkvertiseBtn

    UICorner_5.CornerRadius = UDim.new(0, 6)
    UICorner_5.Parent = WorkinkBtn

    WorkinkBtn.Name = "WorkinkBtn"
    WorkinkBtn.Parent = ButtonsFrame
    WorkinkBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    WorkinkBtn.BorderSizePixel = 0
    WorkinkBtn.Position = UDim2.new(0.6, 0, 0, -70)
    WorkinkBtn.Size = UDim2.new(0.4, 0, 1, 0)
    WorkinkBtn.Font = Enum.Font.Gotham
    WorkinkBtn.Text = "How to Get Key?"
    WorkinkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    WorkinkBtn.TextSize = 13

    hoverEffect(SubmitBtn, Color3.fromRGB(200, 70, 70), Color3.fromRGB(255, 85, 85))
    hoverEffect(LinkvertiseBtn)

    DiscordLink.MouseEnter:Connect(function()
        TweenService:Create(DiscordLink, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 70, 70)}):Play()
    end)
    DiscordLink.MouseLeave:Connect(function()
        TweenService:Create(DiscordLink, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 85, 85)}):Play()
    end)

    CreateCopyButton(LinkvertiseBtn, "Get Key",          "Copied!", ASSET_CONFIG.DISCORD_FULL)
    CreateCopyButton(WorkinkBtn,     "How to Get Key?",  "Copied!", ASSET_CONFIG.TUTORIAL_URL)
    CreateCopyButton(DiscordLink,    "Join the Discord", "Copied!", ASSET_CONFIG.DISCORD_URL)

    MakeDraggable(Main, Main)

    return {
        KeySystem = KeySystem,
        Main = Main,
        KeyInput = KeyInput,
        SubmitBtn = SubmitBtn,
    }
end

if getgenv().ZenithNotification == nil then
    local ok, result = pcall(LoadRemote, ASSET_CONFIG.NOTIFY_URL)
    if ok and result then
        getgenv().ZenithNotification = result
    end
end
pcall(writefile, "test.txt" , getgenv().ZenithLoader = {
    Services = {
        UserInputService = UserInputService,
        TweenService = TweenService,
        Players = Players,
        CoreGui = CoreGui,
    },
    Assets = ZenithAssets,
    API = api,
    ExecutorName = ExecutorName,
    ExecutorLower = ExecutorLower,
    MakeDraggable = MakeDraggable,
    ParentUI = ParentUI,
    SafeParentUI = SafeParentUI,
    hoverEffect = hoverEffect,
    safeUIUpdate = safeUIUpdate,
    FetchRemote = FetchRemote,
    LoadRemote = LoadRemote,
    CreateKeySystemUI = CreateKeySystemUI,
    Notify = getgenv().ZenithNotification,
})
getgenv().ZenithLoader = {
    Services = {
        UserInputService = UserInputService,
        TweenService = TweenService,
        Players = Players,
        CoreGui = CoreGui,
    },
    Assets = ZenithAssets,
    API = api,
    ExecutorName = ExecutorName,
    ExecutorLower = ExecutorLower,
    MakeDraggable = MakeDraggable,
    ParentUI = ParentUI,
    SafeParentUI = SafeParentUI,
    hoverEffect = hoverEffect,
    safeUIUpdate = safeUIUpdate,
    FetchRemote = FetchRemote,
    LoadRemote = LoadRemote,
    CreateKeySystemUI = CreateKeySystemUI,
    Notify = getgenv().ZenithNotification,
}
