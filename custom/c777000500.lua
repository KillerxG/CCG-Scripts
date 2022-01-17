--HI3rd Herrscher of Flamescion
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--Fusion Materials
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,777000010,1,aux.FilterBoolFunctionEx(Card.IsSetCard,0x299),2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
    --(1)Send monster to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--(2)Act Limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
	--(3)Damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
s.listed_names={777000010}
--Fusion Materials
function s.contactfil(tp)
	return Duel.GetMatchingGroup(function(c) return c:IsAbleToDeckOrExtraAsCost() end,tp,LOCATION_GRAVE,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
 --(1)Send monster to the GY
 function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=Duel.GetAttackTarget()
	if chk ==0 then return Duel.GetAttacker()==e:GetHandler() and d end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,d,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Damage(1-tp,1000,REASON_EFFECT)~=0 then
		local d=Duel.GetAttackTarget()
		if d:IsRelateToBattle() then
			Duel.SendtoGrave(d,REASON_EFFECT)
		end
	end
end
--(2)Act Limit
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
--(3)Damage
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x299b)
end
function s.fil2ter(c)
	return c:IsFaceup() and c:IsSetCard(0x299f)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local c1=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,nil)
	if c1<4 then
		Duel.Damage(tp,2000-c1*500,REASON_EFFECT)
	end
	local c2=Duel.GetMatchingGroupCount(s.fil2ter,1-tp,LOCATION_MZONE,0,nil)
	if c2<4 then
		Duel.Damage(1-tp,2000-c2*500,REASON_EFFECT)
	end
end