--Singtress of Elementale - Zel
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	--(0) shuffle
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCountLimit(1,id)
	e0:SetCondition(s.condition)
	e0:SetCost(s.cost)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	--(1)Search for lv 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,id+1)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--(2)activate limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+2)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.aclimit)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
	--(3)Ritual Summon Limit
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	--(4)Special Summon condition
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetValue(s.spconlimit)
	c:RegisterEffect(e4)
end
s.listed_names={777000850}
--Ritual Material Limit
function s.mat_filter(c)
	return c:IsLocation(LOCATION_PUBLIC+LOCATION_HAND) or (c:IsCode(id) and c:IsLocation(LOCATION_DECK))
end
-- (0) shuffle hands
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,4,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return
	 Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
				local g2=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #g==0 then return end
		if #g2==0 then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	Duel.ShuffleDeck(1-tp)
	Duel.SendtoDeck(g2,nil,SEQ_DECKSHUFFLE,REASON_COST)
	Duel.ShuffleDeck(tp)
end
function s.filter1(c,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsFaceup() and Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,lv)
end
function s.filter2(c,lv)
	return c:IsLevel(lv) and c:IsAbleToRemove() and aux.SpElimFilter(c,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if Duel.Draw(tp,1,REASON_EFFECT) then
	local dr=Duel.GetOperatedGroup():GetFirst()
	Duel.ConfirmCards(1-tp,dr)
	Duel.BreakEffect()
		if dr:IsSetCard(0x310) and dr:IsType(TYPE_MONSTER) then
			--Effect Draw
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DRAW_COUNT)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetValue(2)
	e:GetHandler():RegisterEffect(e3,tp)
	Duel.ShuffleHand(tp) 
	else 
		local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_SKIP_DP)
	e4:SetTargetRange(1,0)
		e4:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,3)
			Duel.RegisterEffect(e4,tp)
end
end
end
--(1)Search 1 lvl 1
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.thfilter1(c)
	return c:IsSetCard(0x310) and c:IsLevel(1) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--negate

function s.spconfilter(c)
  return c:IsFaceup() and c:IsSetCard(0x310) and c:IsType(TYPE_MONSTER)
end
function s.actcon(e)
	local tp=Duel.GetTurnPlayer() 
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return tp==e:GetHandlerPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
		and #g>0 and g:FilterCount(s.spconfilter,nil)==#g and not e:GetHandler():IsReason(REASON_RULE)
end
function s.aclimit(e,re,tp)
	return (re:GetHandler():IsType(TYPE_TRAP) or re:GetHandler():IsType(TYPE_SPELL) or re:GetHandler():IsType(TYPE_MONSTER))
end
--(3)Ritual Summon Limit
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_RITUAL==SUMMON_TYPE_RITUAL
end
--(4)Special Summon condition
function s.spconlimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS) and (se:GetHandler():IsSetCard(0x313) or se:GetHandler():IsSetCard(0x310))
end