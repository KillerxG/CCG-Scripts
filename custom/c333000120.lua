--Cyberclops Forge
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--activate from hand
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetCondition(s.handcon)
    c:RegisterEffect(e1)	
    --draw
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.drcost)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)
	--Activate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
    e3:SetCost(s.exscost)
	e3:SetTarget(s.nortarget)
	e3:SetOperation(s.noractivate)
	c:RegisterEffect(e3)
end
--activate from hand
function s.hanfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function s.handcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.hanfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
--draw
function s.drfilter(c)
	return c:IsSetCard(0x311)
end
function s.drfilter2(c)
	return c:IsSetCard(0x311b)
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) and 
	Duel.IsExistingMatchingCard(s.drfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) and 
	Duel.IsCanRemoveCounter(tp,1,0,0x311,2,REASON_COST)	end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.drfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local sg=Duel.SelectMatchingCard(tp,s.drfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.RemoveCounter(tp,1,0,0x311,2,REASON_COST)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end
-- Extra Summon.
function s.exscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x311,5,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x311,5,REASON_COST)
end
function s.nortarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=0
		local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
		for _,te in ipairs(ce) do
			ct=math.max(ct,te:GetValue())
		end
		return ct<3
	end
end
function s.noractivate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(3)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end