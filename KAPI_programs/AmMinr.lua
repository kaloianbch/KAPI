if not (os.loadAPI("KAPI")) then
    error("Could not load KAPI")
end

--[Constansts]--

--[Globals]--
YDirection = 1  -- 1 for downwards, 2 for upwards
ZLength = 0
XLength = 0
YLength = 0
YOffset = 0
XOffset = 0
ZOffset = 0
XDirection = 1    -- 3 to dig to the left, 1 to dig to the right
NextTurnCard = nil
StorageDirection = 3
DoWork = true

--[Functions]--
function Miner() -- Main quarry function
    local pos = KAPI.UpdateLastPos()
    if (pos.x == 0) then
        NoGPSHandler()
    end
    NextTurnCard = KAPI.SanitizeCard(NextTurnCard + 2)
    for i = 1,XLength,1 do
        for j = 2,ZLength,1 do
            CheckInv()
            MoveHardWrap(0)
        end
        if (i ~= XLength) then
            local currCard = KAPI.GetFacingCard()
            KAPI.FaceCard(NextTurnCard)
            CheckInv()
            MoveHardWrap(0)
            KAPI.FaceCard(currCard + 2)
        else
            KAPI.FaceCard(KAPI.GetFacingCard() + 2)
        end
    end
    
end

function CheckInv() -- checks capacity and unloads if full. will return after it unloads
    if (KAPI.CheckIfFull()) then
        local pos = KAPI.UpdateLastPos()
        local currCard = KAPI.GetFacingCard()
        if (pos.x == 0) then
            NoGPSHandler()
        end
        local originData = KAPI.GetOrigin()
        KAPI.GoTo(vector.new(originData[1], originData[2], originData[3]))
        KAPI.Unload(StorageDirection)
        MoveHardWrap(0)
        KAPI.GoTo(pos)
        KAPI.FaceCard(currCard)
    end
end

function MoveHardWrap(dir)
    if not KAPI.MoveHard(dir) then
        EndMiningHandler("unbreakable")
    end
end

function MoveHardALotWrap(dir, amount)
    if not KAPI.MoveHardALot(dir, amount) then
        EndMiningHandler("unbreakable")
    end
end

function EndMiningHandler(reason)
    KAPI.Logger("Ending mining due to " .. reason)
    local originData = KAPI.GetOrigin()
    if (originData[1] == 0) then
        NoGPSHandler()  --TODO should have a diffrent handler
    end
    KAPI.GoTo(vector.new(originData[1], originData[2], originData[3]))
    KAPI.Unload(StorageDirection)
    DoWork = false
    print("I've been a miner o7")
    os.shutdown()   --TODO need a way to exit program without restart
end

function NoGPSHandler()
    KAPI.Logger("ERROR: Lost GPS signal")
    error("Lost GPS signal")
end

function Setup()
    print("Enter length of area(Z):")
    ZLength = tonumber(read())
    print("Enter width of area(X):")
    XLength = tonumber(read())
    print("Ender depth of area(Y)\n(Enter 0 or nothing for unlimited):")
    YLength = tonumber(read())

    print("Offset Z:")
    local zOffInput = tonumber(read())
    if zOffInput ~= nil and zOffInput > 0 then
        ZOffset = zOffInput
    end
    print("Offset X:")
    local xOffInput = tonumber(read())
    if xOffInput ~= nil and xOffInput > 0 then
        XOffset = xOffInput
    end
    print("Offset Y:")
    local yOffInput = tonumber(read())
    if yOffInput ~= nil and yOffInput > 0 then
        YOffset = yOffInput
    end
    print("Direction of width,\n3 for left, 1 for right(default):")
    local XDirInput = tonumber(read())
    if XDirInput ~= nil and (XDirInput == 3 or XDirInput == 1) then
        XDirection = XDirInput
    end
    print("Invert depth (y/n):")
    if (read() == "y") then
        YDirection = 2
    end
    
    print("Other settings?(y/n):")
    if (read() == "y") then
        
        print("Starting cardinal(0=South, 1=East, 2=North, 3=West):")
        local sCard = tonumber(read())
        KAPI.SetStartingCard(sCard)
        print("Side of tool(left/right):")
        KAPI.SetToolHand(read())
        print("Unload direction(0-front, 1-down, 2-top, 3-back):")
        StorageDirection = tonumber(read())
        print("Storage ID(blank for wooden chest):")
        local sid = read()
        if (sid ~="") then
            KAPI.SetStorageBlockID(sid)
        end
    
    end

    if (ZLength == nil or ZLength < 1) then
        error("Length is required and must be positive integer")
    end
    if (XLength == nil or XLength < 1) then
        error("Width is required and must be positive integer")
    end

    KAPI.SetProgName("AmMinr")
    math.randomseed(os.time())
    os.setComputerLabel("Yellow Snow Co. Minr " .. math.random(1, 1000))
    KAPI.Init()
    KAPI.Logger("\n---------------------------------------\nAmMinr Settings:")
    KAPI.Logger("Size of area        : " .. XLength .. ", " .. ZLength)
    if YLength ~= nil and YLength > 0 then
        KAPI.Logger("Depth of area       : " .. YLength)
    end
    KAPI.Logger("Offset from start   : " .. XOffset .. ", " .. YOffset .. ", " .. ZOffset)
    KAPI.Logger("Direction of X and Y: " .. XDirection .. " and " .. YDirection)
    KAPI.Logger("Unload Direction: " .. StorageDirection)

    NextTurnCard = KAPI.SanitizeCard(KAPI.GetStartingCard() + XDirection)
end
--[Main]--
print("Running AmMinr V2.1(Athlon)...")
print("The turtle has to be facing South by default.")
print("The turtle should have a regular chest behind it by default.")
print("The turtle will start the quarry at \nthe block in front of and directly below it\n(Accounts for offset if set).")
print("The pickaxe should be on the right side of the turtle.")
Setup()
print("HERE COMES THE MINER!")

MoveHardWrap(0)
if (YOffset ~= nil and YOffset > 1) then
    MoveHardALotWrap(YDirection, YOffset - 1)
end
if (XOffset ~= nil and XOffset > 0) then
    KAPI.FaceCard(KAPI.GetStartingCard() - XDirection)
    MoveHardALotWrap(0, XOffset)
    KAPI.FaceCard(KAPI.GetStartingCard())
end
if (ZOffset ~= nil and ZOffset > 1) then
    KAPI.FaceCard(KAPI.GetStartingCard())
    MoveHardALotWrap(0, ZOffset -1)
end

if (YLength ~= nil and YLength > 0) then
    for i = 1,YLength,1 do
        MoveHardWrap(YDirection)
        Miner()
    end
    EndMiningHandler("finished task")
else
    while DoWork do
        MoveHardWrap(YDirection)
        Miner()
    end
    EndMiningHandler("finished task")
end
