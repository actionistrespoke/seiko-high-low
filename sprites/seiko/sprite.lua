return {
	imageSrc = "sprites/seiko/sprite.png",
	defaultState = "idle",
	states = {
		idle = {
			frameCount = 15,
			offsetY = 0,
			frameW = 400,
			frameH = 450,
			nextState = "idle",
			switchDelay = 0.1
		},
		gameover = {
			frameCount = 1,
			offsetY = 450,
			frameW = 400,
			frameH = 450,
			nextState = "gameover",
			switchDelay = 0.1
		},
		warning = {
			frameCount = 1,
			offsetY = 900,
			frameW = 400,
			frameH = 450,
			nextState = "warning",
			switchDelay = 0.1
		},
		losing = {
			frameCount = 5,
			offsetY = 1350,
			frameW = 400,
			frameH = 450,
			nextState = "losing",
			switchDelay = 0.1
		}
	}
}