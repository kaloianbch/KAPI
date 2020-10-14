if not (os.loadAPI("KAPI")) then
    error("Could not load KAPI")
end

KAPI.setProgName("Template")
--KAPI.setStartingCard(0)
--KAPI.setMoveTimeout(10)
--KAPI.setStorageBlockID("minecraft:chest")

--[Constansts]--

--[Globals]--

--[Functions]--
---------------Epic Unit Test Framework---------------
function failHandler(testName, expected, actual)
    if actual ~= nil then
        error("Failed Test: " .. testName .. "\n" .. "expected: " .. expected .. " recieved: " .. actual)
    else if expected ~= nil then
        error("Failed Test: " .. testName .. "\nexpected: not nil")
    end
        error("Failed Test: " .. testName)
    end
end

function passHandler(testName)
    print("Passed Test:" .. testName)
end

function assertEquals(testName, expected, actual)
    if expected == actual then
        passHandler(testName)
    else
        failHandler(testName, expected, actual)
    end
end

function assertNotNull(testName, actual)
    if nil ~= actual then
        passHandler(testName)
    else
        failHandler(testName,"nil")
    end
end

function assertTrue(testName, actual)
    if actual then
        passHandler(testName)
    else
        failHandler(testName,"expected: true")
    end
end

function assertFalse(testName, actual)
    if not actual then
        passHandler(testName)
    else
        failHandler(testName,"expected: false")
    end
end

---------------Maths functions test---------------
function testCeilGPS() -- deprecated?
    --get pos,  
 end
 
 function testSanitizeCard()
    assertEquals("testSanitizeCard", 3, -1)
    assertEquals("testSanitizeCard", 2, -2)
    assertEquals("testSanitizeCard", 1, -3)
    assertEquals("testSanitizeCard", 0, -4)

    assertEquals("testSanitizeCard", 0, 4)
    assertEquals("testSanitizeCard", 1, 5)
    assertEquals("testSanitizeCard", 2, 6)
    assertEquals("testSanitizeCard", 3, 7)
 end
-------------------------------------------------
---------------Getter/Setter Tests---------------
function testSetGetProgName()
    KAPI.setProgName("KAPITEST")
    assertEquals("testSetGetProgName", "KAPITEST", KAPI.getProgName())
    KAPI.kill()
end

function testSetGetStartingCard()
    KAPI.setStartingCard(0)
    assertEquals("testSetGetStartingCard", 0, KAPI.getStartingCard())
    KAPI.kill()
end

function testSetGetFacingCard()
    KAPI.setFacingCard(0)
    assertEquals("testSetGetFacingCard", 0, KAPI.getFacingCard())
    KAPI.kill()
end

function testSetGetMoveTimeout()
    KAPI.setMoveTimeout(66)
    assertEquals("testSetGetMoveTimeout", 66, KAPI.getMoveTimeout())
    KAPI.kill()
end

function testSetGetToolHand()
    KAPI.setToolHand("poop")
    assertEquals("testSetGetToolHand", "poop", KAPI.getToolHand())
    KAPI.kill()
end

function testSetGetStorageBlockID()
    KAPI.setStorageBlockID("poop2")
    assertEquals("testSetGetStorageBlockID", "poop2", KAPI.getStorageBlockID())
    KAPI.kill()
end

function testSetGetState()
    KAPI.setState("poop3")
    assertEquals("testSetGetState", "poop3", KAPI.getState())
    KAPI.kill()
end

function testSetGetOriginVar()
    KAPI.setOriginVar(vector.new(1,2,3))
    local origvar = KAPI.getOriginVar()
    assertEquals("testSetGetOriginVar_X", 1, origvar.x)
    assertEquals("testSetGetOriginVar_Y", 2, origvar.y)
    assertEquals("testSetGetOriginVar_Z", 3, origvar.z)
    KAPI.kill()
end

-------------------------------------------------
---------------GPS/Init globals Tests---------------
function testInit()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    local log = fs.open("log/log_KAPITEST", "r")
    assertNotNull("testInit_log", log)
    log.close()
    local origin = fs.open("res/coords_origin", "r")
    assertNotNull("testInit_origin", origin)
    origin.close()
    assertNotNull("testInit_facing", KAPI.getFacingCard())
    KAPI.kill()
end

function testInitArgs()
    KAPI.init()
    assertEquals("testInitArgs_startingCard", 0, KAPI.getStartingCard())
    assertEquals("testInitArgs_toolHand", "left", KAPI.getToolHand())
    assertEquals("testInitArgs_storageBlockID", "minecraft:chest", KAPI.getStorageBlockID())
    assertEquals("testInitArgs_facingCard", KAPI.getStartingCard(), KAPI.getFacingCard())
    assertEquals("testInitArgs_progName", "KAPI", KAPI.getProgName())
    local kapiOrigin = KAPI.getOriginVar()
    local orig = vector.new(gps.locate(10))
    if orig.x == nil then
        error("Failed Test: testInitArgs\nGPS Unavailable")
    end
    assertEquals("testInitArgs_origin_x", orig.x, kapiOrigin.x)
    assertEquals("testInitArgs_origin_y", orig.y, kapiOrigin.y)
    assertEquals("testInitArgs_origin_z", orig.z, kapiOrigin.z)
    assertEquals("testInitArgs_moveTimeout", 10, KAPI.getMoveTimeout())
    assertEquals("testInitArgs_State", false, KAPI.getState())
    KAPI.kill()
