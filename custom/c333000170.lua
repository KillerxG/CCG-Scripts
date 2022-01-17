--Cyberclops Hunter
local s,id=GetID()
function s.initial_effect(c)
aux.EnableGeminiAttribute(c)
	c:EnableCounterPermit(0x311)
	--Xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x311),4,3)
	---xyz alternative
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_TYPE_IGNITION)
	e0:SetCost(s.cost)
	e0:SetTarget(s.sptarget)
	e0:SetOperation(s.spactivate)
	c:RegisterEffect(e0)
	--material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--attach 2
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.scost)
    e2:SetTarget(s.actarget)
    e2:SetOperation(s.op)
    c:RegisterEffect(e2)
	--Change Type
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.atcost)
	e3:SetTarget(s.atttg)
	e3:SetOperation(s.attop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end
--alternative summon
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x311,12,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x311,12,REASON_COST)
end
function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spactivate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local c=e:GetHandler()
		Duel.SpecialSummon(c,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
end
--add material normal summoned
function s.filter2(c)
    return c:IsSetCard(0x311b) and c:IsType(TYPE_SPELL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,6,0,0x311)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
if e:GetHandler():AddCounter(0x311,6) then
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,3,nil)
	if #g>0 then
		Duel.Overlay(e:GetHandler(),g)
        end
    end
	end
-- add material by counter
function s.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x311,1,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x311,1,REASON_COST)
end
function s.acxfilter(c,e,tp)
	return c:IsSetCard(0x311b) and c:IsControler(tp) --and c:IsLocation(LOCATION_GRAVE)
end
function s.actarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return eg:IsContains(chkc) and s.acxfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(s.acxfilter,1,nil,e,tp) end
	local g=eg:FilterSelect(tp,s.acxfilter,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
 local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local sg=g:Filter(Card.IsRelateToEffect,nil,e)
        if #sg>0 then 
            Duel.Overlay(e:GetHandler(),sg)
end
end
--transform in normal
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.norfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x311) and not c:IsType(TYPE_NORMAL)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsSetCard(0x311) end
	if chk==0 then return Duel.IsExistingTarget(s.norfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.norfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.eqfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsType(TYPE_SPELL) and not c:IsForbidden()
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
	--normal monster
		local e4=Effect.CreateEffect(tc)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_ADD_TYPE)
		e4:SetValue(TYPE_NORMAL)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		-- final do registro de evento\/
		if tc:RegisterEffect(e4) 
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and
		Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then 
			        local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tc,tp)
        if #g>0 then
		local tx=g:GetFirst()
            Duel.Equip(tp,tx,tc)
			--return to hand
			local e5=Effect.CreateEffect(tx)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetTarget(s.rettg)
	e5:SetOperation(s.retop)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	tx:RegisterEffect(e5)
	end
end
end
end
--back spell to hand
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
