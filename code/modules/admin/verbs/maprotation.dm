/client/proc/forcerandomrotate()
	set category = "Server"
	set name = "Trigger Random Map Rotation"
	ticker.maprotatechecked = 1
	maprotate()

/client/proc/adminchangemap()
	set category = "Server"
	set name = "Change Map"
	var/list/maprotatechoices = list()
	for (var/map in config.maplist)
		var/datum/votablemap/VM = config.maplist[map]
		var/mapname = VM.friendlyname
		if (VM == config.defaultmap)
			mapname += " (Default)"

		if (VM.minusers > 0 || VM.maxusers > 0)
			mapname += " \["
			if (VM.minusers > 0)
				mapname += "[VM.minusers]"
			else
				mapname += "0"
			mapname += "-"
			if (VM.maxusers > 0)
				mapname += "[VM.maxusers]"
			else
				mapname += "inf"
			mapname += "\]"

		maprotatechoices[mapname] = VM
	var/choosenmap = input("Choose a map to change to", "Change Map")  as null|anything in maprotatechoices
	if (!choosenmap)
		return
	ticker.maprotatechecked = 1
	var/datum/votablemap/VM = maprotatechoices[choosenmap]
	message_admins("[key_name_admin(usr)] is changing the map to [VM.name]([VM.friendlyname])")
	log_admin("[key_name(usr)] is changing the map to [VM.name]([VM.friendlyname])")
	if (changemap(VM) == 0)
		message_admins("[key_name_admin(usr)] has changed the map to [VM.name]([VM.friendlyname])")