end

function testInitOrigWrite()
    KAPI.init()
    local orig = vector.new(gps.locate(10))
    if orig.x == nil then
        error("Failed Test: testInitOrigWrite\nGPS Unavailable")
    end
    local file = fs.open("res/coords_origin", "r")
    assertEquals("testInitOrigWrite_x", orig.x, math.floor(file.readLine()))
    assertEquals("testInitOrigWrite_y", orig.y, math.floor(file.readLine()))
    assertEquals("testInitOrigWrite_z", orig.z, math.floor(file.readLine()))
    assertEquals("testInitOrigWrite_card", 0, math.floor(file.readLine()))
    file.close()
    KAPI.kill()
end

function loggerTest()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    KAPI.logger("test message")
    local file = fs.open("log/log_KAPITEST", "r")
    assertEquals("loggerTest_line_1", "", file.readLine())
    assertTrue("loggerTest_line_2", string.find(file.readLine(), "initializing KAPI"))
    file.close()
    KAPI.kill()
end

function testGetOrigin()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    KAPI.setOriginVar(vector.new(1,2,3))
    KAPI.setStartingCard(3)
    local kapiOrig = KAPI.getOrigin()
    assertEquals("testGetOrigin_X", 1, kapiOrig[1])
    assertEquals("testGetOrigin_Y", 2, kapiOrig[2])
    assertEquals("testGetOrigin_Z", 3, kapiOrig[3])
    assertEquals("testGetOrigin_Z", 3, kapiOrig[4])
    KAPI.kill()
end

function testGetOriginfromFile()
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
    assertEquals("testGetOriginfromFile_X", 0, math.floor(kapiOrig[1]))
    assertEquals("testGetOriginfromFile_Y", 1, math.floor(kapiOrig[2]))
    assertEquals("testGetOriginfromFile_Z", 2, math.floor(kapiOrig[3]))
    assertEquals("testGetOriginfromFile_Card", 3, math.floor(kapiOrig[4]))
    KAPI.kill()
end

function testUpdateLastPos()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    KAPI.setFacingCard(0)
    local pos = vector.new(gps.locate(10))
    if pos.x == nil then
        error("Failed Test: testUpdateLastPos\nGPS Unavailable")
    end
    local kapiPos = KAPI.updateLastPos()
    assertEquals("testUpdateLastPos_X", pos.x, kapiPos.x)
    assertEquals("testUpdateLastPos_Y", pos.y, kapiPos.y)
    assertEquals("testUpdateLastPos_Z", pos.z, kapiPos.z)
    local file = fs.open("res/coords_last_known", "r")
    assertEquals("testUpdateLastPos_x_read", pos.x, math.floor(file.readLine()))
    assertEquals("testUpdateLastPos_y_read", pos.y, math.floor(file.readLine()))
    assertEquals("testUpdateLastPos_z_read", pos.z, math.floor(file.readLine()))
    assertEquals("testUpdateLastPos_card", 0, math.floor(file.readLine()))
    file.close()
    KAPI.kill()
end

-------------------------------------------------
---------------Inventory Tests---------------

function testGetItemID()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    print("Place dirt in slot 16(bottom right)")
    read()
    assertEquals("testGetItemID_pass", "minecraft:dirt", KAPI.getItemID(16))
    assertEquals("testGetItemID_fail", "failed",KAPI.getItemID(6))
    KAPI.kill()
end

function testFindItem()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    assertEquals("testFindItem_pass", 16, KAPI.findItem("minecraft:dirt"))
    assertEquals("testFindItem_fail", 0, KAPI.findItem("nothingness"))
    KAPI.kill()
end

function testChangeTo()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    assertTrue("testChangeTo_pass", KAPI.changeTo("minecraft:dirt"))
    assertFalse("testChangeTo_fail", KAPI.changeTo("nothingness"))
    KAPI.kill()
end

function testCheckIfFull()
    KAPI.setProgName("KAPITEST")
    KAPI.init()
    assertTrue("testCheckIfFull", KAPI.checkIfFull)
    KAPI.kill()
    print("Clean out inventory")
    read()
end


-------------------------------------------------
---------------Basic Interactions Tests---------------
function testAttack()
    --
end

function testDig()
    --
end

function testFaceCard()
    --
end

function testPlace()
    --
end

function testUnload()
    --
end

-------------------------------------------------
---------------Movement Tests---------------
function testMoveSoft()
    --
end

function testMoveSoftALot()
    --
end

function testMoveHard()
    --
end

function testMoveHardALot()
    --
end

function testGoTo()
    --
end

--[Main]--

--Setters/Getters--
testSetGetProgName()
testSetGetStartingCard()
testSetGetFacingCard()
testSetGetMoveTimeout()
testSetGetToolHand()
testSetGetStorageBlockID()
testSetGetOriginVar()
testSetGetState()
--Init\GPS--
testInit()
testInitArgs()
testInitOrigWrite()
loggerTest()
testGetOrigin()
testGetOriginfromFile()
testUpdateLastPos()
--Inventory--
testGetItemID()
testFindItem()
testChangeTo()
testCheckIfFull()