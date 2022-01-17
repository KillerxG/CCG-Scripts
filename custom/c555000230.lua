--Intelestar Schrodinger - Drums
--Scripted by Hellboy
local s,id=GetID()
function s.initial_effect(c)
--Link Material
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--If banished from GY
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcondition)
	e2:SetTarget(s.sptarget)
	e2:SetOperation(s.spoperation)
	c:RegisterEffect(e2)
end
--Link Material
function s.matfilter(c,scard,sumtype,tp)
	return (c:IsSetCard(0x5557) and not c:IsType(TYPE_LINK))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
	 e:SetLabel(g:GetFirst():GetCode())
end
--spsummon
function s.filter(c)
	return c:IsAbleToRemove() and c:IsSetCard(0x5557) and c:IsLocation(LOCATION_GRAVE)
end
function s.filter1(c,e,tp)
	return c:IsSetCard(0x5557) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
        local tc=e:GetLabel()
		local b1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_HAND,0,nil,e,tp)
		local b2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,e,tp)
		if not (tc == 555000170) and #b1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local t1=b1:GetFirst()
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local t1=b1:Select(tp,1,1,nil)
		Duel.SpecialSummon(t1,0,tp,tp,false,false,POS_FACEUP)
    end
    if (tc == 555000170) and #b2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local t2=b2:Select(tp,1,1,nil)
		Duel.HintSelection(t2)
		Duel.SpecialSummon(t2,0,tp,tp,false,false,POS_FACEUP)
     end
end
--If banished from GY
function s.spcondition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE) and (e:GetHandler():IsReason(REASON_EFFECT) 
		or (e:GetHandler():IsReason(REASON_COST) and re:IsHasType(~EFFECT_TYPE_FIELD)))
end
function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.spoperation(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
Duel.SendtoHand(c,nil,REASON_EFFECT)
end