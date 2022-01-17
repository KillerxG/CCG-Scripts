--Rockslash Deadlands
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Double damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.ddop)
	c:RegisterEffect(e1)
	--(2)Set itself from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
--(1)Double damage
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_CHANGE_DAMAGE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetTargetRange(0,1)
  e1:SetCondition(s.ddcon)
  e1:SetValue(s.ddval)
  e1:SetReset(RESET_PHASE+PHASE_END,1)
  Duel.RegisterEffect(e1,tp)
end
function s.ddcon(e,tp,eg,ep,ev,re,r,rp)
  return rp==tp
end
function s.ddval(e,re,dam,r,rp,rc)
  if bit.band(r,REASON_EFFECT)~=0 and re:GetHandler():IsSetCard(0x309) then
    return dam*2
  else 
    return dam 
  end
end
--(2)Set itself from GY
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and (r&REASON_BATTLE)==0 and re
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end