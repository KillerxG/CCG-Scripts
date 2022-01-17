--Festos Tools - Comunication Pet
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0x311))
    --to hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.con)
    e1:SetOperation(s.op)
	e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)
	--(2)Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.cost)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.sptarget)
	e2:SetOperation(s.spactivate)
	e2:SetCountLimit(1,id+1)
	c:RegisterEffect(e2)
end
--to hand
function s.con(e)
	return e:GetHandler():GetEquipTarget():IsType(TYPE_NORMAL)
end
function s.filter(c)
    return c:IsSetCard(0x311b)
end
function s.filter2(c)
    return c:IsSetCard(0x311)
end
function s.op(e,tp,eg,ep,ev,re,r,rp,chk)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<6 then return end
    local g=Duel.GetDecktopGroup(tp,6)
    Duel.ConfirmCards(tp,g)
    if g:IsExists(s.filter,1,nil) and g:IsExists(s.filter2,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:FilterSelect(tp,s.filter,1,1,nil)
	 local sg2=g:FilterSelect(tp,s.filter2,1,1,nil)
        Duel.DisableShuffleCheck()
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
		 Duel.SendtoHand(sg2,nil,REASON_EFFECT)
		        Duel.ConfirmCards(1-tp,sg2)
        Duel.ShuffleHand(tp)
        Duel.ShuffleDeck(tp,tp)
    else Duel.ShuffleDeck(tp,tp) end
end
--sp summon
function s.con2(e)
	return e:GetHandler():GetEquipTarget():IsType(TYPE_EFFECT)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x311,2,REASON_COST) end
	local g=e:GetHandler():GetEquipTarget()
	Duel.RemoveCounter(tp,1,0,0x311,2,REASON_COST)
	Duel.Destroy(g,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x311) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.eqfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsSetCard(0x311b)
end
function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) and 
		Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spactivate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
	local tc=g:GetFirst()
	        local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tc,tp)
        if #g>0 then
            Duel.Equip(tp,g:GetFirst(),tc)
	end
end
end