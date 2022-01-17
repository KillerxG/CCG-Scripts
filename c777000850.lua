--Idrakian Ritual Force
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Ritual Summon 1
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,0x313),extrafil=s.extragroup,
								extraop=s.extraop,stage2=s.stage2,forcedselection=s.ritcheck})
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
	--(2)Ritual Summon 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
--(1)Ritual Summon 1
function s.matfilter1(c)
	return c:IsAbleToGrave() and c:IsLevelAbove(1) and c:IsSetCard(0x313)
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter1,tp,LOCATION_DECK,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mat:Sub(mat2)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local e0=Effect.CreateEffect(e:GetHandler())
	
	Duel.RegisterEffect(e0,tp)
end

function s.ritcheck(e,tp,g,sc)
	local extrac=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	local gc=#g
	return extrac==0 or extrac==1 and gc==1,extrac>1 or extrac==1 and gc>1
end
--(2)Ritual Summon 2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.spmfilterf(c,tp,mg,rc)
  if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
    Duel.SetSelectedCard(c)
    return mg:CheckWithSumGreater(Card.GetRitualLevel,rc:GetLevel(),rc)
  else return false end
end
function s.filter2(c,e,tp,m1,m2)
  if not c:IsSetCard(0x313) or bit.band(c:GetType(),0x81)~=0x81
  or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
  local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
  mg:Merge(m2)
     return mg:CheckWithSumGreater(Card.GetRitualLevel,c:GetLevel(),c)
end
function s.mfilter2(c)
  return c:GetLevel()>0 and c:IsAbleToRemove() 
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
    local mg1=Duel.GetRitualMaterial(tp)
    mg1:Remove(Card.IsLocation,nil,LOCATION_HAND+LOCATION_MZONE)
    local mg2=Duel.GetMatchingGroup(s.mfilter2,tp,0,LOCATION_GRAVE,nil)
    return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,mg1,mg2) 
    and e:GetHandler():IsAbleToDeck()
  end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,0,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
    local mg1=Duel.GetRitualMaterial(tp)
    mg1:Remove(Card.IsLocation,nil,LOCATION_HAND+LOCATION_MZONE)
    local mg2=Duel.GetMatchingGroup(s.mfilter2,tp,0,LOCATION_GRAVE,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,mg1,mg2)
    local tc=g:GetFirst()
    if tc then
      local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
      mg:Merge(mg2)
      local mat=nil   
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
      mat=mg:FilterSelect(tp,s.spmfilterf,1,1,nil,tp,mg,tc)
      Duel.SetSelectedCard(mat)
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
      local mat2=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetLevel(),tc)
      mat:Merge(mat2)
      tc:SetMaterial(mat)
      local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)     
      mat:Sub(mat2)
      Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
      Duel.BreakEffect()
      Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
      tc:CompleteProcedure()
    end
  end
end