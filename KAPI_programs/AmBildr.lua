if not (os.loadAPI("KAPI")) then
    error("Could not load KAPI")
end

--[Constansts]--

--[Globals]--
XLength = 0             -- size of area indicators
YLength = 0
ZLength = 0
YOffset = 0             -- offset from start
XOffset = 0
ZOffset = 0
YDirection = 2          -- 1 for down, 2 for up
XDirection = 1          -- 3 to work left of start, 1 to work right of start
StorageDirection = 3     -- (0-Front, 1-Down, 2-Up, 3-Back)
WallBlock = ""
FloorBlock = ""
CeilingBlock = ""
LightBlock = ""
FloorLevels = {1}
FloorToggle = false
--[Functions]--
function MoveHardWrap(dir)
    if not KAPI.MoveHard(dir) then
        UnbreakableHandler()
    end
end

function MoveHardALotWrap(dir, amount)
    if not KAPI.MoveHardALot(dir, amount) then
        UnbreakableHandler()
    end
end

function PlaceWrap(dir, isPlaceLight)   -- by default Places wall on sides, floor below and ceiling above. If light toggle is true, will Place light instead of wall
    if dir == 1 then
        if KAPI.ChangeTo(FloorBlock) then
            KAPI.Place(dir)     --TODO rePlace with PlaceHARD
        else                    --TODO recovery bad when in middle of wall
            OutOfBlockHandler("floor", dir, isPlaceLight)
        end
    elseif dir == 2 then
        if KAPI.ChangeTo(CeilingBlock) then
            KAPI.Place(dir)
        else
            OutOfBlockHandler("ceiling", dir, isPlaceLight)
        end
    elseif isPlaceLight then
        if KAPI.ChangeTo(LightBlock) then
            KAPI.Place(dir)
        else
            OutOfBlockHandler("light", dir, isPlaceLight)
        end
    else
        if KAPI.ChangeTo(WallBlock) then
            KAPI.Place(dir)
        else
            OutOfBlockHandler("wall", dir, isPlaceLight)
        end
    end
end

function OutOfBlockHandler(blockType, dir, isPlaceLight)       --TODO Unload maybe?
    KAPI.Logger("\"Ran out of " .. blockType .. " blocks\"")
    local pos = KAPI.UpdateLastPos()

    if (pos.x == 0) then
        NoGPSHandler()
    end
    local currCard = KAPI.GetFacingCard()
    local originData = KAPI.GetOrigin()

    if (originData[1] == 0) then
        NoGPSHandler()  --TODO should have a diffrent handler
    end

    KAPI.GoTo(vector.new(originData[1], originData[2], originData[3]))
    KAPI.Take(StorageDirection)

    if not KAPI.ChangeTo(WallBlock) then
        KAPI.Logger("\"ERROR: No wall blocks found after restock\"")
        KAPI.Kill()
        error("\"ERROR: No wall blocks found after restock\"")
    end

    if not KAPI.ChangeTo(FloorBlock) then
        KAPI.Logger("\"ERROR: No floor blocks found after restock\"")
        KAPI.Kill()
        error("\"ERROR: No floor blocks found after restock\"")
    end

    if not KAPI.ChangeTo(CeilingBlock) then
        KAPI.Logger("\"ERROR: No ceiling blocks found after restock\"")
        KAPI.Kill()
        error("\"ERROR: No ceiling blocks found after restock\"")
    end

    if not KAPI.ChangeTo(LightBlock) then
        KAPI.Logger("\"EXC: No light blocks found after restock\"")
        LightBlock = ""
    end

    MoveHardALotWrap(0,2)
    KAPI.GoTo(pos)
    KAPI.FaceCard(currCard)
    PlaceWrap(dir, isPlaceLight)
end

function UnbreakableHandler()
    KAPI.Logger("ERROR: Failed to break a block")
    KAPI.Kill()
    error("Ran into an unbreakable block")

end

function NoGPSHandler()
    KAPI.Logger("ERROR: Lost GPS signal")
    KAPI.Kill()
    error("Lost GPS signal")
end

