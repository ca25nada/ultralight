-- Dependencies: Scoretracking.lua

local graphType = tonumber(GetUserPref("GraphTypeP1")); -- 1 = off, 2 = DP, 3 = PS, 4 = MIGS
local avgScoreType = tonumber(GetUserPref("AvgScoreTypeP1"));-- 1 = DP, 2 = PS, 3 = MIGS
local target = (tonumber(GetUserPref("GraphTargetP1"))+1)/100; -- target score from 0% to 100%.
local cols = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer(); -- For relocating graph/judgecount frame
local center1P = ((cols >= 6) or PREFSMAN:GetPreference("Center1Player"));

local t = Def.ActorFrame{}

local frameXP1 = SCREEN_CENTER_X+50
local frameYP1 = SCREEN_CENTER_Y+25
local frameYRP1 = (SCREEN_CENTER_X*0.57)+52

local frameXP2 = SCREEN_CENTER_X+50
local frameYP2 = SCREEN_CENTER_Y+2
local frameYRP2 = (SCREEN_CENTER_X*0.57)+52

if center1P == false then
	frameXP1 = (SCREEN_CENTER_X*0.57)+52
	frameXP2 = SCREEN_CENTER_X+(SCREEN_CENTER_X*0.57)+52
end


function ghostScore(pn)
	local frameX = SCREEN_CENTER_X
	local frameY = SCREEN_CENTER_Y
	if pn == PLAYER_1 then
		frameX = frameXP1
		frameY = frameYP1
		if GAMESTATE:GetPlayerState(pn):GetCurrentPlayerOptions():UsingReverse() == true then
			frameY = frameYR1P
		end
	elseif pn == PLAYER_2 then
		frameX = frameXP1
		frameY = frameYP1
		if GAMESTATE:GetPlayerState(pn):GetCurrentPlayerOptions():UsingReverse() == true then
			frameY = frameYR2P
		end
	end
	local t = LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,frameX+2,frameY;zoom,0.45;diffuse,color("#ff9999");horizalign,left);
		BeginCommand=function(self)
			self:settext('+0')
			self:visible(false)
		end;
		SetCommand=function(self,params)
			if STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetCurrentCombo() > 1 then
				self:visible(true);
			else
				self:visible(false);
			end;
			local targetDiff = 0
			if graphType == 2 then
				targetDiff = getCurScore(pn,0)-(math.ceil(getCurMaxScore(pn,0)*target))
			elseif graphType == 3 then
				targetDiff = getCurScore(pn,1)-(math.ceil(getCurMaxScore(pn,1)*target))
			elseif graphType == 4 then
				targetDiff = getCurScore(pn,2)-(math.ceil(getCurMaxScore(pn,2)*target))
			end;
			if targetDiff > 0 then
				self:settext('+'..targetDiff)
				self:diffuse(color("#66ccff"))
			elseif targetDiff == 0 then
				self:settext('+'..targetDiff)
				self:diffuse(color("#FFFFFF"))
			else
				self:settext('-'..(math.abs(targetDiff)))
				self:diffuse(color("#FF9999"))
			end;
		end;
		JudgmentMessageCommand=function(self,params)
			self:queuecommand("Set");
		end;
	};
	return t
end;

function avgScore(pn)
	local frameX = 0
	local frameY = 0
	if pn == PLAYER_1 then
		frameX = frameXP1
		frameY = frameYP1
		if GAMESTATE:GetPlayerState(pn):GetCurrentPlayerOptions():UsingReverse() == true then
			frameY = frameYR1P
		end
	elseif pn == PLAYER_2 then
		frameX = frameXP1
		frameY = frameYP1
		if GAMESTATE:GetPlayerState(pn):GetCurrentPlayerOptions():UsingReverse() == true then
			frameY = frameYR2P
		end
	end
	local t = LoadFont("Common Normal") .. { -- Current/Average Percentage Score
		InitCommand=cmd(xy,frameX,frameY;zoom,0.45;diffuse,color("#ffffff");horizalign,right);
		BeginCommand=function(self)
			self:settext('0.00%')
			self:visible(false)
		end;
		SetCommand=function(self,params)
			if STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetCurrentCombo() > 1 then
				self:visible(true);
			else
				self:visible(false);
			end;
			if avgScoreType == 1 then
				if getCurMaxScore(pn,0) ~= 0 then
					self:settextf("%.2f%%",(math.floor(getCurScore(pn,0)/getCurMaxScore(pn,0)*10000))/100); 
				else
					self:settext('0.00%')
				end;
			elseif avgScoreType == 2 then
				if getCurMaxScore(pn,1) ~= 0 then
					self:settextf("%.2f%%",(math.floor(getCurScore(pn,1)/getCurMaxScore(pn,1)*10000))/100); 
				else
					self:settext('0.00%')
				end;
			elseif avgScoreType == 3 then
				if getCurMaxScore(pn,2) ~= 0 then
					self:settextf("%.2f%%",(math.floor(getCurScore(pn,2)/getCurMaxScore(pn,2)*10000))/100); 
				else
					self:settext('0.00%')
				end;
			end;
		end;
		JudgmentMessageCommand=function(self)
			self:queuecommand("Set");
		end;
	};
	return t
end;

t[#t+1] = ghostScore(PLAYER_1)
t[#t+1] = avgScore(PLAYER_1)

return t