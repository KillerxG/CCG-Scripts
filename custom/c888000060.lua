--Oceanic Storm Banshee of Frightening Sea
--Scripted by Imp, Misaki
local s,id=GetID()
function s.initial_effect(c)
    --Always treated as a "Oceanic Storm Banshee" card
    c:AddSetcodesRule(0x312a)
	c:EnableReviveLimit()
	--Fusion Summon
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x312a),1,aux.FilterBoolFunctionEx(Card.IsSetCard,0x312c),1)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
    --(1)Send added card
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
	--(2)Banish card from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_series={0x312,0x312a}
function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
--(1)Send added card
function s.cfilter(c,tp)
    return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,1-tp) and #eg==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=eg:Filter(s.cfilter,nil,1-tp)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and not tc:IsLocation(LOCATION_HAND+LOCATION_DECK) 
        and aux.nvfilter(tc) then
        if (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
        and tc:IsSSetable() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.BreakEffect()
        Duel.SSet(tp,tc)
        end
    end
end
--(2)Banish card from GY
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_SZONE,0,1,e:GetHandler())
	and	Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_SZONE,0,1,2,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local c=e:GetHandler()
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
	local n=ct
    if n>#g then n=#g end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,n,n,e:GetHandler())
        if #sg>0 then Duel.Remove(sg,POS_FACEUP,REASON_EFFECT) end
	end
end