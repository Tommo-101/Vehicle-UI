_menuPool = NativeUI.CreatePool()

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

function has_hash_value (tab, val)
    for index, value in ipairs(tab) do
		if GetHashKey(value) == val then
			return true
        end
    end
    return false
end

cardoors = {}
for k, v in pairs (Config.doors) do 
    cardoors[k] = v
end

carwindows = {}
for k, v in pairs (Config.windows) do 
    carwindows[k] = v
end

---- Creating Menus
function LiveryMenu(vehicle, menu)
	local liveryMenu = _menuPool:AddSubMenu(menu, "Livery", "Edit vehicle liveries", true, true, true)
	local livery_count = GetVehicleLiveryCount(vehicle)
	local livery_list = {}
	local fetched_liveries = false
	
	for liveryID = 1, livery_count do
		livery_list[liveryID] = liveryID
		fetched_liveries = true
    end
	
	local liveryItem = NativeUI.CreateListItem("Livery", livery_list, GetVehicleLivery(vehicle))
    liveryMenu:AddItem(liveryItem)
    
	liveryMenu.OnListChange = function(sender, item, index)
        if item == liveryItem then
			SetVehicleLivery(vehicle,item:IndexToItem(index))
        end
    end
end

function ExtrasMenu(vehicle, menu)
	local extrasMenu = _menuPool:AddSubMenu(menu, "Extras", "Edit vehicle extras", true, true)
    
	local veh_extras = {['vehicleExtras'] = {}}
    local items = {['vehicle'] = {}}
    local fetched_extras = false
    
	for extraID = 0, 20 do
        if DoesExtraExist(vehicle, extraID) then
            veh_extras.vehicleExtras[extraID] = (IsVehicleExtraTurnedOn(vehicle, extraID) == 1)
            fetched_extras = true
        end
    end

    if fetched_extras then
		for k, v in pairs(veh_extras.vehicleExtras) do
			local extraItem = NativeUI.CreateCheckboxItem('Extra ' .. k, veh_extras.vehicleExtras[k],"Toggle for Extra "..k)
			extrasMenu:AddItem(extraItem)
			items.vehicle[k] = extraItem
		end
		
		extrasMenu.OnCheckboxChange = function(sender, item, checked)
			for k, v in pairs(items.vehicle) do
				if item == v then
					veh_extras.vehicleExtras[k] = checked
					if veh_extras.vehicleExtras[k] then
						SetVehicleExtra(vehicle, k, 0)
					else
						SetVehicleExtra(vehicle, k, 1)
					end
				end
			end
		end
    end
    
end

function AddLocksEngineMenu(vehicle, menu)
	local lockMenu = NativeUI.CreateItem("Toggle Locks", "Lock/Unlock vehicle")
	local engineMenu = NativeUI.CreateItem("Toggle Engine", "Start/Stop engine")
	menu:AddItem(lockMenu)
	menu:AddItem(engineMenu)

	menu.OnListChange = function(sender, item, index)
        print("Beep Beep.")
    end
	
	menu.OnItemSelect = function(sender, item, index)
		if item == lockMenu then
            print("Lock status:")
            print(GetVehicleDoorLockStatus(vehicle))
			if GetVehicleDoorLockStatus(vehicle) == 1 or GetVehicleDoorLockStatus(vehicle) == 0 then
				SetVehicleDoorsLocked(vehicle,4)
				ShowNotification("Locking Doors")
			else
				SetVehicleDoorsLocked(vehicle,1)
				ShowNotification("Unlocking Doors")
			end
        end
		if item == engineMenu then
            print("engine running?:")
			print(GetIsVehicleEngineRunning(vehicle))
			if GetIsVehicleEngineRunning(vehicle) then
				SetVehicleEngineOn(vehicle,false,false,true)
			else
				SetVehicleEngineOn(vehicle,true,false,true)
			end
        end
    end  
end

