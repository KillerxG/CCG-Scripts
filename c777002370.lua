--Girly Force - Ayame
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --(1)Negate and destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
s.listed_names={777002340}
--(1)Negate and destroy
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsExistingMatchingCard(s.house_filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function s.house_filter(c,e,tp)
	return c:IsSetCard(0x293) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),c)>0
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) then
		if re:GetHandler():IsRelateToEffect(re) then
			Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT)
		end
		if not c:IsRelateToEffect(e) then return end
		Duel.BreakEffect()
		Duel.SendtoDeck(c,nil,0,REASON_EFFECT)
		if c:IsLocation(LOCATION_DECK) and Duel.IsExistingMatchingCard(s.house_filter,tp,LOCATION_DECK,0,1,nil,e,tp) then
			local tg=Duel.SelectMatchingCard(tp,s.house_filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if tg then
				Duel.SpecialSummon(tg,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
			end
		end
	end
end