if not (os.loadAPI("KAPI")) then
    error("Could not load KAPI")
end

--[Constansts]--

--[Globals]--

--[Functions]--
---------------Epic Unit Test Framework---------------
function FailHandler(testName, expected, actual)
    KAPI.kill()
    if actual ~= nil then
        error("Failed Test: " .. testName .. "\n" .. "expected: " .. expected .. " recieved: " .. actual)
    else if expected ~= nil then
        error("Failed Test: " .. testName .. "\n" .. "expected: " .. expected)
    end
        error("Failed Test: " .. testName)
    end
end

function PassHandler(testName)
    print("Passed Test:" .. testName)
end

function AssertEquals(testName, expected, actual)
    if expected == actual then
        PassHandler(testName)
    else
        FailHandler(testName, expected, actual)
    end
end

function AssertNotNull(testName, actual)
    if nil ~= actual then
        PassHandler(testName)
    else
        FailHandler(testName,"not nil")
    end
end

function AssertNull(testName, actual)
    if nil == actual then
        PassHandler(testName)
    else
        FailHandler(testName,"nil")
    end
end

function AssertTrue(testName, actual)
    if actual then
        PassHandler(testName)
    else
        FailHandler(testName,"true")
    end
end

function AssertFalse(testName, actual)
    if not actual then
        PassHandler(testName)
    else
        FailHandler(testName,"false")
    end
end

---------------Maths functions test---------------
function TestCeilGPS() -- deprecated?
    --get pos,  
 end
 
 function TestSanitizeCard()
    AssertEquals("testSanitizeCard_neg1", 3, KAPI.sanitizeCard(-1))
    AssertEquals("testSanitizeCard_neg2", 2, KAPI.sanitizeCard(-2))
    AssertEquals("testSanitizeCard_neg3", 1, KAPI.sanitizeCard(-3))
    AssertEquals("testSanitizeCard_neg4", 0, KAPI.sanitizeCard(-4))

    AssertEquals("testSanitizeCard_pos4", 0, KAPI.sanitizeCard(4))
    AssertEquals("testSanitizeCard_pos5", 1, KAPI.sanitizeCard(5))
    AssertEquals("testSanitizeCard_pos6", 2, KAPI.sanitizeCard(6))
    AssertEquals("testSanitizeCard_pos7", 3, KAPI.sanitizeCard(7))
 end
 
 function TestFlipDirection()
    AssertEquals("TestFlipDirection_front", 3, KAPI.flipDirection(0))
    AssertEquals("TestFlipDirection_down", 2, KAPI.flipDirection(1))
    AssertEquals("TestFlipDirection_up", 1, KAPI.flipDirection(2))
    AssertEquals("TestFlipDirection_back", 0, KAPI.flipDirection(3))
 end
-------------------------------------------------
---------------Getter/Setter Tests---------------
function TestSetGetProgName()
    KAPI.setProgName("KAPITEST")
    AssertEquals("testSetGetProgName", "KAPITEST", KAPI.getProgName())
    KAPI.kill()
end

function TestSetGetStartingCard()
    KAPI.setStartingCard(0)
    AssertEquals("testSetGetStartingCard", 0, KAPI.getStartingCard())
    KAPI.kill()
end

function TestSetGetFacingCard()
    KAPI.setFacingCard(0)
    AssertEquals("testSetGetFacingCard", 0, KAPI.getFacingCard())
    KAPI.kill()
end

function TestSetGetMoveTimeout()
    KAPI.setMoveTimeout(66)
    AssertEquals("testSetGetMoveTimeout", 66, KAPI.getMoveTimeout())
    KAPI.kill()
end

function TestSetGetToolHand()
    KAPI.setToolHand("poop")
    AssertEquals("testSetGetToolHand", "poop", KAPI.getToolHand())
    KAPI.kill()
end

function TestSetGetStorageBlockID()
    KAPI.setStorageBlockID("poop2")
    AssertEquals("testSetGetStorageBlockID", "poop2", KAPI.getStorageBlockID())
    KAPI.kill()
end

function TestSetGetState()
    KAPI.setState("poop3")
    AssertEquals("testSetGetState", "poop3", KAPI.getState())
    KAPI.kill()
end

