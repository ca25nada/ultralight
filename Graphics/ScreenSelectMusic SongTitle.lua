
local t = Def.ActorFrame{
	Font("mentone","24px") .. {
		Name="SongTitle"; -- was Artist
		InitCommand=cmd(y,-8;zoom,0.45;horizalign,left;vertalign,bottom;NoStroke;maxwidth,480);
		SetCommand=function(self)
			local text = "";
			if GAMESTATE:GetCurrentSong() then
				text = GAMESTATE:GetCurrentSong():GetDisplayMainTitle();
			elseif GAMESTATE:GetCurrentCourse() then
				text = ""
			end;
			self:settext( text );
		end;
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
		CurrentCourseChangedMessageCommand=cmd(playcommand,"Set");
		CurrentTrailP1ChangedMessageCommand=cmd(playcommand,"Set");
		CurrentTrailP2ChangedMessageCommand=cmd(playcommand,"Set");
		OffCommand=cmd(bouncebegin,0.35;addy,-SCREEN_CENTER_Y*1.25);
	};
};

return t;