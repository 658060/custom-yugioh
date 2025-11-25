--Inzektor Springtail
--mostly ripped from ladybug's card script
local s, id = GetID()
function s.initial_effect(c)
	--Equip 1 "Inzektor" monster to this card
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c, nil, s.eqval, s.equipop, e1)
	--Increase ATK/DEF/Level of the equipped monster
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(200)
	c:RegisterEffect(e2)
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	local e4 = Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_LEVEL)
	e4:SetValue(2)
	c:RegisterEffect(e4)
	--equip from Deck
	local e5 = Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id, 0))
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(function(e)
		return e:GetHandler():GetEquipTarget()
	end)
	e5:SetCost(Cost.SelfToGrave)
	e5:SetTarget(s.teqtg)
	e5:SetOperation(s.teqop)
	c:RegisterEffect(e5)
	--set S/T from Deck
	local e6 = Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id, 1))
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(function(e)
		return e:GetHandler():GetEquipTarget()
	end)
	e6:SetCost(Cost.SelfToGrave)
	e6:SetTarget(s.settg)
	e6:SetOperation(s.setdeck)
	c:RegisterEffect(e6)
end
s.listed_series = { SET_INZEKTOR }
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
--must control a face-up Inzektor monster
function s.teqfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_INZEKTOR)
end
--equip from deck must be an inzektor monster other than Springtail
function s.teqfilter2(c)
	return c:IsSetCard(SET_INZEKTOR) and c:IsMonster() and c:Code() ~= id and not c:IsForbidden()
end
--target a face-up Inzektor monster you control
function s.teqtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.teqfilter(chkc)
	end
	if chk == 0 then
		return Duel.IsExistingTarget(s.teqfilter, tp, LOCATION_MZONE, 0, 1, nil)
			and Duel.IsExistingMatchingCard(s.teqfilter2, tp, LOCATION_DECK, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
	Duel.SelectTarget(tp, s.teqfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.teqop(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
		local ec = Duel.SelectMatchingCard(tp, s.teqfilter2, tp, LOCATION_DECK, 0, 1, 1, nil, tp):GetFirst()
		if ec then
			s.tequipop(tc, e, tp, ec)
		end
	end
end

function s.tequipop(c, e, tp, ec)
	if not c:EquipByEffectAndLimitRegister(e, tp, ec, nil, true) then
		return
	end
	local e1 = Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(s.eqlimit)
	e1:SetReset(RESET_EVENT | RESETS_STANDARD)
	ec:RegisterEffect(e1)
end

function s.eqlimit(e, c)
	return c:GetControler() == e:GetHandlerPlayer()
end

function s.setfilter(c)
	return c:IsSetCard(SET_INZEKTOR) and c:IsSpellTrap()
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
	return Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_DECK, 0, 1, nil)
end

function s.setdeck(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local g = Duel.GetMatchingGroup(s.setfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g == 0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
	local sg = g:Select(tp, 1, 1, nil)
	if #sg > 0 then
		Duel.BreakEffect()
		Duel.SSet(tp, sg)
	end
end
