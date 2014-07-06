local t = Def.ActorFrame{
	Font("mentone","24px") .. {
		Name="Genre";
		InitCommand=cmd(x,-SCREEN_CENTER_X+8;y,405;halign,0;zoom,0.45;NoStroke;shadowlength,1;maxwidth,784);
		OnCommand=cmd(playcommand,"Set");
		SetCommand=function(self)
			local text = "";
			if GAMESTATE:IsCourseMode() then
				-- current song [course] (cur#/#songs)
				if GAMESTATE:GetCurrentCourse() then
					-- xxx: have to deal with endless
					local songIdx = GAMESTATE:GetCourseSongIndex();
					local curSong = GAMESTATE:GetCurrentCourse():GetCourseEntry(songIdx):GetSong();
					if curSong then
						text = string.format(
							ScreenString("%s [%s] (Song %i-%i)"),
							curSong:GetDisplayFullTitle(),
							GAMESTATE:GetCurrentCourse():GetDisplayFullTitle(),
							songIdx+1,
							GAMESTATE:GetCurrentCourse():GetEstimatedNumStages()
						);
					else
						text = string.format(
							ScreenString("%s (Song %i-%i)"),
							GAMESTATE:GetCurrentCourse():GetDisplayFullTitle(),
							songIdx+1,
							GAMESTATE:GetCurrentCourse():GetEstimatedNumStages()
						);
					end;
				end;
			else
				if GAMESTATE:GetCurrentSong() then
					text = string.format(
						"%s - %s",
						GAMESTATE:GetCurrentSong():GetDisplayMainTitle(),
						GAMESTATE:GetCurrentSong():GetDisplayArtist()
					);
				end;
			end;
			self:settext( text );
		end;
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
	};
	Font("mentone","24px") .. {
		Name="Genre";
		InitCommand=cmd(x,-SCREEN_CENTER_X+10;y,416;halign,0;zoom,0.4;NoStroke;shadowlength,1;maxwidth,784);
		OnCommand=cmd(playcommand,"Set");
		SetCommand=function(self)
			local text = "";
			if GAMESTATE:IsCourseMode() then
				-- current song [course] (cur#/#songs)
				if GAMESTATE:GetCurrentCourse() then
					-- xxx: have to deal with endless
					local songIdx = GAMESTATE:GetCourseSongIndex();
					local curSong = GAMESTATE:GetCurrentCourse():GetCourseEntry(songIdx):GetSong();
					if curSong then
						text = string.format(
							ScreenString("%s [%s] (Song %i/%i)"),
							curSong:GetDisplayFullTitle(),
							GAMESTATE:GetCurrentCourse():GetDisplayFullTitle(),
							songIdx+1,
							GAMESTATE:GetCurrentCourse():GetEstimatedNumStages()
						);
					else
						text = string.format(
							ScreenString("%s (Song %i/%i)"),
							GAMESTATE:GetCurrentCourse():GetDisplayFullTitle(),
							songIdx+1,
							GAMESTATE:GetCurrentCourse():GetEstimatedNumStages()
						);
					end;
				end;
			else
				if GAMESTATE:GetCurrentSong() then
					text = string.format(
						"%s",
						GAMESTATE:GetCurrentSong():GetDisplaySubTitle()
						--GAMESTATE:GetCurrentSong():GetDisplayArtist()
					);
				end;
			end;
			self:settext( text );
		end;
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
	};
};

return t;