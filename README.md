# Map Logic Controller - Lua Inputs/Outputs

**Map Logic Controller** (short `MapLogic`) allows you to setup the Inputs/Outputs logic on map from Lua.
If you don't understand what I'm talking about, please refer to the official documentation [Valve Developer Wiki](https://developer.valvesoftware.com/wiki/Inputs_and_Outputs).

The controller is a server-side *point* entity, which makes it possible to create outputs in Lua scripts for map entities.
Thanks to this, you can easily configure the complex logic of mechanisms, elevators, doors, combination locks, trains - everything that in **Hammer** turns into a living hell of dozens of logic entities, millions of outputs, and is often an impossible task.

# Use cases

In general, with this addon, you can easily create logical things that are too cumbersome in **Hammer**. Elevator from *func_tracktrain* for 5 floors? Easy! As usual, create an elevator, its path from *path_track*, 5 buttons in the elevator and each on the floor. Give them all a name, you don't need anything else in **Hammer**. Now just get these entities in the code, and write all logic in Lua - add the necessary outputs and call the inputs via `Entity:Fire` to open the doors and start/stop the elevator. You don't even need to setup the sounds in **Hammer**, because they can be played directly from Lua!

For an RP maps, you can, for example, add buttons for certain jobs. You can setup the logic for different gamemodes, events, weathers or seasons, and switch them using `map_logic_override`. In theory you can change or fix the logic on all current maps if you rename all the necessary entities. However, this will not work on outputs with **targetname** `!activator`, `!caller`, `!self`, `!player`. **Unfortunately, there is no way to delete an already added output from the entity. Alternatively, you can mute them all via `GM:AcceptInput`.**

For **gamemode** specific maps, you can do things like repairing mechanisms, interactive start of the generator in zombie-modes, electronic electronic combination locks. You can, for example, give the opportunity to break the elevator, and then fix it, or disable certain floors. All this is impossible in **Hammer**, but in your scripts you can control it as you like, any bug can always be fixed.

For a coop-maps or a story-maps, you can setup the NPC spawn logic, control waves of enemies and the spawn of bosses. Launch complex scenes and script events by triggers and buttons, give players ammunition and weapons without ugly manipulations with **Hammer** entities! You can easily use all advantages of Lua, create timers, logical if else, switch-case, mathematical operations, calculating integrals, getting computer time... The possibilities of using this addon are limited only by your imagination.

# Security recommendations

It is important to understand that I am not responsible for the scripts that people make for their maps. This entity **is not** an alternative to `lua_run`, it **does't run code** and is not created from **Hammer**. This entity is designed to give easy control over the map logic from Lua scripts, but everything that the author of the script will write lies on his conscience.

On Lua you can do anything, starting from simple prank, ending with major security things. Do not try to create secret buttons that give some goods or admin-access to player. This is similar to what if you used `lua_run` for fun, don't do that! **Please note that it is bad form to check access to secret rooms by SteamID. Please do not kick or ban players on your maps, this is a very bad thing.**

# For players and server owners

The controller is created at the map start, the logic is provided by developer through their scripts, which are not embed into the map file.

* Console command `map_logic_reset` - Removes the old controller and creates a new one. Forces the entire map logic to be initialized again. Please don't use this too many times.

* Console variable `map_logic_override ""` - Overrides map name for which the controller will initialize the logic. This way, you can make several presets for one map. The value of the variable is not saved, so you need to set it when the server starts in `autoexec.cfg` or `server.cfg`.

# For developers

Technically **map_logic_controller** recognizes inputs and calls the binded Lua functions.
These inputs are a callback from the outputs added using **AddOutput**.
Outputs are added in the code via the **MetaTarget** object in the `OnMapLogicInitialized` hook.
You should refer to my [wiki](https://github.com/TIMONz1535/map_logic_controller/wiki) to view the full documentation with samples.

---

© 2021 [TIMON_Z1535](https://steamcommunity.com/profiles/76561198047725014)

Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=2609701688

Wiki: https://github.com/TIMONz1535/map_logic_controller/wiki
