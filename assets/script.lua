require("NeoEngineLua")

-- Print credits
print("Music played by Daniel Veesey (http://freemusicarchive.org/music/Daniel_Veesey/)")

local engine = NeoEngineLua.NeoEngine.getInstance()
local level = engine:getLevel()
local scene = level:getCurrentScene()
local camera = scene:getCameraByName("Camera")
local body = scene:getEntityByName("Body")
local head = scene:getEntityByName("Head")

local input = engine:getInputContext()
local mouse = input:getMouse()

local system = engine:getSystemContext()
local physics = engine:getPhysicsContext()
local bulletId = 0

input:setMouseRelative(true)

-- Start music
scene:getSoundByName("PianoMusic"):play()

function emitBullet(position, cameraMatrix)
	local bullet = scene:addNewEntity(level:loadMesh(system:getWorkingDirectory() .. "/assets/box.obj"))
	local props = bullet:createPhysicsProperties()

	bullet:setPosition(position)
	bullet:updateMatrix()
	
	bullet:setName("bullet" .. bulletId)
	bulletId = bulletId + 1
	
	props:setMass(10)
	bullet:enablePhysics()
	
	physics:addCentralForce(props:getCollisionObjectId(), cameraMatrix:getRotatedVector3(NeoEngineLua.Vector3(0,0, -500)))
end

function addCentralForce(object, force)
	local physprop = object:getPhysicsProperties()
	physics:addCentralForce(physprop:getCollisionObjectId(), force)
end

function clamp(min, max, c)
	if c < min then 
		return min 
	elseif c > max then 
		return max 
	else 
		return c
	end
end

local direction = NeoEngineLua.Vector3()
local bodyMatrix = NeoEngineLua.Matrix4x4()
bodyMatrix:loadIdentity()

body:setInvisible(true)

function update(dt)
	local direction = mouse:getDirection()
	
	local camrot = camera:getEulerRotation()
	camera:setEulerRotation(NeoEngineLua.Vector3(clamp(0, 160, camrot.x - direction.y), 0, camrot.z - direction.x))
	bodyMatrix:setRotationZ(camera:getEulerRotation().z)
	
	if input:isKeyDown(NeoEngineLua.KEY_W) then
		addCentralForce(body, bodyMatrix * NeoEngineLua.Vector3(0,500,0)*dt, false)
	elseif input:isKeyDown(NeoEngineLua.KEY_S) then
		addCentralForce(body, bodyMatrix * NeoEngineLua.Vector3(0,-500,0)*dt, false)
	end
	
	if input:isKeyDown(NeoEngineLua.KEY_A) then
		addCentralForce(body, bodyMatrix * NeoEngineLua.Vector3(-500,0,0)*dt, false)
	elseif input:isKeyDown(NeoEngineLua.KEY_D) then
		addCentralForce(body, bodyMatrix * NeoEngineLua.Vector3(500,0,0)*dt, false)
	end
	
	if mouse:onKeyDown(NeoEngineLua.MOUSE_BUTTON_LEFT) then
		emitBullet(camera:getPosition(), camera:getMatrix())
	end
	
	if input:isKeyDown(NeoEngineLua.KEY_LEFT_ARROW) then
		direction.x = -25
	elseif input:isKeyDown(NeoEngineLua.KEY_RIGHT_ARROW) then
		direction.x = 25
	else
		direction.x = 0
	end
end

function draw()

end

function onEnd()

end 
