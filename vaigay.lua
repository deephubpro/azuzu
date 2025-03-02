_G.AutoFarm = true -- Bật auto farm
_G.FlyHeight = 30  -- Độ cao bay trên NPC

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")

-- Danh sách nhiệm vụ theo level
local QuestList = {
    {Level = 1, Quest = "BanditQuest1", Enemy = "Bandit", Pos = Vector3.new(-1177, 50, 389)},
    {Level = 10, Quest = "JungleQuest1", Enemy = "Monkey", Pos = Vector3.new(-1613, 50, 146)},
    {Level = 15, Quest = "JungleQuest2", Enemy = "Gorilla", Pos = Vector3.new(-1223, 50, -506)},
    {Level = 30, Quest = "BuggyQuest1", Enemy = "Pirate", Pos = Vector3.new(-1133, 50, 3855)},
    {Level = 40, Quest = "BuggyQuest2", Enemy = "Brute", Pos = Vector3.new(-1143, 50, 4327)},
    {Level = 60, Quest = "DesertQuest1", Enemy = "Desert Bandit", Pos = Vector3.new(932, 50, 4482)},
    {Level = 75, Quest = "DesertQuest2", Enemy = "Desert Officer", Pos = Vector3.new(1572, 50, 4371)},
    {Level = 90, Quest = "SnowQuest1", Enemy = "Snow Bandit", Pos = Vector3.new(1197, 50, -1440)},
    {Level = 120, Quest = "SnowQuest2", Enemy = "Snowman", Pos = Vector3.new(1322, 50, -1332)},
    {Level = 150, Quest = "MarineQuest1", Enemy = "Chief Petty Officer", Pos = Vector3.new(-4916, 50, 4292)},
    {Level = 190, Quest = "PrisonerQuest1", Enemy = "Prisoner", Pos = Vector3.new(5302, 50, 474)},
    {Level = 250, Quest = "ColosseumQuest1", Enemy = "Toga Warrior", Pos = Vector3.new(-1793, 50, -2761)},
    {Level = 275, Quest = "ColosseumQuest2", Enemy = "Gladiator", Pos = Vector3.new(-1324, 50, -3123)},
    {Level = 300, Quest = "MagmaQuest1", Enemy = "Military Soldier", Pos = Vector3.new(-5425, 50, 8602)},
    {Level = 375, Quest = "FishmanQuest1", Enemy = "Fishman Warrior", Pos = Vector3.new(60886, 50, 1537)},
    {Level = 450, Quest = "SkyQuest1", Enemy = "Sky Bandit", Pos = Vector3.new(-4972, 450, -2637)},
    {Level = 525, Quest = "FountainQuest1", Enemy = "Galley Pirate", Pos = Vector3.new(5580, 50, 3976)},
    {Level = 700, Quest = "FountainQuest2", Enemy = "Galley Captain", Pos = Vector3.new(5532, 50, 4936)}
}

-- Tìm nhiệm vụ phù hợp với level người chơi
local function getQuestByLevel()
    local level = player.Data.Level.Value
    local bestQuest = nil
    for _, quest in ipairs(QuestList) do
        if level >= quest.Level then
            bestQuest = quest
        else
            break
        end
    end
    return bestQuest
end

-- Tìm NPC gần nhất
local function getNearestMob(enemyName)
    local nearestMob, minDistance = nil, math.huge
    for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
        if mob.Name == enemyName and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
            local distance = (hrp.Position - mob.HumanoidRootPart.Position).magnitude
            if distance < minDistance then
                minDistance = distance
                nearestMob = mob
            end
        end
    end
    return nearestMob
end

-- Tự động nhận nhiệm vụ
local function takeQuest(questName)
    local questNPC = game.Workspace.NPCs:FindFirstChild(questName)
    if questNPC then
        hrp.CFrame = questNPC.HumanoidRootPart.CFrame
        wait(1)
        game.ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questName, 1)
    end
end

-- Auto farm
local function autoFarm()
    while _G.AutoFarm do
        local quest = getQuestByLevel()
        if quest then
            takeQuest(quest.Quest)
            wait(1)
            local mob = getNearestMob(quest.Enemy)

            while _G.AutoFarm do
                if mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                    -- Bay ổn định trên đầu NPC
                    hrp.CFrame = CFrame.new(mob.HumanoidRootPart.Position + Vector3.new(0, _G.FlyHeight, 0))

                    -- Tấn công NPC liên tục
                    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Attack")
                    wait(0.1)
                else
                    -- Tìm NPC mới nếu con hiện tại đã chết
                    mob = getNearestMob(quest.Enemy)
                    if not mob then
                        hrp.CFrame = CFrame.new(quest.Pos) -- Quay lại chỗ farm
                        wait(1)
                    end
                end
            end
        end
        wait(0.5)
    end
end

spawn(autoFarm) -- Chạy script
