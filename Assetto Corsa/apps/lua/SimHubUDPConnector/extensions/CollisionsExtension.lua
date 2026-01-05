CollisionsExtension = {}

local carState = ac.getCar(0)

function CollisionsExtension:update(dt, customData)
    customData.CollisionPositionX = carState.collisionPosition.x
    customData.CollisionPositionY = carState.collisionPosition.y
    customData.CollisionPositionZ = carState.collisionPosition.z
    customData.CollidedWithId = carState.collidedWith
    customData.CollidedWith = (carState.collidedWith == 0) and 'Track' or
    ((carState.collidedWith > 0) and ac.getDriverName(carState.collidedWith) or 'None')
    customData.ColliderSpeed = (carState.collidedWith > 0) and ac.getCar(carState.collidedWith).speedKmh or 0
end

return CollisionsExtension