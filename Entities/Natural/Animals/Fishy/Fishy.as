
//script for a cute fishy

#include "AnimalConsts.as";

//sprite

const array<array<string>> anims =
{
	{"speck_default", "speck_idle", "speck_dead"},
	{"baby_default", "baby_idle", "baby_dead"},
	{"young_default", "young_idle", "young_dead"},
	{"default", "idle", "dead"}
};

void onInit(CSprite@ this)
{
	uint col = uint(XORRandom(8));
	if (this.getBlob().exists("colour"))
		col = this.getBlob().get_u8("colour");
	else
		this.getBlob().set_u8("colour", col);

	this.ReloadSprites(col, 0); //random colour
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	u8 age = Maths::Min(blob.get_u8("age"), 3);

	if (!blob.hasTag("dead"))
	{
		if (blob.isKeyPressed(key_left) ||
		        blob.isKeyPressed(key_right) ||
		        blob.isKeyPressed(key_up) ||
		        blob.isKeyPressed(key_down))
		{
			this.SetAnimation(anims[age][0]);
		}
		else
		{
			this.SetAnimation(anims[age][1]);
		}
	}
	else
	{
		this.SetAnimation(anims[age][2]);
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

//blob

void onInit(CBlob@ this)
{
	string[] tags = {"player", "flesh"};
	this.set("tags to eat", tags);

	this.set_f32("bite damage", 0.5f);
	
	this.set_f32(terr_rad_property, 64.0f);
	this.set_f32(target_searchrad_property, 96.0f);

	
	this.set_u8(personality_property, AGGRO_BIT);
	this.set_f32(target_searchrad_property, 56.0f);

	this.getBrain().server_SetActive(true);

	this.set_f32("swimspeed", 0.5f);
	this.set_f32("swimforce", 0.1f);

	this.Tag("flesh");
	this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 40;

	if (!this.exists("age"))
		this.set_u8("age", 0);
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
	if (Maths::Abs(x) > 1.0f)
	{
		this.SetFacingLeft(x < 0);
	}
	else
	{
		if (this.isKeyPressed(key_left))
			this.SetFacingLeft(true);
		if (this.isKeyPressed(key_right))
			this.SetFacingLeft(false);
	}

	if (getNet().isServer())
	{
		u8 age = this.get_u8("age");
		if (age < 3)
		{
			if (XORRandom(512) < 64)
			{
				age++;
			}

			this.set_u8("age", age);
			this.Sync("age", true);
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(damage == 0)
		return damage;

	u8 age = this.get_u8("age");

	this.Tag("dead");
	this.AddScript("Eatable.as");
	this.getShape().getConsts().buoyancy = 0.8f;
	this.getShape().getConsts().collidable = true;

	CSprite@ sprite = this.getSprite();

	sprite.SetAnimation(anims[age][2]);

	sprite.SetFacingLeft(!sprite.isFacingLeft());

	this.getCurrentScript().runFlags |= Script::remove_after_this;
	return damage;
}
