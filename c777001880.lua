--Warbeast Maiden
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Set 1 "Warbeast" S/T then SS Token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
--(1)Set 1 "Warbeast" S/T then SS Token
function s.thfilter(c)
	return c:IsSetCard(0x308) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sumfilter(c)
	return c:IsPlayerCanSpecialSummon(tp,id+5,0,TYPES_TOKEN,1000,1000,4,RACE_BEASTWARRIOR,ATTRIBUTE_DARK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g,nil,REASON_EFFECT)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+5,0,TYPES_TOKEN+TYPE_TUNER,1000,1000,4,RACE_BEASTWARRIOR,ATTRIBUTE_DARK) 
			and Duel.SelectYesNo(tp,aux.Stringid(id,1))	then
		local token=Duel.CreateToken(tp,id+5)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end



