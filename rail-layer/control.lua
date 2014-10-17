require "defines"

local lastRailPosition = {x = 0, y = 0}
local lastBigPolePosition = {x = 0, y = 0}
local lastCheckPole = {x = 0, y = 0}
local active = false
local railDirection = 0
local wantedDirection = 0

local straightRail = 0
local curvedRail = 0
local bigElectricPole = 0

local curves={
  {raildirection = 2, wanteddirection = 3, curvedir = 6, xoffset = -3.0, yoffset =  1.0, xmove = -7.5, ymove =  4.5, corner = 1, cornerx = -6.5, cornery =  3.5, cornerr = 5},
  {raildirection = 2, wanteddirection = 1, curvedir = 7, xoffset = -3.0, yoffset = -1.0, xmove = -6.5, ymove = -3.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0},
  {raildirection = 6, wanteddirection = 5, curvedir = 3, xoffset =  3.0, yoffset =  1.0, xmove =  7.5, ymove =  4.5, corner = 1, cornerx =  6.5, cornery =  3.5, cornerr = 7},
  {raildirection = 6, wanteddirection = 7, curvedir = 2, xoffset =  3.0, yoffset = -1.0, xmove =  6.5, ymove = -3.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0}, 

  {raildirection = 0, wanteddirection = 1, curvedir = 0, xoffset = -1.0, yoffset = -3.0, xmove = -4.5, ymove = -7.5, corner = 1, cornerx = -3.5, cornery = -6.5, cornerr = 7},
  {raildirection = 0, wanteddirection = 7, curvedir = 1, xoffset =  1.0, yoffset = -3.0, xmove =  4.5, ymove = -7.5, corner = 1, cornerx =  3.5, cornery = -6.5, cornerr = 1},
  {raildirection = 4, wanteddirection = 3, curvedir = 5, xoffset = -1.0, yoffset =  3.0, xmove = -3.5, ymove =  6.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0},
  {raildirection = 4, wanteddirection = 5, curvedir = 4, xoffset =  1.0, yoffset =  3.0, xmove =  3.5, ymove =  6.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0},
  
  {raildirection = 1, wanteddirection = 2, curvedir = 3, xoffset = -2.5, yoffset = -1.5, xmove = -7.5, ymove = -2.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0},
  {raildirection = 1, wanteddirection = 0, curvedir = 4, xoffset = -2.5, yoffset = -3.5, xmove = -3.5, ymove = -8.5, corner = 1, cornerx =  0.0, cornery =  0.0, cornerr = 3},
  {raildirection = 5, wanteddirection = 4, curvedir = 0, xoffset =  1.5, yoffset =  2.5, xmove =  2.5, ymove =  7.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 7},
  {raildirection = 5, wanteddirection = 6, curvedir = 7, xoffset =  3.5, yoffset =  2.5, xmove =  8.5, ymove =  3.5, corner = 1, cornerx =  0.0, cornery =  0.0, cornerr = 7},

  {raildirection = 3, wanteddirection = 4, curvedir = 1, xoffset = -1.5, yoffset =  2.5, xmove = -2.5, ymove =  7.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0},
  {raildirection = 3, wanteddirection = 2, curvedir = 2, xoffset = -3.5, yoffset =  2.5, xmove = -8.5, ymove =  3.5, corner = 1, cornerx =  0.0, cornery =  0.0, cornerr = 1},
  {raildirection = 7, wanteddirection = 6, curvedir = 6, xoffset =  2.5, yoffset = -1.5, xmove =  7.5, ymove = -2.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0},
  {raildirection = 7, wanteddirection = 0, curvedir = 5, xoffset =  2.5, yoffset = -3.5, xmove =  3.5, ymove = -8.5, corner = 1, cornerx =  0.0, cornery =  0.0, cornerr = 1}
}

