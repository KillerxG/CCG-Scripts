--Elementale Trainment
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsLevel(1) and c:IsSetCard(0x310) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tp=Duel.GetTurnPlayer()
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) and
		Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) then
				Duel.ConfirmCards(1-tp,g)
			local tp=Duel.GetTurnPlayer()
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)		
			if Duel.SendtoHand(g,nil,REASON_EFFECT) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
				Duel.SetTargetPlayer(tp)
				Duel.SetTargetParam(1)
				Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				Duel.Draw(p,d,REASON_EFFECT)
						    e:GetHandler():CancelToGrave()
				Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
		else
		Duel.ConfirmCards(1-tp,g)
	end
end
end
end