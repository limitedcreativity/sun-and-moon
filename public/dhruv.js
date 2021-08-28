const nightFadeDuration = 9000

const night = new Audio('/music/night_coming.wav');
night.loop = true;

export const music = {
  nightFadeDuration,
  handleEvents: {
    onDayStart: () => {
      console.log('DAY STARTED!')
      night.pause();
    },
    onNightApproach: () => {
      console.log("NIGHT")
      night.currentTime = 0;
      night.play();
    },
  },
  soundEffects: {
    onGuardianBuilt: {
      warrior: [],
      archer: [],
      mage: []
    },
    onGuardianWake: {
      warrior: [],
      archer: [],
      mage: []
    },
    onGuardianAttack: {
      warrior: [],
      archer: [],
      mage: []
    },
    onGuardianHurt: {
      warrior: [],
      archer: [],
      mage: []
    },
    onGuardianKilled: {
      warrior: [],
      archer: [],
      mage: []
    },
    onEnemyKilled: {
      warrior: [],
      archer: [],
      mage: []
    },
    onShrineAttacked: [],
    onShrineDestroyed: []
  }
}