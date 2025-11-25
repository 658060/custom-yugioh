--Inzektor Termite
local s, id = GetID()
function s.initial_effect(c)
	--Special Summon itself from hand
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.selfspcon)
	c:RegisterEffect(e1)
	--Equip 1 "Inzektor" monster to itself
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c, nil, s.eqval, s.equipop, e2)
	--Increase level while equipped to a monster
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_LEVEL)
	e3:SetValue(3)
	c:RegisterEffect(e3)
	--Add 1 "Inzektor" monster from the GY to hand
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.addcon)
	e4:SetTarget(s.addtg)
	e4:SetOperation(s.addop)
	c:RegisterEffect(e4)
end
s.listed_series = { SET_INZEKTOR }
function s.selfspcon(e, c)
	if c == nil then
		return true
	end
	local tp = c:GetControler()
	return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingMatchingCard(Card.IsSetCard, tp, LOCATION_ONFIELD, 0, 1, nil, SET_INZEKTOR)
end
function s.eqval(ec, c, tp)
	return ec:IsControler(tp) and ec:IsSetCard(SET_INZEKTOR)
end
function s.filter(c)
	return c:IsSetCard(SET_INZEKTOR) and c:IsMonster() and not c:IsForbidden()
end
function s.eqtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
			and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_GRAVE | LOCATION_HAND, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, tp, LOCATION_GRAVE | LOCATION_HAND)
end
function s.equipop(c, e, tp, tc)
	c:EquipByEffectAndLimitRegister(e, tp, tc, nil, true)
end
function s.eqop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then
		return
	end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then
		return
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
	local g =
		Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.filter), tp, LOCATION_GRAVE | LOCATION_HAND, 0, 1, 1, nil)
	local tc = g:GetFirst()
	if tc then
		s.equipop(c, e, tp, tc)
	end
end
function s.cfilter(c, ec, tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:GetEquipTarget() == ec
end
function s.addcon(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(s.cfilter, 1, nil, e:GetHandler(), tp)
end
function s.addfilter(c)
	return c:IsSetCard(SET_INZEKTOR) and c:IsAbleToHand()
end
function s.addtg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then
		return c:IsRelateToEffect(e)
			and c:IsFaceup()
			and Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end
function s.addop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.addfilter), tp, LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end
