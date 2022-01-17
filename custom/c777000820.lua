--Draconic Return
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	--(2)Destroy Replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
--(1)Special Summon
function s.spfilter1(c,e,tp,check)
	return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and (check==0 or Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_EXTRA,0,1,c,e,tp))
end
function s.banfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and (c:IsAbleToRemoveAsCost() or c:IsAbleToRemove()) 
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,0)
	local b=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,1)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (a or b) end
	if b and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_EXTRA,0,1,nil) ---- banish
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_EXTRA,0,1,1,nil) ---- banish
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,e:GetLabel()+1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and e:GetLabel()~=1 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or e:GetLabel()~=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g2>0 then
			Duel.BreakEffect() 
			Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
		end
	end
end
--(2)Destroy Replace
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x300) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) 
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
