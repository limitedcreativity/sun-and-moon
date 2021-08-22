
/**
 *   Example level:
 * 
      {
        reward: 500,
        waves: {
          0: {
            NORTH: ['rogue']
          },
          5: {
            EAST: ['rogue']
          },
          10: {
            NORTH: ['rogue'],
            EAST: ['rogue'],
            WEST: ['rogue'],
          }
        }
      }
 * 
 */
export const levels = [
  {
    reward: 500,
    waves: {
      0: {
        NORTH: ['rogue']
      },
      5: {
        EAST: ['rogue']
      },
      10: {
        NORTH: ['rogue'],
        EAST: ['rogue'],
        WEST: ['rogue'],
      }
    }
  }
]

export const startingGold =
  100


export const costs = {
  warrior: 100,
  archer: 200,
  mage: 500
}

export default {
  startingGold,
  costs,
  levels
}