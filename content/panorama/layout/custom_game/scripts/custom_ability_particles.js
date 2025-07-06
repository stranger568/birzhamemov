const ABILITY_PARTICLES = {
    "scp682_bite": {
        particle: "particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_range_finder_aoe.vpcf",
        attachment: ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW,
        update: updateConeAbility
    },
    "kakashi_graze_wave": {
        particle: "particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_range_finder_aoe.vpcf",
        attachment: ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW,
        update: updateConeAbility
    },
    "puchkov_smeh": {
        particle: "particles/units/heroes/hero_dark_willow/dark_willow_bramble_range_finder_aoe.vpcf",
        attachment: ParticleAttachment_t.PATTACH_CUSTOMORIGIN,
        update: updateCircularAbility
    },
    "item_birzha_ward": {
        particle: "particles/ui_mouseactions/range_finder_ward_aoe.vpcf",
        attachment: ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW,
        update: updateWardAbility
    },
    "puchkov_pigs": {
        particle: "particles/ui_mouseactions/custom_range_finder_cone.vpcf",
        attachment: ParticleAttachment_t.PATTACH_WORLDORIGIN,
        update: updatePigsAbility
    }
};

let vectorTargetParticle;
let lastAbility = -1;

function Think() {
    const currentAbility = Abilities.GetLocalPlayerActiveAbility();
    // Проверка изменения активной способности
    if (currentAbility !== lastAbility) {
        handleAbilityChange(currentAbility);
        lastAbility = currentAbility;
    }
    
    // Обновление частиц для текущей способности
    if (vectorTargetParticle && currentAbility !== -1) {
        const abilityName = Abilities.GetAbilityName(currentAbility);
        const abilityConfig = ABILITY_PARTICLES[abilityName];
        
        if (abilityConfig && abilityConfig.update) {
            abilityConfig.update(currentAbility, vectorTargetParticle);
        }
    }
    
    $.Schedule(1/144, Think);
}

function handleAbilityChange(currentAbility) {
    // Удаляем старые частицы
    if (vectorTargetParticle) {
        Particles.DestroyParticleEffect(vectorTargetParticle, true);
        vectorTargetParticle = undefined;
    }
    
    // Создаем новые частицы для новой способности
    if (currentAbility !== -1) {
        const abilityName = Abilities.GetAbilityName(currentAbility);
        const abilityConfig = ABILITY_PARTICLES[abilityName];
        if (abilityConfig) {
            vectorTargetParticle = Particles.CreateParticle(
                abilityConfig.particle,
                abilityConfig.attachment,
                Players.GetLocalPlayerPortraitUnit()
            );
        }
    }
}

// Функции обновления для разных типов способностей
function updateConeAbility(ability, particle) {
    const cursor = GameUI.GetCursorPosition();
    const worldPosition = GameUI.GetScreenWorldPosition(cursor);
    const origin = Entities.GetAbsOrigin(Players.GetLocalPlayerPortraitUnit());
    const direction = Vector_normalize(Vector_sub(origin, worldPosition));
    let castRange = Abilities.GetCastRange(ability);
    let pointBlank = 0;
    
    if (Abilities.GetAbilityName(ability) === "scp682_bite") 
    {
        pointBlank = Abilities.GetSpecialValueFor(ability, "point_blank_range");
        if (HasModifier(Players.GetLocalPlayerPortraitUnit(), "modifier_scp682_ultimate")) {
            pointBlank += 150;
        }
    }

    Particles.SetParticleControl(particle, 0, origin);
    Particles.SetParticleControl(particle, 1, Vector_sub(origin, Vector_mult(direction, (castRange + (300*0.7) ))) );
	Particles.SetParticleControl(particle, 2, [75/2, 300/2, 0] );
	Particles.SetParticleControl(particle, 3, [75/2, (300*0.7)/2, 0] );
    Particles.SetParticleControl(particle, 6, Vector_sub(origin, Vector_mult(direction, pointBlank)) );
}

function updateCircularAbility(ability, particle) {
    const cursor = GameUI.GetCursorPosition();
    const worldPosition = GameUI.GetScreenWorldPosition(cursor);
    const radius = Abilities.GetSpecialValueFor(ability, "radius");
    
    Particles.SetParticleControl(particle, 1, [radius, radius, radius]);
    
    const c = Math.sqrt(2) * 0.5 * radius;
    const xOffset = [-radius, -c, 0.0, c, radius, c, 0.0, -c];
    const yOffset = [0.0, c, radius, c, 0.0, -c, -radius, -c];
    
    Particles.SetParticleControl(particle, 0, worldPosition);
    for (let i = 0; i < 8; i++) {
        Particles.SetParticleControl(particle, 2 + i, Vector_add(worldPosition, [xOffset[i], yOffset[i], 0]));
    }
}

function updateWardAbility(ability, particle) {
    const cursor = GameUI.GetCursorPosition();
    const worldPosition = GameUI.GetScreenWorldPosition(cursor);
    const origin = Entities.GetAbsOrigin(Players.GetLocalPlayerPortraitUnit());
    
    Particles.SetParticleControl(particle, 0, origin);
    Particles.SetParticleControl(particle, 1, [255, 255, 255]);
    Particles.SetParticleControl(particle, 6, [255, 255, 255]);
    Particles.SetParticleControl(particle, 2, worldPosition);
    
    const wardModifier = FindModifier(Players.GetLocalPlayerPortraitUnit(), "modifier_item_birzha_ward");
    if (wardModifier) {
        const wardAbility = Buffs.GetAbility(Players.GetLocalPlayerPortraitUnit(), wardModifier);
        const wardTable = CustomNetTables.GetTableValue('ward_type', String(wardAbility));
        
        if (wardTable?.type) {
            if (wardTable.type === "observer") {
                Particles.SetParticleControl(particle, 11, [0, 0, 0]);
                const range = HowStacks("modifier_item_birzha_ward") === 3 ? 1700 : 1600;
                Particles.SetParticleControl(particle, 3, [range, range, range]);
            } else if (wardTable.type === "sentry") {
                Particles.SetParticleControl(particle, 11, [1, 0, 0]);
                Particles.SetParticleControl(particle, 3, [1000, 1000, 1000]);
            }
        }
    }
}

function updatePigsAbility(ability, particle) {
    const cursor = GameUI.GetCursorPosition();
    const worldPosition = GameUI.GetScreenWorldPosition(cursor);
    const origin = Entities.GetAbsOrigin(Players.GetLocalPlayerPortraitUnit());
    const distance = Abilities.GetSpecialValueFor(ability, "distance");
    const direction = Vector_normalize(Vector_sub(origin, worldPosition));
    
    Particles.SetParticleControl(particle, 2, Vector_sub(origin, Vector_mult(direction, distance)));
    Particles.SetParticleControl(particle, 0, origin);
    Particles.SetParticleControl(particle, 1, origin);
    Particles.SetParticleControl(particle, 3, [125, 125, 1]);
    Particles.SetParticleControl(particle, 4, [0, 255, 0]);
    Particles.SetParticleControl(particle, 6, [1, 0, 0]);
}

Think();