local treeRemoveForCurved = {
    {{x = -1, y = -3}, {x = -1, y = -1}, {x =  0, y = -1}, {x =  1, y = 1}, {x =  0, y = 1}, {x =  1, y = 3}},
	{{x =  1, y = -4}, {x =  1, y = -2}, {x =  0, y = -1}, {x =  0, y = 1}, {x = -1, y = 1}, {x = -1, y = 3}},
	{{x =  3, y = -1}, {x =  1, y = -1}, {x =  1, y =  0}, {x = -1, y = 0}, {x = -1, y = 1}, {x = -3, y = 1}},
	{{x = -3, y = -1}, {x = -1, y = -1}, {x = -1, y =  0}, {x =  1, y = 0}, {x =  1, y = 1}, {x =  3, y = 1}}
}

local function check_tech()
  if (game.player.force.technologies["automated-rail-transportation"].researched) then
    game.player.force.technologies["automated-rail-transportation"].researched = false
    game.player.force.technologies["automated-rail-transportation"].researched = true
	game.player.force.recipes["rail-layer"].enabled = true
  end
end

game.oninit(function()
	check_tech()
end)

game.onload(function()
	check_tech()
end)

local function update_cargo()
    straightRail = 0
    curvedRail = 0
	bigElectricPole = 0
	local train = game.player.character.vehicle.train.carriages
	for _, entity in ipairs(train) do
	  if (entity.type == "cargo-wagon") then
	    local inv = entity.getinventory(1)
		straightRail = straightRail + inv.getitemcount("straight-rail")
		curvedRail = curvedRail + inv.getitemcount("curved-rail")
		bigElectricPole = bigElectricPole + inv.getitemcount("big-electric-pole")
	  end
	end
	--game.player.print("Straight = " .. straightRail .. " curved = " .. curvedRail .. " bigPole = " .. bigElectricPole)
end

local function addItem(itemName, count)
	local train = game.player.character.vehicle.train.carriages
	for _, entity in ipairs(train) do
	  if (entity.type == "cargo-wagon") then
        if (entity.getinventory(1).caninsert({name = itemName, count = count})) then
		  entity.getinventory(1).insert({name = itemName, count = count})
		  return
		else
		    local position = game.findnoncollidingposition("item-on-ground", game.player.character.position, 100, 0.5)
		    game.createentity{name = "item-on-ground", position = position, stack = {name = itemName, count = 1}}
			return
		end
	  end
	end
end

local function removeTrees(X, Y)
    local area = {{X - 1.5, Y - 1.5}, {X + 1.5, Y + 1.5}}
    for _, entity in ipairs(game.findentitiesfiltered{area = area, type = "tree"}) do
        -- game.player.print("Removing "..entity.name.." @("..entity.position.x..","..entity.position.y..").")
		addItem("raw-wood", 1)
		entity.die()
	end
end

local function removeFromTrain(itemName)
    local train = game.player.character.vehicle.train.carriages
    for _, entity in ipairs(train) do
        if (entity.type == "cargo-wagon") then
            local inv = entity.getinventory(1).getcontents()
            if inv[itemName] then
                entity.getinventory(1).remove({name = itemName, count = 1})
			    return
		    end
        end
	end
end

local function hasRail(X, Y, railDirection, railType)
    local area ={{X - 0.22, Y - 0.22}, {X + 0.22, Y + 0.22}}
    local res = false
    for _, entity in ipairs(game.findentitiesfiltered{area = area, name = railType}) do
        if ((railType == "straight-rail") and (entity.direction % 2 == 0)) then
            if ((entity.name == railType) and (entity.direction % 4 == railDirection % 4) and (entity.position.x == X) and (entity.position.y == Y)) then
			    return true
			end
		else
		    if ((entity.name == railType) and (entity.direction == railDirection) and (entity.position.x == X) and (entity.position.y == Y)) then
		        return true
		    end
	    end
	end
	return false
end

local function placeRail(X, Y, railDirection, railType)
    if hasRail(X, Y, railDirection, railType) then
	    return
	end

    if (railType == "straight-rail") then
        removeTrees(X, Y)
	end
	if (railType == "curved-rail") then
		local index = railDirection % 4 + 1
        for i = 1,6 do
		    removeTrees(X + treeRemoveForCurved[index][i].x, Y + treeRemoveForCurved[index][i].y)
		end
	end

    local canplace = game.canplaceentity{name = railType, position = {X, Y}, direction = railDirection}
    if canplace then
        game.createentity{name = railType, position = {X, Y}, direction = railDirection, force = game.forces.player}
        --game.createentity{name = "ghost", position = {X, Y}, innername = railType, direction = railDirection, force = game.player.force}
		removeFromTrain(railType)
        return true
    end
	return false
