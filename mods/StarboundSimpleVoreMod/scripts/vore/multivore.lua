require "/scripts/vore/exclusions.lua"

oldInit = init
oldInteract = interact
oldUpdate = update

---------------------------------------------------------------------------------------
--#####################################################################################
--CONFIG SECTION

-- Player Chance is a percent chance that the player will be vored compared to the standard base chance
-- Keep the value anywhere between 0 and 1
-- 0% = 0, 50% = 0.5 or 1/2, 100% chance = 1.0
-- This can also be done in the individual .lua files.
playerChance = 0.5

-- Audio will activate, Guess what, the audio portion of the mod. This will turn off audio for all preds.
-- For individual preds, you can overide this value to suit your needs.
-- This line can either be "true" or "false"
audio = true

-- Enabling Preds on Ships will allow your predators to devour players on your ship. We do this by removing
-- the player invincibility on ships. There is no easy way to communicate between pred and status effect
-- so I can't open and close this window selectively, without fail, and without breaking it. Enabling Preds
-- on ships will remove your invincibility on your ship only. This will probably remove it for every server
-- you go to forever. I could easily fix this but the solution could be used for a great amount of griefing
-- so I won't be including it in the mod. The only consequences I can think of are you will take a small
-- amount of fall damage on your ship if you jump far enought, and beaming to your ship won't make fire/acid
-- go away like normal. If you don't want this, it is disabled by default, if you do want this, you have read
-- all this and realize the risk. If you join a server with this option enabled, just don't put preds on your
-- ship. You must also remove them from your ship before joining a server with this configuration. You need
-- to enable this on both this script and npcvore.lua script, should you want this to apply to that group.
predsOnShips = false
--#####################################################################################
---------------------------------------------------------------------------------------
duration 	= 120
playerTimer = 120
talkTimer	= 1
stopWatch	= { 0, 0, 0 }

capacity	= 3

i 			= 0
j			= 0

isDigest	= false
isPlayer	= false
requested	= false

head		= nil
chest		= nil
legs		= nil
back		= nil

midhead		= nil
midchest	= nil
midlegs		= nil
midback		= nil

fullhead	= nil
fullchest	= nil
fulllegs	= nil
fullback	= nil

request		= { false, false, false }
victim		= { nil, nil, nil }

voreeffect = "dragonvore"
projectile	= "npcvoreprojectile"
dprojectile	= "npcdvoreprojectile"

function init()

	oldInit()
	npc.setInteractive(true)

	if predsOnShips then
		world.setProperty("invinciblePlayers", false)
	end

	initHook()
end

function feed()
	
	local people = world.entityQuery( mcontroller.position(), 7, {
		withoutEntityId = entity.id(),
		includedTypes = {"npc", "player"},
		boundMode = "CollisionArea"
	})
	
	local eggcheck = world.entityQuery( mcontroller.position(), 7, {
		withoutEntityId = entity.id(),
		includedTypes = {"npc", "player", "projectile"},
		boundMode = "CollisionArea"
	})
	
	local personalspace = world.entityQuery( mcontroller.position(), 2, {
		withoutEntityId = entity.id(),
		includedTypes = {"npc", "player"},
		boundMode = "CollisionArea"
	})
	
	
	if #people == #victim + 1 and #eggcheck == #victim + 1 and #personalspace == #victim then
		
		i = 1
		temp = 1
		
--		First Victim
		if #victim == 0 then
			victim[1] = world.entityName(people[temp])
