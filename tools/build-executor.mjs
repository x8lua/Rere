import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const lib = path.join(repo, "lib");
const files = [];

function walk(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full);
    else if (entry.name.endsWith(".lua")) files.push(full);
  }
}
walk(lib);

function keyFor(file) {
  let key = path.relative(lib, file).replaceAll(path.sep, "/").replace(/\.lua$/, "");
  if (key === "init") return "Iris";
  if (key.endsWith("/init")) key = key.slice(0, -5);
  return key;
}

const keys = files.map(keyFor).sort((a, b) => a.split("/").length - b.split("/").length);
const lines = [
  "-- Rere executor distribution. Generated from Iris source; no Studio require() is needed.",
  "local function node(name, parent)",
  "    local value = {Name = name, Parent = parent}",
  "    if parent then parent[name] = value end",
  "    return value",
  "end",
  "local nodes, sources, cache = {}, {}, {}",
  "local root = node('Iris')",
  "nodes['Iris'] = root",
];

for (const key of keys) {
  if (key === "Iris") continue;
  const parts = key.split("/");
  let parentKey = "Iris";
  for (let i = 0; i < parts.length; i++) {
    const current = parts.slice(0, i + 1).join("/");
    if (!keys.includes(current) && i < parts.length - 1) continue;
    if (!lines.some((line) => line.includes(`nodes['${current}']`))) {
      lines.push(`nodes['${current}'] = node('${parts[i]}', nodes['${parentKey}'])`);
    }
    parentKey = current;
  }
}

lines.push(
  "local function requireModule(module)",
  "    assert(module and sources[module], 'Rere: missing bundled module '..tostring(module and module.Name))",
  "    if cache[module] == nil then cache[module] = sources[module](module) end",
  "    return cache[module]",
  "end",
);

for (const file of files.sort()) {
  const key = keyFor(file);
  const source = fs.readFileSync(file, "utf8").replace(/\r\n/g, "\n");
  lines.push(`sources[nodes['${key}']] = function(script)`);
  lines.push("    local require = requireModule");
  lines.push(source.split("\n").map((line) => line.length > 0 ? `    ${line}` : "").join("\n"));
  lines.push("end");
}

lines.push("return requireModule(nodes['Iris'])");
fs.mkdirSync(path.join(repo, "src"), { recursive: true });
fs.writeFileSync(path.join(repo, "src", "Rere.lua"), lines.join("\n") + "\n");
