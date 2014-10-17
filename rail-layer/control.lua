require "defines"

local edge={x=0,y=0}
local active=false
local raildirection=0
local wanteddirection=0
local traindirection=0
local cargo_straight=0
local cargo_curve=0

local curves={
  {raildirection=2, wanteddirection=3, curvedir=6, xoffset=-2, yoffset= 2, xmove=-8, ymove= 4, corner=0, cornerx= 0, cornery= 0, cornerr=0},
  {raildirection=2, wanteddirection=1, curvedir=7, xoffset=-2, yoffset= 0, xmove=-8, ymove=-4, corner=0, cornerx= 0, cornery= 0, cornerr=0},
  {raildirection=6, wanteddirection=5, curvedir=3, xoffset= 4, yoffset= 2, xmove= 6, ymove= 4, corner=0, cornerx= 0, cornery= 0, cornerr=0},
  {raildirection=6, wanteddirection=7, curvedir=2, xoffset= 4, yoffset= 0, xmove= 6, ymove=-4, corner=0, cornerx= 0, cornery= 0, cornerr=0},

  {raildirection=0, wanteddirection=1, curvedir=0, xoffset= 0, yoffset=-2, xmove=-6, ymove=-8, corner=1, cornerx=-4, cornery=-6, cornerr=1},
  {raildirection=0, wanteddirection=7, curvedir=1, xoffset= 2, yoffset=-2, xmove= 4, ymove=-8, corner=1, cornerx= 4, cornery=-6, cornerr=7},
  {raildirection=4, wanteddirection=3, curvedir=5, xoffset= 0, yoffset= 4, xmove=-6, ymove= 8, corner=1, cornerx=-4, cornery= 6, cornerr=3},
  {raildirection=4, wanteddirection=5, curvedir=4, xoffset= 2, yoffset= 4, xmove= 4, ymove= 8, corner=1, cornerx= 4, cornery= 6, cornerr=5},

  {raildirection=1, wanteddirection=2, curvedir=3, xoffset= 0, yoffset= 0, xmove=-6, ymove=-2, corner=0, cornerx= 0, cornery= 0, cornerr=0},
  {raildirection=1, wanteddirection=0, curvedir=4, xoffset= 0, yoffset=-2, xmove=-2, ymove=-8, corner=1, cornerx= 2, cornery= 0, cornerr=5},
  {raildirection=5, wanteddirection=4, curvedir=0, xoffset= 4, yoffset= 4, xmove= 4, ymove= 8, corner=1, cornerx= 0, cornery= 0, cornerr=1},
  {raildirection=5, wanteddirection=6, curvedir=7, xoffset= 4, yoffset= 2, xmove= 8, ymove= 2, corner=0, cornerx= 0, cornery= 0, cornerr=0},

  {raildirection=3, wanteddirection=4, curvedir=1, xoffset= 0, yoffset= 4, xmove=-2, ymove= 8, corner=1, cornerx= 2, cornery= 0, cornerr=7},
  {raildirection=3, wanteddirection=2, curvedir=2, xoffset= 0, yoffset= 2, xmove=-6, ymove= 2, corner=0, cornerx= 0, cornery= 0, cornerr=0},
  {raildirection=7, wanteddirection=6, curvedir=6, xoffset= 4, yoffset= 0, xmove= 8, ymove=-2, corner=0, cornerx= 0, cornery= 0, cornerr=0},
  {raildirection=7, wanteddirection=0, curvedir=5, xoffset= 4, yoffset=-2, xmove= 4, ymove=-8, corner=1, cornerx= 0, cornery= 0, cornerr=3}
}

 local cm={
   {{x=-2,y=-4},{x=-2,y=-2},{x=-1,y=0},{x=-1,y=-2},{x=0,y=0},{x=0,y=2}},
   {{x=0,y=-4},{x=0,y=-2},{x=-1,y=0},{x=-1,y=-2},{x=-2,y=0},{x=-2,y=2}},
   {{x=-4,y=0},{x=-2,y=0},{x=0,y=-1},{x=-2,y=-1},{x=0,y=-2},{x=2,y=-2}},
   {{x=-4,y=-2},{x=-2,y=-2},{x=0,y=-1},{x=-2,y=-1},{x=0,y=0},{x=2,y=0}}
}

local function check_tech()
  if (game.player.force.technologies["automated-rail-transportation"].researched) then
    game.player.force.technologies["automated-rail-transportation"].researched=false
    game.player.force.technologies["automated-rail-transportation"].researched=true
	game.player.force.recipes["rail-layer"].enabled=true
  end
end

game.oninit(function()
	check_tech()
end)

game.onload(function()
	check_tech()
end)

local function update_cargo()
    cargo_straight=0
    cargo_curve=0
	local train=game.player.character.vehicle.train.carriages
	for _, entity in ipairs(train) do
	  if (entity.name=="cargo-wagon") then
	    local inv=entity.getinventory(1).getcontents()
		if inv["straight-rail"] then cargo_straight=cargo_straight+inv["straight-rail"] end
		if inv["curved-rail"] then cargo_curve=cargo_curve+inv["curved-rail"] end
	  end
	end
