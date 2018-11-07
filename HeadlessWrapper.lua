#@
-- This wrapper allows the program to run headless on any OS (in theory)
-- It can be run using a standard lua interpreter, although LuaJIT is preferable


-- Callbacks
local callbackTable = { }
local mainObject
local function runCallback(name, ...)
	if callbackTable[name] then
		return callbackTable[name](...)
	elseif mainObject and mainObject[name] then
		return mainObject[name](mainObject, ...)
	end
end
function SetCallback(name, func)
	callbackTable[name] = func
end
function GetCallback(name)
	return callbackTable[name]
end
function SetMainObject(obj)
	mainObject = obj
end

require 'Stubs'

dofile("Launch.lua")

runCallback("OnInit")
runCallback("OnFrame") -- Need at least one frame for everything to initialise

if mainObject.promptMsg then
	-- Something went wrong during startup
	print(mainObject.promptMsg)
	io.read("*l")
	return
end

local build = mainObject.main.modes["BUILD"]

local function loadBuildFromJSON(getItemsJSON, getPassiveSkillsJSON)
	mainObject.main:SetMode("BUILD", false, "")
	runCallback("OnFrame")
	local charData = build.importTab:ImportItemsAndSkills(getItemsJSON)
	build.importTab:ImportPassiveTreeAndJewels(getPassiveSkillsJSON, charData)
end

require('lib.import.character_window')
character_window = common.New('CharacterWindow')
char = character_window:getAccountCharacter('seekays', 'VortexInnuendo')

loadBuildFromJSON(char.itemJson, char.skillJson)

print("Imported level: " .. build.characterLevel)
build.calcsTab:BuildOutput()
build:OnFrame({})
for index, stat in pairs(build.displayStats) do
  -- Not all stats have stats...
  if stat.stat and build.calcsTab.mainOutput[stat.stat] then
    print(stat.stat..": "..build.calcsTab.mainOutput[stat.stat])
  end
  -- print(stat.label..":"..build.calcsTab.mainOutput[stat.stat])
end
-- Probably optional
-- runCallback("OnExit")
