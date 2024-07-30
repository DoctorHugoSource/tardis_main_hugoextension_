-- todo: make the rotation on sliding landing more natural isntead of fixed, also add a check for when sliding off a ramp/cliff

if SERVER then
    function ENT:IsVerticalLanding(collision_data)
        local ang = self:GetAngles()
        local angmax = math.max(math.abs(ang.p), math.abs(ang.r))

        local hit_normal_z = collision_data.HitNormal.z
        local vel = collision_data.OurOldVelocity
        local velh = Vector(vel.x, vel.y, 0):Length()
        local velv = math.abs(vel.z)

        return (angmax < 30 and hit_normal_z < -0.85 and vel.z < 0 and (velh <= 10000 or velv > 500))
    end

    ENT:AddHook("PhysicsCollide", "falling", function(self, data, collider)

        if self:IsVerticalLanding(data) then
            if self:CallHook("ShouldNotPlayLandingSound") ~= true and data.OurOldVelocity.z < -100 then
                self:SendMessage((data.OurOldVelocity.z < -1500) and "fall_crashing_sound" or "fall_landing_sound")
            end

            if math.abs(data.OurOldVelocity.x) > 400 or math.abs(data.OurOldVelocity.y) > 400 then
                self:SetData("slidingspeed", true)
            end

        self:SetData("vertbrakes", true)
            self:Timer("vertbrakes", 10, function()
                self:SetData("vertbrakes", false)
            end)
        end

    end)

    ENT:AddHook("PhysicsUpdate", "falling", function(self,ph)

        local free_movement = not self:GetData("float") and not self:GetData("flight") and not self:IsPlayerHolding()
        free_movement = free_movement and ph:IsGravityEnabled() and self:IsAlive()

        self:SetData("free_movement", free_movement, true)

        if not free_movement then
            if self:GetData("vertbrakes") then
                self:SetData("vertbrakes", false)
            end
            return
        end

        if not self:IsAlive() then return end

        local phm=FrameTime()*66
        local up=self:GetUp()
        local ri2=self:GetRight()
        local fwd2=self:GetForward()
        local ang=self:GetAngles()
        local vel=ph:GetVelocity()
        local vell=ph:GetVelocity():Length()
        local cen=ph:GetMassCenter()
        local mass=ph:GetMass()
        local lev=ph:GetInertia():Length()
        local angv=ph:GetAngleVelocity()

        local function align_in_flight()
            local angmax = math.max(math.abs(ang.p), math.abs(ang.r))
            local angvmax = math.max(math.abs(angv.x), math.abs(angv.y))

            ph:SetAngleVelocityInstantaneous(Vector(angv.x * 0.95, angv.y * 0.95, angv.z))

            if angvmax <= 50 and angmax > 1 then
                ph:ApplyForceOffset( up * -ang.p * 10, cen - fwd2 * lev)
                ph:ApplyForceOffset(-up * -ang.p * 10, cen + fwd2 * lev)
                ph:ApplyForceOffset( up * -ang.r * 10, cen - ri2 * lev)
                ph:ApplyForceOffset(-up * -ang.r * 10, cen + ri2 * lev)
            end
        end

        local function align_on_ground()                                        -- stabilizes the tardis while sliding on the ground like during the unit tower landing in the legend of ruby sunday
            local angmax = math.max(math.abs(ang.p), math.abs(ang.r))
            local angvmax = math.max(math.abs(angv.x), math.abs(angv.y))

            if angvmax <= 50 and angmax > 2 then
                ph:ApplyForceOffset( up * -ang.p * 60, cen - fwd2 * lev)
                ph:ApplyForceOffset(-up * -ang.p * 60, cen + fwd2 * lev)
                ph:ApplyForceOffset( up * -ang.r * 60, cen - ri2 * lev)
                ph:ApplyForceOffset(-up * -ang.r * 60, cen + ri2 * lev)
            end
        end


        local function reduce_movement()
            if math.abs(ang.p) <= 35 and math.abs(ang.r) <= 35 and vel.z > 0 then
                local newvel_x = math.Clamp(vel.x * 0.05,-30,30)
                local newvel_y = math.Clamp(vel.y * 0.05,-30,30)


                ph:SetVelocityInstantaneous(-up * 100 * phm)
                ph:AddVelocity(Vector(newvel_x,newvel_y,0))

                local newavel_x = math.Clamp(angv.x * 0.1,-300,300)
                local newavel_y = math.Clamp(angv.y * 0.1,-300,300)
                local newavel_z = math.Clamp(angv.z * 0.1,-300,300)
                ph:SetAngleVelocityInstantaneous(Vector(newavel_x,newavel_y,newavel_z))
            end
        end

        local function reduce_movement_sliding()
            if math.abs(ang.p) <= 35 and math.abs(ang.r) <= 35 and vel.z > 0 then
                local newvel_x = vel.x
                local newvel_y = vel.y
                -- math.Clamp(vel.x * 0.05,-30,30)

                ph:SetVelocityInstantaneous(-up * 10 * phm)  -- produce a level of base friction and 'stickines' to the ground for extra stability during the slide
                ph:AddVelocity(Vector(newvel_x,newvel_y,0))

                local newavel_z
                local newavel_x = math.Clamp(angv.x * 0.1,-300,300)
                local newavel_y = math.Clamp(angv.y * 0.1,-300,300)
                newavel_z = math.Clamp(1 * (vell * 0.1),30,300)
                if self:GetSpinDir() == 1 then
                newavel_z = newavel_z * -1
                end
                ph:SetAngleVelocityInstantaneous(Vector(newavel_x,newavel_y,newavel_z)) -- induce some slow, artificial spin to give the same feeling as the episode
            end                                                                  -- because it'll never play that nice with actual game physics
        end

        local pressing_down = IsValid(self.pilot) and TARDIS:IsBindDown(self.pilot,"flight-down")
        local vertbrakes = self:GetData("vertbrakes")
        local slidingspeed = self:GetData("slidingspeed", true)
        local stopped = (vell < 10)


        local height = self:OBBMaxs().z - self:OBBMins().z
        local tr = util.QuickTrace(self:GetPos()-Vector(0,0,10), Vector(0,0,-10), self)
        local mattr = util.QuickTrace(self:GetPos()+Vector(0,50,20), Vector(0,0,-40), self)  -- get the material immediately in front of the tardis

        if pressing_down and not vertbrakes and not tr.Hit then
            align_in_flight()
        end

        local function slidingsparks()  -- todo: use a collision box check to determine the corners of any given model instead of hardcoded points

            local sparkposes = {
                [1] = Vector(25,25,-5),
                [2] = Vector(-25,25,-5),
                [3] = Vector(25,-25,-5),
                [4] = Vector(-25,-25,-5),
            }

            local earthmaterials = {

            85,
            78,
            68,
            79,
            74,

            }

            -- i dont think there is any way to detect a material and any kind of corresponding impact effect automatically, so i have to do it manually
            local sparkmat = "ElectricSpark"

                for k,v in pairs (earthmaterials) do -- either dust for earth materials or sparks
                    if v == mattr.MatType then
                        sparkmat = "WheelDust"
                    end
                end

            local effect_data = EffectData()
            effect_data:SetOrigin(self:LocalToWorld(table.Random(sparkposes)))

            effect_data:SetScale(2)
            effect_data:SetMagnitude(3)
            effect_data:SetRadius(0.5)
            util.Effect(sparkmat, effect_data)
        end

        if stopped then
            ph:SetMaterial("default")
            self:SetData("vertbrakes", false)
            self:CancelTimer("vertbrakes")
            self:SetData("slidingspeed", false)
        elseif vertbrakes and slidingspeed then
            ph:SetMaterial("glass")
            reduce_movement_sliding()
            align_on_ground()
            slidingsparks()
        elseif vertbrakes then
            ph:SetMaterial("default")
            reduce_movement()
        end
    end)
