

const { warrior, archer, mage } = {
  warrior: 'warrior',
  archer: 'archer',
  mage: 'mage'
}

export const gameplay = {
  turnSpeed: 1000,
  startingGold: 1000,
  shrine: {
    health: 10
  },
  costs: {
    warrior: 200,
    archer: 500,
    mage: 1000
  },
  units: {
    guardian: {
      warrior: {
        health: 5,
        damage: 1
      },
      archer: {
        health: 5,
        damage: 1,
        range: 4
      },
      mage: {
        health: 5,
        damage: 1,
        range: 4,
        areaOfEffect: 1
      }
    },
    enemy: {
      warrior: {
        health: 3,
        damage: 1
      },
      archer: {
        health: 3,
        damage: 1,
        range: 4
      },
      mage: {
        health: 3,
        damage: 1,
        range: 4,
        areaOfEffect: 1
      }
    }
  },
  levels: [
    {
      lengthOfDay: 5000,
      reward: 500,
      waves: {
        0: { north: warrior },
        5: { east: warrior },
        10: { west: warrior },
      }
    },
    {
      lengthOfDay: 4000,
      reward: 1000,
      waves: {
        0: { east: warrior },
        5: { west: warrior },
        10: { north: warrior, east: warrior, west: warrior },
      }
    }
  ]
}
