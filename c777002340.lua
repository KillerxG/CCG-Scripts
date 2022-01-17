--Girly Force - Heaven's Gate
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon
	Ritual.AddProcGreater({handler=c,filter=s.ritualfil,lv=Card.GetDefense,matfilter=s.filter,location=LOCATION_HAND|LOCATION_GRAVE,requirementfunc=Card.GetAttack,desc=aux.Stringid(id,0)})
	--(1)Destroy Replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
end
--Ritual Summon
function s.ritualfil(c)
	return c:GetDefense()>0 and c:IsRitualMonster() and c:IsSetCard(0x293)
end
function s.filter(c)
	return c:GetAttack()>0
end
--(1)Destroy Replace
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsRitualMonster() and c:IsSetCard(0x293)
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end