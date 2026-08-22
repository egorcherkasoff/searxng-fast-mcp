// Удаление MCP-сервера из конфига opencode (у CLI нет команды remove).
// Понимает JSONC: комментарии вырезаются вне строк, конфиг пишется обратно как JSON.
import { readFileSync, writeFileSync, existsSync } from "node:fs"
import { homedir } from "node:os"
import { join } from "node:path"
import process from "node:process"

const name = process.argv[2]
if (!name) {
  console.error("usage: node uninstall.mjs <server-name>")
  process.exit(2)
}

const dir = join(homedir(), ".config", "opencode")
const candidates = ["opencode.json", "opencode.jsonc"].map((f) => join(dir, f))
const configPath = candidates.find(existsSync)

if (!configPath) {
  console.log("Конфиг opencode не найден — нечего удалять.")
  process.exit(0)
}

function stripComments(text) {
  let out = ""
  let i = 0
  let inString = false
  while (i < text.length) {
    const c = text[i]
    const next = text[i + 1]
    if (inString) {
      out += c
      if (c === "\\") {
        out += next ?? ""
        i += 2
        continue
      }
      if (c === '"') inString = false
      i++
      continue
    }
    if (c === '"') {
      inString = true
      out += c
      i++
      continue
    }
    if (c === "/" && next === "/") {
      while (i < text.length && text[i] !== "\n") i++
      continue
    }
    if (c === "/" && next === "*") {
      i += 2
      while (i < text.length && !(text[i] === "*" && text[i + 1] === "/")) i++
      i += 2
      continue
    }
    out += c
    i++
  }
  return out
}

const raw = readFileSync(configPath, "utf8")
const config = JSON.parse(stripComments(raw))
let changed = false

if (config.mcp?.[name] !== undefined) {
  delete config.mcp[name]
  if (Object.keys(config.mcp).length === 0) delete config.mcp
  changed = true
}

if (!changed) {
  console.log(`Сервер "${name}" в ${configPath} не найден.`)
  process.exit(0)
}

writeFileSync(configPath, JSON.stringify(config, null, 2) + "\n")
console.log(`Убрал "${name}" из ${configPath}`)
