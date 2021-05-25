require "/scripts/vore/npcvore.lua"

audio = false

-- Set this to determine how long each stage of "compression" will last.  The lower the value, the faster she compresses you.
-- Default is 30.  Don't go any lower than 2 or you might have problems actually escaping.  Or it'll break.  Either way, not good.
stageInterval = 30

-- Fluff-wise, she tends to only UB people that want it.  So player vore should be request only, usually.
-- Besides, she only does her thing with request vore, so yah.  :P
playerChance = 0
npcChance = 0.01

talkTimer = 0

playerLines = {	"^red;<3",
				"^white;O^pink;#^white;v^pink;#^white;O",
				"-v- ~ ^red;<3",
				"^red;<3 <3 <3",
				"^red;<3 ^pink;<3 ^red;<3",
				"^red;*love*",
				"^red;*warmth*",
				"^red;*pleasure*",
				"^red;*happiness*",
				"^red;*bliss*"
}

function initHook()

	if storage.belly == nil then
		storage.belly = ""
	end
	
end

function feedHook()

	npc.setItemSlot( "head", "argonpcheadbelly1" )
	npc.setItemSlot( "chest", "argonpcchestbelly1" )
	npc.setItemSlot( "legs", "argonpcpantsbelly1" )

	storage.belly = "1"

end

function loseHook()
	
--	if isPlayer then
--		entity.say("^blue;<3")
--	end
	
	npc.setItemSlot( "head", "argonpchead" )
	npc.setItemSlot( "chest", "argonpcchest" )
	npc.setItemSlot( "legs", "argonpcpants" )
	
	storage.belly = ""
	
	isPlayer = false
	
end

function interact(args)
	
	if reqTimer < 0.7 then
		if #victim > 0 then
			if request[#victim] then
				if stopWatch[#victim] <= stageInterval then
					reqRelease(args)
					npc.say("^blue;<3")
				else
					stopWatch[#victim] = stopWatch[#victim] - stageInterval
				end
			else
				reqRelease(args)
			end
		else
			victim[#victim + 1] = args.sourceId
			request[#victim] = true
			isPlayer[#victim] = true
			world.sendEntityMessage( victim[#victim], "applyStatusEffect", effect, duration, entity.id() )
	
			dress()
			requestHook(input)
		end
		do return end
	else
		reqTimer = 0
	end

	interactHook()
	oldInteract(args)
end

function updateHook()

	if #victim == 1 and request[#victim] then
		if stopWatch[#victim] > stageInterval*5 then
			npc.setItemSlot( "head", "argonpcheadbelly5" )
			npc.setItemSlot( "chest", "argonpcchest" )
			npc.setItemSlot( "legs", "argonpcpants" )
			storage.belly = "5"
		elseif stopWatch[#victim] > stageInterval*4 then
			npc.setItemSlot( "head", "argonpcheadbelly5" )
			npc.setItemSlot( "chest", "argonpcchestbelly5" )
			npc.setItemSlot( "legs", "argonpcpantsbelly5" )
			storage.belly = "5"
		elseif stopWatch[#victim] > stageInterval*3 then
			npc.setItemSlot( "head", "argonpcheadbelly4" )
			npc.setItemSlot( "chest", "argonpcchestbelly4" )
			npc.setItemSlot( "legs", "argonpcpantsbelly4" )
			storage.belly = "4"
		elseif stopWatch[#victim] > stageInterval*2 then
			npc.setItemSlot( "head", "argonpcheadbelly3" )
			npc.setItemSlot( "chest", "argonpcchestbelly3" )
			npc.setItemSlot( "legs", "argonpcpantsbelly3" )
			storage.belly = "3"
		elseif stopWatch[#victim] > stageInterval then
			npc.setItemSlot( "head", "argonpcheadbelly2" )
			npc.setItemSlot( "chest", "argonpcchestbelly2" )
			npc.setItemSlot( "legs", "argonpcpantsbelly2" )
			storage.belly = "2"
		elseif stopWatch[#victim] <= stageInterval then
			npc.setItemSlot( "head", "argonpcheadbelly1" )
			npc.setItemSlot( "chest", "argonpcchestbelly1" )
			npc.setItemSlot( "legs", "argonpcpantsbelly1" )
			storage.belly = "1"
		end
		if stopWatch[#victim] > stageInterval*5.7 then
			stopWatch[#victim] = stageInterval*5.6
		end
	end

	if npc.isLounging() then
		if #victim > 0 then
			npc.setItemSlot( "head", "argonpcheadbelly" .. storage.belly .. "blink" )
		else
			npc.setItemSlot( "head", "argonpcheadblink" )
		end
	else
		if #victim > 0 then
			npc.setItemSlot( "head", "argonpcheadbelly" .. storage.belly )
		else
			npc.setItemSlot( "head", "argonpchead" )
		end
	end

	if containsPlayer() and math.random(700) == 1 then
		sayLine( playerLines )
	end
end