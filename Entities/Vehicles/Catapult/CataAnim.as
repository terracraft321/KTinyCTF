void onInit(CSprite@ this)
{
	ReloadSprites(this);
}

void ReloadSprites(CSprite@ sprite)
{
	string filename = sprite.getFilename();

	sprite.SetZ(-25.0f);
	sprite.ReloadSprite(filename);

	// (re)init arm and cage sprites
	sprite.RemoveSpriteLayer("rollcage");
	CSpriteLayer@ rollcage = sprite.addSpriteLayer("rollcage", filename, 24, 16);

	if (rollcage !is null)
	{
		Animation@ anim = rollcage.addAnimation("default", 0, false);
		anim.AddFrame(3);
		rollcage.SetOffset(Vec2f(0, -2.0f));
		rollcage.SetRelativeZ(-0.01f);
	}

	sprite.RemoveSpriteLayer("arm");
	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", filename, 8, 18);

	if (arm !is null)
	{
		Animation@ anim = arm.addAnimation("default", 0, false);
		anim.AddFrame(6);
		anim.AddFrame(7);
		arm.ResetTransform();
		arm.SetOffset(Vec2f(-4.0f, -5.0f));
		arm.SetRelativeZ(-10.5f);
		//rotation handled by update
	}
}