function TestSetGetOriginVar()
    KAPI.setOriginVar(vector.new(1,2,3))
    local origvar = KAPI.getOriginVar()
    AssertEquals("testSetGetOriginVar_X", 1, origvar.x)
    AssertEquals("testSetGetOriginVar_Y", 2, origvar.y)
    AssertEquals("testSetGetOriginVar_Z", 3, origvar.z)
    KAPI.kill()
end

-------------------------------------------------
---------------GPS/Init globals Tests---------------
function TestInit()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    local log = fs.open("log/log_KAPITEST", "r")
    AssertNotNull("testInit_log", log)
    log.close()
    local origin = fs.open("res/coords_origin", "r")
    AssertNotNull("testInit_origin", origin)
    origin.close()
    AssertNotNull("testInit_facing", KAPI.getFacingCard())
    KAPI.kill()
end

function TestInitArgs()
    KAPI.init()
    AssertEquals("testInitArgs_startingCard", 0, KAPI.getStartingCard())
    AssertEquals("testInitArgs_toolHand", "right", KAPI.getToolHand())
    AssertEquals("testInitArgs_storageBlockID", "minecraft:chest", KAPI.getStorageBlockID())
    AssertEquals("testInitArgs_facingCard", KAPI.getStartingCard(), KAPI.getFacingCard())
    AssertEquals("testInitArgs_progName", "KAPI", KAPI.getProgName())
    local kapiOrigin = KAPI.getOriginVar()
    local orig = vector.new(gps.locate(10))
    if orig.x == nil then
        error("Failed Test: testInitArgs\nGPS Unavailable")
    end
    AssertEquals("testInitArgs_origin_x", orig.x, kapiOrigin.x)
    AssertEquals("testInitArgs_origin_y", orig.y, kapiOrigin.y)
    AssertEquals("testInitArgs_origin_z", orig.z, kapiOrigin.z)
    AssertEquals("testInitArgs_moveTimeout", 10, KAPI.getMoveTimeout())
    AssertEquals("testInitArgs_State", false, KAPI.getState())
    KAPI.kill()
end

function TestInitOrigWrite()
    KAPI.init()
    local orig = vector.new(gps.locate(10))
    if orig.x == nil then
        error("Failed Test: testInitOrigWrite\nGPS Unavailable")
    end
    local file = fs.open("res/coords_origin", "r")
    AssertEquals("testInitOrigWrite_x", orig.x, math.floor(file.readLine()))
    AssertEquals("testInitOrigWrite_y", orig.y, math.floor(file.readLine()))
    AssertEquals("testInitOrigWrite_z", orig.z, math.floor(file.readLine()))
    AssertEquals("testInitOrigWrite_card", 0, math.floor(file.readLine()))
    file.close()
    KAPI.kill()
end

function TestLogger()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    KAPI.logger("test message")
    local file = fs.open("log/log_KAPITEST", "r")
    AssertEquals("loggerTest_line_1", "", file.readLine())
    file.readLine()
    file.readLine()
    AssertTrue("loggerTest_line_2", string.find(file.readLine(), "initializing KAPI"))
    file.close()
    KAPI.kill()
end

function TestGetOrigin()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    KAPI.setOriginVar(vector.new(1,2,3))
    KAPI.setStartingCard(3)
    local kapiOrig = KAPI.getOrigin()
    AssertEquals("testGetOrigin_X", 1, kapiOrig[1])
    AssertEquals("testGetOrigin_Y", 2, kapiOrig[2])
    AssertEquals("testGetOrigin_Z", 3, kapiOrig[3])
    AssertEquals("testGetOrigin_Z", 3, kapiOrig[4])
    KAPI.kill()
end

function TestGetOriginfromFile()
    local file = fs.open("res/coords_origin", "w") 
    if (file == nil) then
        error("Failed Test: testGetOriginfromFile\nCould not write to res/coords_origin")
    else
        file.writeLine(0)
        file.writeLine(1)
        file.writeLine(2)
        file.writeLine(3)
    end
    file.close()
    local kapiOrig = KAPI.getOrigin()
    AssertEquals("testGetOriginfromFile_X", 0, math.floor(kapiOrig[1]))
    AssertEquals("testGetOriginfromFile_Y", 1, math.floor(kapiOrig[2]))
    AssertEquals("testGetOriginfromFile_Z", 2, math.floor(kapiOrig[3]))
    AssertEquals("testGetOriginfromFile_Card", 3, math.floor(kapiOrig[4]))
    KAPI.kill()
