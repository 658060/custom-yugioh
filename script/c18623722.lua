--Inzektor Exa-Titan
local s, id = GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(
		c,
		aux.FilterBoolFunctionEx(Card.IsRace, RACE_INSECT),
		7,
		2,
		s.ovfilter,
		aux.Stringid(id, 0),
		2,
		s.xyzop
	)
	c:EnableReviveLimit()
	--quick effect
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 1))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1, false, EFFECT_MARKER_DETACH_XMAT)
	aux.AddEREquipLimit(c, nil, function(ec, _, tp)
		return ec:IsControler(1 - tp)
	end, s.equipop, e1)
	--if this card would be destroyed, send an equip instead
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	c:RegisterEffect(e2)
end
s.listed_series = { SET_INZEKTOR }
--allowed to summon on top of an "Inzektor" Xyz,
--but not "Inzektor Exa-Titan".
function s.ovfilter(c, tp, xyzc)
	return c:IsFaceup()
		and c:IsSetCard(SET_INZEKTOR, xyzc, SUMMON_TYPE_XYZ, tp)
		and not c:IsSummonCode(xyzc, SUMMON_TYPE_XYZ, tp, id)
		and c:IsType(TYPE_XYZ, xyzc, SUMMON_TYPE_XYZ, tp)
end
--can only use alt summoning condition OPT
function s.xyzop(e, tp, chk)
	if chk == 0 then
		return Duel.GetFlagEffect(tp, id) == 0
	end
	Duel.RegisterFlagEffect(tp, id, RESET_PHASE | PHASE_END, 0, 1)
	return true
end
--condition under which the effect can be activated
function s.eqtg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
			and Duel.IsExistingMatchingCard(
				s.eqfilter,
				tp,
				LOCATION_GRAVE | LOCATION_MZONE,
				LOCATION_GRAVE | LOCATION_MZONE,
				1,
				c
			)
	end
end
--equip 1 monster from the field or either GY
function s.eqop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
	local g = Duel.SelectMatchingCard(
		tp,
		s.eqfilter,
		tp,
		LOCATION_ONFIELD | LOCATION_GRAVE,
		LOCATION_ONFIELD | LOCATION_GRAVE,
		1,
		1,
		c
	)
	if #g > 0 then
		Duel.HintSelection(g)
		-- local tc = g:Select(tp, 1, 1, nil):GetFirst()
		local tc = g:GetFirst()
		--shouldn't happen
		if tc == nil then
			return
		end
		if not s.equipop(c, e, tp, tc) then
			return
		end
	end
end
--each equip card gains the effects to increase Exa-Titan's atk/def
function s.equipop(c, e, tp, tc)
	if not c:EquipByEffectAndLimitRegister(e, tp, tc) then
		return
	end
	if tc:IsFaceup() then
		local atk = tc:GetTextAttack() / 2
		if atk < 0 then
			atk = 0
		end
		local e3 = Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetReset(RESET_EVENT | RESETS_STANDARD)
		e3:SetValue(atk)
		tc:RegisterEffect(e3)
		local def = tc:GetTextDefense() / 2
		if def < 0 then
			def = 0
		end
		local e4 = Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_EQUIP)
		e4:SetCode(EFFECT_UPDATE_DEFENSE)
		e4:SetReset(RESET_EVENT | RESETS_STANDARD)
		e4:SetValue(def)
		tc:RegisterEffect(e4)
	end
end
--must equip a valid monster
function s.eqfilter(c)
	return c:IsLocation(LOCATION_MZONE) or c:IsMonster() and not c:IsForbidden()
end
function s.repfilter(c)
	return c:IsAbleToGrave() and c:IsEquipCard()
end
function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then
		return not c:IsReason(REASON_REPLACE)
			and c:IsReason(REASON_EFFECT)
			and Duel.IsExistingMatchingCard(s.repfilter, tp, LOCATION_ONFIELD, 0, 1, c)
	end
	if Duel.SelectEffectYesNo(tp, e:GetHandler(), 96) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESREPLACE)
		local g = Duel.SelectMatchingCard(tp, s.repfilter, tp, LOCATION_ONFIELD, 0, 1, 1, c)
		Duel.SendtoGrave(g, REASON_EFFECT | REASON_REPLACE)
		return true
	else
		return false
	end
end