else
    ENT:OnMessage("fall_landing_sound", function(self, data, ply)
        if not TARDIS:GetSetting("sound") then return end
        if CurTime() - self:GetData("fall_sound_last", 0) < 2 then return end
        self:SetData("fall_sound_last", CurTime())

        local snds = self.metadata.Exterior.Sounds

        if TARDIS:GetSetting("flight-externalsound") then
            self:EmitSound(snds.FlightLand)
        end

        if IsValid(self.interior) and TARDIS:GetSetting("flight-internalsound") then
            local snds_i = self.metadata.Interior.Sounds
            self.interior:EmitSound(snds_i.FlightLand or snds.FlightLand)
        end
    end)

    ENT:OnMessage("fall_crashing_sound", function(self, data, ply)
        if not TARDIS:GetSetting("sound") then return end
        local snds = self.metadata.Exterior.Sounds

        if TARDIS:GetSetting("flight-externalsound") then
            self:EmitSound(snds.FlightFall)
        end

        if IsValid(self.interior) and TARDIS:GetSetting("flight-internalsound") then
            local snds_i = self.metadata.Interior.Sounds
            self.interior:EmitSound(snds_i.FlightFall or snds.FlightFall)
        end
    end)
end

-- if SERVER then
--     function ENT:IsVerticalLanding(collision_data)
--         local ang = self:GetAngles()
--         local angmax = math.max(math.abs(ang.p), math.abs(ang.r))

