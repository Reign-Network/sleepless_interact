local LocalEntityInteraction = require 'classes.localEntityInteraction'
local utils = require 'imports.utils'

---@class NetEntityInteraction: Interaction
local NetEntityInteraction = lib.class('NetEntityInteraction', LocalEntityInteraction)

function NetEntityInteraction:constructor(data)
    self:super(data)
    self.netId = data.netId
end

function NetEntityInteraction:update(data)
    utils.loadInteractionDefaults(data, self.resource)

    self.renderDistance = data.renderDistance
    self.activeDistance = data.activeDistance
    self.options = data.options
    self.DuiOptions = {}

    self.private.cooldown = data.cooldown

    for i = 1, #self.options do
        self.DuiOptions[i] = { text = self.options[i].label or self.options[i].text, icon = self.options[i].icon }
    end

    self.netId = data.netId
    self.bone = data.bone
    self.offset = data.offset
    self.removeWhenDead = data.removeWhenDead
end

function NetEntityInteraction:getEntity()
    if self.isDestroyed or not self:verifyEntity() then
        return 0
    end
    self.entity = NetworkGetEntityFromNetworkId(self.netId)
    return self.entity
end

function NetEntityInteraction:verifyEntity()
    if not self.isDestroyed and ((self.globalType and not NetworkDoesEntityExistWithNetworkId(self.netId)) or (self.removeWhenDead and IsEntityDead(NetworkGetEntityFromNetworkId(self.netId)))) then
        self.isDestroyed = true
        lib.print.warn(string.format('entity didnt exist with netid %s for interaction: %s. interaction removed', self.netId, self.id))
        interact.removeById(self.id)
        if self.globalType then
            utils.wipeCacheForEntityKey(self.globalType, self.netId)
        end
        return false
    end
    return true
end

return NetEntityInteraction
