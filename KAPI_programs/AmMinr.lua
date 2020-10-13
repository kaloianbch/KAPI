--[Constants]--
startingDir = 0 -- Always place Turtle facing South
toolHand = "left" -- side of the turtle with the tool
--[Globals]--
facingDir = startingDir
invFull = false
failedToDig = false
isUnloading = false
offsetY = 0
originX,originY,originZ = gps.locate(10)
--[Functions]--
function forward(count) -- go forwards this amount, will remove obstacles.
    for i = 1,count,1  do
        if not (turtle.forward()) then
            repeat
                turtle.attack(toolHand)
                dig(0)
                if(failedToDig and not invFull) then
                    failedToDig = false
                    unload(false)
                    print("TASK COMPLETE: I've been a miner o7")
                    error("Failed to Dig")
                elseif(invFull) then
                    invFull = false
                    unload(true)
                end
                local didGoFwd = turtle.forward()
            until (didGoFwd)
        end
    end
end

function down(count) -- go down this amount, will remove obstacles.
    for i = 1,count,1  do
        if not (turtle.down()) then
            repeat
                turtle.attackDown(toolHand)
                dig(1)
                if(failedToDig and not invFull) then
                    failedToDig = false
                    unload(false)
                    print("TASK COMPLETE: I've been a miner o7")
                    error("Failed to Dig")
                elseif(invFull) then
                    invFull = false
                    unload(true)
                end
                local didGoDown = turtle.down()
            until (didGoDown)
        end
    end
end

function up(count) -- go up this amount, will remove obstacles.
    for i = 1,count,1  do
        if not (turtle.up()) then
            repeat
                turtle.attackUp(toolHand)
                dig(2)
                if(failedToDig) then
                    failedToDig = false
                    error("Stuck, send help(Couldn't dig up)")
                end
                local didGoUp = turtle.up()
            until (didGoUp)
        end
    end
end

function dig(dir)	-- dig in a direction if block is present (0 = dig in front, 1 = dig down, 2 = dig up)
    if (turtle.getItemCount(16) > 0 and not isUnloading) then
        invFull = true
    else
        if (dir == 0) then
            if (turtle.detect) then
                if not(turtle.dig(toolHand)) then
                    failedToDig = true
                end
            end
        end
        if (dir == 1) then
            if (turtle.detectDown) then
                if not(turtle.digDown(toolHand)) then
                    failedToDig = true
                end
            end
        end    
        if (dir == 2) then
            if (turtle.detectUp) then
                if not(turtle.digUp(toolHand)) then
                    failedToDig = true
                end
            end
        end
    end
end

function faceDir(dir)   -- turn to direction (0=South, 1=East, 2=North, 3=West)
    if(sanitizeDir(facingDir - 1) == dir) then
            turnRight()
    else
        while (facingDir ~= dir) do
            turnLeft()
        end
    end
end

function turnRight() -- turn right and update direction var
    turtle.turnRight()
    facingDir = sanitizeDir(facingDir - 1)
end

function turnLeft() -- turn left and update direction var
    turtle.turnLeft()
    facingDir = sanitizeDir(facingDir + 1)
end

function sanitizeDir(val) -- wraps a given value to it's correct cardinal direction going clockwise
    while not (val <= 3 and val >= 0) do
        if (val > 3) then
            val = val - 4
        elseif(val < 0) then
            val = val + 4
        end
    end
    return val
end

function goTo(x,y,z) -- navigates to given coords, disregarding blocks in the way
    local curr = vector.new(gps.locate(10))
    if not curr.x then
        error("GPS Unavailable")
    else
        local dest = vector.new(x, y, z)
        print("dest", dest:tostring())
        print("curr", curr:tostring())
        local diff = dest - curr
        print("diff", diff:tostring())
        
        if (diff.y >= 0) then
            up(diff.y)
        else
            down(-diff.y)
        end
        
        if (diff.x >= 0) then
            faceDir(1)
            forward(diff.x)
        else
            faceDir(3)
            forward(-diff.x)
        end
        
        if (diff.z >= 0) then
            faceDir(0)
            forward(diff.z)
        else
            faceDir(2)
            forward(-diff.z)
        end
    end
    faceDir(0)
end

function unload(doReturn) -- Attemps to unload inventory in storage above. set bool to true to resume digging after unloading
    isUnloading = true
    local currX, currY, currZ, currDir
    if(doReturn) then
        currDir = facingDir
        currX,currY,currZ = gps.locate(10)
    end
    goTo(originX, originY, originZ)
    local upBool, upData = turtle.inspectUp()
    if (upData.name == "minecraft:chest") then
        for i = 1, 16, 1 do
            if(turtle.getItemCount(i) > 0) then
                turtle.select(i)
                if not(turtle.dropUp()) then
                    error("Failed to unload slot:", i)
                end
            end
        end
        turtle.select(1)
        invFull = false
    else
        error("Chest not found")
    end
    
    if(doReturn) then
        if not currX then
            error("GPS Unavailable")
        end
        faceDir(startingDir)
        forward(1)
        goTo(currX, currY, currZ)
        faceDir(currDir)
    end
    isUnloading = false
end

--[Main]--
print("Running AmMnr V1.0...")
if not originX then
    error("GPS Unavailable")
end

doWork = true
print("Make sure the turtle has to be facing South.")
print("Make sure to place a regular chest on top of turtle.")
print("Enter length of quarry:")
x = tonumber(read())
print("Enter width of quarry:")
y = tonumber(read())
print("Other settings?(y/n):")
otherSettings = read()

if (otherSettings == "y") then
    print("Toolside:")
    toolHand = read()
    print("offcetY:")
    offsetY = tonumber(read())
end

print("HERE COMES THE MINER!")
qTurningDir = sanitizeDir(startingDir + 3)

forward(1)
if (offsetY > 0)then
    down(offsetY)
end

while (doWork) do 
    local checkBool, checkData = turtle.inspectDown()

    if (checkData.name == "minecraft:bedrock") then
        unload(false)
        doWork = false
        print("TASK COMPLETE: I've been a miner o7")
    else
        if (invFull) then
            unload(true)
        end
        down(1)
        qTurningDir = sanitizeDir(qTurningDir + 2)
        for i = 1,y,1 do
            for j = 2,x,1 do
                if (invFull) then
                    unload(true)
                end
                forward(1)
            end
            if (i ~= y) then
                local currDir = facingDir
                faceDir(qTurningDir)
                forward(1)
                if (invFull) then
                    unload(true)
                end
                faceDir(sanitizeDir(currDir + 2))
            else
                faceDir(sanitizeDir(facingDir + 2))
            end
        end
    end
end