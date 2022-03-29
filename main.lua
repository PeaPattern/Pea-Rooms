if not game:IsLoaded() then
    repeat task.wait() until game:IsLoaded()
end

local Player = game:GetService("Players").LocalPlayer
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local JSONDecode = HttpService.JSONDecode
local Prefix = ":"

local Remotes = {
    AlmondWater = "no"
}
if game:GetService("ReplicatedStorage"):FindFirstChild("SanityEvents") and game:GetService("ReplicatedStorage").SanityEvents:FindFirstChild("AlmondWater") then
    Remotes.AlmondWater = game:GetService("ReplicatedStorage").SanityEvents.AlmondWater
end

local Floors = {
    {"0", 7648148853},
    {"0.1", 7616073978},
    {"0.3", 8151347919},
    {"1", 8128962963},
    {"1.5", 7627016705},
    {"2", 7626856913},
    {"2.1", 7655581380},
    {"3", 7656560023},
    {"4", 7665495496},
    {"5", 7673275331},
    {"5.555", 8143429620},
    {"6", 7708955577},
    {"6.1", 8070289333},
    {"7", 7708956164},
    {"8", 7708955862},
    {"9", 7746181215},
    {"10", 7746273215},
    {"11", 7804239024},
    {"12", 7870417570},
    {"15", 8267783618},
    {"188", 8592506349},
    {"hub", 7662894222},
    {"thebackroom", 8246789981},
    {"fridge", 8656240402},
}

local function findServer(theid)
    local Info = JSONDecode(HttpService, game.HttpGetAsync(game, string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", theid)))
    local Servers = Info.data
    if #Servers == 0 then return "No servers found!" end
    local newServers = {}
    for _,v in pairs(Servers) do
        if v.playing ~= v.maxPlayers and v.id ~= game.JobId then
            table.insert(newServers, v)
        end
    end
    if #newServers == 0 then return "All servers are full or no other servers available." end
    Server = newServers[#newServers]
    TeleportService:TeleportToPlaceInstance(theid, Server.id)
    syn.queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/PeaPattern/Pea-Rooms/main/main.lua"))()')
    return "Sucessfully teleported."
end

local function Notify(Description)
    game.StarterGui:SetCore( "ChatMakeSystemMessage",  { Text = string.format("[SYSTEM] %s", Description), Color = Color3.fromRGB( 0,255,0 ), Font = Enum.Font.GothamBold, FontSize = Enum.FontSize.Size24 } )
end

local Commands = {}
local function addCommand(Name, Aliases, Description, Func)
    table.insert(Commands, {Name, Aliases, Func})
end

Notify(string.format("Welcome ADMIN, %s (@%s)!", Player.Name, Player.DisplayName))

addCommand("tp", {"level", "floor", "to", "teleport"}, "Teleports you to your desired floor.", function(Message, Args)
    if #Args >= 2 then
        for _,v in pairs(Floors) do
            local floorName = v[1]
            local floorID = v[2]
            if Args[2]:lower() == floorName:lower() then
                local Info = findServer(floorID)
                return Info
            end
        end
    else
        return "No second argument."
    end
end)

addCommand("sanity", {"snt"}, "Adds sanity to local player.", function(Message, Args)
    if #Args >= 2 then
        if tonumber(Args[2]) then
            if tonumber(Args[2]) <= 10000 then
                for i=1,math.round( tonumber( Args[2] ) / 40) do
                    Remotes.AlmondWater:FireServer()
                end
                return "Successfully added sanity."
            else
                for i=1,math.round( tonumber( 10000 ) / 40) do
                    Remotes.AlmondWater:FireServer()
                end
                return "Number was too large to change, instead set to 10000."
            end
        else
            return "Second argument is not an integer."
        end
    else
        return "Second argument was not given."
    end
end)

addCommand("thirdperson", {"tdpn", "zoom"}, "Allows zooming/third person on local player.", function(Message, Args)
    Player.CameraMode = Enum.CameraMode.Classic
    Player.CameraMaxZoomDistance = 999
    Camera.CameraType = Enum.CameraType.Track
    task.wait()
    return "Successfully third person."
end)

addCommand("fixlighting", {"restorelighting", "fl", "rl"}, "Removes annoying fog and restore the lighting to it's default.", function(Message, Args)
    Lighting:ClearAllChildren()
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.ClockTime = 14
    Lighting.Brightness = 1
    Lighting.Ambient = Color3.fromRGB(182,182,182)
    Lighting.OutdoorAmbient = Color3.fromRGB(102,102,102)
    task.wait()
    return "Fixed lighting successfully."
end)

addCommand("commands", {"cmds"}, "Lists out commands.", function(Message, Args)
    local Final = ""
    for _,v in pairs(Commands) do
        local Name = v[1]
    end
    return Final
end)

Player.Chatted:Connect(function(Message)
    for _,v in pairs(Commands) do
        local Name = v[1]
        local Aliases = v[2]
        local Func = v[3]
        local Split = string.split(Message, " ")
        if Split[1]:lower() == Prefix:lower() .. Name:lower() then
            local Result = Func(Message, Split)
            if Result then Notify(Result) end
        end
        for i,Alias in pairs(Aliases) do
            if Split[1]:lower() == Prefix:lower() .. Alias:lower() then
                local Result = Func(Message, Split)
                if Result then Notify(Result) end
            end
        end
    end
end)

--- cmds:
--:tp {place}
--:sanity {amount}
--:thirdperson
--:fixlighting
--:cmds
--->> PeaPattern#2703 enjoy <<---
