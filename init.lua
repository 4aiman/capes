default_model = "helmet.x"
--
-- Start of configuration area:
--

-- Player animation speed
animation_speed = 30

-- Player animation blending
-- Note: This is currently broken due to a bug in Irrlicht, leave at 0
animation_blend = 0

-- Frame ranges for each player model
function armour_get_animations(model)

        return {
        stand_START = 0,
        stand_END = 79,
        sit_START = 81,
        sit_END = 160,
        lay_START = 162,
        lay_END = 166,
        walk_START = 168,
        walk_END = 187,
        mine_START = 189,
        mine_END = 198,
        walk_mine_START = 200,
        walk_mine_END = 219
        }

end


-- Player stats and animations
local player_model = {}
local player_anim = {}
local player_sneak = {}
local ANIM_STAND = 1
local ANIM_SIT = 2
local ANIM_LAY = 3
local ANIM_WALK  = 4
local ANIM_WALK_MINE = 5
local ANIM_MINE = 6


-- Update appearance when the player joins
-- minetest.register_on_joinplayer(ar_update_visuals)



local ar = {
    physical = false,
    collisionbox = {-0.5,-1,-0.5, 0.5,1,0.5},
    visual = "mesh",
    mesh = "helmet.x",
    textures = {"ar.png"},
    visual_size = {x=1, y=1, z = 1},
    wielder = nil,
    v = 0,
    animation_speed = 30,
    animation_blend = 0,
    animation = ANIM_STAND,
}


function ar:on_rightclick(clicker)
    if not clicker or not clicker:is_player() then
        return
    end
    --if self.wielder and clicker == self.wielder then
---        self.wielder = nil
    --    clicker:set_detach()
--    elseif not self.driver then
        self.wielder = clicker
        -- self.object:set_attach(self.wielder, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
        self.object:setyaw(self.wielder:get_look_yaw())
            
      --  minetest.chat_send_all(self.mesh)
        local anim = armour_get_animations(self.mesh)
        self.object:set_animation({x=anim.stand_START, y=anim.stand_STOP}, 30, 0)

--    end
end

function ar:on_step(dtime)
  local wielder = self.wielder
  if wielder == nil then 
     return 
  end
--  local name = wielder:get_player_name()
--  if name ~=nil then 
 
        local controls = wielder:get_player_control()
        local walking = false
        local animation_speed_mod = animation_speed
        local anim = armour_get_animations(self.mesh)


        if controls.up 
        or controls.down 
        or controls.left 
        or controls.right 
        then
            walking = true
        end

        
        if  controls.sneak 
        and wielder:get_hp() ~= 0 
        and (walking or controls.LMB) 
        then
            animation_speed_mod = animation_speed_mod / 2                    
        else
            animation_speed_mod = animation_speed_mod * 2        
        end



        if wielder:get_hp() == 0 then
           if self.animation ~= ANIM_LAY then
              self.object:set_animation({x=anim.lay_START, y=anim.lay_END}, animation_speed_mod, animation_blend)
              self.animation = ANIM_LAY
           end 
           
        elseif walking and controls.LMB then
           if self.animation ~= ANIM_WALK_MINE then
              self.object:set_animation({x=anim.walk_mine_START, y=anim.walk_mine_END}, animation_speed_mod, animation_blend)
              self.animation = ANIM_WALK_MINE
           end 
           
        elseif walking then
           if self.animation ~= ANIM_WALK then
              self.object:set_animation({x=anim.walk_START, y=anim.walk_END}, animation_speed_mod, animation_blend)
              self.animation = ANIM_WALK
           end 
           
        elseif controls.LMB then
           if self.animation ~= ANIM_MINE then
              self.object:set_animation({x=anim.mine_START, y=anim.mine_END}, animation_speed_mod, animation_blend)
              self.animation = ANIM_MINE
           end 
           
        else
           if self.animation ~= ANIM_STAND then
              self.object:set_animation({x=anim.stand_START, y=anim.stand_END}, animation_speed_mod, animation_blend)
              self.animation = ANIM_STAND
           end 
           
        end


end

minetest.register_entity("capes:ar", ar)


minetest.register_craftitem("capes:helmet", {
    description = "Cape",
    inventory_image = "ar.png",
    wield_image = "ar.png",
    wield_scale = {x=2, y=2, z=1},
    liquids_pointable = true,
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return
        end
        local arm = minetest.env:add_entity(pointed_thing.above, "capes:ar")
        local prop = {mesh = "helmet.x",    }
        arm:set_properties(prop)
        itemstack:take_item()
        return itemstack
    end,
})


minetest.register_craftitem("capes:char", {
    description = "Cape",
    inventory_image = "ar.png",
    wield_image = "ar.png",
    wield_scale = {x=2, y=2, z=1},
    liquids_pointable = true,

    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return
        end
        local arm = minetest.env:add_entity(pointed_thing.above, "capes:ar")
        local prop = {mesh = "character.x",    }
        arm:set_properties(prop)
        itemstack:take_item()
        return itemstack
    end,
})