end

local function remove_from_train(rname)
	local train=game.player.character.vehicle.train.carriages
	for _, entity in ipairs(train) do
	  if (entity.name=="cargo-wagon") then
	    local inv=entity.getinventory(1).getcontents()
		if inv[rname] then 
		  entity.getinventory(1).remove({name=rname, count=1}) 
		  return
		end
	  end
	end
end

local function add_to_train(rname)
	local train=game.player.character.vehicle.train.carriages
	for _, entity in ipairs(train) do
	  if (entity.name=="cargo-wagon") then
        if (entity.getinventory(1).caninsert({name=rname, count=1})) then
		  entity.getinventory(1).insert({name=rname, count=1})
		  return true
		end
	  end
	end
	return false
end

local function removetrees(xpos,ypos)
  local bb2={{xpos-1, ypos-1}, {xpos+1, ypos+1}}
  for _, entity in ipairs(game.findentitiesfiltered{area = bb2, type="tree"}) do
	--game.player.print("Removing "..entity.name.. " @("..entity.position.x..","..entity.position.y..").")
	entity.die()
	if (add_to_train("raw-wood")) then
	  --game.player.print("inserting wood")
	else
	  --game.player.print("train full")
    end
  end
end

local function canplace2_water(xpos, ypos)
  local res=true
  for xx=-1,1 do 
    for yy=-1,1 do 
      if ((game.gettile(xpos+xx, ypos+yy).name=="water") or 
		  (game.gettile(xpos+xx, ypos+yy).name=="deepwater") or
		  (game.gettile(xpos+xx, ypos+yy).name=="water-green") or
		  (game.gettile(xpos+xx, ypos+yy).name=="deepwater-green")) then 
	    res=false  
      end
    end
  end
  return res
end


local function hastrack(xpos,ypos,rot,rtype)
 -- if (rtype=="curved-rail") then return false end
		local bb={{xpos-0.22, ypos-0.22}, {xpos+0.22, ypos+0.22}}
		local res=false
	    for _, entity in ipairs(game.findentitiesfiltered{area = bb, name=rtype}) do
		--for _, entity in ipairs(game.findentities(bb)) do
			--game.player.print(entity.name)
			if ((rtype=="straight-rail") and (entity.direction%2==0)) then
				if ((entity.name==rtype) and (entity.direction%4==rot%4) and (entity.position.x==xpos) and (entity.position.y==ypos)) then res=true end
			else
				if ((entity.name==rtype) and (entity.direction==rot) and (entity.position.x==xpos) and (entity.position.y==ypos)) then res=true end
			end
		end
		return res
end
 
local function placetrack(xpos,ypos,rot,rtype)
   if (rtype=="straight-rail") then removetrees(xpos,ypos) end
   if (rtype=="curved-rail") then 
	 for i=1,6 do 
        removetrees(xpos+cm[rot%4+1][i].x,ypos+cm[rot%4+1][i].y)
	 end
   end

   --local canplace=game.canplaceentity{name = rtype, position= {xpos, ypos}, direction=rot}
   local canplace=true
   
   if (rtype=="curved-rail") then
	 for i=1,6 do 
        if not (canplace2_water(xpos+cm[rot%4+1][i].x,ypos+cm[rot%4+1][i].y)) then canplace=false end
	 end
   end
   if (rtype=="straight-rail") then
        canplace=canplace2_water(xpos,ypos)
   end


   if (canplace) then
	if (not hastrack(xpos,ypos,rot,rtype)) then
		game.createentity{name = rtype, position= {xpos, ypos}, direction=rot, force=game.forces.player}
		remove_from_train(rtype)
		return true
	else
		--game.player.print("ERROR (hastrack), rail @(".. edge.x ..",".. edge.y ..").")
		return false
	end
  else
    --game.player.print("ERROR (canplaceentity), rail @(".. edge.x ..",".. edge.y ..").")
    return false
  end
  
  return false
end