end

function TestUpdateLastPos()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    KAPI.setFacingCard(0)
    local pos = vector.new(gps.locate(10))
    if pos.x == nil then
        error("Failed Test: testUpdateLastPos\nGPS Unavailable")
    end
    local kapiPos = KAPI.updateLastPos()
    AssertEquals("testUpdateLastPos_X", pos.x, kapiPos.x)
    AssertEquals("testUpdateLastPos_Y", pos.y, kapiPos.y)
    AssertEquals("testUpdateLastPos_Z", pos.z, kapiPos.z)
    local file = fs.open("res/coords_last_known", "r")
    AssertEquals("testUpdateLastPos_x_read", pos.x, math.floor(file.readLine()))
    AssertEquals("testUpdateLastPos_y_read", pos.y, math.floor(file.readLine()))
    AssertEquals("testUpdateLastPos_z_read", pos.z, math.floor(file.readLine()))
    AssertEquals("testUpdateLastPos_card", 0, math.floor(file.readLine()))
    file.close()
    KAPI.kill()
end

-------------------------------------------------
---------------Inventory Tests---------------

function TestGetItemID()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Place dirt in slot 16(bottom right)")
    read()
    AssertEquals("testGetItemID_pass", "minecraft:dirt", KAPI.getItemID(16))
    AssertEquals("testGetItemID_fail", "failed",KAPI.getItemID(6))
    KAPI.kill()
end

function TestFindItem()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    AssertEquals("testFindItem_pass", 16, KAPI.findItem("minecraft:dirt"))
    AssertEquals("testFindItem_fail", 0, KAPI.findItem("nothingness"))
    KAPI.kill()
end

function TestChangeTo()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    AssertTrue("testChangeTo_pass", KAPI.changeTo("minecraft:dirt"))
    AssertTrue("testChangeTo_repeat", KAPI.changeTo("minecraft:dirt"))
    AssertFalse("testChangeTo_fail", KAPI.changeTo("nothingness"))
    KAPI.kill()
end

function TestCheckIfFull()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    AssertTrue("testCheckIfFull", KAPI.checkIfFull)
    KAPI.kill()
end


-------------------------------------------------
---------------Basic Interactions Tests---------------
function TestFaceCard()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    KAPI.faceCard(1)
    print("Am I facing East (y/n)?")
    AssertEquals("testFaceCard_east", "y", read())
    KAPI.faceCard(2)
    print("Am I facing North (y/n)?")
    AssertEquals("testFaceCard_north", "y", read())
    KAPI.faceCard(3)
    print("Am I facing West (y/n)?")
    AssertEquals("testFaceCard_west", "y", read())
    KAPI.faceCard(4)
    print("Am I facing South (y/n)?")
    AssertEquals("testFaceCard_south", "y", read())
    KAPI.kill()

end

function TestAttack()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Place a chicken in all interaction directions")
    read()
    AssertTrue("testAttack_pass_front", KAPI.attack(0))
    AssertTrue("testAttack_pass_down", KAPI.attack(1))
    AssertTrue("testAttack_pass_up", KAPI.attack(2))
    AssertTrue("testAttack_pass_back", KAPI.attack(3))
    print("\"Remove\" the chickens please")
    read()
    AssertFalse("testAttack_fail_front", KAPI.attack(0))
    AssertFalse("testAttack_fail_down", KAPI.attack(1))
    AssertFalse("testAttack_fail_up", KAPI.attack(2))
    AssertFalse("testAttack_fail_back", KAPI.attack(3))
    KAPI.kill()
end

function TestDig()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Place dirt in all interactable directions")
    read()
    AssertTrue("testDig_pass_front", KAPI.dig(0))
    AssertTrue("testDig_pass_down", KAPI.dig(1))
    AssertTrue("testDig_pass_up", KAPI.dig(2))
    AssertTrue("testDig_pass_back", KAPI.dig(3))
    AssertFalse("testDig_fail_front", KAPI.dig(0))
    AssertFalse("testDig_fail_down", KAPI.dig(1))
    AssertFalse("testDig_fail_up", KAPI.dig(2))
    AssertFalse("testDig_fail_back", KAPI.dig(3))
    KAPI.kill()
