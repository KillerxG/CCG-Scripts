--FGO Chaldea Master
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Sort Top
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--(2)Place Counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.pcttg)
	e2:SetOperation(s.pctop)
	c:RegisterEffect(e2)
end
--(1)Sort Top
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x294),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.min(10,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
	if ct~=0 then
		local ac=ct==1 and ct or Duel.AnnounceNumberRange(tp,1,ct)
		Duel.SortDecktop(tp,tp,ct)
	end
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	
end
--(2)Place Counter
function s.pcttg(e,tp,eg,ep,ev,re,r,rp,chk)
  local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
  if chk==0 then return tc and tc:IsFaceup() and tc:IsSetCard(0x294) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
end
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
  if tc and tc:IsFaceup() and tc:IsSetCard(0x294) then
    tc:AddCounter(0x1294,5)
  end
end