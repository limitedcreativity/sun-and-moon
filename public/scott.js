

const { warrior, archer, mage } = {
  warrior: 'warrior',
  archer: 'archer',
  mage: 'mage'
}

export const gameplay = {
  turnSpeed: 1000,
  startingGold: 800,
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
        health: 8,
        damage: 2
      },
      archer: {
        health: 5,
        damage: 1,
        range: 3
      },
      mage: {
        health: 5,
        heal: 1,
        range: 2
      }
    },
    enemy: {
      warrior: {
        health: 6,
        damage: 2
      },
      archer: {
        health: 3,
        damage: 1,
        range: 3
      },
      mage: {
        health: 4,
        heal: 1,
        range: 2
      }
    }
  },
  levels: [
    {
      lengthOfDay: 20000,
      reward: 800,
      waves: {
        0: { north: warrior },
        5: { east: warrior, west: warrior },
        10: { north: archer },
      }
    },
    {
      lengthOfDay: 19000,
      reward: 800,
      waves: {
        0: { east: warrior },
        1: { west: warrior },
        2: { north: warrior },
        6: { east: archer, west: archer }, 
        10: { north: warrior, east: warrior, west: warrior },
      }
    },
    {
      lengthOfDay: 18000,
      reward: 800,
      waves: {
        0: { north: warrior, east: warrior },
        4: { north: warrior, west: warrior },
        8: { east: archer, west: archer },
        15: { north: mage, east: warrior, west: warrior }, 
      }
    },
    {
      lengthOfDay: 17000,
      reward: 900,
      waves: {
        0: { north: warrior, east: mage, west: mage },
        6: { north: archer, east: warrior, west: warrior },
        12: { north: mage, east: archer, west: archer },
        16: { north: mage, east: warrior, west: warrior }, 
      }
    },
    {
      lengthOfDay: 16000,
      reward: 900,
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
      lengthOfDay: 15000,
      reward: 900,
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
      lengthOfDay: 14000,
      reward: 900,
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
      lengthOfDay: 13000,
      reward: 1000,
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
      lengthOfDay: 12000,
      reward: 1000,
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
      lengthOfDay: 11000,
      reward: 1000,
      waves: {
        0: { north: warrior },
        1: { north: warrior },
        2: { north: warrior },
        3: { north: warrior },
        4: { north: warrior },
        5: { north: warrior },
        6: { north: warrior },
        7: { north: warrior, east: warrior, west: warrior },
        8: { north: warrior, east: warrior, west: warrior },
        9: { north: warrior, east: warrior, west: warrior },
        10: { north: warrior, east: archer },
        11: { north: warrior, west: archer },
        12: { north: warrior, east: archer },
        13: { north: warrior, west: archer },
        14: { north: warrior, east: archer },
        15: { north: warrior, west: archer },
        16: { north: warrior, east: mage },
        17: { north: warrior, west: mage },
        18: { north: warrior, east: mage },
        19: { north: warrior, west: mage },
        20: { north: warrior, east: mage, west: warrior },
        21: { north: warrior, west: mage, west: warrior },
        22: { north: warrior, east: warrior, west: warrior },
        23: { north: warrior, east: warrior, west: warrior },
        24: { north: warrior, east: archer, west: archer },
        25: { north: mage, east: warrior, west: warrior },
        26: { north: archer, east: mage, west: mage },
        27: { north: warrior, east: warrior, west: warrior },
        28: { north: warrior, east: warrior, west: warrior },
        29: { north: mage, east: warrior, west: warrior },
        30: { north: archer, east: mage, west: mage },
      }
    }
  ]
}
