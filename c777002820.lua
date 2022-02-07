--Genshin Impact - Yae Miko
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),5,2,s.ovfilter,aux.Stringid(id,0))
    c:EnableReviveLimit()
    --(1)Banish
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(TIMING_END_PHASE,TIMINGS_CHECK_MONSTER_E)
    e1:SetCountLimit(1,id)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCost(s.ctcost)
    e1:SetTarget(s.cttg)
    e1:SetOperation(s.ctop)
    c:RegisterEffect(e1)
end
 --Xyz Summon
function s.ovfilter(c,tp,lc)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ) and c:IsSetCard(0x291,lc,SUMMON_TYPE_XYZ,tp)
end
--(1)Banish
 function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local rt=math.min(Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsAbleToRemove),tp,0,LOCATION_MZONE,nil),Duel.GetLocationCount(tp,LOCATION_MZONE,tp,nil),c:GetOverlayCount(),3)
    if chk==0 then return rt>0 and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
    c:RemoveOverlayCard(tp,1,rt,REASON_COST)
    local ct=Duel.GetOperatedGroup():GetCount()
    e:SetLabel(ct)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=math.min(e:GetLabel(),Duel.GetLocationCount(tp,LOCATION_MZONE,tp,nil))
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsAbleToRemove),tp,0,LOCATION_MZONE,ct,ct,nil)
    Duel.Remove(g,POS_FACEUP,REASON_EFFECT)    
end