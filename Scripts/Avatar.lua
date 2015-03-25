--shamelessly copied from customspeedmod
local function ReadAvatarFile(path)
	local file = RageFileUtil.CreateRageFile()
	if not file:Open(path, 1) then
		file:destroy()
		return nil
	end

	local contents = file:Read()
	file:Close()
	file:destroy()

	return contents
end

-- Returns a path to the avatar image (relative to the ultralight theme folder) for the specified player.
function getAvatarPath(pn)
	local profile
	local profilePath = ""
	local fileName = "generic.gif"
	if GAMESTATE:IsPlayerEnabled(pn) then
		profile = GetPlayerOrMachineProfile(pn)
		profilePath = PROFILEMAN:GetProfileDir('ProfileSlot_Player1')
		fileName = ReadAvatarFile(profilePath.."/avatar.txt")
		if fileName == nil then
			fileName = "generic.gif"
		end
	end

	if FILEMAN:DoesFileExist("Themes/"..THEME:GetCurThemeName().."/Graphics/Player avatar/"..fileName) then
		return "/Graphics/Player avatar/"..fileName
	end
	return "/Graphics/Player avatar/generic"
end;

-- Creates an actor with the avatar image.
function getAvatar(pn)
	local profile
	local profilePath = ""
	local fileName = "generic.gif"
	if GAMESTATE:IsPlayerEnabled(pn) then
		profile = GetPlayerOrMachineProfile(pn)
		profilePath = PROFILEMAN:GetProfileDir('ProfileSlot_Player1')
		fileName = ReadAvatarFile(profilePath.."/avatar.txt")
		if fileName == nil then
			fileName = "generic.gif"
		end
	end

	if FILEMAN:DoesFileExist("Themes/"..THEME:GetCurThemeName().."/Graphics/Player avatar/"..fileName) then
		t = LoadActor("../Graphics/Player avatar/"..fileName)..{
			Name="Avatar";
			InitCommand=cmd(visible,true;zoomto,50,50;halign,0;valign,0;);
		};
	else
		t = LoadActor("../Graphics/Player avatar/generic")..{
			Name="Avatar";
			InitCommand=cmd(visible,true;zoomto,50,50;halign,0;valign,0;);
		};
	end

	return t
end;
