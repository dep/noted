import { Buffer } from 'buffer';
import process from 'process';

const g = globalThis as typeof globalThis & {
  Buffer?: typeof Buffer;
  process?: typeof process;
};

if (!g.Buffer) {
  g.Buffer = Buffer;
}

if (!g.process) {
  g.process = process;
} else {
  const existing = g.process as Partial<typeof process>;
  if (!existing.env) existing.env = process.env;
  if (!existing.version) existing.version = process.version;
  if (!existing.nextTick) existing.nextTick = process.nextTick;
}