function EndProgramHandler()
    local origin = KAPI.GetOrigin()
    KAPI.GoTo(vector.new(origin[1], origin[2], origin[3]))
    KAPI.Unload(StorageDirection)
    KAPI.Logger("*Building Completed, enjoy.")
    print("Building Completed, enjoy.")
    -- break in call loop
end

function RegisterBlocks()       -- sets building blocks from slots, if no ceiling block exists will use wall block and if no light block exists, no lights will be Placed
    local wall = KAPI.GetItemID(1)
    local floor = KAPI.GetItemID(2)
    local ceiling = KAPI.GetItemID(3)
    local light = KAPI.GetItemID(4)

    if wall == "failed" then
        KAPI.Logger("\n ERROR: No wall block found")
        error("No wall block found")
    end
    if floor == "failed" then
        KAPI.Logger("\n ERROR: No floor block found")
        error("No floor block found")
    end

    if ceiling == "failed" then
        KAPI.Logger("\n ERROR: No ceiling block found")
        error("No ceiling block found")
    end
    if light ~= "failed" then
        -- TODO add lighting functionality
        -- LightBlock = light
    end

    WallBlock = wall
    FloorBlock = floor
    CeilingBlock = ceiling
end

function Setup()    --TODO inverting Y
    print("Enter length of area(Z):")
    ZLength = tonumber(read())
    print("Enter width of area(X):")
    XLength = tonumber(read())
    print("Enter height of area(Y)")
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
    print("Please enter additional floor levels\n(Enter nothing or 0 to stop):")
    local floorTemp = tonumber(read())
    while floorTemp ~=nil and floorTemp ~= 0 do
        table.insert(FloorLevels, floorTemp)
        floorTemp = tonumber(read())
    end
    print("Please place the wall block in slot 1,\nfloor block in slot 2,\nceiling block in slot 3 and\nlight block in slot 3(optional)")
    read()
    RegisterBlocks()
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

    if (ZLength == nil or ZLength < 2) then
        error("Length is required and must be positive integer greater than 2")
    end
    if (XLength == nil or XLength < 2) then
        error("Width is required and must be positive integer greater than 2")
    end
    if (YLength == nil or YLength < 1) then
        error("Height is required and must be positive integer")
    end
    KAPI.SetProgName("AmBildr")
    math.randomseed(os.time())
    os.setComputerLabel("Yellow Snow Co. Bildr " .. math.random(1, 1000))

    KAPI.Init()
    KAPI.Logger("\n---------------------------------------\nAmBildr Settings:")
    KAPI.Logger("Size of area        : " .. XLength .. ", " .. YLength .. ", " .. ZLength)
    KAPI.Logger("Offset from start   : " .. XOffset .. ", " .. YOffset .. ", " .. ZOffset)
    KAPI.Logger("Direction of X and Y: " .. XDirection .. " and " .. YDirection)
    KAPI.Logger("Unload Direction: " .. StorageDirection)
    KAPI.Logger("Wall Block   : " .. WallBlock)
    KAPI.Logger("Floor Block  : " .. FloorBlock)
    KAPI.Logger("Ceiling Block: " .. CeilingBlock)
    KAPI.Logger("Light Block  : " .. LightBlock)
    local floorStr = ""
    for key, val in pairs(FloorLevels) do
        if key == 1 then
            floorStr = floorStr .. val
        else
            floorStr = floorStr .. ", " .. val
        end
    end
    KAPI.Logger("Floor Levels : " .. floorStr .. "\n---------------------------------------")
end

function DoSurface(dir, y, turnCard) -- builds surface. 1 for floor, 2 for ceiling
    KAPI.Logger("Starting work on surface at y: " .. y .. " in direction: " .. dir)
    if XLength % 2 == 0 then
        KAPI.FaceCard(KAPI.GetStartingCard()) --TODO simplify
    end
    for x = 1, XLength, 1 do
        PlaceWrap(dir)
        for z = 1, ZLength - 1, 1 do
            MoveHardWrap(0)
            PlaceWrap(dir)
        end
        if x ~= XLength then
            KAPI.FaceCard(KAPI.GetFacingCard() - turnCard)
            MoveHardWrap(0)
            KAPI.FaceCard(KAPI.GetFacingCard() - turnCard)
            turnCard = KAPI.SanitizeCard(turnCard - 2)
        end
    end
