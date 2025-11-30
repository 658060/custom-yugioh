--Tiger Behe-moth
local s, id = GetID()
function s.initial_effect(c)
  -- discard; send deck->GY
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_TOGRAVE)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetRange(LOCATION_HAND)
  e1:SetCountLimit(1, {id, 0})
  e1:SetCost(s.cost1)
  e1:SetOperation(s.op1)
  c:RegisterEffect(e1)
  -- if banished, banish s/t and insect to return to gy
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_REMOVE)
  e2:SetProperty(EFFECT_FLAG_DELAY)
  e2:SetCountLimit(1, {id, 1})
  e2:SetCost(s.cost2)
  e2:SetTarget(s.tg2)
  e2:SetOperation(s.op2)
  c:RegisterEffect(e2)
  -- if sent to GY, banish target insect to special summon
  local e3 = Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetCode(EVENT_TO_GRAVE)
  e3:SetProperty(EFFECT_FLAG_DELAY)
  e3:SetCountLimit(1, {id, 2})
  e3:SetTarget(s.tg3)
  e3:SetOperation(s.op3)
  c:RegisterEffect(e3)
end

s.listed_series = { 0xa056 }

-- discard; send deck->GY
function s.filter1(c)
  return c:IsSetCard(0xa056) 
    and c:IsAbleToGrave()
    and c:GetCode() ~= id -- cannot be "Tiger Behe-moth"
end
function s.cost1(e, tp, eg, ep, ev, re, r, rp, chk)
  local c = e:GetHandler()

  if chk == 0 then 
    return c:IsDiscardable() and
      Duel.IsExistingMatchingCard(s.filter1, tp, LOCATION_DECK, 0, 1, nil)
  end
  
  Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.op1(e, tp, eg, ep, ev, re, r, rp)
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
  local g = Duel.SelectMatchingCard(tp, s.filter1, tp, LOCATION_DECK, 0, 1, 1, nil)
  if #g > 0 then
    Duel.SendtoGrave(g, REASON_EFFECT)
  end
end

-- if banished, banish s/t and insect to return to gy
function s.filter2(c)
  return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
function s.cost2(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
    return Duel.IsExistingMatchingCard(s.filter2, tp, LOCATION_GRAVE, 0, 1, nil)
  end
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
  local rmc = Duel.SelectMatchingCard(tp, s.filter2, tp, LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
  Duel.Remove(rmc, POS_FACEUP, REASON_COST)
end
function s.tg2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  local c = e:GetHandler()

  if chkc then 
    return chkc:IsSpellTrap() 
      and Duel.IsPlayerCanRemove(tp, chkc) 
  end
  if chk == 0 then
    return Duel.IsExistingTarget(Card.IsSpellTrap, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
      and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
      and c:IsAbleToGrave()
  end
  
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
  local bc = Duel.SelectTarget(tp, Card.IsSpellTrap, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
  if #bc > 0 then
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
  end
end
function s.op2(e, tp, eg, ep, ev, re, r, rp)
  local c = e:GetHandler()
  local bc = Duel.GetTargetCards(e):GetFirst()
  if Duel.Remove(bc, POS_FACEUP, REASON_EFFECT) then
    Duel.SendtoGrave(c, REASON_EFFECT)
  end
end

-- if sent to GY, banish target insect to special summon
function s.filter3(c)
  return c:IsRace(RACE_INSECT)
end
function s.tg3(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  local c = e:GetHandler()

  if chkc then
    return chkc:IsLocation(LOCATION_GRAVE) 
      and Duel.IsPlayerCanRemove(tp, chkc)
  end
  if chk == 0 then 
    return Duel.IsExistingTarget(s.filter3, tp, LOCATION_GRAVE, 0, 1, c)
  end

  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
  local bc = Duel.SelectTarget(tp, s.filter3, tp, LOCATION_GRAVE, 0, 1, 1, c)
  if #bc > 0 then
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, bc, 1, 0, 0)
  end
end
function s.op3(e, tp, eg, ep, ev, re, r, rp)
  local c = e:GetHandler()
  local bc = Duel.GetTargetCards(e):GetFirst()
  if Duel.Remove(bc, POS_FACEUP, REASON_EFFECT) then
    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
  end
end
