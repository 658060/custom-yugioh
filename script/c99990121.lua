--Death's Head Behe-moth
local s, id = GetID()
function s.initial_effect(c)
	-- synchro summon
	Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_INSECT), 1, 1, Synchro.NonTuner(nil), 1, 99)
	c:EnableReviveLimit()
	-- quick effect special summon banished insect
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	-- insects you control are unaffected by S/Ts
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE, 0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace, RACE_INSECT))
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

function s.filter1(c, e, tp)
	return c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.tg1(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	local c = e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_REMOVED)
	end
	if chk == 0 then
		return Duel.IsExistingTarget(s.filter1, tp, LOCATION_REMOVED, 0, 1, nil, e, tp)
			and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
	end

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectTarget(tp, s.filter1, tp, LOCATION_REMOVED, 0, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, tp, LOCATION_REMOVED)
end
function s.op1(e, tp, eg, ep, ev, re, rp)
	local c = e:GetHandler()
	local tc = Duel.GetTargetCards(e)
	Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
end

-- insects you control are unaffected by S/Ts
function s.val2(e, te)
	return te:IsSpellTrapEffect()
end