end

function TestPlace()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Put a 4 blocks of dirt and vanilla wooden planks in inv")
    read()
    KAPI.changeTo("minecraft:dirt")
    AssertTrue("testPlace_pass_front", KAPI.place(0))
    AssertTrue("testPlace_pass_down", KAPI.place(1))
    AssertTrue("testPlace_pass_up", KAPI.place(2))
    AssertTrue("testPlace_pass_back", KAPI.place(3))

    AssertTrue("testPlace_skip_front", KAPI.place(0))
    AssertTrue("testPlace_skip_down", KAPI.place(1))
    AssertTrue("testPlace_skip_up", KAPI.place(2))
    AssertTrue("testPlace_skip_back", KAPI.place(3))

    KAPI.changeTo("minecraft:oak_planks")
    AssertTrue("testPlace_replace_front", KAPI.place(0))
    AssertTrue("testPlace_replace_down", KAPI.place(1))
    AssertTrue("testPlace_replace_up", KAPI.place(2))
    AssertTrue("testPlace_replace_back", KAPI.place(3))

    KAPI.dig(0)
    KAPI.dig(1)
    KAPI.dig(2)
    KAPI.dig(3)
    KAPI.kill()
end

function TestUnload()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Place vanilla chest in all interactable directions.\nPut something in the inventory after every unload.")
    read()
    KAPI.unload(0)
    print("Did I unload front (y/n)?")
    AssertEquals("testUnload_front", "y", read())
    print("Fill'er up!")
    read()
    KAPI.unload(1)
    print("Did I unload down (y/n)?")
    AssertEquals("testUnload_down", "y", read())
    print("Fill'er up!")
    read()
    KAPI.unload(2)
    print("Did I unload up (y/n)?")
    AssertEquals("testUnload_up", "y", read())
    print("Fill'er up!")
    read()
    KAPI.unload(3)
    print("Did I unload back (y/n)?")
    AssertEquals("testUnload_back", "y", read())

    KAPI.kill()
end

function TestTake()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Place vanilla chest in all interactable directions.\nPut at least a stack in each chests.")
    read()
    KAPI.take(0)
    print("Did I take from front (y/n)?")
    AssertEquals("TestTake_front", "y", read())
    read()
    KAPI.take(1)
    print("Did I take from down (y/n)?")
    AssertEquals("TestTake_down", "y", read())
    read()
    KAPI.take(2)
    print("Did I take from up (y/n)?")
    AssertEquals("TestTake_up", "y", read())
    read()
    KAPI.take(3)
    print("Did I take from back (y/n)?")
    AssertEquals("TestTake_back", "y", read())

    KAPI.dig(0)
    KAPI.dig(1)
    KAPI.dig(2)
    KAPI.dig(3)
    KAPI.kill()
end

-------------------------------------------------
---------------Movement Tests---------------
function TestMoveSoft()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Remove blocks above and in front of turtle")
    read()
    AssertTrue("testMoveSoft_forwards_pass", KAPI.moveSoft(0))
    AssertTrue("testMoveSoft_backwards_pass", KAPI.moveSoft(3))
    AssertTrue("testMoveSoft_up_pass", KAPI.moveSoft(2))
    AssertTrue("testMoveSoft_down_pass", KAPI.moveSoft(1))
    print("Place blocks in all movable directions")
    read()
    AssertFalse("testMoveSoft_forwards_fail", KAPI.moveSoft(0))
    AssertFalse("testMoveSoft_backwards_fail", KAPI.moveSoft(3))
    AssertFalse("testMoveSoft_up_fail", KAPI.moveSoft(2))
    AssertFalse("testMoveSoft_down_fail", KAPI.moveSoft(1))
end

function TestMoveSoftALot()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Remove blocks above and in front of turtle")
    read()
    AssertTrue("testMoveSoftALot_forwards_pass", KAPI.moveSoftALot(0,2))
    AssertTrue("testMoveSoftALot_backwards_pass", KAPI.moveSoftALot(3,2))
    AssertTrue("testMoveSoftALot_up_pass", KAPI.moveSoftALot(2,2))
    AssertTrue("testMoveSoftALot_down_pass", KAPI.moveSoftALot(1,2))
    print("Place blocks in all movable directions with a gap of 1 in front and above")
    read()
    AssertFalse("testMoveSoftALot_forwards_fail", KAPI.moveSoftALot(0,2))
    AssertFalse("testMoveSoftALot_backwards_fail", KAPI.moveSoftALot(3,2))
    AssertFalse("testMoveSoftALot_up_fail", KAPI.moveSoftALot(2,2))
    AssertFalse("testMoveSoftALot_down_fail", KAPI.moveSoftALot(1,2))
