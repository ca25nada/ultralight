
local scorestatheld = false
local t = Def.ActorFrame{
	Def.Actor{
		Name="scorestat";
		CodeMessageCommand=function(self,params)
			if params.Name == "ScoreStat" then
				scorestatheld = true
			end;
			if params.Name == "ScoreStatOff" then
				scorestatheld = false
			end;
		end;
	};
	Font("mentone","24px") .. {
		Name="Above"; -- was Artist
		InitCommand=cmd(y,-8;zoom,0.8;horizalign,left;vertalign,bottom;NoStroke;shadowlength,1;maxwidth,SCREEN_CENTER_X*0.75);
		SetCommand=function(self)
			local text = "";
			if GAMESTATE:GetCurrentSong() then
				text = GAMESTATE:GetCurrentSong():GetDisplayArtist();
			elseif GAMESTATE:GetCurrentCourse() then
				local trail = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber())
				if trail then
					local artists = trail:GetArtists();
					text = join(", ", artists);
				end;
			end;
			self:settext( text );
		end;
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
		CurrentCourseChangedMessageCommand=cmd(playcommand,"Set");
		CurrentTrailP1ChangedMessageCommand=cmd(playcommand,"Set");
		CurrentTrailP2ChangedMessageCommand=cmd(playcommand,"Set");
		CodeMessageCommand=function(self,params)
			self:finishtweening()
			if scorestatheld then
				self:playcommand("Off")
			else
				self:bouncebegin(0.35)
				self:y(-8)
			end;
		end;
		OffCommand=cmd(bouncebegin,0.35;addy,-SCREEN_CENTER_Y*1.25);
	};
	Font("mentone","24px") .. {
		Name="Below"; -- was Genre
		InitCommand=cmd(y,8;zoom,0.8;horizalign,left;vertalign,top;NoStroke;shadowlength,1;maxwidth,SCREEN_CENTER_X*0.75);
		SetCommand=function(self)
			local text = "";
			if GAMESTATE:GetCurrentSong() then
				text = GAMESTATE:GetCurrentSong():GetGenre();
			elseif GAMESTATE:GetCurrentCourse() then
				local numStages = GAMESTATE:GetCurrentCourse():GetEstimatedNumStages();
				if numStages == 1 then
					text = string.format(ScreenString("%i stage"),numStages)
				else
					text = string.format(ScreenString("%i stages"),numStages)
				end;
			end;
			self:settext( text );
		end;
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
		CurrentCourseChangedMessageCommand=cmd(playcommand,"Set");
		CodeMessageCommand=function(self,params)
			self:finishtweening()
			if scorestatheld then
				self:playcommand("Off")
			else
				self:bouncebegin(0.35)
				self:y(8)
			end;
		end;
		OffCommand=cmd(bouncebegin,0.35;addy,SCREEN_CENTER_Y*1.25);
	};
};

return t;