end

local function placePole(lastRail)
    local polePoint = {x = lastRail.x, y = lastRail.y}
    removeTrees(polePoint.x, polePoint.y)
    local canplace = game.canplaceentity{name = "big-electric-pole", position = {polePoint.x, polePoint.y}}
    if canplace then
        game.createentity{name = "big-electric-pole", position = {polePoint.x, polePoint.y}, force = game.forces.player}
		removeFromTrain("big-electric-pole")
		--game.player.print("last rail position x = " .. lastRail.x .. " y = " .. lastRail.y)
		--game.player.print("Pole position x = " .. polePoint.x .. " y = " .. polePoint.y)
        return true
	else
	    --game.player.print("Can`t place POLE!!!! x = " .. polePoint.x .. " y = " .. polePoint.y)
    end
	return false
end

local function distance(point1, point2)
	local diffX = point1.x - point2.x
	local diffY = point1.y - point2.y
	return diffX * diffX + diffY * diffY
end
	
game.onevent(defines.events.ontick, function(event)
    if game.player.character and game.player.character.vehicle and game.player.character.vehicle.name == "rail-layer" then
		local playerPosition = game.player.character.vehicle.position
		-- game.player.print("Player position x = " .. playerPosition.x .. " y = " .. playerPosition.y)
		-- game.player.print("Want direction = " .. wantedDirection)
		-- game.player.print("Train direction = " .. trainDirection)
        if active then
			local d = math.abs(lastRailPosition.x - playerPosition.x) + math.abs(lastRailPosition.y - playerPosition.y)
			if (d < 15) then
		        local cursor = game.player.screen2realposition(game.player.cursorposition)
		        local ax = math.abs(playerPosition.x - cursor.x)
		        local ay = math.abs(playerPosition.y - cursor.y)

		        if (ax > ay * 2) then
		    	    if (cursor.x - playerPosition.x > 0) then
		                wantedDirection = 6
		        	else
		    	        wantedDirection = 2
		    	    end
	    	    elseif (ay > ax * 2) then
		        	if (cursor.y - playerPosition.y > 0) then
		                wantedDirection = 4
		        	else
		        	    wantedDirection = 0
		        	end
		        elseif (cursor.x - playerPosition.x > 0) then
		        	if (cursor.y - playerPosition.y > 0) then
		                wantedDirection = 5
		        	else
		        	    wantedDirection = 7
		        	end		
		        elseif (cursor.y - playerPosition.y > 0) then
                    wantedDirection = 3
		        else
		            wantedDirection = 1
		        end			
				update_cargo()
			    --game.player.print("Want go to " .. wantedDirection)
				--game.player.print("Go to " .. railDirection)
				if (bigElectricPole > 0) then
				    local tmp = {x = lastCheckPole.x, y = lastCheckPole.y}
				    if railDirection == 0 then
				        lastCheckPole.x = lastRailPosition.x + 2
				    	lastCheckPole.y = lastRailPosition.y
				    elseif railDirection == 1 then
				      	lastCheckPole.x = lastRailPosition.x + 3.5
				    	lastCheckPole.y = lastRailPosition.y - 3.5
				    elseif railDirection == 2 then
				       	lastCheckPole.x = lastRailPosition.x
				    	lastCheckPole.y = lastRailPosition.y - 2
				    elseif railDirection == 3 then
				        lastCheckPole.x = lastRailPosition.x - 3.5
				    	lastCheckPole.y = lastRailPosition.y - 3.5				    
				    elseif railDirection == 4 then
					    lastCheckPole.x = lastRailPosition.x + 2
					    lastCheckPole.y = lastRailPosition.y
				    elseif railDirection == 5 then
				        lastCheckPole.x = lastRailPosition.x + 3.5
					    lastCheckPole.y = lastRailPosition.y - 3.5
				    elseif railDirection == 6 then
				    	lastCheckPole.x = lastRailPosition.x
					    lastCheckPole.y = lastRailPosition.y - 2
				    elseif railDirection == 7 then
				    	lastCheckPole.x = lastRailPosition.x - 3.5
				    	lastCheckPole.y = lastRailPosition.y - 3.5
				    end  
				    local poleDistance = distance(lastBigPolePosition, lastCheckPole)
				    --game.player.print("poleDistance = " .. poleDistance)
				    if  poleDistance > 850 then
				        --game.player.print("lastCheck = " .. lastCheckPole.x)
					    --game.player.print("tmp = " .. tmp.x)
					    placePole(tmp)
					    lastBigPolePosition.x = tmp.x
					    lastBigPolePosition.y = tmp.y					
				    end
                end					
			    if (wantedDirection == railDirection) then
				    if ((railDirection % 2 == 0) and (straightRail > 0)) then 
                        -- horizontal or vertical
						--game.player.print("Rail " .. lastRailPosition.x .. " y = " .. lastRailPosition.y .. "direction = " .. railDirection)
	 	                placeRail(lastRailPosition.x, lastRailPosition.y, railDirection, "straight-rail") 
	                    if (railDirection == 0) then
						    lastRailPosition.y = lastRailPosition.y - 2
						elseif (railDirection == 4) then
						    lastRailPosition.y = lastRailPosition.y + 2
						elseif (railDirection == 2) then
						    lastRailPosition.x = lastRailPosition.x - 2
						elseif (railDirection == 6) then
						    lastRailPosition.x = lastRailPosition.x + 2
						end
			        elseif ((railDirection % 4 == 3) and (straightRail > 1)) then
					    -- giagonal /
						--game.player.print("Rail " .. lastRailPosition.x .. " y = " .. lastRailPosition.y .. "direction = " .. 1)
	 	                placeRail(lastRailPosition.x, lastRailPosition.y, 1, "straight-rail")
						if (railDirection == 7) then
						    --game.player.print("Rail " .. lastRailPosition.x + 1 .. " y = " .. lastRailPosition.y - 1 .. "direction = " .. 5)
	 	                    placeRail(lastRailPosition.x + 1, lastRailPosition.y - 1, 5, "straight-rail")
                            lastRailPosition.x = lastRailPosition.x + 2
                            lastRailPosition.y = lastRailPosition.y - 2
                        else
						    --game.player.print("Rail " .. lastRailPosition.x - 1 .. " y = " .. lastRailPosition.y + 1 .. "direction = " .. 5)
	 	                    placeRail(lastRailPosition.x - 1, lastRailPosition.y + 1, 5, "straight-rail")
                            lastRailPosition.x = lastRailPosition.x - 2
                            lastRailPosition.y = lastRailPosition.y + 2
                        end
			        elseif ((railDirection % 4 == 1) and (straightRail > 1)) then
					    -- giagonal \
						--game.player.print("Rail " .. lastRailPosition.x .. " y = " .. lastRailPosition.y .. "direction = " .. 7)
	 	                placeRail(lastRailPosition.x, lastRailPosition.y, 7, "straight-rail")
						if (railDirection == 5) then
						    --game.player.print("Rail " .. lastRailPosition.x + 1 .. " y = " .. lastRailPosition.y + 1 .. "direction = " .. 3)
	 	                    placeRail(lastRailPosition.x + 1, lastRailPosition.y + 1, 3, "straight-rail")
                            lastRailPosition.x = lastRailPosition.x + 2
                            lastRailPosition.y = lastRailPosition.y + 2
                        else
						    --game.player.print("Rail " .. lastRailPosition.x - 1 .. " y = " .. lastRailPosition.y - 1 .. "direction = " .. 3)
	 	                    placeRail(lastRailPosition.x - 1, lastRailPosition.y - 1, 3, "straight-rail")
                            lastRailPosition.x = lastRailPosition.x - 2
                            lastRailPosition.y = lastRailPosition.y - 2
                        end						
					end
				else
				    if ((curvedRail > 0) and (straightRail > 0)) then
					    for i = 1, 16, 1 do
						    if (railDirection == curves[i].raildirection) and (wantedDirection == curves[i].wanteddirection) then
							    --game.player.print("Curves rail #" .. i .. "x = " .. lastRailPosition.x + curves[i].xoffset .. " y = " .. lastRailPosition.y + curves[i].yoffset)
							    local success = false
								success = placeRail(lastRailPosition.x + curves[i].xoffset, lastRailPosition.y + curves[i].yoffset, curves[i].curvedir, "curved-rail")
								if ((curves[i].corner == 1) and success) then
								    placeRail(lastRailPosition.x + curves[i].cornerx, lastRailPosition.y + curves[i].cornery, curves[i].cornerr, "straight-rail")
								end
								railDirection = wantedDirection
								lastRailPosition.x = lastRailPosition.x + curves[i].xmove
								lastRailPosition.y = lastRailPosition.y + curves[i].ymove
								break
							end
						end
					end
				end
				--game.player.print("Next position x = " .. lastRailPosition.x .. " y = " .. lastRailPosition.y)
			end	
		else
		    local trainDirection = math.abs(math.floor(game.player.character.vehicle.orientation * 8 + 0.5) - 8) % 8
		    local isHaveRail = false
			local railFindArea = {{playerPosition.x - 0.5, playerPosition.y - 0.5}, {playerPosition.x + 0.5, playerPosition.y + 0.5}}
			local poleFindArea = {{playerPosition.x - 30, playerPosition.y - 30}, {playerPosition.x + 30, playerPosition.y + 30}}
			local foundRail = false
			--game.player.print("Player position x = " .. playerPosition.x .. " y = " .. playerPosition.y)
			for _, entity in ipairs(game.findentitiesfiltered{area = railFindArea, type = "rail"}) do
				--game.player.print("Found rail " .. entity.name .. " x = " .. entity.position.x .. " y = " .. entity.position.y)
			    if (entity.name == "straight-rail") then
                    --game.player.print("railDirection = " .. entity.direction)
		            if (entity.direction % 4 == trainDirection % 4) then
					    lastRailPosition = entity.position
						if (trainDirection % 2 == 0) then
						    lastRailPosition = entity.position
                        else
							local x = math.floor(playerPosition.x)
							local y = math.floor(playerPosition.y)
							if x % 2 == 0 and y % 2 == 1 then
						        lastRailPosition.x = x + 0.5
							    lastRailPosition.y = y + 0.5
							elseif x % 2 == 1 and y % 2 == 0 then
						        lastRailPosition.x = x - 0.5
							    lastRailPosition.y = y - 0.5
							elseif x % 2 == 1 and y % 2 == 1 then
						        lastRailPosition.x = x + 0.5
							    lastRailPosition.y = y + 0.5
							else
						        lastRailPosition.x = x + 1.5
							    lastRailPosition.y = y - 0.5
							end
						end
						railDirection = trainDirection
						foundRail = true
						break
				    end
				elseif (entity.name == "curved-rail") then
				    -- TODO
					lastRailPosition = entity.position
					-- railDirection = ??
					foundRail = true
				end
			end
			local distanceForPole
			local minDistance = 99999
			local foundPole = false
			for _, entity in ipairs(game.findentitiesfiltered{area = poleFindArea, name = "big-electric-pole"}) do
			    distanceForPole = distance(entity.position, playerPosition)
				if (minDistance > distanceForPole) then
				    lastBigPolePosition = entity.position
					lastCheckPole.x = lastBigPolePosition.x
				    lastCheckPole.y = lastBigPolePosition.y
					minDistance = distanceForPole
					foundPole = true
					-- game.player.print("Found Pole!!")	
				end
			end
			
			if (not foundPole) then
				-- game.player.print("Initial Pole!!")
				lastBigPolePosition.x = lastRailPosition.x - 50
			    lastBigPolePosition.y = lastRailPosition.y - 50
				lastCheckPole.x = lastRailPosition.x + 2
				lastCheckPole.y = lastRailPosition.x - 2
			end
			
			--game.player.print("trainDirection = " .. trainDirection)
			--game.player.print("last rail x = " .. lastRailPosition.x .. " y = " .. lastRailPosition.y)
			active = foundRail
		end
	else
		active = false
		trainDirection = nil
	end
end)