--Silver Fangs Oracle
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	Card.SetUniqueOnField(c,1,0,id,LOCATION_SZONE)
	--(1)Activation Condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetValue(s.zones)
	c:RegisterEffect(e1)
	--(2)ATK Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.adval)
	c:RegisterEffect(e2)
	--(3)Indestructable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--(4)Gain LP
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.lpcon)
	e3:SetTarget(s.lptg)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)
end
--(1)Activation Condition
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetLinkedZone(tp)>>8) & 0xff
end
--(2)ATK Up
function s.atkcon(e)
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	local a=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	if a:IsControler(1-tp) then a=Duel.GetAttackTarget() end
	local lg=e:GetHandler():GetLinkedGroup()
	return a and lg:IsContains(a)
end
function s.atktg(e,c)
	local lg=e:GetHandler():GetLinkedGroup()
	return lg:IsContains(c) and c:IsLinkMonster() and c:IsSetCard(0x307) and (c==Duel.GetAttacker() or c==Duel.GetAttackTarget())
end
function s.adval(e,c)
	return c:GetAttack()
end
--(3)Indestructable
function s.indtg(e,c)
	return c:IsSetCard(0x307) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
--(4)Gain LP
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
  local ec=eg:GetFirst()
  local bc=ec:GetBattleTarget()
  return ec:IsControler(tp) and ec:IsSetCard(0x307) and bc 
  and bc:IsType(TYPE_MONSTER) and ec:IsStatus(STATUS_OPPO_BATTLE)
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end