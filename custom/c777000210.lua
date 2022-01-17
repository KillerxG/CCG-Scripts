--Azur Lane - Richelieu
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--XYZ Materials
	Xyz.AddProcedure(c,nil,7,2,nil,nil,nil,nil,false,s.xyzcheck)
	c:EnableReviveLimit()
    --(1)Direct Attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.dacon)
	c:RegisterEffect(e1)
	--(1.2)Damage reduce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(s.rdcon)
	e2:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e2)
	--(2)Limit to DEF
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spdcost)
	e3:SetCondition(s.spcon)
	e3:SetOperation(s.spdop)
	c:RegisterEffect(e3)
	--(3)Disable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.discon)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
--XYZ Materials
function s.xyzfilter(c,xyz,tp)
	return c:IsSetCard(0x298,xyz,SUMMON_TYPE_XYZ,tp)
end
function s.xyzcheck(g,tp,xyz)
	local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
	return mg:IsExists(s.xyzfilter,1,nil,xyz,tp)
end
--(1)Direct Attack
function s.dacon(e)
	return e:GetHandler():GetOverlayCount()>0
end
--(1.2)Damage reduce
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	return Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
--(2)Limit to DEF
function s.spdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function s.spconfilter(c)
  return c:IsFaceup() and c:IsSetCard(0x298) and c:IsType(TYPE_MONSTER)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
  return #g>0 and g:FilterCount(s.spconfilter,nil)==#g and not e:GetHandler():IsReason(REASON_RULE)
end
function s.spdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(POS_FACEUP_DEFENSE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsType(TYPE_LINK)
end
function s.deftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
	Duel.SetChainLimit(aux.FALSE)
end
function s.deffilter(c,e)
	return c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) and c:GetControler()~=e:GetHandler():GetControler()
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=eg:Filter(s.deffilter,nil,e)
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
--(3)Disable
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc,pos=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_POSITION)
	return e:GetHandler():IsAttackPos()
		and re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE and (pos&POS_DEFENSE)~=0
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end