end

function TestMoveHard()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Place blocks above and in front of turtle")
    read()
    AssertTrue("testMoveHard_forwards_pass", KAPI.moveHard(0))
    AssertTrue("testMoveHard_backwards_pass", KAPI.moveHard(3))
    AssertTrue("testMoveHard_up_pass", KAPI.moveHard(2))
    AssertTrue("testMoveHard_down_pass", KAPI.moveHard(1))
    print("Place bedrock in all movable directions")
    read()
    AssertFalse("testMoveHard_forwards_fail", KAPI.moveHard(0))
    AssertFalse("testMoveHard_backwards_fail", KAPI.moveHard(3))
    AssertFalse("testMoveHard_up_fail", KAPI.moveHard(2))
    AssertFalse("testMoveHard_down_fail", KAPI.moveHard(1))
    KAPI.kill()
end

function TestMoveHardALot()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Place blocks above and in front of turtle + 1")
    read()
    AssertTrue("testMoveHardALot_forwards_pass", KAPI.moveHardALot(0,2))
    AssertTrue("testMoveHardALot_backwards_pass", KAPI.moveHardALot(3,2))
    AssertTrue("testMoveHardALot_up_pass", KAPI.moveHardALot(2,2))
    AssertTrue("testMoveHardALot_down_pass", KAPI.moveHardALot(1,2))
    print("Place Bedrock in all movable directions with a gap of 1 in front and above")
    read()
    AssertFalse("testMoveHardALot_forwards_fail", KAPI.moveHardALot(0,2))
    AssertFalse("testMoveHardALot_backwards_fail", KAPI.moveHardALot(3,2))
    AssertFalse("testMoveHardALot_up_fail", KAPI.moveHardALot(2,2))
    AssertFalse("testMoveHardALot_down_fail", KAPI.moveHardALot(1,2))
end

function TestGoTo()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    local goPos = KAPI.updateLastPos()
    goPos= vector.new(goPos.x + 2, goPos.y + 2, goPos.z + 2)
    print("Turtle will go +2 in all directions\nGoing to: ".. goPos.x .. ', ' .. goPos.y .. ', ' .. goPos.z)
    read()
    KAPI.goTo(goPos)
    print("Did I go +2 and am I facing the same direction? (y/n)")
    AssertEquals("testGoTo_positive", "y", read())

    goPos = vector.new(goPos.x - 2, goPos.y - 2, goPos.z - 2)
    print("Turtle will go -2 in all directions\nGoing to: ".. goPos.x .. ', ' .. goPos.y .. ', ' .. goPos.z)
    read()
    KAPI.goTo(goPos)
    print("Did I go -2(starting position) and am I facing the same direction? (y/n)")
    AssertEquals("testGoTo_negative", "y", read())
    KAPI.kill()
end

--TODO - goTo recovery test

--[Main]--
--!!Do not skip the first 3 sections when writing new tests!!--
print("Place facing South")
read()
--Maths--
TestSanitizeCard()
TestFlipDirection()
--Setters/Getters--
TestSetGetProgName()
TestSetGetStartingCard()
TestSetGetFacingCard()
TestSetGetMoveTimeout()
TestSetGetToolHand()
TestSetGetStorageBlockID()
TestSetGetOriginVar()
TestSetGetState()
--Init\GPS--
TestInit()
TestInitArgs()
TestInitOrigWrite()
TestLogger()
TestGetOrigin()
TestGetOriginfromFile()
TestUpdateLastPos()
--Inventory--
TestGetItemID()
TestFindItem()
TestChangeTo()
TestCheckIfFull()
--Basic Interactions--
TestFaceCard()
TestAttack()
TestDig()
TestPlace()
TestUnload()
TestTake()
--Movements--
TestMoveSoft()
TestMoveSoftALot()
TestMoveHard()
TestMoveHardALot()
TestGoTo()