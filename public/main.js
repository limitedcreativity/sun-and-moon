import { Elm } from '../src/Main.elm'
import { levels, startingGold, costs } from './settings.js'


const app = Elm.Main.init({
  node: document.getElementById('app'),
  flags: { startingGold, costs, levels }
})


const sendOffsets = () => {
  app.ports.onGridResize.send(getPositions())
}

window.addEventListener('resize', sendOffsets)
window.requestAnimationFrame(sendOffsets)

const getPositions = () => {
  const dots = [...document.querySelectorAll('.grid__dot')]
  return dots.map((dot, i) => {
    const { x, y, height } = dot.getBoundingClientRect()
    return [i, { x, y, scale: height }]
  })
}

let state = {
  cache: {}
}

const handlers = {
  'playClip': (filepath) => {
    const clip = state.cache[filepath] || new Audio(filepath)
    state.cache[filepath] = clip
    clip.play()
  }
}
app.ports.outgoing.subscribe(({ tag, data }) => {
  const handler = handlers[tag]
  if (handler) {
    handler(data)
  }
})
