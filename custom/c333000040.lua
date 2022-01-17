--Operator of Cyberclops - Festos
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x311)
	--counter
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_COUNTER)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e0:SetCondition(s.condition)
	e0:SetTarget(s.addct)
	e0:SetOperation(s.addc)
	c:RegisterEffect(e0)
	--counter recycle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetTarget(s.actarget)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
    --Activate multiple summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
    e2:SetOperation(s.op)       
    c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--(1)Negate
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCountLimit(1,id+2)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.negcost)
	e4:SetCondition(s.negcon)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
s.listed_names={777000850}
--Ritual Material Limit
function s.mat_filter(c)
	return c:IsLocation(LOCATION_PUBLIC+LOCATION_HAND) or (c:IsCode(id) and c:IsLocation(LOCATION_DECK))
end
--add counter when summoned
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,10,0,0x311)
end
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x311,10)
	end
end
-- add counter when machine monsters
function s.acxfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsControler(tp) --and c:IsLocation(LOCATION_GRAVE)
end
function s.actarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return  eg:IsExists(s.acxfilter,1,nil,e,tp) end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x311,1)
end
-- summon geminis (multiple summon)
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x311,1,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x311,1,REASON_COST)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
    --summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
	Duel.SetChainLimit(aux.FALSE)
end
function s.filter(c)
    return c:IsRace(RACE_MACHINE) and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x311))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.Summon(tp,tc,true,nil)
    end
end
--- special summon and add 
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x311,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x311,2,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filters2(c,e,tp)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_EQUIP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.filters2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
	 local ag=Duel.SelectMatchingCard(tp,s.filters2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	 	if #ag>0 then
		Duel.SendtoHand(ag,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,ag)
		end
	end
end
--(1)Negate
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x311,3,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x311,3,REASON_COST)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
  return re:GetHandler()~=e:GetHandler() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp~=tp
  and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
  local c=e:GetHandler()
	local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_IMMUNE_EFFECT)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.etarget)
    e4:SetValue(s.efilter)
    e4:SetLabel(re:GetHandler():GetOriginalType()&0x7)
    e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e4)
end
end
function s.etarget(e,c)
    return c:IsSetCard(0x311) and c:IsType(TYPE_MONSTER)
end
function s.efilter(e,re)
    return re:GetOwnerPlayer()~=e:GetHandlerPlayer() and re:GetHandler():GetOriginalType()&0x7==e:GetLabel()
end