end

function DoCorner()
    MoveHardWrap(0)
    KAPI.FaceCard(KAPI.GetFacingCard() + XDirection)
    MoveHardWrap(0)
    KAPI.FaceCard(KAPI.GetFacingCard() - XDirection)
    PlaceWrap(0)
    KAPI.FaceCard(KAPI.GetFacingCard() + XDirection)
    MoveHardWrap(3)
    PlaceWrap(0)
    KAPI.FaceCard(KAPI.GetFacingCard() - XDirection)
    PlaceWrap(0)
    KAPI.FaceCard(KAPI.GetFacingCard() - XDirection)
end

function WalkAndPlace(length)
    for i = 1, length, 1 do
        MoveHardWrap(0)
        KAPI.FaceCard(KAPI.GetFacingCard() + XDirection)
        PlaceWrap(0)
        KAPI.FaceCard(KAPI.GetFacingCard() - XDirection)
    end
end

--[Main]--
print("Running AmBildr V2.0(Bulldozer)...")
print("The turtle should to be facing South by default.")
print("The turtle will start building 2 blocks ahead to allow for storage access(Accounts for offset if set).")
print("The turtle will start building the floor at the turtle's current floor level(Accounts for offset if set).")
print("The turtle should have a vanilla wooden chest behind it.")
print("The pickaxe should be on the right side of the turtle.")
Setup()
print("I came to build, build, build, build")


MoveHardALotWrap(0,2) -- Move to starting position
MoveHardWrap(KAPI.FlipDirection(YDirection))

if (YOffset ~= nil and YOffset > 1) then
    MoveHardALotWrap(YDirection, YOffset - 1)
end
if (XOffset ~= nil and XOffset > 0) then
    KAPI.FaceCard(KAPI.GetStartingCard() - XDirection)
    MoveHardALotWrap(0, XOffset)
    KAPI.FaceCard(KAPI.GetStartingCard())
end
if (ZOffset ~= nil and ZOffset > 2) then
    KAPI.FaceCard(KAPI.GetStartingCard())
    MoveHardALotWrap(0, ZOffset -2)
end

for y = 1, YLength + 2, 1 do
    local startCard = KAPI.GetFacingCard()
    local sideFirst = 0
    local sideSecond = 0
    if startCard == KAPI.SanitizeCard(KAPI.GetStartingCard() + 1) or
       startCard == KAPI.SanitizeCard(KAPI.GetFacingCard() - 1) then
        sideFirst = XLength - 2
        sideSecond = ZLength - 2
    else
        sideFirst = ZLength - 2
        sideSecond = XLength - 2
    end
    WalkAndPlace(sideFirst)
    DoCorner()
    WalkAndPlace(sideSecond)
    DoCorner()
    WalkAndPlace(sideFirst)
    DoCorner()
    WalkAndPlace(sideSecond)
    DoCorner()

    KAPI.FaceCard(startCard)
    if(y == YLength + 2) then -- last surface(ceiling for now)
        MoveHardWrap(KAPI.FlipDirection(YDirection))
        DoSurface(2, YLength)
        EndProgramHandler()
        break
    end

    MoveHardWrap(YDirection)
    for key, val in pairs(FloorLevels) do -- first and other surfaces
        if y == val then
            if XLength % 2 == 0 then
                if FloorToggle then
                    DoSurface(1, y, KAPI.SanitizeCard(XDirection + 2))
                    KAPI.FaceCard(KAPI.GetStartingCard())
                    FloorToggle = not FloorToggle
                else
                    DoSurface(1, y, XDirection)
                    KAPI.FaceCard(KAPI.GetStartingCard() + XDirection)
                    FloorToggle = not FloorToggle
                end
            else
                if FloorToggle then
                    DoSurface(1, y, XDirection)
                    KAPI.FaceCard(KAPI.GetStartingCard())
                    FloorToggle = not FloorToggle
                else
                    DoSurface(1, y, XDirection)
                    KAPI.FaceCard(KAPI.GetStartingCard() + 2)
                    FloorToggle = not FloorToggle
                end
            end
        end
    end
end

KAPI.Kill()