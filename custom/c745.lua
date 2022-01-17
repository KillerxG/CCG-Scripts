--
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)--token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local token=Duel.CreateToken(tp,89631139)
		Duel.SendtoHand(token,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,token)
	end







