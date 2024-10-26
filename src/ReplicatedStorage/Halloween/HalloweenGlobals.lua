local globals = {}
globals.candyColors = {
	Blue = Color3.fromRGB(52, 130, 255);
	Green = Color3.fromRGB(39, 236, 35);
	Orange = Color3.fromRGB(255, 116, 24);
	Pink = Color3.fromRGB(255, 114, 241);
	Yellow = Color3.fromRGB(255, 255, 0);
}

globals.itemImages={
	Candy="rbxassetid://86343935474416";
	CandyCorn="rbxassetid://132604135806537";
	Lollipop="rbxassetid://110083267306176";
	GummyBear="rbxassetid://86686643572830";
	Chocolate="rbxassetid://131913285284275";
	
	StarCookie="rbxassetid://5782455755";
	PhantomCoil="rbxassetid://126417285482914";
	Bombkin="rbxassetid://86283391474095";
}

globals.crafting={
	Candy = {
		CandyCorn={
			OrangeCandy=2;
			YellowCandy=3;
		};

		GummyBear={
			OrangeCandy=1;
			BlueCandy=1;
			PinkCandy=2;
			GreenCandy=1;
		};

		Lollipop={
			BlueCandy=3;
			PinkCandy=2;
		};
		
		Chocolate={
			CandyCorn=1;
			Lollipop=1;
		}
	};

	Gear = {
		StarCookie={
			Chocolate=1;
			Lollipop=2;
			BlueCandy=1;
		};

		Bombkin={
			Chocolate=1;
			CandyCorn=3;
			GummyBear=1;
		};
		
		PhantomCoil={
			Lollipop=2;
			GummyBear=2;
			Chocolate=2;
			CandyCorn=2;
		};
	};
	
}

return globals