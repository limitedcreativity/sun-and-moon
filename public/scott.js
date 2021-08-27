

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
        heal: 1,
        range: 2
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
        heal: 1,
        range: 2
      }
    }
  },
  levels: [
    {
      lengthOfDay: 5000,
      reward: 1500,
      waves: {
        0: { north: warrior },
        5: { east: warrior, west: warrior },
        10: { north: archer },
      }
    },
    {
      lengthOfDay: 4500,
      reward: 2000,
      waves: {
        0: { east: warrior },
        1: { west: warrior },
        2: { north: warrior },
        6: { east: archer, west: archer }, 
        10: { north: warrior, east: warrior, west: warrior },
      }
    },
    {
      lengthOfDay: 4000,
      reward: 2500,
      waves: {
        0: { north: warrior, east: warrior },
        4: { north: warrior, west: warrior },
        8: { east: archer, west: archer },
        15: { north: mage, east: warrior, west: warrior }, 
      }
    },
    {
      lengthOfDay: 3750,
      reward: 3000,
      waves: {
        0: { north: warrior, east: mage, west: mage },
        6: { north: archer, east: warrior, west: warrior },
        12: { north: mage, east: archer, west: archer },
        16: { north: mage, east: warrior, west: warrior }, 
      }
    },
    {
      lengthOfDay: 3500,
      reward: 3500,
      waves: {
        0: { north: warrior },
        1: { east: warrior },
        2: { north: warrior },
        3: { west: warrior },
        4: { east: warrior },
        5: { west: warrior },
        6: { north: warrior },
        7: { east: warrior },
        8: { west: warrior },
        9: { north: warrior },
        10: { west: warrior },
        11: { east: archer },
        12: { west: mage },
        13: { north: archer },
        14: { east: mage },
        15: { north: warrior },
      }
    },
    {
      lengthOfDay: 3500,
      reward: 4000,
      waves: {
        0: { north: warrior, east: mage, west: mage },
        3: { north: archer, east: warrior, west: warrior },
        8: { north: mage, east: archer, west: archer },
        12: { north: mage, east: warrior, west: warrior },
        14: { north: warrior, east: archer, west: warrior },
        17: { north: mage, east: warrior, west: warrior },
      }
    },
    {
      lengthOfDay: 3250,
      reward: 4500,
      waves: {
        0: { north: warrior, east: mage },
        2: { north: warrior, west: archer },
        4: { north: warrior, east: mage },
        6: { north: warrior, west: archer },
        8: { north: warrior, east: mage },
        10: { north: warrior, west: archer },
        12: { north: warrior, east: mage },
        14: { north: warrior, west: archer },
        16: { north: warrior, east: mage },
        18: { north: warrior, west: archer },
        20: { north: warrior, east: mage },
      }
    },
    {
      lengthOfDay: 3000,
      reward: 5000,
      waves: {
        0: { north: mage, east: mage, west: mage },
        3: { north: mage, east: mage, west: mage },
        6: { north: mage, east: mage, west: mage },
        9: { north: mage, east: mage, west: mage },
        12: { north: mage, east: mage, west: mage },
        15: { north: mage, east: mage, west: mage },
      }
    },
    {
      lengthOfDay: 2750,
      reward: 5500,
      waves: {
        0: { north: warrior, east: archer, west: mage },
        4: { north: archer, east: mage, west: warrior },
        8: { north: mage, east: warrior, west: archer },
        12: { north: warrior, east: archer, west: mage },
        16: { north: archer, east: mage, west: warrior },
        20: { north: mage, east: warrior, west: archer },
        24: { north: warrior, east: archer, west: mage },
      }
    },
    {
      lengthOfDay: 2500,
      reward: 6000,
      waves: {
        0: { north: warrior },
        1: { north: warrior },
        2: { north: warrior },
        3: { north: warrior },
        4: { north: warrior },
        5: { north: warrior },
        6: { north: warrior },
        7: { north: warrior },
        8: { north: warrior },
        9: { north: warrior },
        10: { east: archer },
        11: { west: archer },
        12: { east: archer },
        13: { west: archer },
        14: { east: archer },
        15: { west: archer },
        16: { east: mage },
        17: { west: mage },
        18: { east: mage },
        19: { west: mage },
        20: { east: mage },
        21: { west: mage },
        22: { north: warrior, east: warrior, west: warrior },
        23: { north: warrior, east: warrior, west: warrior },
        24: { north: warrior, east: archer, west: archer },
        25: { north: mage, east: warrior, west: warrior },
        30: { north: archer, east: mage, west: mage, },
      }
    },
  ]
}
