import { Elm } from '../src/Main.elm'
import { gameplay } from './scott.js'
import { music } from './music.js'


const app = Elm.Main.init({
  node: document.getElementById('app'),
  flags: { music, gameplay }
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
  'log': console.log,
  'newGameStarted': () => window.requestAnimationFrame(sendOffsets),
  'dayStarted': () => music.handleEvents.onDayStart(),
  'nightApproaches': () => music.handleEvents.onNightApproach(),
  'playClip': (keys) => {
    const clips = keys.split('.').reduce(
      (acc, key) => acc && acc[key] ? acc[key] : [],
      music.soundEffects
    )
    if (clips.length === 0) return
    const randomClip = clips[parseInt(Math.random() * clips.length)]
    if (randomClip) {
      const audio = state.cache[randomClip] || (state.cache[randomClip] = new Audio(randomClip))
      audio.play()
    }
  }
}
app.ports.outgoing.subscribe(({ tag, data }) => {
  const handler = handlers[tag]
  if (handler) {
    handler(data)
  }
})