function AddDoorsMenu(vehicle, menu)
	local doorMenu = _menuPool:AddSubMenu(menu, "Doors", "Open/Close doors", true, true)

	for k, v in pairs(cardoors) do
		newIndex = k - 1
		if DoesVehicleHaveDoor(vehicle, newIndex) then 
			--print(newIndex.. ":"..k)
			local doorItem = NativeUI.CreateItem("Toggle "..v,"Toggle for "..v)
			doorMenu:AddItem(doorItem)
		end
	end

	doorMenu.OnItemSelect = function(sender, item, index)
		newIndex = index - 1
		if DoesVehicleHaveDoor(vehicle, newIndex) then 
			local isopen = GetVehicleDoorAngleRatio(vehicle,newIndex)
			if isopen == 0 then
				SetVehicleDoorOpen(vehicle,newIndex,0,0)
				ShowNotification("Opening "..Config.doors[index].." Door")
			else
				SetVehicleDoorShut(vehicle,newIndex,0)
				ShowNotification("Shutting "..Config.doors[index].." Door")
			end
		end
    end
end

function AddWindowsMenu(vehicle, menu)
	local windowMenu = _menuPool:AddSubMenu(menu, "Windows", "Open/Close windows", true, true)

	for k, v in pairs(carwindows) do
		local windowItem = NativeUI.CreateItem("Toggle "..v.." Window","")
		windowMenu:AddItem(windowItem)
	end

	windowMenu.OnItemSelect = function(sender, item, index)
		newIndex = index - 1
		local isopen = IsVehicleWindowIntact(vehicle,newIndex)
		if isopen then
			RollDownWindow(vehicle,newIndex,0,0)
			ShowNotification("Opening "..Config.windows[index].." Window")
		else
			RollUpWindow(vehicle,newIndex,0)
			ShowNotification("Shutting "..Config.windows[index].." Window")
		end
    end 
end

--[[function ViewHealthMenu(vehicle, menu)
	local healthMenu = _menuPool:AddSubMenu(menu, "Health", "View vehicle health", true, true, true)
	
	--GetVehicleBodyHealth(vehicle)
	--GetVehicleEngineHealth(vehicle)
	--GetVehicleEngineTemperature(vehicle)
	--GetVehicleFuelLevel(vehicle)
	--GetVehicleOilLevel(vehicle)
	--GetVehiclePetrolTankHealth(vehicle)
	--GetVehicleDirtLevel(vehicle)
	
end]]--

function openDynamicMenu(vehicle)
	_menuPool:Remove()
	if vehMenu ~= nil and vehMenu:Visible() then
		vehMenu:Visible(false)
		if itemMenu then
			vehMenu:Visible(false)
		end
		return
	end
	vehMenu = NativeUI.CreateMenu(Config.mTitle, 'Edit your vehicle', 5, 100,Config.mBG[1],Config.mBG[2]) 
	_menuPool:Add(vehMenu)
	LiveryMenu(vehicle, vehMenu)
	ExtrasMenu(vehicle, vehMenu)
	AddDoorsMenu(vehicle, vehMenu)
	AddWindowsMenu(vehicle, vehMenu)
	AddLocksEngineMenu(vehicle, vehMenu)
	--ViewHealthMenu(vehicle, vehMenu)
	
	_menuPool:RefreshIndex()
	_menuPool:MouseControlsEnabled (false);
	_menuPool:MouseEdgeEnabled (false);
	_menuPool:ControlDisablingEnabled(false);
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		_menuPool:ProcessMenus()
		
		local ped = GetPlayerPed(-1)
		local vehicle = GetVehiclePedIsIn(ped, false)
		
		if IsControlJustReleased(1, Config.menuKey) then
			if IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(vehicle, -1) == ped then
				collectgarbage()
				openDynamicMenu(vehicle)
				vehMenu:Visible(not vehMenu:Visible())
			end
        end
		
		if IsPedInAnyVehicle(ped, false) == false then
			if vehMenu ~= nil and vehMenu:Visible() then
				vehMenu:Visible(false)
				if itemMenu then
					vehMenu:Visible(false)
				end
				return
			end
		end
    end
end)