--Silver Fangs Valky Support
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --(1)Change all monsters to Attack Position
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_POSITION)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.poscon)
	e2:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e2)
	--(2)Change Battle Target
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)	
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.cbcon)
	e3:SetTarget(s.cbtg)
	e3:SetOperation(s.cbop)
	c:RegisterEffect(e3)
end
--(1)Change all monsters to Attack Position
function s.poscon(e)
	return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer() and Duel.IsBattlePhase()
end
--(2)Change Battle Target
function s.cbcon(e,tp,eg,ep,ev,re,r,rp)
	local bt=Duel.GetAttackTarget()
	return bt and bt:IsLocation(LOCATION_MZONE) and bt:IsPosition(POS_FACEUP_ATTACK) and bt:IsControler(tp) and bt:IsSetCard(0x307)
end
function s.cbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.GetAttacker():IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK) end
end
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	local bt=Duel.GetAttackTarget()
	if not (bt:IsRelateToBattle() and bt:IsControler(tp)) then return end
	if at:CanAttack() and not at:IsStatus(STATUS_ATTACK_CANCELED) and Duel.Recover(tp,bt:GetAttack(),REASON_EFFECT)>0 then
		Duel.ChangeAttackTarget(nil)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	bt:RegisterEffect(e1)
end