--		Second and third Victims
		else			
			for i=1, #people do
				j = 1
				while (j <= #victim) do	
					if world.entityName(people[i]) == victim[j] then
						break
					end
					j = j+1
				end
				if j == #victim+1 then
					temp = i
				end
			end
			victim[#victim+1] = world.entityName(people[temp])
		end
		
		
		
		if world.isNpc( people[temp] ) then
			for k = 1, #exclusionList do
				if world.entityName(people[temp]) == exclusionList[k] then
					return
				end
			end
		else
			isPlayer = true
		end
				
		local collisionBlocks = world.collisionBlocksAlongLine(mcontroller.position(), world.entityPosition( people[temp] ), {"Null", "Block", "Dynamic"}, 1)
		if #collisionBlocks ~= 0 then
			isPlayer = false
			return
		end
		
		if ( isPlayer and math.random() <= playerChance ) or isPlayer == false or requested then
		
			tem = entity.id()
			
			if requested then
				tem = tem + 20000
				request[#victim] = true
				forceFeed()
			end
			
			if isDigest then
				tem = tem + 10000
			end
			
			local mergeOptions = {
				statusEffects = {
				{
					effect = voreeffect,
					duration = tem
			}}}
			
			world.spawnProjectile( projectile , world.entityPosition( people[temp] ), entity.id(), {0, 0}, false, mergeOptions)
	
			if audio then
				world.spawnProjectile( "swallowprojectile" , mcontroller.position(), entity.id(), {0, 0}, false )
			end

			redress()
			feedHook()
			
			if isPlayer and requested == false then
				playerTimer = 0
			end
			
		else
			victim[#victim] = nil
		end
	end
	isPlayer = false
	requested = false
end

function digest()

	for i=1, #stopWatch do
		if stopWatch[i] >= duration and request[i] == false then
			
			for j = i, capacity do
			
				if stopWatch[j+1] == capacity then
					stopWatch[j] = 0
					victim[j] = nil
					request[j] = false
				else
					stopWatch[j] = stopWatch[j+1]
					victim[j] = victim[j+1]
					request[j] = request[j+1]
				end				
			end
		redress()
		digestHook()
		do return end
		end
	end
end

function redress()

	if #victim == 0 then
		if head then
			npc.setItemSlot( "head", head )
		end	
		if chest then
			npc.setItemSlot( "chest", chest )
		end	
		if legs then
			npc.setItemSlot( "legs", legs )
		end	
		if back then
			npc.setItemSlot( "back", back )
		end
	elseif #victim == 1 or #victim == 2 then
		if midhead then
			npc.setItemSlot( "head", midhead )
		end
		if midchest then
			npc.setItemSlot( "chest", midchest )
		end
		if midlegs then
			npc.setItemSlot( "legs", midlegs )
		end
		if midback then
			npc.setItemSlot( "back", midback )
		end
	else
		if fullhead then
			npc.setItemSlot( "head", fullhead )
		end	
		if fullchest then
			npc.setItemSlot( "chest", fullchest )
		end	
		if fulllegs then
			npc.setItemSlot( "legs", fulllegs )
		end	
		if fullback then
			npc.setItemSlot( "back", fullback )
		end
	end
	
	dressHook()
end

function update(dt)
	tempupdate = update
	tempinteract = interact
	oldUpdate(dt)
	
	if #victim < capacity and math.random(400) == 1 then
		feed()
	end
	
	if #victim > 0 then
		i = 1
		for i=1, #victim do
			stopWatch[i] = stopWatch[i] + dt
		end
		if playerTimer <= duration then
			playerTimer = playerTimer + dt
		end
		
		if math.random(500) == 1 and audio then
			world.spawnProjectile( "digestprojectile" , mcontroller.position(), entity.id(), {0, 0}, false )
		end
		
		digest()
	end
	
	if talkTimer < 1 then
		talkTimer = talkTimer + dt
	end
	
	updateHook()
	updateHook(dt)
	
	update = tempupdate
	interact = tempinteract
end

function interact(args)
	
	if talkTimer < 1 then
	
		if isVictim( world.entityName( args.sourceId ) ) then
		
			world.spawnProjectile( "cleanser" , world.entityPosition( entity.id() ), entity.id(), {0, 0}, true )
			
			playerTimer = 120
			
			for i=1, capacity do
				request[i] = false
				stopWatch[i] = 0
				victim[i] = nil
			end
			
			redress()
			
			forceExit()
		else
			requested = true
			feed()
		end
		
		talkTimer = 1
		
	else
		talkTimer = 0
	end

	interactHook()
	oldInteract(args)

	return nil

end

function isVictim( name )

	local personalspace = world.entityQuery( mcontroller.position(), 2, {
		withoutEntityId = entity.id(),
		includedTypes = {"npc", "player"},
		boundMode = "CollisionArea"
	})
	
	for i=1, #personalspace do
		if world.entityName( personalspace[i] ) == name then
			return true
		end
	end
	
	return false
	
end

function initHook()

end

function feedHook()

end

function forceExit()

end

function forceFeed()

end

function digestHook()

end

function dressHook()

end

function updateHook()

end

function updateHook(dt)

end

function interactHook()

end