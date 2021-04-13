local CharReseption = {
	Name = "resepshen",
	Icon = "",
}

DialogScript = {
	Steps = {
		Step_StartDialog = {
			Char = CharReseption,
			Text = "hi, chem mogu pomoch?",
			Ansvers = {
				{
					Text = "chto eto za mesto?",
					NextStepName = "Step_OGostiniche",
				},
				{
					Text = "chto proizoshlo na uliche?",
					NextStepName = "Step_ODrake",
				},
			}
		},

		Step_OGostiniche = {
			Char = CharReseption,
			Text = "eto gostinicha",
			Ansvers = {
				{
					Text = "ponyatno, poka!",
					NextStepName = "Step_Vihod",
				},
				{
					Text = "chto proizoshlo na uliche?",
					NextStepName = "Step_ODrake",
				},
			}
		},

		Step_ODrake = {
			Char = CharReseption,
			Text = "bila draka okolo bara, polichiya ochepila mesto, skoro dolzhni ublat ograzhdeniya, ne hotite li ostatsya nanoch?",
			Ansvers = {
				{
					Text = "net, poka!",
					NextStepName = "Step_Vihod",
				},
				{
					Text = "biloby neploho otdohnyt",
					NextStepName = "Step_Utro",
				},
			}
		},

		Step_Vihod = {
			Char = CharReseption,
			Text = "zahodite k nam snova!",
			Ansvers = {
				{
					Text = "...",
					NextStepName = "",
					Action = {
						Type = "MultiAction",
						ActionList = {
							{
								Type = "MoveObj",
								ObjName = "player_actor",
								TargetObjName = "HotelOutTrigger",
							},	
							{
								Type = "BackToScene"
							},												
						},
					},
				},
			}
		},

		Step_Utro = {
			Char = CharReseption,
			Text = "S dobrim utrom. na vashem schetu net dostatochnoy summi dlya oplati prozhivaniya. My vernem vashy vesci kak tolko vi oplatite sceta.",
			Ansvers = {
				{
					Text = "ok...",
					NextStepName = "",
					Action = TODO,
				},
			}
		},
	}
}