--         local hit_normal_z = collision_data.HitNormal.z
--         local vel = collision_data.OurOldVelocity
--         local velh = Vector(vel.x, vel.y, 0):Length()
--         local velv = math.abs(vel.z)

--         return (angmax < 30 and hit_normal_z < -0.85 and vel.z < 0 and (velh <= 10000 or velv > 500))
--     end

--     ENT:AddHook("PhysicsCollide", "falling", function(self, data, collider)

--         if self:IsVerticalLanding(data) then
--             if self:CallHook("ShouldNotPlayLandingSound") ~= true and data.OurOldVelocity.z < -100 then
--                 self:SendMessage((data.OurOldVelocity.z < -1500) and "fall_crashing_sound" or "fall_landing_sound")
--             end

--             self:SetData("vertbrakes", true)
--             self:Timer("vertbrakes", 10, function()
--                 self:SetData("vertbrakes", false)
--             end)
--         end

--     end)

--     ENT:AddHook("PhysicsUpdate", "falling", function(self,ph)

--         local free_movement = not self:GetData("float") and not self:GetData("flight") and not self:IsPlayerHolding()
--         free_movement = free_movement and ph:IsGravityEnabled() and self:IsAlive()

--         self:SetData("free_movement", free_movement, true)

--         if not free_movement then
--             if self:GetData("vertbrakes") then
--                 self:SetData("vertbrakes", false)
--             end
--             return
--         end

--         if not self:IsAlive() then return end

--         local phm=FrameTime()*66
--         local up=self:GetUp()
--         local ri2=self:GetRight()
--         local fwd2=self:GetForward()
--         local ang=self:GetAngles()
--         local vel=ph:GetVelocity()
--         local vell=ph:GetVelocity():Length()
--         local cen=ph:GetMassCenter()
--         local mass=ph:GetMass()
--         local lev=ph:GetInertia():Length()
--         local angv=ph:GetAngleVelocity()

--         local function align_in_flight()
--             local angmax = math.max(math.abs(ang.p), math.abs(ang.r))
--             local angvmax = math.max(math.abs(angv.x), math.abs(angv.y))

--             local height = self:OBBMaxs().z - self:OBBMins().z
--             local tr = util.QuickTrace(self:GetPos(), Vector(0,0,-height))
--             if not tr.Hit then
--             ph:SetAngleVelocityInstantaneous(Vector(angv.x * 0.15, angv.y * 0.15, angv.z))
--             end

--             if angvmax <= 50 and angmax > 1 then
--                 ph:ApplyForceOffset( up * -ang.p * 60, cen - fwd2 * lev)
--                 ph:ApplyForceOffset(-up * -ang.p * 60, cen + fwd2 * lev)
--                 ph:ApplyForceOffset( up * -ang.r * 60, cen - ri2 * lev)
--                 ph:ApplyForceOffset(-up * -ang.r * 60, cen + ri2 * lev)
--             end
--         end


--         local function reduce_movement()
--             if math.abs(ang.p) <= 35 and math.abs(ang.r) <= 35 and vel.z > 0 then  -- checks if youre landing upright and 
--                 local newvel_x = vel.x
--                 local newvel_y = vel.y

--                 ph:SetVelocityInstantaneous(-up * 10 * phm)
--                 ph:AddVelocity(Vector(newvel_x,newvel_y,0))

--                 local newavel_x = math.Clamp(angv.x * 0.1,-300,300)
--                 local newavel_y = math.Clamp(angv.y * 0.1,-300,300)
--                 local newavel_z = math.Clamp(angv.z * 0.6,-30,30)
--                 -- angv.z = math.Clamp(angv.z * 1,-100,100)
--                 -- newavel_z = angv.z
--                 ph:SetAngleVelocityInstantaneous(Vector(newavel_x,newavel_y,30))
--                 print (newavel_z)
--             end
--         end

--         local pressing_down = IsValid(self.pilot) and TARDIS:IsBindDown(self.pilot,"flight-down")
--         local vertbrakes = self:GetData("vertbrakes")
--         local stopped = (vell < 1)

--         local height = self:OBBMaxs().z - self:OBBMins().z
--         local tr = util.QuickTrace(self:GetPos(), Vector(0,0,-height))

--         if pressing_down and not vertbrakes and not tr.Hit then
--             align_in_flight()
--         end

--         if vertbrakes then
--             if stopped then
--                 self:SetData("vertbrakes", false)
--                 self:CancelTimer("vertbrakes")
--             end
--             reduce_movement()
--             align_in_flight()
--             local sparkposes = {
--                 [1] = Vector(25,25,-5),
--                 [2] = Vector(-25,25,-5),
--                 [3] = Vector(25,-25,-5),
--                 [4] = Vector(-25,-25,-5),
--             }

--             local effect_data = EffectData()
--             effect_data:SetOrigin(self:LocalToWorld(table.Random(sparkposes)))

--             effect_data:SetScale(2)
--             effect_data:SetMagnitude(3)
--             effect_data:SetRadius(0.5)
--             util.Effect("ElectricSpark", effect_data)
--         end
--     end)
-- else
--     ENT:OnMessage("fall_landing_sound", function(self, data, ply)
--         if not TARDIS:GetSetting("sound") then return end
--         if CurTime() - self:GetData("fall_sound_last", 0) < 2 then return end
--         self:SetData("fall_sound_last", CurTime())

--         local snds = self.metadata.Exterior.Sounds

--         if TARDIS:GetSetting("flight-externalsound") then
--             self:EmitSound(snds.FlightLand)
--         end

--         if IsValid(self.interior) and TARDIS:GetSetting("flight-internalsound") then
--             local snds_i = self.metadata.Interior.Sounds
--             self.interior:EmitSound(snds_i.FlightLand or snds.FlightLand)
--         end
--     end)

--     ENT:OnMessage("fall_crashing_sound", function(self, data, ply)
--         if not TARDIS:GetSetting("sound") then return end
--         local snds = self.metadata.Exterior.Sounds

--         if TARDIS:GetSetting("flight-externalsound") then
--             self:EmitSound(snds.FlightFall)
--         end

--         if IsValid(self.interior) and TARDIS:GetSetting("flight-internalsound") then
--             local snds_i = self.metadata.Interior.Sounds
--             self.interior:EmitSound(snds_i.FlightFall or snds.FlightFall)
--         end
--     end)
-- end