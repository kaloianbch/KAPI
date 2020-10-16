if not (os.loadAPI("KAPI")) then
    error("Could not load KAPI")
end

--[Constansts]--

--[Globals]--

--[Functions]--

--[Main]--
KAPI.setProgName("Template")
--You can and should set the other KAPI globals as needed
KAPI.init()
--logic goes here
KAPI.kill()