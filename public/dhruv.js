const nightFadeDuration = 1000

export const music = {
  nightFadeDuration,
  handleEvents: {
    onDayStart: () => {
      console.log('DAY STARTED!')
    },
    onNightApproach: () => {
      console.log('NIGHT APPROACHES!')
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