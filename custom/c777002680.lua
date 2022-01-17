--Genshin Impact - Yoimiya
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),5,2,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--(1)Destroy hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_DRAW_PHASE)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.attg)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
end
--Xyz Summon
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_XYZ) and c:IsSetCard(0x291,lc,SUMMON_TYPE_XYZ,tp)
end
--(1)Destroy hand
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	if e:GetLabel()==1 then
		e:SetLabel(0)		
	end
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g==0 then return end
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local hg=g:Select(tp,1,1,nil)
	Duel.SendtoGrave(hg,REASON_EFFECT+REASON_DISCARD)
	Duel.ShuffleHand(1-tp)
	local tc=hg:GetFirst()
	if tc:IsType(TYPE_MONSTER) then
		Duel.Damage(1-tp,tc:GetLevel()*300,REASON_EFFECT)
	end	
end
