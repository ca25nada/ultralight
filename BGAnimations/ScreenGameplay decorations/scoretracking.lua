
local t = Def.ActorFrame{}

t[#t+1] = Def.Actor{ -- ScoreCalc
	SetCommand=function(self)
		if isFailing(PLAYER_1) == false then
			dpscore = getCurScore(PLAYER_1,0)
			percentscore = getCurScore(PLAYER_1,1)
			migsscore = getCurScore(PLAYER_1,2)
		end;
		curmaxdp = getCurMaxScore(PLAYER_1,0)
		curmaxps = getCurMaxScore(PLAYER_1,1)
		curmaxmigs = getCurMaxScore(PLAYER_1,2)
		dppercent = string.format("%.2f",dpscore/curmaxdp)
		pspercent = string.format("%.2f",percentscore/curmaxps)
		migspercent = string.format("%.2f",migsscore/curmaxmigs)
		
	end;
	JudgmentMessageCommand=function(self,params)
		if params.HoldNoteScore then
			addJudge(PLAYER_1,params.HoldNoteScore,true)
			judgetable = getJudgeTable(PLAYER_1)
		elseif params.TapNoteScore == 'TapNoteScore_HitMine' or params.TapNoteScore == 'TapNoteScore_AvoidMine' then
			addJudge(PLAYER_1,params.TapNoteScore,false)
			totmines = getCurMaxMines(PLAYER_1)
			judgetable = getJudgeTable(PLAYER_1)
		else
			addJudge(PLAYER_1,params.TapNoteScore,false)
			totnotes = getCurMaxNotes(PLAYER_1)
			judgetable = getJudgeTable(PLAYER_1)
			if params.TapNoteScore ~= 'TapNoteScore_Miss' then
				if not params.Early then
					addOffset(PLAYER_1,params.TapNoteOffset)
					protimingtable = getOffsetTable(PLAYER_1)
					protimingsum = protimingsum - params.TapNoteOffset
				else
					addOffset(PLAYER_1,-params.TapNoteOffset)
					protimingtable = getOffsetTable(PLAYER_1)
					protimingsum = protimingsum + params.TapNoteOffset
				end;
			end;
		end;
		self:queuecommand("Set");
	end;
};

return t