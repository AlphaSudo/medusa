const fs = require("fs");

const [deltaPath, targetUrl = "http://localhost:8080"] = process.argv.slice(2);
if (!deltaPath) {
  console.error("Usage: node build-request-seeds-vanilla.js <deltaFile> [targetUrl]");
  process.exit(1);
}

const lines = fs
  .readFileSync(deltaPath, "utf8")
  .split(/\r?\n/)
  .map((l) => l.trim())
  .filter(Boolean);

if (lines.length === 0 || lines[0] === "FULL") {
  process.stdout.write("");
  process.exit(0);
}

function normalizePath(p) {
  let path = String(p || "").trim().replace(/\/+$/, "");
  if (!path) return "/";
  if (!path.startsWith("/")) path = `/${path}`;
  path = path.replace(/\/:(\w+)/g, "/{$1}");
  return path;
}

function concrete(path) {
  return path
    .replace(/\{id\}/g, "1")
    .replace(/\{user_id\}/g, "1")
    .replace(/\{document_id\}/g, "1");
}

const seen = new Set();
const out = ["  - type: requestor", "    requests:"];

for (const raw of lines) {
  if (raw === "FULL") continue;
  const p = concrete(normalizePath(raw));
  const url = `${targetUrl.replace(/\/+$/, "")}${p}`;
  if (seen.has(url)) continue;
  seen.add(url);
  out.push(`      - url: "${url}"`);
  out.push('        method: "GET"');
}

if (out.length === 2) {
  const root = `${targetUrl.replace(/\/+$/, "")}/`;
  out.push(`      - url: "${root}"`);
  out.push('        method: "GET"');
}

process.stdout.write(`${out.join("\n")}\n`);