game.onevent(defines.events.ontick, function(event)

if game.player.character and game.player.character.vehicle and game.player.character.vehicle.name == "rail-layer" then
  
  --if not (game.tick%2==0) then	return  end

  local tmpx=math.floor(game.player.character.vehicle.position.x)
  local tmpy=math.floor(game.player.character.vehicle.position.y)

  local d1=1
  local d2=1
  local lut={{1,2,0}, {3,2,4}, {5,6,4}, {7,6,0}}
  local cursor=game.player.screen2realposition(game.player.cursorposition)
  local ax=math.abs(cursor.x-tmpx)
  local ay=math.abs(cursor.y-tmpy)
  if (ax>ay*2) then d1=2 end
  if (ay>ax*2) then d1=3 end
  if (cursor.x-tmpx>0) then
	if (cursor.y-tmpy>0) then d2=3 else d2=4 end
  else
	if (cursor.y-tmpy>0) then d2=2 else d2=1 end
  end
  wanteddirection=lut[d2][d1]

  traindirection=math.floor(-game.player.character.vehicle.orientation*8+0.5)%8

  if (not active) then
	local foundrail=false
	local bb3={{tmpx-1, tmpy-1}, {tmpx+1, tmpy+1}}
    for _, entity in ipairs(game.findentities(bb3)) do
	  if (entity.name=="straight-rail") then
		if (((entity.direction%2==0) and (entity.direction%4==traindirection%4)) or (entity.direction==traindirection)) then 
		  --game.player.print(entity.name.. " @("..entity.position.x..","..entity.position.y..") r=".. entity.direction)
		  edge.x=entity.position.x
		  edge.y=entity.position.y
		  if (traindirection==5) then edge.y=edge.y+2 end
		  if (traindirection==7) then edge.y=edge.y-2 end
		  foundrail=true
		end
	  end
	end
	active=foundrail
	raildirection=traindirection
	if not (wanteddirection==traindirection) then active=false end
  else
	--local distance=math.sqrt((edge.x-tmpx)*(edge.x-tmpx)+(edge.y-tmpy)*(edge.y-tmpy))
	local distance=math.abs(edge.x-tmpx)+math.abs(edge.y-tmpy)


	update_cargo()
	--game.player.print("s="..cargo_straight.." c="..cargo_curve)
	if (distance<10) then
	  --straight
	  if (raildirection==wanteddirection) then
	    --orthogonal -|
	    if ((raildirection%2==0) and (cargo_straight>0)) then 
	 	  placetrack(edge.x,edge.y,raildirection,"straight-rail") 
	      if (raildirection==0) then edge.y=edge.y-2 end
		  if (raildirection==4) then edge.y=edge.y+2 end
	      if (raildirection==2) then edge.x=edge.x-2 end
	      if (raildirection==6) then edge.x=edge.x+2 end
	    end
	    --diagonal \
	    if ((raildirection%4==1) and (cargo_straight>1)) then 
		  placetrack(edge.x+2,edge.y,7,"straight-rail") 
		  placetrack(edge.x,edge.y-.5,3,"straight-rail") 
	      if (raildirection==1) then 
	   	    edge.x=edge.x-2
		    edge.y=edge.y-2
	      end
	      if (raildirection==5) then 
  		    edge.x=edge.x+2
		    edge.y=edge.y+2
		  end
  	    end
	  --diagonal /
	    if ((raildirection%4==3) and (cargo_straight>1)) then 
		  placetrack(edge.x+2,edge.y,1,"straight-rail") 
		  placetrack(edge.x+.5,edge.y,5,"straight-rail") 
	      if (raildirection==3) then 
	   	    edge.x=edge.x-2
		    edge.y=edge.y+2
	      end
	      if (raildirection==7) then 
		    edge.x=edge.x+2
		    edge.y=edge.y-2
		  end
  	    end
	    --[[
        for i=edge.x-10,edge.x+10,1 do 
	      for j=edge.y-10,edge.y+10,1 do 
		    game.settiles{{name="dirt", position={edge.x, edge.y}}}
	      end
        end
        game.settiles{{name="sand", position={edge.x, edge.y}}}
	    --]]
      end
	--curves
	  if ((cargo_curve>0) and (cargo_straight>0)) then
      for i=1,16,1 do 
          if (raildirection==curves[i].raildirection) and (wanteddirection==curves[i].wanteddirection) then
		    local success=false
		    success=placetrack(edge.x+curves[i].xoffset,edge.y+curves[i].yoffset,curves[i].curvedir,"curved-rail")
	        if ((curves[i].corner==1) and (success)) then
          			if (curves[i].cornerr%2 == 0) then
            			    placetrack(edge.x+curves[i].cornerx, edge.y+curves[i].cornery, curves[i].cornerr, "straight-rail")
          			end
          			if (curves[i].cornerr%8 == 1) then
          			    placetrack(edge.x+curves[i].cornerx, edge.y+curves[i].cornery-1, 3, "straight-rail")
          			end
          			if (curves[i].cornerr%8 == 3) then
          			    placetrack(edge.x+curves[i].cornerx+.5, edge.y+curves[i].cornery+.5, 1, "straight-rail")
          			end
          			if (curves[i].cornerr%8 == 5) then
          			    placetrack(edge.x+curves[i].cornerx-1, edge.y+curves[i].cornery, 3, "straight-rail")
          			end
          			if (curves[i].cornerr%8 == 7) then
          			    placetrack(edge.x+curves[i].cornerx, edge.y+curves[i].cornery-1, 1, "straight-rail")
          			end
	        end
            raildirection=wanteddirection
            edge.x=edge.x+curves[i].xmove
	        edge.y=edge.y+curves[i].ymove
          end
        end
	  end
    end
  end
else
  active=false
end

end)